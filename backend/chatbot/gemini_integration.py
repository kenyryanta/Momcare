import os
import logging
import time
import json
import hashlib
import google.generativeai as genai
from typing import Dict, Any, Optional, List, Tuple, Union
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, TimeoutError

# Konfigurasi logging dengan rotasi file
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("gemini_integration.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("GeminiIntegration")

class ModelConfig:
    """Konfigurasi model yang dapat disesuaikan"""
    def __init__(
        self,
        temperature: float = 0.7,
        top_p: float = 0.95,
        top_k: int = 40,
        max_output_tokens: int = 1024,
        candidate_count: int = 1,
        stop_sequences: List[str] = None
    ):
        self.temperature = temperature
        self.top_p = top_p
        self.top_k = top_k
        self.max_output_tokens = max_output_tokens
        self.candidate_count = candidate_count
        self.stop_sequences = stop_sequences or []
    
    def to_dict(self) -> Dict[str, Any]:
        """Konversi konfigurasi ke dictionary"""
        return {
            "temperature": self.temperature,
            "top_p": self.top_p,
            "top_k": self.top_k,
            "max_output_tokens": self.max_output_tokens,
            "candidate_count": self.candidate_count,
            "stop_sequences": self.stop_sequences
        }

class ResponseCache:
    """Cache untuk menyimpan respons dari API Gemini"""
    def __init__(self, max_size: int = 100, ttl: int = 3600):
        self.cache = {}
        self.max_size = max_size
        self.ttl = ttl  # Time to live in seconds
    
    def _generate_key(self, prompt: str) -> str:
        """Generate unique key for prompt"""
        return hashlib.md5(prompt.encode()).hexdigest()
    
    def get(self, prompt: str) -> Optional[str]:
        """Get response from cache if exists and not expired"""
        key = self._generate_key(prompt)
        if key in self.cache:
            timestamp, response = self.cache[key]
            if time.time() - timestamp <= self.ttl:
                logger.info(f"Cache hit for prompt: {prompt[:50]}...")
                return response
            else:
                # Remove expired entry
                del self.cache[key]
        return None
    
    def set(self, prompt: str, response: str) -> None:
        """Set response in cache"""
        key = self._generate_key(prompt)
        self.cache[key] = (time.time(), response)
        
        # Remove oldest entries if cache exceeds max size
        if len(self.cache) > self.max_size:
            oldest_key = min(self.cache.keys(), key=lambda k: self.cache[k][0])
            del self.cache[oldest_key]

class GeminiIntegration:
    """Integrasi dengan Gemini API untuk generasi respons"""
    
    AVAILABLE_MODELS = [
        "gemini-2.0-flash", 
        "gemini-2.0-flash-lite", 
        "gemini-1.5-flash", 
        "gemini-1.5-flash-8b"
    ]
    
    def __init__(
        self, 
        model_name: str = 'gemini-2.0-flash',
        fallback_model: str = 'gemini-1.5-flash',
        enable_cache: bool = True,
        cache_size: int = 100,
        cache_ttl: int = 3600,
        timeout: int = 30,
        max_retries: int = 3,
        retry_delay: int = 2
    ):
        # Validasi model
        if model_name not in self.AVAILABLE_MODELS:
            logger.warning(f"Model {model_name} tidak dikenali. Menggunakan model default: gemini-2.0-flash")
            model_name = "gemini-2.0-flash"
            
        # Konfigurasi API key
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            logger.error("GOOGLE_API_KEY tidak ditemukan di environment variables")
            raise ValueError("GOOGLE_API_KEY tidak ditemukan di environment variables")
        
        # Inisialisasi atribut
        self.model_name = model_name
        self.fallback_model = fallback_model
        self.timeout = timeout
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.last_request_time = 0
        self.request_count = 0
        
        # Inisialisasi cache jika diaktifkan
        self.enable_cache = enable_cache
        if enable_cache:
            self.cache = ResponseCache(max_size=cache_size, ttl=cache_ttl)
        
        try:
            # Konfigurasi Gemini API
            genai.configure(api_key=api_key)
            
            # Inisialisasi model utama
            self.model = genai.GenerativeModel(model_name)
            logger.info(f"Model utama '{model_name}' berhasil diinisialisasi")
            
            # Inisialisasi model fallback
            if fallback_model != model_name:
                self.fallback_model_instance = genai.GenerativeModel(fallback_model)
                logger.info(f"Model fallback '{fallback_model}' berhasil diinisialisasi")
            else:
                self.fallback_model_instance = None
                
        except Exception as e:
            logger.error(f"Gagal menginisialisasi model Gemini: {str(e)}")
            raise
    
    def generate_response(
        self, 
        user_message: str, 
        nlp_result: Dict[str, Any], 
        kb_data: Dict[str, Any],
        model_config: Optional[ModelConfig] = None
    ) -> str:
        """Generate response using Gemini API with advanced error handling and retries"""
        
        # Format knowledge base data for prompt
        kb_context = self._format_kb_data(kb_data)
        
        # Buat prompt dengan konteks
        prompt = self._create_prompt(user_message, nlp_result, kb_context)
        
        # Log prompt untuk debugging (hanya sebagian untuk menghindari log yang terlalu panjang)
        logger.debug(f"Prompt untuk Gemini (truncated): {prompt[:200]}...")
        
        # Cek cache jika diaktifkan
        if self.enable_cache:
            cached_response = self.cache.get(prompt)
            if cached_response:
                return cached_response
        
        # Gunakan konfigurasi default jika tidak disediakan
        if not model_config:
            model_config = ModelConfig()
        
        # Catat waktu permintaan untuk rate limiting
        current_time = time.time()
        time_since_last_request = current_time - self.last_request_time
        self.last_request_time = current_time
        self.request_count += 1
        
        # Log statistik permintaan
        logger.info(f"Request #{self.request_count}, time since last request: {time_since_last_request:.2f}s")
        
        # Coba generate response dengan model utama dan retries
        for attempt in range(1, self.max_retries + 1):
            try:
                # Gunakan ThreadPoolExecutor untuk menerapkan timeout
                with ThreadPoolExecutor(max_workers=1) as executor:
                    future = executor.submit(
                        self._call_gemini_api,
                        prompt=prompt,
                        model=self.model,
                        model_name=self.model_name,
                        config=model_config
                    )
                    
                    # Tunggu hasil dengan timeout
                    response_text = future.result(timeout=self.timeout)
                    
                    # Simpan ke cache jika berhasil dan cache diaktifkan
                    if self.enable_cache:
                        self.cache.set(prompt, response_text)
                    
                    return response_text
                    
            except TimeoutError:
                logger.warning(f"Timeout pada percobaan {attempt}/{self.max_retries} untuk model {self.model_name}")
                
            except Exception as e:
                logger.error(f"Error pada percobaan {attempt}/{self.max_retries} untuk model {self.model_name}: {str(e)}")
                
            # Jika masih ada percobaan tersisa, tunggu sebelum mencoba lagi
            if attempt < self.max_retries:
                delay = self.retry_delay * attempt  # Exponential backoff
                logger.info(f"Menunggu {delay} detik sebelum percobaan berikutnya...")
                time.sleep(delay)
        
        # Jika semua percobaan gagal dan ada model fallback, coba gunakan model fallback
        if self.fallback_model_instance:
            logger.info(f"Mencoba menggunakan model fallback: {self.fallback_model}")
            try:
                response_text = self._call_gemini_api(
                    prompt=prompt,
                    model=self.fallback_model_instance,
                    model_name=self.fallback_model,
                    config=model_config
                )
                return response_text
            except Exception as e:
                logger.error(f"Error saat menggunakan model fallback: {str(e)}")
        
        # Jika semua upaya gagal, kembalikan pesan error
        error_message = f"Maaf, terjadi kesalahan saat memproses pertanyaan Anda. Semua upaya untuk menggunakan Gemini API gagal setelah {self.max_retries} percobaan."
        logger.error(error_message)
        return error_message
    
    def _call_gemini_api(
        self, 
        prompt: str, 
        model: Any, 
        model_name: str,
        config: ModelConfig
    ) -> str:
        """Helper method to call Gemini API with proper error handling"""
        try:
            # Catat waktu mulai untuk mengukur latensi
            start_time = time.time()
            
            # Panggil API dengan konfigurasi yang diberikan
            response = model.generate_content(
                prompt,
                generation_config=config.to_dict()
            )
            
            # Hitung latensi
            latency = time.time() - start_time
            logger.info(f"Berhasil mendapatkan respons dari model {model_name} (latency: {latency:.2f}s)")
            
            # Ekstrak dan kembalikan teks respons
            return response.text
            
        except genai.types.generation_types.StopCandidateException as e:
            # Handle safety filter blocks
            logger.warning(f"Respons dari model {model_name} diblokir oleh safety filter: {str(e)}")
            return f"Maaf, saya tidak dapat memberikan respons untuk pertanyaan tersebut karena batasan keamanan. Detail: {str(e)}"
            
        except Exception as e:
            # Re-raise exception untuk ditangani oleh caller
            logger.error(f"Error saat memanggil model {model_name}: {str(e)}")
            raise
    
    def _create_prompt(self, user_message: str, nlp_result: Dict[str, Any], kb_context: str) -> str:
        """Create a well-structured prompt for Gemini with advanced personalization"""
        # Template dasar untuk system prompt
        system_prompt = """Kamu adalah chatbot stunting yang membantu memberikan informasi tentang nutrisi kehamilan dan pencegahan stunting.
Berikan jawaban yang informatif, akurat, dan mudah dipahami dalam Bahasa Indonesia.
Gunakan data yang disediakan untuk memberikan informasi yang spesifik.
Jika tidak yakin atau tidak memiliki informasi yang cukup, sampaikan dengan jujur.
Format respons dengan rapi menggunakan paragraf dan poin-poin untuk memudahkan pembacaan."""

        # Ekstrak informasi dari NLP result
        intent = nlp_result.get('intent', 'general_query')
        entities = nlp_result.get('entities', {})
        context = nlp_result.get('context', [])
        confidence = nlp_result.get('confidence', 0.0)
        
        # Customize prompt based on intent dengan detail lebih spesifik
        intent_context = ""
        if intent == "nutrisi_kehamilan":
            intent_context = """Fokus pada informasi nutrisi kehamilan dan rekomendasi makanan yang sehat.
Berikan informasi tentang kebutuhan kalori, protein, dan nutrisi penting lainnya.
Jelaskan manfaat nutrisi tersebut untuk perkembangan janin dan kesehatan ibu.
Berikan contoh menu harian yang seimbang jika memungkinkan."""
            
            # Tambahkan konteks spesifik trimester jika ada
            if 'trimester' in entities:
                trimester = entities['trimester']
                intent_context += f"\nFokus pada kebutuhan nutrisi khusus untuk trimester {trimester}."
                
        elif intent == "detail_nutrisi":
            intent_context = """Berikan detail lengkap tentang kandungan nutrisi dan manfaatnya untuk ibu hamil.
Jelaskan kandungan protein, lemak, karbohidrat, vitamin, dan mineral.
Jelaskan bagaimana nutrisi tersebut mempengaruhi perkembangan janin.
Berikan informasi tentang porsi yang direkomendasikan dan cara penyajian terbaik."""
            
            # Tambahkan konteks spesifik makanan jika ada
            if 'food_item' in entities:
                food_item = entities['food_item']
                intent_context += f"\nFokus pada detail nutrisi {food_item} dan manfaatnya untuk ibu hamil."
                
        elif intent == "pencegahan_stunting":
            intent_context = """Jelaskan cara-cara efektif untuk mencegah stunting pada anak.
Berikan informasi tentang faktor risiko stunting dan cara mengatasinya.
Jelaskan pentingnya nutrisi selama 1000 hari pertama kehidupan.
Berikan rekomendasi praktis yang dapat diterapkan oleh keluarga."""
        
        # Tambahkan timestamp untuk konteks waktu
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Buat prompt lengkap dengan semua konteks
        prompt = f"""{system_prompt}

Waktu saat ini: {timestamp}

Pertanyaan pengguna: {user_message}

Intent terdeteksi: {intent} (confidence: {confidence:.2f})
Entities terdeteksi: {entities}
Context: {context}

{intent_context}

Data relevan:
{kb_context}

Berikan respons yang natural, informatif, dan personal berdasarkan data di atas.
Gunakan bahasa yang ramah dan mudah dipahami.
Jika ada informasi yang tidak lengkap, sampaikan dengan jujur dan berikan alternatif yang mungkin berguna.
"""
        return prompt
    
    def _format_kb_data(self, kb_data: Dict[str, Any]) -> str:
        """Format knowledge base data for Gemini prompt with improved structure"""
        formatted_text = ""
        
        # Format data nutrisi trimester
        if 'trimester_nutrition' in kb_data and kb_data['trimester_nutrition']:
            tn = kb_data['trimester_nutrition']
            formatted_text += f"=== INFORMASI NUTRISI {tn['trimester'].replace('_', ' ').upper()} ===\n"
            formatted_text += f"- Kebutuhan kalori: {tn['calorie_needs']}\n"
            formatted_text += f"- Kebutuhan protein: {tn['protein_needs']}\n"
            formatted_text += "- Nutrisi penting:\n"
            
            for nutrient in tn['key_nutrients']:
                formatted_text += f"  * {nutrient['name']} ({nutrient['amount']})\n"
                formatted_text += f"    Fungsi: {nutrient['importance']}\n"
                formatted_text += f"    Sumber: {', '.join(nutrient['sources'])}\n"
            
            formatted_text += f"- Rekomendasi: {tn['recommendations']}\n"
            formatted_text += f"- Masalah umum: {', '.join(tn['common_issues'])}\n\n"
        
        # Format data nutrisi makanan
        if 'food_nutrition' in kb_data and kb_data['food_nutrition']:
            fn = kb_data['food_nutrition']
            formatted_text += f"=== DETAIL NUTRISI {fn['name'].upper()} ===\n"
            formatted_text += f"Kategori: {fn['category']}\n"
            formatted_text += f"Porsi: {fn['portion']}\n\n"
            formatted_text += "Kandungan nutrisi:\n"
            formatted_text += f"- Protein: {fn['nutrients']['protein']}\n"
            formatted_text += f"- Lemak: {fn['nutrients']['lemak']}\n"
            formatted_text += f"- Karbohidrat: {fn['nutrients']['karbohidrat']}\n"
            formatted_text += f"- Kalori: {fn['nutrients']['kalori']}\n"
            
            if 'vitamin' in fn['nutrients']:
                formatted_text += f"- Vitamin: {', '.join(fn['nutrients']['vitamin'])}\n"
            
            if 'mineral' in fn['nutrients']:
                formatted_text += f"- Mineral: {', '.join(fn['nutrients']['mineral'])}\n"
            
            formatted_text += f"\nManfaat untuk kehamilan:\n{fn['benefits_pregnancy']}\n\n"
        
        # Format rekomendasi makanan
        if 'food_recommendations' in kb_data and kb_data['food_recommendations']:
            formatted_text += "=== REKOMENDASI MAKANAN ===\n"
            
            for category in kb_data['food_recommendations']:
                formatted_text += f"Kategori: {category['category']} ({category['description']})\n"
                
                for food in category['foods']:
                    formatted_text += f"- {food['name']} (Porsi: {food.get('portion', 'N/A')})\n"
                    formatted_text += f"  Manfaat: {food['benefits']}\n"
            
            formatted_text += "\n"
        
        # Format data pencegahan stunting
        # Format data pencegahan stunting
        if 'stunting_prevention' in kb_data and kb_data['stunting_prevention']:
            formatted_text += "=== PENCEGAHAN STUNTING ===\n"
            
            for item in kb_data['stunting_prevention']:
                formatted_text += f"- {item['factor']} (Prioritas: {item['importance']})\n"
                formatted_text += f"  Detail: {item['description']}\n\n"
        
        return formatted_text
    
    def test_connection(self) -> bool:
        """Test connection to Gemini API"""
        try:
            response = self.model.generate_content("Hello, are you working?")
            logger.info("Koneksi ke Gemini API berhasil")
            return True
        except Exception as e:
            logger.error(f"Koneksi ke Gemini API gagal: {str(e)}")
            return False
            
    def get_model_info(self) -> Dict[str, Any]:
        """Get information about the current model configuration"""
        return {
            "primary_model": self.model_name,
            "fallback_model": self.fallback_model,
            "cache_enabled": self.enable_cache,
            "max_retries": self.max_retries,
            "timeout": self.timeout,
            "available_models": self.AVAILABLE_MODELS
        }

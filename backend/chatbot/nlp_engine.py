import nltk
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords
import re
from typing import Dict, List, Tuple, Any

class NLPEngine:
    def __init__(self):
        self.lemmatizer = WordNetLemmatizer()
        try:
            self.stop_words = set(stopwords.words('indonesian'))
        except:
            self.stop_words = set(stopwords.words('english'))
        
        # Keywords for intent detection
        self.intent_keywords = {
            'nutrisi_kehamilan': ['nutrisi', 'makanan', 'kehamilan', 'hamil', 'makan', 'trimester'],
            'detail_nutrisi': ['detail', 'nutrisi', 'kandungan', 'gizi', 'komposisi', 'vitamin', 'mineral'],
            'pencegahan_stunting': ['cegah', 'stunting', 'pencegahan', 'mencegah', 'hindari', 'pendek'],
            'greeting': ['halo', 'hai', 'hi', 'selamat', 'pagi', 'siang', 'malam']
        }
        
        # Keywords for entity detection
        self.entity_keywords = {
            'trimester_pertama': ['trimester pertama', 'trimester 1', 'awal kehamilan'],
            'trimester_kedua': ['trimester kedua', 'trimester 2', 'tengah kehamilan'],
            'trimester_ketiga': ['trimester ketiga', 'trimester 3', 'akhir kehamilan'],
            'telur': ['telur', 'telor'],
            'ikan_salmon': ['ikan salmon', 'salmon'],
            'ikan': ['ikan', 'tuna', 'lele', 'kembung'],
            'daging': ['daging', 'ayam', 'sapi'],
            'bayam': ['bayam'],
            'brokoli': ['brokoli'],
            'kacang': ['kacang', 'kacang-kacangan']
        }
    
    def process_message(self, message: str) -> Dict[str, Any]:
        """Process user message to extract intent, entities, and context"""
        # Clean and tokenize message
        cleaned_message = self._clean_text(message)
        tokens = word_tokenize(cleaned_message)
        
        # Detect intent
        intent = self._detect_intent(cleaned_message)
        
        # Recognize entities
        entities = self._recognize_entities(cleaned_message)
        
        # Analyze context
        context = self._analyze_context(cleaned_message, intent, entities)
        
        # Calculate confidence
        confidence = self._calculate_confidence(intent, entities, context)
        
        return {
            'intent': intent,
            'entities': entities,
            'context': context,
            'confidence': confidence
        }
    
    def _clean_text(self, text: str) -> str:
        """Clean text by removing special characters and converting to lowercase"""
        text = text.lower()
        text = re.sub(r'[^\w\s]', ' ', text)
        return text
    
    def _detect_intent(self, message: str) -> str:
        """Detect the intent of the message"""
        # Count keyword matches for each intent
        intent_scores = {}
        for intent, keywords in self.intent_keywords.items():
            score = sum(1 for keyword in keywords if keyword in message)
            intent_scores[intent] = score
        
        # Get intent with highest score
        if any(intent_scores.values()):
            max_intent = max(intent_scores.items(), key=lambda x: x[1])
            if max_intent[1] > 0:
                return max_intent[0]
        
        # Default to general query
        return 'general_query'
    
    def _recognize_entities(self, message: str) -> Dict[str, str]:
        """Extract entities from the message"""
        entities = {}
        
        # Check for trimester entities
        for entity_type, keywords in self.entity_keywords.items():
            for keyword in keywords:
                if keyword in message:
                    if entity_type.startswith('trimester_'):
                        entities['trimester'] = entity_type.split('_')[1]
                    else:
                        entities['food_item'] = entity_type
        
        return entities
    
    def _analyze_context(self, message: str, intent: str, entities: Dict[str, str]) -> List[str]:
        """Analyze the context of the conversation"""
        context = []
        
        if intent == 'nutrisi_kehamilan':
            context.append('rekomendasi_makanan')
        
        if 'trimester' in entities:
            context.append(f"trimester_{entities['trimester']}")
        
        if intent == 'detail_nutrisi' and 'food_item' in entities:
            context.append('detail_makanan')
        
        if 'makanan' in message or 'makan' in message:
            context.append('rekomendasi_makanan')
        
        return context
    
    def _calculate_confidence(self, intent: str, entities: Dict[str, str], context: List[str]) -> float:
        """Calculate confidence score for the NLP results"""
        # Base confidence
        confidence = 0.5
        
        # Increase confidence if we have a specific intent
        if intent != 'general_query':
            confidence += 0.2
        
        # Increase confidence if we have entities
        if entities:
            confidence += 0.2
        
        # Increase confidence if we have context
        if context:
            confidence += 0.1
        
        # Cap at 1.0
        return min(confidence, 1.0)

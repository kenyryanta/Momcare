import json
import os
from typing import Dict, Any, List

def load_json_data(file_path: str) -> Dict[str, Any]:
    """Load data from JSON file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error loading JSON file {file_path}: {e}")
        return {}

def save_json_data(data: Dict[str, Any], file_path: str) -> bool:
    """Save data to JSON file"""
    try:
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)
            
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(data, file, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"Error saving JSON file {file_path}: {e}")
        return False

def create_sample_data():
    """Create sample data files for the chatbot"""
    # Create data directory
    os.makedirs('chatbot/data', exist_ok=True)
    
    # Trimester nutrition data
    trimester_nutrition = {
        "trimester_nutrition": [
            {
                "trimester": "trimester_pertama",
                "calorie_needs": "Tambahan 300 kalori/hari",
                "protein_needs": "60g/hari (peningkatan dari 46g/hari)",
                "key_nutrients": [
                    {"name": "Folat", "amount": "600μg/hari", "importance": "Mencegah cacat tabung saraf", "sources": ["Sayuran hijau", "Kacang-kacangan", "Jeruk"]},
                    {"name": "Zat Besi", "amount": "27mg/hari", "importance": "Mencegah anemia", "sources": ["Daging merah", "Bayam", "Kacang-kacangan"]},
                    {"name": "Kalsium", "amount": "1000mg/hari", "importance": "Pembentukan tulang janin", "sources": ["Susu", "Keju", "Yogurt"]}
                ],
                "recommendations": "Makan porsi kecil tapi sering untuk mengatasi mual, hindari makanan berminyak dan pedas",
                "common_issues": ["Morning sickness", "Mual", "Muntah", "Kelelahan"]
            },
            {
                "trimester": "trimester_kedua",
                "calorie_needs": "Tambahan 300 kalori/hari",
                "protein_needs": "60g/hari",
                "key_nutrients": [
                    {"name": "Omega-3", "amount": "200-300mg DHA/hari", "importance": "Perkembangan otak janin", "sources": ["Ikan salmon", "Sarden", "Minyak ikan"]},
                    {"name": "Kalsium", "amount": "1000mg/hari", "importance": "Pembentukan tulang dan gigi janin", "sources": ["Susu", "Yogurt", "Keju"]},
                    {"name": "Vitamin D", "amount": "15μg/hari", "importance": "Penyerapan kalsium", "sources": ["Ikan berlemak", "Telur", "Susu fortifikasi"]}
                ],
                "recommendations": "Fokus pada makanan bergizi tinggi, hindari makanan olahan dan tinggi gula",
                "common_issues": ["Sembelit", "Sakit punggung", "Heartburn"]
            },
            {
                "trimester": "trimester_ketiga",
                "calorie_needs": "Tambahan 300 kalori/hari",
                "protein_needs": "60g/hari",
                "key_nutrients": [
                    {"name": "Zat Besi", "amount": "27mg/hari", "importance": "Mencegah anemia dan mempersiapkan persalinan", "sources": ["Daging merah", "Bayam", "Hati"]},
                    {"name": "Vitamin K", "amount": "90μg/hari", "importance": "Pembekuan darah", "sources": ["Sayuran hijau", "Brokoli", "Bayam"]},
                    {"name": "Magnesium", "amount": "350-360mg/hari", "importance": "Mencegah kelahiran prematur", "sources": ["Kacang-kacangan", "Biji-bijian", "Sayuran hijau"]}
                ],
                "recommendations": "Makan makanan tinggi serat, hindari makanan tinggi sodium, minum banyak air",
                "common_issues": ["Heartburn", "Sesak napas", "Kram kaki", "Sulit tidur"]
            }
        ]
    }
    
    # Food recommendations data
    food_recommendations = {
        "food_recommendations": [
            {
                "category": "protein",
                "description": "Untuk pertumbuhan janin",
                "foods": [
                    {
                        "name": "Telur",
                        "portion": "1 butir (50g)",
                        "benefits": "Sumber protein lengkap, kolin untuk perkembangan otak"
                    },
                    {
                        "name": "Ikan salmon",
                        "portion": "85-140g, 2-3x seminggu",
                        "benefits": "Omega-3 untuk perkembangan otak janin"
                    },
                    {
                        "name": "Daging tanpa lemak",
                        "portion": "85g/hari",
                        "benefits": "Zat besi heme yang mudah diserap"
                    }
                ]
            },
            {
                "category": "sayuran",
                "description": "Untuk zat besi dan folat",
                "foods": [
                    {
                        "name": "Bayam",
                        "portion": "1 mangkuk (30g)",
                        "benefits": "Kaya zat besi, folat, dan vitamin K"
                    },
                    {
                        "name": "Brokoli",
                        "portion": "1 mangkuk (30g)",
                        "benefits": "Kaya folat, kalsium, dan serat"
                    },
                    {
                        "name": "Kacang-kacangan",
                        "portion": "1/2 mangkuk (100g)",
                        "benefits": "Sumber protein nabati dan serat"
                    }
                ]
            }
        ]
    }
    
    # Food nutrition details data
    food_nutrition_details = {
        "food_nutrition_details": [
            {
                "name": "telur",
                "category": "Protein",
                "portion": "1 butir (50g)",
                "nutrients": {
                    "protein": "6g",
                    "lemak": "5g",
                    "karbohidrat": "0.6g",
                    "kalori": "70",
                    "vitamin": ["A", "D", "E", "K", "B12"],
                    "mineral": ["Zat besi", "Selenium", "Fosfor"]
                },
                "benefits_pregnancy": "Membantu perkembangan otak janin, sumber protein lengkap, mengandung kolin untuk perkembangan saraf"
            },
            {
                "name": "ikan_salmon",
                "category": "Protein",
                "portion": "100g",
                "nutrients": {
                    "protein": "22g",
                    "lemak": "13g",
                    "karbohidrat": "0g",
                    "kalori": "206",
                    "vitamin": ["D", "B12"],
                    "mineral": ["Selenium", "Fosfor"]
                },
                "benefits_pregnancy": "Kaya omega-3 untuk perkembangan otak janin, menurunkan risiko kelahiran prematur"
            },
            {
                "name": "bayam",
                "category": "Sayuran",
                "portion": "100g",
                "nutrients": {
                    "protein": "2.9g",
                    "lemak": "0.4g",
                    "karbohidrat": "3.6g",
                    "kalori": "23",
                    "vitamin": ["A", "C", "K", "Folat"],
                    "mineral": ["Zat besi", "Kalsium", "Magnesium"]
                },
                "benefits_pregnancy": "Mencegah anemia, mendukung perkembangan tulang, meningkatkan sistem kekebalan tubuh"
            },
            {
                "name": "brokoli",
                "category": "Sayuran",
                "portion": "100g",
                "nutrients": {
                    "protein": "2.8g",
                    "lemak": "0.4g",
                    "karbohidrat": "6.6g",
                    "kalori": "34",
                    "vitamin": ["C", "K", "Folat"],
                    "mineral": ["Kalsium", "Kalium"]
                },
                "benefits_pregnancy": "Mendukung perkembangan tulang janin, mencegah cacat tabung saraf"
            }
        ]
    }
    
    # Stunting prevention data
    stunting_prevention = {
        "stunting_prevention": [
            {
                "factor": "ASI eksklusif",
                "importance": "Tinggi",
                "description": "Berikan ASI eksklusif selama 6 bulan pertama untuk memberikan nutrisi optimal dan meningkatkan sistem kekebalan tubuh bayi"
            },
            {
                "factor": "Nutrisi ibu hamil",
                "importance": "Tinggi",
                "description": "Pastikan ibu hamil mendapatkan nutrisi yang cukup, terutama protein, zat besi, asam folat, dan kalsium"
            },
            {
                "factor": "MPASI bergizi",
                "importance": "Tinggi",
                "description": "Berikan makanan pendamping ASI yang bergizi dan beragam setelah bayi berusia 6 bulan"
            },
            {
                "factor": "Pemantauan pertumbuhan",
                "importance": "Sedang",
                "description": "Pantau pertumbuhan anak secara teratur di posyandu atau fasilitas kesehatan"
            },
            {
                "factor": "Sanitasi dan kebersihan",
                "importance": "Sedang",
                "description": "Jaga kebersihan lingkungan, cuci tangan dengan sabun, dan pastikan akses ke air bersih untuk mencegah infeksi dan diare"
            },
            {
                "factor": "Imunisasi lengkap",
                "importance": "Sedang",
                "description": "Berikan imunisasi lengkap sesuai jadwal untuk melindungi anak dari penyakit infeksi yang dapat menghambat pertumbuhan"
            }
        ]
    }
    
    # Save data to files
    save_json_data(trimester_nutrition, 'chatbot/data/trimester_nutrition.json')
    save_json_data(food_recommendations, 'chatbot/data/food_recommendations.json')
    save_json_data(food_nutrition_details, 'chatbot/data/food_nutrition_details.json')
    save_json_data(stunting_prevention, 'chatbot/data/stunting_prevention.json')
    
    print("Sample data created successfully!")

def validate_api_response(response_data: Dict[str, Any]) -> bool:
    """Validate API response data"""
    required_fields = ['response']
    return all(field in response_data for field in required_fields)

def format_chat_history(messages: List[Dict[str, Any]]) -> str:
    """Format chat history for display"""
    formatted_history = ""
    for msg in messages:
        sender = "User" if msg.get('is_user', False) else "Bot"
        timestamp = msg.get('timestamp', '')[:16].replace('T', ' ')  # Format: YYYY-MM-DD HH:MM
        content = msg.get('content', '')
        formatted_history += f"[{timestamp}] {sender}: {content}\n\n"
    return formatted_history

def extract_entities_from_message(message: str) -> Dict[str, str]:
    """Simple entity extraction from message (fallback method)"""
    entities = {}
    
    # Extract trimester
    if 'trimester pertama' in message.lower() or 'trimester 1' in message.lower():
        entities['trimester'] = 'pertama'
    elif 'trimester kedua' in message.lower() or 'trimester 2' in message.lower():
        entities['trimester'] = 'kedua'
    elif 'trimester ketiga' in message.lower() or 'trimester 3' in message.lower():
        entities['trimester'] = 'ketiga'
    
    # Extract food items
    food_items = {
        'telur': ['telur', 'telor'],
        'ikan_salmon': ['ikan salmon', 'salmon'],
        'bayam': ['bayam'],
        'brokoli': ['brokoli']
    }
    
    for food, keywords in food_items.items():
        if any(keyword in message.lower() for keyword in keywords):
            entities['food_item'] = food
            break
    
    return entities
               

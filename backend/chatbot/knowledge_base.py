import json
import os
from typing import Dict, List, Any, Optional

class KnowledgeBase:
    def __init__(self, data_path: str = "chatbot/data"):
        self.data_path = data_path
        
        # Create data directory if it doesn't exist
        os.makedirs(self.data_path, exist_ok=True)
        
        # Load data or create default data if files don't exist
        self.trimester_nutrition = self._load_json("trimester_nutrition.json")
        self.food_recommendations = self._load_json("food_recommendations.json")
        self.food_nutrition_details = self._load_json("food_nutrition_details.json")
        self.stunting_prevention = self._load_json("stunting_prevention.json")
        
        # Create default data if not loaded
        if not self.trimester_nutrition:
            self._create_default_data()
            
            # Reload data
            self.trimester_nutrition = self._load_json("trimester_nutrition.json")
            self.food_recommendations = self._load_json("food_recommendations.json")
            self.food_nutrition_details = self._load_json("food_nutrition_details.json")
            self.stunting_prevention = self._load_json("stunting_prevention.json")
        
        # In-memory storage for user preferences
        self.user_preferences = {}
    
    def _load_json(self, filename: str) -> Dict:
        """Load data from JSON file"""
        try:
            with open(f"{self.data_path}/{filename}", "r", encoding="utf-8") as file:
                return json.load(file)
        except (FileNotFoundError, json.JSONDecodeError):
            # Return empty dict if file doesn't exist or is invalid
            return {}
    
    def _save_json(self, data: Dict, filename: str) -> bool:
        """Save data to JSON file"""
        try:
            with open(f"{self.data_path}/{filename}", "w", encoding="utf-8") as file:
                json.dump(data, file, ensure_ascii=False, indent=2)
            return True
        except Exception as e:
            print(f"Error saving JSON file {filename}: {e}")
            return False
    
    def _create_default_data(self):
        """Create default data files"""
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
        self._save_json(trimester_nutrition, "trimester_nutrition.json")
        self._save_json(food_recommendations, "food_recommendations.json")
        self._save_json(food_nutrition_details, "food_nutrition_details.json")
        self._save_json(stunting_prevention, "stunting_prevention.json")
        
        print("Default data created successfully!")
    
    def get_trimester_nutrition(self, trimester: str) -> Optional[Dict]:
        """Get nutrition information for a specific trimester"""
        trimester_data = self.trimester_nutrition.get("trimester_nutrition", [])
        for item in trimester_data:
            if item.get("trimester") == trimester:
                return item
        return None
    
    def get_food_recommendations(self, category: Optional[str] = None) -> List[Dict]:
        """Get food recommendations, optionally filtered by category"""
        recommendations = self.food_recommendations.get("food_recommendations", [])
        if category:
            return [r for r in recommendations if r.get("category") == category]
        return recommendations
    
    def get_food_nutrition(self, food_name: str) -> Optional[Dict]:
        """Get detailed nutrition information for a specific food"""
        food_data = self.food_nutrition_details.get("food_nutrition_details", [])
        for item in food_data:
            if item.get("name", "").lower() == food_name.lower():
                return item
        return None
    
    def get_stunting_prevention(self) -> List[Dict]:
        """Get stunting prevention information"""
        return self.stunting_prevention.get("stunting_prevention", [])
    
    def get_user_preferences(self, user_id: str) -> Dict:
        """Get user preferences"""
        return self.user_preferences.get(user_id, {})
    
    def update_user_preferences(self, user_id: str, preferences: Dict) -> bool:
        """Update user preferences"""
        if user_id not in self.user_preferences:
            self.user_preferences[user_id] = {}
        self.user_preferences[user_id].update(preferences)
        return True
    
    def get_relevant_data(self, intent: str, entities: Dict, context: List[str]) -> Dict[str, Any]:
        """Get relevant data based on intent, entities and context"""
        result = {}
        
        # Handle nutrition intent
        if intent == 'nutrisi_kehamilan':
            trimester = None
            for key, value in entities.items():
                if key == "trimester":
                    trimester = f"trimester_{value}"
            
            if trimester:
                result["trimester_nutrition"] = self.get_trimester_nutrition(trimester)
            
            if "rekomendasi_makanan" in context:
                result["food_recommendations"] = self.get_food_recommendations()
        
        # Handle detail nutrition intent
        elif intent == 'detail_nutrisi':
            food_item = None
            for key, value in entities.items():
                if key == "food_item":
                    food_item = value
            
            if food_item:
                result["food_nutrition"] = self.get_food_nutrition(food_item)
        
        # Handle stunting prevention intent
        elif intent == 'pencegahan_stunting':
            result["stunting_prevention"] = self.get_stunting_prevention()
        
        return result

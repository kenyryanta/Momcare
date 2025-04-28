from typing import Dict, List, Any, Optional
import random

class ResponseGenerator:
    def __init__(self):
        # Default responses for different intents
        self.default_responses = {
            'greeting': [
                'Halo! Selamat datang di Chatbot Stunting. Apa yang ingin Anda ketahui tentang nutrisi kehamilan atau pencegahan stunting?',
                'Hai! Saya siap membantu Anda dengan informasi seputar nutrisi kehamilan dan pencegahan stunting. Apa yang ingin Anda tanyakan?'
            ],
            'general_query': [
                'Maaf, saya tidak memahami pertanyaan Anda. Bisa diulangi dengan kata-kata berbeda?',
                'Saya belum mengerti maksud Anda. Coba tanyakan tentang nutrisi kehamilan, makanan untuk trimester tertentu, atau cara mencegah stunting.'
            ]
        }
    
    def generate_response(self, nlp_result: Dict[str, Any], kb_data: Dict[str, Any], user_preferences: Dict[str, Any]) -> str:
        """Generate response based on NLP result and knowledge base data"""
        intent = nlp_result.get('intent', 'general_query')
        entities = nlp_result.get('entities', {})
        context = nlp_result.get('context', [])
        
        # Handle greetings
        if intent == 'greeting':
            return random.choice(self.default_responses['greeting'])
        
        # Handle general queries with low confidence
        if nlp_result.get('confidence', 0) < 0.7:
            return random.choice(self.default_responses['general_query'])
        
        # Handle nutrition queries
        if intent == 'nutrisi_kehamilan':
            return self._format_nutrition_response(kb_data, entities, user_preferences)
        
        # Handle detail nutrition queries
        if intent == 'detail_nutrisi':
            return self._format_food_nutrition_response(kb_data)
        
        # Handle stunting prevention queries
        if intent == 'pencegahan_stunting':
            return self._format_stunting_prevention_response(kb_data)
        
        # Default response
        return random.choice(self.default_responses['general_query'])
    
    def _format_nutrition_response(self, kb_data: Dict[str, Any], entities: Dict[str, str], user_preferences: Dict[str, Any]) -> str:
        """Format response for nutrition queries"""
        response = ""
        
        # Add trimester nutrition information
        if 'trimester_nutrition' in kb_data and kb_data['trimester_nutrition']:
            tn = kb_data['trimester_nutrition']
            trimester_name = tn['trimester'].replace('_', ' ')
            
            response += f"Untuk {trimester_name}, berikut rekomendasi nutrisi:\n\n"
            response += f"• Kebutuhan kalori: {tn['calorie_needs']}\n"
            response += f"• Kebutuhan protein: {tn['protein_needs']}\n\n"
            
            response += "Nutrisi penting:\n"
            for nutrient in tn['key_nutrients']:
                response += f"• {nutrient['name']} ({nutrient['amount']}): {nutrient['importance']}\n"
                response += f"  Sumber: {', '.join(nutrient['sources'])}\n"
            
            response += f"\nRekomendasi: {tn['recommendations']}\n"
        
        # Add food recommendations
        if 'food_recommendations' in kb_data:
            if not response:
                response = "Berikut rekomendasi makanan untuk ibu hamil:\n\n"
            else:
                response += "\nRekomendasi makanan:\n"
            
            for category in kb_data['food_recommendations']:
                response += f"\n• Kategori {category['category']}:\n"
                for food in category['foods']:
                    response += f"  - {food['name']}: {food['benefits']}\n"
        
        # If no data found
        if not response:
            trimester = entities.get('trimester', '')
            if trimester:
                response = f"Maaf, saya tidak memiliki informasi spesifik untuk trimester {trimester}. Secara umum, ibu hamil memerlukan tambahan 300 kalori per hari dan protein 60g per hari."
            else:
                response = "Nutrisi yang baik sangat penting selama kehamilan. Pastikan untuk mengonsumsi makanan yang kaya protein, zat besi, asam folat, dan kalsium. Konsultasikan dengan dokter atau ahli gizi untuk rekomendasi yang lebih spesifik."
        
        # Add personalized note if user has preferences
        if user_preferences:
            if 'allergies' in user_preferences:
                allergies = user_preferences['allergies']
                response += f"\n\nCatatan: Berdasarkan informasi yang Anda berikan, Anda memiliki alergi terhadap {', '.join(allergies)}. Harap hindari makanan tersebut dan konsultasikan dengan dokter."
        
        return response
    
    def _format_food_nutrition_response(self, kb_data: Dict[str, Any]) -> str:
        """Format response for food nutrition queries"""
        if 'food_nutrition' not in kb_data or not kb_data['food_nutrition']:
            return "Maaf, saya tidak memiliki informasi detail tentang makanan tersebut."
        
        fn = kb_data['food_nutrition']
        response = f"Detail nutrisi {fn['name']} (per {fn['portion']}):\n\n"
        response += f"• Protein: {fn['nutrients']['protein']}\n"
        response += f"• Lemak: {fn['nutrients']['lemak']}\n"
        response += f"• Karbohidrat: {fn['nutrients']['karbohidrat']}\n"
        response += f"• Kalori: {fn['nutrients']['kalori']}\n"
        
        if 'vitamin' in fn['nutrients']:
            response += f"• Vitamin: {', '.join(fn['nutrients']['vitamin'])}\n"
        
        if 'mineral' in fn['nutrients']:
            response += f"• Mineral: {', '.join(fn['nutrients']['mineral'])}\n"
        
        response += f"\nManfaat untuk kehamilan: {fn['benefits_pregnancy']}"
        
        return response
    
    def _format_stunting_prevention_response(self, kb_data: Dict[str, Any]) -> str:
        """Format response for stunting prevention queries"""
        if 'stunting_prevention' not in kb_data or not kb_data['stunting_prevention']:
            return "Stunting adalah kondisi gagal tumbuh pada anak akibat kekurangan gizi kronis. Untuk mencegahnya, pastikan nutrisi yang cukup selama kehamilan, berikan ASI eksklusif selama 6 bulan pertama, dan berikan makanan pendamping ASI yang bergizi setelahnya."
        
        prevention_data = kb_data['stunting_prevention']
        response = "Untuk mencegah stunting, berikut adalah hal-hal penting yang perlu diperhatikan:\n\n"
        
        for item in prevention_data:
            response += f"• {item['factor']} (Prioritas: {item['importance']}): {item['description']}\n\n"
        
        response += "Penting untuk memulai pencegahan stunting sejak masa kehamilan dengan memastikan ibu mendapatkan nutrisi yang cukup."
        
        return response
    
    def generate_suggestions(self, intent: str, entities: Dict[str, str], context: List[str]) -> List[str]:
        """Generate suggested follow-up questions"""
        suggestions = []
        
        if intent == 'greeting' or intent == 'general_query':
            suggestions = [
                "Apa makanan yang baik untuk trimester pertama?",
                "Bagaimana cara mencegah stunting?",
                "Apa kandungan gizi telur untuk ibu hamil?"
            ]
        elif intent == 'nutrisi_kehamilan':
            trimester = entities.get('trimester')
            if trimester:
                other_trimesters = [t for t in ['pertama', 'kedua', 'ketiga'] if t != trimester]
                suggestions.append(f"Apa makanan yang baik untuk trimester {other_trimesters[0]}?")
                suggestions.append(f"Berapa kebutuhan kalori untuk trimester {trimester}?")
            else:
                suggestions = [
                    "Apa makanan yang baik untuk trimester pertama?",
                    "Apa makanan yang baik untuk trimester kedua?",
                    "Apa makanan yang baik untuk trimester ketiga?"
                ]
            
            suggestions.append("Apa saja sumber zat besi untuk ibu hamil?")
        elif intent == 'detail_nutrisi':
            food_item = entities.get('food_item')
            if food_item:
                other_foods = [f for f in ['telur', 'ikan_salmon', 'bayam', 'brokoli'] if f != food_item]
                suggestions = [
                    f"Apa kandungan gizi {other_foods[0]}?",
                    f"Apa kandungan gizi {other_foods[1]}?",
                    f"Bagaimana cara mengolah {food_item} yang baik untuk ibu hamil?"
                ]
            else:
                suggestions = [
                    "Apa kandungan gizi telur?",
                    "Apa kandungan gizi ikan salmon?",
                    "Apa kandungan gizi bayam?"
                ]
        elif intent == 'pencegahan_stunting':
            suggestions = [
                "Apa faktor risiko stunting?",
                "Apakah ASI eksklusif mencegah stunting?",
                "Kapan waktu kritis untuk mencegah stunting?"
            ]
        
        return suggestions

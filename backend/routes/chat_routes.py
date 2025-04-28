from flask import Blueprint, request, jsonify
from chatbot.nlp_engine import NLPEngine
from chatbot.knowledge_base import KnowledgeBase
from chatbot.response_generator import ResponseGenerator
from chatbot.gemini_integration import GeminiIntegration
from models.chat_models import Message, ChatSession
from datetime import datetime
import json
import os
from typing import Dict, List, Any
import openai
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize OpenAI API key if available
openai_api_key = os.getenv("OPENAI_API_KEY")
if openai_api_key:
    openai.api_key = openai_api_key

# Initialize Gemini integration if API key is available
gemini_integration = None
gemini_api_key = os.getenv("GOOGLE_API_KEY")
if gemini_api_key:
    try:
        gemini_integration = GeminiIntegration()
        print("Gemini API initialized successfully")
    except Exception as e:
        print(f"Failed to initialize Gemini API: {e}")

# Initialize blueprint
chat_bp = Blueprint('chat', __name__)

# Initialize chatbot components
nlp_engine = NLPEngine()
knowledge_base = KnowledgeBase()
response_generator = ResponseGenerator()

# In-memory storage for chat sessions
chat_sessions = {}

@chat_bp.route('/chat', methods=['POST'])
def chat():
    """Endpoint for chat interactions"""
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    user_message = data.get('message', '')
    user_id = data.get('user_id', 'anonymous')
    use_openai = data.get('use_openai', False) and openai_api_key is not None
    use_gemini = data.get('use_gemini', False) and gemini_integration is not None
    
    print(f"Request: message='{user_message}', user_id='{user_id}', use_openai={use_openai}, use_gemini={use_gemini}")
    
    if not user_message:
        return jsonify({"error": "No message provided"}), 400
    
    # Get or create chat session
    if user_id not in chat_sessions:
        chat_sessions[user_id] = ChatSession(user_id=user_id)
    
    session = chat_sessions[user_id]
    
    # Add user message to session
    user_msg = Message(content=user_message, is_user=True)
    session.add_message(user_msg)
    
    # Process message with NLP engine
    nlp_result = nlp_engine.process_message(user_message)
    print(f"NLP Result: {nlp_result}")
    
    # Get relevant data from knowledge base
    kb_data = knowledge_base.get_relevant_data(
        nlp_result['intent'],
        nlp_result['entities'],
        nlp_result['context']
    )
    
    # Get user preferences
    user_preferences = knowledge_base.get_user_preferences(user_id)
    
    # Generate response
    response_text = ""
    response_source = "local"
    
    if use_gemini and gemini_integration and nlp_result['confidence'] >= 0.6:
        try:
            # Use Gemini for response generation
            print("Using Gemini API for response generation")
            response_text = gemini_integration.generate_response(
                user_message,
                nlp_result,
                kb_data
            )
            response_source = "gemini"
        except Exception as e:
            print(f"Error using Gemini API: {e}")
            # Fall back to local response generator
            response_text = response_generator.generate_response(
                nlp_result,
                kb_data,
                user_preferences
            )
    elif use_openai and openai_api_key and nlp_result['confidence'] >= 0.6:
        try:
            # Use OpenAI for response generation
            print("Using OpenAI API for response generation")
            response_text = generate_openai_response(
                user_message,
                nlp_result,
                kb_data
            )
            response_source = "openai"
        except Exception as e:
            print(f"Error using OpenAI API: {e}")
            # Fall back to local response generator
            response_text = response_generator.generate_response(
                nlp_result,
                kb_data,
                user_preferences
            )
    else:
        # Use local response generator
        print("Using local response generator")
        response_text = response_generator.generate_response(
            nlp_result,
            kb_data,
            user_preferences
        )
    
    # Generate suggestions
    suggestions = response_generator.generate_suggestions(
        nlp_result['intent'],
        nlp_result['entities'],
        nlp_result['context']
    )
    
    # Add bot message to session
    bot_msg = Message(content=response_text, is_user=False)
    session.add_message(bot_msg)
    
    # Update session context
    session.context.update({
        'last_intent': nlp_result['intent'],
        'last_entities': nlp_result['entities'],
        'last_context': nlp_result['context']
    })
    
    # Save session to file (optional)
    _save_session(session)
    
    return jsonify({
        "response": response_text,
        "suggestions": suggestions,
        "nlp_result": nlp_result,
        "response_source": response_source
    })

@chat_bp.route('/preferences', methods=['POST'])
def update_preferences():
    """Endpoint to update user preferences"""
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    user_id = data.get('user_id', '')
    preferences = data.get('preferences', {})
    
    if not user_id:
        return jsonify({"error": "No user_id provided"}), 400
    
    # Update preferences in knowledge base
    knowledge_base.update_user_preferences(user_id, preferences)
    
    return jsonify({"status": "success", "message": "Preferences updated successfully"})

@chat_bp.route('/history/<user_id>', methods=['GET'])
def get_history(user_id):
    """Endpoint to get chat history for a user"""
    if user_id not in chat_sessions:
        return jsonify({"error": "No chat history found for this user"}), 404
    
    session = chat_sessions[user_id]
    messages = [msg.to_dict() for msg in session.messages]
    
    return jsonify({
        "user_id": user_id,
        "messages": messages
    })

@chat_bp.route('/init-data', methods=['POST'])
def initialize_data():
    """Endpoint to initialize sample data"""
    try:
        # Reinitialize knowledge base to create default data
        global knowledge_base
        knowledge_base = KnowledgeBase()
        return jsonify({"status": "success", "message": "Sample data initialized successfully"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

def generate_openai_response(user_message: str, nlp_result: Dict[str, Any], kb_data: Dict[str, Any]) -> str:
    """Generate response using OpenAI API"""
    try:
        # Format knowledge base data for prompt
        kb_context = _format_kb_data_for_prompt(kb_data)
        
        # Create system message
        system_message = """
        Anda adalah chatbot stunting yang membantu memberikan informasi tentang nutrisi kehamilan dan pencegahan stunting.
        Berikan jawaban yang informatif, akurat, dan mudah dipahami.
        Gunakan data yang disediakan untuk memberikan informasi yang spesifik.
        Jika tidak yakin atau tidak memiliki informasi yang cukup, sampaikan dengan jujur.
        """
        
        # Create user message with context
        user_prompt = f"""
        Pertanyaan pengguna: {user_message}
        
        Intent terdeteksi: {nlp_result['intent']}
        Entities terdeteksi: {nlp_result['entities']}
        
        Data relevan:
        {kb_context}
        
        Berikan respons yang natural dan informatif berdasarkan data di atas.
        """
        
        # Call OpenAI API
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_message},
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=500,
            temperature=0.7
        )
        
        # Extract and return response text
        return response.choices[0].message['content'].strip()
    except Exception as e:
        print(f"Error calling OpenAI API: {e}")
        # Fallback to local response generator
        return f"Maaf, terjadi kesalahan saat memproses pertanyaan Anda dengan OpenAI: {str(e)}"

def _format_kb_data_for_prompt(kb_data: Dict[str, Any]) -> str:
    """Format knowledge base data for prompt"""
    formatted_text = ""
    
    # Format trimester nutrition data
    if 'trimester_nutrition' in kb_data and kb_data['trimester_nutrition']:
        tn = kb_data['trimester_nutrition']
        formatted_text += f"Informasi nutrisi {tn['trimester'].replace('_', ' ')}:\n"
        formatted_text += f"- Kebutuhan kalori: {tn['calorie_needs']}\n"
        formatted_text += f"- Kebutuhan protein: {tn['protein_needs']}\n"
        formatted_text += "- Nutrisi penting:\n"
        
        for nutrient in tn['key_nutrients']:
            formatted_text += f"  * {nutrient['name']}: {nutrient['amount']} - {nutrient['importance']}\n"
            formatted_text += f"    Sumber: {', '.join(nutrient['sources'])}\n"
        
        formatted_text += f"- Rekomendasi: {tn['recommendations']}\n"
        formatted_text += f"- Masalah umum: {', '.join(tn['common_issues'])}\n\n"
    
    # Format food nutrition data
    if 'food_nutrition' in kb_data and kb_data['food_nutrition']:
        fn = kb_data['food_nutrition']
        formatted_text += f"Detail nutrisi {fn['name']} (per {fn['portion']}):\n"
        formatted_text += f"- Protein: {fn['nutrients']['protein']}\n"
        formatted_text += f"- Lemak: {fn['nutrients']['lemak']}\n"
        formatted_text += f"- Karbohidrat: {fn['nutrients']['karbohidrat']}\n"
        formatted_text += f"- Kalori: {fn['nutrients']['kalori']}\n"
        
        if 'vitamin' in fn['nutrients']:
            formatted_text += f"- Vitamin: {', '.join(fn['nutrients']['vitamin'])}\n"
        
        if 'mineral' in fn['nutrients']:
            formatted_text += f"- Mineral: {', '.join(fn['nutrients']['mineral'])}\n"
        
        formatted_text += f"- Manfaat untuk kehamilan: {fn['benefits_pregnancy']}\n\n"
    
    # Format food recommendations
    if 'food_recommendations' in kb_data and kb_data['food_recommendations']:
        formatted_text += "Rekomendasi makanan:\n"
        
        for category in kb_data['food_recommendations']:
            formatted_text += f"- Kategori {category['category']}:\n"
            
            for food in category['foods']:
                formatted_text += f"  * {food['name']}: {food['benefits']}\n"
        
        formatted_text += "\n"
    
    # Format stunting prevention data
    if 'stunting_prevention' in kb_data and kb_data['stunting_prevention']:
        formatted_text += "Pencegahan stunting:\n"
        
        for item in kb_data['stunting_prevention']:
            formatted_text += f"- {item['factor']} (Prioritas: {item['importance']}): {item['description']}\n"
    
    return formatted_text

def _save_session(session: ChatSession) -> None:
    """Save chat session to file (optional)"""
    # Create directory if it doesn't exist
    os.makedirs('sessions', exist_ok=True)
    
    # Save to file
    with open(f'sessions/{session.user_id}.json', 'w', encoding='utf-8') as f:
        json.dump(session.to_dict(), f, ensure_ascii=False, indent=2)

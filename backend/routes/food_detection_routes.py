from flask import Flask, Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db
import os
import requests
from dotenv import load_dotenv
load_dotenv()

# LogMeal API
API_USER_TOKEN = '18b96a8cdf45b26fbd71223995eeaba97de0e72f'
HEADERS = {'Authorization': f'Bearer {API_USER_TOKEN}'}
API_URL = 'https://api.logmeal.es/v2/image/segmentation/complete'

# Nutritionix API (Text-Based)
NUTRITIONIX_APP_ID  = os.getenv('NUTRITIONIX_APP_ID')
NUTRITIONIX_APP_KEY = os.getenv('NUTRITIONIX_APP_KEY')
NUTRITIONIX_URL     = 'https://trackapi.nutritionix.com/v2/natural/nutrients'

food_detection_bp = Blueprint('food_detection', __name__)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@food_detection_bp.route('/detect_food', methods=['POST'])
def detect_food():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request.'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file.'}), 400

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    with open(file_path, 'rb') as img:
        response = requests.post(API_URL, files={'image': img}, headers=HEADERS)

    os.remove(file_path)

    if response.status_code == 200:
        result = response.json()
        image_id = result.get('imageId')
        segmentation_results = result.get('segmentation_results', [])
        recognized_dishes = [dish for seg in segmentation_results for dish in seg.get('recognition_results', [])]
        valid_dishes = [dish for dish in recognized_dishes if dish.get('name') and dish.get('name') != '_empty_']
        top_dish = max(valid_dishes, key=lambda x: x.get('prob', 0)) if valid_dishes else {}

        return jsonify({
            'dish_name': top_dish.get('name', 'Unknown'),
            'imageId': image_id
        })
    return jsonify({'error': 'API Error', 'details': response.text}), response.status_code

@food_detection_bp.route('/get_nutritional_info', methods=['POST'])
def get_nutritional_info():
    data = request.get_json()
    image_id = data.get('imageId')

    if not image_id:
        return jsonify({'error': 'Missing imageId'}), 400

    nutrition_url = 'https://api.logmeal.com/v2/recipe/nutritionalInfo'
    nutrition_response = requests.post(nutrition_url, json={'imageId': image_id}, headers=HEADERS)

    if nutrition_response.status_code == 200:
        nutrition_data = nutrition_response.json()
        nutritional_info = nutrition_data.get('nutritional_info', {})
        total_nutrients = nutritional_info.get('totalNutrients', {})

        nutritional_info_response = {
            'calories': nutritional_info.get('calories', 'N/A'),
            'protein': total_nutrients.get('PROCNT', {}).get('quantity', 'N/A'),
            'fat': total_nutrients.get('FAT', {}).get('quantity', 'N/A'),
            'carbs': total_nutrients.get('CHOCDF', {}).get('quantity', 'N/A'),
        }

        return jsonify({
            'nutritional_info': nutritional_info_response
        })
    
    return jsonify({'error': 'Failed to retrieve nutrition info', 'details': nutrition_response.text}), 500

@food_detection_bp.route('/store_nutritional_info', methods=['POST'])
@jwt_required()
def store_nutritional_info(): 
    
    from models import db  
    from models.daily_nutrition_log import DailyNutritionLog
    from models.user import User

    print("Store nutritional info route hit")
    data = request.get_json()
    print("→ payload:", data)


    user_id = get_jwt_identity()
    calories = data.get('calories')
    protein = data.get('protein')
    fat = data.get('fat')
    carbs = data.get('carbs')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404

    nutrition_entry = DailyNutritionLog(
        user_id=user_id,
        daily_calories=calories,
        daily_protein=protein,
        daily_fat=fat,
        daily_carbs=carbs
    )
    db.session.add(nutrition_entry)
    try:
        db.session.commit()
        return jsonify({'message': 'Nutrition info saved successfully'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to save nutrition info: {str(e)}'}), 500

@food_detection_bp.route('/get_nutrition_by_text', methods=['POST'])
def get_nutrition_by_text():
    data = request.get_json()
    items = data.get('items', [])
    if not items:
        return jsonify({'error': 'Missing items list'}), 400

    lines = [f"{item['quantity']} {item['name']}" for item in items]
    query_text = "\n".join(lines)

    nx_headers = {
        'x-app-id':  NUTRITIONIX_APP_ID,
        'x-app-key': NUTRITIONIX_APP_KEY,
        'Content-Type': 'application/json'
    }
    nx_payload = {'query': query_text}
    nx_resp = requests.post(NUTRITIONIX_URL, json=nx_payload, headers=nx_headers)

    if nx_resp.status_code != 200:
        return jsonify({'error': 'Nutritionix API error', 'details': nx_resp.text}), nx_resp.status_code

    result = nx_resp.json()
    print("Nutritionix resp:", nx_resp.status_code, nx_resp.text)
    foods = result.get('foods', [])

    total_calories = sum(f.get('nf_calories', 0) for f in foods)
    total_protein  = sum(f.get('nf_protein',  0) for f in foods)
    total_fat      = sum(f.get('nf_total_fat', 0) for f in foods)
    total_carbs    = sum(f.get('nf_total_carbohydrate', 0) for f in foods)

    return jsonify({
        'calories': total_calories,
        'protein':  total_protein,
        'fat':      total_fat,
        'carbs':    total_carbs
    })

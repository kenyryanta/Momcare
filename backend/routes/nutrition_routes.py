from flask import Blueprint, request, redirect, url_for, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.nutrition_service import calculate_nutrition_goals
from models import db
from models.daily_nutrition import DailyNutrition
from datetime import date

nutrition_bp = Blueprint('nutrition', __name__, url_prefix='/nutrition')

@nutrition_bp.route('/set_goal', methods=['POST'])
@jwt_required()
def set_nutrition_goal():
    user = get_jwt_identity() 

    age = user.age
    weights = user.weight
    heights = user.height
    trimesters = user.trimester

    goals = calculate_nutrition_goals(age, weights, heights, trimesters)

    new_goal = DailyNutrition(
        user_id=user.id,
        calories=goals["calories"],
        protein=goals["protein"],
        fat=goals["fat"],
        carbs=goals["carbs"],
        date=date.today()
    )
    db.session.add(new_goal)
    db.session.commit()

    return jsonify({"message": "Nutrition goal set successfully", "status": "success"}), 201

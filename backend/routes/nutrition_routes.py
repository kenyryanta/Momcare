from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.nutrition_service import calculate_nutrition_goals
from models import db
from models.daily_nutrition import DailyNutrition
from models.user import User     # ← import the User model
from datetime import date
from models.daily_nutrition_log import DailyNutritionLog

nutrition_bp = Blueprint('nutrition', __name__, url_prefix='/nutrition')

@nutrition_bp.route('/set_goal', methods=['POST'])
@jwt_required()
def set_nutrition_goal():
    # 1) Get the raw identity (a string), cast to int, then load the User
    raw_id = get_jwt_identity()
    try:
        user_id = int(raw_id)
    except (TypeError, ValueError):
        return jsonify({'error': 'Invalid user identity'}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # 2) Now you can safely read user.age, user.weight, etc.
    age = user.age
    weights = user.weight
    heights = user.height
    trimesters = user.trimester

    goals = calculate_nutrition_goals(age, weights, heights, trimesters)

    # 3) Pass only the args your model __init__ expects
    new_goal = DailyNutrition(
        user_id=user_id,
        calories=goals["calories"],
        protein=goals["protein"],
        fat=goals["fat"],
        carbs=goals["carbs"]
    )

    try:
        db.session.add(new_goal)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to save goal: {str(e)}'}), 500

    return jsonify({"message": "Nutrition goal set successfully", "status": "success"}), 201

@nutrition_bp.route('/log/today', methods=['GET'])
@jwt_required()
def get_today_log():
    """Return today's nutrition log for the current user (zeros if none)."""
    raw_id = get_jwt_identity()
    try:
        user_id = int(raw_id)
    except (TypeError, ValueError):
        return jsonify({'error': 'Invalid user identity'}), 400

    today = date.today()
    log = DailyNutritionLog.query.filter_by(user_id=user_id, date=today).first()
    if not log:
        # no entry yet → return zeros
        return jsonify({
            'date': today.isoformat(),
            'daily_calories': 0,
            'daily_protein':  0,
            'daily_fat':      0,
            'daily_carbs':    0,
        }), 200

    return jsonify({
        'date':           log.date.isoformat(),
        'daily_calories': log.daily_calories,
        'daily_protein':  log.daily_protein,
        'daily_fat':      log.daily_fat,
        'daily_carbs':    log.daily_carbs,
    }), 200

@nutrition_bp.route('/goal', methods=['GET'])
@jwt_required()
def get_nutrition_goal():
    """Return the current user's nutrition goal (from daily_nutrition)."""
    try:
        user_id = int(get_jwt_identity())
    except (TypeError, ValueError):
        return jsonify({'error': 'Invalid user identity'}), 400

    # pull the most recent goal row
    goal = (DailyNutrition.query
              .filter_by(user_id=user_id)
              .order_by(DailyNutrition.id.desc())
              .first())

    # we assume one always exists; if you want safety you can .first_or_404()
    return jsonify(goal.to_dict()), 200

@nutrition_bp.route('/summary', methods=['GET'])
@jwt_required()
def get_nutrition_summary():
    """Return today's consumed totals + today's goal in one shot."""
    try:
        user_id = int(get_jwt_identity())
    except (TypeError, ValueError):
        return jsonify({'error': 'Invalid user identity'}), 400

    today = date.today()

    # Fetch most recent goal
    goal = (DailyNutrition.query
              .filter_by(user_id=user_id)
              .order_by(DailyNutrition.id.desc())
              .first())
    if not goal:
        return jsonify({'error': 'No goal set'}), 404

    # Fetch or zero‐fill today's log
    log = DailyNutritionLog.query.filter_by(user_id=user_id, date=today).first()
    consumed = {
        'calories': log.daily_calories if log else 0,
        'protein':  log.daily_protein  if log else 0,
        'fat':      log.daily_fat      if log else 0,
        'carbs':    log.daily_carbs    if log else 0,
    }

    return jsonify({
        'date':      today.isoformat(),
        'goal': {
            'calories': goal.calories,
            'protein':  goal.protein,
            'fat':      goal.fat,
            'carbs':    goal.carbs,
        },
        'consumed': consumed
    }), 200

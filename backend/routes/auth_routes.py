from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from services.nutrition_service import calculate_nutrition_goals 
from models.daily_nutrition import DailyNutrition            
from models import db
from models.user import User
import datetime
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Endpoint untuk registrasi pengguna baru.
    """
    data = request.get_json()

    if not all(key in data for key in ['username', 'email', 'password', 'age', 'weight', 'height', 'trimester']):
        return jsonify({'success': False, 'message': 'Data tidak lengkap'}), 400
    
    if User.find_by_email(data['email']):
        return jsonify({'success': False, 'message': 'Email sudah terdaftar'}), 400
    
    try:
        new_user = User.create(data['username'], data['email'], data['password'], data['age'], data['height'], data['weight'], data['trimester'])
        
        # 2) Calculate initial nutrition goals for this user
        goals = calculate_nutrition_goals(
            new_user.age,
            new_user.weight,
            new_user.height,
            new_user.trimester
        )
        # 3) Store the goals in daily_nutrition table
        initial_goal = DailyNutrition(
            user_id=new_user.id,
            calories=goals['calories'],
            protein=goals['protein'],
            fat=goals['fat'],
            carbs=goals['carbs']
        )
        db.session.add(initial_goal)
        db.session.commit()
        
        
        access_token = create_access_token(identity=str(new_user.id))
        return jsonify({
        'success': True,
        'message': 'Registrasi berhasil',
        'user': new_user.to_dict(),
        'token': access_token
        }), 201
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
        


@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validasi payload
        if not all(field in data for field in ['email', 'password']):
            return jsonify({
                'success': False,
                'message': 'Email dan password wajib diisi'
            }), 400

        email = data['email'].strip().lower()
        password = data['password']

        # Cari user berdasarkan email
        user = User.find_by_email(email)
        
        # Verifikasi user dan password
        if not user or not user.verify_password(password):
            return jsonify({
                'success': False,
                'message': 'Email atau password salah'
            }), 401

#         # Generate JWT token
#         access_token = create_access_token(
#             identity=user.to_dict(),  # INI MASALAHNYA - menggunakan dictionary sebagai identity
#             expires_delta=datetime.timedelta(hours=1)
# )
        # Generate JWT token
        access_token = create_access_token(
            identity=str(user.id),  # Gunakan ID user sebagai string
            expires_delta=datetime.timedelta(hours=1)
        )

        return jsonify({
            'success': True,
            'message': 'Login berhasil',
            'user': user.to_dict(),
            'token': access_token
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Terjadi kesalahan server: {str(e)}'
        }), 500


@auth_bp.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    """
    Endpoint contoh yang memerlukan autentikasi JWT.
    """
    current_user = get_jwt_identity()
    return jsonify({'success': True, 'user': current_user}), 200

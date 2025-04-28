from datetime import datetime
from models import db

class DailyNutrition(db.Model):
    __tablename__ = 'daily_nutrition'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    calories = db.Column(db.Float, nullable=False)
    protein = db.Column(db.Float, nullable=False)
    fat = db.Column(db.Float, nullable=False)
    carbs = db.Column(db.Float, nullable=False)

    # Relationship with User

    def __init__(self, user_id, calories, protein, fat, carbs):
        self.user_id = user_id
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs

    def save(self):
        """Save the user's daily nutrition intake"""
        try:
            db.session.add(self)
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Failed to save daily nutrition intake: {str(e)}")
            raise

    def to_dict(self):
        """Convert to dictionary for API responses"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'calories': self.calories,
            'protein': self.protein,
            'fat': self.fat,
            'carbs': self.carbs,
            'created_at': self.created_at.isoformat() if isinstance(self.created_at, datetime) else self.created_at
        }

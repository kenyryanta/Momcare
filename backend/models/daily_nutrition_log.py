from datetime import date
from models import db

class DailyNutritionLog(db.Model):
    __tablename__ = 'daily_nutrition_log'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    date = db.Column(db.Date, nullable=False, default=date.today)

    daily_calories = db.Column(db.Float, default=0)
    daily_protein = db.Column(db.Float, default=0)
    daily_fat = db.Column(db.Float, default=0)
    daily_carbs = db.Column(db.Float, default=0)

    def __init__(self, user_id, daily_calories=0, daily_protein=0, daily_fat=0, daily_carbs=0, date=None):
        self.user_id = user_id
        self.daily_calories = daily_calories
        self.daily_protein = daily_protein
        self.daily_fat = daily_fat
        self.daily_carbs = daily_carbs
        self.date = date or date.today()

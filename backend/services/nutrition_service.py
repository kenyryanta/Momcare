def calculate_nutrition_goals(age, weight, height, trimester):

    eer = 354 - 6.91 * age + 1 * (9.36 * weight + 726 * (float(height) / 100))

    if trimester == 1:
        extra_calories = 0
    elif trimester == 2:
        extra_calories = 340
    elif trimester == 3:
        extra_calories = 452
    else:
        raise ValueError("Trimester must be 1, 2, or 3.")

    total_calories = eer + extra_calories

    protein_grams = weight * 1.1
    protein_calories = protein_grams * 4

    fat_calories = 0.30 * total_calories
    fat_grams = fat_calories / 9

    remaining_calories = total_calories - (protein_calories + fat_calories)
    carbs_grams = remaining_calories / 4

    return {
        "calories": total_calories,
        "protein": protein_grams,
        "fat": fat_grams,
        "carbs": carbs_grams
    }




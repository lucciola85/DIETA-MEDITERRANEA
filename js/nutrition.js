/**
 * Nutrition Module - TDEE, BMR, Macro calculations
 */

const Nutrition = {
    // Activity levels for TDEE calculation
    activityLevels: {
        sedentary: 1.2,
        light: 1.375,
        moderate: 1.55,
        active: 1.725,
        veryActive: 1.9
    },

    // Calculate BMR using Mifflin-St Jeor Formula
    calculateBMR(weight, height, age, gender) {
        // Weight in kg, height in cm, age in years
        // Men: BMR = 10 * weight + 6.25 * height - 5 * age + 5
        // Women: BMR = 10 * weight + 6.25 * height - 5 * age - 161
        
        const baseBMR = 10 * weight + 6.25 * height - 5 * age;
        const bmr = gender === 'male' ? baseBMR + 5 : baseBMR - 161;
        
        return Math.round(bmr);
    },

    // Calculate TDEE (Total Daily Energy Expenditure)
    calculateTDEE(bmr, activityLevel = 'light') {
        const multiplier = this.activityLevels[activityLevel];
        return Math.round(bmr * multiplier);
    },

    // Calculate target calories with deficit for 1kg/week loss
    calculateTargetCalories(tdee) {
        // 1 kg fat ≈ 7700 kcal
        // For 1 kg/week loss: deficit of ~1100 kcal/day
        const deficit = 1000;
        const targetCalories = tdee - deficit;
        
        // Safety check: don't go below BMR
        return Math.round(targetCalories);
    },

    // Calculate safe minimum calories (should not go below BMR)
    getSafeMinimumCalories(bmr) {
        return Math.round(bmr);
    },

    // Check if deficit is too aggressive
    isDeficitSafe(targetCalories, bmr) {
        return targetCalories >= bmr;
    },

    // Calculate macro distribution for Mediterranean Diet
    calculateMacros(targetCalories, weight) {
        // Mediterranean Diet macros:
        // Carbs: 50-55% (we'll use 52.5% as average)
        // Protein: 15-20% BUT minimum 1.2g/kg to preserve muscle
        // Fats: 25-30% (we'll use 27.5% as average)

        // Calculate protein first (priority: at least 1.2g/kg)
        const minProteinGrams = weight * 1.2;
        const proteinFromPercentage = (targetCalories * 0.175) / 4; // 17.5% average, 4 kcal per gram
        const proteinGrams = Math.max(minProteinGrams, proteinFromPercentage);
        const proteinCalories = proteinGrams * 4;

        // Calculate fats (27.5% of calories)
        const fatsCalories = targetCalories * 0.275;
        const fatsGrams = fatsCalories / 9; // 9 kcal per gram

        // Remaining calories go to carbs
        const carbsCalories = targetCalories - proteinCalories - fatsCalories;
        const carbsGrams = carbsCalories / 4; // 4 kcal per gram

        return {
            carbs: {
                grams: Math.round(carbsGrams),
                calories: Math.round(carbsCalories),
                percentage: Math.round((carbsCalories / targetCalories) * 100)
            },
            protein: {
                grams: Math.round(proteinGrams),
                calories: Math.round(proteinCalories),
                percentage: Math.round((proteinCalories / targetCalories) * 100)
            },
            fats: {
                grams: Math.round(fatsGrams),
                calories: Math.round(fatsCalories),
                percentage: Math.round((fatsCalories / targetCalories) * 100)
            },
            total: {
                calories: targetCalories
            }
        };
    },

    // Calculate nutrition for a profile
    calculateProfileNutrition(profile) {
        const bmr = this.calculateBMR(
            profile.weight,
            profile.height,
            profile.age,
            profile.gender
        );

        // Use light activity as baseline
        const tdee = this.calculateTDEE(bmr, 'light');
        const targetCalories = this.calculateTargetCalories(tdee);
        const safeMinimum = this.getSafeMinimumCalories(bmr);
        const isSafe = this.isDeficitSafe(targetCalories, bmr);

        // Adjust if not safe
        const finalTarget = isSafe ? targetCalories : safeMinimum;

        const macros = this.calculateMacros(finalTarget, profile.weight);

        return {
            bmr,
            tdee,
            targetCalories: finalTarget,
            safeMinimum,
            isSafe,
            deficit: tdee - finalTarget,
            macros
        };
    },

    // Meal distribution (percentage of daily calories)
    mealDistribution: {
        breakfast: { min: 0.20, max: 0.25, avg: 0.225 }, // 20-25%
        morningSnack: { min: 0.05, max: 0.10, avg: 0.075 }, // 5-10%
        lunch: { min: 0.35, max: 0.40, avg: 0.375 }, // 35-40%
        afternoonSnack: { min: 0.05, max: 0.10, avg: 0.075 }, // 5-10%
        dinner: { min: 0.20, max: 0.25, avg: 0.225 } // 20-25%
    },

    // Calculate target calories for a specific meal
    getMealTarget(mealType, dailyCalories) {
        const distribution = this.mealDistribution[mealType];
        if (!distribution) {
            throw new Error('Invalid meal type');
        }

        return {
            min: Math.round(dailyCalories * distribution.min),
            max: Math.round(dailyCalories * distribution.max),
            target: Math.round(dailyCalories * distribution.avg)
        };
    },

    // Calculate macros for a specific meal
    getMealMacros(mealType, dailyMacros) {
        const distribution = this.mealDistribution[mealType];
        if (!distribution) {
            throw new Error('Invalid meal type');
        }

        const percentage = distribution.avg;

        return {
            carbs: Math.round(dailyMacros.carbs.grams * percentage),
            protein: Math.round(dailyMacros.protein.grams * percentage),
            fats: Math.round(dailyMacros.fats.grams * percentage),
            calories: Math.round(dailyMacros.total.calories * percentage)
        };
    },

    // Calculate nutrition for food items
    calculateFoodNutrition(food, grams) {
        // All values in database are per 100g
        const factor = grams / 100;

        return {
            calories: Math.round(food.calories * factor),
            protein: parseFloat((food.protein * factor).toFixed(1)),
            carbs: parseFloat((food.carbs * factor).toFixed(1)),
            fats: parseFloat((food.fats * factor).toFixed(1)),
            fiber: parseFloat((food.fiber * factor).toFixed(1))
        };
    },

    // Calculate total nutrition for a meal
    calculateMealNutrition(foodItems) {
        return foodItems.reduce((total, item) => {
            const nutrition = this.calculateFoodNutrition(item.food, item.grams);
            return {
                calories: total.calories + nutrition.calories,
                protein: total.protein + nutrition.protein,
                carbs: total.carbs + nutrition.carbs,
                fats: total.fats + nutrition.fats,
                fiber: total.fiber + nutrition.fiber
            };
        }, { calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0 });
    },

    // AUTOMATIC PORTION CALCULATION
    // Given a list of foods, calculate optimal portions to match target macros
    calculateOptimalPortions(foods, targetMacros) {
        // This is a simplified algorithm that proportionally distributes
        // the target macros across the selected foods based on their macro profiles
        
        if (foods.length === 0) {
            return [];
        }

        // Start with equal calories distribution
        const caloriesPerFood = targetMacros.calories / foods.length;
        
        const portions = foods.map(food => {
            // Calculate grams needed to reach the calorie target for this food
            // calories = (food.calories * grams) / 100
            // grams = (calories * 100) / food.calories
            let grams = (caloriesPerFood * 100) / food.calories;
            
            // Round to reasonable portions (5g increments)
            grams = Math.round(grams / 5) * 5;
            
            // Minimum 5g, maximum 500g per food item
            grams = Math.max(5, Math.min(500, grams));
            
            return {
                food: food,
                grams: grams,
                nutrition: this.calculateFoodNutrition(food, grams)
            };
        });

        // Refine portions to better match macros (iterative adjustment)
        const maxIterations = 10;
        for (let i = 0; i < maxIterations; i++) {
            const currentTotal = portions.reduce((sum, p) => ({
                calories: sum.calories + p.nutrition.calories,
                protein: sum.protein + p.nutrition.protein,
                carbs: sum.carbs + p.nutrition.carbs,
                fats: sum.fats + p.nutrition.fats
            }), { calories: 0, protein: 0, carbs: 0, fats: 0 });

            // Check if we're close enough
            const calorieDiff = Math.abs(currentTotal.calories - targetMacros.calories);
            if (calorieDiff < 50) break; // Within 50 kcal is acceptable

            // Adjust portions proportionally
            const adjustmentFactor = targetMacros.calories / currentTotal.calories;
            portions.forEach(portion => {
                portion.grams = Math.round((portion.grams * adjustmentFactor) / 5) * 5;
                portion.grams = Math.max(5, Math.min(500, portion.grams));
                portion.nutrition = this.calculateFoodNutrition(portion.food, portion.grams);
            });
        }

        return portions;
    },

    // Get meal type name in Italian
    getMealTypeName(mealType) {
        const names = {
            breakfast: 'Colazione',
            morningSnack: 'Spuntino Mattina',
            lunch: 'Pranzo',
            afternoonSnack: 'Merenda',
            dinner: 'Cena'
        };
        return names[mealType] || mealType;
    },

    // Get all meal types
    getAllMealTypes() {
        return [
            { key: 'breakfast', name: 'Colazione' },
            { key: 'morningSnack', name: 'Spuntino Mattina' },
            { key: 'lunch', name: 'Pranzo' },
            { key: 'afternoonSnack', name: 'Merenda' },
            { key: 'dinner', name: 'Cena' }
        ];
    }
};

/**
 * Nutrition Module - TDEE, BMR, Macro calculations
 */

const Nutrition = {
    // Thresholds for food classification (g per 100g)
    PROTEIN_RICH_THRESHOLD: 10,
    CARB_RICH_THRESHOLD: 15,
    FAT_RICH_THRESHOLD: 5,
    
    // Macro adjustment factors for optimization
    MACRO_ADJUSTMENT_INCREASE: 1.05,
    MACRO_ADJUSTMENT_DECREASE: 0.95,
    
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
            calories: Math.round(dailyMacros.total.calories * percentage),
            fiber: Math.round((dailyMacros.fiber?.grams || 25) * percentage) // 25g is recommended daily target
        };
    },

    // Helper function to round up to 1 decimal place
    roundUpToOneDecimal(value) {
        return Math.ceil(value * 10) / 10;
    },

    // Calculate nutrition for food items
    calculateFoodNutrition(food, grams) {
        // All values in database are per 100g
        const factor = grams / 100;

        return {
            calories: Math.ceil(food.calories * factor), // Calories always rounded up to integer
            protein: this.roundUpToOneDecimal(food.protein * factor),
            carbs: this.roundUpToOneDecimal(food.carbs * factor),
            fats: this.roundUpToOneDecimal(food.fats * factor),
            fiber: this.roundUpToOneDecimal(food.fiber * factor)
        };
    },

    // Round grams to practical values for weighing
    // Under 50g: round to 5g
    // 50-200g: round to 10g  
    // Over 200g: round to 25g
    roundToPracticalGrams(grams) {
        if (grams < 50) {
            return Math.round(grams / 5) * 5;
        } else if (grams < 200) {
            return Math.round(grams / 10) * 10;
        } else {
            return Math.round(grams / 25) * 25;
        }
    },

    // Calculate total nutrition for a meal
    calculateMealNutrition(foodItems) {
        const total = foodItems.reduce((total, item) => {
            const nutrition = this.calculateFoodNutrition(item.food, item.grams);
            return {
                calories: total.calories + nutrition.calories,
                protein: total.protein + nutrition.protein,
                carbs: total.carbs + nutrition.carbs,
                fats: total.fats + nutrition.fats,
                fiber: total.fiber + nutrition.fiber
            };
        }, { calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0 });
        
        // Round up all totals to 1 decimal
        return {
            calories: Math.ceil(total.calories),
            protein: this.roundUpToOneDecimal(total.protein),
            carbs: this.roundUpToOneDecimal(total.carbs),
            fats: this.roundUpToOneDecimal(total.fats),
            fiber: this.roundUpToOneDecimal(total.fiber)
        };
    },

    // AUTOMATIC PORTION CALCULATION
    // Given a list of foods (max 5), calculate optimal portions to match target macros
    calculateOptimalPortions(foods, targetMacros) {
        // Improved input validation
        if (!foods || !Array.isArray(foods) || foods.length === 0) {
            console.warn('No foods provided for portion calculation');
            return [];
        }
        
        if (!targetMacros || !targetMacros.calories || targetMacros.calories <= 0) {
            console.error('Invalid target macros');
            return [];
        }
        
        // Filter foods with invalid data
        const validFoods = foods.filter(food => 
            food && 
            typeof food.calories === 'number' && 
            food.calories > 0
        );
        
        if (validFoods.length === 0) {
            console.warn('No valid foods after filtering');
            return [];
        }
        
        if (validFoods.length > 5) {
            console.warn('Maximum 5 ingredients allowed. Using first 5.');
            foods = validFoods.slice(0, 5);
        } else {
            foods = validFoods;
        }

        // Start with equal calories distribution
        const caloriesPerFood = targetMacros.calories / foods.length;
        
        const portions = foods.map(food => {
            // Calculate grams needed to reach the calorie target for this food
            // calories = (food.calories * grams) / 100
            // grams = (calories * 100) / food.calories
            let grams = (caloriesPerFood * 100) / food.calories;
            
            // Round to practical portions using new function
            grams = this.roundToPracticalGrams(grams);
            
            // Apply constraints: minimum 10g, maximum 500g per food item
            grams = Math.max(10, Math.min(500, grams));
            
            return {
                food: food,
                grams: grams,
                nutrition: this.calculateFoodNutrition(food, grams)
            };
        });

        // Refine portions to better match macros (iterative adjustment)
        // This optimization tries to match calories first, then balance macros
        // 20 iterations provide good balance between accuracy and performance
        const MAX_ITERATIONS = 20;
        
        for (let i = 0; i < MAX_ITERATIONS; i++) {
            const currentTotal = portions.reduce((sum, p) => ({
                calories: sum.calories + p.nutrition.calories,
                protein: sum.protein + p.nutrition.protein,
                carbs: sum.carbs + p.nutrition.carbs,
                fats: sum.fats + p.nutrition.fats
            }), { calories: 0, protein: 0, carbs: 0, fats: 0 });

            // Calculate differences from target
            const calorieDiff = currentTotal.calories - targetMacros.calories;
            const proteinDiff = currentTotal.protein - targetMacros.protein;
            const carbsDiff = currentTotal.carbs - targetMacros.carbs;
            const fatsDiff = currentTotal.fats - targetMacros.fats;

            // Check if we're close enough (within 3% for calories)
            if (Math.abs(calorieDiff) < targetMacros.calories * 0.03) {
                break;
            }

            // Adjust portions based on which foods can help balance macros
            // Foods with higher protein density should be adjusted when protein is low
            // Foods with higher carb density should be adjusted when carbs are low, etc.
            
            portions.forEach(portion => {
                let adjustment = 1.0;
                
                // Primary goal: match calories
                const calorieAdjustment = targetMacros.calories / currentTotal.calories;
                adjustment *= calorieAdjustment;
                
                // Secondary goal: balance macros based on food's macro profile
                // If we need more protein and this food is protein-rich, increase it slightly
                if (proteinDiff < 0 && portion.food.protein > this.PROTEIN_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_INCREASE;
                } else if (proteinDiff > 0 && portion.food.protein > this.PROTEIN_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_DECREASE;
                }
                
                // If we need more carbs and this food is carb-rich, increase it
                if (carbsDiff < 0 && portion.food.carbs > this.CARB_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_INCREASE;
                } else if (carbsDiff > 0 && portion.food.carbs > this.CARB_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_DECREASE;
                }
                
                // If we need more fats and this food is fat-rich, increase it
                if (fatsDiff < 0 && portion.food.fats > this.FAT_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_INCREASE;
                } else if (fatsDiff > 0 && portion.food.fats > this.FAT_RICH_THRESHOLD) {
                    adjustment *= this.MACRO_ADJUSTMENT_DECREASE;
                }
                
                // Apply adjustment
                let newGrams = portion.grams * adjustment;
                newGrams = this.roundToPracticalGrams(newGrams);
                newGrams = Math.max(10, Math.min(500, newGrams));
                
                portion.grams = newGrams;
                portion.nutrition = this.calculateFoodNutrition(portion.food, portion.grams);
            });
        }

        return portions;
    },

    // Calculate macro adherence levels (for visual feedback)
    // Returns: 'excellent' (<5% deviation), 'good' (5-15%), 'poor' (>15%)
    getMacroAdherence(current, target) {
        if (target === 0) return 'excellent';
        
        const deviation = Math.abs((current - target) / target) * 100;
        
        if (deviation < 5) return 'excellent';
        if (deviation < 15) return 'good';
        return 'poor';
    },

    // Calculate complete meal analysis with adherence feedback
    analyzeMealComposition(portions, targetMacros) {
        if (!portions || portions.length === 0) {
            return {
                totalNutrition: { calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0 },
                adherence: {
                    calories: { level: 'poor', deviation: 100, icon: '❌' },
                    protein: { level: 'poor', deviation: 100, icon: '❌' },
                    carbs: { level: 'poor', deviation: 100, icon: '❌' },
                    fats: { level: 'poor', deviation: 100, icon: '❌' }
                },
                suggestions: ['Aggiungi almeno un alimento per iniziare']
            };
        }

        // Calculate totals
        const totalNutrition = portions.reduce((sum, p) => ({
            calories: sum.calories + p.nutrition.calories,
            protein: sum.protein + p.nutrition.protein,
            carbs: sum.carbs + p.nutrition.carbs,
            fats: sum.fats + p.nutrition.fats,
            fiber: sum.fiber + p.nutrition.fiber
        }), { calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0 });
        
        // Round up all totals to 1 decimal
        totalNutrition.calories = Math.ceil(totalNutrition.calories);
        totalNutrition.protein = this.roundUpToOneDecimal(totalNutrition.protein);
        totalNutrition.carbs = this.roundUpToOneDecimal(totalNutrition.carbs);
        totalNutrition.fats = this.roundUpToOneDecimal(totalNutrition.fats);
        totalNutrition.fiber = this.roundUpToOneDecimal(totalNutrition.fiber);

        // Calculate adherence for each macro
        const adherence = {
            calories: {
                level: this.getMacroAdherence(totalNutrition.calories, targetMacros.calories),
                deviation: targetMacros.calories > 0 ? 
                    Math.abs((totalNutrition.calories - targetMacros.calories) / targetMacros.calories * 100) : 0,
                icon: ''
            },
            protein: {
                level: this.getMacroAdherence(totalNutrition.protein, targetMacros.protein),
                deviation: targetMacros.protein > 0 ? 
                    Math.abs((totalNutrition.protein - targetMacros.protein) / targetMacros.protein * 100) : 0,
                icon: ''
            },
            carbs: {
                level: this.getMacroAdherence(totalNutrition.carbs, targetMacros.carbs),
                deviation: targetMacros.carbs > 0 ? 
                    Math.abs((totalNutrition.carbs - targetMacros.carbs) / targetMacros.carbs * 100) : 0,
                icon: ''
            },
            fats: {
                level: this.getMacroAdherence(totalNutrition.fats, targetMacros.fats),
                deviation: targetMacros.fats > 0 ? 
                    Math.abs((totalNutrition.fats - targetMacros.fats) / targetMacros.fats * 100) : 0,
                icon: ''
            }
        };

        // Add icons based on adherence level
        Object.keys(adherence).forEach(macro => {
            if (adherence[macro].level === 'excellent') {
                adherence[macro].icon = '✅';
            } else if (adherence[macro].level === 'good') {
                adherence[macro].icon = '⚠️';
            } else {
                adherence[macro].icon = '❌';
            }
        });

        // Generate suggestions
        const suggestions = [];
        
        // Check if any food category is missing (using module-level thresholds)
        const hasProteinSource = portions.some(p => p.food.protein > this.PROTEIN_RICH_THRESHOLD);
        const hasCarbSource = portions.some(p => p.food.carbs > this.CARB_RICH_THRESHOLD);
        const hasFatSource = portions.some(p => p.food.fats > this.FAT_RICH_THRESHOLD);
        
        if (!hasProteinSource && adherence.protein.level !== 'excellent') {
            suggestions.push('💡 Aggiungi una fonte proteica (pesce, carne, legumi, uova)');
        }
        
        if (!hasCarbSource && adherence.carbs.level !== 'excellent') {
            suggestions.push('💡 Aggiungi una fonte di carboidrati (cereali, frutta, patate)');
        }
        
        if (!hasFatSource && adherence.fats.level !== 'excellent') {
            suggestions.push('💡 Aggiungi una fonte di grassi sani (olio d\'oliva, frutta secca)');
        }
        
        // Check overall balance
        if (adherence.calories.level === 'poor') {
            if (totalNutrition.calories < targetMacros.calories * 0.85) {
                suggestions.push('⚠️ Calorie troppo basse - aumenta le porzioni');
            } else {
                suggestions.push('⚠️ Calorie troppo alte - riduci le porzioni');
            }
        }

        return {
            totalNutrition,
            adherence,
            suggestions
        };
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

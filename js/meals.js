/**
 * Meals Module - Meal planning and food management
 */

const Meals = {
    // Save meal to database
    async saveMeal(profileId, date, mealType, foodItems) {
        const meal = {
            id: Storage.generateId(),
            profileId: profileId,
            date: date,
            mealType: mealType,
            foodItems: foodItems.map(item => ({
                foodName: item.food.name,
                foodData: {
                    calories: item.food.calories,
                    protein: item.food.protein,
                    carbs: item.food.carbs,
                    fats: item.food.fats,
                    fiber: item.food.fiber,
                    category: item.food.category
                },
                grams: item.grams,
                nutrition: item.nutrition
            })),
            totalNutrition: Nutrition.calculateMealNutrition(foodItems),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        await Storage.addToStore('meals', meal);
        return meal;
    },

    // Update existing meal
    async updateMeal(mealId, foodItems) {
        const meal = await Storage.getFromStore('meals', mealId);
        if (!meal) {
            throw new Error('Meal not found');
        }

        meal.foodItems = foodItems.map(item => ({
            foodName: item.food.name,
            foodData: {
                calories: item.food.calories,
                protein: item.food.protein,
                carbs: item.food.carbs,
                fats: item.food.fats,
                fiber: item.food.fiber,
                category: item.food.category
            },
            grams: item.grams,
            nutrition: item.nutrition
        }));
        meal.totalNutrition = Nutrition.calculateMealNutrition(foodItems);
        meal.updatedAt = new Date().toISOString();

        await Storage.updateInStore('meals', meal);
        return meal;
    },

    // Delete meal
    async deleteMeal(mealId) {
        if (!mealId) {
            console.error('Invalid meal ID');
            return false;
        }
        
        try {
            await Storage.deleteFromStore('meals', mealId);
            return true;
        } catch (error) {
            console.error('Error deleting meal:', error);
            return false;
        }
    },

    // Get meal by ID
    async getMeal(mealId) {
        return await Storage.getFromStore('meals', mealId);
    },

    // Get meals for a specific date
    async getMealsByDate(profileId, date) {
        const allMeals = await Storage.getAllFromStore('meals', 'profileId', profileId);
        const dateStr = this.formatDate(new Date(date));
        
        return allMeals.filter(meal => {
            const mealDateStr = this.formatDate(new Date(meal.date));
            return mealDateStr === dateStr;
        });
    },

    // Get meals for a date range
    async getMealsByDateRange(profileId, startDate, endDate) {
        const allMeals = await Storage.getAllFromStore('meals', 'profileId', profileId);
        const start = new Date(startDate);
        const end = new Date(endDate);
        
        return allMeals.filter(meal => {
            const mealDate = new Date(meal.date);
            return mealDate >= start && mealDate <= end;
        });
    },

    // Get meal for specific date and type
    async getMealByDateAndType(profileId, date, mealType) {
        const meals = await this.getMealsByDate(profileId, date);
        return meals.find(meal => meal.mealType === mealType);
    },

    // Format date to YYYY-MM-DD
    formatDate(date) {
        const d = new Date(date);
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    },

    // Get week dates (Monday to Sunday)
    getWeekDates(date) {
        const d = new Date(date);
        const day = d.getDay();
        const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust when day is Sunday
        const monday = new Date(d.setDate(diff));
        
        const dates = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(monday);
            date.setDate(monday.getDate() + i);
            dates.push(date);
        }
        
        return dates;
    },

    // Get day name in Italian
    getDayName(date) {
        const days = ['Domenica', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì', 'Sabato'];
        return days[new Date(date).getDay()];
    },

    // Generate shopping list from weekly meals
    async generateShoppingList(profileId, startDate, endDate) {
        const meals = await this.getMealsByDateRange(profileId, startDate, endDate);
        
        // If no meals, return empty result with message
        if (!meals || meals.length === 0) {
            return {
                items: {},
                summary: {
                    totalMeals: 0,
                    daysIncluded: [],
                    message: 'Nessun pasto compilato nel periodo selezionato. Compila almeno un pasto per generare la lista.'
                }
            };
        }
        
        // Track which days and meals are included
        const daysIncluded = new Set();
        const mealsIncluded = [];
        
        // Aggregate all food items
        const foodMap = new Map();
        
        meals.forEach(meal => {
            // Track the day
            const mealDate = this.formatDate(new Date(meal.date));
            daysIncluded.add(mealDate);
            mealsIncluded.push({
                date: mealDate,
                day: this.getDayName(meal.date),
                mealType: Nutrition.getMealTypeName(meal.mealType)
            });
            
            // Aggregate the ingredients
            meal.foodItems.forEach(item => {
                const existing = foodMap.get(item.foodName);
                if (existing) {
                    existing.grams += item.grams;
                    existing.occurrences += 1;
                } else {
                    const food = FoodDatabase.getFoodByName(item.foodName);
                    foodMap.set(item.foodName, {
                        name: item.foodName,
                        grams: item.grams,
                        category: food ? food.category : 'other',
                        occurrences: 1
                    });
                }
            });
        });

        // Group by category
        const shoppingList = {};
        foodMap.forEach(item => {
            if (!shoppingList[item.category]) {
                shoppingList[item.category] = [];
            }
            shoppingList[item.category].push({
                name: item.name,
                grams: Math.ceil(item.grams), // Round up to integer
                occurrences: item.occurrences
            });
        });

        // Sort items within each category
        Object.keys(shoppingList).forEach(category => {
            shoppingList[category].sort((a, b) => a.name.localeCompare(b.name));
        });

        return {
            items: shoppingList,
            summary: {
                totalMeals: meals.length,
                totalDays: daysIncluded.size,
                daysIncluded: Array.from(daysIncluded).sort(),
                mealsIncluded: mealsIncluded,
                message: `Lista generata da ${meals.length} pasti in ${daysIncluded.size} giorni`
            }
        };
    },

    // Calculate daily nutrition summary
    calculateDailyNutrition(meals) {
        return meals.reduce((total, meal) => {
            const nutrition = meal.totalNutrition;
            return {
                calories: total.calories + nutrition.calories,
                protein: total.protein + nutrition.protein,
                carbs: total.carbs + nutrition.carbs,
                fats: total.fats + nutrition.fats,
                fiber: total.fiber + nutrition.fiber
            };
        }, { calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0 });
    },

    // Check if daily targets are met
    checkDailyTargets(dailyNutrition, targetMacros) {
        const tolerance = 0.1; // 10% tolerance

        return {
            calories: {
                current: dailyNutrition.calories,
                target: targetMacros.total.calories,
                met: Math.abs(dailyNutrition.calories - targetMacros.total.calories) <= targetMacros.total.calories * tolerance
            },
            protein: {
                current: dailyNutrition.protein,
                target: targetMacros.protein.grams,
                met: dailyNutrition.protein >= targetMacros.protein.grams * (1 - tolerance)
            },
            carbs: {
                current: dailyNutrition.carbs,
                target: targetMacros.carbs.grams,
                met: Math.abs(dailyNutrition.carbs - targetMacros.carbs.grams) <= targetMacros.carbs.grams * tolerance
            },
            fats: {
                current: dailyNutrition.fats,
                target: targetMacros.fats.grams,
                met: Math.abs(dailyNutrition.fats - targetMacros.fats.grams) <= targetMacros.fats.grams * tolerance
            }
        };
    },

    // Get meal completion status for a week
    async getWeekCompletion(profileId, weekDates) {
        const completion = {};
        
        for (const date of weekDates) {
            const dateStr = this.formatDate(date);
            const meals = await this.getMealsByDate(profileId, date);
            
            completion[dateStr] = {
                breakfast: meals.some(m => m.mealType === 'breakfast'),
                morningSnack: meals.some(m => m.mealType === 'morningSnack'),
                lunch: meals.some(m => m.mealType === 'lunch'),
                afternoonSnack: meals.some(m => m.mealType === 'afternoonSnack'),
                dinner: meals.some(m => m.mealType === 'dinner'),
                total: meals.length
            };
        }
        
        return completion;
    },

    // Export shopping list to text
    exportShoppingListToText(shoppingList) {
        let text = 'LISTA DELLA SPESA\n';
        text += '==================\n\n';
        
        Object.keys(shoppingList).forEach(categoryKey => {
            const categoryName = FoodDatabase.getCategoryName(categoryKey);
            text += `${categoryName}\n`;
            text += '-'.repeat(categoryName.length) + '\n';
            
            shoppingList[categoryKey].forEach(item => {
                text += `☐ ${item.name} - ${item.grams}g\n`;
            });
            
            text += '\n';
        });
        
        return text;
    },

    // Add food items to meal with automatic portion calculation
    async addFoodsToMeal(profileId, date, mealType, selectedFoods) {
        // Get target macros for this meal type
        const profile = await Profiles.getCurrentProfile();
        const nutrition = Nutrition.calculateProfileNutrition(profile);
        const mealMacros = Nutrition.getMealMacros(mealType, nutrition.macros);

        // Calculate optimal portions automatically
        const portions = Nutrition.calculateOptimalPortions(selectedFoods, mealMacros);

        // Check if meal already exists
        const existingMeal = await this.getMealByDateAndType(profileId, date, mealType);

        if (existingMeal) {
            // Update existing meal
            return await this.updateMeal(existingMeal.id, portions);
        } else {
            // Create new meal
            return await this.saveMeal(profileId, date, mealType, portions);
        }
    }
};

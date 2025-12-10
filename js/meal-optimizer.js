/**
 * Meal Optimizer Module - Automatic Portion Calculation
 * Calculates optimal portions to match meal targets
 */

const MealOptimizer = {
    // Costanti di configurazione per l'ottimizzazione
    MAX_ITERATIONS: 100,
    MIN_MACRO_PER_GRAM: 0.1, // Soglia minima per considerare un macro significativo (g per 1g di alimento)
    
    // Soglie di convergenza per l'algoritmo iterativo
    CALORIE_CONVERGENCE_THRESHOLD: 5,
    PROTEIN_CONVERGENCE_THRESHOLD: 2,
    CARBS_CONVERGENCE_THRESHOLD: 2,
    FATS_CONVERGENCE_THRESHOLD: 2,
    
    // Pesi per ogni macro nell'ottimizzazione
    CALORIE_WEIGHT: 1.0,
    PROTEIN_WEIGHT: 0.8,
    CARBS_WEIGHT: 0.6,
    FATS_WEIGHT: 0.6,
    
    // Fattori di contributo per l'aggiustamento delle grammature
    CALORIE_CONTRIBUTION_FACTOR: 0.3,
    MACRO_CONTRIBUTION_FACTOR: 0.2,
    
    /**
     * Calcola le grammature ottimali per raggiungere il target del pasto
     * @param {Array} selectedFoods - Alimenti selezionati con i loro valori nutrizionali per 100g
     * @param {Object} targetMacros - Target del pasto {calories, protein, carbs, fats}
     * @returns {Array} - Alimenti con grammature ottimizzate
     */
    calculateOptimalGrams(selectedFoods, targetMacros) {
        if (!selectedFoods || selectedFoods.length === 0) {
            return [];
        }
        
        // Target
        const target = {
            calories: targetMacros.calories || 0,
            protein: targetMacros.protein || 0,
            carbs: targetMacros.carbs || 0,
            fats: targetMacros.fats || 0
        };
        
        // Se c'è un solo alimento, calcola direttamente
        if (selectedFoods.length === 1) {
            return this.calculateSingleFood(selectedFoods[0], target);
        }
        
        // Per più alimenti, usa l'algoritmo di ottimizzazione
        return this.optimizeMultipleFoods(selectedFoods, target);
    },
    
    /**
     * Calcolo per singolo alimento
     */
    calculateSingleFood(food, target) {
        // Priorità: calorie, poi proteine
        const caloriesPer100g = food.calories || 0;
        
        if (caloriesPer100g <= 0) {
            return [{ ...food, grams: 100 }];
        }
        
        // Calcola grammi per raggiungere target calorie
        let grams = Math.round((target.calories / caloriesPer100g) * 100);
        grams = Math.max(1, grams); // Minimo 1g
        
        return [{
            ...food,
            grams: grams,
            calculatedNutrients: this.calculateNutrients(food, grams)
        }];
    },
    
    /**
     * Ottimizzazione per più alimenti usando algoritmo iterativo
     */
    optimizeMultipleFoods(foods, target) {
        const n = foods.length;
        
        // Inizializza con distribuzione equa delle calorie
        let currentGrams = foods.map(food => {
            const caloriesPerGram = (food.calories || 0) / 100;
            if (caloriesPerGram <= 0) return 50;
            const targetCaloriesPerFood = target.calories / n;
            return Math.round(targetCaloriesPerFood / caloriesPerGram);
        });
        
        // Iterazioni per ottimizzare
        const maxIterations = this.MAX_ITERATIONS;
        
        for (let iter = 0; iter < maxIterations; iter++) {
            const currentTotals = this.calculateTotals(foods, currentGrams);
            
            // Calcola errori
            const errors = {
                calories: target.calories - currentTotals.calories,
                protein: target.protein - currentTotals.protein,
                carbs: target.carbs - currentTotals.carbs,
                fats: target.fats - currentTotals.fats
            };
            
            // Se siamo abbastanza vicini, esci
            if (Math.abs(errors.calories) < this.CALORIE_CONVERGENCE_THRESHOLD && 
                Math.abs(errors.protein) < this.PROTEIN_CONVERGENCE_THRESHOLD && 
                Math.abs(errors.carbs) < this.CARBS_CONVERGENCE_THRESHOLD && 
                Math.abs(errors.fats) < this.FATS_CONVERGENCE_THRESHOLD) {
                break;
            }
            
            // Aggiusta le grammature
            currentGrams = this.adjustGrams(foods, currentGrams, errors, target);
        }
        
        // Arrotonda a multipli di 1g e assicura minimo 1g
        currentGrams = currentGrams.map(g => Math.max(1, Math.round(g)));
        
        // Ritorna alimenti con grammature ottimizzate
        return foods.map((food, index) => ({
            ...food,
            grams: currentGrams[index],
            calculatedNutrients: this.calculateNutrients(food, currentGrams[index])
        }));
    },
    
    /**
     * Aggiusta le grammature in base agli errori
     */
    adjustGrams(foods, currentGrams, errors, target) {
        const newGrams = [...currentGrams];
        const n = foods.length;
        
        for (let i = 0; i < n; i++) {
            const food = foods[i];
            let adjustment = 0;
            
            // Calcola l'aggiustamento basato su tutti i macro
            const caloriesPer1g = (food.calories || 0) / 100;
            const proteinPer1g = (food.protein || 0) / 100;
            const carbsPer1g = (food.carbs || 0) / 100;
            const fatsPer1g = (food.fats || 0) / 100;
            
            // Contributo di ogni macro all'aggiustamento
            if (caloriesPer1g > 0) {
                adjustment += (errors.calories / n) / caloriesPer1g * this.CALORIE_WEIGHT * this.CALORIE_CONTRIBUTION_FACTOR;
            }
            if (proteinPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.protein / n) / proteinPer1g * this.PROTEIN_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR;
            }
            if (carbsPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.carbs / n) / carbsPer1g * this.CARBS_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR;
            }
            if (fatsPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.fats / n) / fatsPer1g * this.FATS_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR;
            }
            
            newGrams[i] = Math.max(1, newGrams[i] + adjustment);
        }
        
        return newGrams;
    },
    
    /**
     * Calcola i totali nutrizionali
     */
    calculateTotals(foods, grams) {
        return foods.reduce((totals, food, index) => {
            const g = grams[index];
            const multiplier = g / 100;
            
            return {
                calories: totals.calories + (food.calories || 0) * multiplier,
                protein: totals.protein + (food.protein || 0) * multiplier,
                carbs: totals.carbs + (food.carbs || 0) * multiplier,
                fats: totals.fats + (food.fats || 0) * multiplier
            };
        }, { calories: 0, protein: 0, carbs: 0, fats: 0 });
    },
    
    /**
     * Calcola nutrienti per una specifica grammatura
     */
    calculateNutrients(food, grams) {
        const multiplier = grams / 100;
        return {
            calories: Math.round((food.calories || 0) * multiplier),
            protein: Math.round((food.protein || 0) * multiplier * 10) / 10,
            carbs: Math.round((food.carbs || 0) * multiplier * 10) / 10,
            fats: Math.round((food.fats || 0) * multiplier * 10) / 10
        };
    }
};

window.MealOptimizer = MealOptimizer;

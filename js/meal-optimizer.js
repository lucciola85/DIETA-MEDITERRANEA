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
    
    // Limiti massimi per categoria alimentare (in grammi)
    FOOD_CATEGORY_LIMITS: {
        'latte': 200,
        'yogurt': 150,
        'formaggio': 50,
        'formaggio_fresco': 100,
        'pane': 80,
        'pasta': 100,
        'riso': 90,
        'cereali': 80,
        'carne_rossa': 120,
        'carne_bianca': 150,
        'pesce': 200,
        'uova': 120,
        'affettati': 50,
        'legumi': 150,
        'verdura': 300,
        'frutta': 200,
        'frutta_secca': 30,
        'olio': 15,
        'burro': 10,
        'miele': 20,
        'default': 150
    },
    
    // Priorità di bilanciamento per tipo pasto (Dieta Mediterranea 2025)
    mealTypePriorities: {
        breakfast: {
            name: 'Colazione',
            priorities: { carbs: 1.6, fats: 1.2, protein: 0.7 },
            description: 'Carboidrati complessi per energia mattutina'
        },
        morningSnack: {
            name: 'Spuntino Mattina',
            priorities: { carbs: 1.0, fats: 0.9, protein: 1.3 },
            description: 'Frutta e proteine leggere'
        },
        lunch: {
            name: 'Pranzo',
            priorities: { carbs: 1.4, fats: 1.0, protein: 1.2 },
            description: 'Pasto principale equilibrato'
        },
        afternoonSnack: {
            name: 'Merenda',
            priorities: { carbs: 0.8, fats: 1.4, protein: 1.0 },
            description: 'Grassi buoni da frutta secca'
        },
        dinner: {
            name: 'Cena',
            priorities: { carbs: 0.5, fats: 1.0, protein: 1.7 },
            description: 'Proteine alte, carboidrati ridotti',
            categoryOverrides: { 'pasta': 60, 'riso': 50, 'pane': 50 }
        }
    },
    
    /**
     * Calcola le grammature ottimali per raggiungere il target del pasto
     * @param {Array} selectedFoods - Alimenti selezionati con i loro valori nutrizionali per 100g
     * @param {Object} targetMacros - Target del pasto {calories, protein, carbs, fats}
     * @param {String} mealType - Tipo di pasto (breakfast, lunch, dinner, etc.)
     * @returns {Array} - Alimenti con grammature ottimizzate
     */
    calculateOptimalGrams(selectedFoods, targetMacros, mealType = 'lunch') {
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
            return this.calculateSingleFood(selectedFoods[0], target, mealType);
        }
        
        // Per più alimenti, usa l'algoritmo di ottimizzazione
        return this.optimizeMultipleFoods(selectedFoods, target, mealType);
    },
    
    /**
     * Calcolo per singolo alimento
     */
    calculateSingleFood(food, target, mealType = 'lunch') {
        // Priorità: calorie, poi proteine
        const caloriesPer100g = food.calories || 0;
        
        if (caloriesPer100g <= 0) {
            return [{ ...food, grams: 100 }];
        }
        
        // Calcola grammi per raggiungere target calorie
        let grams = Math.round((target.calories / caloriesPer100g) * 100);
        grams = Math.max(1, grams); // Minimo 1g
        
        // Applica il limite massimo per categoria
        const maxGrams = this.getMaxGramsForFood(food, mealType);
        grams = Math.min(grams, maxGrams);
        
        return [{
            ...food,
            grams: grams,
            calculatedNutrients: this.calculateNutrients(food, grams)
        }];
    },
    
    /**
     * Ottimizzazione per più alimenti usando algoritmo iterativo
     */
    optimizeMultipleFoods(foods, target, mealType = 'lunch') {
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
            currentGrams = this.adjustGrams(foods, currentGrams, errors, target, mealType);
        }
        
        // Arrotonda a multipli di 1g e assicura minimo 1g
        currentGrams = currentGrams.map(g => Math.max(1, Math.round(g)));
        
        // Applica i limiti massimi per categoria
        currentGrams = currentGrams.map((g, index) => {
            const maxGrams = this.getMaxGramsForFood(foods[index], mealType);
            return Math.min(g, maxGrams);
        });
        
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
    adjustGrams(foods, currentGrams, errors, target, mealType = 'lunch') {
        const newGrams = [...currentGrams];
        const n = foods.length;
        
        // Ottieni le priorità per questo tipo di pasto
        const priorities = this.mealTypePriorities[mealType]?.priorities || { carbs: 1.0, fats: 1.0, protein: 1.0 };
        
        for (let i = 0; i < n; i++) {
            const food = foods[i];
            let adjustment = 0;
            
            // Calcola l'aggiustamento basato su tutti i macro
            const caloriesPer1g = (food.calories || 0) / 100;
            const proteinPer1g = (food.protein || 0) / 100;
            const carbsPer1g = (food.carbs || 0) / 100;
            const fatsPer1g = (food.fats || 0) / 100;
            
            // Contributo di ogni macro all'aggiustamento con priorità per tipo pasto
            if (caloriesPer1g > 0) {
                adjustment += (errors.calories / n) / caloriesPer1g * this.CALORIE_WEIGHT * this.CALORIE_CONTRIBUTION_FACTOR;
            }
            if (proteinPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.protein / n) / proteinPer1g * this.PROTEIN_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR * priorities.protein;
            }
            if (carbsPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.carbs / n) / carbsPer1g * this.CARBS_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR * priorities.carbs;
            }
            if (fatsPer1g > this.MIN_MACRO_PER_GRAM) {
                adjustment += (errors.fats / n) / fatsPer1g * this.FATS_WEIGHT * this.MACRO_CONTRIBUTION_FACTOR * priorities.fats;
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
    },
    
    /**
     * Rileva la categoria dell'alimento in base al nome
     * @param {Object} food - L'alimento da classificare
     * @returns {String} - La categoria dell'alimento
     */
    detectFoodCategory(food) {
        const name = (food.name || '').toLowerCase();
        
        // Latte
        if (name.includes('latte')) return 'latte';
        
        // Yogurt
        if (name.includes('yogurt')) return 'yogurt';
        
        // Formaggi freschi (più specifico prima)
        if (name.includes('ricotta') || name.includes('mozzarella') || 
            name.includes('stracchino') || name.includes('crescenza') ||
            name.includes('spalmabile')) return 'formaggio_fresco';
        
        // Formaggi stagionati
        if (name.includes('formaggio') || name.includes('parmigiano') || 
            name.includes('pecorino') || name.includes('grana') ||
            name.includes('feta') || name.includes('caciotta') ||
            name.includes('scamorza') || name.includes('gorgonzola') ||
            name.includes('emmental') || name.includes('provolone') ||
            name.includes('asiago') || name.includes('fontina')) return 'formaggio';
        
        // Pane
        if (name.includes('pane') || name.includes('fette') || name.includes('fetta')) return 'pane';
        
        // Pasta
        if (name.includes('pasta') || name.includes('spaghetti') || 
            name.includes('penne') || name.includes('fusilli') ||
            name.includes('rigatoni') || name.includes('linguine') ||
            name.includes('tagliatelle') || name.includes('farfalle')) return 'pasta';
        
        // Riso
        if (name.includes('riso')) return 'riso';
        
        // Cereali/Fiocchi
        if (name.includes('fiocchi') || name.includes('avena') || 
            name.includes('cereali') || name.includes('muesli') ||
            name.includes('corn flakes')) return 'cereali';
        
        // Carne bianca
        if (name.includes('pollo') || name.includes('tacchino') || 
            name.includes('coniglio') || name.includes('galletto')) return 'carne_bianca';
        
        // Carne rossa
        if (name.includes('manzo') || name.includes('vitello') || 
            name.includes('maiale') || name.includes('agnello') ||
            name.includes('vitellone')) return 'carne_rossa';
        
        // Pesce
        if (name.includes('salmone') || name.includes('tonno') || 
            name.includes('pesce') || name.includes('orata') ||
            name.includes('branzino') || name.includes('merluzzo') ||
            name.includes('trota') || name.includes('sgombro') ||
            name.includes('sardine') || name.includes('acciughe') ||
            name.includes('gamberi') || name.includes('calamari') ||
            name.includes('polpo') || name.includes('cozze')) return 'pesce';
        
        // Uova
        if (name.includes('uovo') || name.includes('uova')) return 'uova';
        
        // Affettati
        if (name.includes('prosciutto') || name.includes('salame') || 
            name.includes('bresaola') || name.includes('speck') ||
            name.includes('mortadella') || name.includes('coppa') ||
            name.includes('pancetta') || name.includes('affettato')) return 'affettati';
        
        // Legumi
        if (name.includes('legumi') || name.includes('fagioli') || 
            name.includes('lenticchie') || name.includes('ceci') ||
            name.includes('fave') || name.includes('piselli') ||
            name.includes('soia')) return 'legumi';
        
        // Verdura
        if (food.category === 'vegetables') return 'verdura';
        
        // Frutta secca
        if (name.includes('noci') || name.includes('mandorle') || 
            name.includes('nocciole') || name.includes('pistacchi') ||
            name.includes('anacardi') || name.includes('pinoli') ||
            name.includes('arachidi') || name.includes('semi')) return 'frutta_secca';
        
        // Frutta
        if (food.category === 'fruits') return 'frutta';
        
        // Olio
        if (name.includes('olio') && !name.includes('burro')) return 'olio';
        
        // Burro
        if (name.includes('burro') && !name.includes('arachidi') && !name.includes('mandorle')) return 'burro';
        
        // Miele
        if (name.includes('miele')) return 'miele';
        
        return 'default';
    },
    
    /**
     * Ottiene il limite massimo di grammi per un alimento in base al tipo di pasto
     * @param {Object} food - L'alimento
     * @param {String} mealType - Il tipo di pasto
     * @returns {Number} - Il limite massimo in grammi
     */
    getMaxGramsForFood(food, mealType) {
        const category = this.detectFoodCategory(food);
        const mealConfig = this.mealTypePriorities[mealType];
        
        // Verifica se c'è un override specifico per questo pasto (es. cena)
        if (mealConfig?.categoryOverrides?.[category]) {
            return mealConfig.categoryOverrides[category];
        }
        
        // Altrimenti usa il limite standard della categoria
        return this.FOOD_CATEGORY_LIMITS[category] || this.FOOD_CATEGORY_LIMITS['default'];
    }
};

window.MealOptimizer = MealOptimizer;

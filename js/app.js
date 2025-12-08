/**
 * Main Application Module - Orchestrates all modules
 */

const App = {
    currentScreen: 'profile',
    currentPage: 'dashboard',
    currentWeek: new Date(),
    currentDay: new Date(),

    // Initialize application
    async init() {
        console.log('Initializing Dieta Mediterranea App...');

        // Register service worker for offline support
        if ('serviceWorker' in navigator) {
            try {
                await navigator.serviceWorker.register('/sw.js');
                console.log('Service Worker registered successfully');
            } catch (error) {
                console.error('Service Worker registration failed:', error);
            }
        }

        // Initialize storage
        if (!Storage.init()) {
            this.showToast('Errore nell\'inizializzazione dello storage', 'error');
            return;
        }

        // Initialize IndexedDB
        await Storage.initIndexedDB();

        // Initialize profiles
        await Profiles.init();

        // Check if user has profiles
        const profiles = await Profiles.getAllProfiles();
        
        if (profiles.length === 0 || !Profiles.getCurrentProfile()) {
            // Show profile selection screen
            this.showScreen('profileScreen');
            this.renderProfileList();
        } else {
            // Show main app
            this.showScreen('appScreen');
            await this.loadMainApp();
        }

        // Setup event listeners
        this.setupEventListeners();

        console.log('App initialized successfully');
    },

    // Setup all event listeners
    setupEventListeners() {
        // Profile screen events
        document.getElementById('createProfileBtn')?.addEventListener('click', () => {
            this.showProfileForm();
        });

        document.getElementById('cancelProfileBtn')?.addEventListener('click', () => {
            this.showScreen('profileScreen');
            this.renderProfileList();
        });

        document.getElementById('profileForm')?.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleProfileFormSubmit();
        });

        // Auto-calculate BMI when height/weight changes
        ['profileHeight', 'profileWeight'].forEach(id => {
            document.getElementById(id)?.addEventListener('input', () => {
                this.updateBMIDisplay();
            });
        });

        // Navigation events
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const page = link.dataset.page;
                this.navigateTo(page);
            });
        });

        // Change profile button
        document.getElementById('changeProfileBtn')?.addEventListener('click', () => {
            this.showScreen('profileScreen');
            this.renderProfileList();
        });

        // Week navigation
        document.getElementById('prevWeek')?.addEventListener('click', () => {
            this.navigateWeek(-1);
        });

        document.getElementById('nextWeek')?.addEventListener('click', () => {
            this.navigateWeek(1);
        });

        // Weight tracking
        document.getElementById('addWeightBtn')?.addEventListener('click', () => {
            this.showWeightForm();
        });

        document.getElementById('cancelWeightBtn')?.addEventListener('click', () => {
            this.hideWeightForm();
        });

        document.getElementById('weightEntryForm')?.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleWeightFormSubmit();
        });

        // Shopping list
        document.getElementById('generateShoppingList')?.addEventListener('click', () => {
            this.generateShoppingList();
        });

        document.getElementById('exportShoppingList')?.addEventListener('click', () => {
            this.exportShoppingList();
        });

        document.getElementById('printShoppingList')?.addEventListener('click', () => {
            this.printShoppingList();
        });

        // Backup
        document.getElementById('exportDataBtn')?.addEventListener('click', () => {
            this.exportData();
        });

        document.getElementById('importDataBtn')?.addEventListener('click', () => {
            document.getElementById('importFile').click();
        });

        document.getElementById('importFile')?.addEventListener('change', (e) => {
            this.importData(e.target.files[0]);
        });

        // Profile management
        document.getElementById('editProfileBtn')?.addEventListener('click', () => {
            this.editCurrentProfile();
        });

        document.getElementById('deleteProfileBtn')?.addEventListener('click', () => {
            this.deleteCurrentProfile();
        });

        // Workout level change
        document.getElementById('workoutLevel')?.addEventListener('change', (e) => {
            this.renderWorkoutSchedule(e.target.value);
        });

        // Export workout PDF
        document.getElementById('exportWorkoutPdfBtn')?.addEventListener('click', () => {
            this.exportWorkoutToPDF();
        });
    },

    // Show specific screen
    showScreen(screenId) {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.remove('active');
        });
        document.getElementById(screenId)?.classList.add('active');
        this.currentScreen = screenId;
    },

    // Navigate to page
    navigateTo(page) {
        document.querySelectorAll('.page').forEach(p => {
            p.classList.remove('active');
        });
        document.getElementById(page + 'Page')?.classList.add('active');

        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[data-page="${page}"]`)?.classList.add('active');

        this.currentPage = page;

        // Load page-specific content
        this.loadPageContent(page);
    },

    // Load page content
    async loadPageContent(page) {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        switch (page) {
            case 'dashboard':
                await this.renderDashboard();
                break;
            case 'meals':
                await this.renderMeals();
                break;
            case 'weight':
                await this.renderWeight();
                break;
            case 'workout':
                await this.renderWorkout();
                break;
            case 'profile':
                await this.renderProfile();
                break;
        }
    },

    // Render profile list
    async renderProfileList() {
        const profiles = await Profiles.getAllProfiles();
        const container = document.getElementById('profileList');
        
        if (profiles.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: #999;">Nessun profilo creato</p>';
            return;
        }

        container.innerHTML = profiles.map(profile => `
            <div class="profile-card" data-profile-id="${profile.id}">
                <h3>${profile.name}</h3>
                <div class="profile-info">
                    ${profile.age} anni • ${profile.gender === 'male' ? 'Maschio' : 'Femmina'} • 
                    ${profile.height} cm • ${profile.weight} kg • BMI: ${profile.bmi}
                </div>
            </div>
        `).join('');

        // Add click handlers
        container.querySelectorAll('.profile-card').forEach(card => {
            card.addEventListener('click', async () => {
                const profileId = card.dataset.profileId;
                await Profiles.setCurrentProfile(profileId);
                this.showScreen('appScreen');
                await this.loadMainApp();
            });
        });
    },

    // Show profile form
    showProfileForm(profile = null) {
        this.showScreen('profileFormScreen');
        
        const form = document.getElementById('profileForm');
        const title = document.getElementById('profileFormTitle');
        
        if (profile) {
            title.textContent = 'Modifica Profilo';
            form.dataset.profileId = profile.id;
            document.getElementById('profileName').value = profile.name;
            document.getElementById('profileAge').value = profile.age;
            document.getElementById('profileGender').value = profile.gender;
            document.getElementById('profileHeight').value = profile.height;
            document.getElementById('profileWeight').value = profile.weight;
            document.getElementById('profileActivity').value = profile.hasActivity ? 'yes' : 'no';
            this.updateBMIDisplay();
        } else {
            title.textContent = 'Crea Nuovo Profilo';
            form.reset();
            delete form.dataset.profileId;
            document.getElementById('bmiDisplay').textContent = '--';
        }
    },

    // Update BMI display
    updateBMIDisplay() {
        const height = parseFloat(document.getElementById('profileHeight').value);
        const weight = parseFloat(document.getElementById('profileWeight').value);
        const display = document.getElementById('bmiDisplay');

        if (height && weight) {
            const bmi = Profiles.calculateBMI(height, weight);
            const category = Profiles.getBMICategory(bmi);
            display.textContent = `${bmi} (${category})`;
        } else {
            display.textContent = '--';
        }
    },

    // Handle profile form submit
    async handleProfileFormSubmit() {
        const form = document.getElementById('profileForm');
        const data = {
            name: document.getElementById('profileName').value,
            age: document.getElementById('profileAge').value,
            gender: document.getElementById('profileGender').value,
            height: document.getElementById('profileHeight').value,
            weight: document.getElementById('profileWeight').value,
            hasActivity: document.getElementById('profileActivity').value
        };

        try {
            if (form.dataset.profileId) {
                // Update existing profile
                await Profiles.updateProfile(form.dataset.profileId, data);
                this.showToast('Profilo aggiornato con successo', 'success');
                await this.loadMainApp();
            } else {
                // Create new profile
                const profile = await Profiles.createProfile(data);
                await Profiles.setCurrentProfile(profile.id);
                this.showToast('Profilo creato con successo', 'success');
                this.showScreen('appScreen');
                await this.loadMainApp();
            }
        } catch (error) {
            console.error('Error saving profile:', error);
            this.showToast('Errore nel salvataggio del profilo', 'error');
        }
    },

    // Load main app content
    async loadMainApp() {
        await this.renderDashboard();
        this.navigateTo('dashboard');
    },

    // Render dashboard
    async renderDashboard() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const nutrition = Nutrition.calculateProfileNutrition(profile);

        // Welcome message
        document.getElementById('profileWelcome').textContent = `Benvenuto, ${profile.name}!`;

        // Stats
        document.getElementById('tdeeValue').textContent = nutrition.tdee;
        document.getElementById('targetCalories').textContent = nutrition.targetCalories;
        document.getElementById('bmiValue').textContent = profile.bmi;
        document.getElementById('bmiCategory').textContent = Profiles.getBMICategory(profile.bmi);
        document.getElementById('currentWeight').textContent = profile.weight;

        // Macros
        document.getElementById('carbsTarget').textContent = `${nutrition.macros.carbs.grams}g`;
        document.getElementById('proteinTarget').textContent = `${nutrition.macros.protein.grams}g`;
        document.getElementById('fatsTarget').textContent = `${nutrition.macros.fats.grams}g`;

        // Today's meals summary
        const today = new Date();
        const meals = await Meals.getMealsByDate(profile.id, today);
        const dailyNutrition = Meals.calculateDailyNutrition(meals);

        const summaryContainer = document.getElementById('todayMealsSummary');
        if (meals.length === 0) {
            summaryContainer.innerHTML = '<p style="text-align: center; color: #999;">Nessun pasto pianificato per oggi</p>';
        } else {
            // Show macro summary
            const macroSummaryHTML = `
                <div class="macro-grid">
                    <div class="stat-card">
                        <h3>Calorie</h3>
                        <p class="stat-value">${dailyNutrition.calories}</p>
                        <small>di ${nutrition.targetCalories} kcal</small>
                    </div>
                    <div class="stat-card">
                        <h3>Proteine</h3>
                        <p class="stat-value">${dailyNutrition.protein}g</p>
                        <small>di ${nutrition.macros.protein.grams}g</small>
                    </div>
                    <div class="stat-card">
                        <h3>Carboidrati</h3>
                        <p class="stat-value">${dailyNutrition.carbs}g</p>
                        <small>di ${nutrition.macros.carbs.grams}g</small>
                    </div>
                    <div class="stat-card">
                        <h3>Grassi</h3>
                        <p class="stat-value">${dailyNutrition.fats}g</p>
                        <small>di ${nutrition.macros.fats.grams}g</small>
                    </div>
                </div>
            `;

            // Show meal details
            const mealsDetailsHTML = `
                <div style="margin-top: 2rem;">
                    <h3 style="margin-bottom: 1rem;">📋 Pasti di Oggi</h3>
                    ${meals.map(meal => {
                        const mealTypeName = Nutrition.getMealTypeName(meal.mealType);
                        return `
                            <div style="background: white; border: 1px solid #e0e0e0; border-radius: 8px; padding: 1rem; margin-bottom: 1rem;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                                    <h4 style="margin: 0; color: var(--primary);">${mealTypeName}</h4>
                                    <span style="font-weight: bold; color: var(--primary);">${meal.totalNutrition.calories} kcal</span>
                                </div>
                                <div style="font-size: 0.9rem; color: #666; margin-bottom: 0.75rem;">
                                    Proteine: ${meal.totalNutrition.protein}g | 
                                    Carboidrati: ${meal.totalNutrition.carbs}g | 
                                    Grassi: ${meal.totalNutrition.fats}g |
                                    Fibre: ${meal.totalNutrition.fiber}g
                                </div>
                                <div style="border-top: 1px solid #f0f0f0; padding-top: 0.75rem;">
                                    ${meal.foodItems.map(item => `
                                        <div style="display: flex; justify-content: space-between; padding: 0.25rem 0; font-size: 0.9rem;">
                                            <span>• ${item.foodName}</span>
                                            <span style="color: #666;">${item.grams}g</span>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            `;

            summaryContainer.innerHTML = macroSummaryHTML + mealsDetailsHTML;
        }

        // Show safety warning if deficit is too aggressive
        if (!nutrition.isSafe) {
            this.showToast('Attenzione: il deficit calorico è stato limitato per sicurezza', 'warning');
        }
    },

    // Render meals page
    async renderMeals() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        // Setup week navigation
        const weekDates = Meals.getWeekDates(this.currentWeek);
        const weekStart = weekDates[0];
        const weekEnd = weekDates[6];
        
        document.getElementById('currentWeek').textContent = 
            `${weekStart.toLocaleDateString('it-IT', { day: '2-digit', month: 'short' })} - ${weekEnd.toLocaleDateString('it-IT', { day: '2-digit', month: 'short', year: 'numeric' })}`;

        // Render day tabs
        const dayTabsContainer = document.getElementById('dayTabs');
        dayTabsContainer.innerHTML = weekDates.map((date, index) => `
            <div class="day-tab ${index === 0 ? 'active' : ''}" data-date="${Meals.formatDate(date)}">
                ${Meals.getDayName(date)}<br>
                <small>${date.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit' })}</small>
            </div>
        `).join('');

        // Add click handlers to tabs
        dayTabsContainer.querySelectorAll('.day-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                dayTabsContainer.querySelectorAll('.day-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');
                this.currentDay = new Date(tab.dataset.date);
                this.renderDayMeals();
            });
        });

        // Render first day
        this.currentDay = weekDates[0];
        await this.renderDayMeals();
    },

    // Render meals for a specific day
    async renderDayMeals() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const nutrition = Nutrition.calculateProfileNutrition(profile);
        const mealTypes = Nutrition.getAllMealTypes();
        const container = document.getElementById('mealsContainer');

        const mealsHTML = await Promise.all(mealTypes.map(async ({ key, name }) => {
            const mealMacros = Nutrition.getMealMacros(key, nutrition.macros);
            const meal = await Meals.getMealByDateAndType(profile.id, this.currentDay, key);

            return `
                <div class="meal-section">
                    <div class="meal-header">
                        <h3>${name}</h3>
                        <div class="meal-target">Target: ${mealMacros.calories} kcal</div>
                    </div>
                    <div class="meal-items" id="meal-${key}">
                        ${meal ? this.renderMealItems(meal.foodItems) : '<p style="color: #999;">Nessun alimento aggiunto</p>'}
                    </div>
                    ${meal ? `
                        <div style="margin-top: 1rem; padding: 1rem; background: var(--cream); border-radius: 6px;">
                            <strong>Totale:</strong> 
                            ${meal.totalNutrition.calories} kcal | 
                            Proteine: ${meal.totalNutrition.protein}g | 
                            Carboidrati: ${meal.totalNutrition.carbs}g | 
                            Grassi: ${meal.totalNutrition.fats}g
                        </div>
                    ` : ''}
                    <div style="display: flex; gap: 10px; margin-top: 0.5rem;">
                        <button class="btn btn-primary meal-add-btn" data-meal-type="${key}" style="flex: 1;">
                            ${meal ? '✏️ Modifica Pasto' : '+ Aggiungi Alimenti'}
                        </button>
                        ${meal ? `
                            <button class="btn btn-danger meal-delete-btn" data-meal-id="${meal.id}" data-meal-type="${key}" style="background: #dc3545; color: white;">
                                🗑️ Elimina
                            </button>
                        ` : ''}
                    </div>
                </div>
            `;
        }));

        container.innerHTML = mealsHTML.join('');

        // Add click handlers to add/modify buttons
        container.querySelectorAll('.meal-add-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const mealType = btn.dataset.mealType;
                this.showFoodSelector(mealType);
            });
        });

        // Add click handlers to delete buttons
        container.querySelectorAll('.meal-delete-btn').forEach(btn => {
            btn.addEventListener('click', async () => {
                const mealId = btn.dataset.mealId;
                const mealType = btn.dataset.mealType;
                const mealName = {
                    breakfast: 'Colazione',
                    morningSnack: 'Spuntino Mattina',
                    lunch: 'Pranzo',
                    afternoonSnack: 'Merenda',
                    dinner: 'Cena'
                }[mealType];
                
                if (confirm(`Sei sicuro di voler eliminare ${mealName}? Questa azione non può essere annullata.`)) {
                    const success = await Meals.deleteMeal(mealId);
                    if (success) {
                        this.showToast('Pasto eliminato con successo', 'success');
                        await this.renderMealsForDate(this.selectedDate);
                        await this.renderDashboard();
                    } else {
                        this.showToast('Errore nell\'eliminazione del pasto', 'error');
                    }
                }
            });
        });
    },

    // Render meal items
    renderMealItems(foodItems) {
        return foodItems.map(item => `
            <div class="meal-item">
                <div class="meal-item-info">
                    <div class="meal-item-name">${item.foodName}</div>
                    <div class="meal-item-macros">
                        <strong>${item.grams}g</strong> - 
                        ${item.nutrition.calories} kcal | 
                        Proteine: ${item.nutrition.protein}g | 
                        Carboidrati: ${item.nutrition.carbs}g | 
                        Grassi: ${item.nutrition.fats}g
                    </div>
                </div>
            </div>
        `).join('');
    },

    // Show food selector modal
    showFoodSelector(mealType) {
        const modal = document.getElementById('foodModal');
        modal.classList.add('active');
        modal.dataset.mealType = mealType;

        // Initialize selected foods array
        this.selectedFoods = [];
        this.calculatedPortions = null;

        // Get target macros for this meal
        const profile = Profiles.getCurrentProfile();
        const nutrition = Nutrition.calculateProfileNutrition(profile);
        const mealMacros = Nutrition.getMealMacros(mealType, nutrition.macros);
        
        // Store target for later use
        this.currentMealTarget = mealMacros;

        // Update meal target info
        document.getElementById('mealTypeName').textContent = Nutrition.getMealTypeName(mealType);
        document.getElementById('mealTargetCalories').textContent = mealMacros.calories;
        document.getElementById('targetCarbs').textContent = mealMacros.carbs;
        document.getElementById('targetProtein').textContent = mealMacros.protein;
        document.getElementById('targetFats').textContent = mealMacros.fats;

        // Setup modal
        const searchInput = document.getElementById('foodSearch');
        const categorySelect = document.getElementById('foodCategory');

        // Populate categories
        const categories = FoodDatabase.getAllCategories();
        categorySelect.innerHTML = '<option value="">Tutte le categorie</option>' +
            categories.map(cat => `<option value="${cat.key}">${cat.name}</option>`).join('');

        // Render all foods initially
        this.renderFoodList(FoodDatabase.getAllFoods());

        // Update selected foods display
        this.updateSelectedFoodsDisplay();

        // Search handler
        searchInput.oninput = () => {
            const query = searchInput.value;
            const category = categorySelect.value;
            this.filterFoods(query, category);
        };

        // Category filter handler
        categorySelect.onchange = () => {
            const query = searchInput.value;
            const category = categorySelect.value;
            this.filterFoods(query, category);
        };

        // Calculate portions button handler
        document.getElementById('calculatePortionsBtn').onclick = () => {
            this.calculateMealPortions();
        };

        // Save meal button handler
        document.getElementById('saveMealBtn').onclick = () => {
            this.saveMealFromModal();
        };

        // Close modal handler
        modal.querySelector('.modal-close').onclick = () => {
            this.closeFoodModal();
        };

        // Close on background click
        modal.onclick = (e) => {
            if (e.target === modal) {
                this.closeFoodModal();
            }
        };
    },

    // Close food modal
    closeFoodModal() {
        const modal = document.getElementById('foodModal');
        modal.classList.remove('active');
        this.selectedFoods = [];
        this.calculatedPortions = null;
        this.currentMealTarget = null;
        
        // Reset search
        document.getElementById('foodSearch').value = '';
        document.getElementById('foodCategory').value = '';
    },

    // Update selected foods display
    updateSelectedFoodsDisplay() {
        const container = document.getElementById('selectedFoodsList');
        const countSpan = document.getElementById('selectedCount');
        const calculateBtn = document.getElementById('calculatePortionsBtn');
        const saveMealBtn = document.getElementById('saveMealBtn');
        const mealAnalysis = document.getElementById('mealAnalysis');

        countSpan.textContent = this.selectedFoods.length;

        if (this.selectedFoods.length === 0) {
            container.innerHTML = '<p class="empty-message">Seleziona fino a 5 ingredienti dalla lista</p>';
            calculateBtn.disabled = true;
            saveMealBtn.style.display = 'none';
            mealAnalysis.style.display = 'none';
            return;
        }

        calculateBtn.disabled = false;

        // Show selected foods
        const html = this.selectedFoods.map((food, index) => {
            const portion = this.calculatedPortions ? this.calculatedPortions[index] : null;
            
            return `
                <div class="selected-food-item ${portion ? 'calculated' : ''}">
                    <div class="selected-food-header">
                        <div class="selected-food-name">${food.name}</div>
                        <button class="remove-food-btn" data-index="${index}">×</button>
                    </div>
                    <div class="selected-food-info">
                        Per 100g: ${food.calories} kcal | Proteine: ${food.protein}g | Carboidrati: ${food.carbs}g | Grassi: ${food.fats}g
                    </div>
                    ${portion ? `
                        <div class="selected-food-portion">
                            <input type="number" class="portion-input" value="${portion.grams}" 
                                   min="10" max="500" step="5" data-index="${index}">
                            <span>g →</span>
                            <span>${portion.nutrition.calories} kcal | 
                                  Proteine: ${portion.nutrition.protein}g | 
                                  Carboidrati: ${portion.nutrition.carbs}g | 
                                  Grassi: ${portion.nutrition.fats}g</span>
                        </div>
                    ` : ''}
                </div>
            `;
        }).join('');

        container.innerHTML = html;

        // Add remove button handlers
        container.querySelectorAll('.remove-food-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const index = parseInt(btn.dataset.index, 10);
                this.removeFoodFromSelection(index);
            });
        });

        // Add portion input handlers for manual adjustment
        container.querySelectorAll('.portion-input').forEach(input => {
            input.addEventListener('change', () => {
                const index = parseInt(input.dataset.index, 10);
                const newGrams = parseInt(input.value, 10);
                
                // Validate portion range (10-500g)
                if (isNaN(newGrams) || newGrams < 10 || newGrams > 500) {
                    showNotification('Grammatura deve essere tra 10g e 500g', 'error');
                    input.value = this.calculatedPortions[index].grams; // Reset to previous value
                    return;
                }
                
                this.updatePortionManually(index, newGrams);
            });
        });

        // Show meal analysis if portions calculated
        if (this.calculatedPortions) {
            this.displayMealAnalysis();
            saveMealBtn.style.display = 'block';
        }
    },

    // Remove food from selection
    removeFoodFromSelection(index) {
        this.selectedFoods.splice(index, 1);
        
        // Clear calculations if we remove a food
        if (this.calculatedPortions) {
            this.calculatedPortions = null;
        }
        
        this.updateSelectedFoodsDisplay();
        this.renderFoodList(FoodDatabase.getAllFoods());
    },

    // Update portion manually
    updatePortionManually(index, newGrams) {
        if (!this.calculatedPortions || !this.calculatedPortions[index]) return;
        
        // Update the grams
        this.calculatedPortions[index].grams = newGrams;
        
        // Recalculate nutrition for this portion
        const food = this.calculatedPortions[index].food;
        this.calculatedPortions[index].nutrition = Nutrition.calculateFoodNutrition(food, newGrams);
        
        // Update display
        this.displayMealAnalysis();
    },

    // Calculate meal portions
    calculateMealPortions() {
        if (this.selectedFoods.length === 0) return;

        // Calculate optimal portions
        this.calculatedPortions = Nutrition.calculateOptimalPortions(
            this.selectedFoods, 
            this.currentMealTarget
        );

        // Update display
        this.updateSelectedFoodsDisplay();
        
        this.showToast('Grammature calcolate! Verifica i valori nutrizionali', 'success');
    },

    // Display meal analysis
    displayMealAnalysis() {
        const analysisDiv = document.getElementById('mealAnalysis');
        const totalNutritionDiv = document.getElementById('totalNutrition');
        const macroAdherenceDiv = document.getElementById('macroAdherence');
        const suggestionsDiv = document.getElementById('suggestions');

        if (!this.calculatedPortions) {
            analysisDiv.style.display = 'none';
            return;
        }

        analysisDiv.style.display = 'block';

        // Get analysis
        const analysis = Nutrition.analyzeMealComposition(
            this.calculatedPortions,
            this.currentMealTarget
        );

        // Display total nutrition
        totalNutritionDiv.innerHTML = `
            <div class="nutrition-item">
                <span class="nutrition-label">Calorie</span>
                <span class="nutrition-value">${analysis.totalNutrition.calories} kcal</span>
            </div>
            <div class="nutrition-item">
                <span class="nutrition-label">Proteine</span>
                <span class="nutrition-value">${analysis.totalNutrition.protein}g</span>
            </div>
            <div class="nutrition-item">
                <span class="nutrition-label">Carboidrati</span>
                <span class="nutrition-value">${analysis.totalNutrition.carbs}g</span>
            </div>
            <div class="nutrition-item">
                <span class="nutrition-label">Grassi</span>
                <span class="nutrition-value">${analysis.totalNutrition.fats}g</span>
            </div>
            <div class="nutrition-item">
                <span class="nutrition-label">Fibre</span>
                <span class="nutrition-value">${analysis.totalNutrition.fiber}g</span>
            </div>
        `;

        // Display macro adherence
        const adherenceHTML = ['calories', 'protein', 'carbs', 'fats'].map(macro => {
            const adh = analysis.adherence[macro];
            const macroNames = {
                calories: 'Calorie',
                protein: 'Proteine',
                carbs: 'Carboidrati',
                fats: 'Grassi'
            };
            
            return `
                <div class="adherence-item ${adh.level}">
                    <div class="adherence-label">
                        <span class="adherence-icon">${adh.icon}</span>
                        <span>${macroNames[macro]}</span>
                    </div>
                    <div class="adherence-values">
                        <div class="adherence-current">
                            ${analysis.totalNutrition[macro]}${macro === 'calories' ? ' kcal' : 'g'} / 
                            ${this.currentMealTarget[macro]}${macro === 'calories' ? ' kcal' : 'g'}
                        </div>
                        <div class="adherence-deviation">${adh.deviation.toFixed(1)}% scostamento</div>
                    </div>
                </div>
            `;
        }).join('');

        macroAdherenceDiv.innerHTML = adherenceHTML;

        // Display suggestions
        if (analysis.suggestions && analysis.suggestions.length > 0) {
            suggestionsDiv.style.display = 'block';
            suggestionsDiv.innerHTML = analysis.suggestions
                .map(s => `<div class="suggestion-item">${s}</div>`)
                .join('');
        } else {
            suggestionsDiv.style.display = 'none';
        }
    },

    // Save meal from modal
    async saveMealFromModal() {
        if (!this.calculatedPortions || this.calculatedPortions.length === 0) {
            this.showToast('Calcola prima le grammature', 'warning');
            return;
        }

        const modal = document.getElementById('foodModal');
        const mealType = modal.dataset.mealType;
        const profile = Profiles.getCurrentProfile();

        try {
            await Meals.saveMeal(
                profile.id, 
                Meals.formatDate(this.currentDay), 
                mealType, 
                this.calculatedPortions
            );

            this.closeFoodModal();
            this.showToast('Pasto salvato con successo!', 'success');
            await this.renderDayMeals();
        } catch (error) {
            console.error('Error saving meal:', error);
            this.showToast('Errore nel salvataggio del pasto', 'error');
        }
    },

    // Filter and render foods
    filterFoods(query, category) {
        let foods = FoodDatabase.getAllFoods();

        if (category) {
            foods = foods.filter(f => f.category === category);
        }

        if (query) {
            foods = foods.filter(f => f.name.toLowerCase().includes(query.toLowerCase()));
        }

        this.renderFoodList(foods);
    },

    // Render food list
    renderFoodList(foods) {
        const foodList = document.getElementById('foodList');
        
        if (foods.length === 0) {
            foodList.innerHTML = '<p style="text-align: center; color: #999;">Nessun alimento trovato</p>';
            return;
        }

        foodList.innerHTML = foods.map(food => {
            const isSelected = this.selectedFoods && this.selectedFoods.some(f => f.name === food.name);
            return `
                <div class="food-item ${isSelected ? 'selected' : ''}" data-food="${food.name}">
                    <div class="food-item-name">${food.name}</div>
                    <div class="food-item-category">${FoodDatabase.getCategoryName(food.category)}</div>
                    <div class="food-item-macros">
                        ${food.calories} kcal | Proteine: ${food.protein}g | Carboidrati: ${food.carbs}g | Grassi: ${food.fats}g (per 100g)
                    </div>
                </div>
            `;
        }).join('');

        // Add click handlers
        foodList.querySelectorAll('.food-item').forEach(item => {
            item.addEventListener('click', () => {
                const foodName = item.dataset.food;
                this.toggleFoodSelection(foodName);
            });
        });
    },

    // Toggle food selection (add or remove from selection)
    toggleFoodSelection(foodName) {
        // Check if already selected
        const index = this.selectedFoods.findIndex(f => f.name === foodName);
        
        if (index >= 0) {
            // Already selected, remove it
            this.removeFoodFromSelection(index);
        } else {
            // Not selected, add it (if under limit)
            if (this.selectedFoods.length >= 5) {
                this.showToast('Massimo 5 ingredienti per pasto', 'warning');
                return;
            }
            
            const food = FoodDatabase.getFoodByName(foodName);
            if (!food) {
                this.showToast('Alimento non trovato', 'error');
                return;
            }
            
            this.selectedFoods.push(food);
            
            // Clear previous calculations
            this.calculatedPortions = null;
            
            this.updateSelectedFoodsDisplay();
            this.renderFoodList(FoodDatabase.getAllFoods());
        }
    },

    // Navigate week
    navigateWeek(direction) {
        const currentWeek = new Date(this.currentWeek);
        currentWeek.setDate(currentWeek.getDate() + (direction * 7));
        this.currentWeek = currentWeek;
        this.renderMeals();
    },

    // Generate shopping list
    async generateShoppingList() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const weekDates = Meals.getWeekDates(this.currentWeek);
        const startDate = weekDates[0];
        const endDate = weekDates[6];

        try {
            const result = await Meals.generateShoppingList(profile.id, startDate, endDate);
            this.renderShoppingList(result);
            
            // Show/hide export button based on whether there are meals
            const actionsContainer = document.querySelector('.shopping-actions');
            if (actionsContainer) {
                actionsContainer.style.display = result.summary.totalMeals > 0 ? 'flex' : 'none';
            }
            
            this.showToast(result.summary.message, result.summary.totalMeals > 0 ? 'success' : 'info');
        } catch (error) {
            console.error('Error generating shopping list:', error);
            this.showToast('Errore nella generazione della lista', 'error');
        }
    },

    // Render shopping list
    renderShoppingList(result) {
        const container = document.getElementById('shoppingList');
        const actionsContainer = document.querySelector('.shopping-actions');

        // Build summary HTML
        const summaryHtml = `
            <div class="shopping-list-summary">
                <h4>📊 Riepilogo</h4>
                <p>${result.summary.message}</p>
                ${result.summary.totalMeals > 0 ? `
                    <details>
                        <summary>Giorni inclusi (${result.summary.totalDays})</summary>
                        <ul>
                            ${result.summary.mealsIncluded.map(m => 
                                `<li>${m.day} - ${m.mealType}</li>`
                            ).join('')}
                        </ul>
                    </details>
                ` : ''}
            </div>
        `;

        // If no meals
        if (result.summary.totalMeals === 0) {
            container.innerHTML = `
                ${summaryHtml}
                <div class="empty-state">
                    <p>🛒 Nessun ingrediente da mostrare</p>
                    <p>Vai al <strong>Pianificatore Pasti</strong> e compila almeno un pasto per generare la lista della spesa.</p>
                </div>
            `;
            if (actionsContainer) actionsContainer.style.display = 'none';
            return;
        }

        // Build shopping list HTML
        let listHtml = summaryHtml + '<div class="shopping-list-items">';
        
        Object.keys(result.items).forEach(categoryKey => {
            const categoryName = FoodDatabase.getCategoryName(categoryKey);
            listHtml += `
                <div class="shopping-category">
                    <h3>${categoryName}</h3>
                    <div class="shopping-items">
                        ${result.items[categoryKey].map(item => `
                            <div class="shopping-item">
                                <input type="checkbox" id="shop-${categoryKey}-${item.name}">
                                <label for="shop-${categoryKey}-${item.name}">
                                    <span class="item-name">${item.name}</span>
                                    <span class="item-quantity">${item.grams}g</span>
                                    ${item.occurrences > 1 ? `<span class="item-occurrences">(usato ${item.occurrences}x)</span>` : ''}
                                </label>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        });
        
        listHtml += '</div>';
        
        container.innerHTML = listHtml;

        // Show action buttons
        if (actionsContainer) actionsContainer.style.display = 'flex';

        // Add checkbox handlers
        container.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
            checkbox.addEventListener('change', (e) => {
                e.target.parentElement.classList.toggle('checked', e.target.checked);
            });
        });
    },

    // Export shopping list
    async exportShoppingList() {
        const profile = Profiles.getCurrentProfile();
        const weekDates = Meals.getWeekDates(this.currentWeek);
        const result = await Meals.generateShoppingList(profile.id, weekDates[0], weekDates[6]);
        
        const text = Meals.exportShoppingListToText(result.items);
        
        const blob = new Blob([text], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `lista-spesa-${Meals.formatDate(new Date())}.txt`;
        a.click();
        
        this.showToast('Lista esportata', 'success');
    },

    // Print shopping list to PDF
    printShoppingList() {
        const shoppingContainer = document.getElementById('shoppingList');
        
        if (!shoppingContainer || shoppingContainer.innerHTML.trim() === '') {
            this.showToast('Genera prima la lista della spesa', 'error');
            return;
        }

        // Add print class to body for print-specific styling
        document.body.classList.add('printing-shopping-list');
        
        // Print
        window.print();
        
        // Remove print class after printing
        setTimeout(() => {
            document.body.classList.remove('printing-shopping-list');
        }, 100);
    },

    // Render weight page
    async renderWeight() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const weights = await Profiles.getWeightHistory(profile.id);
        const stats = await Profiles.getWeightStats(profile.id);

        // Update stats
        document.getElementById('initialWeight').textContent = stats.initial ? `${stats.initial} kg` : '--';
        document.getElementById('latestWeight').textContent = stats.current ? `${stats.current} kg` : '--';
        document.getElementById('weightChange').textContent = stats.change ? `${stats.change > 0 ? '+' : ''}${stats.change.toFixed(1)} kg` : '--';
        document.getElementById('weeklyAverage').textContent = stats.weeklyAverage ? `${stats.weeklyAverage.toFixed(2)} kg/settimana` : '--';

        // Draw chart
        Charts.drawWeightChart('weightChart', weights);
        Charts.setupResponsiveChart('weightChart', weights);

        // Render history
        this.renderWeightHistory(weights);
    },

    // Render weight history
    renderWeightHistory(weights) {
        const container = document.getElementById('weightHistory');
        
        if (weights.length === 0) {
            container.innerHTML = '<h3>Storico</h3><p style="text-align: center; color: #999;">Nessuna registrazione</p>';
            return;
        }

        const html = `
            <h3>Storico Pesate</h3>
            ${weights.reverse().map(w => `
                <div class="weight-entry">
                    <div>
                        <strong>${new Date(w.date).toLocaleDateString('it-IT')}</strong>
                    </div>
                    <div>
                        ${w.weight} kg
                    </div>
                </div>
            `).join('')}
        `;

        container.innerHTML = html;
    },

    // Show weight form
    showWeightForm() {
        document.getElementById('weightForm').style.display = 'block';
        document.getElementById('weightDate').value = new Date().toISOString().split('T')[0];
    },

    // Hide weight form
    hideWeightForm() {
        document.getElementById('weightForm').style.display = 'none';
        document.getElementById('weightEntryForm').reset();
    },

    // Handle weight form submit
    async handleWeightFormSubmit() {
        const profile = Profiles.getCurrentProfile();
        const date = document.getElementById('weightDate').value;
        const weight = document.getElementById('weightValue').value;

        try {
            await Profiles.addWeightEntry(profile.id, parseFloat(weight), new Date(date).toISOString());
            this.hideWeightForm();
            this.showToast('Peso registrato', 'success');
            await this.renderWeight();
        } catch (error) {
            console.error('Error adding weight:', error);
            this.showToast('Errore nella registrazione del peso', 'error');
        }
    },

    // Render workout page
    async renderWorkout() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const level = Workout.getRecommendedLevel(profile);
        document.getElementById('workoutLevel').value = level;

        await this.renderWorkoutSchedule(level);
    },

    // Render workout schedule
    async renderWorkoutSchedule(level) {
        const program = Workout.getProgram(level);
        const container = document.getElementById('workoutSchedule');
        const profile = Profiles.getCurrentProfile();

        const html = program.schedule.map(day => {
            return `
                <div class="workout-day">
                    <h3>${day.day} - ${day.type}</h3>
                    <div class="exercise-list">
                        ${day.exercises.map(ex => {
                            const exercise = Workout.getExercise(ex.exercise);
                            const hasDetailedDescription = exercise.detailedDescription;
                            return `
                                <div class="exercise-item">
                                    <div class="exercise-header">
                                        <div style="flex: 1;">
                                            <div class="exercise-name">${exercise.name}</div>
                                            <div class="exercise-details">
                                                ${ex.sets} serie × ${ex.reps} ripetizioni
                                                ${ex.weight ? ` - ${ex.weight}` : ''}
                                                ${ex.resistance ? ` - Resistenza ${ex.resistance}` : ''}
                                                ${ex.rest !== undefined ? ` - Recupero: ${ex.rest}s` : exercise.restBetweenSets ? ` - Recupero: ${exercise.restBetweenSets}s` : ''}
                                                ${exercise.tempo ? ` - Tempo: ${exercise.tempo}` : ''}
                                            </div>
                                            <div class="exercise-details" style="margin-top: 0.25rem;">
                                                <small>${exercise.description}</small>
                                            </div>
                                            ${hasDetailedDescription ? `
                                                <button class="btn-link exercise-details-toggle" data-exercise="${ex.exercise}" style="margin-top: 0.5rem; font-size: 0.9rem;">
                                                    📖 Vedi spiegazione dettagliata
                                                </button>
                                                <div class="exercise-detailed-description" id="details-${ex.exercise}" style="display: none; margin-top: 1rem; padding: 1rem; background: #f8f9fa; border-left: 3px solid var(--primary); border-radius: 4px; font-size: 0.9rem; line-height: 1.6;">
                                                    ${exercise.imageUrl ? `
                                                        <div style="text-align: center; margin-bottom: 1rem;">
                                                            <img src="${exercise.imageUrl}" alt="${exercise.name}" style="max-width: 100%; max-height: 300px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" onerror="this.style.display='none'">
                                                        </div>
                                                    ` : ''}
                                                    ${exercise.detailedDescription}
                                                </div>
                                            ` : ''}
                                        </div>
                                        <div class="exercise-completed">
                                            <input type="checkbox" id="ex-${day.day}-${ex.exercise}">
                                            <label for="ex-${day.day}-${ex.exercise}">Fatto</label>
                                        </div>
                                    </div>
                                </div>
                            `;
                        }).join('')}
                    </div>
                </div>
            `;
        }).join('');

        container.innerHTML = html;

        // Add event listeners for detail toggles
        container.querySelectorAll('.exercise-details-toggle').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                const exerciseKey = btn.dataset.exercise;
                const detailsDiv = document.getElementById(`details-${exerciseKey}`);
                
                if (detailsDiv.style.display === 'none') {
                    detailsDiv.style.display = 'block';
                    btn.textContent = '📖 Nascondi spiegazione';
                } else {
                    detailsDiv.style.display = 'none';
                    btn.textContent = '📖 Vedi spiegazione dettagliata';
                }
            });
        });
    },

    // Export workout to PDF
    async exportWorkoutToPDF() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) {
            this.showNotification('Seleziona un profilo prima', 'error');
            return;
        }

        const level = document.getElementById('workoutLevel').value;
        const program = Workout.getProgram(level);
        
        // Show loading notification
        this.showNotification('Generazione PDF in corso...', 'info');

        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            
            let yPos = 20;
            const pageWidth = doc.internal.pageSize.getWidth();
            const pageHeight = doc.internal.pageSize.getHeight();
            const margin = 20;
            const maxWidth = pageWidth - 2 * margin;

            // Helper function to add new page if needed
            const checkPageBreak = (neededSpace) => {
                if (yPos + neededSpace > pageHeight - 20) {
                    doc.addPage();
                    yPos = 20;
                    return true;
                }
                return false;
            };

            // Helper function to wrap text
            const wrapText = (text, maxWidth) => {
                return doc.splitTextToSize(text, maxWidth);
            };

            // Title
            doc.setFontSize(22);
            doc.setTextColor(0, 105, 148); // Sea blue
            doc.text('SCHEDA ALLENAMENTO', pageWidth / 2, yPos, { align: 'center' });
            yPos += 10;

            // Profile info
            doc.setFontSize(12);
            doc.setTextColor(100, 100, 100);
            doc.text(`Profilo: ${profile.name}`, pageWidth / 2, yPos, { align: 'center' });
            yPos += 6;
            doc.text(`Livello: ${level === 'beginner' ? 'Principiante' : level === 'intermediate' ? 'Intermedio' : 'Avanzato'}`, pageWidth / 2, yPos, { align: 'center' });
            yPos += 6;
            doc.text(`Data: ${new Date().toLocaleDateString('it-IT')}`, pageWidth / 2, yPos, { align: 'center' });
            yPos += 15;

            // Program description
            doc.setFontSize(10);
            doc.setTextColor(80, 80, 80);
            const descLines = wrapText(program.description, maxWidth);
            descLines.forEach(line => {
                checkPageBreak(6);
                doc.text(line, margin, yPos);
                yPos += 6;
            });
            yPos += 5;

            // Iterate through each day
            for (const day of program.schedule) {
                checkPageBreak(15);

                // Day header
                doc.setFillColor(0, 105, 148);
                doc.rect(margin, yPos - 5, maxWidth, 10, 'F');
                doc.setTextColor(255, 255, 255);
                doc.setFontSize(14);
                doc.text(`${day.day} - ${day.type}`, margin + 3, yPos + 2);
                yPos += 12;

                // Exercises for this day
                for (const ex of day.exercises) {
                    const exercise = Workout.getExercise(ex.exercise);
                    
                    checkPageBreak(25);

                    // Exercise name
                    doc.setFontSize(12);
                    doc.setTextColor(0, 105, 148);
                    doc.text(`• ${exercise.name}`, margin + 2, yPos);
                    yPos += 6;

                    // Exercise details
                    doc.setFontSize(10);
                    doc.setTextColor(60, 60, 60);
                    const details = `${ex.sets} serie × ${ex.reps} ripetizioni` +
                        (ex.weight ? ` - ${ex.weight}` : '') +
                        (ex.resistance ? ` - Resistenza ${ex.resistance}` : '') +
                        (ex.rest !== undefined ? ` - Recupero: ${ex.rest}s` : exercise.restBetweenSets ? ` - Recupero: ${exercise.restBetweenSets}s` : '') +
                        (exercise.tempo ? ` - Tempo: ${exercise.tempo}` : '');
                    const detailLines = wrapText(details, maxWidth - 5);
                    detailLines.forEach(line => {
                        checkPageBreak(5);
                        doc.text(line, margin + 5, yPos);
                        yPos += 5;
                    });

                    // Short description
                    doc.setFontSize(9);
                    doc.setTextColor(100, 100, 100);
                    const descLine = wrapText(exercise.description, maxWidth - 5);
                    descLine.forEach(line => {
                        checkPageBreak(5);
                        doc.text(line, margin + 5, yPos);
                        yPos += 5;
                    });

                    // Detailed description if available
                    if (exercise.detailedDescription) {
                        yPos += 2;
                        doc.setFontSize(9);
                        doc.setTextColor(80, 80, 80);
                        
                        // Clean HTML tags and format the detailed description
                        const cleanText = exercise.detailedDescription
                            .replace(/<strong>/g, '')
                            .replace(/<\/strong>/g, ': ')
                            .replace(/•/g, '  •')
                            .replace(/✗/g, '  ✗')
                            .replace(/<[^>]*>/g, '\n')
                            .split('\n')
                            .filter(line => line.trim().length > 0);

                        for (const line of cleanText) {
                            const wrappedLines = wrapText(line.trim(), maxWidth - 5);
                            wrappedLines.forEach(wl => {
                                checkPageBreak(4);
                                doc.text(wl, margin + 5, yPos);
                                yPos += 4;
                            });
                        }
                    }

                    yPos += 5; // Space between exercises
                }

                yPos += 5; // Space between days
            }

            // Footer on last page
            doc.setFontSize(8);
            doc.setTextColor(150, 150, 150);
            doc.text('Generato da Dieta Mediterranea & Allenamento', pageWidth / 2, pageHeight - 10, { align: 'center' });

            // Save the PDF
            const fileName = `Scheda_Allenamento_${profile.name}_${level}_${new Date().toISOString().split('T')[0]}.pdf`;
            doc.save(fileName);

            this.showNotification('PDF generato con successo!', 'success');
        } catch (error) {
            console.error('Error generating PDF:', error);
            this.showNotification('Errore nella generazione del PDF', 'error');
        }
    },

    // Render profile page
    async renderProfile() {
        const profile = Profiles.getCurrentProfile();
        if (!profile) return;

        const nutrition = Nutrition.calculateProfileNutrition(profile);

        const html = `
            <div class="profile-detail-item">
                <span class="profile-detail-label">Nome</span>
                <span class="profile-detail-value">${profile.name}</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Età</span>
                <span class="profile-detail-value">${profile.age} anni</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Sesso</span>
                <span class="profile-detail-value">${profile.gender === 'male' ? 'Maschio' : 'Femmina'}</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Altezza</span>
                <span class="profile-detail-value">${profile.height} cm</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Peso</span>
                <span class="profile-detail-value">${profile.weight} kg</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">BMI</span>
                <span class="profile-detail-value">${profile.bmi} (${Profiles.getBMICategory(profile.bmi)})</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Attività Sportiva</span>
                <span class="profile-detail-value">${profile.hasActivity ? 'Sì' : 'No'}</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Metabolismo Basale</span>
                <span class="profile-detail-value">${nutrition.bmr} kcal/giorno</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">TDEE</span>
                <span class="profile-detail-value">${nutrition.tdee} kcal/giorno</span>
            </div>
            <div class="profile-detail-item">
                <span class="profile-detail-label">Creato il</span>
                <span class="profile-detail-value">${new Date(profile.createdAt).toLocaleDateString('it-IT')}</span>
            </div>
        `;

        document.getElementById('profileDetails').innerHTML = html;
    },

    // Edit current profile
    editCurrentProfile() {
        const profile = Profiles.getCurrentProfile();
        this.showProfileForm(profile);
    },

    // Delete current profile
    async deleteCurrentProfile() {
        if (!confirm('Sei sicuro di voler eliminare questo profilo? Tutti i dati associati saranno persi.')) {
            return;
        }

        const profile = Profiles.getCurrentProfile();
        
        try {
            await Profiles.deleteProfile(profile.id);
            this.showToast('Profilo eliminato', 'success');
            this.showScreen('profileScreen');
            await this.renderProfileList();
        } catch (error) {
            console.error('Error deleting profile:', error);
            this.showToast('Errore nell\'eliminazione del profilo', 'error');
        }
    },

    // Export data
    async exportData() {
        try {
            const data = await Storage.exportData();
            const json = JSON.stringify(data, null, 2);
            const blob = new Blob([json], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `dieta-mediterranea-backup-${Date.now()}.json`;
            a.click();
            
            this.showToast('Dati esportati con successo', 'success');
        } catch (error) {
            console.error('Error exporting data:', error);
            this.showToast('Errore nell\'esportazione dei dati', 'error');
        }
    },

    // Import data
    async importData(file) {
        if (!file) return;

        try {
            const text = await file.text();
            const data = JSON.parse(text);
            
            const success = await Storage.importData(data);
            
            if (success) {
                this.showToast('Dati importati con successo', 'success');
                // Reload app
                location.reload();
            } else {
                this.showToast('Errore nell\'importazione dei dati', 'error');
            }
        } catch (error) {
            console.error('Error importing data:', error);
            this.showToast('File non valido', 'error');
        }
    },

    // Show toast notification
    showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        
        container.appendChild(toast);
        
        setTimeout(() => {
            toast.remove();
        }, 4000);
    }
};

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => App.init());
} else {
    App.init();
}

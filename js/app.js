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
            summaryContainer.innerHTML = `
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
                            P: ${meal.totalNutrition.protein}g | 
                            C: ${meal.totalNutrition.carbs}g | 
                            G: ${meal.totalNutrition.fats}g
                        </div>
                    ` : ''}
                    <button class="btn btn-primary meal-add-btn" data-meal-type="${key}">
                        ${meal ? '✏️ Modifica Pasto' : '+ Aggiungi Alimenti'}
                    </button>
                </div>
            `;
        }));

        container.innerHTML = mealsHTML.join('');

        // Add click handlers to add buttons
        container.querySelectorAll('.meal-add-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const mealType = btn.dataset.mealType;
                this.showFoodSelector(mealType);
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
                        P: ${item.nutrition.protein}g | 
                        C: ${item.nutrition.carbs}g | 
                        G: ${item.nutrition.fats}g
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

        // Setup modal
        const searchInput = document.getElementById('foodSearch');
        const categorySelect = document.getElementById('foodCategory');
        const foodList = document.getElementById('foodList');

        // Populate categories
        const categories = FoodDatabase.getAllCategories();
        categorySelect.innerHTML = '<option value="">Tutte le categorie</option>' +
            categories.map(cat => `<option value="${cat.key}">${cat.name}</option>`).join('');

        // Render all foods initially
        this.renderFoodList(FoodDatabase.getAllFoods());

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

        // Close modal handler
        modal.querySelector('.modal-close').onclick = () => {
            modal.classList.remove('active');
        };

        // Close on background click
        modal.onclick = (e) => {
            if (e.target === modal) {
                modal.classList.remove('active');
            }
        };
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

        foodList.innerHTML = foods.map(food => `
            <div class="food-item" data-food="${food.name}">
                <div class="food-item-name">${food.name}</div>
                <div class="food-item-category">${FoodDatabase.getCategoryName(food.category)}</div>
                <div class="food-item-macros">
                    ${food.calories} kcal | P: ${food.protein}g | C: ${food.carbs}g | G: ${food.fats}g (per 100g)
                </div>
            </div>
        `).join('');

        // Add click handlers
        foodList.querySelectorAll('.food-item').forEach(item => {
            item.addEventListener('click', async () => {
                const foodName = item.dataset.food;
                await this.addFoodToMeal(foodName);
            });
        });
    },

    // Add food to meal with automatic portion calculation
    async addFoodToMeal(foodName) {
        const modal = document.getElementById('foodModal');
        const mealType = modal.dataset.mealType;
        const profile = Profiles.getCurrentProfile();

        try {
            const food = FoodDatabase.getFoodByName(foodName);
            if (!food) {
                this.showToast('Alimento non trovato', 'error');
                return;
            }

            // For now, just add the food - in a full implementation, 
            // we'd allow selecting multiple foods and then calculate optimal portions
            const nutrition = Nutrition.calculateProfileNutrition(profile);
            const mealMacros = Nutrition.getMealMacros(mealType, nutrition.macros);

            // Calculate portion for single food
            const portions = Nutrition.calculateOptimalPortions([food], mealMacros);

            await Meals.saveMeal(profile.id, Meals.formatDate(this.currentDay), mealType, portions);

            modal.classList.remove('active');
            this.showToast(`${foodName} aggiunto con porzione calcolata automaticamente: ${portions[0].grams}g`, 'success');
            await this.renderDayMeals();
        } catch (error) {
            console.error('Error adding food:', error);
            this.showToast('Errore nell\'aggiunta dell\'alimento', 'error');
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
            const shoppingList = await Meals.generateShoppingList(profile.id, startDate, endDate);
            this.renderShoppingList(shoppingList);
            document.getElementById('exportShoppingList').style.display = 'inline-block';
            this.showToast('Lista della spesa generata', 'success');
        } catch (error) {
            console.error('Error generating shopping list:', error);
            this.showToast('Errore nella generazione della lista', 'error');
        }
    },

    // Render shopping list
    renderShoppingList(shoppingList) {
        const container = document.getElementById('shoppingList');

        if (Object.keys(shoppingList).length === 0) {
            container.innerHTML = '<p style="text-align: center; color: #999;">Nessun alimento nella lista</p>';
            return;
        }

        const html = Object.keys(shoppingList).map(categoryKey => {
            const categoryName = FoodDatabase.getCategoryName(categoryKey);
            const items = shoppingList[categoryKey];

            return `
                <div class="shopping-category">
                    <h3>${categoryName}</h3>
                    <div class="shopping-items">
                        ${items.map(item => `
                            <div class="shopping-item">
                                <input type="checkbox" id="shop-${categoryKey}-${item.name}">
                                <label for="shop-${categoryKey}-${item.name}">
                                    ${item.name} - ${item.grams}g
                                </label>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        }).join('');

        container.innerHTML = html;

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
        const shoppingList = await Meals.generateShoppingList(profile.id, weekDates[0], weekDates[6]);
        
        const text = Meals.exportShoppingListToText(shoppingList);
        
        const blob = new Blob([text], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `lista-spesa-${Meals.formatDate(new Date())}.txt`;
        a.click();
        
        this.showToast('Lista esportata', 'success');
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
                            return `
                                <div class="exercise-item">
                                    <div class="exercise-header">
                                        <div>
                                            <div class="exercise-name">${exercise.name}</div>
                                            <div class="exercise-details">
                                                ${ex.sets} serie × ${ex.reps} ripetizioni
                                                ${ex.weight ? ` - ${ex.weight}` : ''}
                                                ${ex.resistance ? ` - Resistenza ${ex.resistance}` : ''}
                                                ${ex.rest ? ` - Recupero: ${ex.rest}s` : ''}
                                            </div>
                                            <div class="exercise-details" style="margin-top: 0.25rem;">
                                                <small>${exercise.description}</small>
                                            </div>
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

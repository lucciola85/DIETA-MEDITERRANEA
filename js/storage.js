/**
 * Storage Module - Handles LocalStorage and IndexedDB operations
 */

const Storage = {
    // LocalStorage keys
    KEYS: {
        CURRENT_PROFILE: 'currentProfile',
        PROFILES: 'profiles',
        SETTINGS: 'settings'
    },

    // Initialize storage
    init() {
        // Check if localStorage is available
        if (!this.isLocalStorageAvailable()) {
            console.error('LocalStorage is not available');
            return false;
        }

        // Initialize IndexedDB
        this.initIndexedDB();
        return true;
    },

    // Check LocalStorage availability
    isLocalStorageAvailable() {
        try {
            const test = '__storage_test__';
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            return true;
        } catch (e) {
            return false;
        }
    },

    // Initialize IndexedDB
    initIndexedDB() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open('DietaMediterraneaDB', 1);

            request.onerror = () => {
                console.error('IndexedDB error:', request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                this.db = request.result;
                resolve(this.db);
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;

                // Create object stores
                if (!db.objectStoreNames.contains('profiles')) {
                    const profileStore = db.createObjectStore('profiles', { keyPath: 'id' });
                    profileStore.createIndex('name', 'name', { unique: false });
                }

                if (!db.objectStoreNames.contains('meals')) {
                    const mealStore = db.createObjectStore('meals', { keyPath: 'id' });
                    mealStore.createIndex('profileId', 'profileId', { unique: false });
                    mealStore.createIndex('date', 'date', { unique: false });
                }

                if (!db.objectStoreNames.contains('weights')) {
                    const weightStore = db.createObjectStore('weights', { keyPath: 'id' });
                    weightStore.createIndex('profileId', 'profileId', { unique: false });
                    weightStore.createIndex('date', 'date', { unique: false });
                }

                if (!db.objectStoreNames.contains('workouts')) {
                    const workoutStore = db.createObjectStore('workouts', { keyPath: 'id' });
                    workoutStore.createIndex('profileId', 'profileId', { unique: false });
                    workoutStore.createIndex('date', 'date', { unique: false });
                }
            };
        });
    },

    // LocalStorage operations
    set(key, value) {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (e) {
            console.error('Error saving to localStorage:', e);
            return false;
        }
    },

    get(key) {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : null;
        } catch (e) {
            console.error('Error reading from localStorage:', e);
            return null;
        }
    },

    remove(key) {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (e) {
            console.error('Error removing from localStorage:', e);
            return false;
        }
    },

    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (e) {
            console.error('Error clearing localStorage:', e);
            return false;
        }
    },

    // IndexedDB operations
    async addToStore(storeName, data) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.add(data);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async updateInStore(storeName, data) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.put(data);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async getFromStore(storeName, key) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.get(key);

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async getAllFromStore(storeName, indexName, indexValue) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            let request;

            if (indexName && indexValue !== undefined) {
                const index = store.index(indexName);
                request = index.getAll(indexValue);
            } else {
                request = store.getAll();
            }

            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async deleteFromStore(storeName, key) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.delete(key);

            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    },

    async clearStore(storeName) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.clear();

            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    },

    // Export all data as JSON
    async exportData() {
        try {
            const data = {
                version: '1.0',
                exportDate: new Date().toISOString(),
                profiles: await this.getAllFromStore('profiles'),
                meals: await this.getAllFromStore('meals'),
                weights: await this.getAllFromStore('weights'),
                workouts: await this.getAllFromStore('workouts'),
                settings: this.get(this.KEYS.SETTINGS) || {},
                currentProfile: this.get(this.KEYS.CURRENT_PROFILE)
            };
            return data;
        } catch (e) {
            console.error('Error exporting data:', e);
            return null;
        }
    },

    // Import data from JSON
    async importData(data) {
        try {
            // Validate data structure
            if (!data.version || !data.profiles) {
                throw new Error('Invalid data format');
            }

            // Clear existing data
            await this.clearStore('profiles');
            await this.clearStore('meals');
            await this.clearStore('weights');
            await this.clearStore('workouts');

            // Import profiles
            for (const profile of data.profiles) {
                await this.addToStore('profiles', profile);
            }

            // Import meals
            if (data.meals) {
                for (const meal of data.meals) {
                    await this.addToStore('meals', meal);
                }
            }

            // Import weights
            if (data.weights) {
                for (const weight of data.weights) {
                    await this.addToStore('weights', weight);
                }
            }

            // Import workouts
            if (data.workouts) {
                for (const workout of data.workouts) {
                    await this.addToStore('workouts', workout);
                }
            }

            // Import settings
            if (data.settings) {
                this.set(this.KEYS.SETTINGS, data.settings);
            }

            // Set current profile
            if (data.currentProfile) {
                this.set(this.KEYS.CURRENT_PROFILE, data.currentProfile);
            }

            return true;
        } catch (e) {
            console.error('Error importing data:', e);
            return false;
        }
    },

    // Generate unique ID
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substring(2);
    }
};

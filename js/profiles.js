/**
 * Profiles Module - Multi-profile management
 */

const Profiles = {
    currentProfile: null,

    // Initialize profiles
    async init() {
        await Storage.initIndexedDB();
        const currentProfileId = Storage.get(Storage.KEYS.CURRENT_PROFILE);
        if (currentProfileId) {
            this.currentProfile = await Storage.getFromStore('profiles', currentProfileId);
        }
    },

    // Create new profile
    async createProfile(data) {
        const profile = {
            id: Storage.generateId(),
            name: data.name,
            age: parseInt(data.age),
            gender: data.gender,
            height: parseFloat(data.height),
            weight: parseFloat(data.weight),
            hasActivity: data.hasActivity === 'yes',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        // Calculate BMI
        profile.bmi = this.calculateBMI(profile.height, profile.weight);

        // Save profile
        await Storage.addToStore('profiles', profile);

        // Create initial weight entry
        await this.addWeightEntry(profile.id, profile.weight, new Date().toISOString());

        return profile;
    },

    // Update profile
    async updateProfile(profileId, data) {
        const profile = await Storage.getFromStore('profiles', profileId);
        if (!profile) {
            throw new Error('Profile not found');
        }

        // Update fields
        if (data.name) profile.name = data.name;
        if (data.age) profile.age = parseInt(data.age);
        if (data.gender) profile.gender = data.gender;
        if (data.height) profile.height = parseFloat(data.height);
        if (data.weight) profile.weight = parseFloat(data.weight);
        if (data.hasActivity !== undefined) profile.hasActivity = data.hasActivity === 'yes';

        // Recalculate BMI if height or weight changed
        if (data.height || data.weight) {
            profile.bmi = this.calculateBMI(profile.height, profile.weight);
        }

        profile.updatedAt = new Date().toISOString();

        await Storage.updateInStore('profiles', profile);

        // If current profile was updated, refresh it
        if (this.currentProfile && this.currentProfile.id === profileId) {
            this.currentProfile = profile;
        }

        return profile;
    },

    // Delete profile
    async deleteProfile(profileId) {
        // Delete profile
        await Storage.deleteFromStore('profiles', profileId);

        // Delete associated data
        const meals = await Storage.getAllFromStore('meals', 'profileId', profileId);
        for (const meal of meals) {
            await Storage.deleteFromStore('meals', meal.id);
        }

        const weights = await Storage.getAllFromStore('weights', 'profileId', profileId);
        for (const weight of weights) {
            await Storage.deleteFromStore('weights', weight.id);
        }

        const workouts = await Storage.getAllFromStore('workouts', 'profileId', profileId);
        for (const workout of workouts) {
            await Storage.deleteFromStore('workouts', workout.id);
        }

        // Clear current profile if it was deleted
        if (this.currentProfile && this.currentProfile.id === profileId) {
            this.currentProfile = null;
            Storage.remove(Storage.KEYS.CURRENT_PROFILE);
        }
    },

    // Get all profiles
    async getAllProfiles() {
        return await Storage.getAllFromStore('profiles');
    },

    // Set current profile
    async setCurrentProfile(profileId) {
        const profile = await Storage.getFromStore('profiles', profileId);
        if (!profile) {
            throw new Error('Profile not found');
        }

        this.currentProfile = profile;
        Storage.set(Storage.KEYS.CURRENT_PROFILE, profileId);
        return profile;
    },

    // Get current profile
    getCurrentProfile() {
        return this.currentProfile;
    },

    // Calculate BMI
    calculateBMI(height, weight) {
        // BMI = weight(kg) / (height(m))^2
        const heightInMeters = height / 100;
        const bmi = weight / (heightInMeters * heightInMeters);
        return parseFloat(bmi.toFixed(1));
    },

    // Get BMI category
    getBMICategory(bmi) {
        if (bmi < 18.5) return 'Sottopeso';
        if (bmi < 25) return 'Normale';
        if (bmi < 30) return 'Sovrappeso';
        return 'Obeso';
    },

    // Add weight entry
    async addWeightEntry(profileId, weight, date) {
        const weightEntry = {
            id: Storage.generateId(),
            profileId: profileId,
            weight: parseFloat(weight),
            date: date || new Date().toISOString(),
            createdAt: new Date().toISOString()
        };

        await Storage.addToStore('weights', weightEntry);

        // Update profile weight if this is the latest entry
        const profile = await Storage.getFromStore('profiles', profileId);
        if (profile) {
            const allWeights = await this.getWeightHistory(profileId);
            const latestWeight = allWeights[allWeights.length - 1];
            if (latestWeight && latestWeight.id === weightEntry.id) {
                profile.weight = weight;
                profile.bmi = this.calculateBMI(profile.height, weight);
                await Storage.updateInStore('profiles', profile);
                
                if (this.currentProfile && this.currentProfile.id === profileId) {
                    this.currentProfile = profile;
                }
            }
        }

        return weightEntry;
    },

    // Get weight history
    async getWeightHistory(profileId) {
        const weights = await Storage.getAllFromStore('weights', 'profileId', profileId);
        // Sort by date
        return weights.sort((a, b) => new Date(a.date) - new Date(b.date));
    },

    // Get weight stats
    async getWeightStats(profileId) {
        const weights = await this.getWeightHistory(profileId);
        
        if (weights.length === 0) {
            return {
                initial: 0,
                current: 0,
                change: 0,
                weeklyAverage: 0
            };
        }

        const initial = weights[0].weight;
        const current = weights[weights.length - 1].weight;
        const change = current - initial;

        // Calculate weekly average (if more than 1 week of data)
        const firstDate = new Date(weights[0].date);
        const lastDate = new Date(weights[weights.length - 1].date);
        const weeks = (lastDate - firstDate) / (1000 * 60 * 60 * 24 * 7);
        const weeklyAverage = weeks > 0 ? change / weeks : 0;

        return {
            initial,
            current,
            change,
            weeklyAverage
        };
    }
};

/**
 * Workout Module - Training program management with Panca Piana
 */

const Workout = {
    // Equipment available
    equipment: {
        dumbbells: {
            name: 'Manubri',
            weights: ['0.5 kg', '1 kg', '2 kg']
        },
        treadmill: {
            name: 'Tapis Roulant'
        },
        elastics: {
            name: 'Elastici',
            resistances: ['Leggera', 'Media', 'Forte']
        },
        bench: {
            name: 'Panca Piana'
        },
        bodyweight: {
            name: 'Corpo Libero'
        }
    },

    // Exercise database
    exercises: {
        // Dumbbell exercises
        bicepCurls: {
            name: 'Curl Bicipiti con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Braccia',
            description: 'In piedi o seduti, fletti i gomiti portando i manubri verso le spalle'
        },
        tricepExtension: {
            name: 'Estensioni Tricipiti',
            equipment: 'dumbbells',
            muscleGroup: 'Braccia',
            description: 'Distendi le braccia sopra la testa alternando o insieme'
        },
        shoulderPress: {
            name: 'Spalle con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Spalle',
            description: 'Solleva i manubri sopra la testa partendo dalle spalle'
        },
        lateralRaises: {
            name: 'Alzate Laterali',
            equipment: 'dumbbells',
            muscleGroup: 'Spalle',
            description: 'Solleva i manubri lateralmente fino all\'altezza delle spalle'
        },
        chestPress: {
            name: 'Chest Press con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Petto',
            description: 'Sdraiati sulla panca, spingi i manubri verso l\'alto'
        },
        chestFly: {
            name: 'Aperture con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Petto',
            description: 'Sdraiati sulla panca, apri le braccia lateralmente con gomiti leggermente flessi'
        },
        bentOverRow: {
            name: 'Rematore con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Schiena',
            description: 'Piegato in avanti, tira i manubri verso il torace'
        },
        dumbbellSquat: {
            name: 'Squat con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Gambe',
            description: 'Manubri ai lati, esegui uno squat completo'
        },
        dumbbellLunges: {
            name: 'Affondi con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Gambe',
            description: 'Manubri ai lati, esegui affondi alternati'
        },

        // Bench exercises (Panca Piana)
        benchPress: {
            name: 'Distensioni su Panca con Manubri',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Sdraiati sulla panca piana, spingi i manubri verso l\'alto'
        },
        benchFly: {
            name: 'Croci su Panca',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Sulla panca piana, apri le braccia con manubri'
        },
        inclineBenchPress: {
            name: 'Distensioni su Panca (variante)',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Distensioni con manubri sulla panca'
        },

        // Treadmill exercises
        treadmillWalk: {
            name: 'Camminata Veloce',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Camminata a passo sostenuto'
        },
        treadmillJog: {
            name: 'Corsa Leggera',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Corsa a ritmo moderato'
        },
        treadmillHIIT: {
            name: 'HIIT Tapis Roulant',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Alternanza di scatti e recupero attivo'
        },
        treadmillIncline: {
            name: 'Camminata in Salita',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Camminata con inclinazione'
        },

        // Elastic band exercises
        elasticChestPress: {
            name: 'Spinte Petto con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Petto',
            description: 'Elastico dietro la schiena, spingi in avanti'
        },
        elasticRow: {
            name: 'Rematore con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Schiena',
            description: 'Tira l\'elastico verso il corpo'
        },
        elasticSquat: {
            name: 'Squat con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Gambe',
            description: 'Squat con resistenza elastico'
        },
        elasticBiceps: {
            name: 'Curl Bicipiti con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Braccia',
            description: 'Piedi sull\'elastico, curl verso le spalle'
        },
        elasticTriceps: {
            name: 'Estensioni Tricipiti con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Braccia',
            description: 'Estensioni sopra la testa con elastico'
        },
        elasticLateralRaise: {
            name: 'Alzate Laterali con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Spalle',
            description: 'Piedi sull\'elastico, alzate laterali'
        },

        // Bodyweight exercises
        pushUps: {
            name: 'Flessioni',
            equipment: 'bodyweight',
            muscleGroup: 'Petto',
            description: 'Flessioni classiche a terra'
        },
        squats: {
            name: 'Squat',
            equipment: 'bodyweight',
            muscleGroup: 'Gambe',
            description: 'Squat a corpo libero'
        },
        lunges: {
            name: 'Affondi',
            equipment: 'bodyweight',
            muscleGroup: 'Gambe',
            description: 'Affondi alternati senza peso'
        },
        plank: {
            name: 'Plank',
            equipment: 'bodyweight',
            muscleGroup: 'Core',
            description: 'Posizione plank tenuta'
        },
        crunches: {
            name: 'Crunch',
            equipment: 'bodyweight',
            muscleGroup: 'Addominali',
            description: 'Crunch addominali classici'
        },
        mountainClimbers: {
            name: 'Mountain Climbers',
            equipment: 'bodyweight',
            muscleGroup: 'Full Body',
            description: 'Posizione plank, porta le ginocchia al petto alternando'
        },
        burpees: {
            name: 'Burpees',
            equipment: 'bodyweight',
            muscleGroup: 'Full Body',
            description: 'Sequenza completa: squat, plank, push-up, salto'
        },
        jumpingJacks: {
            name: 'Jumping Jacks',
            equipment: 'bodyweight',
            muscleGroup: 'Cardio',
            description: 'Salti con apertura gambe e braccia'
        },
        highKnees: {
            name: 'High Knees',
            equipment: 'bodyweight',
            muscleGroup: 'Cardio',
            description: 'Corsa sul posto portando le ginocchia in alto'
        },
        legRaises: {
            name: 'Sollevamenti Gambe',
            equipment: 'bodyweight',
            muscleGroup: 'Addominali',
            description: 'Sdraiati, solleva le gambe verso l\'alto'
        },
        gluteBridge: {
            name: 'Ponte Glutei',
            equipment: 'bodyweight',
            muscleGroup: 'Glutei',
            description: 'Sdraiati, solleva il bacino'
        }
    },

    // Workout programs by level
    programs: {
        beginner: {
            name: 'Principiante',
            description: 'Per chi non pratica attività sportiva',
            weeksBeforeProgression: 4,
            schedule: [
                {
                    day: 'Lunedì',
                    type: 'Full Body + Cardio Leggero',
                    exercises: [
                        { exercise: 'treadmillWalk', sets: 1, reps: '15 min', rest: 0 },
                        { exercise: 'squats', sets: 2, reps: 12, rest: 60 },
                        { exercise: 'pushUps', sets: 2, reps: '8-10', rest: 60 },
                        { exercise: 'plank', sets: 2, reps: '20 sec', rest: 45 },
                        { exercise: 'bicepCurls', sets: 2, reps: 12, weight: '0.5-1 kg', rest: 45 }
                    ]
                },
                {
                    day: 'Mercoledì',
                    type: 'Cardio + Core',
                    exercises: [
                        { exercise: 'treadmillWalk', sets: 1, reps: '20 min', rest: 0 },
                        { exercise: 'crunches', sets: 2, reps: 15, rest: 45 },
                        { exercise: 'legRaises', sets: 2, reps: 10, rest: 45 },
                        { exercise: 'gluteBridge', sets: 2, reps: 12, rest: 45 },
                        { exercise: 'jumpingJacks', sets: 2, reps: 30, rest: 60 }
                    ]
                },
                {
                    day: 'Venerdì',
                    type: 'Total Body con Elastici',
                    exercises: [
                        { exercise: 'elasticSquat', sets: 2, reps: 12, resistance: 'Leggera', rest: 60 },
                        { exercise: 'elasticChestPress', sets: 2, reps: 12, resistance: 'Leggera', rest: 60 },
                        { exercise: 'elasticRow', sets: 2, reps: 12, resistance: 'Leggera', rest: 60 },
                        { exercise: 'elasticBiceps', sets: 2, reps: 12, resistance: 'Leggera', rest: 45 },
                        { exercise: 'treadmillWalk', sets: 1, reps: '10 min', rest: 0 }
                    ]
                }
            ]
        },
        intermediate: {
            name: 'Intermedio',
            description: 'Per chi ha già una base di allenamento',
            weeksBeforeProgression: 6,
            schedule: [
                {
                    day: 'Lunedì',
                    type: 'Upper Body',
                    exercises: [
                        { exercise: 'benchPress', sets: 3, reps: 12, weight: '1-2 kg', rest: 60 },
                        { exercise: 'bentOverRow', sets: 3, reps: 12, weight: '1-2 kg', rest: 60 },
                        { exercise: 'shoulderPress', sets: 3, reps: 10, weight: '1 kg', rest: 60 },
                        { exercise: 'bicepCurls', sets: 3, reps: 12, weight: '1-2 kg', rest: 45 },
                        { exercise: 'tricepExtension', sets: 3, reps: 12, weight: '1 kg', rest: 45 }
                    ]
                },
                {
                    day: 'Martedì',
                    type: 'Cardio HIIT',
                    exercises: [
                        { exercise: 'treadmillHIIT', sets: 8, reps: '30 sec sprint / 60 sec recupero', rest: 0 },
                        { exercise: 'burpees', sets: 3, reps: 10, rest: 90 },
                        { exercise: 'mountainClimbers', sets: 3, reps: 20, rest: 60 }
                    ]
                },
                {
                    day: 'Giovedì',
                    type: 'Lower Body',
                    exercises: [
                        { exercise: 'dumbbellSquat', sets: 3, reps: 15, weight: '2 kg', rest: 90 },
                        { exercise: 'dumbbellLunges', sets: 3, reps: '12 per gamba', weight: '1-2 kg', rest: 60 },
                        { exercise: 'gluteBridge', sets: 3, reps: 15, rest: 60 },
                        { exercise: 'elasticSquat', sets: 3, reps: 15, resistance: 'Media', rest: 60 }
                    ]
                },
                {
                    day: 'Venerdì',
                    type: 'Petto + Schiena con Panca',
                    exercises: [
                        { exercise: 'benchPress', sets: 3, reps: 12, weight: '1-2 kg', rest: 60 },
                        { exercise: 'benchFly', sets: 3, reps: 12, weight: '1 kg', rest: 60 },
                        { exercise: 'bentOverRow', sets: 3, reps: 12, weight: '2 kg', rest: 60 },
                        { exercise: 'elasticRow', sets: 3, reps: 15, resistance: 'Media', rest: 45 }
                    ]
                },
                {
                    day: 'Sabato',
                    type: 'Core + Cardio',
                    exercises: [
                        { exercise: 'treadmillJog', sets: 1, reps: '25 min', rest: 0 },
                        { exercise: 'plank', sets: 3, reps: '45 sec', rest: 45 },
                        { exercise: 'crunches', sets: 3, reps: 20, rest: 45 },
                        { exercise: 'legRaises', sets: 3, reps: 15, rest: 45 }
                    ]
                }
            ]
        },
        advanced: {
            name: 'Avanzato',
            description: 'Per atleti esperti',
            weeksBeforeProgression: 8,
            schedule: [
                {
                    day: 'Lunedì',
                    type: 'Petto + Tricipiti',
                    exercises: [
                        { exercise: 'benchPress', sets: 4, reps: 12, weight: '2 kg', rest: 60 },
                        { exercise: 'benchFly', sets: 4, reps: 12, weight: '1-2 kg', rest: 60 },
                        { exercise: 'pushUps', sets: 3, reps: 20, rest: 60 },
                        { exercise: 'tricepExtension', sets: 4, reps: 15, weight: '1-2 kg', rest: 45 },
                        { exercise: 'elasticChestPress', sets: 3, reps: 15, resistance: 'Forte', rest: 45 }
                    ]
                },
                {
                    day: 'Martedì',
                    type: 'HIIT Intenso',
                    exercises: [
                        { exercise: 'treadmillHIIT', sets: 10, reps: '45 sec sprint / 45 sec recupero', rest: 0 },
                        { exercise: 'burpees', sets: 4, reps: 15, rest: 60 },
                        { exercise: 'mountainClimbers', sets: 4, reps: 30, rest: 60 },
                        { exercise: 'highKnees', sets: 4, reps: '45 sec', rest: 60 }
                    ]
                },
                {
                    day: 'Mercoledì',
                    type: 'Schiena + Bicipiti',
                    exercises: [
                        { exercise: 'bentOverRow', sets: 4, reps: 15, weight: '2 kg', rest: 60 },
                        { exercise: 'elasticRow', sets: 4, reps: 15, resistance: 'Forte', rest: 60 },
                        { exercise: 'bicepCurls', sets: 4, reps: 15, weight: '2 kg', rest: 45 },
                        { exercise: 'elasticBiceps', sets: 3, reps: 15, resistance: 'Media', rest: 45 }
                    ]
                },
                {
                    day: 'Giovedì',
                    type: 'Gambe + Glutei',
                    exercises: [
                        { exercise: 'dumbbellSquat', sets: 4, reps: 20, weight: '2 kg', rest: 90 },
                        { exercise: 'dumbbellLunges', sets: 4, reps: '15 per gamba', weight: '2 kg', rest: 75 },
                        { exercise: 'gluteBridge', sets: 4, reps: 20, rest: 60 },
                        { exercise: 'elasticSquat', sets: 3, reps: 20, resistance: 'Forte', rest: 60 }
                    ]
                },
                {
                    day: 'Venerdì',
                    type: 'Spalle + Core',
                    exercises: [
                        { exercise: 'shoulderPress', sets: 4, reps: 15, weight: '1-2 kg', rest: 60 },
                        { exercise: 'lateralRaises', sets: 4, reps: 15, weight: '1 kg', rest: 45 },
                        { exercise: 'plank', sets: 4, reps: '60 sec', rest: 45 },
                        { exercise: 'crunches', sets: 4, reps: 25, rest: 45 },
                        { exercise: 'legRaises', sets: 4, reps: 20, rest: 45 }
                    ]
                },
                {
                    day: 'Sabato',
                    type: 'Cardio Lungo + Full Body',
                    exercises: [
                        { exercise: 'treadmillJog', sets: 1, reps: '35 min', rest: 0 },
                        { exercise: 'burpees', sets: 3, reps: 15, rest: 90 },
                        { exercise: 'jumpingJacks', sets: 3, reps: 50, rest: 60 }
                    ]
                }
            ]
        }
    },

    // Get program by level
    getProgram(level) {
        return this.programs[level] || this.programs.beginner;
    },

    // Get exercise details
    getExercise(exerciseKey) {
        return this.exercises[exerciseKey];
    },

    // Save workout completion
    async saveWorkoutCompletion(profileId, date, day, exercises) {
        const workout = {
            id: Storage.generateId(),
            profileId: profileId,
            date: date,
            day: day,
            exercises: exercises,
            completedAt: new Date().toISOString()
        };

        await Storage.addToStore('workouts', workout);
        return workout;
    },

    // Get workouts for date range
    async getWorkouts(profileId, startDate, endDate) {
        const allWorkouts = await Storage.getAllFromStore('workouts', 'profileId', profileId);
        const start = new Date(startDate);
        const end = new Date(endDate);
        
        return allWorkouts.filter(workout => {
            const workoutDate = new Date(workout.date);
            return workoutDate >= start && workoutDate <= end;
        });
    },

    // Check if workout is completed for a date
    async isWorkoutCompleted(profileId, date, dayName) {
        const workouts = await this.getWorkouts(profileId, date, date);
        return workouts.some(w => w.day === dayName);
    },

    // Get workout level based on profile
    getRecommendedLevel(profile) {
        if (!profile.hasActivity) {
            return 'beginner';
        }
        // Default to intermediate for users who have activity
        return 'intermediate';
    }
};

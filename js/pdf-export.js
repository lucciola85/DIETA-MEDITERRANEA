/**
 * PDF Export Module - Generate PDFs for Shopping List and Weekly Menu
 */

const PDFExport = {
    /**
     * Clean text for PDF export - removes emojis and problematic characters
     * @param {string} text - Text to clean
     * @returns {string} Cleaned text safe for PDF
     */
    cleanTextForPDF(text) {
        if (!text) return '';
        
        let cleaned = text.toString();
        
        // Map emoji to text equivalents
        const emojiMap = {
            '🛒': '[Carrello]',
            '🍽️': '[Piatto]',
            '🏋️': '[Allenamento]',
            '📊': '[Grafico]',
            '📋': '[Lista]',
            '✅': '[OK]',
            '⚠️': '[!]',
            '❌': '[X]',
            '🥬': '',
            '🥩': '',
            '🐟': '',
            '🌾': '',
            '🫒': '',
            '🍞': '',
            '☐': '[ ]',
            '→': '->',
            '•': '-',
            '═': '=',
            '─': '-',
            '📄': '',
            '💪': '',
            '👁️': '',
            '🗑️': '',
            '✏️': ''
        };
        
        // Remove emoji
        Object.keys(emojiMap).forEach(emoji => {
            cleaned = cleaned.split(emoji).join(emojiMap[emoji]);
        });
        
        // Remove any remaining emoji
        cleaned = cleaned.replace(/[\u{1F300}-\u{1F9FF}]/gu, '');
        
        return cleaned;
    },
    /**
     * Generate Shopping List PDF
     * @param {Object} shoppingListData - Shopping list data with items and summary
     * @param {string} weekRange - Week range string (e.g., "09-15 Dicembre 2025")
     */
    generateShoppingListPDF(shoppingListData, weekRange) {
        const { jsPDF } = window.jspdf;
        if (!jsPDF) {
            throw new Error('jsPDF library not loaded');
        }

        const doc = new jsPDF();
        let yPos = 20;
        const pageWidth = doc.internal.pageSize.getWidth();
        const margin = 20;
        const maxWidth = pageWidth - 2 * margin;

        // Title
        doc.setFontSize(20);
        doc.setTextColor(0, 105, 148);
        doc.text(this.cleanTextForPDF('LISTA DELLA SPESA'), margin, yPos);
        yPos += 10;

        // Week range
        doc.setFontSize(12);
        doc.setTextColor(100, 100, 100);
        doc.text(this.cleanTextForPDF(`Settimana: ${weekRange}`), margin, yPos);
        yPos += 8;

        // Summary
        doc.setFontSize(10);
        doc.setTextColor(80, 80, 80);
        doc.text(`Generata da: ${shoppingListData.summary.totalMeals} pasti in ${shoppingListData.summary.totalDays} giorni`, margin, yPos);
        yPos += 10;

        // Date
        doc.setFontSize(9);
        doc.setTextColor(150, 150, 150);
        doc.text(`Data generazione: ${new Date().toLocaleDateString('it-IT')}`, margin, yPos);
        yPos += 15;

        // Categories and items
        Object.keys(shoppingListData.items).forEach(categoryKey => {
            const categoryName = FoodDatabase.getCategoryName(categoryKey);
            const items = shoppingListData.items[categoryKey];

            // Category header
            doc.setFontSize(14);
            doc.setTextColor(0, 105, 148);
            doc.text(this.cleanTextForPDF(categoryName.toUpperCase()), margin, yPos);
            yPos += 8;

            // Items
            doc.setFontSize(10);
            doc.setTextColor(60, 60, 60);
            
            items.forEach(item => {
                // Check if we need a new page
                if (yPos > 270) {
                    doc.addPage();
                    yPos = 20;
                }

                // Checkbox
                doc.setDrawColor(100, 100, 100);
                doc.rect(margin, yPos - 3, 3, 3);
                
                // Item name with dots
                const itemText = this.cleanTextForPDF(`${item.name}`);
                const dotsWidth = maxWidth - 35;
                const textWidth = doc.getTextWidth(itemText);
                const gramsText = `${item.grams}g`;
                const gramsWidth = doc.getTextWidth(gramsText);
                const dotsNeeded = Math.floor((dotsWidth - textWidth - gramsWidth) / doc.getTextWidth('.'));
                const dots = '.'.repeat(Math.max(0, dotsNeeded));
                
                doc.text(itemText, margin + 6, yPos);
                doc.setTextColor(150, 150, 150);
                doc.text(dots, margin + 6 + textWidth + 2, yPos);
                doc.setTextColor(60, 60, 60);
                doc.text(gramsText, pageWidth - margin - gramsWidth, yPos);
                
                yPos += 6;
            });

            yPos += 6; // Space between categories
        });

        // Footer
        doc.setFontSize(8);
        doc.setTextColor(150, 150, 150);
        const footerY = doc.internal.pageSize.getHeight() - 10;
        doc.text('Generato da Dieta Mediterranea & Allenamento', pageWidth / 2, footerY, { align: 'center' });

        // Save PDF
        const fileName = `Lista_Spesa_${this.formatDateForFilename(new Date())}.pdf`;
        doc.save(fileName);
    },

    /**
     * Generate Weekly Menu PDF
     * @param {Array} weekDates - Array of Date objects for the week
     */
    async generateWeeklyMenuPDF(weekDates) {
        const { jsPDF } = window.jspdf;
        if (!jsPDF) {
            throw new Error('jsPDF library not loaded');
        }

        // Get profile
        const profile = Profiles.getCurrentProfile();
        if (!profile) {
            throw new Error('No profile selected');
        }
        const profileId = profile.id;

        // Get nutrition data
        const nutrition = Nutrition.calculateProfileNutrition(profile);

        const doc = new jsPDF();
        let yPos = 20;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        const margin = 20;
        const maxWidth = pageWidth - 2 * margin;

        // Helper function to check page break
        const checkPageBreak = (neededSpace) => {
            if (yPos + neededSpace > pageHeight - 20) {
                doc.addPage();
                yPos = 20;
                return true;
            }
            return false;
        };

        // Title
        doc.setFontSize(20);
        doc.setTextColor(0, 105, 148);
        doc.text(this.cleanTextForPDF('MENU SETTIMANALE'), pageWidth / 2, yPos, { align: 'center' });
        yPos += 10;

        // Profile info
        doc.setFontSize(12);
        doc.setTextColor(100, 100, 100);
        doc.text(this.cleanTextForPDF(`Profilo: ${profile.name}`), pageWidth / 2, yPos, { align: 'center' });
        yPos += 6;
        doc.text(`Target giornaliero: ${nutrition.targetCalories} kcal`, pageWidth / 2, yPos, { align: 'center' });
        yPos += 6;

        // Week range
        const weekStart = weekDates[0];
        const weekEnd = weekDates[6];
        const weekRange = `${weekStart.toLocaleDateString('it-IT', { day: '2-digit', month: 'short' })} - ${weekEnd.toLocaleDateString('it-IT', { day: '2-digit', month: 'short', year: 'numeric' })}`;
        doc.text(this.cleanTextForPDF(`Settimana: ${weekRange}`), pageWidth / 2, yPos, { align: 'center' });
        yPos += 15;

        // Fetch all meals for the week first
        const allWeekMeals = await Promise.all(
            weekDates.map(date => Meals.getMealsByDate(profileId, date))
        );
        
        // Check if any meals were found
        const totalMealsInWeek = allWeekMeals.flat().length;

        if (totalMealsInWeek === 0) {
            // No meals found
            doc.setFontSize(12);
            doc.setTextColor(150, 150, 150);
            doc.text('Nessun pasto pianificato per questa settimana', pageWidth / 2, 100, { align: 'center' });
            doc.setFontSize(10);
            doc.text('Vai al Pianificatore Pasti per compilare i tuoi pasti', pageWidth / 2, 110, { align: 'center' });
        } else {
            // Process each day
            for (let i = 0; i < weekDates.length; i++) {
                const date = weekDates[i];
                const meals = allWeekMeals[i];
                
                // Skip if no meals for this day
                if (meals.length === 0) {
                    continue;
                }

                const dayName = Meals.getDayName(date);
                const dateStr = date.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit' });

                checkPageBreak(20);

                // Day header
                doc.setFontSize(14);
                doc.setTextColor(0, 105, 148);
                const dayHeader = this.cleanTextForPDF(`====== ${dayName.toUpperCase()} ${dateStr} ======`);
                doc.text(dayHeader, pageWidth / 2, yPos, { align: 'center' });
                yPos += 10;

                // Process each meal
                for (const meal of meals) {
                    checkPageBreak(25);

                    const mealTypeName = Nutrition.getMealTypeName(meal.mealType);

                    // Meal type name
                    doc.setFontSize(12);
                    doc.setTextColor(0, 105, 148);
                    doc.text(this.cleanTextForPDF(mealTypeName.toUpperCase()), margin, yPos);
                    yPos += 7;

                    // Food items
                    doc.setFontSize(10);
                    doc.setTextColor(60, 60, 60);
                    
                    meal.foodItems.forEach(item => {
                        checkPageBreak(6);
                        doc.text(this.cleanTextForPDF(`- ${item.foodName}: ${item.grams}g`), margin + 2, yPos);
                        yPos += 5;
                    });

                    yPos += 2;

                    // Meal totals
                    doc.setFontSize(10);
                    doc.setTextColor(0, 105, 148);
                    const totalsText = this.cleanTextForPDF(`-> ${meal.totalNutrition.calories} kcal | Proteine: ${meal.totalNutrition.protein}g | Carboidrati: ${meal.totalNutrition.carbs}g | Grassi: ${meal.totalNutrition.fats}g`);
                    const wrappedTotals = doc.splitTextToSize(totalsText, maxWidth - 4);
                    wrappedTotals.forEach(line => {
                        checkPageBreak(5);
                        doc.text(line, margin + 2, yPos);
                        yPos += 5;
                    });

                    yPos += 5;
                }

                // Daily totals
                const dailyNutrition = Meals.calculateDailyNutrition(meals);
                checkPageBreak(10);
                
                doc.setFontSize(11);
                doc.setTextColor(0, 105, 148);
                doc.setFont(undefined, 'bold');
                doc.text(this.cleanTextForPDF(`[Grafico] TOTALE ${dayName.toUpperCase()}: ${dailyNutrition.calories} kcal`), margin, yPos);
                doc.setFont(undefined, 'normal');
                yPos += 6;
                
                doc.setFontSize(9);
                doc.setTextColor(80, 80, 80);
                doc.text(this.cleanTextForPDF(`Proteine: ${dailyNutrition.protein}g | Carboidrati: ${dailyNutrition.carbs}g | Grassi: ${dailyNutrition.fats}g | Fibre: ${dailyNutrition.fiber}g`), margin, yPos);
                yPos += 12;
            }
        }

        // Footer
        doc.setFontSize(8);
        doc.setTextColor(150, 150, 150);
        const footerY = pageHeight - 10;
        doc.text('Generato da Dieta Mediterranea & Allenamento', pageWidth / 2, footerY, { align: 'center' });

        // Save PDF
        const fileName = `Menu_Settimanale_${profile.name}_${this.formatDateForFilename(new Date())}.pdf`;
        doc.save(fileName);
    },

    /**
     * Format date for filename
     * @param {Date} date - Date object
     * @returns {string} Formatted date string
     */
    formatDateForFilename(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    },

    /**
     * Generate Workout PDF
     * @param {Object} options - Options object containing profile, level, and program
     * @param {Object} options.profile - User profile object
     * @param {string} options.level - Workout level (beginner, intermediate, advanced)
     * @param {Object} options.program - Workout program from Workout.getProgram()
     */
    async generateWorkoutPDF({ profile, level, program }) {
        const { jsPDF } = window.jspdf;
        if (!jsPDF) {
            throw new Error('jsPDF library not loaded');
        }

        const doc = new jsPDF();
        let yPos = 20;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        const margin = 20;
        const maxWidth = pageWidth - 2 * margin;

        // Helper function to check page break
        const checkPageBreak = (neededSpace) => {
            if (yPos + neededSpace > pageHeight - 20) {
                doc.addPage();
                yPos = 20;
                return true;
            }
            return false;
        };

        // Helper function to wrap text with cleaning
        const wrapText = (text, maxWidth) => {
            return doc.splitTextToSize(this.cleanTextForPDF(text), maxWidth);
        };

        // Title
        doc.setFontSize(22);
        doc.setTextColor(0, 105, 148);
        doc.text('SCHEDA ALLENAMENTO', pageWidth / 2, yPos, { align: 'center' });
        yPos += 10;

        // Profile info
        doc.setFontSize(12);
        doc.setTextColor(100, 100, 100);
        doc.text(this.cleanTextForPDF(`Profilo: ${profile.name}`), pageWidth / 2, yPos, { align: 'center' });
        yPos += 6;
        
        const levelText = level === 'beginner' ? 'Principiante' : level === 'intermediate' ? 'Intermedio' : 'Avanzato';
        doc.text(this.cleanTextForPDF(`Livello: ${levelText}`), pageWidth / 2, yPos, { align: 'center' });
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
            doc.text(this.cleanTextForPDF(`${day.day} - ${day.type}`), margin + 3, yPos + 2);
            yPos += 12;

            // Exercises for this day
            for (const ex of day.exercises) {
                // Note: We need access to Workout.getExercise() here
                // This assumes Workout module is available globally
                const exercise = window.Workout.getExercise(ex.exercise);
                
                checkPageBreak(25);

                // Exercise name
                doc.setFontSize(12);
                doc.setTextColor(0, 105, 148);
                doc.text(this.cleanTextForPDF(`- ${exercise.name}`), margin + 2, yPos);
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
                        .replace(/•/g, '  -')
                        .replace(/✗/g, '  X')
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
    }
};

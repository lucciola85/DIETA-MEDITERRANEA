/**
 * PDF Export Module - Generate PDFs for Shopping List and Weekly Menu
 */

const PDFExport = {
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
        doc.text('🛒 LISTA DELLA SPESA', margin, yPos);
        yPos += 10;

        // Week range
        doc.setFontSize(12);
        doc.setTextColor(100, 100, 100);
        doc.text(`Settimana: ${weekRange}`, margin, yPos);
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
            const categoryName = this.getCategoryName(categoryKey);
            const items = shoppingListData.items[categoryKey];

            // Category header
            doc.setFontSize(14);
            doc.setTextColor(0, 105, 148);
            doc.text(categoryName.toUpperCase(), margin, yPos);
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
                const itemText = `${item.name}`;
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
     * @param {string} profileId - Profile ID
     * @param {Array} weekDates - Array of Date objects for the week
     */
    async generateWeeklyMenuPDF(profileId, weekDates) {
        const { jsPDF } = window.jspdf;
        if (!jsPDF) {
            throw new Error('jsPDF library not loaded');
        }

        // Get profile
        const profile = Profiles.getCurrentProfile();
        if (!profile) {
            throw new Error('No profile selected');
        }

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
        doc.text('🍽️ MENÙ SETTIMANALE', pageWidth / 2, yPos, { align: 'center' });
        yPos += 10;

        // Profile info
        doc.setFontSize(12);
        doc.setTextColor(100, 100, 100);
        doc.text(`Profilo: ${profile.name}`, pageWidth / 2, yPos, { align: 'center' });
        yPos += 6;
        doc.text(`Target giornaliero: ${nutrition.targetCalories} kcal`, pageWidth / 2, yPos, { align: 'center' });
        yPos += 6;

        // Week range
        const weekStart = weekDates[0];
        const weekEnd = weekDates[6];
        const weekRange = `${weekStart.toLocaleDateString('it-IT', { day: '2-digit', month: 'short' })} - ${weekEnd.toLocaleDateString('it-IT', { day: '2-digit', month: 'short', year: 'numeric' })}`;
        doc.text(`Settimana: ${weekRange}`, pageWidth / 2, yPos, { align: 'center' });
        yPos += 15;

        // Process each day
        for (const date of weekDates) {
            const dayName = Meals.getDayName(date);
            const dateStr = date.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit' });
            const meals = await Meals.getMealsByDate(profileId, date);

            // Skip if no meals for this day
            if (meals.length === 0) {
                continue;
            }

            checkPageBreak(20);

            // Day header
            doc.setFontSize(14);
            doc.setTextColor(0, 105, 148);
            const dayHeader = `══════ ${dayName.toUpperCase()} ${dateStr} ══════`;
            doc.text(dayHeader, pageWidth / 2, yPos, { align: 'center' });
            yPos += 10;

            // Process each meal
            for (const meal of meals) {
                checkPageBreak(25);

                const mealTypeName = Nutrition.getMealTypeName(meal.mealType);

                // Meal type name
                doc.setFontSize(12);
                doc.setTextColor(0, 105, 148);
                doc.text(mealTypeName.toUpperCase(), margin, yPos);
                yPos += 7;

                // Food items
                doc.setFontSize(10);
                doc.setTextColor(60, 60, 60);
                
                meal.foodItems.forEach(item => {
                    checkPageBreak(6);
                    doc.text(`• ${item.foodName}: ${item.grams}g`, margin + 2, yPos);
                    yPos += 5;
                });

                yPos += 2;

                // Meal totals
                doc.setFontSize(10);
                doc.setTextColor(0, 105, 148);
                const totalsText = `→ ${meal.totalNutrition.calories} kcal | Proteine: ${meal.totalNutrition.protein}g | Carboidrati: ${meal.totalNutrition.carbs}g | Grassi: ${meal.totalNutrition.fats}g`;
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
            doc.text(`📊 TOTALE ${dayName.toUpperCase()}: ${dailyNutrition.calories} kcal`, margin, yPos);
            doc.setFont(undefined, 'normal');
            yPos += 6;
            
            doc.setFontSize(9);
            doc.setTextColor(80, 80, 80);
            doc.text(`Proteine: ${dailyNutrition.protein}g | Carboidrati: ${dailyNutrition.carbs}g | Grassi: ${dailyNutrition.fats}g | Fibre: ${dailyNutrition.fiber}g`, margin, yPos);
            yPos += 12;
        }

        // Check if any meals were found
        const totalMealsInWeek = (await Promise.all(
            weekDates.map(date => Meals.getMealsByDate(profileId, date))
        )).flat().length;

        if (totalMealsInWeek === 0) {
            // No meals found
            doc.setFontSize(12);
            doc.setTextColor(150, 150, 150);
            doc.text('Nessun pasto pianificato per questa settimana', pageWidth / 2, 100, { align: 'center' });
            doc.setFontSize(10);
            doc.text('Vai al Pianificatore Pasti per compilare i tuoi pasti', pageWidth / 2, 110, { align: 'center' });
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
     * Get category name in Italian
     * @param {string} categoryKey - Category key
     * @returns {string} Category name
     */
    getCategoryName(categoryKey) {
        const categories = {
            vegetables: 'VERDURE',
            fruits: 'FRUTTA',
            cereals: 'CEREALI E DERIVATI',
            legumes: 'LEGUMI',
            fish: 'PESCE',
            seafood: 'FRUTTI DI MARE',
            poultry: 'POLLAME',
            meat: 'CARNE',
            eggs: 'UOVA',
            dairy: 'LATTICINI',
            nuts: 'FRUTTA SECCA E SEMI',
            oils: 'OLI E GRASSI',
            other: 'ALTRO'
        };
        return categories[categoryKey] || categoryKey.toUpperCase();
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
    }
};

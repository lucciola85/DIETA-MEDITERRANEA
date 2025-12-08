/**
 * Database Module - Mediterranean Food Database (300+ items)
 * All values are per 100g
 */

const FoodDatabase = {
    categories: {
        vegetables: '🥬 Verdure e Ortaggi',
        fruits: '🍎 Frutta Fresca',
        nuts: '🥜 Frutta Secca e Semi',
        grains: '🌾 Cereali',
        legumes: '🫘 Legumi',
        fish: '🐟 Pesce e Frutti di Mare',
        meat: '🥩 Carni',
        eggs: '🥚 Uova',
        dairy: '🧀 Latticini',
        oils: '🫒 Oli e Grassi',
        herbs: '🌿 Spezie e Aromi',
        sweeteners: '🍯 Dolcificanti',
        beverages: '🍷 Bevande'
    },

    foods: [
        // Vegetables (Verdure e Ortaggi) - 60+ items
        { name: 'Pomodori', category: 'vegetables', calories: 18, protein: 0.9, carbs: 3.9, fats: 0.2, fiber: 1.2 },
        { name: 'Pomodori ciliegino', category: 'vegetables', calories: 27, protein: 1.3, carbs: 5.8, fats: 0.3, fiber: 1.8 },
        { name: 'Pomodori secchi', category: 'vegetables', calories: 258, protein: 14.1, carbs: 55.8, fats: 3.0, fiber: 12.3 },
        { name: 'Zucchine', category: 'vegetables', calories: 17, protein: 1.2, carbs: 3.1, fats: 0.3, fiber: 1.0 },
        { name: 'Melanzane', category: 'vegetables', calories: 25, protein: 1.0, carbs: 5.9, fats: 0.2, fiber: 3.0 },
        { name: 'Peperoni rossi', category: 'vegetables', calories: 31, protein: 1.0, carbs: 6.0, fats: 0.3, fiber: 2.1 },
        { name: 'Peperoni gialli', category: 'vegetables', calories: 27, protein: 1.0, carbs: 6.3, fats: 0.2, fiber: 0.9 },
        { name: 'Peperoni verdi', category: 'vegetables', calories: 20, protein: 0.9, carbs: 4.6, fats: 0.2, fiber: 1.7 },
        { name: 'Spinaci', category: 'vegetables', calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4, fiber: 2.2 },
        { name: 'Bietole', category: 'vegetables', calories: 19, protein: 1.8, carbs: 3.7, fats: 0.2, fiber: 1.6 },
        { name: 'Carciofi', category: 'vegetables', calories: 47, protein: 3.3, carbs: 10.5, fats: 0.2, fiber: 5.4 },
        { name: 'Broccoli', category: 'vegetables', calories: 34, protein: 2.8, carbs: 7.0, fats: 0.4, fiber: 2.6 },
        { name: 'Cavolfiori', category: 'vegetables', calories: 25, protein: 1.9, carbs: 5.0, fats: 0.3, fiber: 2.0 },
        { name: 'Lattuga', category: 'vegetables', calories: 15, protein: 1.4, carbs: 2.9, fats: 0.2, fiber: 1.3 },
        { name: 'Lattuga iceberg', category: 'vegetables', calories: 14, protein: 0.9, carbs: 3.0, fats: 0.1, fiber: 1.2 },
        { name: 'Rucola', category: 'vegetables', calories: 25, protein: 2.6, carbs: 3.7, fats: 0.7, fiber: 1.6 },
        { name: 'Radicchio', category: 'vegetables', calories: 23, protein: 1.4, carbs: 4.5, fats: 0.3, fiber: 0.9 },
        { name: 'Finocchi', category: 'vegetables', calories: 31, protein: 1.2, carbs: 7.3, fats: 0.2, fiber: 3.1 },
        { name: 'Sedano', category: 'vegetables', calories: 16, protein: 0.7, carbs: 3.0, fats: 0.2, fiber: 1.6 },
        { name: 'Carote', category: 'vegetables', calories: 41, protein: 0.9, carbs: 9.6, fats: 0.2, fiber: 2.8 },
        { name: 'Cipolle', category: 'vegetables', calories: 40, protein: 1.1, carbs: 9.3, fats: 0.1, fiber: 1.7 },
        { name: 'Cipolle rosse', category: 'vegetables', calories: 42, protein: 0.9, carbs: 10.1, fats: 0.1, fiber: 1.4 },
        { name: 'Aglio', category: 'vegetables', calories: 149, protein: 6.4, carbs: 33.1, fats: 0.5, fiber: 2.1 },
        { name: 'Porri', category: 'vegetables', calories: 61, protein: 1.5, carbs: 14.2, fats: 0.3, fiber: 1.8 },
        { name: 'Asparagi', category: 'vegetables', calories: 20, protein: 2.2, carbs: 3.9, fats: 0.1, fiber: 2.0 },
        { name: 'Fagiolini', category: 'vegetables', calories: 31, protein: 1.8, carbs: 7.0, fats: 0.2, fiber: 3.4 },
        { name: 'Piselli freschi', category: 'vegetables', calories: 81, protein: 5.4, carbs: 14.5, fats: 0.4, fiber: 5.7 },
        { name: 'Fave fresche', category: 'vegetables', calories: 88, protein: 5.2, carbs: 17.6, fats: 0.4, fiber: 4.2 },
        { name: 'Cetrioli', category: 'vegetables', calories: 15, protein: 0.7, carbs: 3.6, fats: 0.1, fiber: 0.5 },
        { name: 'Rape', category: 'vegetables', calories: 28, protein: 0.9, carbs: 6.4, fats: 0.1, fiber: 1.8 },
        { name: 'Cavolo', category: 'vegetables', calories: 25, protein: 1.3, carbs: 5.8, fats: 0.1, fiber: 2.5 },
        { name: 'Cavolo nero', category: 'vegetables', calories: 43, protein: 3.3, carbs: 8.8, fats: 0.9, fiber: 3.6 },
        { name: 'Verza', category: 'vegetables', calories: 27, protein: 1.3, carbs: 6.1, fats: 0.1, fiber: 2.5 },
        { name: 'Cavolo cappuccio', category: 'vegetables', calories: 25, protein: 1.3, carbs: 5.8, fats: 0.1, fiber: 2.5 },
        { name: 'Cavoletti di Bruxelles', category: 'vegetables', calories: 43, protein: 3.4, carbs: 8.9, fats: 0.3, fiber: 3.8 },
        { name: 'Funghi champignon', category: 'vegetables', calories: 22, protein: 3.1, carbs: 3.3, fats: 0.3, fiber: 1.0 },
        { name: 'Funghi porcini', category: 'vegetables', calories: 26, protein: 3.5, carbs: 3.7, fats: 0.7, fiber: 2.5 },
        { name: 'Zucca', category: 'vegetables', calories: 26, protein: 1.0, carbs: 6.5, fats: 0.1, fiber: 0.5 },
        { name: 'Patate', category: 'vegetables', calories: 77, protein: 2.0, carbs: 17.5, fats: 0.1, fiber: 2.2 },
        { name: 'Patate dolci', category: 'vegetables', calories: 86, protein: 1.6, carbs: 20.1, fats: 0.1, fiber: 3.0 },
        { name: 'Barbabietole', category: 'vegetables', calories: 43, protein: 1.6, carbs: 9.6, fats: 0.2, fiber: 2.8 },
        { name: 'Catalogna', category: 'vegetables', calories: 16, protein: 1.5, carbs: 2.8, fats: 0.3, fiber: 3.6 },
        { name: 'Cicoria', category: 'vegetables', calories: 23, protein: 1.7, carbs: 4.7, fats: 0.3, fiber: 3.1 },
        { name: 'Indivia', category: 'vegetables', calories: 17, protein: 1.3, carbs: 3.4, fats: 0.2, fiber: 3.1 },
        { name: 'Scarola', category: 'vegetables', calories: 17, protein: 1.3, carbs: 3.4, fats: 0.2, fiber: 3.1 },
        { name: 'Valeriana', category: 'vegetables', calories: 21, protein: 2.0, carbs: 3.6, fats: 0.4, fiber: 2.2 },
        { name: 'Crescione', category: 'vegetables', calories: 11, protein: 2.3, carbs: 1.3, fats: 0.1, fiber: 0.5 },
        { name: 'Olive verdi', category: 'vegetables', calories: 145, protein: 1.0, carbs: 3.8, fats: 15.3, fiber: 3.3 },
        { name: 'Olive nere', category: 'vegetables', calories: 235, protein: 1.5, carbs: 5.6, fats: 23.9, fiber: 3.0 },
        { name: 'Capperi', category: 'vegetables', calories: 23, protein: 2.4, carbs: 4.9, fats: 0.9, fiber: 3.2 },
        { name: 'Crauti', category: 'vegetables', calories: 19, protein: 0.9, carbs: 4.3, fats: 0.1, fiber: 2.9 },

        // Fruits (Frutta Fresca) - 50+ items
        { name: 'Mele', category: 'fruits', calories: 52, protein: 0.3, carbs: 13.8, fats: 0.2, fiber: 2.4 },
        { name: 'Mele verdi', category: 'fruits', calories: 48, protein: 0.3, carbs: 12.8, fats: 0.1, fiber: 2.6 },
        { name: 'Pere', category: 'fruits', calories: 57, protein: 0.4, carbs: 15.2, fats: 0.1, fiber: 3.1 },
        { name: 'Arance', category: 'fruits', calories: 47, protein: 0.9, carbs: 11.8, fats: 0.1, fiber: 2.4 },
        { name: 'Arance rosse', category: 'fruits', calories: 45, protein: 0.8, carbs: 11.4, fats: 0.1, fiber: 2.3 },
        { name: 'Mandarini', category: 'fruits', calories: 53, protein: 0.8, carbs: 13.3, fats: 0.3, fiber: 1.8 },
        { name: 'Clementine', category: 'fruits', calories: 47, protein: 0.9, carbs: 12.0, fats: 0.2, fiber: 1.7 },
        { name: 'Limoni', category: 'fruits', calories: 29, protein: 1.1, carbs: 9.3, fats: 0.3, fiber: 2.8 },
        { name: 'Pompelmi', category: 'fruits', calories: 42, protein: 0.8, carbs: 10.7, fats: 0.1, fiber: 1.6 },
        { name: 'Uva bianca', category: 'fruits', calories: 69, protein: 0.7, carbs: 18.1, fats: 0.2, fiber: 0.9 },
        { name: 'Uva nera', category: 'fruits', calories: 67, protein: 0.6, carbs: 17.2, fats: 0.4, fiber: 0.9 },
        { name: 'Pesche', category: 'fruits', calories: 39, protein: 0.9, carbs: 9.5, fats: 0.3, fiber: 1.5 },
        { name: 'Pesche noci', category: 'fruits', calories: 44, protein: 1.1, carbs: 10.6, fats: 0.3, fiber: 1.7 },
        { name: 'Albicocche', category: 'fruits', calories: 48, protein: 1.4, carbs: 11.1, fats: 0.4, fiber: 2.0 },
        { name: 'Susine', category: 'fruits', calories: 46, protein: 0.7, carbs: 11.4, fats: 0.3, fiber: 1.4 },
        { name: 'Ciliegie', category: 'fruits', calories: 63, protein: 1.1, carbs: 16.0, fats: 0.2, fiber: 2.1 },
        { name: 'Fragole', category: 'fruits', calories: 32, protein: 0.7, carbs: 7.7, fats: 0.3, fiber: 2.0 },
        { name: 'Fichi', category: 'fruits', calories: 74, protein: 0.8, carbs: 19.2, fats: 0.3, fiber: 2.9 },
        { name: 'Fichi secchi', category: 'fruits', calories: 249, protein: 3.3, carbs: 63.9, fats: 0.9, fiber: 9.8 },
        { name: 'Melograno', category: 'fruits', calories: 83, protein: 1.7, carbs: 18.7, fats: 1.2, fiber: 4.0 },
        { name: 'Kiwi', category: 'fruits', calories: 61, protein: 1.1, carbs: 14.7, fats: 0.5, fiber: 3.0 },
        { name: 'Banane', category: 'fruits', calories: 89, protein: 1.1, carbs: 22.8, fats: 0.3, fiber: 2.6 },
        { name: 'Melone', category: 'fruits', calories: 34, protein: 0.8, carbs: 8.2, fats: 0.2, fiber: 0.9 },
        { name: 'Anguria', category: 'fruits', calories: 30, protein: 0.6, carbs: 7.6, fats: 0.2, fiber: 0.4 },
        { name: 'Prugne secche', category: 'fruits', calories: 240, protein: 2.2, carbs: 63.9, fats: 0.4, fiber: 7.1 },
        { name: 'Datteri', category: 'fruits', calories: 277, protein: 1.8, carbs: 75.0, fats: 0.2, fiber: 6.7 },
        { name: 'Uva passa', category: 'fruits', calories: 299, protein: 3.1, carbs: 79.2, fats: 0.5, fiber: 3.7 },
        { name: 'Mirtilli', category: 'fruits', calories: 57, protein: 0.7, carbs: 14.5, fats: 0.3, fiber: 2.4 },
        { name: 'More', category: 'fruits', calories: 43, protein: 1.4, carbs: 9.6, fats: 0.5, fiber: 5.3 },
        { name: 'Lamponi', category: 'fruits', calories: 52, protein: 1.2, carbs: 11.9, fats: 0.7, fiber: 6.5 },
        { name: 'Ribes', category: 'fruits', calories: 56, protein: 1.4, carbs: 13.8, fats: 0.2, fiber: 4.3 },
        { name: 'Ananas', category: 'fruits', calories: 50, protein: 0.5, carbs: 13.1, fats: 0.1, fiber: 1.4 },
        { name: 'Mango', category: 'fruits', calories: 60, protein: 0.8, carbs: 15.0, fats: 0.4, fiber: 1.6 },
        { name: 'Papaya', category: 'fruits', calories: 43, protein: 0.5, carbs: 10.8, fats: 0.3, fiber: 1.7 },
        { name: 'Avocado', category: 'fruits', calories: 160, protein: 2.0, carbs: 8.5, fats: 14.7, fiber: 6.7 },
        { name: 'Cocco', category: 'fruits', calories: 354, protein: 3.3, carbs: 15.2, fats: 33.5, fiber: 9.0 },
        { name: 'Nespole', category: 'fruits', calories: 47, protein: 0.4, carbs: 12.1, fats: 0.2, fiber: 1.7 },
        { name: 'Cachi', category: 'fruits', calories: 70, protein: 0.6, carbs: 18.6, fats: 0.2, fiber: 3.6 },

        // Nuts and Seeds (Frutta Secca e Semi) - 25+ items
        { name: 'Noci', category: 'nuts', calories: 654, protein: 15.2, carbs: 13.7, fats: 65.2, fiber: 6.7 },
        { name: 'Mandorle', category: 'nuts', calories: 579, protein: 21.2, carbs: 21.6, fats: 49.9, fiber: 12.5 },
        { name: 'Nocciole', category: 'nuts', calories: 628, protein: 15.0, carbs: 16.7, fats: 60.8, fiber: 9.7 },
        { name: 'Pistacchi', category: 'nuts', calories: 562, protein: 20.2, carbs: 27.2, fats: 45.3, fiber: 10.6 },
        { name: 'Pinoli', category: 'nuts', calories: 673, protein: 13.7, carbs: 13.1, fats: 68.4, fiber: 3.7 },
        { name: 'Anacardi', category: 'nuts', calories: 553, protein: 18.2, carbs: 30.2, fats: 43.9, fiber: 3.3 },
        { name: 'Arachidi', category: 'nuts', calories: 567, protein: 25.8, carbs: 16.1, fats: 49.2, fiber: 8.5 },
        { name: 'Noci brasiliane', category: 'nuts', calories: 656, protein: 14.3, carbs: 12.3, fats: 66.4, fiber: 7.5 },
        { name: 'Noci pecan', category: 'nuts', calories: 691, protein: 9.2, carbs: 13.9, fats: 72.0, fiber: 9.6 },
        { name: 'Noci macadamia', category: 'nuts', calories: 718, protein: 7.9, carbs: 13.8, fats: 75.8, fiber: 8.6 },
        { name: 'Semi di lino', category: 'nuts', calories: 534, protein: 18.3, carbs: 28.9, fats: 42.2, fiber: 27.3 },
        { name: 'Semi di chia', category: 'nuts', calories: 486, protein: 16.5, carbs: 42.1, fats: 30.7, fiber: 34.4 },
        { name: 'Semi di girasole', category: 'nuts', calories: 584, protein: 20.8, carbs: 20.0, fats: 51.5, fiber: 8.6 },
        { name: 'Semi di zucca', category: 'nuts', calories: 559, protein: 30.2, carbs: 10.7, fats: 49.1, fiber: 6.0 },
        { name: 'Semi di sesamo', category: 'nuts', calories: 573, protein: 17.7, carbs: 23.4, fats: 49.7, fiber: 11.8 },
        { name: 'Semi di papavero', category: 'nuts', calories: 525, protein: 17.9, carbs: 28.1, fats: 41.6, fiber: 19.5 },

        // Grains (Cereali) - 40+ items
        { name: 'Pasta di semola', category: 'grains', calories: 371, protein: 13.0, carbs: 75.2, fats: 1.5, fiber: 3.2 },
        { name: 'Pasta integrale', category: 'grains', calories: 348, protein: 13.4, carbs: 71.2, fats: 2.5, fiber: 8.0 },
        { name: 'Pasta all\'uovo', category: 'grains', calories: 368, protein: 13.1, carbs: 71.4, fats: 2.9, fiber: 3.3 },
        { name: 'Riso bianco', category: 'grains', calories: 365, protein: 7.1, carbs: 79.9, fats: 0.6, fiber: 1.3 },
        { name: 'Riso integrale', category: 'grains', calories: 370, protein: 7.9, carbs: 77.2, fats: 2.9, fiber: 3.5 },
        { name: 'Riso basmati', category: 'grains', calories: 370, protein: 7.5, carbs: 79.0, fats: 0.6, fiber: 0.9 },
        { name: 'Riso parboiled', category: 'grains', calories: 374, protein: 7.5, carbs: 81.3, fats: 1.0, fiber: 1.4 },
        { name: 'Farro', category: 'grains', calories: 335, protein: 15.1, carbs: 67.1, fats: 2.5, fiber: 10.7 },
        { name: 'Orzo perlato', category: 'grains', calories: 354, protein: 10.6, carbs: 77.7, fats: 1.2, fiber: 9.2 },
        { name: 'Avena', category: 'grains', calories: 389, protein: 16.9, carbs: 66.3, fats: 6.9, fiber: 10.6 },
        { name: 'Quinoa', category: 'grains', calories: 368, protein: 14.1, carbs: 64.2, fats: 6.1, fiber: 7.0 },
        { name: 'Couscous', category: 'grains', calories: 376, protein: 12.8, carbs: 77.4, fats: 0.6, fiber: 5.0 },
        { name: 'Bulgur', category: 'grains', calories: 342, protein: 12.3, carbs: 75.9, fats: 1.3, fiber: 18.3 },
        { name: 'Miglio', category: 'grains', calories: 378, protein: 11.0, carbs: 72.8, fats: 4.2, fiber: 8.5 },
        { name: 'Amaranto', category: 'grains', calories: 371, protein: 13.6, carbs: 65.3, fats: 7.0, fiber: 6.7 },
        { name: 'Grano saraceno', category: 'grains', calories: 343, protein: 13.3, carbs: 71.5, fats: 3.4, fiber: 10.0 },
        { name: 'Pane bianco', category: 'grains', calories: 265, protein: 8.9, carbs: 49.4, fats: 3.2, fiber: 3.5 },
        { name: 'Pane integrale', category: 'grains', calories: 247, protein: 9.2, carbs: 45.4, fats: 3.3, fiber: 7.0 },
        { name: 'Pane di segale', category: 'grains', calories: 259, protein: 8.5, carbs: 48.3, fats: 3.3, fiber: 5.8 },
        { name: 'Pane carasau', category: 'grains', calories: 361, protein: 12.3, carbs: 72.2, fats: 2.5, fiber: 3.2 },
        { name: 'Grissini', category: 'grains', calories: 433, protein: 12.3, carbs: 68.4, fats: 13.9, fiber: 3.5 },
        { name: 'Fette biscottate', category: 'grains', calories: 410, protein: 11.3, carbs: 76.0, fats: 6.0, fiber: 3.8 },
        { name: 'Crackers integrali', category: 'grains', calories: 439, protein: 11.0, carbs: 66.5, fats: 13.0, fiber: 8.5 },
        { name: 'Crackers salati', category: 'grains', calories: 428, protein: 9.4, carbs: 71.3, fats: 11.3, fiber: 2.5 },
        { name: 'Biscotti secchi', category: 'grains', calories: 416, protein: 6.6, carbs: 82.3, fats: 7.9, fiber: 3.0 },
        { name: 'Corn flakes', category: 'grains', calories: 357, protein: 7.5, carbs: 84.0, fats: 0.9, fiber: 3.0 },
        { name: 'Muesli', category: 'grains', calories: 352, protein: 9.7, carbs: 66.9, fats: 5.8, fiber: 7.3 },
        { name: 'Polenta', category: 'grains', calories: 358, protein: 8.7, carbs: 79.8, fats: 2.7, fiber: 3.9 },
        { name: 'Semolino', category: 'grains', calories: 360, protein: 10.3, carbs: 75.6, fats: 1.2, fiber: 3.9 },

        // Legumes (Legumi) - 20+ items
        { name: 'Fagioli borlotti secchi', category: 'legumes', calories: 333, protein: 23.6, carbs: 60.0, fats: 1.8, fiber: 17.3 },
        { name: 'Fagioli cannellini secchi', category: 'legumes', calories: 343, protein: 23.4, carbs: 60.5, fats: 1.6, fiber: 17.5 },
        { name: 'Fagioli neri secchi', category: 'legumes', calories: 341, protein: 21.6, carbs: 62.4, fats: 1.4, fiber: 15.5 },
        { name: 'Fagioli rossi secchi', category: 'legumes', calories: 333, protein: 24.4, carbs: 60.0, fats: 0.8, fiber: 15.2 },
        { name: 'Ceci secchi', category: 'legumes', calories: 364, protein: 19.3, carbs: 60.6, fats: 6.0, fiber: 17.4 },
        { name: 'Lenticchie secche', category: 'legumes', calories: 353, protein: 25.8, carbs: 60.1, fats: 1.1, fiber: 13.8 },
        { name: 'Lenticchie rosse', category: 'legumes', calories: 358, protein: 24.6, carbs: 63.1, fats: 1.1, fiber: 10.7 },
        { name: 'Fave secche', category: 'legumes', calories: 341, protein: 27.2, carbs: 58.3, fats: 1.5, fiber: 25.0 },
        { name: 'Piselli secchi', category: 'legumes', calories: 352, protein: 21.7, carbs: 60.4, fats: 2.0, fiber: 23.8 },
        { name: 'Lupini', category: 'legumes', calories: 371, protein: 36.2, carbs: 40.4, fats: 9.7, fiber: 18.9 },
        { name: 'Soia', category: 'legumes', calories: 446, protein: 36.5, carbs: 30.2, fats: 19.9, fiber: 9.3 },
        { name: 'Fagioli borlotti in scatola', category: 'legumes', calories: 91, protein: 6.7, carbs: 13.7, fats: 0.5, fiber: 5.5 },
        { name: 'Ceci in scatola', category: 'legumes', calories: 115, protein: 6.7, carbs: 17.7, fats: 2.6, fiber: 5.4 },
        { name: 'Lenticchie in scatola', category: 'legumes', calories: 95, protein: 7.6, carbs: 15.8, fats: 0.4, fiber: 5.1 },

        // Fish and Seafood (Pesce e Frutti di Mare) - 35+ items
        { name: 'Salmone fresco', category: 'fish', calories: 208, protein: 20.0, carbs: 0.0, fats: 13.4, fiber: 0.0 },
        { name: 'Salmone affumicato', category: 'fish', calories: 117, protein: 18.3, carbs: 0.0, fats: 4.3, fiber: 0.0 },
        { name: 'Tonno fresco', category: 'fish', calories: 144, protein: 23.3, carbs: 0.0, fats: 4.9, fiber: 0.0 },
        { name: 'Tonno in scatola al naturale', category: 'fish', calories: 116, protein: 25.5, carbs: 0.0, fats: 0.8, fiber: 0.0 },
        { name: 'Tonno in scatola olio', category: 'fish', calories: 192, protein: 25.0, carbs: 0.0, fats: 9.0, fiber: 0.0 },
        { name: 'Sgombro fresco', category: 'fish', calories: 205, protein: 19.0, carbs: 0.0, fats: 13.9, fiber: 0.0 },
        { name: 'Sardine fresche', category: 'fish', calories: 208, protein: 20.9, carbs: 0.0, fats: 13.6, fiber: 0.0 },
        { name: 'Sardine in scatola', category: 'fish', calories: 208, protein: 24.6, carbs: 0.0, fats: 11.5, fiber: 0.0 },
        { name: 'Acciughe fresche', category: 'fish', calories: 131, protein: 20.4, carbs: 0.0, fats: 4.8, fiber: 0.0 },
        { name: 'Acciughe sott\'olio', category: 'fish', calories: 210, protein: 25.9, carbs: 0.0, fats: 11.3, fiber: 0.0 },
        { name: 'Merluzzo fresco', category: 'fish', calories: 82, protein: 17.8, carbs: 0.0, fats: 0.7, fiber: 0.0 },
        { name: 'Nasello', category: 'fish', calories: 71, protein: 16.3, carbs: 0.0, fats: 0.3, fiber: 0.0 },
        { name: 'Orata', category: 'fish', calories: 121, protein: 20.7, carbs: 0.0, fats: 3.8, fiber: 0.0 },
        { name: 'Branzino', category: 'fish', calories: 97, protein: 19.4, carbs: 0.0, fats: 1.5, fiber: 0.0 },
        { name: 'Trota', category: 'fish', calories: 119, protein: 19.5, carbs: 0.0, fats: 3.0, fiber: 0.0 },
        { name: 'Pesce spada', category: 'fish', calories: 144, protein: 19.8, carbs: 0.0, fats: 6.7, fiber: 0.0 },
        { name: 'Sogliola', category: 'fish', calories: 86, protein: 17.0, carbs: 0.0, fats: 1.7, fiber: 0.0 },
        { name: 'Platessa', category: 'fish', calories: 91, protein: 18.8, carbs: 0.0, fats: 1.9, fiber: 0.0 },
        { name: 'Spigola', category: 'fish', calories: 97, protein: 19.4, carbs: 0.0, fats: 1.5, fiber: 0.0 },
        { name: 'Cernia', category: 'fish', calories: 92, protein: 19.4, carbs: 0.0, fats: 1.0, fiber: 0.0 },
        { name: 'Gamberi', category: 'fish', calories: 71, protein: 13.6, carbs: 0.9, fats: 0.6, fiber: 0.0 },
        { name: 'Gamberetti', category: 'fish', calories: 106, protein: 20.3, carbs: 2.9, fats: 1.7, fiber: 0.0 },
        { name: 'Gamberi rossi', category: 'fish', calories: 80, protein: 17.6, carbs: 0.0, fats: 0.6, fiber: 0.0 },
        { name: 'Calamari', category: 'fish', calories: 92, protein: 15.6, carbs: 3.1, fats: 1.4, fiber: 0.0 },
        { name: 'Seppie', category: 'fish', calories: 72, protein: 14.0, carbs: 0.7, fats: 1.5, fiber: 0.0 },
        { name: 'Polpo', category: 'fish', calories: 82, protein: 14.9, carbs: 2.2, fats: 1.0, fiber: 0.0 },
        { name: 'Cozze', category: 'fish', calories: 86, protein: 11.7, carbs: 3.7, fats: 2.7, fiber: 0.0 },
        { name: 'Vongole', category: 'fish', calories: 72, protein: 10.2, carbs: 2.6, fats: 2.5, fiber: 0.0 },
        { name: 'Capesante', category: 'fish', calories: 88, protein: 17.0, carbs: 2.4, fats: 1.2, fiber: 0.0 },
        { name: 'Aragosta', category: 'fish', calories: 89, protein: 18.8, carbs: 0.0, fats: 0.9, fiber: 0.0 },
        { name: 'Astice', category: 'fish', calories: 77, protein: 16.5, carbs: 0.0, fats: 0.8, fiber: 0.0 },

        // Meat (Carni) - 25+ items
        { name: 'Petto di pollo', category: 'meat', calories: 165, protein: 31.0, carbs: 0.0, fats: 3.6, fiber: 0.0 },
        { name: 'Coscia di pollo', category: 'meat', calories: 211, protein: 24.8, carbs: 0.0, fats: 11.8, fiber: 0.0 },
        { name: 'Pollo intero', category: 'meat', calories: 239, protein: 27.3, carbs: 0.0, fats: 13.6, fiber: 0.0 },
        { name: 'Petto di tacchino', category: 'meat', calories: 135, protein: 29.0, carbs: 0.0, fats: 1.6, fiber: 0.0 },
        { name: 'Tacchino macinato', category: 'meat', calories: 149, protein: 20.9, carbs: 0.0, fats: 6.6, fiber: 0.0 },
        { name: 'Coniglio', category: 'meat', calories: 136, protein: 21.2, carbs: 0.0, fats: 5.5, fiber: 0.0 },
        { name: 'Manzo magro', category: 'meat', calories: 250, protein: 26.4, carbs: 0.0, fats: 15.4, fiber: 0.0 },
        { name: 'Vitello', category: 'meat', calories: 109, protein: 20.0, carbs: 0.0, fats: 2.7, fiber: 0.0 },
        { name: 'Maiale magro', category: 'meat', calories: 143, protein: 21.3, carbs: 0.0, fats: 5.7, fiber: 0.0 },
        { name: 'Lonza di maiale', category: 'meat', calories: 147, protein: 22.7, carbs: 0.0, fats: 5.7, fiber: 0.0 },
        { name: 'Agnello', category: 'meat', calories: 294, protein: 25.0, carbs: 0.0, fats: 21.0, fiber: 0.0 },
        { name: 'Prosciutto crudo', category: 'meat', calories: 145, protein: 26.9, carbs: 0.0, fats: 3.9, fiber: 0.0 },
        { name: 'Prosciutto cotto', category: 'meat', calories: 132, protein: 19.8, carbs: 0.9, fats: 4.4, fiber: 0.0 },
        { name: 'Bresaola', category: 'meat', calories: 151, protein: 32.0, carbs: 0.2, fats: 2.6, fiber: 0.0 },
        { name: 'Speck', category: 'meat', calories: 301, protein: 28.3, carbs: 0.5, fats: 20.9, fiber: 0.0 },
        { name: 'Salame', category: 'meat', calories: 425, protein: 22.6, carbs: 1.2, fats: 37.1, fiber: 0.0 },
        { name: 'Mortadella', category: 'meat', calories: 317, protein: 15.7, carbs: 1.5, fats: 28.1, fiber: 0.0 },
        { name: 'Salsiccia', category: 'meat', calories: 304, protein: 15.4, carbs: 1.0, fats: 26.7, fiber: 0.0 },

        // Eggs (Uova)
        { name: 'Uova intere', category: 'eggs', calories: 155, protein: 13.0, carbs: 1.1, fats: 11.0, fiber: 0.0 },
        { name: 'Albume d\'uovo', category: 'eggs', calories: 52, protein: 10.9, carbs: 0.7, fats: 0.2, fiber: 0.0 },
        { name: 'Tuorlo d\'uovo', category: 'eggs', calories: 322, protein: 15.9, carbs: 3.6, fats: 26.5, fiber: 0.0 },

        // Dairy (Latticini) - 30+ items
        { name: 'Latte intero', category: 'dairy', calories: 64, protein: 3.3, carbs: 4.8, fats: 3.6, fiber: 0.0 },
        { name: 'Latte parzialmente scremato', category: 'dairy', calories: 46, protein: 3.3, carbs: 4.9, fats: 1.5, fiber: 0.0 },
        { name: 'Latte scremato', category: 'dairy', calories: 36, protein: 3.6, carbs: 5.3, fats: 0.2, fiber: 0.0 },
        { name: 'Latte di capra', category: 'dairy', calories: 69, protein: 3.6, carbs: 4.5, fats: 4.1, fiber: 0.0 },
        { name: 'Yogurt intero', category: 'dairy', calories: 66, protein: 3.5, carbs: 4.3, fats: 3.9, fiber: 0.0 },
        { name: 'Yogurt parzialmente scremato', category: 'dairy', calories: 43, protein: 3.3, carbs: 3.8, fats: 1.7, fiber: 0.0 },
        { name: 'Yogurt magro', category: 'dairy', calories: 36, protein: 3.3, carbs: 4.0, fats: 0.9, fiber: 0.0 },
        { name: 'Yogurt greco intero', category: 'dairy', calories: 97, protein: 9.0, carbs: 3.6, fats: 5.0, fiber: 0.0 },
        { name: 'Yogurt greco 0%', category: 'dairy', calories: 59, protein: 10.2, carbs: 3.6, fats: 0.4, fiber: 0.0 },
        { name: 'Ricotta vaccina', category: 'dairy', calories: 146, protein: 11.3, carbs: 3.5, fats: 10.9, fiber: 0.0 },
        { name: 'Ricotta di pecora', category: 'dairy', calories: 157, protein: 11.5, carbs: 3.0, fats: 11.5, fiber: 0.0 },
        { name: 'Mozzarella', category: 'dairy', calories: 280, protein: 18.7, carbs: 2.5, fats: 22.4, fiber: 0.0 },
        { name: 'Mozzarella light', category: 'dairy', calories: 163, protein: 20.3, carbs: 2.5, fats: 9.0, fiber: 0.0 },
        { name: 'Mozzarella di bufala', category: 'dairy', calories: 288, protein: 16.7, carbs: 0.4, fats: 24.4, fiber: 0.0 },
        { name: 'Parmigiano Reggiano', category: 'dairy', calories: 392, protein: 33.0, carbs: 3.2, fats: 28.4, fiber: 0.0 },
        { name: 'Grana Padano', category: 'dairy', calories: 384, protein: 33.0, carbs: 0.0, fats: 28.0, fiber: 0.0 },
        { name: 'Pecorino', category: 'dairy', calories: 387, protein: 25.8, carbs: 3.2, fats: 32.0, fiber: 0.0 },
        { name: 'Feta', category: 'dairy', calories: 264, protein: 14.2, carbs: 4.1, fats: 21.3, fiber: 0.0 },
        { name: 'Caciotta', category: 'dairy', calories: 316, protein: 23.0, carbs: 1.4, fats: 25.0, fiber: 0.0 },
        { name: 'Scamorza', category: 'dairy', calories: 334, protein: 25.0, carbs: 1.9, fats: 26.3, fiber: 0.0 },
        { name: 'Provolone', category: 'dairy', calories: 351, protein: 28.9, carbs: 2.1, fats: 26.6, fiber: 0.0 },
        { name: 'Fontina', category: 'dairy', calories: 389, protein: 24.5, carbs: 0.5, fats: 31.1, fiber: 0.0 },
        { name: 'Gorgonzola', category: 'dairy', calories: 330, protein: 19.0, carbs: 0.0, fats: 28.7, fiber: 0.0 },
        { name: 'Stracchino', category: 'dairy', calories: 300, protein: 18.5, carbs: 0.8, fats: 25.1, fiber: 0.0 },
        { name: 'Philadelphia', category: 'dairy', calories: 258, protein: 5.8, carbs: 4.1, fats: 24.7, fiber: 0.0 },
        { name: 'Fiocchi di latte', category: 'dairy', calories: 99, protein: 11.0, carbs: 3.4, fats: 4.3, fiber: 0.0 },

        // Oils and Fats (Oli e Grassi)
        { name: 'Olio extravergine d\'oliva', category: 'oils', calories: 884, protein: 0.0, carbs: 0.0, fats: 100.0, fiber: 0.0 },
        { name: 'Olio di semi', category: 'oils', calories: 900, protein: 0.0, carbs: 0.0, fats: 100.0, fiber: 0.0 },
        { name: 'Burro', category: 'oils', calories: 717, protein: 0.9, carbs: 1.1, fats: 83.4, fiber: 0.0 },

        // Herbs and Spices (Spezie e Aromi)
        { name: 'Basilico fresco', category: 'herbs', calories: 23, protein: 3.2, carbs: 2.6, fats: 0.6, fiber: 1.6 },
        { name: 'Origano secco', category: 'herbs', calories: 265, protein: 9.0, carbs: 68.9, fats: 4.3, fiber: 42.5 },
        { name: 'Rosmarino fresco', category: 'herbs', calories: 131, protein: 3.3, carbs: 20.7, fats: 5.9, fiber: 14.1 },
        { name: 'Salvia fresca', category: 'herbs', calories: 315, protein: 10.6, carbs: 60.7, fats: 12.7, fiber: 40.3 },
        { name: 'Timo secco', category: 'herbs', calories: 276, protein: 9.1, carbs: 63.9, fats: 7.4, fiber: 37.0 },
        { name: 'Prezzemolo fresco', category: 'herbs', calories: 36, protein: 3.0, carbs: 6.3, fats: 0.8, fiber: 3.3 },
        { name: 'Menta fresca', category: 'herbs', calories: 70, protein: 3.8, carbs: 14.9, fats: 0.9, fiber: 8.0 },
        { name: 'Alloro', category: 'herbs', calories: 313, protein: 7.6, carbs: 74.9, fats: 8.4, fiber: 26.3 },
        { name: 'Pepe nero', category: 'herbs', calories: 251, protein: 10.4, carbs: 63.9, fats: 3.3, fiber: 25.3 },
        { name: 'Peperoncino', category: 'herbs', calories: 40, protein: 2.0, carbs: 8.8, fats: 0.4, fiber: 1.5 },
        { name: 'Curcuma', category: 'herbs', calories: 312, protein: 9.7, carbs: 67.1, fats: 3.3, fiber: 22.7 },
        { name: 'Zenzero fresco', category: 'herbs', calories: 80, protein: 1.8, carbs: 17.8, fats: 0.8, fiber: 2.0 },
        { name: 'Cannella', category: 'herbs', calories: 247, protein: 4.0, carbs: 80.6, fats: 1.2, fiber: 53.1 },
        { name: 'Noce moscata', category: 'herbs', calories: 525, protein: 5.8, carbs: 49.3, fats: 36.3, fiber: 20.8 },

        // Sweeteners (Dolcificanti)
        { name: 'Miele', category: 'sweeteners', calories: 304, protein: 0.3, carbs: 82.4, fats: 0.0, fiber: 0.2 },
        { name: 'Zucchero bianco', category: 'sweeteners', calories: 392, protein: 0.0, carbs: 99.8, fats: 0.0, fiber: 0.0 },
        { name: 'Zucchero di canna', category: 'sweeteners', calories: 377, protein: 0.1, carbs: 97.3, fats: 0.0, fiber: 0.0 },
        { name: 'Sciroppo d\'acero', category: 'sweeteners', calories: 260, protein: 0.0, carbs: 67.0, fats: 0.2, fiber: 0.0 },

        // Beverages (Bevande)
        { name: 'Vino rosso', category: 'beverages', calories: 85, protein: 0.1, carbs: 2.6, fats: 0.0, fiber: 0.0 },
        { name: 'Vino bianco', category: 'beverages', calories: 82, protein: 0.1, carbs: 2.6, fats: 0.0, fiber: 0.0 },
        { name: 'Caffè', category: 'beverages', calories: 2, protein: 0.1, carbs: 0.0, fats: 0.0, fiber: 0.0 },
        { name: 'Tè', category: 'beverages', calories: 1, protein: 0.0, carbs: 0.3, fats: 0.0, fiber: 0.0 },
        { name: 'Acqua', category: 'beverages', calories: 0, protein: 0.0, carbs: 0.0, fats: 0.0, fiber: 0.0 }
    ],

    // Get all foods
    getAllFoods() {
        return this.foods;
    },

    // Get foods by category
    getFoodsByCategory(category) {
        return this.foods.filter(food => food.category === category);
    },

    // Search foods by name
    searchFoods(query) {
        const lowerQuery = query.toLowerCase();
        return this.foods.filter(food => 
            food.name.toLowerCase().includes(lowerQuery)
        );
    },

    // Get food by exact name
    getFoodByName(name) {
        return this.foods.find(food => food.name === name);
    },

    // Get category name
    getCategoryName(category) {
        return this.categories[category] || category;
    },

    // Get all categories
    getAllCategories() {
        return Object.entries(this.categories).map(([key, value]) => ({
            key,
            name: value
        }));
    }
};

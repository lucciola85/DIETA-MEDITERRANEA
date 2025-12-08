# 🌊 Piattaforma Dieta Mediterranea & Allenamento Personale

Una piattaforma web completa per la gestione di una dieta mediterranea personalizzata e una scheda di allenamento casalingo. Funziona completamente **offline** e salva tutti i dati localmente.

## ✨ Caratteristiche Principali

### 🎯 Gestione Multi-Profilo
- Crea e gestisci più profili per diverse persone
- Ogni profilo è completamente indipendente
- Elimina o modifica profili esistenti

### 📊 Scheda Personale
- Nome, età, sesso
- Altezza e peso
- **Calcolo automatico del BMI** basato su genere, altezza e peso
- Indicazione se pratica attività sportiva

### 🔢 Calcolo Automatico dei Macro
- **TDEE** (Total Daily Energy Expenditure) con formula Mifflin-St Jeor
- Deficit calorico sicuro per perdita di 1 kg/settimana
- Distribuzione macro secondo la Dieta Mediterranea:
  - **Carboidrati**: 50-55% delle calorie
  - **Proteine**: 15-20% (minimo 1.2g/kg per preservare massa muscolare)
  - **Grassi**: 25-30% delle calorie

### 🍽️ Pianificatore Pasti Intelligente
- **5 pasti giornalieri** con distribuzione calorica ottimale:
  - Colazione: 20-25%
  - Spuntino mattina: 5-10%
  - Pranzo: 35-40%
  - Merenda: 5-10%
  - Cena: 20-25%
- **Calcolo automatico delle porzioni**: seleziona gli alimenti e la piattaforma calcola automaticamente la grammatura esatta in grammi per rispettare i macro del pasto
- Pianificazione settimanale (7 giorni)
- Verifica rispetto dei target giornalieri

### 🥗 Database Alimenti Mediterranei
- **530+ alimenti** della tradizione mediterranea
- 13 categorie (verdure, frutta, cereali, pesce, carni, latticini, etc.)
- Valori nutrizionali completi per 100g
- Ricerca e filtri per categoria

### 🛒 Lista della Spesa Automatica
- Generazione automatica dalla pianificazione settimanale
- Aggregazione delle quantità per alimento
- Esportazione in formato testo
- Raggruppamento per categoria

### ⚖️ Monitoraggio Peso
- Registrazione peso settimanale
- **Grafico evoluzione** con visualizzazione trend
- Calcolo variazione totale e media settimanale
- Storico completo delle pesate

### 💪 Scheda Allenamento Personale
- **3 livelli di difficoltà**: Principiante, Intermedio, Avanzato
- Esercizi con:
  - Manubri (0.5kg, 1kg, 2kg)
  - **Panca Piana** (NUOVO)
  - Tapis Roulant
  - Elastici (leggera, media, forte resistenza)
  - Corpo libero
- Schede settimanali complete con descrizioni dettagliate
- Timer e tracciamento completamento esercizi

### 💾 Backup e Sicurezza
- Salvataggio automatico su LocalStorage
- Export/Import completo in formato JSON
- Funzionamento **100% offline** dopo primo caricamento
- Nessun dato inviato a server esterni

## 🚀 Come Iniziare

1. **Apri `index.html`** nel browser (Chrome, Firefox, Safari, Edge)
2. **Crea un profilo** inserendo i tuoi dati personali
3. La piattaforma calcolerà automaticamente:
   - Il tuo BMI
   - Il tuo TDEE
   - I tuoi macro giornalieri
4. **Pianifica i tuoi pasti** selezionando gli alimenti
   - La piattaforma calcola automaticamente le porzioni in grammi!
5. **Registra il tuo peso** ogni settimana
6. **Segui la scheda di allenamento** personalizzata

## 📱 Installazione come PWA

La piattaforma può essere installata come app sul tuo dispositivo:

1. **Desktop**: Clicca sull'icona "Installa" nella barra degli indirizzi
2. **Mobile**: Menu → "Aggiungi a schermata Home"

## 🏗️ Struttura del Progetto

```
/
├── index.html              # Pagina principale
├── manifest.json          # Configurazione PWA
├── sw.js                  # Service Worker per offline
├── css/
│   └── style.css          # Stili completi
└── js/
    ├── app.js             # Logica principale e UI
    ├── storage.js         # Gestione LocalStorage e IndexedDB
    ├── database.js        # Database 530+ alimenti
    ├── profiles.js        # Gestione profili
    ├── nutrition.js       # Calcoli nutrizionali e TDEE
    ├── meals.js           # Pianificatore pasti
    ├── workout.js         # Scheda allenamento
    └── charts.js          # Grafici peso
```

## 🎨 Design

- Palette colori ispirata al Mediterraneo
- Design responsive per mobile e desktop
- Interfaccia intuitiva in italiano
- Grafici e statistiche visivamente accattivanti

## 🔒 Privacy e Sicurezza

- **Tutti i dati rimangono sul tuo dispositivo**
- Nessuna connessione a server esterni
- Nessun tracciamento o analytics
- Backup completo esportabile

## 💡 Funzionalità Avanzate

### Calcolo Automatico Porzioni
Quando componi un pasto (es. colazione), **NON devi calcolare le grammature**:
1. Seleziona gli alimenti che vuoi mangiare
2. La piattaforma calcola automaticamente le porzioni esatte in grammi
3. Le porzioni rispettano i macro target del pasto (es. 20-25% per colazione)
4. Tutto espresso in GRAMMI per evitare errori

### Sicurezza Nutrizionale
- Il deficit calorico non scende mai sotto il metabolismo basale
- Avvisi se il deficit è troppo aggressivo
- Proteine sempre ≥ 1.2g/kg per preservare massa muscolare

### Allenamento Intelligente
- Se NON pratichi sport → livello PRINCIPIANTE automatico
- Progressione nel tempo con settimane raccomandate per livello
- Include la **Panca Piana** per esercizi più completi

## 🛠️ Tecnologie Utilizzate

- **HTML5** - Struttura
- **CSS3** - Stili e responsive design
- **JavaScript Vanilla** - Logica (nessun framework)
- **LocalStorage** - Dati persistenti semplici
- **IndexedDB** - Database locale strutturato
- **Service Worker** - Funzionamento offline
- **PWA** - Installabile come app

## 📄 Licenza

Questo progetto è open source e disponibile per uso personale.

## 🙏 Contributi

Contributi, issues e feature requests sono benvenuti!

---

**Fatto con ❤️ per una vita più sana con la Dieta Mediterranea** 🌊🍇🥗

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

    // Exercise database with detailed explanations
    exercises: {
        // Dumbbell exercises
        bicepCurls: {
            name: 'Curl Bicipiti con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Braccia',
            description: 'Esercizio di isolamento per i bicipiti',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/dumbbell-bicep-curl.gif',
            videos: {
                it: 'https://www.youtube.com/embed/ykJmrZ5v0Oo',
                en: 'https://www.youtube.com/embed/ykJmrZ5v0Oo'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, gambe larghezza spalle, schiena dritta
• Manubri ai lati del corpo con palmi rivolti in avanti (presa supina)
• Gomiti leggermente davanti al corpo, vicini ai fianchi
• Core attivato, spalle rilassate

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Fletti i gomiti portando i manubri verso le spalle
   - Mantieni i gomiti fissi nella posizione iniziale
   - Contrai i bicipiti nella fase finale del movimento
   - Evita di oscillare il corpo o usare lo slancio
2. PAUSA (1 secondo): Mantieni la contrazione massima in cima al movimento
3. FASE ECCENTRICA (3 secondi): Abbassa i manubri lentamente fino alla posizione iniziale
   - Controlla la discesa senza far cadere i pesi
   - Non estendere completamente il gomito per mantenere tensione

<strong>RESPIRAZIONE:</strong>
• Espira durante la fase di salita (contrazione)
• Inspira durante la fase di discesa (allungamento)

<strong>ERRORI COMUNI:</strong>
✗ Oscillare il corpo per dare slancio
✗ Sollevare le spalle durante il movimento
✗ Muovere i gomiti avanti e indietro
✗ Scendere troppo velocemente

<strong>VARIANTI:</strong>
• Curl alternati (un braccio alla volta)
• Curl a martello (palmi rivolti verso il corpo)
• Curl concentrato (seduti, gomito appoggiato)`,
            tempo: '2-1-3-0', // Concentrica-Pausa-Eccentrica-Riposo
            restBetweenSets: 45
        },
        tricepExtension: {
            name: 'Estensioni Tricipiti',
            equipment: 'dumbbells',
            muscleGroup: 'Braccia',
            description: 'Esercizio di isolamento per i tricipiti',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/10/dumbbell-overhead-tricep-extension.gif',
            videos: {
                it: 'https://www.youtube.com/embed/nRiJVZDpdL0',
                en: 'https://www.youtube.com/embed/nRiJVZDpdL0'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi o seduti, schiena dritta
• Un manubrio tenuto con entrambe le mani sopra la testa
• Gomiti piegati, manubrio dietro la nuca
• Gomiti rivolti verso l'alto, vicini alle orecchie

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Estendi i gomiti portando il manubrio sopra la testa
   - Mantieni i gomiti fissi e vicini alla testa
   - Estendi completamente le braccia contraendo i tricipiti
2. PAUSA (1 secondo): Mantieni la contrazione in alto
3. FASE ECCENTRICA (3 secondi): Abbassa lentamente il manubrio dietro la nuca
   - Controlla la discesa mantenendo i gomiti fermi

<strong>RESPIRAZIONE:</strong>
• Espira durante l'estensione (salita)
• Inspira durante la flessione (discesa)

<strong>ERRORI COMUNI:</strong>
✗ Allargare i gomiti durante il movimento
✗ Inarcare la schiena
✗ Usare un peso eccessivo
✗ Movimento brusco e senza controllo

<strong>VARIANTI:</strong>
• Kickback con manubri (piegati in avanti)
• Estensioni con elastico
• French press su panca`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        shoulderPress: {
            name: 'Spalle con Manubri (Military Press)',
            equipment: 'dumbbells',
            muscleGroup: 'Spalle',
            description: 'Esercizio composto per deltoidi anteriori e mediali',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/dumbbell-shoulder-press.gif',
            videos: {
                it: 'https://www.youtube.com/embed/qEwKCR5JCog',
                en: 'https://www.youtube.com/embed/qEwKCR5JCog'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi o seduti con supporto lombare
• Manubri all'altezza delle spalle, gomiti a 90°
• Palmi rivolti in avanti
• Schiena dritta, core attivato

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Spingi i manubri verso l'alto
   - Estendi le braccia sopra la testa
   - Non bloccare completamente i gomiti
   - I manubri si avvicinano leggermente in alto
2. PAUSA (1 secondo): Mantieni la posizione con controllo
3. FASE ECCENTRICA (3 secondi): Abbassa i manubri alle spalle
   - Controlla la discesa fino a gomiti a 90°
   - Mantieni sempre tensione sui deltoidi

<strong>RESPIRAZIONE:</strong>
• Espira durante la spinta verso l'alto
• Inspira durante la discesa

<strong>ERRORI COMUNI:</strong>
✗ Inarcare eccessivamente la schiena
✗ Usare lo slancio delle gambe
✗ Portare i manubri troppo avanti o indietro
✗ Bloccare completamente i gomiti

<strong>VARIANTI:</strong>
• Arnold Press (rotazione dei polsi)
• Shoulder Press con bilanciere
• Military Press in piedi`,
            tempo: '2-1-3-0',
            restBetweenSets: 60
        },
        lateralRaises: {
            name: 'Alzate Laterali',
            equipment: 'dumbbells',
            muscleGroup: 'Spalle',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/dumbbell-lateral-raise.gif',
            description: 'Isolamento per deltoidi mediali',
            videos: {
                it: 'https://www.youtube.com/embed/3VcKaXpzqRo',
                en: 'https://www.youtube.com/embed/3VcKaXpzqRo'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, gambe leggermente divaricate
• Manubri ai lati del corpo
• Gomiti leggermente flessi (10-15°)
• Busto leggermente inclinato in avanti (5-10°)

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Solleva i manubri lateralmente
   - Mantieni i gomiti leggermente flessi
   - Solleva fino all'altezza delle spalle
   - I mignoli leggermente più in alto dei pollici
2. PAUSA (1 secondo): Mantieni la posizione di massima contrazione
3. FASE ECCENTRICA (3 secondi): Abbassa i manubri lentamente
   - Controlla la discesa senza far cadere i pesi
   - Non toccare completamente i fianchi per mantenere tensione

<strong>RESPIRAZIONE:</strong>
• Espira durante la fase di alzata
• Inspira durante la discesa

<strong>ERRORI COMUNI:</strong>
✗ Usare pesi troppo pesanti
✗ Sollevare sopra l'altezza delle spalle
✗ Oscillare il corpo per dare slancio
✗ Sollevare le spalle (trapezi)

<strong>VARIANTI:</strong>
• Alzate frontali
• Alzate laterali con elastico
• Alzate su panca inclinata`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        chestPress: {
            name: 'Chest Press con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Petto',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/dumbbell-chest-press.gif',
            description: 'Esercizio composto per pettorali, deltoidi anteriori e tricipiti',
            videos: {
                it: 'https://www.youtube.com/embed/VmB1G1K7v94',
                en: 'https://www.youtube.com/embed/VmB1G1K7v94'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiati sulla panca piana
• Piedi ben appoggiati a terra
• Schiena aderente alla panca, leggero arco lombare naturale
• Manubri all'altezza del petto, gomiti a 90°
• Scapole retratte (spalle indietro)

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Spingi i manubri verso l'alto
   - Estendi le braccia sopra il petto
   - I manubri si avvicinano leggermente in alto
   - Non bloccare completamente i gomiti
2. PAUSA (1 secondo): Mantieni la contrazione in alto
3. FASE ECCENTRICA (3 secondi): Abbassa i manubri al petto
   - Controlla la discesa fino a gomiti a 90°
   - Senti lo stretching del pettorale

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la spinta verso l'alto

<strong>ERRORI COMUNI:</strong>
✗ Sollevare i piedi da terra
✗ Inarcare eccessivamente la schiena
✗ Rimbalzare i pesi sul petto
✗ Perdere la retrazione scapolare

<strong>VARIANTI:</strong>
• Chest press con bilanciere
• Push-up (corpo libero)
• Chest press con elastico`,
            tempo: '2-1-3-0',
            restBetweenSets: 60
        },
        chestFly: {
            name: 'Aperture con Manubri (Chest Fly)',
            equipment: 'dumbbells',
            muscleGroup: 'Petto',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/dumbbell-chest-fly.gif',
            description: 'Isolamento per pettorali',
            videos: {
                it: 'https://www.youtube.com/embed/eozdVDA78K0',
                en: 'https://www.youtube.com/embed/eozdVDA78K0'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiati sulla panca piana
• Braccia estese sopra il petto
• Gomiti leggermente flessi (10-20°)
• Palmi rivolti uno verso l'altro
• Scapole retratte

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (3 secondi): Apri le braccia lateralmente
   - Mantieni i gomiti leggermente flessi
   - Scendi fino a sentire lo stretching del pettorale
   - Non andare oltre la linea delle spalle
2. PAUSA (1 secondo): Mantieni lo stretching controllato
3. FASE CONCENTRICA (2 secondi): Chiudi le braccia sopra il petto
   - Contrai i pettorali portando i manubri a toccarsi
   - Mantieni l'angolo dei gomiti costante

<strong>RESPIRAZIONE:</strong>
• Inspira durante l'apertura
• Espira durante la chiusura

<strong>ERRORI COMUNI:</strong>
✗ Piegare troppo i gomiti (diventa una press)
✗ Scendere troppo (rischio spalle)
✗ Usare pesi troppo pesanti
✗ Movimento rapido e incontrollato

<strong>VARIANTI:</strong>
• Fly con elastico
• Fly su panca inclinata
• Cable crossover`,
            tempo: '3-1-2-0',
            restBetweenSets: 60
        },
        bentOverRow: {
            name: 'Rematore con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Schiena',
            description: 'Esercizio composto per dorsali, romboidi e trapezi',
            videos: {
                it: 'https://www.youtube.com/embed/roCP6wCXPqo',
                en: 'https://www.youtube.com/embed/roCP6wCXPqo'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Piedi larghezza spalle, ginocchia leggermente piegate
• Busto inclinato in avanti a 45-60°
• Schiena dritta, naturale curva lombare
• Manubri davanti al corpo, braccia estese
• Sguardo rivolto leggermente in avanti

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Tira i manubri verso il busto
   - Porta i gomiti indietro e in alto
   - Contrai le scapole insieme
   - I manubri raggiungono i fianchi/addome basso
2. PAUSA (1 secondo): Mantieni la contrazione delle scapole
3. FASE ECCENTRICA (3 secondi): Abbassa i manubri
   - Estendi le braccia controllando il peso
   - Senti lo stretching del dorsale

<strong>RESPIRAZIONE:</strong>
• Espira durante la trazione verso il corpo
• Inspira durante il rilascio

<strong>ERRORI COMUNI:</strong>
✗ Ruotare il busto durante il movimento
✗ Usare lo slancio per sollevare i pesi
✗ Sollevare le spalle invece di retrarre le scapole
✗ Inarcare o incurvare la schiena

<strong>VARIANTI:</strong>
• Rematore a un braccio con supporto
• Rematore con bilanciere
• Rematore con elastico`,
            tempo: '2-1-3-0',
            restBetweenSets: 60
        },
        dumbbellSquat: {
            name: 'Squat con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Gambe',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/dumbbell-squat.gif',
            description: 'Esercizio composto per quadricipiti, glutei e core',
            videos: {
                it: 'https://www.youtube.com/embed/aclHkVaku9U',
                en: 'https://www.youtube.com/embed/aclHkVaku9U'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, piedi larghezza spalle o leggermente più larghi
• Punte dei piedi leggermente ruotate verso l'esterno (10-15°)
• Manubri ai lati del corpo o sulle spalle
• Schiena dritta, petto in fuori, core attivato
• Sguardo in avanti o leggermente verso l'alto

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (3 secondi): Scendi come per sederti
   - Piega ginocchia e anche contemporaneamente
   - Mantieni il peso sui talloni
   - Ginocchia in linea con le punte dei piedi
   - Scendi fino a cosce parallele al suolo o più in basso
2. PAUSA (1 secondo): Mantieni la posizione più bassa
3. FASE CONCENTRICA (2 secondi): Spingi verso l'alto
   - Spingi attraverso i talloni
   - Estendi ginocchia e anche
   - Contrai glutei in alto

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la salita

<strong>ERRORI COMUNI:</strong>
✗ Ginocchia che superano troppo le punte dei piedi
✗ Sollevare i talloni da terra
✗ Inarcare o incurvare la schiena
✗ Scendere troppo velocemente

<strong>VARIANTI:</strong>
• Goblet squat (manubrio al petto)
• Squat bulgaro (una gamba)
• Squat a corpo libero`,
            tempo: '3-1-2-0',
            restBetweenSets: 90
        },
        dumbbellLunges: {
            name: 'Affondi con Manubri',
            equipment: 'dumbbells',
            muscleGroup: 'Gambe',
            description: 'Esercizio unilaterale per gambe e glutei',
            videos: {
                it: 'https://www.youtube.com/embed/QOVaHwm-Q6U',
                en: 'https://www.youtube.com/embed/QOVaHwm-Q6U'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, piedi larghezza anche
• Manubri ai lati del corpo
• Schiena dritta, core attivato
• Sguardo in avanti

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (2 secondi): Fai un passo avanti
   - Gamba avanti: ginocchio a 90°, coscia parallela al suolo
   - Gamba dietro: ginocchio scende verso il pavimento
   - Mantieni il busto eretto
   - Non appoggiare il ginocchio a terra
2. PAUSA (1 secondo): Mantieni la posizione di affondo
3. FASE CONCENTRICA (2 secondi): Spingi per tornare su
   - Spingi attraverso il tallone della gamba avanti
   - Torna alla posizione di partenza
4. RIPOSO (1 secondo): Prepara l'altra gamba

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la spinta verso l'alto

<strong>ERRORI COMUNI:</strong>
✗ Ginocchio che supera la punta del piede
✗ Inclinarsi in avanti con il busto
✗ Passo troppo corto o troppo lungo
✗ Perdere l'equilibrio

<strong>VARIANTI:</strong>
• Affondi camminati
• Affondi inversi
• Affondi laterali
• Affondi bulgari (piede posteriore su panca)`,
            tempo: '2-1-2-1',
            restBetweenSets: 60
        },

        // Bench exercises (Panca Piana)
        benchPress: {
            name: 'Distensioni su Panca con Manubri',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Esercizio fondamentale per pettorali su panca piana',
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiati sulla panca piana, schiena aderente
• Piedi ben piantati a terra per stabilità
• Scapole retratte (spalle indietro e in basso)
• Manubri all'altezza del petto, gomiti a 90°
• Leggero arco lombare naturale

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Spingi i manubri verso l'alto
   - Estendi le braccia sopra il petto centrale
   - I manubri si avvicinano leggermente in alto
   - Non bloccare completamente i gomiti
   - Mantieni le scapole retratte
2. PAUSA (1 secondo): Contrai i pettorali in alto
3. FASE ECCENTRICA (3 secondi): Abbassa controllando il peso
   - Porta i gomiti a 90° o leggermente sotto
   - Senti lo stretching del pettorale
   - Non rimbalzare i pesi sul petto

<strong>RESPIRAZIONE:</strong>
• Inspira profondamente durante la discesa
• Espira durante la spinta esplosiva

<strong>ERRORI COMUNI:</strong>
✗ Sollevare i piedi dalla pedana
✗ Perdere la retrazione scapolare
✗ Rimbalzare i pesi sul petto
✗ Inarcare eccessivamente la schiena

<strong>VARIANTI:</strong>
• Panca inclinata (enfasi pettorale alto)
• Panca declinata (enfasi pettorale basso)
• Press con bilanciere`,
            tempo: '2-1-3-0',
            restBetweenSets: 60
        },
        benchFly: {
            name: 'Croci su Panca',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Isolamento pettorali su panca piana',
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiati sulla panca piana
• Piedi ben piantati a terra
• Scapole retratte
• Braccia estese sopra il petto
• Gomiti leggermente flessi (10-20°)
• Palmi rivolti uno verso l'altro

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (3-4 secondi): Apri le braccia lateralmente
   - Mantieni l'angolo dei gomiti costante
   - Scendi controllando fino al piano della panca
   - Senti lo stretching profondo del pettorale
   - Non scendere oltre la linea delle spalle
2. PAUSA (1-2 secondi): Mantieni lo stretching controllato
3. FASE CONCENTRICA (2 secondi): Chiudi le braccia
   - Contrai intensamente i pettorali
   - Porta i manubri a toccarsi sopra il petto
   - Mantieni sempre gomiti leggermente flessi

<strong>RESPIRAZIONE:</strong>
• Inspira profondamente durante l'apertura
• Espira durante la chiusura

<strong>ERRORI COMUNI:</strong>
✗ Piegare troppo i gomiti (diventa press)
✗ Usare pesi troppo pesanti
✗ Scendere troppo (stress spalle)
✗ Movimento rapido e incontrollato

<strong>VARIANTI:</strong>
• Croci su panca inclinata
• Croci con cavi (cable crossover)`,
            tempo: '3-2-2-0',
            restBetweenSets: 60
        },
        inclineBenchPress: {
            name: 'Distensioni su Panca Inclinata',
            equipment: 'bench',
            muscleGroup: 'Petto',
            description: 'Enfasi sul pettorale alto e deltoidi anteriori',
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Panca inclinata 30-45° (ottimale per pettorale alto)
• Sdraiati con schiena aderente
• Piedi ben piantati a terra
• Scapole retratte
• Manubri all'altezza del petto superiore

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Spingi i manubri verso l'alto
   - Traiettoria leggermente verso la testa
   - Estendi le braccia senza bloccare i gomiti
2. PAUSA (1 secondo): Contrazione in alto
3. FASE ECCENTRICA (3 secondi): Abbassa controllando
   - Porta i gomiti a 90°
   - Mantieni controllo totale

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la spinta

<strong>ERRORI COMUNI:</strong>
✗ Inclinazione eccessiva (>45° enfatizza spalle)
✗ Perdere l'appoggio dei piedi
✗ Movimento troppo rapido`,
            tempo: '2-1-3-0',
            restBetweenSets: 60
        },

        // Treadmill exercises
        treadmillWalk: {
            name: 'Camminata Veloce',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Camminata aerobica a passo sostenuto',
            detailedDescription: `
<strong>IMPOSTAZIONI:</strong>
• Velocità: 5-6.5 km/h
• Inclinazione: 0-2%
• Frequenza cardiaca target: 60-70% FCmax

<strong>ESECUZIONE:</strong>
• Postura eretta, spalle rilassate
• Braccia piegate a 90°, movimento naturale
• Appoggio tallone-punta del piede
• Passo lungo e deciso
• Respirazione ritmica e profonda

<strong>WARM-UP (primi 3 min):</strong>
• Inizia a velocità ridotta (4 km/h)
• Aumenta gradualmente fino alla velocità target

<strong>FASE PRINCIPALE:</strong>
• Mantieni velocità costante
• Respira col naso, espira con la bocca
• Ogni 5 minuti bevi un sorso d'acqua

<strong>COOL-DOWN (ultimi 2-3 min):</strong>
• Riduci gradualmente la velocità
• Termina con stretching gambe

<strong>BENEFICI:</strong>
✓ Brucia calorie (circa 200-300 in 30 min)
✓ Migliora salute cardiovascolare
✓ Basso impatto sulle articolazioni
✓ Ideale per principianti`,
            tempo: 'N/A',
            restBetweenSets: 0
        },
        treadmillJog: {
            name: 'Corsa Leggera',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Corsa a ritmo moderato',
            detailedDescription: `
<strong>IMPOSTAZIONI:</strong>
• Velocità: 7-9 km/h
• Inclinazione: 0-1%
• Frequenza cardiaca target: 70-80% FCmax

<strong>ESECUZIONE:</strong>
• Postura eretta, leggera inclinazione in avanti
• Braccia piegate a 90°, movimento ritmico
• Appoggio mesopiede, falcata media
• Respirazione ritmica 3:3 (3 passi inspira, 3 espira)

<strong>WARM-UP (5 min):</strong>
• 2 min camminata veloce (5 km/h)
• 3 min aumento graduale fino a velocità target

<strong>FASE PRINCIPALE:</strong>
• Mantieni ritmo costante e sostenibile
• Monitora frequenza cardiaca
• Puoi parlare ma con qualche difficoltà
• Idratati ogni 10 minuti

<strong>COOL-DOWN (5 min):</strong>
• 3 min riduzione graduale velocità
• 2 min camminata lenta

<strong>BENEFICI:</strong>
✓ Brucia 400-600 kcal in 30 min
✓ Migliora resistenza aerobica
✓ Rinforza sistema cardio-respiratorio`,
            tempo: 'N/A',
            restBetweenSets: 0
        },
        treadmillHIIT: {
            name: 'HIIT Tapis Roulant',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Allenamento intervallato ad alta intensità',
            detailedDescription: `
<strong>IMPOSTAZIONI SPRINT:</strong>
• Velocità: 11-14 km/h (80-90% sforzo massimo)
• Durata: 30-45 secondi

<strong>IMPOSTAZIONI RECUPERO:</strong>
• Velocità: 4-5 km/h (camminata)
• Durata: 60-90 secondi

<strong>PROTOCOLLO COMPLETO:</strong>
1. WARM-UP (5 min):
   - 3 min camminata (5 km/h)
   - 2 min corsa leggera (7 km/h)

2. FASE HIIT (ripeti 6-10 volte):
   - SPRINT (30-45 sec): Velocità massima sostenibile
     • Respira intensamente
     • Mantieni la forma corretta
     • Braccia attive
   - RECUPERO ATTIVO (60-90 sec): Camminata
     • Respira profondamente per recuperare
     • Non fermarti completamente

3. COOL-DOWN (5 min):
   - Riduzione graduale intensità
   - Camminata lenta finale

<strong>RESPIRAZIONE:</strong>
• Durante sprint: respira come serve, anche con la bocca
• Durante recupero: respira profondamente col naso

<strong>ERRORI COMUNI:</strong>
✗ Partire troppo veloce
✗ Non recuperare abbastanza
✗ Saltare il warm-up
✗ Fermarsi completamente tra gli sprint

<strong>BENEFICI:</strong>
✓ Massimo consumo calorico (500-800 kcal in 20-30 min)
✓ Effetto EPOC (brucia calorie fino a 24h dopo)
✓ Migliora VO2max
✓ Risparmio tempo`,
            tempo: 'N/A',
            restBetweenSets: 0
        },
        treadmillIncline: {
            name: 'Camminata in Salita',
            equipment: 'treadmill',
            muscleGroup: 'Cardio',
            description: 'Camminata con inclinazione per glutei e gambe',
            detailedDescription: `
<strong>IMPOSTAZIONI:</strong>
• Velocità: 4.5-6 km/h
• Inclinazione: 8-15%
• Frequenza cardiaca: 65-75% FCmax

<strong>ESECUZIONE:</strong>
• Postura eretta, non aggrapparsi ai corrimano
• Leggera inclinazione del busto in avanti (5-10°)
• Appoggio tallone-punta deciso
• Passo completo senza accorciare la falcata
• Braccia attive nel movimento

<strong>PROTOCOLLO:</strong>
1. WARM-UP (3 min):
   - Velocità 4 km/h, inclinazione 0%
   
2. FASE PRINCIPALE (20-30 min):
   - Aumenta inclinazione gradualmente
   - Opzione A: Inclinazione costante
   - Opzione B: Variare inclinazione ogni 3-5 min (8-12-15%)

3. COOL-DOWN (3 min):
   - Riduci inclinazione gradualmente
   - Termina in piano

<strong>MUSCOLI TARGET:</strong>
• Glutei (attivazione >40% rispetto a piano)
• Femorali
• Polpacci
• Core (stabilizzazione)

<strong>BENEFICI:</strong>
✓ Tonifica glutei e gambe
✓ Brucia più calorie del piano (30-50% in più)
✓ Basso impatto articolare
✓ Simula salita naturale`,
            tempo: 'N/A',
            restBetweenSets: 0
        },

        // Elastic band exercises
        elasticChestPress: {
            name: 'Spinte Petto con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Petto',
            description: 'Chest press con resistenza elastico',
            detailedDescription: `
<strong>SETUP:</strong>
• Elastico passato dietro la schiena (altezza petto)
• Impugnature nelle mani
• Un piede avanti per stabilità
• Braccia piegate, gomiti indietro

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Spingi avanti
   - Estendi le braccia davanti al petto
   - Mani si avvicinano ma non si toccano
   - Mantieni tensione sull'elastico
2. PAUSA (1 secondo): Contrai i pettorali
3. FASE ECCENTRICA (3 secondi): Ritorna controllando
   - Resisti alla trazione dell'elastico
   - Non far scattare indietro le braccia

<strong>RESPIRAZIONE:</strong>
• Espira durante la spinta
• Inspira durante il ritorno

<strong>RESISTENZA CONSIGLIATA:</strong>
• Principiante: Leggera (gialla/verde)
• Intermedio: Media (rossa)
• Avanzato: Forte (blu/nera)

<strong>VARIANTI:</strong>
• Spinte alternate
• Spinte dall'alto verso il basso
• Spinte dal basso verso l'alto`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        elasticRow: {
            name: 'Rematore con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Schiena',
            description: 'Trazione orizzontale per dorsali',
            detailedDescription: `
<strong>SETUP:</strong>
• Elastico ancorato davanti (altezza petto)
• Seduti o in piedi
• Braccia estese, impugnature in mano
• Schiena dritta, petto in fuori

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Tira verso il corpo
   - Porta i gomiti indietro
   - Contrai le scapole insieme
   - Gomiti vicini al corpo
2. PAUSA (1-2 secondi): Contrazione massima scapole
3. FASE ECCENTRICA (3 secondi): Estendi controllando
   - Resisti alla trazione dell'elastico
   - Mantieni sempre tensione

<strong>RESPIRAZIONE:</strong>
• Espira durante la trazione
• Inspira durante l'estensione

<strong>PUNTI CHIAVE:</strong>
• Petto sempre in fuori
• Spalle basse e indietro
• Non curvare la schiena
• Movimento fluido e controllato`,
            tempo: '2-2-3-0',
            restBetweenSets: 45
        },
        elasticSquat: {
            name: 'Squat con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Gambe',
            description: 'Squat con resistenza elastica',
            detailedDescription: `
<strong>SETUP:</strong>
• Piedi sull'elastico, larghezza spalle
• Impugnature all'altezza delle spalle
• Elastico teso anche in posizione di partenza

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (3 secondi): Scendi in squat
   - Mantieni tensione sull'elastico
   - Schiena dritta, petto in fuori
   - Scendi fino a cosce parallele
2. PAUSA (1 secondo): Posizione bassa controllata
3. FASE CONCENTRICA (2 secondi): Spingi verso l'alto
   - Estendi attraverso i talloni
   - Combatti la resistenza dell'elastico
   - Contrai glutei in alto

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la salita

<strong>PROGRESSIONE:</strong>
• Aumenta resistenza elastico
• Aggiungi pausa in basso (3-5 sec)
• Squat jump con elastico (avanzato)`,
            tempo: '3-1-2-0',
            restBetweenSets: 60
        },
        elasticBiceps: {
            name: 'Curl Bicipiti con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Braccia',
            description: 'Curl per bicipiti con elastico',
            detailedDescription: `
<strong>SETUP:</strong>
• Piedi al centro dell'elastico
• Impugnature in mano, palmi in avanti
• Gomiti vicini ai fianchi
• Posizione eretta, core attivo

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Fletti i gomiti
   - Porta le mani verso le spalle
   - Gomiti fissi nella posizione
   - Contrai i bicipiti in alto
2. PAUSA (1 secondo): Contrazione massima
3. FASE ECCENTRICA (3 secondi): Abbassa controllando
   - Resisti alla trazione elastico
   - Non estendere completamente

<strong>RESPIRAZIONE:</strong>
• Espira durante la flessione
• Inspira durante l'estensione

<strong>VARIANTI:</strong>
• Curl a martello (palmi verso il corpo)
• Curl alternati
• Curl concentrato (seduto)`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        elasticTriceps: {
            name: 'Estensioni Tricipiti con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Braccia',
            description: 'Estensioni overhead per tricipiti',
            detailedDescription: `
<strong>SETUP:</strong>
• Piede su elastico (o ancoraggio basso)
• Impugnatura dietro la nuca
• Gomiti rivolti verso l'alto
• Posizione stabile

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Estendi i gomiti
   - Porta l'impugnatura sopra la testa
   - Gomiti fermi e vicini alla testa
   - Contrai i tricipiti in alto
2. PAUSA (1 secondo): Contrazione massima
3. FASE ECCENTRICA (3 secondi): Abbassa controllando
   - Resisti alla trazione
   - Mantieni gomiti fissi

<strong>RESPIRAZIONE:</strong>
• Espira durante l'estensione
• Inspira durante la flessione

<strong>VARIANTI:</strong>
• Kickback con elastico
• Estensioni sopra la testa a due mani
• French press con elastico`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        elasticLateralRaise: {
            name: 'Alzate Laterali con Elastico',
            equipment: 'elastics',
            muscleGroup: 'Spalle',
            description: 'Isolamento deltoidi mediali',
            detailedDescription: `
<strong>SETUP:</strong>
• Piedi al centro dell'elastico
• Impugnature in mano ai lati
• Gomiti leggermente flessi
• Posizione stabile

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Solleva lateralmente
   - Porta le braccia all'altezza spalle
   - Gomiti leggermente flessi
   - Mignoli leggermente più in alto
2. PAUSA (1 secondo): Mantieni contrazione
3. FASE ECCENTRICA (3 secondi): Abbassa controllando
   - Resisti alla trazione elastico
   - Non rilasciare completamente

<strong>RESPIRAZIONE:</strong>
• Espira durante l'alzata
• Inspira durante la discesa

<strong>PUNTI CHIAVE:</strong>
• Non sollevare sopra le spalle
• Non usare slancio del corpo
• Mantieni tensione costante`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },

        // Bodyweight exercises
        pushUps: {
            name: 'Flessioni',
            equipment: 'bodyweight',
            muscleGroup: 'Petto',
            description: 'Flessioni classiche a terra',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/push-up.gif',
            videos: {
                it: 'https://www.youtube.com/embed/IODxDxX7oi4',
                en: 'https://www.youtube.com/embed/IODxDxX7oi4'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Posizione plank: mani larghezza spalle o poco più
• Corpo in linea retta dalla testa ai talloni
• Piedi uniti o leggermente divaricati
• Sguardo a terra, circa 30cm avanti alle mani
• Core attivato, glutei contratti

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (2-3 secondi): Scendi verso il pavimento
   - Piega gomiti all'indietro (45° rispetto al corpo)
   - Scendi fino a petto vicino al pavimento
   - Mantieni corpo in linea retta
   - Gomiti non si aprono eccessivamente
2. PAUSA (0-1 secondo): Tocca quasi il pavimento
3. FASE CONCENTRICA (2 secondi): Spingi verso l'alto
   - Estendi completamente le braccia
   - Mantieni sempre core attivo
   - Non inarcare la schiena

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la spinta

<strong>ERRORI COMUNI:</strong>
✗ Bacino che cede verso il basso
✗ Sedere sollevato troppo in alto
✗ Gomiti troppo larghi (stress spalle)
✗ Testa che guarda avanti (stress cervicale)
✗ Movimento parziale

<strong>PROGRESSIONI:</strong>
• Principiante: Push-up sulle ginocchia
• Intermedio: Push-up standard
• Avanzato: Push-up con pausa, diamond push-up, archer push-up
• Molto avanzato: Push-up a una mano, push-up con battito

<strong>VARIANTI:</strong>
• Wide push-up (mani più larghe)
• Diamond push-up (mani unite)
• Decline push-up (piedi rialzati)
• Pike push-up (per spalle)`,
            tempo: '2-1-2-0',
            restBetweenSets: 60
        },
        squats: {
            name: 'Squat a Corpo Libero',
            equipment: 'bodyweight',
            muscleGroup: 'Gambe',
            description: 'Squat fondamentale senza peso',
            videos: {
                it: 'https://www.youtube.com/embed/aclHkVaku9U',
                en: 'https://www.youtube.com/embed/aclHkVaku9U'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Piedi larghezza spalle o poco più
• Punte leggermente ruotate verso l'esterno (10-15°)
• Braccia davanti per bilanciamento
• Schiena dritta, petto in fuori
• Sguardo avanti e leggermente in alto

<strong>ESECUZIONE:</strong>
1. FASE ECCENTRICA (3 secondi): Scendi come per sederti
   - Piega ginocchia e anche simultaneamente
   - Mantieni peso sui talloni (puoi sollevare dita)
   - Ginocchia seguono direzione punte piedi
   - Schiena resta dritta con naturale curva lombare
   - Scendi almeno fino a cosce parallele (più in basso se possibile)
2. PAUSA (1 secondo): Mantieni posizione bassa
3. FASE CONCENTRICA (2 secondi): Spingi attraverso i talloni
   - Estendi ginocchia e anche
   - Mantieni il core attivo
   - Contrai glutei in posizione finale

<strong>RESPIRAZIONE:</strong>
• Inspira profondamente durante la discesa
• Espira durante la salita

<strong>ERRORI COMUNI:</strong>
✗ Ginocchia che collassano verso l'interno
✗ Talloni che si sollevano
✗ Schiena che si incurva
✗ Guardare in basso
✗ Non scendere abbastanza

<strong>TEST MOBILITÀ:</strong>
• Se non riesci a scendere a 90°: lavora su mobilità caviglie/anche
• Se talloni si sollevano: stretching polpacci

<strong>PROGRESSIONI:</strong>
• Principiante: Squat a sedia (assistito)
• Intermedio: Squat completo
• Avanzato: Squat jump, pistol squat (una gamba)`,
            tempo: '3-1-2-0',
            restBetweenSets: 60
        },
        lunges: {
            name: 'Affondi a Corpo Libero',
            equipment: 'bodyweight',
            muscleGroup: 'Gambe',
            description: 'Affondi alternati senza peso',
            videos: {
                it: 'https://www.youtube.com/embed/QOVaHwm-Q6U',
                en: 'https://www.youtube.com/embed/QOVaHwm-Q6U'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, piedi larghezza anche
• Mani sui fianchi o davanti per equilibrio
• Schiena dritta, core attivo

<strong>ESECUZIONE:</strong>
1. Fai un passo avanti (circa 60-90cm)
2. FASE ECCENTRICA (2 secondi): Scendi verticalmente
   - Gamba avanti: ginocchio a 90°, coscia parallela
   - Gamba dietro: ginocchio scende verso terra
   - Mantieni busto eretto
   - Peso distribuito 60% avanti, 40% dietro
3. PAUSA (1 secondo): Ginocchio dietro a 2-3cm da terra
4. FASE CONCENTRICA (2 secondi): Spingi per tornare su
   - Spingi principalmente col tallone della gamba avanti
   - Riporta il piede in posizione di partenza
5. Alterna le gambe

<strong>RESPIRAZIONE:</strong>
• Inspira durante la discesa
• Espira durante la spinta

<strong>PUNTI CHIAVE:</strong>
• Ginocchio avanti non supera la punta del piede
• Busto sempre verticale
• Sguardo avanti
• Movimento controllato

<strong>VARIANTI:</strong>
• Affondi sul posto (senza riportare piede)
• Affondi camminati
• Affondi inversi (passo indietro)
• Affondi laterali
• Affondi con salto (avanzato)`,
            tempo: '2-1-2-0',
            restBetweenSets: 60
        },
        plank: {
            name: 'Plank (Tenuta Isometrica)',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/plank.gif',
            equipment: 'bodyweight',
            muscleGroup: 'Core',
            description: 'Esercizio isometrico per core e stabilità',
            videos: {
                it: 'https://www.youtube.com/embed/ASdvN_XEl_c',
                en: 'https://www.youtube.com/embed/ASdvN_XEl_c'
            },
            detailedDescription: `
<strong>POSIZIONE:</strong>
• Appoggio su avambracci e punte dei piedi
• Gomiti sotto le spalle
• Corpo in linea retta dalla testa ai talloni
• Sguardo a terra tra le mani
• Core completamente attivato
• Glutei contratti
• Gambe tese

<strong>MANTENIMENTO:</strong>
• Respira normalmente (non trattenere il respiro!)
• Inspira col naso, espira con la bocca
• Mantieni tutto il corpo in tensione
• Non far cadere i fianchi
• Non sollevare i glutei troppo in alto
• Pensa a "tirare l'ombelico verso la colonna"

<strong>DURATA:</strong>
• Principiante: 3 x 20-30 secondi
• Intermedio: 3 x 45-60 secondi
• Avanzato: 3 x 60-90 secondi

<strong>QUANDO INTERROMPERE:</strong>
✗ Fianchi che scendono
✗ Schiena che si inarca
✗ Spalle che collassano
✗ Impossibilità di respirare normalmente

<strong>ERRORI COMUNI:</strong>
✗ Trattenere il respiro
✗ Glutei troppo in alto (posizione V)
✗ Fianchi che cedono verso il basso
✗ Spalle che si sollevano verso le orecchie

<strong>PROGRESSIONI:</strong>
• Principiante: Plank sulle ginocchia
• Intermedio: Plank standard
• Avanzato: Plank con sollevamento gamba, plank laterale, plank con tocchi spalle

<strong>BENEFICI:</strong>
✓ Rinforza core completo
✓ Migliora postura
✓ Previene mal di schiena
✓ Migliora stabilità generale`,
            tempo: 'Isometrico',
            restBetweenSets: 45
        },
        crunches: {
            name: 'Crunch Addominali',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/crunch.gif',
            equipment: 'bodyweight',
            muscleGroup: 'Addominali',
            description: 'Crunch classici per addominali',
            videos: {
                it: 'https://www.youtube.com/embed/Xyd_fa5zoEU',
                en: 'https://www.youtube.com/embed/Xyd_fa5zoEU'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiati supini (a pancia in su)
• Ginocchia piegate, piedi appoggiati a terra
• Zona lombare aderente al pavimento
• Mani dietro la nuca (NON intrecciate)
• Mento lontano dal petto (spazio di un pugno)

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Solleva le spalle
   - Contrai gli addominali "arrotolando" il busto
   - Solleva solo le scapole da terra (8-10cm)
   - Zona lombare resta sempre a terra
   - Non tirare la testa con le mani
2. PAUSA (1 secondo): Massima contrazione addominale
3. FASE ECCENTRICA (2 secondi): Scendi controllando
   - Non far cadere le spalle
   - Mantieni tensione sugli addominali
   - Scapole toccano terra ma mantieni contrazione

<strong>RESPIRAZIONE:</strong>
• Espira durante la salita (contrazione)
• Inspira durante la discesa

<strong>ERRORI COMUNI:</strong>
✗ Tirare la testa con le mani
✗ Sollevare troppo (coinvolge flessori anca)
✗ Far scattare il movimento
✗ Staccare la zona lombare da terra
✗ Trattenere il respiro

<strong>PUNTI CHIAVE:</strong>
• Focus sulla contrazione volontaria degli addominali
• Movimento breve e controllato
• Qualità > Quantità
• Se senti dolore al collo: mani incrociate sul petto

<strong>VARIANTI:</strong>
• Crunch inversi (solleva gambe)
• Bicycle crunches (alternati con rotazione)
• Crunch obliqui (per addominali laterali)`,
            tempo: '2-1-2-0',
            restBetweenSets: 45
        },
        mountainClimbers: {
            name: 'Mountain Climbers',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/mountain-climber.gif',
            equipment: 'bodyweight',
            muscleGroup: 'Full Body',
            description: 'Esercizio dinamico cardio e core',
            videos: {
                it: 'https://www.youtube.com/embed/nmwgirgXLYM',
                en: 'https://www.youtube.com/embed/nmwgirgXLYM'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Posizione plank alta (braccia estese)
• Mani sotto le spalle
• Corpo in linea retta
• Core attivato

<strong>ESECUZIONE:</strong>
1. Porta un ginocchio verso il petto
2. Riporta indietro quella gamba
3. Porta avanti l'altro ginocchio
4. Continua alternando rapidamente
5. Mantieni sempre posizione plank con il busto

<strong>RITMO:</strong>
• Principiante: 1 ginocchio al secondo (lento e controllato)
• Intermedio: 2 ginocchia al secondo
• Avanzato: Massima velocità mantenendo forma

<strong>RESPIRAZIONE:</strong>
• Respira ritmicamente
• Non trattenere il respiro
• 2 movimenti = 1 respiro

<strong>ERRORI COMUNI:</strong>
✗ Glutei che si sollevano troppo
✗ Fianchi che oscillano lateralmente
✗ Movimento troppo lento (perde efficacia cardio)
✗ Spalle che collassano in avanti

<strong>DURATA:</strong>
• Serie di 20-30-45 secondi
• Focus su velocità e forma corretta

<strong>BENEFICI:</strong>
✓ Cardio ad alta intensità
✓ Brucia calorie rapidamente
✓ Rinforza core
✓ Migliora coordinazione
✓ Full body workout`,
            tempo: 'N/A - Dinamico',
            restBetweenSets: 60
        },
        burpees: {
            name: 'Burpees',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/burpee.gif',
            equipment: 'bodyweight',
            muscleGroup: 'Full Body',
            description: 'Esercizio completo full body',
            videos: {
                it: 'https://www.youtube.com/embed/TU8QYVW0gDU',
                en: 'https://www.youtube.com/embed/TU8QYVW0gDU'
            },
            detailedDescription: `
<strong>SEQUENZA COMPLETA:</strong>

1. POSIZIONE INIZIALE: In piedi

2. SQUAT (1 secondo):
   - Scendi in squat
   - Mani a terra davanti ai piedi

3. PLANK (1 secondo):
   - Salta o cammina indietro con i piedi
   - Assumi posizione plank

4. PUSH-UP (2 secondi - opzionale):
   - Esegui una flessione completa
   - Petto tocca quasi il pavimento

5. RITORNO (1 secondo):
   - Salta o cammina con i piedi verso le mani
   - Torna in posizione squat

6. SALTO (1 secondo):
   - Salta verso l'alto
   - Braccia sopra la testa
   - Atterra in posizione squat per iniziare il prossimo

<strong>VARIANTI INTENSITÀ:</strong>
• Principiante: Senza push-up, passo indietro invece di salto
• Intermedio: Con push-up, senza salto finale
• Standard: Sequenza completa
• Avanzato: Con push-up esplosivo o burpee box jump

<strong>RESPIRAZIONE:</strong>
• Espira durante push-up
• Inspira durante squat/salto
• Trova il tuo ritmo

<strong>ERRORI COMUNI:</strong>
✗ Posizione plank scorretta
✗ Push-up incompleto
✗ Salto finale assente
✗ Movimento troppo lento (perde efficacia)

<strong>RITMO:</strong>
• Principiante: 6-8 secondi per burpee
• Intermedio: 4-5 secondi per burpee
• Avanzato: 3 secondi per burpee

<strong>BENEFICI:</strong>
✓ Massimo consumo calorico (10-15 kcal/min)
✓ Allenamento full body
✓ Migliora condizionamento
✓ Rinforza tutto il corpo
✓ Nessuna attrezzatura necessaria`,
            tempo: 'N/A - Dinamico',
            restBetweenSets: 90
        },
        jumpingJacks: {
            name: 'Jumping Jacks',
            imageUrl: 'https://www.inspireusafoundation.org/wp-content/uploads/2022/02/jumping-jack.gif',
            equipment: 'bodyweight',
            muscleGroup: 'Cardio',
            description: 'Salti con apertura gambe e braccia',
            videos: {
                it: 'https://www.youtube.com/embed/c4DAnQ6DtF8',
                en: 'https://www.youtube.com/embed/c4DAnQ6DtF8'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, gambe unite
• Braccia lungo i fianchi
• Postura eretta

<strong>ESECUZIONE:</strong>
1. SALTO APERTURA (0.5 secondi):
   - Salta aprendo gambe e braccia
   - Gambe oltre larghezza spalle
   - Braccia sopra la testa (si toccano o quasi)
   - Atterra su avampiede con ginocchia morbide

2. SALTO CHIUSURA (0.5 secondi):
   - Salta richiudendo gambe
   - Riporta braccia ai fianchi
   - Atterra con controllo

3. Continua alternando apertura/chiusura

<strong>RITMO:</strong>
• Principiante: 30-40 jumping jacks al minuto
• Intermedio: 50-60 jumping jacks al minuto
• Avanzato: 60-80 jumping jacks al minuto

<strong>RESPIRAZIONE:</strong>
• Respira ritmicamente
• Ogni 4 movimenti = 1 ciclo respiratorio
• Non trattenere il respiro

<strong>ERRORI COMUNI:</strong>
✗ Atterrare con gambe rigide
✗ Atterrare sui talloni (stress articolazioni)
✗ Braccia che non raggiungono sopra la testa
✗ Movimento scoordinato

<strong>VARIANTI:</strong>
• Low impact: Step side-to-side (senza salti)
• Plank jacks (in posizione plank)
• Star jumps (salto esplosivo)

<strong>UTILIZZO:</strong>
• Warm-up: 2-3 minuti
• HIIT: Serie da 30-60 secondi
• Cardio leggero: 5-10 minuti

<strong>BENEFICI:</strong>
✓ Riscaldamento completo
✓ Attiva tutto il corpo
✓ Migliora coordinazione
✓ Brucia calorie
✓ Adatto a tutti i livelli`,
            tempo: 'N/A - Dinamico',
            restBetweenSets: 30
        },
        highKnees: {
            name: 'High Knees (Ginocchia Alte)',
            equipment: 'bodyweight',
            muscleGroup: 'Cardio',
            description: 'Corsa sul posto portando le ginocchia in alto',
            videos: {
                it: 'https://www.youtube.com/embed/8opcQdC-V-U',
                en: 'https://www.youtube.com/embed/8opcQdC-V-U'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• In piedi, postura eretta
• Piedi larghezza anche
• Braccia piegate a 90°

<strong>ESECUZIONE:</strong>
1. Solleva un ginocchio verso il petto
   - Altezza target: ginocchio all'altezza dell'anca
   - Rimbalza sull'avampiede della gamba di appoggio
2. Riporta il piede a terra
3. Alterna rapidamente le gambe
4. Braccia si muovono in opposizione (come correndo)

<strong>RITMO:</strong>
• Principiante: 60-80 passi al minuto
• Intermedio: 100-120 passi al minuto
• Avanzato: 140-160 passi al minuto

<strong>RESPIRAZIONE:</strong>
• Respira ritmicamente e profondamente
• Non trattenere il respiro
• Ogni 4 passi = 1 respiro

<strong>ERRORI COMUNI:</strong>
✗ Ginocchia troppo basse (sotto 90°)
✗ Inclinare il busto in avanti
✗ Braccia non coordinate
✗ Atterrare sui talloni

<strong>PUNTI CHIAVE:</strong>
• Rimbalza sugli avampiedi
• Mantieni busto eretto
• Core sempre attivo
• Braccia attive nel movimento
• Movimento rapido ed esplosivo

<strong>DURATA:</strong>
• Serie da 20-45 secondi
• 2-4 serie totali

<strong>BENEFICI:</strong>
✓ Cardio ad alta intensità
✓ Rinforza flessori dell'anca
✓ Migliora coordinazione
✓ Brucia calorie rapidamente
✓ Migliora velocità di gambe`,
            tempo: 'N/A - Dinamico',
            restBetweenSets: 60
        },
        legRaises: {
            name: 'Sollevamenti Gambe',
            equipment: 'bodyweight',
            muscleGroup: 'Addominali',
            description: 'Esercizio per addominali bassi',
            videos: {
                it: 'https://www.youtube.com/embed/JB2oyawG9KI',
                en: 'https://www.youtube.com/embed/JB2oyawG9KI'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiato supino (a pancia in su)
• Gambe estese, talloni a terra
• Braccia lungo i fianchi o sotto i glutei per supporto
• Zona lombare aderente al pavimento
• Testa appoggiata

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2-3 secondi): Solleva le gambe
   - Mantieni gambe tese o leggermente piegate
   - Solleva fino a 90° (perpendic al pavimento)
   - NON inarcare la zona lombare
   - Solleva usando gli addominali, non le gambe
2. PAUSA (1 secondo): Mantieni contrazione
3. FASE ECCENTRICA (3-4 secondi): Abbassa controllando
   - Scendi lentamente verso il pavimento
   - Non far cadere le gambe
   - Fermati a 5-10cm da terra (mantieni tensione)
   - Zona lombare sempre a terra

<strong>RESPIRAZIONE:</strong>
• Espira durante la salita
• Inspira durante la discesa

<strong>ERRORI COMUNI:</strong>
✗ Inarcare zona lombare (rischio mal di schiena)
✗ Usare slancio invece di controllo
✗ Piegare troppo le ginocchia
✗ Sollevare con flessori anca invece di addominali

<strong>PROTEZIONE LOMBARE:</strong>
• Se senti tensione lombare: piega leggermente ginocchia
• Mani sotto i glutei per supporto extra
• Non continuare se c'è dolore lombare

<strong>PROGRESSIONI:</strong>
• Principiante: Ginocchia piegate 90°
• Intermedio: Gambe leggermente piegate
• Avanzato: Gambe completamente tese
• Molto avanzato: Tenuta isometrica a 45°

<strong>VARIANTI:</strong>
• Flutter kicks (alternati piccoli)
• Scissors (forbice)
• Leg raises appesi (barra)`,
            tempo: '2-1-3-0',
            restBetweenSets: 45
        },
        gluteBridge: {
            name: 'Ponte Glutei (Glute Bridge)',
            equipment: 'bodyweight',
            muscleGroup: 'Glutei',
            description: 'Esercizio di attivazione glutei',
            videos: {
                it: 'https://www.youtube.com/embed/OUgsJ8-Vi0E',
                en: 'https://www.youtube.com/embed/OUgsJ8-Vi0E'
            },
            detailedDescription: `
<strong>POSIZIONE DI PARTENZA:</strong>
• Sdraiato supino (a pancia in su)
• Ginocchia piegate a 90°, piedi a terra
• Piedi larghezza anche, vicini ai glutei
• Braccia lungo i fianchi, palmi a terra
• Schiena piatta a terra

<strong>ESECUZIONE:</strong>
1. FASE CONCENTRICA (2 secondi): Solleva il bacino
   - Spingi attraverso i talloni
   - Solleva i fianchi verso l'alto
   - Corpo forma linea retta da spalle a ginocchia
   - Contrai intensamente i glutei in alto
   - NON inarcare eccessivamente la schiena
2. PAUSA (1-2 secondi): Massima contrazione glutei
   - Spremi i glutei insieme
   - Mantieni core attivo
3. FASE ECCENTRICA (2-3 secondi): Abbassa controllando
   - Scendi vertebra per vertebra
   - Glutei toccano terra ma mantieni tensione

<strong>RESPIRAZIONE:</strong>
• Espira durante la salita
• Inspira durante la discesa

<strong>PUNTI CHIAVE:</strong>
• Focus sulla contrazione dei glutei
• Non usare la schiena per sollevare
• Mantieni ginocchia allineate (non collassano)
• Peso sui talloni, non sulle punte

<strong>ERRORI COMUNI:</strong>
✗ Inarcare eccessivamente la schiena
✗ Sollevare troppo (sopra linea corpo)
✗ Ginocchia che si aprono o chiudono
✗ Non contrarre i glutei
✗ Usare quadricipiti invece di glutei

<strong>ATTIVAZIONE GLUTEI:</strong>
• Prima di iniziare: contrai i glutei per 5 sec
• Durante: pensa a "spremere" i glutei
• Dovresti sentire bruciore nei glutei, non schiena

<strong>PROGRESSIONI:</strong>
• Principiante: Standard
• Intermedio: Pausa 3-5 secondi in alto
• Avanzato: Una gamba (Single leg bridge)
• Molto avanzato: Con banda elastica sopra ginocchia

<strong>BENEFICI:</strong>
✓ Attiva e rinforza glutei
✓ Migliora postura
✓ Riduce dolore lombare
✓ Prepara per squat e deadlift`,
            tempo: '2-2-2-0',
            restBetweenSets: 45
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

/**
 * ExerciseVideos - Utility for managing exercise video tutorials
 */
const ExerciseVideos = {
    // Validate YouTube URL for security
    isValidYouTubeUrl(url) {
        if (!url || typeof url !== 'string') return false;
        
        // Only allow YouTube embed URLs
        const validPatterns = [
            /^https:\/\/www\.youtube\.com\/embed\/[a-zA-Z0-9_-]+$/,
            /^https:\/\/youtube\.com\/embed\/[a-zA-Z0-9_-]+$/
        ];
        
        return validPatterns.some(pattern => pattern.test(url));
    },
    
    // Get video URL for an exercise with language preference
    getVideoUrl(exercise, preferredLanguage = 'it') {
        if (!exercise || !exercise.videos) return null;
        
        // Priority: preferred language (Italian by default)
        if (preferredLanguage === 'it' && exercise.videos.it && this.isValidYouTubeUrl(exercise.videos.it)) {
            return {
                url: exercise.videos.it,
                language: 'it',
                label: '🇮🇹 Video in italiano'
            };
        }
        
        // Fallback: English
        if (exercise.videos.en && this.isValidYouTubeUrl(exercise.videos.en)) {
            return {
                url: exercise.videos.en,
                language: 'en',
                label: '🇬🇧 Video in English'
            };
        }
        
        // Fallback: any available video
        const availableLang = Object.keys(exercise.videos)[0];
        if (availableLang && this.isValidYouTubeUrl(exercise.videos[availableLang])) {
            return {
                url: exercise.videos[availableLang],
                language: availableLang,
                label: `📹 Video (${availableLang.toUpperCase()})`
            };
        }
        
        return null;
    },
    
    // Generate HTML for video embed
    renderVideoEmbed(exercise, preferredLanguage = 'it') {
        const video = this.getVideoUrl(exercise, preferredLanguage);
        
        if (!video) {
            return `
                <div class="no-video">
                    <p>📹 Video tutorial non ancora disponibile</p>
                </div>
            `;
        }
        
        return `
            <div class="exercise-video">
                <h4>📹 Video Tutorial</h4>
                <div class="video-container">
                    <iframe 
                        src="${video.url}" 
                        style="border: none;" 
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                        allowfullscreen
                        loading="lazy"
                        title="Video tutorial ${exercise.name}">
                    </iframe>
                </div>
                <p class="video-language">${video.label}</p>
            </div>
        `;
    }
};

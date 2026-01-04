# TrendSentinel EA - Presupposti e Analisi dei Rischi

## Domanda Chiave
**"Quali presupposti stai dando per scontati, e cosa cambierebbe se uno di questi fosse sbagliato?"**

Questo documento analizza i presupposti fondamentali su cui si basa la logica del TrendSentinel EA e le conseguenze se questi presupposti risultassero errati.

---

## 1. PRESUPPOSTI SULLA STRUTTURA DEL MERCATO

### Presupposto 1.1: I trend persistono nel tempo
**Assunzione:** Una volta iniziato un trend, tende a continuare abbastanza a lungo da permettere profitti con R:R 2.5:1

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Whipsaws frequenti, stop loss colpiti prima di raggiungere il take profit
- **Segnali:** Win rate < 30%, profit factor < 1.0
- **Mitigazione:** 
  - Aumentare `MinTrendQuality` a 8-9
  - Ridurre `TP_RiskReward` a 1.5-2.0
  - Aumentare `SL_ATR_Multiplier` a 2.5-3.0

### Presupposto 1.2: I breakout di Donchian Channel sono significativi
**Assunzione:** Quando il prezzo rompe il massimo/minimo degli ultimi 20 periodi, indica l'inizio di un movimento direzionale

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Falsi breakout, entrate premature in range-bound markets
- **Segnali:** Alta frequenza di stop loss rapidi, drawdown durante fasi laterali
- **Mitigazione:**
  - Aumentare `Donchian_Period` a 30-50
  - Richiedere conferma di chiusura oltre il breakout (modificare codice)
  - Aggiungere filtro di volatilità (ATR minimo richiesto)

### Presupposto 1.3: L'allineamento multi-timeframe è predittivo
**Assunzione:** Quando M15, H1, H4 e D1 sono allineati, la probabilità di trend genuino aumenta

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Segnali troppo rari, opportunità mancate, over-filtering
- **Segnali:** < 1 trade/settimana, performance inferiore a strategia più semplice
- **Mitigazione:**
  - Ridurre a 2 timeframe (M15 + H1)
  - Cambiare logica: richiedere solo 1 su 3 timeframes superiori
  - Modificare `CheckTrendAlignment()` per accettare `alignedCount >= 1`

---

## 2. PRESUPPOSTI SUGLI INDICATORI

### Presupposto 2.1: ADX > 25 indica trend forte
**Assunzione:** ADX sopra 25 distingue trend da range, ADX > 35 indica trend molto forte

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Trading in mercati range-bound o in ritardo nei trend
- **Segnali:** Stop loss frequenti, entrate tardive quando ADX è alto
- **Mitigazione:**
  - Testare soglie diverse (20, 30) per diversi simboli
  - Considerare la direzione del movimento ADX (crescente vs decrescente)
  - Aggiungere filtro: ADX[0] > ADX[1] (ADX in crescita)

### Presupposto 2.2: EMA 8/21/50 cattura i trend efficacemente
**Assunzione:** Questi periodi sono ottimali per identificare trend su M15-D1

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Lag eccessivo o segnali troppo rumorosi
- **Segnali:** Entrate tardive (lag) o whipsaws (troppo sensibili)
- **Mitigazione:**
  - Ottimizzare per simbolo: valute vs indici vs commodity
  - Considerare periodi adattivi basati su volatilità
  - Testare 10/30/100 o 5/13/34 (Fibonacci)

### Presupposto 2.3: RSI 50 è il punto neutro per momentum
**Assunzione:** RSI > 50 indica momentum rialzista, RSI < 50 ribassista; range 30-70 è "sano"

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Entrate in zone di ipercomprato/ipervenduto o momentum debole
- **Segnali:** Reversioni improvvise dopo l'entrata
- **Mitigazione:**
  - Per trend forti: accettare RSI > 70 (bullish) o < 30 (bearish)
  - Aggiungere condizione: RSI[0] > RSI[1] (momentum in accelerazione)
  - Usare RSI multi-timeframe invece di solo SignalTF

### Presupposto 2.4: Volume superiore del 20% indica convinzione
**Assunzione:** Volume > 1.2 × media conferma la forza del movimento

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Segnali basati su spike di volume anomali o ignorare setup validi a volume normale
- **Segnali:** Performance non migliora con filtro volume
- **Mitigazione:**
  - Rendere il volume opzionale (peso minore nel quality score)
  - Usare volume relativo al giorno della settimana
  - Considerare che in forex il volume tick non è volume reale

---

## 3. PRESUPPOSTI SUL RISK MANAGEMENT

### Presupposto 3.1: ATR × 1.8 è uno stop loss ottimale
**Assunzione:** 1.8 ATR cattura la normale volatilità senza essere troppo stretto

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Stop loss troppo stretti (rumore) o troppo larghi (perdite eccessive)
- **Segnali:** > 60% dei trade stopped out (troppo stretto) o drawdown > 20% (troppo largo)
- **Mitigazione:**
  - Ottimizzare per simbolo: 1.5 ATR per valute major, 2.5 ATR per commodity
  - Usare ATR di timeframe superiore (H1 invece di M15)
  - Implementare stop loss adattivo basato su volatilità recente

### Presupposto 3.2: Partial close al breakeven migliora performance
**Assunzione:** Chiudere 50% a R:R 1:1 e spostare SL a breakeven riduce rischio mantenendo upside

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Profitti limitati se il trend continua fortemente
- **Segnali:** Avg Win diminuisce, molti trade chiusi a breakeven
- **Mitigazione:**
  - Rendere opzionale (`UsePartialClose = false`)
  - Chiudere solo 30% invece di 50%
  - Spostare SL a breakeven + 0.5 ATR invece che a entry price

### Presupposto 3.3: Correlazione > 0.7 è rischiosa
**Assunzione:** Trading simboli correlati aumenta rischio non diversificabile

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Opportunità perse su setup validi in simboli correlati
- **Segnali:** Troppo pochi trade, capital underutilization
- **Mitigazione:**
  - Aumentare soglia a 0.85
  - Permettere 1 trade addizionale se quality > 8
  - Usare correlation rolling su 50 periodi invece di 20

### Presupposto 3.4: 0.5% per trade è sostenibile
**Assunzione:** Rischiare 0.5% per trade permette sopravvivenza durante drawdown

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Crescita troppo lenta (troppo conservativo) o rovina (troppo aggressivo)
- **Segnali:** Anni per raddoppiare account o drawdown > 30%
- **Mitigazione:**
  - Scalare con performance: 0.5% base, 0.75% se equity > initial + 20%
  - Kelly Criterion: risk% = (Win% × AvgWin - Loss% × AvgLoss) / AvgWin
  - Mai superare 2% per trade

---

## 4. PRESUPPOSTI OPERATIVI

### Presupposto 4.1: Stop entry orders migliorano entry timing
**Assunzione:** Entrare a +0.5 ATR conferma momentum e riduce falsi segnali

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Entry peggiore rispetto a market orders, slippage maggiore
- **Segnali:** Entry price medio molto peggiore di signal price
- **Mitigazione:**
  - Testare con `UseStopEntry = false`
  - Ridurre distanza a 0.3 ATR
  - Usare limit orders invece di stop orders

### Presupposto 4.2: Scan ogni 5 minuti è sufficiente
**Assunzione:** 300 secondi bilancia carico computazionale e tempestività

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Opportunità perse (troppo lento) o overload (troppo veloce)
- **Segnali:** Segnali con quality > 8 già mossi di 1+ ATR quando rilevati
- **Mitigazione:**
  - Per M15: scan ogni 3 minuti (180 sec)
  - Per H1+: scan ogni 10 minuti (600 sec)
  - Implementare scan on tick per simboli selezionati

### Presupposto 4.3: Quality score ≥ 7 filtra efficacemente
**Assunzione:** Questo threshold bilancia quantità e qualità dei segnali

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Troppi falsi segnali (soglia bassa) o troppo pochi trade (soglia alta)
- **Segnali:** Win rate < 40% o < 5 trade/mese
- **Mitigazione:**
  - Ottimizzare in backtest: testare 5, 6, 7, 8, 9
  - Variare con condizioni: 6 in trend forte (ADX > 30), 8 in mercati choppy
  - Logging dettagliato: analizzare win rate per quality level

---

## 5. PRESUPPOSTI DI MERCATO SPECIFICI

### Presupposto 5.1: I mercati sono liquidi durante trading hours
**Assunzione:** 08:00-20:00 fornisce liquidità sufficiente per execution

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Slippage eccessivo, rejection degli ordini, fill parziali
- **Segnali:** Execution price >> entry price planned, molti ordini pending scaduti
- **Mitigazione:**
  - Restringere a 09:00-17:00 (sovrapposizione sessioni)
  - Evitare periodi specifici (12:00-14:00 per EUR)
  - Filtrare simboli per spread e slippage storico

### Presupposto 5.2: Le news ad alto impatto sono prevedibili
**Assunzione:** Filtrare 60 min prima e 30 min dopo news major protegge da volatilità

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Opportunità perse (filtro eccessivo) o spike inattesi (filtro insufficiente)
- **Segnali:** Molti trade stopped out immediatamente dopo news
- **Mitigazione:**
  - Integrare economic calendar API reale
  - Filtro dinamico: estendere finestra per news "rosso" (150 min before/60 after)
  - Chiudere posizioni esistenti prima di news major

### Presupposto 5.3: Tutti i simboli si comportano similmente
**Assunzione:** Gli stessi parametri funzionano per EUR, GBP, JPY, gold, indici

**Cosa cambierebbe se sbagliato:**
- **Impatto:** Performance eccellente su alcuni simboli, pessima su altri
- **Segnali:** Sharpe ratio varia 0.5-2.0 tra simboli diversi
- **Mitigazione:**
  - Implementare symbol-specific parameters
  - Grouping: FX Major, FX Minor, Metals, Indices
  - Parameter optimization per gruppo

---

## 6. SCENARI DI FALLIMENTO E CONTROMISURE

### Scenario A: Mercato Range-Bound Prolungato
**Problema:** EA genera segnali continui che falliscono in mercati laterali

**Sintomi:**
- Win rate scende < 35%
- Drawdown > 10% senza recovery
- ADX costantemente < 20

**Contromisure:**
```mql5
// Aggiungere filtro regime:
if(ADX_Average_20_periods < 20 && ADX_Trending_Down)
{
    Print("Range-bound market detected, pausing trading");
    return; // Skip scanning
}
```

### Scenario B: Volatilità Estrema (VIX spike, eventi geopolitici)
**Problema:** Stop loss troppo stretti, slippage eccessivo, gap improvvisi

**Sintomi:**
- Stop loss colpiti con gap
- Slippage medio > 5 pips
- Multiple losses consecutive

**Contromisure:**
```mql5
// Dynamic SL widening:
double volatilityMultiplier = CurrentATR / AverageATR_20days;
if(volatilityMultiplier > 2.0)
{
    SL_ATR_Multiplier_Adjusted = SL_ATR_Multiplier * 1.5;
    MinTrendQuality_Adjusted = MinTrendQuality + 1;
}
```

### Scenario C: Market Regime Change
**Problema:** Parametri ottimizzati su trend forti falliscono in nuovo regime

**Sintomi:**
- Performance degrada progressivamente
- Sharp ratio passa da 1.5 a 0.5
- Profitto delle ultime 50 trades < 0

**Contromisure:**
- Implementare walk-forward optimization trimestrale
- Monitoring: alertare se rolling 30-day Sharpe < 0.5
- Portfolio approach: multiple strategy variations in parallelo

### Scenario D: Overoptimization (Curve Fitting)
**Problema:** Parametri perfetti in backtest, disastrosi in forward test

**Sintomi:**
- Backtest: Sharpe 2.5, Forward: Sharpe 0.3
- Parametri molto specifici (es: EMA 8.3, ADX 24.7)
- Performance degrada immediatamente live

**Contromisure:**
- Usare parametri rotondi (5, 10, 20, 50)
- Out-of-sample testing: ultimo 30% dati non toccato
- Walk-forward: almeno 10 windows
- Robustness test: variare ogni parametro ±20%, performance deve rimanere accettabile

---

## 7. METRICHE DI MONITORING

### Red Flags che indicano presupposti violati:

| Metrica | Threshold Normale | Red Flag | Azione |
|---------|-------------------|----------|--------|
| Win Rate | 40-60% | < 35% | Aumentare MinTrendQuality, verificare regime |
| Profit Factor | > 1.5 | < 1.2 | Ridurre TP o aumentare filtri |
| Avg Win/Loss | > 2.0 | < 1.5 | Verificare R:R ratio, considerare trailing stop più aggressivo |
| Max Consecutive Losses | < 5 | > 7 | Stop trading, rianalizzare mercato |
| Slippage Medio | < 2 pips | > 5 pips | Verificare liquidità, restringere trading hours |
| Drawdown | < 15% | > 20% | Halve position size, verificare risk management |
| Sharpe Ratio (30d) | > 1.0 | < 0.5 | Pause auto-trading, manual review |
| Trade Frequency | 5-15/week | < 2 o > 30 | Verificare quality threshold e parametri |

---

## 8. RACCOMANDAZIONI FINALI

### Per l'Utente:

1. **Non usare parametri default alla cieca**
   - Backtest su almeno 2 anni di dati
   - Forward test su demo per 1-2 mesi
   - Start conservativo: MinTrendQuality = 8, RiskPerTrade = 0.3%

2. **Monitoring attivo i primi 30 giorni**
   - Review giornaliero dei segnali e trade
   - Confronto con aspettative del backtest
   - Annotare eventi di mercato anomali

3. **Preparare Plan B**
   - Se drawdown > 15%: stop e review
   - Se win rate < 35% per 20 trades: pause
   - Avere set alternativo di parametri ready

4. **Ottimizzazione periodica**
   - Ogni trimestre: review performance
   - Ogni semestre: re-optimization su dati recenti
   - Annuale: consider strategy overhaul

### Per lo Sviluppatore:

1. **Implementare regime detection**
   - Trend vs Range classifier
   - Volatility regime (low/normal/high)
   - Parametri adattivi per regime

2. **Enhanced risk management**
   - Kelly Criterion per position sizing
   - Volatility-adjusted stops
   - Equity-curve based risk scaling

3. **Machine Learning integration**
   - Quality score da ML model
   - Feature importance analysis
   - Adaptive parameter optimization

4. **Robustezza**
   - Multiple strategy ensemble
   - Symbol-specific optimization
   - Walk-forward automation

---

## CONCLUSIONE

Il TrendSentinel EA si basa su **13 presupposti fondamentali** relativi a:
- Struttura del mercato (persistenza trend, significatività breakout)
- Efficacia degli indicatori (ADX, EMA, RSI)
- Parametri di risk management (ATR, correlation)
- Condizioni operative (liquidità, timing)

**Nessun presupposto è garantito**. I mercati cambiano, la volatilità fluttua, i regimi si alternano.

**L'EA deve essere:**
- Monitorato costantemente
- Adattato periodicamente
- Usato con consapevolezza dei limiti
- Testato approfonditamente prima del live

**La chiave del successo non è avere presupposti perfetti, ma:**
1. Conoscere i propri presupposti
2. Monitorare quando falliscono
3. Avere piani di contingenza
4. Adattarsi rapidamente

Questo documento fornisce il framework per tale approccio.

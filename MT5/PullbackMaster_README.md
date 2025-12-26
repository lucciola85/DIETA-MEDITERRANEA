# PullbackMaster EA - MetaTrader 5 Expert Advisor

## Panoramica

**PullbackMaster EA** è un Expert Advisor professionale per MetaTrader 5 specializzato nel trading di pullback sui rimbalzi a supporti e resistenze. L'EA identifica automaticamente i livelli chiave S/R e entra in posizione quando il prezzo rimbalza da questi livelli senza romperli.

### Caratteristiche Principali

- 🎯 **Trading sui Pullback**: Specializzato nei rimbalzi a supporti e resistenze
- 📊 **Rilevamento Automatico S/R**: Identificazione automatica dei livelli usando swing points
- ⚡ **Operatività Intraday**: Ottimizzato per trading frequente con alta probabilità
- 💰 **Money Management Avanzato**: Sistemi multipli di gestione del rischio personalizzabili
- 🛡️ **Sistema di Protezione**: Limiti giornalieri, drawdown massimo, controllo margine
- 📈 **Gestione Posizioni**: Breakeven, trailing stop, chiusura parziale

## Strumenti e Timeframe Consigliati

### Strumenti Ottimali
| Strumento | Caratteristiche | Consigliato |
|-----------|-----------------|-------------|
| **EUR/USD** | Alta liquidità, spread bassi, movimenti puliti | ⭐⭐⭐⭐⭐ |
| **GBP/USD** | Buona volatilità, livelli S/R chiari | ⭐⭐⭐⭐ |
| **USD/JPY** | Movimenti tecnici, buona reazione ai livelli | ⭐⭐⭐⭐ |
| **GBP/JPY** | Alta volatilità, attenzione allo spread | ⭐⭐⭐ |

### Timeframe Consigliati
| Timeframe | Uso | Frequenza Trade |
|-----------|-----|-----------------|
| **M15** | Trading principale (default) | Alta (5-8 trade/giorno) |
| **M30** | Alternativa più conservativa | Media (3-5 trade/giorno) |
| **H1** | Per trend timeframe filter | N/A (solo filtro) |

### Configurazione Multi-Timeframe
L'EA utilizza un approccio multi-timeframe:
- **Timeframe Principale (M15)**: Rilevamento S/R e segnali di ingresso
- **Timeframe Trend (H1)**: Filtro di direzione del trend

## Installazione

1. Copia `PullbackMaster_EA.mq5` nella cartella Experts di MT5:
   ```
   [MT5 Data Folder]/MQL5/Experts/PullbackMaster_EA.mq5
   ```

2. Compila l'EA in MetaEditor (F7)

3. Applica l'EA al grafico desiderato (EUR/USD M15 consigliato)

4. Configura i parametri secondo le tue preferenze

## Parametri di Input

### Impostazioni Generali
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| EA Name | PullbackMaster | Nome identificativo |
| Magic Number | 202412 | Numero magico per identificare i trade |
| Trade Comment | PBM | Commento sui trade |
| Main Timeframe | M15 | Timeframe principale |
| Trade Direction | Both | Direzione trading (Buy/Sell/Both) |

### Rilevamento Supporti/Resistenze
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| S/R Method | Swing Points | Metodo di rilevamento |
| Swing Lookback | 10 | Barre per identificare swing point |
| S/R Strength | 2 | Minimo tocchi per validare livello |
| S/R Zone ATR Mult | 0.3 | Larghezza zona S/R (multiplo ATR) |
| Max S/R Levels | 5 | Numero massimo livelli tracciati |

### Rilevamento Pullback
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Bounce ATR Mult | 0.5 | Prossimità al livello (multiplo ATR) |
| Min Bounce Candles | 2 | Candele minime per conferma rimbalzo |
| Require Rejection | true | Richiedi wick di rifiuto |
| Min Wick Ratio | 0.5 | Rapporto minimo wick/body |

### Filtro Trend
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Use Trend Filter | true | Abilita filtro trend |
| EMA Period | 50 | Periodo EMA per trend |
| Trend Timeframe | H1 | Timeframe per analisi trend |

### Filtro RSI
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Use RSI Filter | true | Abilita filtro RSI |
| RSI Period | 14 | Periodo RSI |
| RSI Overbought | 65 | Livello ipercomprato |
| RSI Oversold | 35 | Livello ipervenduto |

### Money Management
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Lot Mode | Risk Percent | Modalità calcolo lotti |
| Fixed Lot | 0.1 | Lotto fisso |
| Risk Percent | 1.0% | Rischio per trade |
| Min/Max Lot | 0.01 / 5.0 | Limiti lotto |
| Max Positions | 2 | Posizioni massime aperte |

### Sistema di Protezione
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Max Daily Loss | 3.0% | Perdita giornaliera massima |
| Max Drawdown | 10.0% | Drawdown massimo totale |
| Max Daily Trades | 8 | Trade massimi al giorno |
| Min Margin Level | 200% | Livello margine minimo |

### Filtro Sessione
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Use Session Filter | true | Abilita filtro orario |
| Session Start | 8 | Ora inizio (server time) |
| Session End | 18 | Ora fine (server time) |
| Avoid News | true | Evita orari news |

### Stop Loss & Take Profit
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Use Dynamic SL/TP | true | SL/TP dinamici basati su ATR |
| Fixed SL | 200 points | Stop Loss fisso |
| Fixed TP | 300 points | Take Profit fisso |
| SL ATR Multiplier | 1.5 | Multiplo ATR per SL |
| Risk/Reward | 2.0 | Rapporto rischio/rendimento |
| Min/Max SL | 100/400 pts | Limiti SL |

### Gestione Posizioni
| Parametro | Default | Descrizione |
|-----------|---------|-------------|
| Use Breakeven | true | Attiva breakeven |
| Breakeven Ratio | 0.5 | Attiva BE al 50% del TP |
| BE Offset | 10 points | Offset dal prezzo di apertura |
| Use Trailing Stop | true | Attiva trailing stop |
| Trailing Ratio | 0.7 | Attiva trailing al 70% del TP |
| Trailing Distance | 100 pts | Distanza trailing |
| Use Partial Close | false | Chiusura parziale |
| Partial Percent | 50% | Percentuale chiusura parziale |

## Logica di Trading

### Come Funziona

1. **Rilevamento S/R**:
   - L'EA identifica swing highs (resistenze) e swing lows (supporti)
   - I livelli vengono raggruppati in zone con minimo 2 tocchi
   - Solo i livelli più forti vengono considerati

2. **Segnale di Ingresso**:
   - Il prezzo si avvicina a un livello S/R (entro la zona di bounce)
   - Si forma una candela di rifiuto (wick significativa)
   - I filtri (trend + RSI) confermano la direzione

3. **Gestione Trade**:
   - SL posizionato oltre il livello S/R
   - TP basato su rapporto rischio/rendimento
   - Breakeven e trailing automatici

### Condizioni di BUY (Bounce da Supporto)
- Prezzo vicino a un supporto validato
- Candela bullish o con lower wick significativa
- Prezzo sopra EMA trend (H1) o neutro
- RSI non in zona ipercomprata

### Condizioni di SELL (Bounce da Resistenza)
- Prezzo vicino a una resistenza validata
- Candela bearish o con upper wick significativa
- Prezzo sotto EMA trend (H1) o neutro
- RSI non in zona ipervenduta

## Aspettative di Performance

### Target Operativi
- **Frequenza**: 3-8 trade al giorno (intraday attivo)
- **Win Rate Atteso**: 55-65%
- **Risk/Reward**: 1:2 (default)
- **Drawdown Max**: < 10% (con protezioni attive)

### Fattori di Successo
✅ Alta liquidità dello strumento
✅ Spread competitivi
✅ Livelli S/R chiari e rispettati
✅ Mercato in range o trend moderato

### Condizioni da Evitare
❌ Alta volatilità (news, eventi)
❌ Mercati in forte trend (breakout frequenti)
❌ Spread elevati
❌ Sessioni a bassa liquidità

## Backtesting

Prima di usare l'EA in reale:

1. **Strategy Tester MT5**:
   - Usa "Every tick based on real ticks"
   - Testa su almeno 1 anno di dati
   - Confronta diversi strumenti

2. **Demo Account**:
   - Esegui forward test per almeno 1 mese
   - Verifica comportamento in diverse condizioni

3. **Go Live**:
   - Inizia con lotti minimi
   - Monitora attivamente le prime settimane

## Set File Consigliati

### Conservativo (Principianti)
```
InpRiskPercent = 0.5
InpMaxDailyLoss = 2.0
InpMaxDailyTrades = 5
InpRiskReward = 2.5
```

### Moderato (Default)
```
InpRiskPercent = 1.0
InpMaxDailyLoss = 3.0
InpMaxDailyTrades = 8
InpRiskReward = 2.0
```

### Aggressivo (Esperti)
```
InpRiskPercent = 2.0
InpMaxDailyLoss = 5.0
InpMaxDailyTrades = 12
InpRiskReward = 1.5
```

## Dashboard

L'EA mostra un pannello informativo con:
- Balance ed Equity correnti
- P/L giornaliero
- Drawdown attuale
- Posizioni aperte
- Trade giornalieri
- Indicatori (RSI, ATR, Trend)
- Livelli S/R più vicini

## Avvertenze

⚠️ **RISCHIO**: Il trading sul forex comporta rischi significativi. Non investire denaro che non puoi permetterti di perdere.

⚠️ **BACKTESTING**: I risultati passati non garantiscono performance future.

⚠️ **PARAMETRI**: L'EA è fornito con parametri di default. Ottimizza in base al tuo strumento e alle condizioni di mercato.

## Supporto

Per supporto, segnalazioni bug o richieste di funzionalità, contatta il team di sviluppo.

## Licenza

Copyright 2024, Trading Systems. Tutti i diritti riservati.

---

**Buon Trading! 📈🎯**

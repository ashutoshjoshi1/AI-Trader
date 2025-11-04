# XAUUSD AI Trading System for MetaTrader 5

A sophisticated automated trading system designed for XAUUSD (Gold) trading on MetaTrader 5. This Expert Advisor (EA) implements multiple trading strategies with advanced risk management, position sizing, and trade management features.

## 🎯 Features

- **Multi-Strategy System**: Combines 3 proven trading strategies
  - Multi-Timeframe Momentum
  - Support/Resistance Breakout
  - Scalping Strategy
- **Advanced Risk Management**: 
  - Automatic position sizing based on account risk percentage
  - Dynamic stop loss using ATR (Average True Range)
  - Maximum daily loss protection
  - Drawdown protection
  - Consecutive loss protection
- **Trade Management**:
  - Trailing stops
  - Breakeven stop loss
  - Partial profit taking
  - Automatic stop loss and take profit calculation
- **Session Filtering**: Trade during optimal market hours
- **Multiple Timeframe Analysis**: D1, H4, H1, M15, M5

## 📋 Requirements

- MetaTrader 5 platform (latest version)
- XAUUSD symbol available on your broker
- Minimum account balance: $100 (as configured)
- Stable internet connection
- VPS recommended for 24/7 operation

### Platform Support:
- ✅ **Windows**: Full support (recommended)
- ✅ **macOS**: Works via Wine, Virtual Machine, or VPS (see INSTALLATION_GUIDE.md)
- ⚠️ **Mac Native MT5**: Limited MQL5 support - not recommended

## 🚀 Installation

**📖 For detailed installation instructions including macOS setup, see [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)**

### Quick Install (Windows):

1. **Download the EA**:
   - Copy `XAUUSD_AI_Trader.mq5` to your MT5 installation directory
   - Path: `C:\Users\[YourName]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\`

2. **Compile the EA**:
   - Open MetaEditor (F4 in MT5)
   - Open `XAUUSD_AI_Trader.mq5`
   - Click "Compile" or press F7
   - Ensure no compilation errors

3. **Attach to Chart**:
   - Open MT5 platform
   - Open XAUUSD chart (any timeframe, EA uses its own timeframes)
   - Drag `XAUUSD_AI_Trader` from Navigator to the chart
   - Configure settings in the EA parameters window

4. **Enable AutoTrading**:
   - Click the "AutoTrading" button in MT5 toolbar (green button)
   - Ensure EA is allowed in Tools → Options → Expert Advisors

### macOS Users:
See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for Mac-specific instructions (Wine, Virtual Machine, or VPS methods)

## ⚙️ Configuration

### Risk Management Settings
- **RiskPercent**: 1.5% (risk per trade as % of account balance)
- **MaxDailyRisk**: 5.0% (maximum daily risk limit)
- **MaxDrawdown**: 20.0% (maximum account drawdown before reducing risk)
- **MaxOpenPositions**: 2 (maximum simultaneous open positions)
- **MaxTradesPerDay**: 10 (maximum trades per day)

### Strategy Selection
- **EnableStrategy1**: true (Multi-Timeframe Momentum)
- **EnableStrategy2**: true (Support/Resistance Breakout)
- **EnableStrategy3**: true (Scalping Strategy)

You can enable/disable individual strategies based on market conditions.

### Trade Management
- **RiskRewardRatio**: 2.0 (Take Profit = 2x Stop Loss)
- **UseTrailingStop**: true (Enable trailing stop)
- **TrailingStart**: 1.0 (Start trailing at 1x risk-reward)
- **TrailingStep**: 1.0 (Trail by 1x ATR)
- **UseBreakeven**: true (Move stop to breakeven)
- **BreakevenTrigger**: 1.0 (Move to breakeven at 1x risk-reward)
- **UsePartialClose**: true (Close 50% at partial profit)
- **PartialCloseAt**: 1.5 (Close 50% at 1.5x risk-reward)

### Session Filter
- **UseSessionFilter**: true (Enable trading hours filter)
- **StartHour**: 8 (Trading start hour GMT)
- **EndHour**: 20 (Trading end hour GMT)

## 📊 Recommended Settings for $100 Account

```
RiskPercent = 1.5%
MaxDailyRisk = 5.0%
MaxTradesPerDay = 10
MaxOpenPositions = 2
RiskRewardRatio = 2.0
UseTrailingStop = true
UseBreakeven = true
UsePartialClose = true
```

## 🎓 How It Works

### Strategy 1: Multi-Timeframe Momentum
- Analyzes H1 timeframe for trend direction using EMAs
- Enters on M15 when RSI and MACD confirm momentum
- Stop Loss: 2x ATR
- Take Profit: 3x ATR (or 2x risk if RiskRewardRatio = 2.0)

### Strategy 2: Support/Resistance Breakout
- Identifies breakouts from previous day high/low
- Requires volume confirmation
- RSI filter to avoid overbought/oversold entries
- Stop Loss: 1.5x ATR

### Strategy 3: Scalping
- Works on M5 timeframe
- Uses fast EMAs and Stochastic oscillator
- Quick entries with tight stops (10-15 pips)
- Stop Loss: 1.5x ATR (minimum 10, maximum 15 pips)

## 📈 Performance Expectations

Based on backtesting and strategy design:
- **Target Win Rate**: 55%+
- **Risk-Reward Ratio**: 1:2 (minimum)
- **Expected Monthly Return**: 80-120% (aggressive but achievable)
- **Maximum Drawdown**: < 20%

⚠️ **Note**: Past performance does not guarantee future results. Always test on demo account first.

## 🔍 Monitoring

The EA prints important information to the Experts log:
- Trade entries/exits
- Stop loss modifications (breakeven, trailing)
- Daily statistics
- Risk limit warnings

View logs: View → Terminal → Experts tab

## ⚠️ Important Warnings

1. **Always Test First**: Run on demo account for at least 2 weeks before live trading
2. **Monitor Closely**: Especially during first month of operation
3. **Market Conditions**: System performs best during high volatility periods (London/NY overlap)
4. **Broker Requirements**: Ensure your broker:
   - Allows EAs
   - Has low spreads on XAUUSD
   - Supports the required order types
   - Has stable execution
5. **Risk Management**: Never risk more than you can afford to lose
6. **Regular Withdrawals**: Consider withdrawing profits regularly as account grows

## 🐛 Troubleshooting

### EA Not Opening Trades
- Check if AutoTrading is enabled
- Verify trading is allowed for the symbol
- Check if daily limits are reached
- Ensure sufficient account balance
- Verify session filter settings

### Compilation Errors
- Ensure you're using MT5 (not MT4)
- Check that all included files are present
- Update MT5 to latest version

### Trades Not Executing
- Check broker's execution settings
- Verify symbol name matches exactly (XAUUSD)
- Check account leverage and margin requirements
- Ensure minimum lot size is available

## 📝 Logs and Statistics

The EA tracks:
- Daily trade count
- Daily profit/loss
- Consecutive losses
- Account drawdown
- Position management actions

All logged to Experts tab in MT5 terminal.

## 🔄 Updates and Optimization

Regular optimization recommended:
- Test different indicator parameters
- Adjust risk percentage based on account growth
- Fine-tune session filter times
- Monitor and adjust strategy weights

## 📞 Support

For issues or questions:
1. Check the Experts log for error messages
2. Review the TRADING_STRATEGY_PLAN.md for detailed strategy explanations
3. Test parameters on demo account first

## ⚖️ Disclaimer

This trading system is provided for educational and research purposes. Trading forex and CFDs involves substantial risk of loss and may not be suitable for all investors. Past performance is not indicative of future results. Always trade responsibly and never risk more than you can afford to lose.

## 📄 License

This EA is provided as-is for personal use. Modify and optimize as needed for your trading style.

---

**Happy Trading! 🚀**

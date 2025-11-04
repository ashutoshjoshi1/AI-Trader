# Quick Setup Guide - XAUUSD AI Trader

## Step-by-Step Installation

### Step 1: Locate MT5 Data Folder
1. Open MetaTrader 5
2. Go to **File** → **Open Data Folder**
3. Navigate to: `MQL5\Experts\`

### Step 2: Copy EA File
1. Copy `XAUUSD_AI_Trader.mq5` to the `Experts` folder
2. Close and reopen MT5 (or press F5 to refresh)

### Step 3: Compile the EA
1. Press **F4** to open MetaEditor
2. In Navigator, find **XAUUSD_AI_Trader.mq5** under Experts
3. Double-click to open it
4. Press **F7** to compile
5. Check the bottom panel for "0 error(s), 0 warning(s)"
6. If errors occur, ensure you're using MT5 (not MT4)

### Step 4: Configure EA Settings
1. In MT5, open an XAUUSD chart (any timeframe)
2. In Navigator panel, find **XAUUSD_AI_Trader** under Expert Advisors
3. Drag it onto the chart
4. A configuration window will appear

### Step 5: Recommended Initial Settings

For a **$100 account**, use these settings:

```
=== RISK MANAGEMENT ===
RiskPercent: 1.5
MaxDailyRisk: 5.0
MaxDrawdown: 20.0
MaxOpenPositions: 2
MaxTradesPerDay: 10

=== STRATEGY SELECTION ===
EnableStrategy1: ✓ (checked)
EnableStrategy2: ✓ (checked)
EnableStrategy3: ✓ (checked)

=== TRADE MANAGEMENT ===
RiskRewardRatio: 2.0
UseTrailingStop: ✓
TrailingStart: 1.0
TrailingStep: 1.0
UseBreakeven: ✓
BreakevenTrigger: 1.0
UsePartialClose: ✓
PartialCloseAt: 1.5

=== SESSION FILTER ===
UseSessionFilter: ✓
StartHour: 8
EndHour: 20

=== MONEY MANAGEMENT ===
InitialBalance: 100.0
MagicNumber: 123456
```

5. Click **OK** to save

### Step 6: Enable AutoTrading
1. Click the **AutoTrading** button in the toolbar (should turn green)
2. If a warning appears, go to:
   - **Tools** → **Options** → **Expert Advisors**
   - Check "Allow automated trading"
   - Check "Allow DLL imports" (if needed)
   - Click OK

### Step 7: Verify EA is Running
1. Check the chart - you should see a smiley face icon in top-right corner
2. Open **View** → **Terminal** → **Experts** tab
3. You should see: "=== XAUUSD AI Trader Initialized ==="
4. Note the account balance and settings displayed

## First-Time Testing (DEMO ACCOUNT STRONGLY RECOMMENDED)

### Before Going Live:
1. **Open a Demo Account** with your broker
2. **Fund it with $100** (or similar amount)
3. **Run the EA for at least 2 weeks** on demo
4. **Monitor daily**:
   - Check Experts log for trade entries
   - Verify risk management is working
   - Check that stop losses are being set correctly
   - Monitor account equity

### What to Watch For:
- ✅ EA opens trades during trading hours
- ✅ Stop loss and take profit are set correctly
- ✅ Position sizes are appropriate for account
- ✅ Trailing stops activate when profit is reached
- ✅ Daily trade limits are respected
- ✅ EA stops trading when daily loss limit is hit

## Common Issues and Solutions

### Issue: EA shows "Not allowed" or smiley is sad
**Solution**: 
- Check AutoTrading is enabled (green button)
- Tools → Options → Expert Advisors → Allow automated trading
- Restart MT5

### Issue: No trades opening
**Solution**:
- Check session filter times (ensure current hour is between StartHour and EndHour)
- Verify XAUUSD symbol exists in Market Watch
- Check if daily trade limit is reached
- Ensure account balance is sufficient

### Issue: "Invalid lot size" error
**Solution**:
- Check broker's minimum lot size
- Adjust RiskPercent if needed (try 1.0% instead of 1.5%)
- Verify account has enough margin

### Issue: Compilation errors
**Solution**:
- Ensure you're using MT5 (not MT4)
- Check MT5 is updated to latest version
- Verify file is saved as .mq5 (not .mq4)

## Daily Monitoring Checklist

### Morning (Before Trading Starts):
- [ ] Check EA is running (smiley face on chart)
- [ ] Verify account balance
- [ ] Check Experts log for any errors

### During Trading:
- [ ] Monitor open positions
- [ ] Check that stop losses are in place
- [ ] Verify position sizes are correct

### End of Day:
- [ ] Review daily trade count
- [ ] Check daily profit/loss
- [ ] Review Experts log for any issues
- [ ] Note any adjustments needed

## Performance Tracking

Create a simple spreadsheet to track:
- Date
- Starting Balance
- Ending Balance
- Daily Profit/Loss
- Number of Trades
- Win Rate
- Max Drawdown

## Safety Tips

1. **Start Small**: Even on live, consider starting with lower RiskPercent (1.0%)
2. **Set Alerts**: MT5 can send email/SMS alerts for important events
3. **Regular Backups**: Export your account statements regularly
4. **Review Weekly**: Analyze performance and adjust if needed
5. **Withdraw Profits**: Consider withdrawing 50% of profits monthly

## When to Adjust Settings

### Increase Risk (if consistently profitable):
- After 1 month of consistent profits
- Gradually increase RiskPercent to 2.0%
- Increase MaxTradesPerDay to 15

### Decrease Risk (if losses are high):
- Reduce RiskPercent to 1.0%
- Reduce MaxDailyRisk to 3.0%
- Disable Strategy3 (scalping) if it's causing losses

### Adjust Strategies:
- If one strategy underperforms, disable it
- Focus on the best-performing strategy
- Test different indicator parameters

## Next Steps

1. **Read** the full `TRADING_STRATEGY_PLAN.md` for strategy details
2. **Test on demo** for minimum 2 weeks
3. **Start live** with small account
4. **Monitor closely** for first month
5. **Optimize** based on results

---

**Remember**: Trading involves risk. Always test thoroughly before risking real money!

# Installation & Running Guide - Windows & macOS

## 🖥️ Running on Windows (Recommended)

### Step 1: Install MetaTrader 5
1. Download MT5 from: https://www.metatrader5.com/en/download
2. Install the application
3. Open MT5 and login/create an account with your broker

### Step 2: Install the EA
1. In MT5, go to **File** → **Open Data Folder**
2. Navigate to: `MQL5\Experts\`
3. Copy `XAUUSD_AI_Trader.mq5` into this folder
4. Restart MT5 or press **F5** to refresh

### Step 3: Compile the EA
1. Press **F4** to open MetaEditor
2. In Navigator panel, find **XAUUSD_AI_Trader.mq5** under Experts
3. Double-click to open
4. Press **F7** to compile
5. Check bottom panel: should show "0 error(s), 0 warning(s)"

### Step 4: Attach to Chart
1. In MT5, open an XAUUSD chart (any timeframe)
2. In Navigator → Expert Advisors, find **XAUUSD_AI_Trader**
3. Drag it onto the chart
4. Configure settings (see SETUP_GUIDE.md for recommended settings)
5. Click **OK**

### Step 5: Enable AutoTrading
1. Click the **AutoTrading** button in toolbar (should turn green)
2. You should see a smiley face on the chart
3. Check Experts tab for initialization message

---

## 🍎 Running on macOS

### Option 1: Native MT5 for Mac (Limited Support)

**⚠️ Important Note**: MetaTrader 5 for macOS has limited MQL5 support compared to Windows. The EA may work but with limitations.

#### Steps:
1. Download MT5 for Mac from: https://www.metatrader5.com/en/download
2. Install and open MT5
3. Try the same steps as Windows (File → Open Data Folder → MQL5\Experts\)
4. **Check if MQL5 compilation works** - this is the critical part
5. If MetaEditor is available and can compile MQL5, proceed with Windows instructions

#### Limitations on Native Mac MT5:
- May not have full MQL5 compiler support
- Some functions might not work
- Backtesting capabilities limited
- Not all brokers support Mac MT5

---

### Option 2: Wine + Windows MT5 (Recommended for Mac)

This runs Windows MT5 on macOS using Wine. This is the most reliable method.

#### Install Wine:
```bash
# Using Homebrew (recommended)
brew install --cask wine-stable

# Or download Wine from: https://www.winehq.org/download
```

#### Install MT5 via Wine:
1. Download Windows version of MT5: https://www.metatrader5.com/en/download
2. Right-click the installer → Open With → Wine
3. Follow Windows installation process
4. MT5 will run as a Windows application on Mac

#### Install the EA:
1. Open MT5 (running through Wine)
2. Follow the Windows installation steps above
3. Everything should work normally

---

### Option 3: Virtual Machine (Most Reliable for Mac)

Run Windows in a virtual machine on your Mac for full compatibility.

#### Using Parallels Desktop (Paid):
1. Install Parallels Desktop
2. Create a Windows 10/11 virtual machine
3. Install MT5 Windows version inside VM
4. Follow Windows installation steps

#### Using VirtualBox (Free):
1. Download VirtualBox: https://www.virtualbox.org/
2. Download Windows ISO from Microsoft
3. Create a virtual machine
4. Install Windows in VM
5. Install MT5 Windows version inside VM
6. Follow Windows installation steps

**Pros**: Full Windows compatibility, no limitations
**Cons**: Requires Windows license, uses more resources

---

### Option 4: Remote Desktop / VPS (Best for 24/7 Trading)

Run MT5 on a Windows VPS (Virtual Private Server) and access remotely.

#### Popular VPS Providers:
- **AWS EC2** (Amazon Web Services)
- **DigitalOcean**
- **Vultr**
- **Forex VPS** (specialized for trading)

#### Steps:
1. Rent a Windows VPS
2. Install MT5 on the VPS
3. Install the EA following Windows steps
4. Access VPS via Remote Desktop from your Mac
5. EA runs 24/7 on the VPS

**Pros**: 
- Runs 24/7 even when your Mac is off
- Full Windows compatibility
- Low latency (usually in same datacenter as broker)
- Can access from anywhere

**Cons**: Monthly cost ($10-30/month typically)

---

## 🚀 Quick Start Commands

### On Windows:
1. Open MT5
2. File → Open Data Folder → Navigate to MQL5\Experts\
3. Copy EA file
4. Press F4 → Compile (F7)
5. Drag EA to chart

### On Mac (Wine method):
```bash
# Install Wine first
brew install --cask wine-stable

# Then download Windows MT5 installer and run:
wine ~/Downloads/mt5setup.exe
```

### On Mac (Terminal - if native MT5 works):
The data folder is typically at:
```
~/Library/Application Support/MetaTrader 5/
```

Navigate there and place EA in `MQL5/Experts/` folder.

---

## ✅ Verification Steps

After installation, verify everything works:

1. **Check EA Compilation**:
   - Open MetaEditor (F4)
   - Find XAUUSD_AI_Trader.mq5
   - Compile (F7)
   - Should show: "0 error(s), 0 warning(s)"

2. **Check EA Loading**:
   - Drag EA to XAUUSD chart
   - Should see configuration window
   - Click OK

3. **Check AutoTrading**:
   - Click AutoTrading button (green)
   - Should see smiley face on chart
   - Check Experts tab for: "=== XAUUSD AI Trader Initialized ==="

4. **Check Indicators Loading**:
   - Wait a few seconds
   - Check Experts tab - should not show indicator errors
   - EA should be waiting for trading signals

---

## 🐛 Troubleshooting

### Issue: "Cannot compile MQL5 on Mac"
**Solution**: 
- Use Wine method (Option 2)
- Or use VPS/Virtual Machine (Options 3 or 4)
- Native Mac MT5 may not support full MQL5

### Issue: "EA not appearing in Navigator"
**Solution**:
- Ensure file is in correct folder: `MQL5/Experts/`
- File must be `.mq5` extension (not .mq4 or .txt)
- Restart MT5 or press F5 to refresh
- Check file was copied completely

### Issue: "Compilation errors"
**Solution**:
- Ensure using MT5 (not MT4)
- Check MT5 is updated to latest version
- Verify all included files are present
- Check Experts log for specific error messages

### Issue: "Wine not working on Mac"
**Solution**:
- Try Wine-staging instead of wine-stable
- Use 64-bit Wine if possible
- Check Mac architecture (Intel vs Apple Silicon)
- Consider using Parallels or VirtualBox instead

### Issue: "EA not trading"
**Solution**:
- Check AutoTrading is enabled (green button)
- Verify trading hours (session filter settings)
- Check daily trade limit hasn't been reached
- Ensure account has sufficient balance
- Check XAUUSD symbol is available and trading is allowed

---

## 📊 Performance on Different Platforms

| Platform | Compatibility | Performance | 24/7 Operation | Recommendation |
|----------|--------------|-------------|----------------|----------------|
| Windows Native | ⭐⭐⭐⭐⭐ | Excellent | Good (with VPS) | **Best Choice** |
| Mac Native MT5 | ⭐⭐ | Limited | Limited | Not Recommended |
| Mac + Wine | ⭐⭐⭐⭐ | Good | Good (with VPS) | Good Alternative |
| Mac + VM | ⭐⭐⭐⭐⭐ | Excellent | Good (with VPS) | Excellent Choice |
| Windows VPS | ⭐⭐⭐⭐⭐ | Excellent | **Excellent** | **Best for 24/7** |

---

## 💡 Recommendations by Use Case

### For Casual Trading (Mac User):
- **Use**: Mac + Wine method
- **Why**: Simple, free, works well
- **When**: Trading during market hours only

### For Serious Trading (Mac User):
- **Use**: Windows VPS
- **Why**: 24/7 operation, low latency, reliable
- **When**: Want automated trading running constantly

### For Development/Testing (Mac User):
- **Use**: Virtual Machine with Windows
- **Why**: Full Windows environment for testing
- **When**: Want to test and develop EAs

### For Best Performance:
- **Use**: Windows VPS in same region as broker
- **Why**: Lowest latency, 24/7 operation
- **When**: Professional trading setup

---

## 🔗 Useful Links

- **MT5 Download**: https://www.metatrader5.com/en/download
- **MT5 Mac Version**: https://www.metatrader5.com/en/download
- **Wine Download**: https://www.winehq.org/download
- **VirtualBox**: https://www.virtualbox.org/
- **Forex VPS Providers**: Search "forex VPS" for specialized options

---

## 📝 Next Steps After Installation

1. ✅ **Test on Demo**: Run on demo account for 2+ weeks
2. ✅ **Monitor Performance**: Check Experts log daily
3. ✅ **Verify Settings**: Ensure risk management is working
4. ✅ **Start Small**: Begin with recommended $100 settings
5. ✅ **Optimize**: Adjust based on results

---

**Remember**: Always test thoroughly before using real money, regardless of platform!

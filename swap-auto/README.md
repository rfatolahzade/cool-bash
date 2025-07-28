# Dynamic Swap Manager 

Automatically manages swap files based on memory usage - creates swap when memory exceeds 80%, removes it when usage drops below 80% 

📋 Features 

   - Automatic swap creation when memory usage > 80%
   - Automatic swap removal when memory usage < 80%
   - Configurable swap size (default: 4GB)
   - Continuous monitoring with customizable check intervals
   - Robust error handling and comprehensive logging
   - Systemd service for automatic startup
 

🚀 Installation 

```bash
cd cool-bash/swap-auto
mv cool-bash/swap-auto/dynamic-swap.sh /usr/local/bin/dynamic-swap.sh
sudo chmod +x /usr/local/bin/dynamic-swap.sh
sudo touch /var/log/dynamic-swap.log
sudo chmod 644 /var/log/dynamic-swap.log
mv cool-bash/swap-auto/dynamic-swap.service /etc/systemd/system/dynamic-swap.service 
```
And then reload:
```bash
systemctl daemon-reload
systemctl enable dynamic-swap.service
systemctl start dynamic-swap.service
systemctl status dynamic-swap.service
```
Manual Commands:
```bash
# Single memory check
sudo /usr/local/bin/dynamic-swap.sh --check

# Run as daemon (continuous monitoring)
sudo /usr/local/bin/dynamic-swap.sh --daemon

# Show current status
/usr/local/bin/dynamic-swap.sh --status

# Show help
/usr/local/bin/dynamic-swap.sh --help
```

⚙️ Configuration 

Edit the script to modify default settings: 
```bash
# Configuration
SWAP_FILE="/swapfile_dynamic"
SWAP_SIZE_GB=4
MEMORY_THRESHOLD=80   #when Mem usage upper than 80%
CHECK_INTERVAL=37  # seconds

```



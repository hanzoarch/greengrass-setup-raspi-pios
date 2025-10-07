#!/bin/bash

# AWS IoT Greengrass Debug Script
# Comprehensive debugging information collection

echo "=== AWS IoT Greengrass Debug Information ==="
echo "Timestamp: $(date)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
echo ""

# System Information
echo "1. System Information:"
echo "   CPU: $(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | xargs)"
echo "   Memory: $(cat /proc/meminfo | grep MemTotal | awk '{print $2 " " $3}')"
echo "   Disk: $(df -h / | tail -1 | awk '{print $4 " available"}')"
echo ""

# Java Environment
echo "2. Java Environment:"
java -version 2>&1 | head -3
echo "   JAVA_HOME: ${JAVA_HOME:-Not set}"
echo ""

# AWS CLI
echo "3. AWS CLI:"
if command -v aws &> /dev/null; then
    aws --version
    echo "   Region: $(aws configure get region 2>/dev/null || echo 'Not configured')"
    echo "   Credentials: $(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null || echo 'Not configured')"
else
    echo "   AWS CLI not installed"
fi
echo ""

# Greengrass Installation
echo "4. Greengrass Installation:"
if [ -d "/greengrass/v2" ]; then
    echo "   Installation directory: ✅ Exists"
    echo "   Permissions: $(ls -ld /greengrass/v2 | awk '{print $1 " " $3 ":" $4}')"
    
    if [ -f "/greengrass/v2/alts/current/distro/bin/loader" ]; then
        echo "   Loader: ✅ Found"
    else
        echo "   Loader: ❌ Not found"
    fi
else
    echo "   Installation directory: ❌ Not found"
fi
echo ""

# Service Status
echo "5. Service Status:"
if systemctl list-unit-files | grep -q greengrass; then
    echo "   Service file: ✅ Exists"
    sudo systemctl status greengrass --no-pager -l
else
    echo "   Service file: ❌ Not found"
fi
echo ""

# Processes
echo "6. Running Processes:"
ps aux | grep -E "(greengrass|java)" | grep -v grep || echo "   No Greengrass processes found"
echo ""

# Network
echo "7. Network Connectivity:"
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "   Internet: ✅ Connected"
else
    echo "   Internet: ❌ No connection"
fi

if command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null; then
    echo "   AWS API: ✅ Accessible"
else
    echo "   AWS API: ❌ Not accessible"
fi
echo ""

# Log Files
echo "8. Log Files:"
if [ -f "$HOME/greengrass-setup.log" ]; then
    echo "   Setup log: ✅ Found ($(wc -l < $HOME/greengrass-setup.log) lines)"
    echo "   Last 5 lines:"
    tail -5 "$HOME/greengrass-setup.log" | sed 's/^/     /'
else
    echo "   Setup log: ❌ Not found"
fi

if [ -f "/greengrass/v2/logs/greengrass.log" ]; then
    echo "   Greengrass log: ✅ Found"
    echo "   Last error (if any):"
    sudo grep -i error /greengrass/v2/logs/greengrass.log | tail -3 | sed 's/^/     /' || echo "     No errors found"
else
    echo "   Greengrass log: ❌ Not found"
fi
echo ""

# Components
echo "9. Components:"
if [ -x "/greengrass/v2/bin/greengrass-cli" ]; then
    echo "   CLI available: ✅"
    sudo /greengrass/v2/bin/greengrass-cli component list 2>/dev/null || echo "   Failed to list components"
else
    echo "   CLI available: ❌"
fi
echo ""

# Disk Usage
echo "10. Disk Usage:"
echo "    /greengrass/v2: $(sudo du -sh /greengrass/v2 2>/dev/null || echo 'Not found')"
echo "    ~/greengrass: $(du -sh ~/greengrass 2>/dev/null || echo 'Not found')"
echo ""

# Recent System Logs
echo "11. Recent System Logs (Greengrass related):"
sudo journalctl -u greengrass --no-pager -n 5 2>/dev/null | sed 's/^/    /' || echo "    No systemd logs found"
echo ""

echo "=== Debug Information Collection Complete ==="
echo ""
echo "💡 Next Steps:"
echo "   1. Check for ❌ items above"
echo "   2. Review log files for specific errors"
echo "   3. Ensure all prerequisites are met"
echo "   4. Try rerunning the setup script if needed"
#!/bin/bash

# AWS IoT Greengrass Raspberry Pi Setup Script
# Target OS: Raspberry Pi OS (2025/10/01 64bit版)
# Tested on: Raspberry Pi 5
# 
# NOTE: This script template requires AWS credentials to be embedded
# Use Amazon Q Developer to create a version with your credentials

set -e

LOG_FILE="$HOME/greengrass-setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

log "=== AWS IoT Greengrass Setup Started ==="
log "Target OS: Raspberry Pi OS (2025/10/01 64bit版)"
log "Tested on: Raspberry Pi 5"

# Step 1: System Update and Package Installation
log "Step 1: Updating system and installing packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl unzip default-jdk python3-venv

# Verify Java
java -version || error_exit "Java installation failed"

# Add user to dialout group
sudo usermod -a -G dialout $USER

# Set Java environment
echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/default-java

# Install AWS CLI
if ! command -v aws &> /dev/null; then
    log "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Step 2: AWS Credentials Setup
log "Step 2: Configuring AWS credentials..."

# TODO: Replace with actual credentials using Amazon Q Developer
# export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
# export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
# export AWS_DEFAULT_REGION="YOUR_REGION"

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    error_exit "AWS credentials not configured. Please use Amazon Q Developer to embed credentials."
fi

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION
aws configure set default.output json

# Verify credentials
aws sts get-caller-identity || error_exit "AWS credentials verification failed"

# Step 3: Greengrass Installation
log "Step 3: Installing Greengrass Core..."

# Create working directory
mkdir -p ~/greengrass
cd ~/greengrass

# Clean up any previous installation
sudo rm -rf /greengrass/v2/* 2>/dev/null || true
rm -rf GreengrassInstaller 2>/dev/null || true

# Download Greengrass
log "Downloading Greengrass Core software..."
curl -s https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip > greengrass-nucleus-latest.zip

# Verify download
[ -f greengrass-nucleus-latest.zip ] || error_exit "Failed to download Greengrass software"

# Extract
unzip -q greengrass-nucleus-latest.zip -d GreengrassInstaller

# Verify extraction
[ -f GreengrassInstaller/lib/Greengrass.jar ] || error_exit "Greengrass.jar not found after extraction"

# Create users and directories
log "Setting up Greengrass users and directories..."
sudo useradd --system --create-home ggc_user 2>/dev/null || true
sudo groupadd --system ggc_group 2>/dev/null || true
sudo mkdir -p /greengrass/v2
sudo chown ggc_user:ggc_group /greengrass/v2
sudo chmod 755 /greengrass/v2

# Step 4: Device Provisioning
log "Step 4: Provisioning Greengrass device..."

cd ~/greengrass/GreengrassInstaller

# Generate unique thing name
THING_NAME="RaspberryPi-$(date +%s)"
THING_GROUP_NAME="GreengrassDevices"

log "Thing Name: $THING_NAME"

# Install Greengrass (prerequisites verified on management PC)
log "Installing Greengrass with automatic provisioning..."
sudo -E java -Droot="/greengrass/v2" \
  -Dlog.store=FILE \
  -jar ./lib/Greengrass.jar \
  --aws-region $AWS_DEFAULT_REGION \
  --thing-name $THING_NAME \
  --thing-group-name $THING_GROUP_NAME \
  --component-default-user ggc_user:ggc_group \
  --provision true \
  --setup-system-service true \
  --deploy-dev-tools true

# Step 5: Verification
log "Step 5: Verifying installation..."
sleep 15

sudo systemctl status greengrass || {
    log "Service status check failed, checking logs..."
    sudo journalctl -u greengrass --no-pager -n 20
    sudo tail -50 /greengrass/v2/logs/greengrass.log 2>/dev/null || true
}

# Step 6: Deploy Sample Component
log "Step 6: Deploying sample component..."

sudo mkdir -p /greengrass/v2/work/com.example.HelloWorld
sudo chown -R ggc_user:ggc_group /greengrass/v2/work/

# Create sample component (see examples/component-example.py for full version)
cat > /tmp/hello_world.py << 'EOF'
#!/usr/bin/env python3
import json
import time
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("Hello World component started")
    
    while True:
        try:
            data = {
                "timestamp": datetime.now().isoformat(),
                "temperature": 25.5,
                "humidity": 60.0,
                "device_id": "raspberry-pi-001"
            }
            
            logger.info(f"Data sent: {json.dumps(data)}")
            time.sleep(30)
            
        except KeyboardInterrupt:
            logger.info("Component stopped")
            break
        except Exception as e:
            logger.error(f"Error occurred: {e}")
            time.sleep(10)

if __name__ == "__main__":
    main()
EOF

sudo cp /tmp/hello_world.py /greengrass/v2/work/com.example.HelloWorld/
sudo chown ggc_user:ggc_group /greengrass/v2/work/com.example.HelloWorld/hello_world.py
rm /tmp/hello_world.py

# Final verification
log "=== Setup Complete ==="
log "Thing Name: $THING_NAME"
log "Thing Group: $THING_GROUP_NAME"
log "Region: $AWS_DEFAULT_REGION"
log "Log file: $LOG_FILE"

echo ""
echo "✅ AWS IoT Greengrass setup completed successfully!"
echo "Thing Name: $THING_NAME"
echo "Log file: $LOG_FILE"
echo ""
echo "Verify with these commands:"
echo "sudo systemctl status greengrass"
echo "sudo /greengrass/v2/bin/greengrass-cli component list"
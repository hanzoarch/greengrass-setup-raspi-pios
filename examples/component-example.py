#!/usr/bin/env python3
"""
AWS IoT Greengrass Hello World Component Example

This is a sample component that demonstrates basic Greengrass functionality:
- Logging setup
- Periodic data generation
- Error handling
- Graceful shutdown

Target: Raspberry Pi OS (2025/10/01 64bit版)
"""

import json
import time
import logging
import signal
import sys
from datetime import datetime
from typing import Dict, Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class HelloWorldComponent:
    """Hello World Greengrass Component"""
    
    def __init__(self):
        self.running = True
        self.device_id = "raspberry-pi-001"
        self.interval = 30  # seconds
        
        # Setup signal handlers for graceful shutdown
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
    
    def _signal_handler(self, signum: int, frame) -> None:
        """Handle shutdown signals"""
        logger.info(f"Received signal {signum}, shutting down gracefully...")
        self.running = False
    
    def generate_sensor_data(self) -> Dict[str, Any]:
        """Generate simulated sensor data"""
        return {
            "timestamp": datetime.now().isoformat(),
            "temperature": 25.5,
            "humidity": 60.0,
            "pressure": 1013.25,
            "device_id": self.device_id,
            "component": "HelloWorld",
            "version": "1.0.0"
        }
    
    def publish_data(self, data: Dict[str, Any]) -> None:
        """Publish data (simulated)"""
        # In a real component, this would publish to IoT Core
        logger.info(f"Publishing data: {json.dumps(data, indent=2)}")
    
    def run(self) -> None:
        """Main component loop"""
        logger.info("Hello World component started")
        logger.info(f"Device ID: {self.device_id}")
        logger.info(f"Publish interval: {self.interval} seconds")
        
        while self.running:
            try:
                # Generate and publish sensor data
                sensor_data = self.generate_sensor_data()
                self.publish_data(sensor_data)
                
                # Wait for next iteration
                time.sleep(self.interval)
                
            except Exception as e:
                logger.error(f"Error in main loop: {e}")
                time.sleep(10)  # Wait before retry
        
        logger.info("Hello World component stopped")

def main():
    """Main entry point"""
    try:
        component = HelloWorldComponent()
        component.run()
    except KeyboardInterrupt:
        logger.info("Component interrupted by user")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
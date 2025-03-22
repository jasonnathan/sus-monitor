# META: SUS-MONITOR

## Folder Structure

```plaintext
/Users/jasonnathan/Repos/sus-monitor
├── SusMonitorApp
│   ├── SusMonitorApp
│   ├── SusMonitorApp.xcodeproj
│   ├── SusMonitorAppTests
│   └── SusMonitorAppUITests
├── sus-monitor.py
└── sus-monitor.rb

6 directories, 2 files
```
## File: sus-monitor.py

```py
#!/usr/bin/env python3
import psutil
from pynput.mouse import Listener
import logging
from datetime import datetime
from PIL import ImageGrab
import os
import subprocess

# Setup logging
logging.basicConfig(filename='/usr/local/var/log/sus-monitor.log', level=logging.INFO, format='%(asctime)s: %(message)s')

# Define thresholds
CPU_THRESHOLD = 80
MEMORY_THRESHOLD = 80
CURSOR_MOVE_THRESHOLD = 100  # Change in position to be considered a sudden move

# Variables to track cursor position
last_position = (0, 0)

def send_notification(title, message):
    script = f'display notification "{message}" with title "{title}"'
    subprocess.run(["osascript", "-e", script])

def take_screenshot():
    screenshot = ImageGrab.grab()
    screenshot_path = f'/usr/local/var/sus-monitor/screenshots/{datetime.now().strftime("%Y%m%d%H%M%S")}_screenshot.png'
    screenshot.save(screenshot_path)
    return screenshot_path

def log_current_processes():
    processes_info = ''
    for proc in psutil.process_iter(['pid', 'name', 'username']):
        processes_info += f"PID: {proc.info['pid']}, Name: {proc.info['name']}, User: {proc.info['username']}\n"
    return processes_info

def on_move(x, y):
    global last_position
    dx = abs(x - last_position[0])
    dy = abs(y - last_position[1])
    if dx > CURSOR_MOVE_THRESHOLD or dy > CURSOR_MOVE_THRESHOLD:
        screenshot_path = take_screenshot()
        processes_info = log_current_processes()
        message = f"Sudden cursor movement detected from {last_position} to {(x, y)}. Screenshot saved at {screenshot_path}."
        logging.info(message + f" Process details: {processes_info}")
        send_notification("Cursor Movement Alert", message)
    last_position = (x, y)

def monitor_system():
    cpu_usage = psutil.cpu_percent()
    memory_usage = psutil.virtual_memory().percent
    
    if cpu_usage > CPU_THRESHOLD:
        logging.info(f"High CPU usage detected at {cpu_usage}%")
        send_notification("System Alert", f"High CPU usage at {cpu_usage}%")
    
    if memory_usage > MEMORY_THRESHOLD:
        logging.info(f"High memory usage detected at {memory_usage}%")
        send_notification("System Alert", f"High memory usage at {memory_usage}%")

def run_monitor():
    # Ensure screenshot directory exists
    os.makedirs('/usr/local/var/sus-monitor/screenshots', exist_ok=True)
    
    with Listener(on_move=on_move) as listener:
        while True:
            monitor_system()
            listener.join(60)  # Update every minute

if __name__ == "__main__":
    run_monitor()

```

## Git Repository

```plaintext
origin	git@github.com:jasonnathan/sus-monitor.git (fetch)
origin	git@github.com:jasonnathan/sus-monitor.git (push)
```

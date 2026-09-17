# Employee Activity Monitor Agent

A protected Windows agent that tracks employee activity with anti-tampering features.

## Key Features

- **Protected Mode**: Agent cannot be closed without admin approval
- **Auto-Restart**: Agent restarts automatically if terminated
- **Auto-Start**: Runs automatically when Windows starts

## One-Click Installation

1. **Double-click `setup.bat`** - That's it!

The installer will automatically:
- Install Python if not present
- Install all required packages
- Configure auto-start on Windows login
- Launch the agent

## How Close Protection Works

When an employee tries to close the agent:
1. Right-click tray icon → "Request Close (Requires Approval)"
2. Request is sent to admin dashboard
3. Admin receives notification and can approve/deny
4. Agent only closes if admin approves

## Configuration

Edit `config.json` to customize:

| Option | Default | Description |
|--------|---------|-------------|
| `api_key` | (required) | Employee's unique API key |
| `api_url` | (preset) | Backend API URL |
| `activity_interval` | 30 | Seconds between activity logs |
| `screenshot_interval` | 600 | Seconds between screenshots (10 min) |
| `idle_threshold` | 300 | Seconds before marked idle (5 min) |
| `screenshot_quality` | 60 | JPEG quality (1-100) |

## Getting the API Key

1. Log into the admin dashboard
2. Go to **Agent Download** page
3. Select the employee and download the personalized installer (API key pre-configured!)

## System Tray

The agent runs in the system tray (bottom-right corner):
- **Green icon**: Running normally
- **Right-click menu**:
  - Request Close: Sends close request to admin for approval

## Troubleshooting

### "Python not found"
Install from python.org and ensure "Add to PATH" is checked during installation.

### "Cannot create startup task"
Run `setup.bat` as Administrator (right-click > Run as administrator).

### "Network error"
Check internet connection and verify the API key in config.json.

### Agent restarts after closing
This is by design - the agent is protected and requires admin approval to close.

## Uninstallation (Admin Only)

1. Admin must approve the close request from the dashboard
2. Open Task Scheduler and delete "EmployeeMonitorAgent" task
3. Delete the agent folder

---

For support, contact your IT administrator.


## Automatic background operation

Run `setup.bat` only once. The installer:

- Installs Python dependencies.
- Registers a Windows Scheduled Task named `ActivityTrack Employee Agent`.
- Starts the agent immediately using `pythonw.exe` when available.
- Starts the visible system-tray agent automatically after every Windows login.
- Configures limited automatic restart after an unexpected crash.

You do not need to run `employee_agent.py` manually again.

The agent remains visible in the system tray. To remove automatic startup, run
`remove-autostart.ps1`. This does not delete the agent files.

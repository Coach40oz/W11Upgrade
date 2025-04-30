# Windows 11 Lightweight Upgrade Script

A PowerShell script to force upgrade Windows 10 machines to Windows 11, bypassing hardware checks and TPM requirements. This no-ISO approach is designed for mass deployment via RMM tools.

## Features

- **No ISO Required**: Downloads the Windows 11 Installation Assistant directly from Microsoft
- **Bypasses Hardware Checks**: Sets registry keys to bypass TPM, CPU, and other hardware requirements
- **Silent Installation**: Runs with parameters to minimize user interaction
- **RMM Friendly**: Small footprint makes it easy to deploy via RMM tools
- **Self-Contained**: Creates all necessary folders and handles the complete upgrade process

## Compatibility

- **Tested successfully with Gorelo RMM tool**
- Should work with any RMM solution that can run PowerShell scripts
- If you test this with other RMM tools, please leave a comment with your results!

## How It Works

1. Creates a C:\Win11 folder for downloads and logs
2. Sets registry keys to bypass Windows 11 hardware requirements
3. Downloads the Windows 11 Installation Assistant (~4MB) directly from Microsoft
4. Runs the Installation Assistant with silent parameters
5. The Installation Assistant downloads and installs Windows 11 in the background

## Usage

### Manual Deployment

1. Download the `Win11Upgrade.ps1` script
2. Run PowerShell as Administrator
3. Execute the script: `.\Win11Upgrade.ps1`

### RMM Deployment

1. Upload the script to your RMM platform
2. Deploy as a PowerShell script with Administrator privileges
3. No command-line parameters needed

## Script Parameters

The Windows 11 Installation Assistant is launched with these parameters:

- `/QuietInstall` - Performs installation without user interaction
- `/SkipEULA` - Bypasses the End User License Agreement prompt
- `/auto upgrade` - Automatically performs the upgrade
- `/NoRestartUI` - Suppresses restart UI prompts
- `/copylogs $dir` - Copies logs to our folder

## Expected Timeline

The upgrade process typically takes:
- 30-120 minutes for downloading (depending on internet speed)
- 30-60 minutes for installation
- Total time: 1-4 hours

The system will restart automatically when ready.

## Troubleshooting

If the upgrade doesn't appear to be progressing:

1. Check Task Manager for Windows Update or SetupHost processes
2. Check Windows Update section in Settings
3. Look for the creation of C:\$WINDOWS.~BT folder (appears during installation)
4. Check logs in C:\Win11

## Disclaimer

- This script modifies registry settings to bypass Microsoft's hardware requirements
- Use at your own risk on machines that don't meet Windows 11 requirements
- Always backup important data before upgrading
- Not officially supported by Microsoft

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

If you encounter any issues or have suggestions for improvements, please open an issue in the GitHub repository.

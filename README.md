# Windows 11 Lightweight Upgrade Script

A PowerShell script to force-upgrade Windows 10 machines to Windows 11 without an ISO, bypassing hardware checks and TPM requirements. Designed for mass deployment via RMM tools.

---

## Features

* **No ISO Required**: Downloads the Windows 11 Installation Assistant directly from Microsoft.
* **Bypasses Hardware Checks**: Sets registry keys to ignore TPM, CPU, and other requirement checks.
* **Silent Installation**: Runs with flags to minimize or eliminate user interaction.
* **RMM Friendly**: Small footprint and straightforward parameters make it easy to deploy via any RMM solution.
* **Self-Contained**: Creates necessary folders, handles downloads, logging, and launch.

---

## Compatibility

* **Tested** with Gorelo RMM tool.
* **Should Work** with any RMM platform capable of running PowerShell scripts with administrative rights.

> *If you test this on other RMM solutions, please share your results!*

---

## How It Works

1. **Folder Creation**: Creates `C:\Win11` for storing the installer and logs.
2. **Registry Bypass**: Sets keys under `HKLM:\SYSTEM\Setup\MoSetup` to allow upgrades on unsupported hardware.
3. **Download**: Fetches `Windows11InstallationAssistant.exe` (\~4 MB) from Microsoft.
4. **Silent Launch**: Invokes the assistant with parameters to skip the EULA, hardware checks, and UI.
5. **Background Upgrade**: The assistant downloads the full Windows 11 payload and runs the in-place upgrade.

---

## Usage

### One‑Line Execution

Run directly from an elevated PowerShell prompt:

```powershell
iwr https://raw.githubusercontent.com/Coach40oz/W11Upgrade/main/W11.ps1 -UseBasicParsing | iex
```

This downloads and executes the script without saving a local file.

### Manual Deployment

1. Download `Win11Upgrade.ps1`.
2. Open PowerShell **as Administrator**.
3. Run:

   ```powershell
   .\Win11Upgrade.ps1
   ```

### RMM Deployment

1. Upload the script to your RMM platform.

---

## Script Parameters

The script launches the Windows 11 Installation Assistant with these switches:

| Parameter        | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `/QuietInstall`  | Hides interactive UI                                    |
| `/SkipEULA`      | Auto-accepts the End User License Agreement             |
| `/Auto Upgrade`  | Initiates in-place upgrade mode (preserves files/apps)  |
| `/NoRestartUI`   | Suppresses reboot countdown dialog                      |
| `/CopyLogs $dir` | Copies setup logs to the designated folder (`C:\Win11`) |

---

## Expected Timeline

* **Download**: 30–120 minutes (varies by internet speed).
* **Installation**: 30–60 minutes.
* **Total**: 1–4 hours, followed by an automatic reboot when ready.

---

## Troubleshooting

* **No Progress?**

  * Verify `C:\Win11` exists and contains logs.
  * Check Task Manager for **Windows Update**, **Modern Setup Host**, or **SetupHost** processes.
  * Look for `C:\$WINDOWS.~BT` folder creation.
* **Log Locations**:

  * `C:\Win11\Panther\Setupact.log` and `Setuperr.log`
  * Default: `C:\Windows\Panther\` and `C:\$WINDOWS.~BT\Sources\Panther\`
  * CBS: `C:\Windows\Logs\CBS\CBS.log`
* **Compatibility Blocked?**

  * Ensure registry bypass key exists under `HKLM:\SYSTEM\Setup\MoSetup`.
  * Add `/SkipCompatCheck` if needed to skip PC Health Check requirements.

---

## Disclaimer

> This script **modifies registry settings** to bypass Microsoft’s official hardware requirements.
> Use **at your own risk** on unsupported hardware.
> Always **backup important data** before proceeding.
> Not officially supported by Microsoft.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contributing

Contributions are welcome!

* Submit bugs or feature requests via GitHub Issues.
* Open a Pull Request to propose improvements.

Thank you for using and improving this script!

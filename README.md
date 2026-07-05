# Custom-WinC (AutoHotkey v2)

A lightweight and powerful AutoHotkey v2 script that intercepts the native Win+C shortcut in Windows, allowing you to seamlessly redirect it to a custom keyboard hotkey or launch any executable program directly.

## 🚀 Key Features

* **Low-Level Interception:** Blocks the default Windows Copilot action, taking full control of the Win+C key combination.
* **Intuitive Graphical Interface:** Quick and visual configuration directly from the system tray icon.
* **Stealth Key Capture:** Uses an internal input hook engine to register your new hotkey silently, preventing other applications from being triggered accidentally during setup.
* **Secure AppData Deployment:** When the "Start with Windows" option is enabled, the script automatically clones itself into a secure folder inside `AppData\Roaming\Custom-WinC`. This ensures the tool keeps working flawlessly even if the original downloaded file is moved or deleted.

## ⚙️ Prerequisites

* [AutoHotkey v2.0](https://www.autohotkey.com/) or higher installed.
* Windows 10 or Windows 11 Operating System.

## 🛠️ How to Use

1. Download the script file (`.ahk`) and run it with a double-click.
2. A green icon with the letter "H" will appear in your system tray, next to the Windows clock.
3. Click this icon once to open the configuration window.
4. Choose your desired operation mode:
   * **Send a keyboard shortcut:** Click the capture button and press your combination. The system will automatically record the keys.
   * **Run a program:** Click the browse button and select the `.exe` file of the application you want to open.
5. (Optional) Check the "Start along with Windows" option.
6. Click **Save and Close**. Press Win+C at any time to test it out!

## ⚠️ Important Notes

* To ensure conflict-free operation on Windows 11, make sure the native Win+C shortcut behavior is turned off or set to "No application selected" within your system settings.
* The configuration file (`config_atalho.ini`) is managed automatically and stored cleanly within your user profile (AppData) rather than cluttering your workspace.

## 📄 License

This project is distributed under the MIT License. Feel free to use, modify, and improve the code as needed.

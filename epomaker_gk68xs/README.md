# Configuration for the EPOMAKER GK68XS keyboard
This configuration file sets keymappings and lighting effects for the keyboard.
Since epomaker provides no official tool for linux to reprogram its keyboards, [https://github.com/pixeltris/GK6X](https://github.com/pixeltris/GK6X) is used.

# Usage
1. Clone the repo
2. Build the solution with `mono`: `xbuild GK6X.sln`
3. Switch to the Build directory: `cd Build`
4. Run the application with sudo: `sudo mono GK6X.exe`

On the first run the tool will create a `UserData/KEYBOARD_MODEL_ID.txt` file.
Copy the contents of the file in this folder to this created file.

# Flash the configuration to the keyboard
To flash the configuration after you have the application running using the above steps, run
```
map
```
command from withing the running application.
When succeeded, the application should return `Done`.


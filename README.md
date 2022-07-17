# Desktop QR Scanner

- This app will scan QR Code by taking screenshot in platform's temp directory. Then, copy the content to Clipboard automatically. You can also click to the text to copy though. 
- It is currently available on **Linux**, **Windows**. It's supposed to work on MacOS as well but I couldn't achieve that yet.

## Prerequirements

For Linux, you need to install **gnome-screenshot**. That's because it uses `gnome-screenshot` to take screenshot underneath.
```
sudo apt install gnome-screenshot
```
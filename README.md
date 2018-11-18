# <img src='theia.png' card_color='#40DBB0' width='50' style='vertical-align:bottom'/> THEIA for Mycroft
VS Code experience on your Mycroft device.

## About
Installs and setup THEIA IDE localy on your Mycroft device

## Description
This will install Theia IDE on your Mycroft device. This makes it easy to make and edit skills for Mycroft. Thiea IDE integrates whith Github, and you can use mycroft tools like mycroft-msm and mycroft-msk directly from the integrated shell in the IDE.
Theia provides the VS Code experience in the browser. Developers familiar with Microsoft's VS code editor will find many familiar features and concepts.

https://www.theia-ide.org/index.html

## Warning
Be aware that mark_1 came with only  a 4 GB ssd card. So if you hassnt changed that, the installation will fail.

## How to install
SSH to your mycroft device and make a folder in your home directory (or where you like it) and cd into that. Get the latest instalationcript from github.
Then make that execuable and run it.
After 15 to 30 min installation is finish. While installing, your device will be really slow as there is some heavy work beeing done.

When done, you can acces the IDE on htttp://<hostname>:3000 - like http://picroft:3000

```
mkdir theia-ide
cd theia-ide
wget https://github.com/andlo/theia-for-mycroft/releases/download/v0.1.0/theia-for-mycroft.sh
chmod +x theia-for-mycroft.sh
./theia-for-mycroft.shell
```
## Credits
Andreas Lorensen (@andlo)

## Supported Devices
platform_mark1 platform_picroft

## Category
**Configuration**

## Tags
#theia
#IDE
#editor
#dev

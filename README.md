# <img src='theia.png' card_color='#40DBB0' width='50' style='vertical-align:bottom'/> THEIA for Mycroft
VS Code experience on your Mycroft device.

## About
This repo holds the scrpts for making and running THEIA IDE on a mycroft device and the precompiled packages

The skill that installs and use THEIA IDE on a mycroft device is locatet on a nother githup repo.

https://github.com/andlo/theia-ide-skill

## Usage
* clone the repo
* run build_release.sh
* run patch_dugite.sh
* package relese dir

On Rpi there is limited ram, so to compile without errors there is need for using zram.
use https://github.com/novaspirit/rpi_zram
Also stop mycroft services if they are running as they take up most of the ram.


## Credits
Andreas Lorensen (@andlo)

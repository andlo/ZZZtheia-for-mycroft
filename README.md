# <img src='theia.png' card_color='#40DBB0' width='50' style='vertical-align:bottom'/> THEIA for Mycroft
VS Code experience on your Mycroft device.

## About
This repo holds the scripts for making and running THEIA IDE on a Mycroft device and releases of precompiled packages for several architectures.

A skill which installs and uses THEIA IDE on a Mycroft device can be found located in the [THEIA Skill](https://github.com/andlo/theia-ide-skill) repo, or in the [Mycroft Marketplace](https://market.mycroft.ai/skills) under "THEIA IDE".

## Usage
Most will simply run the THEIA Skill which automatically downloads the [pre-built binaries for the Mark 1 and Picroft platforms](https://github.com/andlo/theia-for-mycroft/releases).

If you want to compile your own binaries:
* clone this repo
* run build_release.sh
* package relese dir

On a Raspberry Pi there is limited RAM, so to compile without errors you need to use [zram](https://github.com/novaspirit/rpi_zram).
Also stop Mycroft services during the compile, as they take up most of the available memory.

## Credits
Andreas Lorensen (@andlo)

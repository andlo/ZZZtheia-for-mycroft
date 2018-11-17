#!/bin/sh
#
# Create a distributable archive of the current version 

VER=`cat VERSION`

../makeself-2.4.0/makeself.sh --current ./theia-for-mycroft theia-for-mycroft-$VER.sh "THEIA IDE for Mycroft v$VER" ./auto_run.sh

                    FLIGHTGEAR "BOURRASQUE" AIRCRAFT - README

Did you know ?
==============

bourrasque is a french word synonyme of "rafale" ;)

pronounce : \bu.ʁask\
- EN : squall
- DE : Windstoß
- ES : chubasco
- IT : burrasca
- RU : порыв

This aircraft is NOT a rafale, I just modeled an aircraft as beautiful as it is.
I did not create a REAL aircraft but I tried to make a REALISTIC aircraft.


How to install ?
================

aircraft install :
http://wiki.flightgear.org/Howto:Install_aircraft

wingman demo install :
copy the file wingman_brsq_demo.xml in $FGDATA/AI/ directory


How to start ?
==============

1/ first, loose 2 minutes to read
---------------------------------
- HELP.txt
- FEATURES.txt
- Known bugs below

2/ sorry, it's a beta
---------------------

for the best experience I recommend :
- use flightgear version >= 2016.3.1
- to see lights, shadows and reheat, enable ALS (atmospheric light scattering)
- to ride a rocket, launch fgfs with parameter --enable-fuel-freeze --prop:/sim/fuel-fraction=0.1

3/ launch
---------

choose launch from terminal or graphical user interface (gui)

edit, change the paths and launch flightgear from a terminal :
    - on Windows : run_fgfs_with_bourrasque.bat
    - on Linux : chmod 0700 run_fgfs_with_bourrasque.sh && ./run_fgfs_with_bourrasque.sh
OR
launch flightgear from a gui and select the aircraft : bourrasque

enjoy ;)


Known bugs :(
=============

- not yet trim !
- as I only got a mouse, flying with joystick could be difficult because no test done
- some interior sounds triggered when view change
- instability on ground when turning too fast and too short
- strobe enabled even if main electric on OFF
- hud/minihud not shown as expected during starting
- heading bug and radial on ND, PFD, stdby-hsi, if mag or true north choosen
- uvmap tanks
- strobe doesnt work yet in MP
- ND and instrument animations in MP backseat


How to help for developpment ?
==============================

- read HELP.txt
- read LAYOUT.txt
- read FILES.txt
- read TODO.txt
- ask me to get ressources.tar.gz file, it contains blender, xcf, scripts, doc
- improve and discuss on forum
- KEEP IN MIND theese keywords : keep it simply stupid (KISS), lean, maintainability, reusability, correct indentation
- please dont copy/past from other aircrafts, ok it's more fast but could creates a technical debt (https://en.wikipedia.org/wiki/Technical_debt)
- test
- update TODO, CHANGELOG, FEATURES and ... AUTHORS ;)
- post me your changes





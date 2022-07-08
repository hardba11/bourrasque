                    FLIGHTGEAR "BOURRASQUE" AIRCRAFT - README

Did you know ?
================================================================================

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
================================================================================

aircraft install :
http://wiki.flightgear.org/Howto:Install_aircraft

AI demo install :

- tanker : see ai/README-tanker-rafale-marine.txt
- timed loop : see ai/README-timed-loop.txt
- wingmen : see ai/README-wingmen.txt


How to start ?
================================================================================

1/ first, loose 2 minutes to read
---------------------------------

- HELP.txt : aircraft documentation for pilot
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

launch flightgear from a gui and select the aircraft : bourrasque, als enabled

enjoy ;)


Known bugs :(
================================================================================

- as I only got a mouse, flying with joystick could be difficult because no test could have been done
- heading bug on ND if mag or true north choosen
- strobe doesnt work yet in MP
- instruments animations in MP backseat
- 3D shadow not always on the ground and doesnt work in multiplay


How to help for developpment ?
================================================================================

- read HELP.txt
- read LAYOUT.txt
- read FILES.txt
- read TODO.txt
- ask me to get ressources.tar.gz file, it contains blender, xcf, scripts, doc
- improve and discuss on forum
- KEEP IN MIND theese keywords : keep it simply stupid (KISS), lean, maintainability, reusability, correct indentation
- please dont copy/past from other aircrafts, ok it's more fast but day after days, it could creates a technical debt (https://en.wikipedia.org/wiki/Technical_debt)
- test
- update TODO, CHANGELOG, FEATURES and ... AUTHORS ;)
- post me your changes (merge request on github)





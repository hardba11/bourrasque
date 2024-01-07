the purpose of the tool trace-loop is to record a loop during a flight to create a timed-loop AI scenario.

description
-----------
A loop contains airborn doors you have to go throught, you have to get each door and do the loop in the best time.
You have some beginning and ending doors to help you to find the starting door.


how to
================================================================================

recording doors coordinates when flying
---------------------------------------

first, you have to record your loop
you will have to hit a key to switch between each type of doors (beginning, loop, ending doors)
the key is > : on qwerty keyboard (the key is at the right of the left shift key)

1- launch fgfs, you have to enable console
2- keep the console-window shown beside the flightgear-window
3- takeoff
4- few seconds after, hit the key >, you begin to record beginning doors positions
5- at the beginning of the loop, hit the key >, you begin to record loop doors positions
6- at the end of the loop, hit the key >, you begin to record ending doors positions
7- at the end of the ending doors, hit the key >, you end the recording and dump the coordinates of each door on the console windows
8- copy/paste each line in a file named trace-loop-INPUT.csv

If you want to record a new time, hit shift > to reinit
Warning, you will loose all previous coordinates.

If it s ok, so you can quit fgfs.


creating ai scenario
--------------------

1- put your file trace-loop-INPUT.csv in the directory tools/trace-loop/
2- open a terminal and run :
    chmod 0700 csv2xml-loop.pl
    ./csv2xml-loop.pl
3- a new file has been created : homemade-timed-loop.xml
4- copy it in the directory fgdata/AI/
5- copy directory bourrasque/ai/homemade-timed-loop/ in the directory fgdata/AI/



testing/using
-------------
1- launch fgfs
2- enable scenario homemade-timed-loop in the menu
3- test





Description
================================================================================

The purpose of the tool trace-loop is to record a loop during a flight TO CREATE A NEW TIMED-LOOP AI SCENARIO.

A loop contains airborn doors you have to go throught, you have to get each door and do the loop in the best time.

You have some beginning and ending doors to help you to find the starting door.


How to
================================================================================

Recording doors coordinates when flying
---------------------------------------

First, you have to "record" your loop. You will have to hit a key to switch between each type of doors (beginning, loop, ending doors).

1. launch fgfs, you have to enable console
2. keep the console-window shown beside the flightgear-window
3. takeoff
4. few seconds after, hit the key `<`, you begin to record beginning doors positions
5. at the beginning of the loop, hit the key `<`, you begin to record timed-loop doors positions
6. at the end of the loop, hit the key `<`, you begin to record ending doors positions
7. at the end of the ending doors, hit the key `<`, you end the recording and dump the coordinates of each door on the console windows
8. copy/paste each line in a file named trace-loop-INPUT.csv

If you want to record a new time, hit `>` to reinit. Warning, you will loose all previous coordinates.

If it is ok, you can quit fgfs.


Creating AI scenario
--------------------

On linux

1. put your file trace-loop-INPUT.csv in the directory tools/trace-loop/
2. open a terminal and run :
        chmod 0700 csv2xml-loop.pl
        ./csv2xml-loop.pl
3. a new file has been created : `homemade-timed-loop.xml`
4. copy it in the directory `fgdata/AI/`
5. copy directory `bourrasque/ai/homemade-timed-loop/` in the directory `fgdata/AI/`


Testing/using
-------------

1. launch fgfs
2. enable scenario homemade-timed-loop in the menu
3. test





Description
-----------

You can choose some tankers for air-air refuelling : KA6-D, A4-F, A330-MRTT and KC-135.

It is possible tu refuel from a Rafale Marine.


How to install ?
----------------

1. copy directory bourrasque/ai/Aircraft/dassault-rafale-M/ in the directory fgdata/AI/Aircraft
2. do a backup copy of file fgdata/AI/tankers.xml
3. copy the file bourrasque/ai/tankers.xml in fgdata/AI/

NB :

If you know xml, you can edit fgdata/AI/tankers.xml and add a new tanker item :

        <tanker>
          <name>Rafale buddy-buddy</name>
          <type>probe</type>
          <model>AI/Aircraft/dassault-rafale-M/dassault-rafale-M.xml</model>
          <speed-kts>250</speed-kts>
          <max-fuel-transfer-lbs-min type="double">1500</max-fuel-transfer-lbs-min>
          <contact>
            <x-m>-15</x-m>
            <z-m>-2</z-m>
          </contact>
        </tanker>



How to use ?
------------

1. launch flightgear
2. open the menu AI/Tanker Controls
3. choose Rafale buddy-buddy in the field Tanker
4. you can adjust some other settings
5. click on the button Request



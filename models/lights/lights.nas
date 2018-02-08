print("*** LOADING lights - lights.nas ... ***");

# namespace : lights

# management of blinking
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.1, 0.05, 1]);
strobe.switch(0);

var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 0.8]);
beacon.switch(0);

var lights = func()
{
    strobe.switch(getprop("/controls/lighting/strobe"));
    beacon.switch(getprop("/controls/lighting/beacon"));
    settimer(lights, 2);
}

setlistener("sim/signals/fdm-initialized", lights);


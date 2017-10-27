print("*** LOADING tool - trace-loop.nas ... ***");

var no_phase = 0;
var buffer_coords = [];
var label_phase = {
    0: "disabled",
    1: "recording entrance",
    2: "recording loop",
    3: "recording exit",
    4: "dumped",
};

# call from input keyboard (key 124)
var event_reinit_loop = func() {
    no_phase = 0;
    buffer_coords = [];
    printf("key pressed - reinit");
}

# call from input keyboard (key 92)
var event_change_phase = func() {
    no_phase += 1;
    if(no_phase > 3)
    {
        foreach(e; buffer_coords)
        {
            print(e);
        }
        no_phase = 4;
        #no_phase = 0;
    }
    printf ("key pressed - %s coords", label_phase[no_phase]);
}

var loop_get_coords = func() {
    if((no_phase > 0) and (no_phase < 4))
    {
        var position = geo.aircraft_position();
        
        var lat = position.lat();
        var lng = position.lon();
        var alt = position.alt();
        var hdg = getprop('/orientation/heading-deg') or 0;
        var pitch = getprop('/orientation/model/pitch-deg') or 0;
        
        append(buffer_coords, sprintf("%s:%s:%s:%d:%d:%d", no_phase, lat, lng, alt, hdg, pitch));
    }
    settimer(loop_get_coords, 4);
}

setlistener('/sim/signals/fdm-initialized', loop_get_coords);


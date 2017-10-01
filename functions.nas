print("*** LOADING my_aircraft_functions - functions.nas ... ***");

# namespace : my_aircraft_functions

var I_MODE              = 0;
var I_DISPLAY_MODE_NUM  = 1;
var I_ND_CENTERED       = 2;
var I_HELMET            = 3;
var I_COPILOT_HEAD      = 4;
var I_AP_SPEED          = 5;
var I_AP_ALT            = 6;
var SETTINGS_MODS = [
    ["TAXI", 0, 1, 37, -25, 10, 0],
    ["APP",  0, 1,  0,   0, 200, 1500],
    ["NAV",  1, 0,  0,  17, 500, 40000],
    ["VFR",  2, 1,  0,  37, 600, 3000],
];


#===============================================================================
#                                                                    CONVERSIONS

# inHg to hPa
var INHG2HPA = 33.86389;

# farenheit to celsius
var DF2DC = func(DF)
{
    if(! DF) DF = 0;
    var out = ((DF - 32) / 1.8);
    return out;
}

# celsius to farenheit
var DC2DF = func(DC)
{
    if(! DC) DC = 0;
    return (DC * 1.8) + 32;
}


#===============================================================================
#                                                                 VIEW ANIMATION
var current_fov = 0;
var current_heading = 0;
var current_pitch = 0;

var save_current_view = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        current_fov     = getprop('/sim/current-view/field-of-view') or 0;
        current_heading = getprop('/sim/current-view/heading-offset-deg') or 0;
        current_pitch   = getprop('/sim/current-view/pitch-offset-deg') or 0;
    }
}
var load_current_view = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', current_fov);
        setprop('/sim/current-view/goal-heading-offset-deg', current_heading);
        setprop('/sim/current-view/goal-pitch-offset-deg', current_pitch);
    }
}

var view_panel_electrical = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 285);
        setprop('/sim/current-view/goal-pitch-offset-deg', -56);
    }
}
var view_panel_engines = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 273);
        setprop('/sim/current-view/goal-pitch-offset-deg', -57);
    }
}
var view_sfd = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 10);
        setprop('/sim/current-view/goal-pitch-offset-deg', -20);
    }
}
var view_panel_command = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 40);
        setprop('/sim/current-view/goal-pitch-offset-deg', -41);
    }
}
var view_panel_light = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 84);
        setprop('/sim/current-view/goal-pitch-offset-deg', -55);
    }
}
var view_panel_radio = func() {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/current-view/field-of-view', 40);
        setprop('/sim/current-view/goal-heading-offset-deg', 325);
        setprop('/sim/current-view/goal-pitch-offset-deg', -45);
    }
}


#===============================================================================
#                                                                         INPUTS
# used in include/input-properties.xml

var throttle_mouse = func() {
    # throttle only if center mouse button pressed
    if(! getprop("/devices/status/mice/mouse[0]/button[1]"))
    {
        return;
    }

    var delta = cmdarg().getNode("offset").getValue() * -4;
    var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
    var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

    var new_thr0_value = thr0_value + delta;
    var new_thr1_value = thr1_value + delta;
    if(size(arg) > 0)
    {
        new_thr0_value = -new_thr0_value;
        new_thr1_value = -new_thr1_value;
    }
    setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
    setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
}

var inc_throttle = func() {

    var locked = getprop("/autopilot/locks/speed");
    if(locked)
    {
        var node = props.globals.getNode("/autopilot/settings/target-speed-kt", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0.0)
        {
            node.setValue(0.0);
        }
    }
    else
    {
        var thr0_value = getprop("/controls/engines/engine[0]/throttle") or 0;
        var thr1_value = getprop("/controls/engines/engine[1]/throttle") or 0;

        var new_thr0_value = thr0_value + arg[0];
        var new_thr1_value = thr1_value + arg[0];

        new_thr0_value = (new_thr0_value < -1.0) ? -1.0 : (new_thr0_value > 1.0) ? 1.0 : new_thr0_value;
        new_thr1_value = (new_thr1_value < -1.0) ? -1.0 : (new_thr1_value > 1.0) ? 1.0 : new_thr1_value;
        setprop("/controls/engines/engine[0]/throttle", new_thr0_value);
        setprop("/controls/engines/engine[1]/throttle", new_thr1_value);
    }
}

var center_flight_controls = func() {
    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/aileron-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
}

var change_mod = func(inc) {
    var current_mod = getprop("/instrumentation/my_aircraft/nd/controls/mode") or "VFR";
    var chosen_mod_number = 0;

    foreach(var mod ; SETTINGS_MODS)
    {
        if(mod[I_MODE] == current_mod)
        {
            break;
        }
        chosen_mod_number += 1;
    }
    chosen_mod_number += inc;
    set_mod(SETTINGS_MODS[math.mod(chosen_mod_number, 4)][I_MODE]);
}

var set_mod = func(current_mod) {
    var chosen_mod_number = 0;
    foreach(var mod ; SETTINGS_MODS)
    {
        if(mod[I_MODE] == current_mod)
        {
            break;
        }
        chosen_mod_number += 1;
    }
    setprop("/instrumentation/my_aircraft/nd/controls/mode",           SETTINGS_MODS[chosen_mod_number][I_MODE]);
    setprop("/instrumentation/my_aircraft/nd/inputs/display-mode-num", SETTINGS_MODS[chosen_mod_number][I_DISPLAY_MODE_NUM]);
    setprop("/instrumentation/my_aircraft/nd/inputs/nd-centered",      SETTINGS_MODS[chosen_mod_number][I_ND_CENTERED]);
    setprop("/controls/pax/helmet",                                    SETTINGS_MODS[chosen_mod_number][I_HELMET]);
    setprop("/controls/pax/copilot-head",                              SETTINGS_MODS[chosen_mod_number][I_COPILOT_HEAD]);
#    setprop("/autopilot/settings/target-speed-kt",                     SETTINGS_MODS[chosen_mod_number][I_AP_SPEED]);
#    setprop("/autopilot/settings/target-altitude-ft",                  SETTINGS_MODS[chosen_mod_number][I_AP_ALT]);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}


#===============================================================================
#                                                                          TOOLS

var reload_fx = func() {
    fgcommand("reinit", props.Node.new({ subsystem: "sound" }));
}

var check_source_aliases = func() {
    var list_of_properties = [
        '/orientation/pitch-deg',
        '/orientation/roll-deg',
        '/orientation/heading-magnetic-deg',
    ];
    
    for(var i = 0 ; i < size(list_of_properties) ; i += 1)
    {
        var property = list_of_properties[i];
        var value = getprop(property);
        if(! value) value = 'NULL !';
        printf ("la propriete %s vaut %s", property, value);
    }
}

var dump_properties = func() {
    io.write_properties('/home/nico/.fgfs/Export/foo.xml', '/');
}






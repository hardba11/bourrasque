print("*** LOADING my_aircraft_functions - functions.nas ... ***");

# namespace : my_aircraft_functions

var I_MODE              = 0;
var I_DISPLAY_MODE_NUM  = 1;
var I_ND_CENTERED       = 2;
var I_HELMET            = 3;
var I_COPILOT_HEAD      = 4;
var I_SFD               = 5;
var I_AP_SPEED          = 6;
var I_AP_ALT            = 7;
var SETTINGS_MODS = [
    ["TAXI", 0, 1, 37, -25, "EICAS", 20, 0],
    ["APP",  0, 1,  0,   0, "EICAS", 250, 1500],
    ["NAV",  1, 0,  0,  17, "RADAR", 500, 35000],
    ["VFR",  2, 1,  0,  37, "RADAR", 800, 3000],
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

var LBS2KG = 0.45359237;


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
    if(! getprop('/devices/status/mice/mouse[0]/button[1]'))
    {
        return;
    }

    var delta = cmdarg().getNode("offset").getValue() * -4;
    var thr0_value = getprop('/controls/engines/engine[0]/throttle') or 0;
    var thr1_value = getprop('/controls/engines/engine[1]/throttle') or 0;

    var new_thr0_value = thr0_value + delta;
    var new_thr1_value = thr1_value + delta;
    if(size(arg) > 0)
    {
        new_thr0_value = -new_thr0_value;
        new_thr1_value = -new_thr1_value;
    }
    setprop('/controls/engines/engine[0]/throttle', new_thr0_value);
    setprop('/controls/engines/engine[1]/throttle', new_thr1_value);
}

var inc_throttle = func() {

    var locked = getprop('/autopilot/locks/speed');
    if(locked)
    {
        var node = props.globals.getNode('/autopilot/settings/target-speed-kt', 1);
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
        var thr0_value = getprop('/controls/engines/engine[0]/throttle') or 0;
        var thr1_value = getprop('/controls/engines/engine[1]/throttle') or 0;

        var new_thr0_value = thr0_value + arg[0];
        var new_thr1_value = thr1_value + arg[0];

        new_thr0_value = (new_thr0_value < -1.0) ? -1.0 : (new_thr0_value > 1.0) ? 1.0 : new_thr0_value;
        new_thr1_value = (new_thr1_value < -1.0) ? -1.0 : (new_thr1_value > 1.0) ? 1.0 : new_thr1_value;
        setprop('/controls/engines/engine[0]/throttle', new_thr0_value);
        setprop('/controls/engines/engine[1]/throttle', new_thr1_value);
    }
}

var inc_elevator = func() {

    var lock_alt = getprop('/autopilot/locks/altitude') or '';
    if(lock_alt == 'altitude-hold')
    {
        var node = props.globals.getNode('/autopilot/settings/target-altitude-ft', 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(0);
        }
        else if(node.getValue() > 40000)
        {
            node.setValue(40000);
        }
    }
    else
    {
        var elevator_value = getprop('/controls/flight/elevator') or 0;
        var new_elevator_value = elevator_value + arg[0];

        new_elevator_value = (new_elevator_value < -1.0) ? -1.0 : (new_elevator_value > 1.0) ? 1.0 : new_elevator_value;
        setprop('/controls/flight/elevator', new_elevator_value);
    }
}

var inc_aileron = func() {

    var lock_hdg = getprop('/autopilot/locks/heading') or '';
    if(lock_hdg == 'dg-heading-hold')
    {
        var node = props.globals.getNode('/autopilot/settings/heading-bug-deg', 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(node.getValue() + 360.0);
        }
        else if(node.getValue()> 360.0)
        {
            node.setValue(node.getValue() - 360.0);
        }
    }
    else
    {
        var aileron_value = getprop('/controls/flight/aileron') or 0;
        var new_aileron_value = aileron_value + arg[0];

        new_aileron_value = (new_aileron_value < -1.0) ? -1.0 : (new_aileron_value > 1.0) ? 1.0 : new_aileron_value;
        setprop('/controls/flight/aileron', new_aileron_value);
    }
}

var center_flight_controls = func() {
    setprop('/controls/flight/elevator', 0);
    setprop('/controls/flight/aileron', 0);
    setprop('/controls/flight/rudder', 0);
}

var center_flight_controls_trim = func() {
    setprop('/controls/flight/elevator-trim', 0);
    setprop('/controls/flight/aileron-trim', 0);
    setprop('/controls/flight/rudder-trim', 0);
}

var change_mod = func(inc) {
    var current_mod = getprop('/instrumentation/my_aircraft/nd/controls/mode') or 'VFR';
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
    setprop('/instrumentation/my_aircraft/nd/controls/mode',                SETTINGS_MODS[chosen_mod_number][I_MODE]);
    setprop('/instrumentation/my_aircraft/nd/inputs/display-mode-num',      SETTINGS_MODS[chosen_mod_number][I_DISPLAY_MODE_NUM]);
    setprop('/instrumentation/my_aircraft/nd/inputs/nd-centered',           SETTINGS_MODS[chosen_mod_number][I_ND_CENTERED]);
    setprop('/controls/pax/helmet',                                         SETTINGS_MODS[chosen_mod_number][I_HELMET]);
    setprop('/controls/pax/copilot-head',                                   SETTINGS_MODS[chosen_mod_number][I_COPILOT_HEAD]);
    setprop('/instrumentation/my_aircraft/sfd/controls/display_sfd_screen', SETTINGS_MODS[chosen_mod_number][I_SFD]);
    var is_ap_alt_locked = getprop('/autopilot/locks/altitude') or '';
    if(is_ap_alt_locked == '') # altitude-hold
    {
        setprop('/autopilot/settings/target-altitude-ft',                   SETTINGS_MODS[chosen_mod_number][I_AP_ALT]);
    }
    var is_ap_speed_locked = getprop('/autopilot/locks/speed') or '';
    if(is_ap_speed_locked == '') # speed-with-throttle
    {
        setprop('/autopilot/settings/target-speed-kt',                      SETTINGS_MODS[chosen_mod_number][I_AP_SPEED]);
    }
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}

var inc_bingo = func(inc) {
    var bingo_choose          = getprop('/instrumentation/my_aircraft/fuel/bingo/choose') or 0;
    var bingo_distance_minute = getprop('/instrumentation/my_aircraft/fuel/bingo/distance_minute') or 0;
    var bingo_distance_nm     = getprop('/instrumentation/my_aircraft/fuel/bingo/distance_nm') or 0;

    if(bingo_choose == 0)
    {
        var new_bingo_distance_minute = bingo_distance_minute + inc;
        new_bingo_distance_minute = (new_bingo_distance_minute < 0) ? 0 : (new_bingo_distance_minute > 300) ? 300 : new_bingo_distance_minute;
        setprop('/instrumentation/my_aircraft/fuel/bingo/distance_minute', new_bingo_distance_minute);
    }
    else
    {
        var new_bingo_distance_nm = bingo_distance_nm + inc;
        new_bingo_distance_nm = (new_bingo_distance_nm < 0) ? 0 : (new_bingo_distance_nm > 500) ? 500 : new_bingo_distance_nm;
        setprop('/instrumentation/my_aircraft/fuel/bingo/distance_nm', new_bingo_distance_nm);
    }
}

var event_toggle_lights = func() {
    var beacon = getprop('/controls/lighting/beacon') or 0;
    var nav    = getprop('/controls/lighting/nav-lights') or 0;
    var pos    = getprop('/controls/lighting/pos-lights') or 0;
    var strobe = getprop('/controls/lighting/strobe') or 0;

    var toggle_lights = ((beacon * nav * pos * strobe) == 0) ? 1 : 0;

    setprop('/controls/lighting/beacon',     toggle_lights);
    setprop('/controls/lighting/nav-lights', toggle_lights);
    setprop('/controls/lighting/pos-lights', toggle_lights);
    setprop('/controls/lighting/strobe',     toggle_lights);
}

var event_toggle_landing_lights = func() {
    var taxi = getprop('/controls/lighting/taxi-light') or 0;

    var toggle_lights = (taxi == 0) ? 1 : 0;

    setprop('/controls/lighting/taxi-light', toggle_lights);
}

var event_acknowledge_master_caution = func() {
    var is_alert = getprop('/instrumentation/my_aircraft/command_h/is_alert') or 0;
    var is_ack = getprop('/instrumentation/my_aircraft/command_h/ack_alert') or 0;

    # before first click : alert (blinking and alert-sound) :

    # first click : alert remain (no blinking and alert-sound disabled) :
    if((is_alert == 1) and (is_ack == 0))
    {
        setprop('/instrumentation/my_aircraft/command_h/ack_alert', 1);

        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/warn_blink',       0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/alert_blink',      0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/warn_blink',       0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/alert_blink',      0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/warn_blink',    0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/alert_blink',   0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/warn_blink',          0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/alert_blink',         0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/warn_blink',          0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/alert_blink',         0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/warn_blink',          0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/alert_blink',         0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/warn_blink',    0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/alert_blink',   0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/warn_blink',     0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/alert_blink',    0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/warn_blink',        0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/alert_blink',       0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/epu/warn_blink',           0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/epu/alert_blink',          0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/warn_blink',         0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/alert_blink',        0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/warn_blink',       0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/alert_blink',      0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/warn_blink',       0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/alert_blink',      0);
    }
    # second click : reinit
    elsif(is_ack == 1)
    {
        setprop('/instrumentation/my_aircraft/command_h/is_alert', 0);
        setprop('/instrumentation/my_aircraft/command_h/ack_alert', 0);

        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/status',           0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/status',           0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/status',        0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/status',              0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/status',              0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/status',              0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/status',        0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/status',         0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/status',            0);
        setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/status',             0);
    }
}

var event_swap_sfd_screen = func() {
    var current_screen = getprop('/instrumentation/my_aircraft/sfd/controls/display_sfd_screen') or '';

    # first click : alert remain (master caution no blinking and alert-sound disabled) :
    if(current_screen == 'EICAS')
    {
        setprop('/instrumentation/my_aircraft/sfd/controls/display_sfd_screen', 'RADAR');
    }
    # second click : reinit
    elsif(current_screen == 'RADAR')
    {
        setprop('/instrumentation/my_aircraft/sfd/controls/display_sfd_screen', 'EICAS');
    }
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






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
    ['TAXI', 0, 1, 37, -25, 'EICAS', 10, 0],
    ['APP',  0, 1,  0,   0, 'EICAS', 250, 1500],
    ['NAV',  1, 0,  0,  17, 'RADAR', 450, 40000],
    ['VFR',  2, 1,  0,  37, 'RADAR', 800, 3000],
];

var SETTINGS_PANEL_VIEW_LEFT = [
    ['fov', 'heading', 'pitch', 'z', 'x', 'y'],
    [40, 11.6, -25, -3.21, 0, 1.10],        # left MFD
    [30.52, 0, -35, -3.21, 0, 0.99],        # center stdby instruments
    [33.86, 45, -55, -3.45, -0.21, 0.99],   # command
    [33.86, 90, -70, -3.21, -0.23, 0.87],   # lights
    [33.86, 45, -55, -3.45, -0.21, 0.99],   # command
    [30.52, 0, -35, -3.21, 0, 0.99],        # center stdby instruments
];

var SETTINGS_PANEL_VIEW_RIGHT = [
    ['fov', 'heading', 'pitch', 'z', 'x', 'y'],
    [40, -11.6, -25, -3.21, 0, 1.10],       # right MFD
    [30.52, 0, -35, -3.21, 0, 0.99],        # center stdby instruments
    [48.72, -60, -55, -3.63, 0.21, 0.85],   # radio
    [33.86, -87, -70, -3.21, 0.23, 0.87],   # systems
    [48.72, -60, -55, -3.63, 0.21, 0.85],   # radio
    [30.52, 0, -35, -3.21, 0, 0.99],        # center stdby instruments
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
var current_z = 0;
var current_x = 0;
var current_y = 0;

var view_cockpit_panels_number = 0;
var view_cockpit_panels = func(inc)
{
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if((view_number == 0) and (view_cockpit_panels_number == 0))
    {
        save_current_view();
    }

    # inc positif : on fait defiler les vues de droite :
    if((view_number == 0) and (inc > 0))
    {
        view_cockpit_panels_number += 1;
        if(view_cockpit_panels_number >= size(SETTINGS_PANEL_VIEW_RIGHT))
        {
        }
        elsif(view_cockpit_panels_number > 0)
        {
            setprop("/sim/current-view/field-of-view",           SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][0]);
            setprop("/sim/current-view/goal-heading-offset-deg", SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][1]);
            setprop("/sim/current-view/goal-pitch-offset-deg",   SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][2]);
            setprop("/sim/current-view/z-offset-m",              SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][3]);
            setprop("/sim/current-view/x-offset-m",              SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][4]);
            setprop("/sim/current-view/y-offset-m",              SETTINGS_PANEL_VIEW_RIGHT[view_cockpit_panels_number][5]);
        }
        else
        {
            view_cockpit_panels_number = 0;
            load_current_view();
        }
    }

    # inc negatif : on fait defiler les vues de gauche :
    elsif((view_number == 0) and (inc < 0))
    {
        view_cockpit_panels_number -= 1;
        if(-view_cockpit_panels_number >= size(SETTINGS_PANEL_VIEW_LEFT))
        {
        }
        elsif(view_cockpit_panels_number < 0)
        {
            setprop("/sim/current-view/field-of-view",           SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][0]);
            setprop("/sim/current-view/goal-heading-offset-deg", SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][1]);
            setprop("/sim/current-view/goal-pitch-offset-deg",   SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][2]);
            setprop("/sim/current-view/z-offset-m",              SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][3]);
            setprop("/sim/current-view/x-offset-m",              SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][4]);
            setprop("/sim/current-view/y-offset-m",              SETTINGS_PANEL_VIEW_LEFT[-view_cockpit_panels_number][5]);
        }
        else
        {
            view_cockpit_panels_number = 0;
            load_current_view();
        }
    }
}

var save_current_view = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        current_fov     = getprop("/sim/current-view/field-of-view") or 0;
        current_heading = getprop("/sim/current-view/heading-offset-deg") or 0;
        current_pitch   = getprop("/sim/current-view/pitch-offset-deg") or 0;
        current_z       = getprop("/sim/current-view/z-offset-m") or 0;
        current_x       = getprop("/sim/current-view/x-offset-m") or 0;
        current_y       = getprop("/sim/current-view/y-offset-m") or 0;
    }
}
var load_current_view = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", current_fov);
        setprop("/sim/current-view/goal-heading-offset-deg", current_heading);
        setprop("/sim/current-view/goal-pitch-offset-deg", current_pitch);
        setprop("/sim/current-view/z-offset-m", current_z);
        setprop("/sim/current-view/x-offset-m", 0);
        setprop("/sim/current-view/y-offset-m", current_y);

    }
}

var view_panel_electrical = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 285);
        setprop("/sim/current-view/goal-pitch-offset-deg", -56);
    }
}
var view_panel_engines = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 273);
        setprop("/sim/current-view/goal-pitch-offset-deg", -57);
    }
}
var view_sfd = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 10);
        setprop("/sim/current-view/goal-pitch-offset-deg", -20);
    }
}
var view_panel_command = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 40);
        setprop("/sim/current-view/goal-pitch-offset-deg", -41);
    }
}
var view_panel_light = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 84);
        setprop("/sim/current-view/goal-pitch-offset-deg", -55);
    }
}
var view_panel_radio = func() {
    var view_number = getprop("/sim/current-view/view-number") or 0;
    if(view_number == 0)
    {
        setprop("/sim/current-view/field-of-view", 40);
        setprop("/sim/current-view/goal-heading-offset-deg", 325);
        setprop("/sim/current-view/goal-pitch-offset-deg", -45);
    }
}

#===============================================================================
#                                                                    ENVIRONMENT
# NOT YET USED, NEED DEBUG
var set_max_cloud_layer = func() {
    var node_clouds = props.globals.getNode("/environment/clouds/");
    var max_cloud_layer_alt = 0;
    foreach(var item ; node_clouds.getChildren())
    {
        if(item.getName() == 'layer')
        {
            var elevation_ft = item.getNode("elevation-ft").getValue();
            max_cloud_layer_alt = (elevation_ft > max_cloud_layer_alt) ? elevation_ft : max_cloud_layer_alt;
        }
    }
    setprop("/environment/clouds/max-layer", max_cloud_layer_alt);
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

var inc_elevator = func() {

    var lock_alt = getprop("/autopilot/locks/altitude") or '';
    if(lock_alt == 'altitude-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/target-altitude-ft", 1);
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
        var elevator_value = getprop("/controls/flight/elevator") or 0;
        var new_elevator_value = elevator_value + arg[0];

        new_elevator_value = (new_elevator_value < -1.0) ? -1.0 : (new_elevator_value > 1.0) ? 1.0 : new_elevator_value;
        setprop("/controls/flight/elevator", new_elevator_value);
    }
}

var inc_aileron = func() {

    var lock_hdg = getprop("/autopilot/locks/heading") or '';
    if(lock_hdg == 'dg-heading-hold')
    {
        var node = props.globals.getNode("/autopilot/settings/heading-bug-deg", 1);
        if(node.getValue() == nil)
        {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if(node.getValue() < 0)
        {
            node.setValue(node.getValue() + 360.0);
        }
        elsif(node.getValue() > 360.0)
        {
            node.setValue(node.getValue() - 360.0);
        }
    }
    else
    {
        var aileron_value = getprop("/controls/flight/aileron") or 0;
        var new_aileron_value = aileron_value + arg[0];

        new_aileron_value = (new_aileron_value < -1.0) ? -1.0 : (new_aileron_value > 1.0) ? 1.0 : new_aileron_value;
        setprop("/controls/flight/aileron", new_aileron_value);
    }
}

var center_flight_controls = func() {
    setprop("/controls/flight/elevator", 0);
    setprop("/controls/flight/aileron", 0);
    setprop("/controls/flight/rudder", 0);
}

var center_flight_controls_trim = func() {
    setprop("/controls/flight/elevator-trim", 0);
    setprop("/controls/flight/aileron-trim", 0);
    setprop("/controls/flight/rudder-trim", 0);
}

var change_mod = func(inc) {
    var current_mod = getprop("/instrumentation/my_aircraft/nd/controls/mode") or 'VFR';
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
    setprop("/instrumentation/my_aircraft/nd/controls/mode",                SETTINGS_MODS[chosen_mod_number][I_MODE]);
    setprop("/instrumentation/my_aircraft/nd/inputs/display-mode-num",      SETTINGS_MODS[chosen_mod_number][I_DISPLAY_MODE_NUM]);
    setprop("/instrumentation/my_aircraft/nd/inputs/nd-centered",           SETTINGS_MODS[chosen_mod_number][I_ND_CENTERED]);
    setprop("/controls/pax/helmet",                                         SETTINGS_MODS[chosen_mod_number][I_HELMET]);
    setprop("/controls/pax/copilot-head",                                   SETTINGS_MODS[chosen_mod_number][I_COPILOT_HEAD]);
    setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", SETTINGS_MODS[chosen_mod_number][I_SFD]);
    var is_ap_alt_locked = getprop("/autopilot/locks/altitude") or '';
    if(is_ap_alt_locked == '') # altitude-hold
    {
        setprop("/autopilot/settings/target-altitude-ft",                   SETTINGS_MODS[chosen_mod_number][I_AP_ALT]);
    }
    var is_ap_speed_locked = getprop("/autopilot/locks/speed") or '';
    if(is_ap_speed_locked == '') # speed-with-throttle
    {
        setprop("/autopilot/settings/target-speed-kt",                      SETTINGS_MODS[chosen_mod_number][I_AP_SPEED]);
    }
    setprop("/sim/model/click", (getprop("/sim/model/click") ? 0 : 1));
}

var inc_bingo = func(inc) {
    var bingo_choose          = getprop("/instrumentation/my_aircraft/fuel/bingo/choose") or 0;
    var bingo_distance_minute = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_minute") or 0;
    var bingo_distance_nm     = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_nm") or 0;

    if(bingo_choose == 0)
    {
        var new_bingo_distance_minute = bingo_distance_minute + inc;
        new_bingo_distance_minute = (new_bingo_distance_minute < 0) ? 0 : (new_bingo_distance_minute > 300) ? 300 : new_bingo_distance_minute;
        setprop("/instrumentation/my_aircraft/fuel/bingo/distance_minute", new_bingo_distance_minute);
    }
    else
    {
        var new_bingo_distance_nm = bingo_distance_nm + inc;
        new_bingo_distance_nm = (new_bingo_distance_nm < 0) ? 0 : (new_bingo_distance_nm > 500) ? 500 : new_bingo_distance_nm;
        setprop("/instrumentation/my_aircraft/fuel/bingo/distance_nm", new_bingo_distance_nm);
    }
}

var disable_hippodrome_if_ap_not_ok = func() {
    var is_hippodrome_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    var ap_heading_mode = getprop("/autopilot/locks/heading")  or '';
    var ap_alt_mode     = getprop("/autopilot/locks/altitude") or '';
    var ap_speed_mode   = getprop("/autopilot/locks/speed")    or '';
    var is_ap_ok = ((ap_heading_mode == 'dg-heading-hold')
        and (ap_alt_mode == 'altitude-hold')
        and (ap_speed_mode == 'speed-with-throttle')
    );

    # disabling hippodrome if ap settings are not valid
    if(! is_ap_ok)
    {
        setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", 0);
    }
}

var event_toggle_hippodrome = func(do_enable) {
    var is_hippodrome_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    var heading_bug_error_deg = math.abs(sprintf('%d', getprop("/autopilot/internal/heading-bug-error-deg") or 0));
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle hippodrome :
        do_enable = (is_hippodrome_enabled == 0) ? 1 : 0;
    }

    # don't enable if turning
    if(heading_bug_error_deg > 4)
    {
        do_enable = 0;
    }

    setprop("/instrumentation/my_aircraft/pfd/controls/hippodrome", do_enable);
    disable_hippodrome_if_ap_not_ok();
}

var event_toggle_lights = func() {
    var beacon = getprop("/controls/lighting/beacon") or 0;
    var nav    = getprop("/controls/lighting/nav-lights") or 0;
    var pos    = getprop("/controls/lighting/pos-lights") or 0;
    var strobe = getprop("/controls/lighting/strobe") or 0;

    var toggle_lights = ((beacon * nav * pos * strobe) == 0) ? 1 : 0;

    setprop("/controls/lighting/beacon",     toggle_lights);
    setprop("/controls/lighting/nav-lights", toggle_lights);
    setprop("/controls/lighting/pos-lights", toggle_lights);
    setprop("/controls/lighting/strobe",     toggle_lights);
}

var event_toggle_landing_lights = func() {
    var taxi = getprop("/controls/lighting/taxi-light") or 0;

    var toggle_lights = (taxi == 0) ? 1 : 0;

    setprop("/controls/lighting/taxi-light", toggle_lights);
}

var event_smoke = func(do_enable) {
    var is_smokepod_installed = getprop("/sim/model/wing-pylons-smoke-pod") or 0;
    var is_smoking = getprop("/sim/model/smoking") or 0;

    if(is_smokepod_installed == 1)
    {
        if(do_enable == -1)
        {
            # do_enable == -1 : toggle
            do_enable = (is_smoking == 0) ? 1 : 0;
        }
        setprop("/sim/model/smoking", do_enable);
    }
}

var event_acknowledge_master_caution = func() {
    setprop("/instrumentation/my_aircraft/command_h/ack_alert", 1);
}

var event_swap_sfd_screen = func() {
    var current_screen = getprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen") or '';

    # first click : alert remain (master caution no blinking and alert-sound disabled) :
    if(current_screen == 'EICAS')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'RADAR');
    }
    # second click : reinit
    elsif(current_screen == 'RADAR')
    {
        setprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen", 'EICAS');
    }
}

var event_toggle_launchbar = func(do_enable) {
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(is_carrier_equiped != 1) { return; }

    var is_launchbar_enabled = getprop("/controls/gear/launchbar") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_launchbar_enabled == 0) ? 1 : 0;
    }

    if(do_enable == 1)
    {
        # lower launchbar
        setprop("/controls/gear/launchbar", 1);

        # raise launchbar if could not have engaged
        settimer(func() {
            var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
            if(state_launchbar != 'Engaged')
            {
                setprop("/controls/gear/catapult-launch-cmd", 0);
                setprop("/controls/gear/launchbar", 0);
            }
        }, 1);
    }
    else
    {
        # raise launchbar unless engaged
        var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
        if(state_launchbar != 'Engaged')
        {
            setprop("/controls/gear/catapult-launch-cmd", 0);
            setprop("/controls/gear/launchbar", 0);
        }
    }
}

var event_launch = func() {
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(is_carrier_equiped != 1) { return; }

    var state_launchbar = getprop("/gear/launchbar/state") or ''; # Disengaged, Engaged, Launching, Completed
    if(state_launchbar == 'Engaged')
    {
        # catapult launching command
        setprop("/controls/gear/catapult-launch-cmd", 1);
        # reinit some values after launch (~2 seconds)
        settimer(func() {
            setprop("/controls/gear/launchbar", 0);
            setprop("/controls/gear/catapult-launch-cmd", 0);
        }, 2);
    }
}

var event_control_canopy = func() {

    var is_on_ground = getprop("/gear/gear[1]/wow") or 0;
    var command_position = getprop("/controls/doors/canopy") or 0;

    if(is_on_ground)
    {
        if(command_position == 1)
        {
            # open to half
            command_position = 0.601;
            canopy_sound = '';
        }
        elsif(command_position > 0.6009)
        {
            # half to close
            command_position = 0;
            canopy_sound = 'lock';
        }
        elsif(command_position == 0)
        {
            # close to half
            command_position = 0.6;
            canopy_sound = 'unlock';
        }
        else
        {
            # half to open
            command_position = 1;
            canopy_sound = '';
        }
#print("DEBUG2 "~ command_position ~ " >> "~ canopy_sound) ;
        setprop("/controls/doors/canopy", command_position);
        setprop("/sim/model/canopy_sound", canopy_sound);
    }
}


var event_control_gear = func(down, animate_view) {

    var is_on_ground = getprop("/gear/gear[1]/wow") or 0;
    if(down == -1)
    {
        # down == -1 : toggle gears :
        var is_down = getprop("/controls/gear/gear-down") or 0;
        down = (is_down == 0) ? 1 : 0;
    }

    if((down == 1) and (is_on_ground == 0))
    {
        # down == 1 : extend gears :
        if(animate_view == 1)
        {
            save_current_view();
            view_panel_command();
            settimer(func() { setprop("/controls/gear/gear-down", 1); setprop("sim/model/lever_gear", 1); }, .3);
            settimer(func() { load_current_view(); }, .5);
        }
        else
        {
            setprop("/controls/gear/gear-down", 1);
            setprop("sim/model/lever_gear", 1);
        }
        # retract refuel pod pipe
        setprop("/controls/refuel-pod/pipe-extended", 0);
    }
    elsif((down == 0) and (is_on_ground == 0))
    {
        # down == 0 : retract gears :
        if(animate_view == 1)
        {
            setprop("/controls/gear/launchbar", 0);
            setprop("/controls/gear/catapult-launch-cmd", 0);
            save_current_view();
            view_panel_command();
            settimer(func() { setprop("/controls/gear/gear-down", 0); setprop("sim/model/lever_gear", 0); }, 0.3);
            settimer(func() { load_current_view(); }, 0.5);
        }
        else
        {
            setprop("/controls/gear/launchbar", 0);
            setprop("/controls/gear/catapult-launch-cmd", 0);
            setprop("/controls/gear/gear-down", 0);
            setprop("sim/model/lever_gear", 0);
        }
    }
}

var event_control_pod_pipe = func(extend) {

    var is_gear_down = getprop("/controls/gear/gear-down") or 0;
    var center_pod = getprop("/sim/model/center-refuel-pod") or 0;
    
    if(center_pod == 1)
    {
        if(extend == -1)
        {
            # retract == -1 : toggle pipe :
            var is_extended = getprop("/controls/refuel-pod/pipe-extended") or 0;
            extend = (is_extended == 0) ? 1 : 0;
        }

        if((extend == 1) and (is_gear_down == 0))
        {
            # extend == 1 : extend pipe :
            setprop("/controls/refuel-pod/pipe-extended", 1);
            setprop("/refuel/contact", 1);
            setprop("/tanker", 1);
        }
        elsif((extend == 0) and (is_gear_down == 0))
        {
            # extend == 0 : retract pipe :
            setprop("/controls/refuel-pod/pipe-extended", 0);
            setprop("/refuel/contact", 0);
            setprop("/tanker", 0);
        }
    }
}

var event_choose_enabled_cams = func() {
    # refueling cam if pod
    var center_pod = getprop("/sim/model/center-refuel-pod") or 0;
    if(center_pod == 1)
    {
        setprop("/sim/view[104]/enabled", 1);
        setprop("/sim/view[102]/enabled", 0);
    }
    else
    {
        setprop("/sim/view[104]/enabled", 0);
        setprop("/sim/view[102]/enabled", 1);
    }

    # tail cam si backseat vide
    var is_copilot = getprop("/controls/pax/copilot") or 0;
    if(is_copilot == 1)
    {
        setprop("/sim/view[105]/enabled", 0);
        setprop("/sim/view[103]/enabled", 1);
    }
    else
    {
        setprop("/sim/view[105]/enabled", 1);
        setprop("/sim/view[103]/enabled", 0);
    }
}

var event_toggle_carrier_equipment = func(do_enable) {
    var is_carrier_equiped = getprop("/sim/model/carrier-equipment") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_carrier_equiped == 0) ? 1 : 0;
    }
    setprop("/sim/model/carrier-equipment", do_enable);
    setprop("/controls/gear/catapult-launch-cmd", do_enable);
    setprop("/controls/gear/launchbar", 0);
}

var event_toggle_jato = func(do_enable) {

    var engine_throttle = props.globals.getNode("/controls/engines/engine[1]/throttle");
    var jato_throttle = props.globals.getNode("/controls/jato/throttle");
    var jato_null = props.globals.getNode("/controls/jato/null");

    if(do_enable == 1)
    {
        jato_throttle.unalias();
        jato_throttle.alias(engine_throttle);
    }
    else
    {
        jato_throttle.unalias();
        jato_throttle.alias(jato_null);
    }
    setprop("/controls/jato/enabled", do_enable);
}

var event_load_store = func(place, load) {
    if(place == 'wing')
    {
        if(load == 'none')
        {
            setprop("/sim/model/wing-tanks-1250", 0);
            setprop("/sim/model/wing-tanks-2000", 0);
        }
        elsif(load == 'tank-1250')
        {
            setprop("/sim/model/wing-tanks-1250", 1);
            setprop("/sim/model/wing-tanks-2000", 0);
        }
        elsif(load == 'tank-2000')
        {
            setprop("/sim/model/wing-tanks-1250", 0);
            setprop("/sim/model/wing-tanks-2000", 1);
        }
        elsif(load == 'tank-1250+tank-2000')
        {
            setprop("/sim/model/wing-tanks-1250", 1);
            setprop("/sim/model/wing-tanks-2000", 1);
        }
    }
    elsif(place == 'center')
    {
        if(load == 'none')
        {
            setprop("/sim/model/center-tank-1250", 0);
            setprop("/sim/model/center-tank-2000", 0);
            setprop("/sim/model/center-refuel-pod", 0);
        }
        elsif(load == 'tank-1250')
        {
            setprop("/sim/model/center-tank-1250", 1);
            setprop("/sim/model/center-tank-2000", 0);
            setprop("/sim/model/center-refuel-pod", 0);
        }
        elsif(load == 'tank-2000')
        {
            setprop("/sim/model/center-tank-1250", 0);
            setprop("/sim/model/center-tank-2000", 1);
            setprop("/sim/model/center-refuel-pod", 0);
        }
        elsif(load == 'refuel-pod')
        {
            setprop("/sim/model/center-tank-1250", 0);
            setprop("/sim/model/center-tank-2000", 0);
            setprop("/sim/model/center-refuel-pod", 1);
        }
    }
    elsif(place == 'wing-pylons')
    {
        if(load == 'none')
        {
            setprop("/sim/model/wing-pylons-smoke-pod", 0);
            setprop("/sim/model/smoking", 0);
        }
        elsif(load == 'smoke-pod')
        {
            setprop("/sim/model/wing-pylons-smoke-pod", 1);
        }
    }
}

var event_brake = func(do_enable) {
    setprop("/controls/gear/brake-left", do_enable);
    setprop("/controls/gear/brake-right", do_enable);
}

var event_airbrake = func(do_enable) {
    var speedbrake = getprop("/controls/flight/speedbrake") or 0;
    if(do_enable == 1)
    {
        speedbrake = (speedbrake >= .75) ? 1 : speedbrake + .2;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
    else
    {
        speedbrake = (speedbrake <= .25) ? 0 : speedbrake - .2;
        setprop("/controls/flight/speedbrake", speedbrake);
    }
    event_status_ap_speed();
}

var event_status_ap_speed = func() {
    var speedbrake     = getprop("/controls/flight/speedbrake") or 0;
    var ap_speed       = getprop("/autopilot/locks/speed") or ''; # speed-with-throttle
    var stdby_ap_speed = getprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby") or 0;

    if((speedbrake > .1) and (ap_speed == 'speed-with-throttle'))
    {
        setprop("/autopilot/locks/speed", '');
    }
    elsif((speedbrake <= .1) and (stdby_ap_speed == 1))
    {
        setprop("/autopilot/locks/speed", 'speed-with-throttle');
    }
}

var event_toggle_std_atm = func(do_enable) {
    var is_std_atm = getprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt") or 0;
    if(do_enable == -1)
    {
        # do_enable == -1 : toggle
        do_enable = (is_std_atm == 0) ? 1 : 0;
    }
    if(do_enable == 1)
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 1);
        var setting_inhg_previous = getprop("/instrumentation/altimeter/setting-inhg");
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous", setting_inhg_previous);
        setprop("/instrumentation/altimeter/setting-inhg", 29.92);
    }
    else
    {
        setprop("/instrumentation/my_aircraft/stdby-alt/controls/std-alt", 0);
        var setting_inhg_previous = getprop("/instrumentation/my_aircraft/stdby-alt/controls/setting-inhg-previous");
        setprop("/instrumentation/altimeter/setting-inhg", setting_inhg_previous);
    }
}


#===============================================================================
#                                                                          TOOLS

var reload_fx = func() {
    fgcommand("reinit", props.Node.new({ subsystem: "sound" }));
}

var check_source_aliases = func() {
    var list_of_properties = [
        "/orientation/pitch-deg",
        "/orientation/roll-deg",
        "/orientation/heading-magnetic-deg",
    ];
    
    for(var i = 0 ; i < size(list_of_properties) ; i += 1)
    {
        var property = list_of_properties[i];
        var value = getprop(property);
        if(! value) value = 'NULL !';
        printf ('la propriete %s vaut %s', property, value);
    }
}

var dump_properties = func() {
    io.write_properties('/home/nico/.fgfs/Export/foo.xml', '/');
}






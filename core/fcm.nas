print("*** LOADING core - fcm.nas ... ***");

# namespace : core

# description :
# - flight control manager
#                                                   fcm.nas
#                                           vvvvvvvvvvvvvvvvvvvvvvvvv
#
# .--------------------------------------.
# |      control (mouse & joystick)      |-----------+
# '--------------------------------------'           |
#     .                                              V
#     .                                         input values (/controls/flight/*)
#     .                                    .--------------------.
#  (default fg settings)                   |        fcm         |
#     .                                    '--------------------'
#     .                                         output values (/controls/flight/fcm-*)
#     .                                              |
#     .                                              |
#     .   .--------------------------.               |
#     .   |       AUTOPILOT          |               |
#     .   |                          |               |
#     .   | if AP disabled           |               |
#     .   |   fdm = fbw-fcm          |               |
#     .   |                          |               |
#     .   '--------------------------'               |
#     .           output values (/controls/flight/fdm-*)
#     .             |
#     V             V
# .--------------------------------------.
# |   yasim / fdm (aircraft behaviour)   |
# '--------------------------------------'
#              output values (/surface-positions/*, /sim/model/*)
#                   |
#                   V
# .--------------------------------------.
# |     sim-multiplay-properties.xml     |
# '--------------------------------------'
#               aliases (/sim/multiplay/generic/*, /surface-positions/*)
#                   |
#                   V
#          input values (sim/multiplay/generic/*, surface-positions/*)
# .--------------------------------------.
# |          model animations            |
# '--------------------------------------'


# fcm settings
# - /instrumentation/my_aircraft/nd/controls/mode
# - TAXI, APP, NAV, VFR


#===============================================================================
#                                                                      CONSTANTS



#===============================================================================
#                                                                 INITIALISATION

# inputs
var node_control_roll     = props.globals.getNode("/controls/flight/aileron");
var node_control_pitch    = props.globals.getNode("/controls/flight/elevator");
var node_control_yaw      = props.globals.getNode("/controls/flight/rudder");

# outputs
var node_fcm_yaw          = props.globals.getNode("/controls/flight/fcm-rudder");
var node_fcm_canard       = props.globals.getNode("/controls/flight/fcm-canard");
var node_fcm_slat         = props.globals.getNode("/controls/flight/slats", 1);

var node_aoa              = props.globals.getNode("/orientation/alpha-deg");

var node_gears            = props.globals.getNode("/gear/gear[0]/position-norm");
var node_gears_comp       = props.globals.getNode("/gear/gear[0]/compression-norm");
var node_elevator_pos     = props.globals.getNode("/surface-positions/elevator-pos-norm", 1);
var node_airbrakes        = props.globals.getNode("/surface-positions/left-flap-pos-norm", 1);
var node_speedbrakes      = props.globals.getNode("/surface-positions/speedbrake-pos-norm", 1);


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                                enable_commands
# this function is used when the engine is started
var enable_commands = func(pitch, roll, yaw, slats, canard) {
    var is_on = getprop("/systems/electrical/bus/commands") or 0;

    if(is_on == 0)
    {
        pitch  = 0;
        roll   = 0;
        yaw    = 0;
        slats  = 0;
        canard = 1;
    }
    #printf("--- enable_commands :: %.1f - %.1f - %.1f - %.1f - %.1f ", pitch, roll, yaw, slats, canard);
    var out = [pitch, roll, yaw, slats, canard];
    return out;
}

#-------------------------------------------------------------------------------
#                                                      slats_and_canards_manager
#
# To calculate the slats and canards positions
var slats_and_canards_manager = func() {

    var airbrk_pos   = node_airbrakes.getValue()    or 0;
    var speedbrk_pos = node_speedbrakes.getValue()  or 0;
    var gear_pos     = node_gears.getValue()        or 0;
    var gear_comp    = node_gears_comp.getValue()   or 0;
    var pitch_pos    = node_elevator_pos.getValue() or 0;
    var alpha_deg    = node_aoa.getValue()          or 0;

    # animation canards :
    # - airbrk and speedbrk increase
    # - aoa decrease
    # - on ground, pulling stick increases and aoa doesn't have effect
    if(gear_pos == 1)
    {
        # gears down
        canard_pos = ((airbrk_pos + speedbrk_pos) * 10) - ((1 + gear_comp) * pitch_pos * 40);
        canard_pos = (canard_pos >  8) ?  8 : canard_pos;
        canard_pos = (canard_pos < -8) ? -8 : canard_pos;
        #printf("canard_pos :: rbrk %.1f - sbrk %.1f - gcomp %.1f - pitch %.1f", airbrk_pos, speedbrk_pos, gear_comp, pitch_pos);
    }
    else
    {
        canard_pos = ((airbrk_pos + speedbrk_pos) * 10) + (pitch_pos * 10) - (alpha_deg * 1.3);
        canard_pos = (canard_pos >  20) ?  20 : canard_pos;
        canard_pos = (canard_pos < -20) ? -20 : canard_pos;
    }
    canard_pos /= 20; # value must be between -1 and 1

    # animation slats
    if((alpha_deg > 2) and (alpha_deg < 30))
    {
        slat_aoa = alpha_deg / 10;
    }
    else
    {
        slat_aoa = 0;
    }

    var out = [slat_aoa, canard_pos];
    return out;
}

#-------------------------------------------------------------------------------
#                                                                       fcm_loop
#
var fcm_loop = func() {
    # we are getting the input values (pilot's controls)
    var input_pitch  = node_control_pitch.getValue() or 0;
    var input_roll   = node_control_roll.getValue()  or 0;
    var input_yaw    = node_control_yaw.getValue()   or 0;

    # the ouput (aircraft's gouverns) equals the input (pilot's controls)
    var output_pitch = input_pitch;
    var output_roll  = input_roll;
    var output_yaw   = input_yaw;

    # other controls managers
    var secondary_outputs = slats_and_canards_manager();
    var output_slats  = secondary_outputs[0];
    var output_canard = secondary_outputs[1];

    # starting
    var outputs = enable_commands(output_pitch, output_roll, output_yaw, output_slats, output_canard);
    output_yaw    = outputs[2];
    output_slats  = outputs[3];
    output_canard = outputs[4];

    # values must be between -1 and 1
    node_fcm_yaw.setValue(output_yaw);
    node_fcm_slat.setValue(output_slats);
    node_fcm_canard.setValue(output_canard);
}



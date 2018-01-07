print("*** LOADING fdm - fcm.nas ... ***");

# namespace : fcm

# description :
# - flight control manager
#                                                   fcm.nas
#                                           vvvvvvvvvvvvvvvvvvvvvvvvv
#
# .--------------------------------------.
# |      control (mouse & joystick)      |---------------+
# '--------------------------------------'               |
#                   .                                    V
#                   .                               input values (/controls/flight/*)
#                   .                          .--------------------.
#          (systeme initial)                   |        fcm         |
#                   .                          '--------------------'
#                   .                               output values (/controls/flight/fcm-*)
#                   V                                    |
# .--------------------------------------.               |
# |   yasim / fdm (aircraft behaviour)   |<--------------+
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

var reduction_of_efficiency_for_gear_down = 0.1;
var reduction_of_efficiency_for_airbrakes = 0.2;

var max_autorized_gload           = 15;    # G
var min_autorized_gload           = -4;    # G
var max_autorized_aoa             = 25;    # deg
var min_autorized_aoa             = -5;    # deg
var max_roll_rate                 = 180;   # deg/sec

# parameters updated by mods, see instruments/nd/nd-model.xml
# default
var optimal_altitude                     = 0;     # ft (INT)
var optimal_speed                        = 200;   # kts (INT)
var range_altitude                       = 20000; # ft (INT)
var range_speed                          = 550;   # kts (INT)
var reduction_of_efficiency_for_altitude = 2;     # (FLOAT)
var reduction_of_efficiency_for_speed    = 2.7;   # (FLOAT)

# TAXI
var taxi_optimal_altitude                     = 0;
var taxi_optimal_speed                        = 0;
var taxi_range_altitude                       = 1;
var taxi_range_speed                          = 50;
var taxi_reduction_of_efficiency_for_altitude = 1;
var taxi_reduction_of_efficiency_for_speed    = 1;

# APP
var app_optimal_altitude                      = 0;
var app_optimal_speed                         = 90;
var app_range_altitude                        = 1;
var app_range_speed                           = 100;
var app_reduction_of_efficiency_for_altitude  = 1;
var app_reduction_of_efficiency_for_speed     = 1.5;

# NAV
var nav_optimal_altitude                      = 0;
var nav_optimal_speed                         = 100;
var nav_range_altitude                        = 20000;
var nav_range_speed                           = 600;
var nav_reduction_of_efficiency_for_altitude  = 10;
var nav_reduction_of_efficiency_for_speed     = 25;

# VFR
var vfr_optimal_altitude                      = 0;
var vfr_optimal_speed                         = 400;
var vfr_range_altitude                        = 30000;
var vfr_range_speed                           = 400;
var vfr_reduction_of_efficiency_for_altitude  = 1.2;
var vfr_reduction_of_efficiency_for_speed     = 1.1;


#===============================================================================
#                                                                 INITIALISATION

# inputs
var node_control_roll     = props.globals.getNode("/controls/flight/aileron");
var node_control_pitch    = props.globals.getNode("/controls/flight/elevator");
var node_control_yaw      = props.globals.getNode("/controls/flight/rudder");

# outputs
var node_fcm_roll         = props.globals.getNode("/controls/flight/fcm-aileron");
var node_fcm_pitch        = props.globals.getNode("/controls/flight/fcm-elevator");
var node_fcm_yaw          = props.globals.getNode("/controls/flight/fcm-rudder");
var node_fcm_canard       = props.globals.getNode("/controls/flight/fcm-canard");
var node_fcm_slat         = props.globals.getNode("/controls/flight/slats", 1);

var node_airspeed         = props.globals.getNode("/instrumentation/airspeed-indicator/true-speed-kt");
var node_altitude         = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft");
var node_pitchrate        = props.globals.getNode("/orientation/pitch-rate-degps");
var node_rollrate         = props.globals.getNode("/orientation/roll-rate-degps");
var node_yawrate          = props.globals.getNode("/orientation/yaw-rate-degps");
var node_aoa              = props.globals.getNode("/orientation/alpha-deg");
var node_gload            = props.globals.getNode("/accelerations/pilot-g", 1);

var node_gears            = props.globals.getNode("/gear/gear[0]/position-norm");
var node_gears_comp       = props.globals.getNode("/gear/gear[0]/compression-norm");
var node_elevator_pos     = props.globals.getNode("/surface-positions/elevator-pos-norm", 1);
var node_airbrakes        = props.globals.getNode("/surface-positions/left-flap-pos-norm", 1);
var node_speedbrakes      = props.globals.getNode("/surface-positions/speedbrake-pos-norm", 1);

var buffer_input_pitch    = 0;
var buffer_pitch          = 1;
var buffer_input_roll     = 0;


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                        keep_in_flight_envelope
# this function keeps input values in flight envelope
# if some values (gload, aoa, roll rate) are exceded, buffered input values are
# returned
var keep_in_flight_envelope = func(input_pitch, input_roll) {

    var keep_pitch = keep_in_flight_envelope_pitch();
    
    if(keep_pitch != 0)
    {
        input_pitch = (abs(input_pitch) < abs(buffer_input_pitch)) ? input_pitch : buffer_input_pitch;
        #printf("KEEP PITCH input:%.4f - buffer_input:%.4f", input_pitch, buffer_input_pitch);
    }
    else
    {
        buffer_input_pitch = input_pitch;
        #printf("OK   PITCH input:%.4f - buffer_input:%.4f", input_pitch, buffer_input_pitch);
    }

    var keep_roll = keep_in_flight_envelope_roll(input_roll);
    if(keep_roll != 0)
    {
        input_roll = (abs(input_roll) < abs(buffer_input_roll)) ? input_roll : buffer_input_roll;
        #printf("KEEP ROLL input:%.4f - buffer_input:%.4f", input_roll, buffer_input_roll);
    }
    else
    {
        buffer_input_roll = input_roll;
        #printf("OK   ROLL input:%.4f - buffer_input:%.4f", input_roll, buffer_input_roll);
    }
    var out = [input_pitch, input_roll];
    return out;
}

#-------------------------------------------------------------------------------
#                                                  keep_in_flight_envelope_pitch
# this function tests gload and aoa and decides if the pitch should be
# restricted
var keep_in_flight_envelope_pitch = func() {
    var out = 0;
    var current_aoa   = node_aoa.getValue()   or 0;
    var current_gload = node_gload.getValue() or 1;
    #printf("--------------  DEBUG current_aoa:%.4f - current_gload:%.4f -  max_autorized_aoa:%.4f - max_autorized_gload:%.4f", current_aoa, current_gload, max_autorized_aoa, max_autorized_gload);
    if((current_aoa > max_autorized_aoa) or (current_gload > max_autorized_gload))
    {
        out = 1;
    }
    elsif((current_aoa < min_autorized_aoa) or (current_gload < min_autorized_gload))
    {
        out = -1;
    }
    return out;
}
#-------------------------------------------------------------------------------
#                                                   keep_in_flight_envelope_roll
# this function tests roll rate and decides if the roll should be restricted
var keep_in_flight_envelope_roll = func(input_roll) {
    var out = 0;
    var current_roll_rate = node_rollrate.getValue() or 0;
    #printf("--------------  DEBUG current_roll_rate :%.6f", current_roll_rate);
    if(abs(current_roll_rate) > max_roll_rate)
    {
        out = (input_roll < 0) ? -1 : 1;
    }
    return out;
}

#-------------------------------------------------------------------------------
#                                         reduce_efficiency_due_to_configuration
# this function returns a factor depending of current configuration (gear down
# or airbrakes deployed)
var reduce_efficiency_due_to_configuration = func() {
    var is_gear_down      = node_gears.getValue()     or 0;
    var is_airbrakes_open = node_airbrakes.getValue() or 0;

    var factor = 0;
    factor += (is_gear_down) ? reduction_of_efficiency_for_gear_down : 0;
    factor += (is_airbrakes_open) ? reduction_of_efficiency_for_airbrakes : 0;

    #printf("--- FACTOR CONFIG:%.6f", factor);
    return factor
}

#-------------------------------------------------------------------------------
#                                                 reduce_efficiency_due_to_speed
# this function returns a factor depending of current speed
var reduce_efficiency_due_to_speed = func() {
    var current_speed = node_airspeed.getValue() or 0;

    var min = (range_speed > optimal_speed) ? 0 : optimal_speed - range_speed;
    var max = optimal_speed + range_speed;

    var factor = reduction_of_efficiency_for_speed;
    if((current_speed >= optimal_speed and current_speed < max)
        or(current_speed < optimal_speed and current_speed > min))
    {
        factor = abs(((reduction_of_efficiency_for_speed * current_speed) / range_speed) - (reduction_of_efficiency_for_speed * (optimal_speed / range_speed)));
    }

    #printf("--- FACTOR SPEED:%.6f - CURRENT SPEED:%.6f", factor, current_speed);
    return factor
}

#-------------------------------------------------------------------------------
#                                              reduce_efficiency_due_to_altitude
# this function returns a factor depending of current altitude
var reduce_efficiency_due_to_altitude = func() {
    var current_altitude  = node_altitude.getValue() or 0;

    var min = (range_altitude > optimal_altitude) ? 0 : optimal_altitude - range_altitude;
    var max = optimal_altitude + range_altitude;
    var factor = reduction_of_efficiency_for_altitude;

    if((current_altitude >= optimal_altitude and current_altitude < max)
        or(current_altitude < optimal_altitude and current_altitude > min))
    {
        factor = abs(((reduction_of_efficiency_for_altitude * current_altitude) / range_altitude) - (reduction_of_efficiency_for_altitude * (optimal_altitude / range_altitude)));
    }

    #printf("--- FACTOR ALTITUDE:%.6f - CURRENT ALTITUDE:%.6f", factor, current_altitude);
    return factor
}

#-------------------------------------------------------------------------------
#                                                               modify_stability
# this function modifies command effect 
var modify_stability = func(input) {

    var factor = 3;

    factor += reduce_efficiency_due_to_speed();
    factor += reduce_efficiency_due_to_altitude();
    factor += reduce_efficiency_due_to_configuration();

    var output = ((input * 2) * (input * 2)) / factor; # f(x) = ((x * 2) ^ 2) / 3
                                                       # f(x) = 1 - (cos(x*1.2) ^ 3)
    output = (input < 0) ? -output : output;

    output = (output < -1) ? -1 : (output > 1) ? 1 : output;
    return output;
}

#-------------------------------------------------------------------------------
#                                                                enable_commands
# this function is used when the engine is started
var enable_commands = func(pitch, roll, yaw, slats, canard) {
    var is_on = getprop('/systems/electrical/bus/commands') or 0;

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
        canard_pos = ((airbrk_pos + speedbrk_pos) * 10) - ((1 + gear_comp) * pitch_pos * 80);
        #printf("canard_pos :: rbrk %.1f - sbrk %.1f - gcomp %.1f - pitch %.1f", airbrk_pos, speedbrk_pos, gear_comp, pitch_pos);
    }
    else
    {
        canard_pos = ((airbrk_pos + speedbrk_pos) * 10) + (pitch_pos * 10) - (alpha_deg * 1.3);
    }
    canard_pos = (canard_pos >  20) ?  20 : canard_pos;
    canard_pos = (canard_pos < -20) ? -20 : canard_pos;
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

    # mods change behaviour of FCM
    # USED FOR TUNNING WITHOUT RESTARTING fcm.nas, see system-properties.xml
    #reduction_of_efficiency_for_speed       = getprop('/systems/fcm/reduction_of_efficiency_for_speed') or 0;
    #reduction_of_efficiency_for_altitude    = getprop('/systems/fcm/reduction_of_efficiency_for_altitude') or 0;
    #optimal_speed                           = getprop('/systems/fcm/optimal_speed') or 0;
    #range_speed                             = getprop('/systems/fcm/range_speed') or 0;
    #optimal_altitude                        = getprop('/systems/fcm/optimal_altitude') or 0;
    #range_altitude                          = getprop('/systems/fcm/optimal_altitude') or 0;
    var mod = getprop('/instrumentation/my_aircraft/nd/controls/mode');
    if(mod == 'TAXI')
    {
        optimal_altitude                     = taxi_optimal_altitude;
        optimal_speed                        = taxi_optimal_speed;
        range_altitude                       = taxi_range_altitude;
        range_speed                          = taxi_range_speed;
        reduction_of_efficiency_for_altitude = taxi_reduction_of_efficiency_for_altitude;
        reduction_of_efficiency_for_speed    = taxi_reduction_of_efficiency_for_speed;
    }
    elsif(mod == 'APP')
    {
        optimal_altitude                     = app_optimal_altitude;
        optimal_speed                        = app_optimal_speed;
        range_altitude                       = app_range_altitude;
        range_speed                          = app_range_speed;
        reduction_of_efficiency_for_altitude = app_reduction_of_efficiency_for_altitude;
        reduction_of_efficiency_for_speed    = app_reduction_of_efficiency_for_speed;
    }
    elsif(mod == 'NAV')
    {
        optimal_altitude                     = nav_optimal_altitude;
        optimal_speed                        = nav_optimal_speed;
        range_altitude                       = nav_range_altitude;
        range_speed                          = nav_range_speed;
        reduction_of_efficiency_for_altitude = nav_reduction_of_efficiency_for_altitude;
        reduction_of_efficiency_for_speed    = nav_reduction_of_efficiency_for_speed;
    }
    elsif(mod == 'VFR')
    {
        optimal_altitude                     = vfr_optimal_altitude;
        optimal_speed                        = vfr_optimal_speed;
        range_altitude                       = vfr_range_altitude;
        range_speed                          = vfr_range_speed;
        reduction_of_efficiency_for_altitude = vfr_reduction_of_efficiency_for_altitude;
        reduction_of_efficiency_for_speed    = vfr_reduction_of_efficiency_for_speed;
    }

    # we are getting the input values (pilot's controls)
    var input_pitch  = node_control_pitch.getValue() or 0;
    var input_roll   = node_control_roll.getValue()  or 0;
    var input_yaw    = node_control_yaw.getValue()   or 0;

    # we are correcting theese values to keep the aircraft in flight envelope
    var inputs = keep_in_flight_envelope(input_pitch, input_roll);
    input_pitch = inputs[0];
    input_roll = inputs[1];

    # the ouput (aircraft's gouverns) equals the input (pilot's controls)
    var output_pitch = input_pitch;
    var output_roll  = input_roll;
    var output_yaw   = input_yaw;

    # in manual mode, the stability is improved (more precise on the center
    # of the controls and depends on speed, altitude, configuration)

    if(getprop("/autopilot/locks/altitude") != "altitude-hold")
    {
        output_pitch = modify_stability(output_pitch);
    }
    if((getprop("/autopilot/locks/heading") != "dg-heading-hold")
        and (getprop("/autopilot/locks/heading") != "nav1-hold"))
    {
        output_roll  = modify_stability(output_roll);
    }

    # other controls managers
    var secondary_outputs = slats_and_canards_manager();
    var output_slats  = secondary_outputs[0];
    var output_canard = secondary_outputs[1];

    # starting
    var outputs = enable_commands(output_pitch, output_roll, output_yaw, output_slats, output_canard);
    output_pitch  = outputs[0];
    output_roll   = outputs[1];
    output_yaw    = outputs[2];
    output_slats  = outputs[3];
    output_canard = outputs[4];

    # values must be between -1 and 1
    node_fcm_pitch.setValue(output_pitch);
    node_fcm_roll.setValue(output_roll);
    node_fcm_yaw.setValue(output_yaw);
    node_fcm_slat.setValue(output_slats);
    node_fcm_canard.setValue(output_canard);

    #printf("PITCH %.4f:%.4f - ROLL %.4f:%.4f - YAW %.4f:%.4f", input_pitch, output_pitch, input_roll, output_roll, input_yaw, output_yaw);

    settimer(fcm_loop, .1);
}

setlistener('/sim/signals/fdm-initialized', fcm_loop);



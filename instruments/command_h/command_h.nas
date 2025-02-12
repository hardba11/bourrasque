print("*** LOADING instrument_command_h - command_h.nas ... ***");

# namespace : instrument_command_h

#                             __________
#  .------------------------ |0         |
#  |     .-----+-----+-----> |    OK    |
#  |     |     |     |       !__________!
#  |     |     |     |        __________ 
#  |     |     |    rules    |1         |
#  |     |     |     |       |   INFO   |
#  |     |     |     `-----> !__________!
#  |     |    rules           __________
#  |     |     |             |2         | <---------.
#  |    rules  `-----------> |  NOTICE  | <---.     |
#  |     |                   !__________!     |     |
#  |     |                    __________     mute   |
#  |     |                   |3         |     |    ack
# rules  `-----------------> | CAUTION* | ----'     |
#  |                         !__________!           |
#  |                          __________            |
#  |                         |4         | ----------'
#  |                         |   WARN   | <---------. 
#  |                         !__________!           |
#  |                          __________           ack
#  |                         |5         |           |
#  `-----------------------> |  ALERT*  | ----------'
#                            !__________!

# STATUS are defined in command_h-properties.xml
#   0 - OK : off
#   1 - INFO : green
#   2 - NOTICE : static yellow
#   3 - CAUTION : blinking yellow - sound* - clicking ack mute the sound
#   4 - WARN : static red
#   5 - ALERT : blinking red - sound* - clicking ack mute the sound

var OK      = 0;
var INFO    = 1;
var NOTICE  = 2;
var CAUTION = 3;
var WARN    = 4;
var ALERT   = 5;

var checking_aircraft_status = func()
{
    #---------------------------------------------------------------------------
    # 1- GETTING AIRCRAFT INFORMATIONS :

    var is_engine0_stopped  = getprop("/engines/engine[0]/stopped") or 0;
    var is_engine1_stopped  = getprop("/engines/engine[1]/stopped") or 0;
    var is_engine0_stopping = getprop("/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping") or 0;
    var is_engine1_stopping = getprop("/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping") or 0;
    var is_on_ground        = getprop("/gear/gear[1]/wow") or 0;
    var is_gear_down        = getprop("/gear/gear[1]/position-norm") or 0;
    var is_epu_connected    = getprop("/sim/model/ground-equipment-p") or 0;
    #var is_fuel_connected   = getprop("/sim/model/ground-equipment-f") or 0;
    var fuel_level          = getprop("/consumables/fuel/total-fuel-m3") or 0;
    var is_engine0_reheat   = getprop("/engines/engine[0]/reheat") or 0;
    var is_engine1_reheat   = getprop("/engines/engine[1]/reheat") or 0;
    var is_hook_down        = getprop("/controls/gear/tailhook") or 0;
    var is_parkbrake        = getprop("/controls/gear/brake-parking") or 0;
    var is_bus_avionics_on  = getprop("/systems/electrical/bus/avionics") or 0;
    var is_hydraulics_on    = getprop("/controls/hydraulic/system/engine-pump") or 0;
    var is_bingo            = getprop("/instrumentation/my_aircraft/fuel/bingo/is_bingo_alert") or 0;
    var is_air_refuelling   = getprop("/systems/refuel/contact") or 0;
    var groundspeed         = getprop("/velocities/groundspeed-kt") or 0;
    var wheelspeed          = getprop("/gear/gear[0]/rollspeed-ms") or 0;
    var canopy_position     = getprop("/sim/model/canopy-pos-norm") or 0;
    var speedbrake_position = getprop("/controls/flight/speedbrake") or 0;
    var engine0_throttle    = getprop("/controls/engines/engine[0]/throttle") or 0;
    var engine1_throttle    = getprop("/controls/engines/engine[1]/throttle") or 0;
    var airspeed            = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0;
    var radar_altitude      = getprop("/position/altitude-agl-ft") or 0;
    var state_launchbar     = getprop("/gear/launchbar/state") or 'Disengaged';
    var is_autotrim_enabled = getprop("/controls/flight/autotrim-pitch") or 0;
    var gear_serviceable    = getprop("/sim/failure-manager/controls/gear/serviceable") or 0;
    var ap_h                = getprop("/autopilot/locks/heading") or '';
    var ap_s                = getprop("/autopilot/locks/speed") or '';
    var ap_a                = getprop("/autopilot/locks/altitude") or '';
    var ap_disabled = ((ap_h == '') and (ap_s == '') and (ap_a == ''));


    #---------------------------------------------------------------------------
    # 2- GETTING CURRENT STATUS INFORMATIONS :

    var engine0_status      = getprop("/instrumentation/my_aircraft/command_h/panel_status/engine0_status") or 0;
    var engine1_status      = getprop("/instrumentation/my_aircraft/command_h/panel_status/engine1_status") or 0;
    var hydraulics_status   = getprop("/instrumentation/my_aircraft/command_h/panel_status/hydraulics_status") or 0;
    var fuel_status         = getprop("/instrumentation/my_aircraft/command_h/panel_status/fuel_status") or 0;
    var gear_status         = getprop("/instrumentation/my_aircraft/command_h/panel_status/gear_status") or 0;
    var hook_status         = getprop("/instrumentation/my_aircraft/command_h/panel_status/hook_status") or 0;
    var speedbrake_status   = getprop("/instrumentation/my_aircraft/command_h/panel_status/speedbrake_status") or 0;
    var parkbrake_status    = getprop("/instrumentation/my_aircraft/command_h/panel_status/parkbrake_status") or 0;
    var canopy_status       = getprop("/instrumentation/my_aircraft/command_h/panel_status/canopy_status") or 0;
    var epu_status          = getprop("/instrumentation/my_aircraft/command_h/panel_status/epu_status") or 0;
    var reheat0_status      = getprop("/instrumentation/my_aircraft/command_h/panel_status/reheat0_status") or 0;
    var reheat1_status      = getprop("/instrumentation/my_aircraft/command_h/panel_status/reheat1_status") or 0;
    var bingo_status        = getprop("/instrumentation/my_aircraft/command_h/panel_status/bingo_status") or 0;
    var air_refuel_status   = getprop("/instrumentation/my_aircraft/command_h/panel_status/air_refuel_status") or 0;
    var avionics_status     = getprop("/instrumentation/my_aircraft/command_h/panel_status/avionics_status") or 0;
    var autotrim_status     = getprop("/instrumentation/my_aircraft/command_h/panel_status/autotrim_status") or 0;
    var ap_status           = getprop("/instrumentation/my_aircraft/command_h/panel_status/ap_status") or 0;


    #---------------------------------------------------------------------------
    # 3- ACKNOWLEDGE ALERTS (AND SOUND MUTE)
    #
    # if ack clicked :
    #   - we change some status
    #   - we mute sound
    #   - we reinit ack (allow to be clicked again)
    #
    ack_alert = getprop("/instrumentation/my_aircraft/command_h/ack_alert") or 0;
    if(ack_alert == 1)
    {
        if(engine0_status == CAUTION)    { engine0_status = NOTICE; }
        elsif(engine0_status == WARN)    { engine0_status = NOTICE; }
        elsif(engine0_status == ALERT)   { engine0_status = WARN; }

        if(engine1_status == CAUTION)    { engine1_status = NOTICE; }
        elsif(engine1_status == WARN)    { engine1_status = NOTICE; }
        elsif(engine1_status == ALERT)   { engine1_status = WARN; }

        if(hydraulics_status == CAUTION)    { hydraulics_status = NOTICE; }
        elsif(hydraulics_status == WARN)    { hydraulics_status = NOTICE; }
        elsif(hydraulics_status == ALERT)   { hydraulics_status = WARN; }

        if(fuel_status == ALERT)   { fuel_status = WARN; }

        if(gear_status == CAUTION)    { gear_status = NOTICE; }
        elsif(gear_status == WARN)    { gear_status = NOTICE; }
        elsif(gear_status == ALERT)   { gear_status = WARN; }

        if(hook_status == CAUTION)    { hook_status = NOTICE; }
        elsif(hook_status == WARN)    { hook_status = NOTICE; }
        elsif(hook_status == ALERT)   { hook_status = WARN; }

        if(speedbrake_status == CAUTION)    { speedbrake_status = NOTICE; }
        elsif(speedbrake_status == WARN)    { speedbrake_status = NOTICE; }
        elsif(speedbrake_status == ALERT)   { speedbrake_status = WARN; }

        if(parkbrake_status == CAUTION)    { parkbrake_status = NOTICE; }
        elsif(parkbrake_status == WARN)    { parkbrake_status = NOTICE; }
        elsif(parkbrake_status == ALERT)   { parkbrake_status = WARN; }

        if(canopy_status == CAUTION)    { canopy_status = NOTICE; }
        elsif(canopy_status == WARN)    { canopy_status = NOTICE; }
        elsif(canopy_status == ALERT)   { canopy_status = WARN; }

        if(epu_status == CAUTION)    { epu_status = NOTICE; }
        elsif(epu_status == WARN)    { epu_status = NOTICE; }
        elsif(epu_status == ALERT)   { epu_status = WARN; }

        if(reheat0_status == CAUTION)    { reheat0_status = NOTICE; }
        elsif(reheat0_status == WARN)    { reheat0_status = NOTICE; }
        elsif(reheat0_status == ALERT)   { reheat0_status = WARN; }

        if(reheat1_status == CAUTION)    { reheat1_status = NOTICE; }
        elsif(reheat1_status == WARN)    { reheat1_status = NOTICE; }
        elsif(reheat1_status == ALERT)   { reheat1_status = WARN; }

        if(bingo_status == CAUTION)    { bingo_status = NOTICE; }
        elsif(bingo_status == WARN)    { bingo_status = NOTICE; }
        elsif(bingo_status == ALERT)   { bingo_status = WARN; }

        if(air_refuel_status == CAUTION)    { air_refuel_status = NOTICE; }
        elsif(air_refuel_status == WARN)    { air_refuel_status = NOTICE; }
        elsif(air_refuel_status == ALERT)   { air_refuel_status = WARN; }

        if(avionics_status == CAUTION)    { avionics_status = NOTICE; }
        elsif(avionics_status == WARN)    { avionics_status = NOTICE; }
        elsif(avionics_status == ALERT)   { avionics_status = WARN; }

        if(autotrim_status == CAUTION)    { autotrim_status = NOTICE; }
        elsif(autotrim_status == WARN)    { autotrim_status = NOTICE; }
        elsif(autotrim_status == ALERT)   { autotrim_status = WARN; }

        #if(ap_status == INFO) { ap_status = INFO; }

        setprop("/instrumentation/my_aircraft/command_h/sound_alert", 0);
        setprop("/instrumentation/my_aircraft/command_h/sound_caution", 0);
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 0);
    }


    #---------------------------------------------------------------------------
    # 4- DEFINTION OF ALERT RULES :
    #
    # the rules can't update status if ALERT or WARN
    #

    # alert rules for ENG1
    if((engine0_status == ALERT) or (engine0_status == WARN))
        {}
    elsif(((is_engine0_stopped == 1) or (is_engine0_stopping == 1)) and (is_on_ground == 0))
        { engine0_status = ALERT }
    elsif((is_engine0_stopped == 1) or (is_engine0_stopping == 1))
        { engine0_status = NOTICE; }
    else
        { engine0_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/engine0_status", engine0_status);

    # alert rules for ENG2
    if((engine1_status == ALERT) or (engine1_status == WARN))
        {}
    elsif(((is_engine1_stopped == 1) or (is_engine1_stopping == 1)) and (is_on_ground == 0))
        { engine1_status = ALERT; }
    elsif((is_engine1_stopped == 1) or (is_engine1_stopping == 1))
        { engine1_status = NOTICE; }
    else
        { engine1_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/engine1_status", engine1_status);

    # alert rules for HYDR
    if((hydraulics_status == ALERT) or (hydraulics_status == WARN))
        {}
    elsif((is_hydraulics_on == 0) and (is_on_ground == 0))
        { hydraulics_status = ALERT; }
    elsif(is_hydraulics_on == 0)
        { hydraulics_status = NOTICE; }
    else
        { hydraulics_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/hydraulics_status", hydraulics_status);

    # alert rules for FUEL
    if(((fuel_level * 805) < 900) and (fuel_status != WARN))
        { fuel_status = ALERT; }
    elsif((fuel_level * 805) < 900)
        { fuel_status = WARN; }
    else
        { fuel_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/fuel_status", fuel_status);

    # alert rules for GEAR
    if((gear_status == ALERT) or (gear_status == WARN))
        {}
    elsif(gear_serviceable == 0)
        { gear_status = WARN; }
    elsif((is_gear_down == 1) and (airspeed > 350))
        { gear_status = ALERT; }
    elsif((is_gear_down == 1) and (airspeed > 270))
        { gear_status = CAUTION; }
    elsif((is_gear_down == 1) and (airspeed < 270) and (gear_status == CAUTION))
        { gear_status = NOTICE; }
    elsif((is_gear_down == 0) and (airspeed < 150) and (radar_altitude < 1500) and (gear_status != NOTICE))
        { gear_status = CAUTION; }
    elsif((is_gear_down == 0) and (airspeed < 150) and (radar_altitude < 1500))
        { gear_status = NOTICE; }
    elsif(is_gear_down == 1)
        { gear_status = INFO; }
    else
        { gear_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/gear_status", gear_status);

    # alert rules for HOOK
    if((hook_status == ALERT) or (hook_status == WARN))
        {}
    elsif((is_hook_down == 1) and (airspeed > 350) and (hook_status != NOTICE))
        { hook_status = CAUTION; }
    elsif(is_hook_down == 1)
        { hook_status = NOTICE; }
    else
        { hook_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/hook_status", hook_status);

    # alert rules for SPBK
    if(speedbrake_position > 0)
        { speedbrake_status = NOTICE; }
    else
        { speedbrake_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/speedbrake_status", speedbrake_status);

    # alert rules for PKBK
    if((parkbrake_status == ALERT) or (parkbrake_status == WARN))
        {}
    elsif((is_parkbrake == 1) and (is_on_ground == 0))
        { parkbrake_status = ALERT; }
    elsif((is_parkbrake == 1) and (state_launchbar != 'Disengaged'))
        { parkbrake_status = CAUTION; }
    elsif((is_parkbrake == 1)
        and ((engine0_throttle > .3) or (engine1_throttle > .3))
        and ((is_engine0_stopped != 1) or (is_engine1_stopped != 1)))
        { parkbrake_status = CAUTION; }
    elsif((is_parkbrake == 1)
        and ((engine0_throttle < .3) or (engine1_throttle < .3))
        and ((is_engine0_stopped != 1) or (is_engine1_stopped != 1)))
        { parkbrake_status = NOTICE; }
    elsif(is_parkbrake == 1)
        { parkbrake_status = INFO; }
    else
        { parkbrake_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/parkbrake_status", parkbrake_status);

    # alert rules for CNPY
    if((canopy_status == ALERT) or (canopy_status == WARN))
        {}
    elsif((canopy_position > .7) and (wheelspeed > 5))
        { canopy_status = ALERT; }
    elsif((canopy_position > .7) and (wheelspeed > 5) and (canopy_status != NOTICE))
        { canopy_status = CAUTION; }
    elsif((canopy_position > .1) and (groundspeed > 25) and (canopy_status != NOTICE))
        { canopy_status = CAUTION; }
    elsif(canopy_position > .1)
        { canopy_status = NOTICE; }
    else
        { canopy_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/canopy_status", canopy_status);

    # alert rules for EPU
    if((epu_status == ALERT) or (epu_status == WARN))
        {}
    elsif((is_epu_connected == 1) and ((is_engine0_stopped == 0) or (is_engine1_stopped == 0)) and (is_parkbrake == 0))
        { epu_status = ALERT; }
    elsif(is_epu_connected == 1)
        { epu_status = NOTICE; }
    else
        { epu_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/epu_status", epu_status);

    # alert rules for RHT1
    if(is_engine0_reheat == 1)
        { reheat0_status = INFO; }
    else
        { reheat0_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/reheat0_status", reheat0_status);

    # alert rules for RHT2
    if(is_engine1_reheat == 1)
        { reheat1_status = INFO; }
    else
        { reheat1_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/reheat1_status", reheat1_status);

    # alert rules for BNGO
    if((bingo_status == ALERT) or (bingo_status == WARN))
        {}
    elsif(is_bingo == 1)
        { bingo_status = ALERT; }
    else
        { bingo_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/bingo_status", bingo_status);

    # alert rules for AARF
    if(is_air_refuelling == 1)
        { air_refuel_status = INFO; }
    else
        { air_refuel_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/air_refuel_status", air_refuel_status);

    # alert rules for AVCS
    if((avionics_status == ALERT) or (avionics_status == WARN))
        {}
    elsif((is_bus_avionics_on == 0) and (is_on_ground == 0))
        { hydraulics_status = ALERT; }
    elsif(is_bus_avionics_on == 0)
        { avionics_status = NOTICE; }
    else
        { avionics_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/avionics_status", avionics_status);

    # alert rules for TRIM
    if(is_autotrim_enabled ==  1)
        { autotrim_status = CAUTION; }
    else
        { autotrim_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/autotrim_status", autotrim_status);

    # alert rules for A/P
    if(!ap_disabled)
        { ap_status = INFO; }
    else
        { ap_status = OK; }
    setprop("/instrumentation/my_aircraft/command_h/panel_status/ap_status", ap_status);


    #---------------------------------------------------------------------------
    # 5- DETECT IF THERE IS A NOT-YET-ACKNOWLEDGED-ALERT (A SOUND WILL PLAY)
    #
    # a new alert will play a sound and init ack to allow
    #
    is_alert = (
        (engine0_status == ALERT) or
        (engine1_status == ALERT) or
        (hydraulics_status == ALERT) or
        (fuel_status == ALERT) or
        (gear_status == ALERT) or
        (hook_status == ALERT) or
        (speedbrake_status == ALERT) or
        (parkbrake_status == ALERT) or
        (canopy_status == ALERT) or
        (epu_status == ALERT) or
        (reheat0_status == ALERT) or
        (reheat1_status == ALERT) or
        (bingo_status == ALERT) or
        (air_refuel_status == ALERT) or
        (avionics_status == ALERT)
    );
    is_warn = (
        (engine0_status == WARN) or
        (engine1_status == WARN) or
        (hydraulics_status == WARN) or
        (fuel_status == WARN) or
        (gear_status == WARN) or
        (hook_status == WARN) or
        (speedbrake_status == WARN) or
        (parkbrake_status == WARN) or
        (canopy_status == WARN) or
        (epu_status == WARN) or
        (reheat0_status == WARN) or
        (reheat1_status == WARN) or
        (bingo_status == WARN) or
        (air_refuel_status == WARN) or
        (avionics_status == WARN)
    );
    is_caution = (
        (engine0_status == CAUTION) or
        (engine1_status == CAUTION) or
        (hydraulics_status == CAUTION) or
        (fuel_status == CAUTION) or
        (gear_status == CAUTION) or
        (hook_status == CAUTION) or
        (speedbrake_status == CAUTION) or
        (parkbrake_status == CAUTION) or
        (canopy_status == CAUTION) or
        (epu_status == CAUTION) or
        (reheat0_status == CAUTION) or
        (reheat1_status == CAUTION) or
        (bingo_status == CAUTION) or
        (air_refuel_status == CAUTION) or
        (avionics_status == CAUTION)
    );
    is_notice = (
        (engine0_status == NOTICE) or
        (engine1_status == NOTICE) or
        (hydraulics_status == NOTICE) or
        (fuel_status == NOTICE) or
        (gear_status == NOTICE) or
        (hook_status == NOTICE) or
        (speedbrake_status == NOTICE) or
        (parkbrake_status == NOTICE) or
        (canopy_status == NOTICE) or
        (epu_status == NOTICE) or
        (reheat0_status == NOTICE) or
        (reheat1_status == NOTICE) or
        (bingo_status == NOTICE) or
        (air_refuel_status == NOTICE) or
        (avionics_status == NOTICE)
    );
    is_infoe = (
        (engine0_status == INFO) or
        (engine1_status == INFO) or
        (hydraulics_status == INFO) or
        (fuel_status == INFO) or
        (gear_status == INFO) or
        (hook_status == INFO) or
        (speedbrake_status == INFO) or
        (parkbrake_status == INFO) or
        (canopy_status == INFO) or
        (epu_status == INFO) or
        (reheat0_status == INFO) or
        (reheat1_status == INFO) or
        (bingo_status == INFO) or
        (air_refuel_status == INFO) or
        (avionics_status == INFO)
    );

    if(is_alert)
    {
        setprop("/instrumentation/my_aircraft/command_h/sound_alert", 1);
        setprop("/instrumentation/my_aircraft/command_h/sound_caution", 0);
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 0);
    }
    elsif(is_caution)
    {
        setprop("/instrumentation/my_aircraft/command_h/sound_alert", 0);
        setprop("/instrumentation/my_aircraft/command_h/sound_caution", 1);
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 0);
    }
    else
    {
        setprop("/instrumentation/my_aircraft/command_h/sound_alert", 0);
        setprop("/instrumentation/my_aircraft/command_h/sound_caution", 0);
        setprop("/instrumentation/my_aircraft/command_h/ack_alert", 0);
    }
}

var light = 0;
var blink = func()
{
    light = (light == 0) ? 1 : 0;
    setprop("/instrumentation/my_aircraft/command_h/blink_alert", light);
}


var reset = func()
{
    setprop("/instrumentation/my_aircraft/command_h/panel_status/engine0_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/engine1_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/hydraulics_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/fuel_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/gear_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/hook_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/speedbrake_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/parkbrake_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/canopy_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/epu_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/reheat0_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/reheat1_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/bingo_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/air_refuel_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/avionics_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/autotrim_status", OK);
    setprop("/instrumentation/my_aircraft/command_h/panel_status/ap_status", OK);
}
























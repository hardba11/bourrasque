print("*** LOADING instrument_command_h - command_h.nas ... ***");

# namespace : instrument_command_h

var checking_aircraft_status = func()
{

# getting panel_status properties :

    var engine0_status          = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/status') or 0;
    var engine0_warn_blink      = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/warn_blink') or 0;
    var engine0_alert_blink     = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/alert_blink') or 0;
    var engine1_status          = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/status') or 0;
    var engine1_warn_blink      = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/warn_blink') or 0;
    var engine1_alert_blink     = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/alert_blink') or 0;
    var hydraulics_status       = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/status') or 0;
    var hydraulics_warn_blink   = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/warn_blink') or 0;
    var hydraulics_alert_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/alert_blink') or 0;
    var fuel_status             = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/status') or 0;
    var fuel_warn_blink         = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/warn_blink') or 0;
    var fuel_alert_blink        = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/alert_blink') or 0;
    var gear_status             = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/status') or 0;
    var gear_warn_blink         = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/warn_blink') or 0;
    var gear_alert_blink        = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/alert_blink') or 0;
    var hook_status             = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/status') or 0;
    var hook_warn_blink         = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/warn_blink') or 0;
    var hook_alert_blink        = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/alert_blink') or 0;
    var speedbrake_status       = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/status') or 0;
    var speedbrake_warn_blink   = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/warn_blink') or 0;
    var speedbrake_alert_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/alert_blink') or 0;
    var parkbrake_status        = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/status') or 0;
    var parkbrake_warn_blink    = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/warn_blink') or 0;
    var parkbrake_alert_blink   = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/alert_blink') or 0;
    var canopy_status           = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/status') or 0;
    var canopy_warn_blink       = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/warn_blink') or 0;
    var canopy_alert_blink      = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/alert_blink') or 0;
    var epu_status              = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/status') or 0;
    var epu_warn_blink          = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/warn_blink') or 0;
    var epu_alert_blink         = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/alert_blink') or 0;
    var reheat0_status          = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/status') or 0;
    var reheat0_warn_blink      = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/warn_blink') or 0;
    var reheat0_alert_blink     = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/alert_blink') or 0;
    var reheat1_status          = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/status') or 0;
    var reheat1_warn_blink      = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/warn_blink') or 0;
    var reheat1_alert_blink     = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/alert_blink') or 0;
    var bingo_status            = getprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/status') or 0;
    var bingo_warn_blink        = getprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/warn_blink') or 0;
    var bingo_alert_blink       = getprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/alert_blink') or 0;
    var air_refuel_status       = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/status') or 0;
    var air_refuel_warn_blink   = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/warn_blink') or 0;
    var air_refuel_alert_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/alert_blink') or 0;
    var avionics_status         = getprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/status') or 0;
    var avionics_warn_blink     = getprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/warn_blink') or 0;
    var avionics_alert_blink    = getprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/alert_blink') or 0;

# getting aircraft data :

    var is_engine0_stopped  = getprop('/engines/engine[0]/stopped') or 0;
    var is_engine1_stopped  = getprop('/engines/engine[1]/stopped') or 0;
    var is_engine0_stopping = getprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping') or 0;
    var is_engine1_stopping = getprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping') or 0;
    var is_on_ground        = getprop('/gear/gear[0]/wow') or 0;
    var is_gear_down        = getprop('/gear/gear[0]/position-norm') or 0;
    var is_epu_connected    = getprop('/sim/model/ground-equipment-p') or 0;
    var is_fuel_connected   = getprop('/sim/model/ground-equipment-f') or 0;
    var is_engine0_reheat   = getprop('/engines/engine[0]/reheat') or 0;
    var is_engine1_reheat   = getprop('/engines/engine[1]/reheat') or 0;
    var is_hook_down        = getprop('/controls/gear/tailhook') or 0;
    var is_parkbrake        = getprop('/controls/gear/brake-parking') or 0;
    var is_bus_avionics_on  = getprop('/systems/electrical/bus/avionics') or 0;
    var is_bus_commands_on  = getprop('/systems/electrical/bus/commands') or 0;
    var is_bingo            = 1;     # TODO
    var is_air_refuelling   = getprop('/systems/refuel/contact') or 0;
    var groundspeed         = getprop('/velocities/groundspeed-kt') or 0;
    var canopy_position     = getprop('/sim/model/canopy-pos-norm') or 0;
    var speedbrake_position = getprop('/controls/flight/speedbrake') or 0;
    var engine0_throttle    = getprop('/controls/engines/engine[0]/throttle') or 0;
    var engine1_throttle    = getprop('/controls/engines/engine[1]/throttle') or 0;
    var airspeed            = getprop('/instrumentation/airspeed-indicator/true-speed-kt') or 0;
    var radar_altitude      = getprop('/position/altitude-agl-ft') or 0;

# setting alert rules :

    # ENG1
    if(engine0_status == 2)
        {}
    elsif(((is_engine0_stopped == 1) or (is_engine0_stopping == 1)) and (is_on_ground == 0))
        { engine0_status = 2; engine0_alert_blink = 1; }
    elsif((is_engine0_stopped == 1) or (is_engine0_stopping == 1))
        { engine0_status = 1; }
    else
        { engine0_status = 0; }

    # ENG2
    if(engine1_status == 2)
        {}
    elsif(((is_engine1_stopped == 1) or (is_engine1_stopping == 1)) and (is_on_ground == 0))
        { engine1_status = 2; engine1_alert_blink = 1; }
    elsif((is_engine1_stopped == 1) or (is_engine1_stopping == 1))
        { engine1_status = 1; }
    else
        { engine1_status = 0; }

    # HYDR
    if(hydraulics_status == 2)
        {}
    elsif((is_bus_commands_on == 0) and (is_on_ground == 0))
        { hydraulics_status = 2; hydraulics_alert_blink = 1; }
    elsif(is_bus_commands_on == 0)
        { hydraulics_status = 1; }
    else
        { hydraulics_status = 0; }

    # FUEL
    if(fuel_status == 2)
        {}
    elsif((is_fuel_connected == 1) and ((is_engine0_stopped == 0) or (is_engine1_stopped == 0)))
        { fuel_status = 2; fuel_alert_blink = 1; }
    elsif(is_fuel_connected == 1)
        { fuel_status = 1; }
    else
        { fuel_status = 0; }

    # GEAR
    if(gear_status == 2)
        {}
    elsif((is_gear_down == 1) and (airspeed > 350))
        { gear_status = 2; gear_alert_blink = 1; }
    elsif(((is_gear_down == 1) and (airspeed > 270)) or ((is_gear_down == 0) and (airspeed < 200) and (radar_altitude < 1500)))
        { gear_status = 1; gear_warn_blink = 1; }
    elsif(is_gear_down == 1)
        { gear_status = 1; gear_warn_blink = 0; }
    else
        { gear_status = 0; gear_warn_blink = 0; }

    # HOOK
    if(hook_status == 2)
        {}
    elsif((is_hook_down == 1) and (airspeed > 350))
        { hook_status = 1; hook_warn_blink = 1; }
    elsif(is_hook_down == 1)
        { hook_status = 1; }
    else
        { hook_status = 0; }

    # SPBK
    if(speedbrake_position > 0)
        { speedbrake_status = 1; }
    else
        { speedbrake_status = 0; }

    # PKBK
    if((is_parkbrake == 1) and ((engine0_throttle > .3) or (engine1_throttle > .3)))
        { parkbrake_status = 1; parkbrake_warn_blink = 1; }
    elsif(is_parkbrake == 1)
        { parkbrake_status = 1; parkbrake_warn_blink = 0; }
    else
        { parkbrake_status = 0; parkbrake_warn_blink = 0; }

    # CNPY
    if(canopy_status == 2)
        {}
    elsif((canopy_position > .7) and (groundspeed > 10))
        { canopy_status = 2; canopy_alert_blink = 1; }
    elsif(((canopy_position > .7) and (groundspeed > 10)) or ((canopy_position > .1) and (groundspeed > 30)))
        { canopy_status = 1; canopy_warn_blink = 1; }
    elsif(canopy_position > .1)
        { canopy_status = 1; canopy_warn_blink = 0; }
    else
        { canopy_status = 0; canopy_warn_blink = 0; }

    # EPU
    if((is_epu_connected == 1) and ((is_engine0_stopped == 0) or (is_engine1_stopped == 0)))
        { epu_status = 2; epu_alert_blink = 1; }
    elsif(is_epu_connected == 1)
        { epu_status = 1; }
    else
        { epu_status = 0; }

    # RHT1
    if(is_engine0_reheat == 1)
        { reheat0_status = 1; }
    else
        { reheat0_status = 0; }

    # RHT2
    if(is_engine1_reheat == 1)
        { reheat1_status = 1; }
    else
        { reheat1_status = 0; }

    # BNGO
    # TODO bingo

    # AARF
    if(is_air_refuelling == 1)
        { air_refuel_status = 1; }
    else
        { air_refuel_status = 0; }

    # AVCS
    if(avionics_status == 2)
        {}
    elsif((is_bus_avionics_on == 0) and (is_on_ground == 0))
        { hydraulics_status = 2; hydraulics_alert_blink = 1; }
    elsif(is_bus_avionics_on == 0)
        { avionics_status = 1; }
    else
        { avionics_status = 0; }


# setting master caution :

    var nb_alert = engine0_warn_blink
        + engine0_alert_blink
        + engine1_warn_blink
        + engine1_alert_blink
        + hydraulics_warn_blink
        + hydraulics_alert_blink
        + fuel_warn_blink
        + fuel_alert_blink
        + gear_warn_blink
        + gear_alert_blink
        + hook_warn_blink
        + hook_alert_blink
        + speedbrake_warn_blink
        + speedbrake_alert_blink
        + parkbrake_warn_blink
        + parkbrake_alert_blink
        + canopy_warn_blink
        + canopy_alert_blink
        + epu_warn_blink
        + epu_alert_blink
        + reheat0_warn_blink
        + reheat0_alert_blink
        + reheat1_warn_blink
        + reheat1_alert_blink
        + bingo_warn_blink
        + bingo_alert_blink
        + air_refuel_warn_blink
        + air_refuel_alert_blink
        + avionics_warn_blink
        + avionics_alert_blink
    ;
    setprop('/instrumentation/my_aircraft/command_h/is_alert', ((nb_alert > 0) ? 1 : 0));

# setting panel_status properties :

    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/status',           engine0_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/warn_blink',       engine0_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/alert_blink',      engine0_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/status',           engine1_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/warn_blink',       engine1_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/alert_blink',      engine1_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/status',        hydraulics_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/warn_blink',    hydraulics_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/alert_blink',   hydraulics_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/status',              fuel_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/warn_blink',          fuel_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/alert_blink',         fuel_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/status',              gear_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/warn_blink',          gear_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/gear/alert_blink',         gear_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/status',              hook_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/warn_blink',          hook_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/hook/alert_blink',         hook_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/status',        speedbrake_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/warn_blink',    speedbrake_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/alert_blink',   speedbrake_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/status',         parkbrake_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/warn_blink',     parkbrake_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/alert_blink',    parkbrake_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/status',            canopy_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/warn_blink',        canopy_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/alert_blink',       canopy_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/epu/status',               epu_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/epu/warn_blink',           epu_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/epu/alert_blink',          epu_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/status',           reheat0_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/warn_blink',       reheat0_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/alert_blink',      reheat0_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/status',           reheat1_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/warn_blink',       reheat1_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/alert_blink',      reheat1_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/status',             bingo_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/warn_blink',         bingo_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/bingo/alert_blink',        bingo_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/status',        air_refuel_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/warn_blink',    air_refuel_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/alert_blink',   air_refuel_alert_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/status',          avionics_status);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/warn_blink',      avionics_warn_blink);
    setprop('/instrumentation/my_aircraft/command_h/panel_status/avionics/alert_blink',     avionics_alert_blink);

    settimer(checking_aircraft_status, 1);
}

setlistener('/sim/signals/fdm-initialized', checking_aircraft_status);

var light = 0;
var blink = func()
{
    light = (light == 0) ? 1 : 0;
    setprop('/instrumentation/my_aircraft/command_h/blink_alert', light);
    settimer(blink, .5);
}
setlistener('/sim/signals/fdm-initialized', blink);




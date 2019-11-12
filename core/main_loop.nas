print("*** LOADING core - main_loop.nas ... ***");

# namespace : core

#===============================================================================
#                                                                          LOOPS


var loop_2000ms = func() {

    core.bourrasque_mp_loop_encode();
    my_aircraft_functions.event_choose_enabled_cams();
    my_aircraft_functions.disable_hippodrome_if_ap_not_ok();
    #my_aircraft_functions.set_max_cloud_layer();
    core.vor_true_to_mag();
}

var loop_1000ms = func() {
    core.hippo_loop();

    instrument_pfd.pfd();
    instrument_fuel.fuel();

# TODO
#    instrument_fuel_canvas
#    instrument_tablet_map

    instrument_command_h.checking_aircraft_status();
}

var loop_500ms = func() {
    instrument_nd.nd();
    instrument_command_h.blink();
}

var loop_200ms = func() {
    instrument_hud.minihud_loop();

    # setting sound factor if internal and canopy closed
    core.loud_sound();

    # alarms update
    core.update_alarms();
}

var loop_100ms = func() {

    instrument_light.light();

    # systems
    core.systems_loop();

    # setting engine egt celsius from egt farenheit
    core.egtf2egtc();

    # setting altimeter kilopascal from inch hg
    setprop("/instrumentation/altimeter/setting-kpa", (getprop("/instrumentation/altimeter/setting-inhg") * my_aircraft_functions.INHG2HPA));

    # setting true-heading-bug from mag-heading-bug
    setprop("/instrumentation/my_aircraft/nd/outputs/true-heading-bug-deg", math.mod(getprop("/autopilot/settings/heading-bug-deg") + getprop("/environment/magnetic-variation-deg"), 360));

# TODO
    #instrument_hud_target_positions
    #instrument_sfd_eicas
    #instrument_sfd_radar
    #instrument_command_h_canvas

    # touchdown smoke
    core.touchdown_smoke();

    # shake cockpit
    core.calculate_shake();
    core.calculate_shake_external_view();
}

var ms = 0;
var ratio_speed = 1;
var main_loop = func() {

    # fly by wire
    core.fcm_loop();

    if(math.mod(ms, 100 * ratio_speed) == 0)
    {
        loop_100ms();
    }
    if(math.mod(ms, 200 * ratio_speed) == 0)
    {
        loop_200ms();
    }
    if(math.mod(ms, 500 * ratio_speed) == 0)
    {
        loop_500ms();
    }
    if(math.mod(ms, 1000 * ratio_speed) == 0)
    {
        loop_1000ms();
    }
    if(math.mod(ms, 2000 * ratio_speed) == 0)
    {
        loop_2000ms();
    }

    ms = (ms > (2000 * ratio_speed)) ? 0 : ms + 100;

    var time_speed = getprop("/sim/speed-up") or 1;
    ratio_speed = (time_speed > 1) ? 2 * time_speed : 1;

    settimer(main_loop, .1);

}

setlistener("/sim/signals/fdm-initialized", main_loop);






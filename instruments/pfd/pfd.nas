print("*** LOADING instrument_pfd - pfd.nas ... ***");

# namespace : instrument_pfd

var autopilot_to_label = {
    '': '-',
# /autopilot/locks/heading
    'dg-heading-hold': 'HDG',
    'true-heading-hold': 'TRU',
    'nav1-hold': 'NAV',
    'wing-leveler': 'LVL',
# /autopilot/locks/speed
    'speed-with-throttle': 'A/T',
    'speed-with-pitch-trim': 'PTCH',
# /autopilot/locks/altitude
    'vertical-speed-hold': 'VS',
    'altitude-hold': 'ALT',
    'pitch-hold': 'PTCH',
    'aoa-hold': 'AOA',
    'agl-hold': 'AGL',
    'gs1-hold': 'GS',
};

var pfd = func()
{
    # hide heading bug if object out of the pfd's box
    var heading_bug_error_deg = getprop("/autopilot/internal/heading-bug-error-deg") or 0;
    heading_bug_error_deg = math.abs(heading_bug_error_deg);
    var display_heading_bug = (heading_bug_error_deg > 80) ? 0 : 1;
    setprop("/instrumentation/my_aircraft/pfd/controls/display-heading-bug", display_heading_bug);

    # update label
    setprop(
        "/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/heading",
        autopilot_to_label[getprop("/autopilot/locks/heading")]
    );
    setprop(
        "/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/speed",
        autopilot_to_label[getprop("/autopilot/locks/speed")]
    );
    setprop(
        "/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/altitude",
        autopilot_to_label[getprop("/autopilot/locks/altitude")]
    );
}

var event_click_hold_autopilot = func()
{
    setprop("/instrumentation/my_aircraft/pfd/controls/hold-blink", 1);

    # set AP altitude as curent altitude
    var curr_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 5000;
    setprop("/autopilot/settings/target-altitude-ft", curr_alt);

    # set AP speed as current speed
    var curr_speed = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 300;
    setprop("/autopilot/settings/target-speed-kt", curr_speed);

    # set AP heading as curent heading
    var curr_heading = getprop("/orientation/heading-magnetic-deg") or 0;
    setprop("/autopilot/settings/heading-bug-deg", curr_heading);

    # arm AP for altitude, speed and heading
    setprop("/autopilot/internal/target-roll-deg",          0);
    setprop("/autopilot/internal/target-climb-rate-fps",    0);
    setprop("/autopilot/locks/altitude",                    'altitude-hold');
    setprop("/autopilot/locks/heading",                     'dg-heading-hold');
    event_click_lock_speed(1);

    var time_speed = getprop("/sim/speed-up") or 1;
    var loop_speed = (time_speed == 1) ? .1 : 2 * time_speed;
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/hold-blink", 0); }, loop_speed * 2);
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/hold-blink", 1); }, loop_speed * 4);
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/hold-blink", 0); }, loop_speed * 6);
}

var event_click_disengage_autopilot = func()
{
    setprop("/instrumentation/my_aircraft/pfd/controls/disengage-blink", 1);

    # disengage AP for altitude, speed and heading
    event_click_lock_alt(0);
    event_click_lock_speed(0);
    setprop("/autopilot/locks/heading",  '');

    var time_speed = getprop("/sim/speed-up") or 1;
    var loop_speed = (time_speed == 1) ? .1 : 2 * time_speed;
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/disengage-blink", 0); }, loop_speed * 2);
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/disengage-blink", 1); }, loop_speed * 4);
    settimer(func() { setprop("/instrumentation/my_aircraft/pfd/controls/disengage-blink", 0); }, loop_speed * 6);
}

var event_click_lock_speed = func(do_enable)
{
    # do_enable == -1 : toggle
    if(do_enable == -1)
    {
        var is_ap_speed_locked = getprop("/autopilot/locks/speed") or '';
        var stdby_ap_speed     = getprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby") or 0;
        do_enable = ((is_ap_speed_locked == '') and (stdby_ap_speed == 0)) ? 1 : 0;
    }

    if(do_enable == 1)
    {
        setprop("/autopilot/locks/speed", 'speed-with-throttle');
        setprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby", 1);
    }
    else
    {
        setprop("/autopilot/locks/speed", '');
        setprop("/instrumentation/my_aircraft/pfd/controls/lock-speed-stdby", 0);
    }
    my_aircraft_functions.event_status_ap_speed();
}

var event_click_lock_alt = func(do_enable)
{
    # do_enable == -1 : toggle
    if(do_enable == -1)
    {
        var is_ap_alt_locked = getprop("/autopilot/locks/altitude") or '';
        do_enable = (is_ap_alt_locked == '') ? 1 : 0;
    }

    if(do_enable == 1)
    {
        setprop("/autopilot/locks/altitude", 'altitude-hold');
    }
    else
    {
        setprop("/autopilot/locks/altitude", '');
        setprop("/controls/flight/elevator-trim", 0);
#        setprop("/controls/flight/fbw/elevator", 0);
#        setprop("/controls/flight/fbw-elevator", 0);

#        var airspeed = getprop("/velocities/airspeed-kt") or 0;
#        if(airspeed > 300)
#        {
#            setprop("/controls/flight/elevator-trim", 0);
#        }
    }
    setprop("/autopilot/internal/target-climb-rate-fps", 0);
}








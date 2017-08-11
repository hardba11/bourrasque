print("*** LOADING instrument_pfd - pfd.nas ... ***");

# namespace : instrument_pfd

var pfd = func()
{
    # hide heading bug if object out of the pfd's box
    var heading_bug_error_deg = getprop('/autopilot/internal/heading-bug-error-deg') or 0;
    heading_bug_error_deg = math.abs(heading_bug_error_deg);
    var display_heading_bug = (heading_bug_error_deg > 80) ? 0 : 1;
    setprop('/instrumentation/my_aircraft/pfd/controls/display-heading-bug', display_heading_bug);

    settimer(pfd, 1);
}

setlistener('/sim/signals/fdm-initialized', pfd);

var event_click_hold_autopilot = func()
{
    # set AP altitude as curent altitude
    var curr_alt = getprop('/position/altitude-ft') or 5000;
    setprop('/autopilot/settings/target-altitude-ft', curr_alt);

    # set AP speed as curent speed
    var curr_speed = getprop('/velocities/airspeed-kt') or 300;
    setprop('/autopilot/settings/target-speed-kt', curr_speed);

    # set AP heading as curent heading
    var curr_heading = getprop('/orientation/heading-magnetic-deg') or 0;
    setprop('/autopilot/settings/heading-bug-deg', curr_heading);

    # arm AP for altitude, speed and heading
    setprop('/autopilot/internal/target-roll-deg',          0);
    setprop('/autopilot/internal/target-climb-rate-fps',    0);
    setprop('/autopilot/locks/altitude',                    'altitude-hold');
    setprop('/autopilot/locks/speed',                       'speed-with-throttle');
    setprop('/autopilot/locks/heading',                     'dg-heading-hold');
}

var event_click_disengage_autopilot = func()
{
    # disengage AP for altitude, speed and heading
    setprop('/autopilot/locks/altitude', '');
    setprop('/autopilot/locks/speed',    '');
    setprop('/autopilot/locks/heading',  '');
}


print("*** LOADING instrument_pfd - pfd.nas ... ***");

# namespace : instrument_pfd

var autopilot_to_label = {
    '': '-',
#/autopilot/locks/heading
    'dg-heading-hold': 'HDG',
    'true-heading-hold': 'TRU',
    'nav1-hold': 'NAV',
    'wing-leveler': 'LVL',
#/autopilot/locks/speed
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
    var heading_bug_error_deg = getprop('/autopilot/internal/heading-bug-error-deg') or 0;
    heading_bug_error_deg = math.abs(heading_bug_error_deg);
    var display_heading_bug = (heading_bug_error_deg > 80) ? 0 : 1;
    setprop('/instrumentation/my_aircraft/pfd/controls/display-heading-bug', display_heading_bug);

    # update label
    setprop(
        '/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/heading',
        autopilot_to_label[getprop('/autopilot/locks/heading')]
    );
    setprop(
        '/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/speed',
        autopilot_to_label[getprop('/autopilot/locks/speed')]
    );
    setprop(
        '/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/altitude',
        autopilot_to_label[getprop('/autopilot/locks/altitude')]
    );

    settimer(pfd, 1);
}

setlistener('/sim/signals/fdm-initialized', pfd);

var event_click_hold_autopilot = func()
{
    setprop('/instrumentation/my_aircraft/pfd/controls/hold-blink', 1);

    # set AP altitude as curent altitude
    var curr_alt = getprop('/instrumentation/altimeter/indicated-altitude-ft') or 5000;
    setprop('/autopilot/settings/target-altitude-ft', curr_alt);

    # set AP speed as current speed
    var curr_speed = getprop('/instrumentation/airspeed-indicator/true-speed-kt') or 300;
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

    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/hold-blink', 0); }, 0.2);
    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/hold-blink', 1); }, 0.4);
    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/hold-blink', 0); }, 0.6);
}

var event_click_disengage_autopilot = func()
{
    setprop('/instrumentation/my_aircraft/pfd/controls/disengage-blink', 1);

    # disengage AP for altitude, speed and heading
    setprop('/autopilot/locks/altitude', '');
    setprop('/autopilot/locks/speed',    '');
    setprop('/autopilot/locks/heading',  '');

    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/disengage-blink', 0); }, 0.2);
    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/disengage-blink', 1); }, 0.4);
    settimer(func() { setprop('/instrumentation/my_aircraft/pfd/controls/disengage-blink', 0); }, 0.6);
}


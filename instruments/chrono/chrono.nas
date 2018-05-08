print("*** LOADING instrument_chrono - chrono.nas ... ***");

# namespace : instrument_chrono


# controls :
# - knob top right : choose mode 0=>UTC, 1=>LOC, 2=>CHR
# - btn top left   : start/pause chrono
# - knob bottom    : ET mode : 0=>HOLD, 1=>RUN, 2=>RESET
#
# affichage selon les modes:
# - heure LOC : heure, minutes, secondes (aiguille), date jj mm (digit bas)
# - heure UTC : heure, minutes, secondes (aiguille), date jj mm (digit bas)
# - chrono CHR : elapsed time secondes (digit bas) centiemes secondes (aiguille), et hh et mm (digit haut)

var is_running       = 0;
var is_hold          = 0;
var is_reset         = 0;
var start_time       = 0;
var stop_time        = 0;
var run_time         = 0;
var accumulated_time = 0;
var colon_blink_on   = 1;

var event_click_mode_knob = func(inc)
{
    var mode_no = getprop("/instrumentation/my_aircraft/chrono/controls/mode-knob") or 0;
    mode_no = math.mod(mode_no + inc, 3);
    setprop("/instrumentation/my_aircraft/chrono/controls/mode-knob", mode_no);

    node_digit_tl = props.globals.getNode("/instrumentation/my_aircraft/chrono/outputs/digit-tl");
    node_digit_tr = props.globals.getNode("/instrumentation/my_aircraft/chrono/outputs/digit-tr");
    node_digit_bl = props.globals.getNode("/instrumentation/my_aircraft/chrono/outputs/digit-bl");
    node_digit_br = props.globals.getNode("/instrumentation/my_aircraft/chrono/outputs/digit-br");
    node_needle   = props.globals.getNode("/instrumentation/my_aircraft/chrono/outputs/needle");

    if(mode_no == 0)
    {
        # mode displaying UTC time, day and month
        node_digit_tl.unalias();
        node_digit_tl.alias("/instrumentation/clock/indicated-hour");
        node_digit_tr.unalias();
        node_digit_tr.alias("/instrumentation/clock/indicated-min");
        node_digit_bl.unalias();
        node_digit_bl.alias("/sim/time/real/day");
        node_digit_br.unalias();
        node_digit_br.alias("/sim/time/real/month");
        node_needle.unalias();
        node_needle.alias("/instrumentation/clock/indicated-sec");
    }
    elsif(mode_no == 1)
    {
        # mode displaying LOCAL time, day and month
        node_digit_tl.unalias();
        node_digit_tl.alias("/instrumentation/clock/local-hour");
        node_digit_tr.unalias();
        node_digit_tr.alias("/instrumentation/clock/indicated-min");
        node_digit_bl.unalias();
        node_digit_bl.alias("/sim/time/real/day");
        node_digit_br.unalias();
        node_digit_br.alias("/sim/time/real/month");
        node_needle.unalias();
        node_needle.alias("/instrumentation/clock/indicated-sec");
    }
    elsif(mode_no == 2)
    {
        # mode CHRONO displaying elapsed time
        node_digit_tl.unalias();
        node_digit_tl.alias("/instrumentation/my_aircraft/chrono/et-hour");
        node_digit_tr.unalias();
        node_digit_tr.alias("/instrumentation/my_aircraft/chrono/et-min");
        node_digit_bl.unalias();
        node_digit_bl.alias("/instrumentation/my_aircraft/chrono/et-sec");
        node_digit_br.unalias();
        node_digit_br.alias("/instrumentation/my_aircraft/chrono/et-msec");
        node_needle.unalias();
        node_needle.alias("/instrumentation/my_aircraft/chrono/needle-msec");
    }
}

var event_click_et_knob = func()
{
    var et_no = getprop("/instrumentation/my_aircraft/chrono/controls/et-knob") or 0;

    # mod 2 (not 3) because we only allow position 0 or 1 to avoid
    # making mistake with reset (position 2)
    et_no = math.mod(et_no + 1, 2);
    setprop("/instrumentation/my_aircraft/chrono/controls/et-knob", et_no);

    if(et_no == 0)
    {
        # hold : chrono running but digits frozen
        is_hold = 1;
        is_reset = 0;
    }
    elsif(et_no == 1)
    {
        # run : chrono running
        is_hold = 0;
        is_reset = 0;
        loop_chrono();
    }
}
var event_click_et_knob_reset = func()
{
    # reset
    et_no = 2;
    setprop("/instrumentation/my_aircraft/chrono/controls/et-knob", et_no);
    is_reset = 1;
    is_running = 0;
    is_hold = 0;
    start_time = 0;
    stop_time = 0;
    run_time = 0;
    accumulated_time = 0;
    setprop("/instrumentation/my_aircraft/chrono/et-hour",     0);
    setprop("/instrumentation/my_aircraft/chrono/et-min",      0);
    setprop("/instrumentation/my_aircraft/chrono/et-sec",      0);
    setprop("/instrumentation/my_aircraft/chrono/et-msec",     0);
    setprop("/instrumentation/my_aircraft/chrono/needle-msec", 0);
}

var event_click_chr_btn = func()
{
    if(is_reset == 0)
    {
        if(is_running == 0)
        {
            # chrono started : we keep start time
            start_time = getprop("/sim/time/elapsed-sec") or 0;
            is_running = 1;
            loop_chrono();
        }
        else
        {
            # chrono stopped : we calculate last run time and add it
            # to accumulated time
            stop_time = getprop("/sim/time/elapsed-sec") or 0;
            run_time = stop_time - start_time;
            accumulated_time += run_time;
            is_running = 0;
        }
    }
}

var loop_chrono = func()
{
    if((is_running == 1) and (is_reset == 0))
    {
        var et = getprop("/sim/time/elapsed-sec") or 0;

        et = et - start_time + accumulated_time;

        var et_hour = et / 3600;
        var et_min  = int(math.mod(et / 60, 60));
        var et_sec  = int(math.mod(et, 60));
        var et_msec = int(math.mod(et * 1000, 1000) / 10);
        var needle_msec = et_msec * 0.6;

        # colon blink if running (even if hold)
        colon_blink_on = (et_msec > 50) ? 0 : 1;
        setprop("/instrumentation/my_aircraft/chrono/outputs/colon", colon_blink_on);

        if(is_hold == 0)
        {
            setprop("/instrumentation/my_aircraft/chrono/et-hour",     et_hour);
            setprop("/instrumentation/my_aircraft/chrono/et-min",      et_min);
            setprop("/instrumentation/my_aircraft/chrono/et-sec",      et_sec);
            setprop("/instrumentation/my_aircraft/chrono/et-msec",     et_msec);
            setprop("/instrumentation/my_aircraft/chrono/needle-msec", needle_msec);
        }
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .01 : 2 * time_speed;
        settimer(loop_chrono, loop_speed);
    }
}


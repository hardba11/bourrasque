print("*** LOADING instrument_command_h - command_h.nas ... ***");

# namespace : instrument_command_h
var blink = func()
{
    var is_alert = getprop('/instrumentation/my_aircraft/command_h/is_alert') or 0;
    var is_ack = getprop('/instrumentation/my_aircraft/command_h/ack_alert') or 0;
    var blink_on = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0;

    # alert and ack : no blink
    if(is_alert and is_ack)
    {
        setprop('/instrumentation/my_aircraft/command_h/blink_alert', 1);
    }
    # alert : blink
    elsif(is_alert and blink_on)
    {
        setprop('/instrumentation/my_aircraft/command_h/blink_alert', 0);
    }
    elsif(is_alert and ! blink_on)
    {
        setprop('/instrumentation/my_aircraft/command_h/blink_alert', 1);
    }
    elsif(! is_alert)
    {
        setprop('/instrumentation/my_aircraft/command_h/blink_alert', 0);
    }
    settimer(blink, .5);
}

setlistener('/sim/signals/fdm-initialized', blink);


print("*** LOADING instrument_sfd - sfd.nas ... ***");

# namespace : instrument_sfd

var event_click_acknowledge_master_caution = func()
{
    var is_alert = getprop('/instrumentation/my_aircraft/command_h/is_alert') or 0;
    var is_ack = getprop('/instrumentation/my_aircraft/command_h/ack_alert') or 0;

    # first click : alert remain (master caution no blinking and alert-sound disabled) :
    if(is_alert and ! is_ack)
    {
        setprop('/instrumentation/my_aircraft/command_h/ack_alert', 1);
    }
    # second click : reinit
    elsif(is_alert and is_ack)
    {
        setprop('/instrumentation/my_aircraft/command_h/is_alert', 0);
        setprop('/instrumentation/my_aircraft/command_h/ack_alert', 0);
    }
}


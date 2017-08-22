print("*** LOADING instrument_hud - hud.nas ... ***");
################################################################################
#
#                          MINI-HUD SWITCHING
#
################################################################################

# namespace : instrument_hud

# this function will display hud #1 (standard) or hud #4 (mini-hud).
var minihud_loop = func()
{
    var hud_number     = getprop("/sim/hud/current-path");
    #var is_internal    = getprop("/sim/current-view/internal");
    var is_pilot       = getprop("/sim/current-view/view-number") == 0;

    var is_on          = getprop("/systems/electrical/bus/avionics");

    var heading_offset = getprop("/sim/current-view/heading-offset-deg");
    var pitch_offset   = getprop("/sim/current-view/pitch-offset-deg");
    
    var x = math.sin(heading_offset * math.pi / 180);
    var y = math.sin(pitch_offset * math.pi / 180);
    var distance_from_center = (x * x) + (y * y);
    var is_looking_behind = (math.cos(heading_offset * math.pi / 180) < 0) ? 1 : 0;
    
    # we check if internal or not :
    if(is_pilot == 1)
    {
        if(distance_from_center > 0.6 or is_looking_behind == 1)
        {
            if(hud_number != 4)
            {
                # head turned, mini hud is displayed
                hud_number = 4;
                setprop("/sim/hud/current-path", hud_number);
                setprop("/sim/hud/clipping/left",   -2000);
                setprop("/sim/hud/clipping/right",   2000);
                setprop("/sim/hud/clipping/top",     2000);
                setprop("/sim/hud/clipping/bottom", -2000);
            }
        }
        else
        {
            if(hud_number != 1)
            {
                # head centered, normal hud is displayed
                hud_number = 1;
                setprop("/sim/hud/current-path", hud_number);
                setprop("/sim/hud/clipping/left",   -130);
                setprop("/sim/hud/clipping/right",   130);
                setprop("/sim/hud/clipping/top",      95);
                setprop("/sim/hud/clipping/bottom",  -95);
            }
            # if too much G, and dynamic cockpit view enabled, the bottom of
            # the hud is hidden
            var is_dynamic_view = getprop("/sim/current-view/dynamic-view");
            if(is_dynamic_view)
            {
                var dynamic_clipping_bottom = -(95 - (getprop("/accelerations/pilot-gdamped") * 7));
                setprop("/sim/hud/clipping/bottom", dynamic_clipping_bottom);
            }
        }
    }
    else
    {
        if(hud_number != 4)
        {
            hud_number = 4;
            setprop("/sim/hud/current-path", hud_number);
            setprop("/sim/hud/clipping/left",   -2000);
            setprop("/sim/hud/clipping/right",   2000);
            setprop("/sim/hud/clipping/top",     2000);
            setprop("/sim/hud/clipping/bottom", -2000);
        }
    }

    if(is_on)
    {
        setprop("/sim/hud/visibility["~ hud_number ~"]", 1);
    }
    else
    {
        setprop("/sim/hud/visibility["~ hud_number ~"]", 0);
    }

    settimer(minihud_loop, 0.5);
}
var hud_number = getprop("/sim/hud/current-path");
if(hud_number == 1)
{
    setprop("/sim/hud/clipping/left",   -130);
    setprop("/sim/hud/clipping/right",   130);
    setprop("/sim/hud/clipping/top",      95);
    setprop("/sim/hud/clipping/bottom",  -95);
}
elsif(hud_number == 4)
{
    setprop("/sim/hud/clipping/left",   -2000);
    setprop("/sim/hud/clipping/right",   2000);
    setprop("/sim/hud/clipping/top",     2000);
    setprop("/sim/hud/clipping/bottom", -2000);
}

setlistener('/sim/signals/fdm-initialized', minihud_loop);

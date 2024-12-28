print("*** LOADING instrument_hud - hud.nas ... ***");
################################################################################
#
#                          MINI-HUD SWITCHING
#
################################################################################

# namespace : instrument_hud

var clipping_left   = -130;
var clipping_right  =  130;
var clipping_top    =   95;
var clipping_bottom =  -95;

# this function will display hud #1 (standard) or hud #4 (mini-hud).
var minihud_loop = func()
{
    var hud_number     = getprop("/sim/hud/current-path");
    var is_pilot       = getprop("/sim/current-view/view-number-raw") == 0;

    var is_on          = getprop("/systems/electrical/bus/avionics");

    var heading_offset = getprop("/sim/current-view/heading-offset-deg");
    var pitch_offset   = getprop("/sim/current-view/pitch-offset-deg");

    var x_offset       = getprop("/sim/current-view/x-offset-m");
    var y_offset       = getprop("/sim/current-view/y-offset-m");
    var z_offset       = getprop("/sim/current-view/z-offset-m");
    
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
                setprop("/sim/hud/current-path",     hud_number);
                setprop("/sim/hud/clipping/left",    200);
                setprop("/sim/hud/clipping/right",   400);
                setprop("/sim/hud/clipping/top",     400);
                setprop("/sim/hud/clipping/bottom",  100);
            }
        }
        else
        {
            if(hud_number != 1)
            {
                # head centered, normal hud is displayed
                hud_number = 1;
                setprop("/sim/hud/current-path", hud_number);
            }

            # if not hud full view, we crop (@see functions.nas)
            if (z_offset > -7)
            {
                setprop("/sim/hud/clipping/left",   (clipping_left   - (x_offset          * 1000)));
                setprop("/sim/hud/clipping/right",  (clipping_right  - (x_offset          * 1000)));
                setprop("/sim/hud/clipping/top",    (clipping_top    - ((y_offset - 1.10) * 1000)));
                setprop("/sim/hud/clipping/bottom", (clipping_bottom - ((y_offset - 1.10) * 1000)));
            }
            else
            {
                setprop("/sim/hud/clipping/left",   clipping_left - 50);
                setprop("/sim/hud/clipping/right",  clipping_right + 50);
                setprop("/sim/hud/clipping/top",    clipping_top + 50);
                setprop("/sim/hud/clipping/bottom", clipping_bottom - 50);
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
            setprop("/sim/hud/current-path",    hud_number);
            setprop("/sim/hud/clipping/left",   200);
            setprop("/sim/hud/clipping/right",  400);
            setprop("/sim/hud/clipping/top",    400);
            setprop("/sim/hud/clipping/bottom", 100);
        }
    }

    if(is_on)
    {
        setprop("/sim/hud/visibility[1]", 1);
        setprop("/sim/hud/visibility[4]", 1);
    }
    else
    {
        setprop("/sim/hud/visibility[1]", 0);
        setprop("/sim/hud/visibility[4]", 0);
    }
}

var hud_number = getprop("/sim/hud/current-path");
if(hud_number == 1)
{
    setprop("/sim/hud/clipping/left",   clipping_left);
    setprop("/sim/hud/clipping/right",  clipping_right);
    setprop("/sim/hud/clipping/top",    clipping_top);
    setprop("/sim/hud/clipping/bottom", clipping_bottom);
}
elsif(hud_number == 4)
{
    setprop("/sim/hud/clipping/left",   200);
    setprop("/sim/hud/clipping/right",  400);
    setprop("/sim/hud/clipping/top",    400);
    setprop("/sim/hud/clipping/bottom", 100);
}



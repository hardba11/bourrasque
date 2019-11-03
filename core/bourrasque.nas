print("*** LOADING core - bourrasque.nas ... ***");

# namespace : core

var egtf2egtc = func() {
    setprop("/engines/engine[0]/egt", 0);
    var m0egt_degf = getprop("/engines/engine[0]/egt-degf");
    if(m0egt_degf)
    {
        var m0egt = my_aircraft_functions.DF2DC(m0egt_degf);
        setprop("/engines/engine[0]/egt", m0egt);
    }
    setprop("/engines/engine[1]/egt", 0);
    var m1egt_degf = getprop("/engines/engine[1]/egt-degf");
    if(m1egt_degf)
    {
        var m1egt = my_aircraft_functions.DF2DC(m1egt_degf);
        setprop("/engines/engine[1]/egt", m1egt);
    }
}

var vor_true_to_mag = func() {
    var tru_orientation = getprop("/orientation/heading-deg") or 0;
    var mag_orientation = getprop("/orientation/heading-magnetic-deg") or 0;

    var nav1_tru = getprop("/instrumentation/nav[0]/heading-deg") or 0;
    setprop("/instrumentation/nav[0]/heading-magnetic-deg", nav1_tru + (mag_orientation - tru_orientation));

    var nav2_tru = getprop("/instrumentation/nav[1]/heading-deg") or 0;
    setprop("/instrumentation/nav[1]/heading-magnetic-deg", nav2_tru + (mag_orientation - tru_orientation));
}

var loud_sound = func() {
    var is_internal = getprop("sim/current-view/internal") or 0;
    var canopy_position = getprop("sim/model/canopy-pos-norm") or 0;
    setprop("/environment/loud-sound", ((is_internal == 1) and (canopy_position == 0)) ? 0.2 : 1);
}

var update_alarms = func() {
    var stall_warning = 0;
    var speed = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0;
    var aoa = getprop("/orientation/alpha-deg") or 0;
    if(speed < 120)
    {
        if(aoa >= 9)  { stall_warning = 1; }
        if(aoa >= 13) { stall_warning = 2; }
    }
    setprop("/sim/alarms/stall-warning", stall_warning);
}

var is_smoke   = [0, 0, 0];
var wow_gear   = [0, 0, 0];
var buffer_wow = [0, 0, 0]; # keep value of wow between cycles
var cycle_wow  = [0, 2, 2]; # number of nasal cycles for smoking
var touchdown_smoke = func() {
    var groundspeed  = getprop("/velocities/groundspeed-kt") or 0;
    for(var i = 1; i <= 2; i += 1)
    {
        wow_gear[i] = getprop("/gear/gear["~i~"]/wow") or 0;

        # if last wow value was 0 (airborn last cycle) and current wow value is 1, begin smoke
        if((buffer_wow[i] == 0)
            and (wow_gear[i] == 1)
            and (is_smoke[i] == 0)
            and (groundspeed > 80))
        {
            is_smoke[i] = 1;
        }
        buffer_wow[i] = wow_gear[i];

        if(is_smoke[i] == 1)
        {
            # smoking during 2 cycles
            if(cycle_wow[i] > 0)
            {
                cycle_wow[i] -= 1;
            }
            else
            {
                is_smoke[i] = 0;
            }
        }
        else
        {
            # end of cycle, stopping smoke and reinit
            cycle_wow[i] = 2;
        }
        setprop("/gear/gear["~i~"]/tyre-smoke", is_smoke[i]);
    }
}

# /instrumentation/my_aircraft/pfd/controls/hippodrome
# - 0: desactive
# - 1: actif
# top
# - 0: ne rien faire (ligne droite)
# - 1: debut ligne droite : lancer virage dans 300s
# - 2: virage en cours : detecter la fin
# - 3: attendre
var top_hippo = 0;
var hippo_turn = func() {
    #print("+++ call hippo_turn");

    hippo_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    if((hippo_enabled == 1) and (top_hippo == 3))
    {
        setprop("/sim/messages/pilot", 'starting turn.');
        var ap_heading = sprintf("%d", getprop("/autopilot/settings/heading-bug-deg") or 0);

        var new_heading = (ap_heading > 180) ? ap_heading - 180 : ap_heading + 180;
        var tmp_heading = (ap_heading > 270) ? ap_heading - 90 : ap_heading + 270;

        settimer(func() {
            setprop("/autopilot/settings/heading-bug-deg", tmp_heading);
        }, 0);
        settimer(func() {
            setprop("/autopilot/settings/heading-bug-deg", new_heading);
            top_hippo = 2;
        }, 5);
    }
}

var mp_encode = func(list_of_values) {
    var values_encoded = 0;

    forindex(var index; list_of_values)
    {
        if((list_of_values[index] == 1) or (list_of_values[index] == 0))
        {
            values_encoded += list_of_values[index] * math.pow(2, index);
        }
    }
    return values_encoded;
}

# 
#         LOCAL                                 MULTIPLAY
# .---------------------.                .----------------------.
# |       MODEL         |                |         MODEL        |
# |  - sim/model/prop1  |       <=>      |  - sim/model/prop1   |
# |  - sim/model/prop2  |                |  - sim/model/prop2   |
# +---------------------+                +----------------------+
# | bourrasque-set.xml  |                | bourrasque-model.xml |
# |  - /sim/model/prop1 |                |  - sim/model/prop1   | => /ai/.../multiplay[x]/sim/model/prop1
# |  - /sim/model/prop2 |                |  - sim/model/prop2   |
# !_____________________!                !______________________!
#           |                                      ^
#           V                                      |
# .-------------------------.            .-------------------.
# | bourrasque.nas::encode  |            | brsq.xml::decode  |
# !_________________________!            !___________________!
#           |                                      ^
#           V                                      |
#  .--------------------------------------------------------------.
#  |                /sim/multiplay/generic/int[0]                 |
#  !______________________________________________________________!
# 
# 
#  encoding 6 bool properties to 1 integer
#    +---------------------- property
#    |   +------------------ property
#    |   |   +-------------- property
#    |   |   |   +---------- property
#    |   |   |   |   +------ property
#    |   |   |   |   |   +-- property
#    v   v   v   v   v   v
#    1   0   1   0   1   1 
#   32  16   8   4   2   1 
#  ----------------------------
#   32     + 8     + 2 + 1 = 43

var bourrasque_mp_loop_encode = func() {
    # encoded in int[0] :
    var beacon                  = getprop("/controls/lighting/beacon") or 0;
    var nav_lights              = getprop("/controls/lighting/nav-lights") or 0;
    var pos_lights              = getprop("/controls/lighting/pos-lights") or 0;
    var strobe                  = getprop("/controls/lighting/strobe") or 0;
    var taxi_light              = getprop("/controls/lighting/taxi-light") or 0;
    var smoking                 = getprop("/sim/model/smoking") or 0;
    setprop("/sim/multiplay/generic/int[0]", mp_encode([
        beacon,
        nav_lights,
        pos_lights,
        strobe,
        taxi_light,
        smoking]));

    # encoded in int[1] :
    var ground_equipment_e      = getprop("/sim/model/ground-equipment-e") or 0;
    var ground_equipment_g      = getprop("/sim/model/ground-equipment-g") or 0;
    var ground_equipment_s      = getprop("/sim/model/ground-equipment-s") or 0;
    var ground_equipment_p      = getprop("/sim/model/ground-equipment-p") or 0;
    var ground_equipment_f      = getprop("/sim/model/ground-equipment-f") or 0;
    var wing_tanks_1250         = getprop("/sim/model/wing-tanks-1250") or 0;
    var wing_tanks_2000         = getprop("/sim/model/wing-tanks-2000") or 0;
    var center_tank_1250        = getprop("/sim/model/center-tank-1250") or 0;
    var center_tank_2000        = getprop("/sim/model/center-tank-2000") or 0;
    var center_refuel_pod       = getprop("/sim/model/center-refuel-pod") or 0;
    var wing_pylons_smoke_pod   = getprop("/sim/model/wing-pylons-smoke-pod") or 0;
    setprop("/sim/multiplay/generic/int[1]", mp_encode([
        ground_equipment_e,
        ground_equipment_g,
        ground_equipment_s,
        ground_equipment_p,
        ground_equipment_f,
        wing_tanks_1250,
        wing_tanks_2000,
        center_tank_1250,
        center_tank_2000,
        center_refuel_pod,
        wing_pylons_smoke_pod]));

    # encoded in int[2] :
    var bus_avionics            = getprop("/systems/electrical/bus/avionics") or 0;
    var bus_engines             = getprop("/systems/electrical/bus/engines") or 0;
    var bus_command             = getprop("/systems/electrical/bus/commands") or 0;
    var engine0_stopped         = getprop("/engines/engine[0]/stopped") or 0;
    var engine1_stopped         = getprop("/engines/engine[1]/stopped") or 0;
    var pax_pilot               = getprop("/controls/pax/pilot") or 0;
    var pax_copilot             = getprop("/controls/pax/copilot") or 0;
    var refuel_serviceable      = getprop("/systems/refuel/serviceable") or 0;
    var carrier_equipment       = getprop("/sim/model/carrier-equipment") or 0;
    setprop("/sim/multiplay/generic/int[2]", mp_encode([
        bus_avionics,
        bus_engines,
        bus_command,
        engine0_stopped,
        engine1_stopped,
        pax_pilot,
        pax_copilot,
        refuel_serviceable,
        carrier_equipment]));
}

var calculate_shake = func() {

    var shake_enabled = getprop("/controls/cockpit/shake-effect") or 0;
    var is_crashed    = getprop("/sim/crashed") or 0;
    # frequence (entre 1=mer calme et 75=secousses)
    # amplitude (entre 200=bcp et 800=peu)

    if((shake_enabled == 1) and ! is_crashed)
    {
        var my_time = getprop("/sim/time/elapsed-sec");

        var shake_x = 0;
        var shake_y = 0;
        var shake_z = 0;

        var wow    = getprop("/gear/gear[1]/wow") or 0;
        var speed  = getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0;
        var aoa    = getprop("/orientation/alpha-deg") or 0;
        var x_acc  = getprop("/fdm/yasim/accelerations/a-x") or 0;
        var z_acc  = getprop("/accelerations/pilot/z-accel-fps_sec") or 0;
        var alt    = getprop("/position/altitude-agl-ft") or 0;
        var g_load = z_acc * -0.03108095;
        if((wow == 1) and (speed > 5))
        {
            shake_y = math.sin(11 * my_time) / (1 + (1000 * 150 / (speed + 1)));
            shake_z = math.sin(15 * my_time) / (1 + (400 * 150 / (speed + 1)));
        }
        elsif((g_load > 4) or ((aoa > 10) and (wow == 0)))
        {
            shake_y = math.sin(9 * my_time) / (1 + (2000 * 7 / (aoa + 1)));
            shake_z = math.sin(75 * my_time) / (1 + (700 * 5 / (aoa + 1)));
        }
        elsif((alt < 10000) and (speed > 100) and (wow == 0))
        {
            var facteur_speed = 1 + ((-15 / 20) * speed) + 2075;
            var facteur_alt = 1 + (math.abs(alt) / 3);
            shake_y = (math.sin(3 * my_time) / (facteur_speed + facteur_alt)) + (math.sin(2 * my_time) / (facteur_speed + facteur_alt));
            shake_z = (math.sin(4 * my_time) / (facteur_speed + facteur_alt)) + (math.sin(3 * my_time) / (facteur_speed + facteur_alt));
        }

        shake_x = -1.5 / (1 + (100 * 10 / (x_acc + 1)));

        setprop("/controls/cockpit/shaking-x", shake_x);
        setprop("/controls/cockpit/shaking-y", shake_y);
        setprop("/controls/cockpit/shaking-z", shake_z);
    }
    else
    {
        setprop("/controls/cockpit/shaking-x", 0);
        setprop("/controls/cockpit/shaking-y", 0);
        setprop("/controls/cockpit/shaking-z", 0);
    }
}

var calculate_shake_external_view = func() {

    # x: left/right - y:down/up - z:fwd/back

    var shake_enabled = getprop("/controls/cockpit/shake-effect") or 0;
    var is_crashed    = getprop("/sim/crashed") or 0;

    if((shake_enabled == 1) and ! is_crashed)
    {
        var view_number     = getprop("/sim/current-view/view-number") or 0;
        var wow             = getprop("/gear/gear[1]/wow") or 0;
        var offset_saved    = getprop("/sim/current-view/offset-saved") or 0;

        # camera reference point
        var x_offset_set   = getprop("/sim/current-view/x-offset-sav") or 0;
        var y_offset_set   = getprop("/sim/current-view/y-offset-sav") or 0;
        var z_offset_set   = getprop("/sim/current-view/z-offset-sav") or 0;

        var x_offset_current   = getprop("/sim/current-view/x-offset-m") or 0;
        var y_offset_current   = getprop("/sim/current-view/y-offset-m") or 0;
        var z_offset_current   = getprop("/sim/current-view/z-offset-m") or 0;

        # detect if camera moved by user :
        if((math.abs(x_offset_current - x_offset_set) > .2)
           or (math.abs(y_offset_current - y_offset_set) > .2)
           or (math.abs(z_offset_current - z_offset_set) > .2))
        {
            offset_saved = 0;
        }

        # save camera position
        if(offset_saved == 0)
        {
            x_offset_set = x_offset_current;
            y_offset_set = y_offset_current;
            z_offset_set = z_offset_current;

            # back up offset
            setprop("/sim/current-view/x-offset-sav", x_offset_current);
            setprop("/sim/current-view/y-offset-sav", y_offset_current);
            setprop("/sim/current-view/z-offset-sav", z_offset_current);
            setprop("/sim/current-view/offset-saved", 1);
        }

        # shaking external camera if airborn
        if((wow == 0)
            and ((view_number == 1) or (view_number == 2) or (view_number == 5) or (view_number == 7)))
        {
            var my_time = getprop("/sim/time/elapsed-sec");
            move_x = (math.sin(1.5 * my_time) / 50) + (math.sin(2.5 * my_time) / 65) + (math.sin(4.5 * my_time) / 90);
            move_y = (math.sin(1 * my_time) / 20) + (math.sin(3 * my_time) / 30) + (math.sin(5 * my_time) / 40);
            move_z = (math.sin(2 * my_time) / 40);

            setprop("/sim/current-view/target-x-offset-m", move_x);
            setprop("/sim/current-view/target-y-offset-m", move_y);
            setprop("/sim/current-view/target-z-offset-m", move_z);

            setprop("/sim/current-view/x-offset-m", x_offset_set - (move_x * 1.1));
            setprop("/sim/current-view/y-offset-m", y_offset_set - (move_y * 1.3));
            setprop("/sim/current-view/z-offset-m", z_offset_set - (move_z * 0.9));
        }
        else
        {
            setprop("/sim/current-view/target-x-offset-m", 0);
            setprop("/sim/current-view/target-y-offset-m", 0);
            setprop("/sim/current-view/target-z-offset-m", 0);

            setprop("/sim/current-view/x-offset", x_offset_set);
            setprop("/sim/current-view/y-offset", y_offset_set);
            setprop("/sim/current-view/z-offset", z_offset_set);
            setprop("/sim/current-view/x-offset-sav", 0);
            setprop("/sim/current-view/y-offset-sav", 0);
            setprop("/sim/current-view/z-offset-sav", 0);
            setprop("/sim/current-view/offset-saved", 0);
        }
    }
}


var hippo_loop = func() {
    hippo_enabled = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome") or 0;
    if(hippo_enabled == 1)
    {
        var leg_duration = getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome-leg-duration") or 30;
        if(top_hippo == 0)
        {
            #print("+++ activation");
            top_hippo = 1;
        }
        elsif(top_hippo == 1)
        {
            #print("+++ top droite");
            setprop("/sim/messages/pilot", 'starting hippodrom leg, turn in '~ leg_duration ~' seconds.');
            settimer(func() { if(getprop("/instrumentation/my_aircraft/pfd/controls/hippodrome")){ setprop("/sim/messages/pilot", 'turn in 10 seconds.'); } }, (leg_duration - 10));
            settimer(func() { hippo_turn(); }, leg_duration);
            top_hippo = 3;
        }
        elsif(top_hippo == 2)
        {
            var heading_bug_error_deg = math.abs(sprintf('%d', getprop("/autopilot/internal/heading-bug-error-deg") or 0));
            #print("+++ virage ... "~ heading_bug_error_deg);
            if(heading_bug_error_deg < 2)
            {
                #print("+++ fin virage");
                top_hippo = 1;
            }
        }
    }
    else
    {
        top_hippo = 0;
    }
}




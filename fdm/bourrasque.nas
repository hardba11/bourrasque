print("*** LOADING fdm - bourrasque.nas ... ***");

# namespace : fdm

# description :
# - mise a jour de proprietes communes (sur l'arbre de propriete original : pas
#   d'alias)
# - modification et calculs sur des proprietes
#

var egtf2egtc = func() {
    setprop('/engines/engine[0]/egt', 0);
    var m0egt_degf = getprop('/engines/engine[0]/egt-degf');
    if(m0egt_degf)
    {
        var m0egt = my_aircraft_functions.DF2DC(m0egt_degf);
        setprop('/engines/engine[0]/egt', m0egt);
    }
    setprop('/engines/engine[1]/egt', 0);
    var m1egt_degf = getprop('/engines/engine[1]/egt-degf');
    if(m1egt_degf)
    {
        var m1egt = my_aircraft_functions.DF2DC(m1egt_degf);
        setprop('/engines/engine[1]/egt', m1egt);
    }
}

var loud_sound = func() {
    var is_internal = getprop('sim/current-view/internal') or 0;
    var canopy_position = getprop('sim/model/canopy-pos-norm') or 0;
    setprop('/environment/loud-sound', ((is_internal == 1) and (canopy_position == 0)) ? 0.2 : 1);
}

var is_smoke1   = 0;
var buffer_wow1 = 1;
var cycle_wow1  = 2;
var is_smoke2   = 0;
var buffer_wow2 = 1;
var cycle_wow2  = 2;
var touchdown_smoke = func() {
    var wow_gear1 = getprop('/gear/gear[1]/wow') or 0;
    var wow_gear2 = getprop('/gear/gear[2]/wow') or 0;

    # if last wow value was 0 and current wow value is 1, begin smoke
    if(! buffer_wow1 and wow_gear1 and is_smoke1 == 0) { is_smoke1 = 1; }
    if(! buffer_wow2 and wow_gear2 and is_smoke2 == 0) { is_smoke2 = 1; }

    if(is_smoke1 == 1)
    {
        # smoking during 2 cycles
        if(cycle_wow1 > 0) { cycle_wow1 -= 1; }
        else               { is_smoke1 = 0;   }
        setprop('/gear/gear[1]/tyre-smoke', 1);
    }
    else
    {
        # end of cycle, stopping smoke and reinit
        cycle_wow1 = 2;
        setprop('/gear/gear[1]/tyre-smoke', 0);
    }
    if(is_smoke2 == 1)
    {
        # smoking during 2 cycles
        if(cycle_wow2 > 0) { cycle_wow2 -= 1; }
        else               { is_smoke2 = 0;   }
        setprop('/gear/gear[2]/tyre-smoke', 1);
    }
    else
    {
        # end of cycle, stopping smoke and reinit
        cycle_wow2 = 2;
        setprop('/gear/gear[2]/tyre-smoke', 0);
    }
    buffer_wow1 = wow_gear1;
    buffer_wow2 = wow_gear2;
}


# debug3
# 0: desactive
# 1: actif
# top
# 0: ne rien faire (ligne droite)
# 1: debut ligne droite : lancer virage dans 60s
# 2: virage en cours : detecter la fin
# 3: attendre
var top_hippo = 0;
var leg_duration = 300;

var hippo_turn = func() {
    #print("+++ call hippo_turn");
    setprop('/sim/messages/pilot', "starting turn.");
    var ap_heading = sprintf('%d', getprop('/autopilot/settings/heading-bug-deg') or 0);

    var new_heading = (ap_heading > 180) ? ap_heading - 180 : ap_heading + 180;
    var tmp_heading = (ap_heading > 270) ? ap_heading - 90 : ap_heading + 270;

    settimer(func() {
        setprop('/autopilot/settings/heading-bug-deg', tmp_heading);
    }, 0);
    settimer(func() {
        setprop('/autopilot/settings/heading-bug-deg', new_heading);
        top_hippo = 2;
    }, 5);
}

var hippo_loop = func() {
    hippo_enabled = getprop('/debug3') or 0;
    if(hippo_enabled == 1)
    {
        if(top_hippo == 0)
        {
            #print("+++ activation");
            top_hippo = 1;
        }
        elsif(top_hippo == 1)
        {
            #print("+++ top droite");
            setprop('/sim/messages/pilot', "starting hippodrom leg, turn in "~ leg_duration ~"s ...");
            settimer(func() { setprop('/sim/messages/pilot', "turn in 5s ..."); }, (leg_duration - 5));
            settimer(func() { hippo_turn(); }, leg_duration);
            top_hippo = 3;
        }
        elsif(top_hippo == 2)
        {
            var heading_bug_error_deg = math.abs(sprintf('%d', getprop('/autopilot/internal/heading-bug-error-deg') or 0));
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
    settimer(hippo_loop, 1);
}

var bourrasque_slow_loop = func() {

    # refueling cam if pod
    var center_pod = getprop('/sim/model/center-tank') or '' ;
    if(center_pod == '4')
    {
        setprop('/sim/view[104]/enabled', 1);
        setprop('/sim/view[102]/enabled', 0);
    }
    else
    {
        setprop('/sim/view[104]/enabled', 0);
        setprop('/sim/view[102]/enabled', 1);
    }

    # tail cam si backseat vide
    var is_copilot = getprop('/controls/pax/copilot') or 0 ;
    if(is_copilot == 1)
    {
        setprop('/sim/view[105]/enabled', 0);
        setprop('/sim/view[103]/enabled', 1);
    }
    else
    {
        setprop('/sim/view[105]/enabled', 1);
        setprop('/sim/view[103]/enabled', 0);
    }

    settimer(bourrasque_slow_loop, 5);
}


var bourrasque_loop = func() {

    # setting engine egt celcius from egt farenheit
    egtf2egtc();

    # setting altimeter kilopascal from inch hg
    setprop('/instrumentation/altimeter/setting-kpa', (getprop('/instrumentation/altimeter/setting-inhg') * my_aircraft_functions.INHG2HPA));

    # setting sound factor if internal and canopy closed
    loud_sound();

    # touchdown smoke
    touchdown_smoke();

    settimer(bourrasque_loop, .1);
}



setlistener('/sim/signals/fdm-initialized', bourrasque_loop);
setlistener('/sim/signals/fdm-initialized', hippo_loop);
setlistener('/sim/signals/fdm-initialized', bourrasque_slow_loop);
























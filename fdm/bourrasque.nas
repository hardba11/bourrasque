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

var bourrasque_loop = func() {

    # setting engine egt celcius from egt farenheit
    egtf2egtc();

    # setting altimeter kilopascal from inch hg
    setprop('/instrumentation/altimeter/setting-kpa', (getprop('/instrumentation/altimeter/setting-inhg') * my_aircraft_functions.INHG2HPA));

    # setting sound factor if internal and canopy closed
    loud_sound();

    # touchdown smoke
    touchdown_smoke();

    settimer(bourrasque_loop, 0.1);
}

setlistener('/sim/signals/fdm-initialized', bourrasque_loop);




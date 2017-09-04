print("*** LOADING fdm - bourrasque.nas ... ***");

# namespace : fdm

# description :
# - mise a jour de proprietes communes (sur l'arbre de propriete original : pas
#   d'alias)
# - modification et calculs sur des proprietes
#

var bourrasque_loop = func() {

    # setting engine egt celcius from egt farenheit
    setprop('/engines/engine[0]/egt', 0);
    var m0egt_degf = getprop('/engines/engine[0]/egt-degf');
    if(m0egt_degf)
    {
        var m0egt = my_aircraft_functions.DF2DC(m0egt_degf);
        setprop("/engines/engine[0]/egt", m0egt);
    }
    setprop('/engines/engine[1]/egt', 0);
    var m1egt_degf = getprop('/engines/engine[1]/egt-degf');
    if(m1egt_degf)
    {
        var m1egt = my_aircraft_functions.DF2DC(m1egt_degf);
        setprop('/engines/engine[1]/egt', m1egt);
    }

    # setting altimeter kilopascal from inch hg
    setprop('/instrumentation/altimeter/setting-kpa', (getprop('/instrumentation/altimeter/setting-inhg') * my_aircraft_functions.INHG2HPA));

    # setting sound factor if internal and canopy closed
    var is_internal = getprop('sim/current-view/internal') or 0;
    var canopy_position = getprop('sim/model/canopy-pos-norm') or 0;
    setprop('/environment/loud-sound', ((is_internal == 1) and (canopy_position == 0)) ? 0.2 : 1);

    # TODO
    # setting offsets for the view position relativ to acceleration
    #var view_number = getprop('/sim/current-view/view-number') or 0;
    #if(view_number == 0)
    #{
    #    setprop('/sim/current-view/z-offset-m',       getprop('/sim/view[0]/config/z-offset-m')       + getprop('/debug1'));
    #    setprop('/sim/current-view/pitch-offset-deg', getprop('/sim/view[0]/config/pitch-offset-deg') + getprop('/debug2'));
    #}

    settimer(bourrasque_loop, 0.1);
}

setlistener('/sim/signals/fdm-initialized', bourrasque_loop);






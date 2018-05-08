print("*** LOADING fdm - systems.nas ... ***");

# namespace : fdm

#     evenement push btn "start" et tt est ok
#               |
#               V
#     +----is_starting----+
#     |      (loop)       |
#     |         ^         |
#     |         |         V
# is_stopped    |     ! is_stopped  (<=> /engines/engine[x]/stopped)
#     ^         |         |
#     |         |         |
#     +----is_stopping----+
#            (loop)
#               ^
#               |
#     evenement interruption inputs (fuel, pump, etc)



#===============================================================================
#                                                                      CONSTANTS

var elapsed_loops = [0, 0];
#var loops_until_start = 100;
var loops_until_start = 200; # = 20s /!\ depends settimer

#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                                   systems_loop
# this function check engines stats and manage engines
var systems_loop = func()
{
    var master_switch       = getprop("/instrumentation/my_aircraft/electricals/controls/master-switch") or 0;
    var avionics_enabled    = getprop("/instrumentation/my_aircraft/electricals/controls/bus-avionics") or 0;
    var engines_enabled     = getprop("/instrumentation/my_aircraft/electricals/controls/bus-engines") or 0;
    var commands_enabled    = getprop("/instrumentation/my_aircraft/electricals/controls/bus-commands") or 0;

    var is_epu              = getprop("/sim/model/ground-equipment-p") or 0;

    var is_bus_avionics_on  = getprop("/systems/electrical/bus/avionics") or 0;
    var is_bus_engines_on   = getprop("/systems/electrical/bus/engines") or 0;
    var is_bus_commands_on  = getprop("/systems/electrical/bus/commands") or 0;

    var nb_engine_stopped = 0;

    # ~~~~~~~~~~~~~~~~~~ ENGINES MANAGEMENT

    foreach(var engine_id ; ['0', '1'])
    {
        var n1 = getprop("/engines/engine["~ engine_id ~"]/n1") or 0;

        var is_stopped  = getprop("/engines/engine["~ engine_id ~"]/stopped") or 0;
        var is_fuelon   = getprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/fuel-on") or 0;
        var is_pump     = getprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/pump") or 0;
        var is_starting = getprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_starting") or 0;
        var is_stopping = getprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_stopping") or 0;

        ### STAT CHANGES

        if((is_stopped == 1) and (is_stopping == 0) and (is_starting == 0))
        {
            # etat stoppe
            n1 = 0;
            elapsed_loops[engine_id] = 0;
        }
        elsif((is_stopped == 0) and (is_stopping == 0) and (is_starting == 0))
        {
            # etat demarre
            elapsed_loops[engine_id] = loops_until_start;
        }
        elsif((is_stopped == 0) and (is_stopping == 1) and (is_starting == 0))
        {
            # transition vers etat stoppe
            elapsed_loops[engine_id] -= 1;
            # diminuer n1 progressivement
            n1 = n1 * elapsed_loops[engine_id] / loops_until_start;
            if(elapsed_loops[engine_id] <= 0)
            {
                is_stopped = 1;
                is_stopping = 0;
            }
        }
        elsif((is_stopped == 1) and (is_stopping == 0) and (is_starting == 1))
        {
            # transition vers etat demarre
            elapsed_loops[engine_id] += 1;
            # augmenter n1 progressivement
            n1 = n1 * elapsed_loops[engine_id] / loops_until_start;
            if(elapsed_loops[engine_id] > loops_until_start)
            {
                is_stopped = 0;
                is_starting = 0;
            }
        }

        ### EVENTS

        if(((is_bus_avionics_on == 0)
                or (is_bus_engines_on == 0)
                or (is_pump == 0)
                or (is_fuelon == 0))
            and(is_stopped == 0))
        {
            # lancer l'arret si plus d'alimentation
            is_stopping = 1;
        }

        if((is_starting == 1)
            and ((is_stopped == 1) or (is_stopping == 1))
            and (is_bus_avionics_on == 1)
            and (is_bus_engines_on == 1)
            and (is_pump == 1)
            and (is_fuelon == 1))
        {
            # demande de demarrage, engine eteint et demarrable :
            is_stopping = 0;
        }
        elsif(is_starting == 1)
        {
            # demande de demarrage, engine eteint et non demarrable :
            is_starting = 0;
        }

        nb_engine_stopped += is_stopped;

        setprop("/engines/engine["~ engine_id ~"]/n1-true", n1);
        setprop("/engines/engine["~ engine_id ~"]/out-of-fuel", is_stopped);
        setprop("/engines/engine["~ engine_id ~"]/stopped", is_stopped);
        setprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_starting", is_starting);
        setprop("/instrumentation/my_aircraft/engines/controls/engine["~ engine_id ~"]/is_stopping", is_stopping);

    } # END foreach engine

    # ~~~~~~~~~~~~~~~~~~ ELECTRICAL MANAGEMENT

    if((master_switch == 0)
        or ((master_switch == 2) and (nb_engine_stopped == 2))
        or ((master_switch == 3) and (is_epu == 0)))
    {
        is_bus_avionics_on = 0;
        is_bus_engines_on  = 0;
        is_bus_commands_on = 0;
    }
    else
    {
        is_bus_avionics_on = (avionics_enabled == 1) ? 1 : 0;
        is_bus_engines_on  = (engines_enabled  == 1) ? 1 : 0;
        is_bus_commands_on = (commands_enabled == 1) ? 1 : 0;
    }
    setprop("/systems/electrical/bus/avionics", is_bus_avionics_on);
    setprop("/systems/electrical/bus/engines",  is_bus_engines_on);
    setprop("/systems/electrical/bus/commands", is_bus_commands_on);

    var time_speed = getprop("/sim/speed-up") or 1;
    var loop_speed = (time_speed == 1) ? .1 : 1 * time_speed;
    settimer(systems_loop, loop_speed);
}

setlistener("/sim/signals/fdm-initialized", systems_loop);



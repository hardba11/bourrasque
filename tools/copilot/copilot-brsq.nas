print("*** LOADING tools - copilot-brsq.nas ... ***");

# namespace : tools/copilot

#                               ~~~ README ~~~
#
#
# ORIGINAL FILE : see bourrasque : https://github.com/hardba11/bourrasque
#
#   https://www.ivao.fr/fr/pages/pilots/rules
#   https://en.wikipedia.org/wiki/Flight_level
#
# how to install for another aircraft
# -----------------------------------
#
# 1- copy this file in a directory (tools/copilot/ for example) 
#    and rename it to copilot-YOUR-AIRPLANE.nas
#
# 2- add the nasal script in your aircraft -set.xml file :
#     <nasal>
#       ... other scripts
#       <tools-copilot>
#         <file type="string">tools/copilot/copilot-YOUR-AIRPLANE.nas</file>
#       </tools-copilot>
#     </nasal>
#
# 3- add a new property in the property tree in your aircraft -set.xml file :
#     <controls>
#       ... other properties
#       <copilot type="bool">1</copilot>
#     </controls>
#
# 4- add a button or a menu gui to enable/disable copilot property
#    example (gui/dialogs/YOUR-AIRPLANE-commands.xml) :
#     <!-- ~~~~~~~~~~~~~~~~~~ copilot -->
#     <group>
#       <layout>table</layout>
#       <halign>left</halign>
#       <button>
#         <row>0</row><col>0</col>
#         <legend>copilot notifs</legend>
#         <binding>
#           <command>property-assign</command>
#           <property>/controls/copilot</property>
#           <value>1</value>
#         </binding>
#       </button>
#       <button>
#         <row>0</row><col>1</col>
#         <legend>mute</legend>
#         <binding>
#           <command>property-assign</command>
#           <property>/controls/copilot</property>
#           <value>0</value>
#         </binding>
#       </button>
#     </group>
#

#===============================================================================
#                                                                 INITIALISATION

var loop_speed = 1;
var elapsed = 0;

var westbound_fls = [60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 310, 350, 390, 430, 470, 510, 550, 590];
var eastbound_fls = [70, 90, 110, 130, 150, 170, 190, 210, 230, 250, 270, 290, 330, 370, 410, 450, 490, 520, 560, 600];

# cycle : incremente a chq cycle si les conditions de declenchement restent
#   vraies. remis a 0 si les conditions sont fausses
var events = {
    'vspeed_on_touchdown': {
        'last_values': {
            'wow': 1,
            'vspeed': 0,
        },
        'message': 'Vertical speed on touchdown : %.2f fps (good < 7)',
        'data': [0],
        'envoie_message': 0,
    },
    'transition_altitude': {
        'trigger': 0,
        'message': 'Reaching transition altitude, set ALT to 29.92 inHg, keep climbing to FL%s.',
        'data': [0],
        'envoie_message': 0,
    },
    'transition_level': {
        'trigger': 0,
        'message': 'Reaching transition level, set ALT to %.2f inHg, keep descending to %d ft.',
        'data': [0, 0],
        'envoie_message': 0,
    },
    'upper_traffic_area': {
        'trigger': 0,
        'message': 'Entering to UTA (upper traffic area).',
        'data': [],
        'envoie_message': 0,
    },
    'lower_traffic_area': {
        'trigger': 0,
        'message': 'Entering to LTA (lower traffic area).',
        'data': [],
        'envoie_message': 0,
    },
    'semicircular_fl': {
        'time': 0,
        'repeat_every_time': 47,
        'message': 'Your magnetic heading is %d, reach FL%s to applie semicircular rules.',
        'data': [0, 0],
        'envoie_message': 0,
    },
    'speed_limit': {
        'time': 0,
        'repeat_every_time': 63,
        'message': 'Your are under FL100, your speed is limited to 250 kt.',
        'data': [],
        'envoie_message': 0,
    },
    'autotrim_on': {
        'time': 0,
        'repeat_every_time': 15,
        'message': 'Your gears are down, you should autotrim (\'s\' key).',
        'data': [],
        'envoie_message': 0,
    },
    'autotrim_off': {
        'time': 0,
        'repeat_every_time': 5,
        'message': 'Your gears are up, you should disable autotrim (\'s\' key) and center (ctrl + numpad 5 key).',
        'data': [],
        'envoie_message': 0,
    },
    'takeoff_v1': {
        'trigger': 0,
        'message': 'v1 : do not abort takeoff !',
        'data': [],
        'envoie_message': 0,
    },
    'takeoff_v2': {
        'trigger': 0,
        'message': 'v2 : rotate !',
        'data': [],
        'envoie_message': 0,
    },

};

var aircraft = {
    'speed': 0,
    'heading': 0,
    'indicated_altitude': 0,
    'elevation': 0,
    'alt': 0,
    'vspd': 0,
    'is_gear_down': 0,
    'is_wow': 0,
};


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                              get_aircraft_info
# 
var get_aircraft_info = func()
{
    aircraft['speed']               = getprop("/velocities/airspeed-kt") or 0;
    aircraft['heading']             = getprop("/orientation/heading-magnetic-deg") or 0;
    aircraft['indicated_altitude']  = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;
    aircraft['elevation']           = getprop("/position/altitude-agl-ft") or 0;
    aircraft['alt']                 = getprop("/position/altitude-ft") or 0;
    aircraft['vspd']                = getprop("/autopilot/internal/vert-speed-fpm") or 0;
    aircraft['is_gear_down']        = getprop("/controls/gear/gear-down") or 0;
    aircraft['is_wow']              = getprop("/gear/gear[1]/wow") or 0;
}

#-------------------------------------------------------------------------------
#                                                     detect_vspeed_on_touchdown
# 
var detect_vspeed_on_touchdown = func()
{
    var e = 'vspeed_on_touchdown';

    # vspeed au toucher des roues
    if(
        (aircraft['is_wow'] == 1)
        and
        (events[e]['last_values']['wow'] == 0)
    ) {
        events[e]['data'][0] = events[e]['last_values']['vspeed'];
        events[e]['envoie_message'] = 1;
    }

    var vspeed = getprop("/velocities/down-relground-fps") or 0;
    events[e]['last_values']['wow'] = aircraft['is_wow'];
    events[e]['last_values']['vspeed'] = vspeed;
}

#-------------------------------------------------------------------------------
#                                                     detect_transition_altitude
# 
var detect_transition_altitude = func()
{
    var e = 'transition_altitude';

    # bascule altitude qnh / std (transition altitude - transition level)
    # En France, la TA est generalement de 5000 ft ou 3000ft AGL
    # TLYR pas de vol en palier calage standard en montee et calage au QNH local en descente
    # TL : C'est le premier niveau de vol IFR situe à 1000 ft au moins au-dessus de l'altitude de transition

    # reinit si on repasse en dessous de l'altitude de transition
    if(
        (
            (aircraft['elevation'] < 3000)
            or
            (aircraft['alt'] < 5000)
        )
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # si on passe l'altitude de transition, annonce du message
    if(
        (
            (aircraft['elevation'] >= 3000)
            and
            (aircraft['alt'] >= 5000)
        )
        and
        (events[e]['trigger'] == 1)
    ) {
        events[e]['data'][0] = int(aircraft['alt'] / 100) + 10;
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                        detect_transition_level
# 
var detect_transition_level = func()
{
    var e = 'transition_level';

    # bascule altitude std / qnh (transition level - transition altitude)
    # En France, la TA est generalement de 5000 ft ou 3000ft AGL
    # TLYR pas de vol en palier calage standard en montee et calage au QNH local en descente
    # TL : C'est le premier niveau de vol IFR situe à 1000 ft au moins au-dessus de l'altitude de transition

    # reinit si on repasse au dessus du niveau de transition
    if(
        (
            (aircraft['elevation'] > 4000)
            or
            (aircraft['alt'] > 6000)
        )
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # si on passe le niveau de transition, annonce du message
    if(
        (
            (aircraft['elevation'] <= 4000)
            and
            (aircraft['alt'] <= 6000)
        )
        and
        (events[e]['trigger'] == 1)
    )
    {
        var qnh = getprop("/environment/pressure-sea-level-inhg") or 0;
        events[e]['data'][0] = qnh;
        events[e]['data'][1] = int(aircraft['alt'] / 1000) * 1000;
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                      detect_upper_traffic_area
# 
var detect_upper_traffic_area = func()
{
    var e = 'upper_traffic_area';

    # bascule en zone controlee
    # Region superieure de contrôle (UTA, Upper Traffic Area) situee entre le FL195 et le FL660

    var fl = int(aircraft['indicated_altitude'] / 100);

    # reinit si on sort de la zone UTA
    if(
        (
            (fl < 195)
            or
            (fl > 660)
        )
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # si on passe dans la zone UTA, annonce du message
    if(
        (
            (fl >= 195)
            and
            (fl <= 660)
        )
        and
        (events[e]['trigger'] == 1)
    ) {
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                      detect_lower_traffic_area
# 
var detect_lower_traffic_area = func()
{
    var e = 'lower_traffic_area';

    # bascule en zone controlee
    # Regions inferieures de contrôle (LTA, Low Traffic Areas) situees entre le plus eleve des deux niveaux suivants FL115 ou 3000 ft ASFC et le FL195

    var fl = int(aircraft['indicated_altitude'] / 100);

    # reinit si on sort de la zone UTA
    if(
        (
            (fl < 115)
            or
            (fl > 195)
        )
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # si on passe dans la zone LTA, annonce du message
    if(
        (
            (fl >= 115)
            and
            (fl <= 195)
        )
        and
        (events[e]['trigger'] == 1)
    ) {
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                              detect_takeoff_v1
# 
var detect_takeoff_v1 = func()
{
    var e = 'takeoff_v1';

    # reinit
    if(
        (aircraft['speed'] < 100)
        and
        (aircraft['is_wow'])
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # declenchement si on passe 100kt au decollage
    if(
        (aircraft['speed'] > 100)
        and
        (aircraft['is_wow'])
        and
        (events[e]['trigger'] == 1)
    ) {
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                              detect_takeoff_v2
# 
var detect_takeoff_v2 = func()
{
    var e = 'takeoff_v2';

    # reinit
    if(
        (aircraft['speed'] < 140)
        and
        (aircraft['is_wow'])
        and
        (events[e]['trigger'] == 0)
    ) {
        events[e]['trigger'] = 1;
    }

    # declenchement si on passe 140kt au decollage
    if(
        (aircraft['speed'] > 140)
        and
        (aircraft['is_wow'])
        and
        (events[e]['trigger'] == 1)
    ) {
        events[e]['envoie_message'] = 1;
        events[e]['trigger'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                         detect_semicircular_fl
# 
var detect_semicircular_fl = func()
{
    var e = 'semicircular_fl';

    # FL / cap
    # etagement FL / FL - route magnetique
    # est : niveau de vol IMPAIR (FL250, FL270 < FL290 ; FL290, FL330...)
    # ouest : niveau de vol PAIR (FL260, FL280 < FL290 ; FL310, FL350...)
    if(
        (aircraft['indicated_altitude'] >= 6000)
        and
        (math.abs(aircraft['vspd']) < 500)
        and
        (aircraft['elevation'] >= 3000)
    ) {
        var semicircular_status = get_semicircular_status(aircraft['heading'], aircraft['indicated_altitude']);

        if(semicircular_status['is_in'] == 0)
        {
            events[e]['data'][0] = aircraft['heading'];
            events[e]['data'][1] = semicircular_status['nearest_fl'];

            # gestion de la repetition du message
            if(events[e]['time'] >= events[e]['repeat_every_time'])
            {
                events[e]['time'] = 0;
            }

            # annonce du message
            if(events[e]['time'] == 0)
            {
                events[e]['envoie_message'] = 1;
            }
            events[e]['time'] += 1;
        }
        else
        {
            events[e]['time'] = 0;
        }
    }
    else
    {
        events[e]['time'] = 0;
    }
}

var get_semicircular_status = func(hdg, alt)
{
    var fl_in_ft = 0;
    var semicircular_status = {'is_in': 0, 'nearest_fl': 0,};
    var ecart_min = 10000000;

    var fls = westbound_fls;
    if(
        (
            (hdg >= 0)
            or
            (hdg >= 360)
        )
        and
        (hdg < 180)
    ) {
        fls = eastbound_fls;
    }

    foreach(var fl ; fls) {
        fl_in_ft = (fl * 100);

        if(
            (alt > (fl_in_ft - 200))
            and
            (alt < (fl_in_ft + 200))
        ) {
            semicircular_status['is_in'] = 1;
        }
        ecart = math.abs(alt - fl_in_ft);
        if(ecart_min > ecart)
        {
            ecart_min = ecart;
            semicircular_status['nearest_fl'] = fl;
        }
    }
    return semicircular_status;
}


#-------------------------------------------------------------------------------
#                                                             detect_speed_limit
# 
var detect_speed_limit = func()
{
    var e = 'speed_limit';

    # vitesse / FL
    # dans tous les espaces aeriens, independamment de leur classe, la limitation de vitesse est de 250 kt sous le FL100.
    if(
        (aircraft['speed'] > 250)
        and
        (aircraft['indicated_altitude'] < 10000)
    )
    {
        # gestion de la repetition du message
        if(events[e]['time'] >= events[e]['repeat_every_time'])
        {
            events[e]['time'] = 0;
        }

        # annonce du message
        if(events[e]['time'] == 0)
        {
            events[e]['envoie_message'] = 1;
        }
        events[e]['time'] += 1;
    }
    else
    {
        events[e]['time'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                             detect_autotrim_on
# 
var detect_autotrim_on = func()
{
    var e = 'autotrim_on';

    # activer autotrim
    # si trains sortis, pas au sol, pas autotrim et pas autopilot

    var autotrim = getprop("/controls/flight/autotrim-pitch") or 0;
    var autopilot_alt = getprop("/instrumentation/my_aircraft/pfd/inputs/autopilot/locks/altitude") or '-';
    if(
        (aircraft['is_gear_down'])
        and
        (!aircraft['is_wow'])
        and
        (!autotrim)
        and
        (autopilot_alt == '-')
        and
        (aircraft['elevation'] >= 400)
    )
    {
        # gestion de la repetition du message
        if(events[e]['time'] >= events[e]['repeat_every_time'])
        {
            events[e]['time'] = 0;
        }

        # annonce du message
        if(events[e]['time'] == 0)
        {
            events[e]['envoie_message'] = 1;
        }
        events[e]['time'] += 1;
    }
    else
    {
        events[e]['time'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                            detect_autotrim_off
# 
var detect_autotrim_off = func()
{
    var e = 'autotrim_off';

    # raz autotrim
    # si trains rentres

    var autotrim = getprop("/controls/flight/autotrim-pitch") or 0;
    if(
        (!aircraft['is_gear_down'])
        and
        (autotrim)
    )
    {
        # gestion de la repetition du message
        if(events[e]['time'] >= events[e]['repeat_every_time'])
        {
            events[e]['time'] = 0;
        }

        # annonce du message
        if(events[e]['time'] == 0)
        {
            events[e]['envoie_message'] = 1;
        }
        events[e]['time'] += 1;
    }
    else
    {
        events[e]['time'] = 0;
    }
}

#-------------------------------------------------------------------------------
#                                                                  detect_events
# fonction de detection
# 
var detect_events = func()
{

    get_aircraft_info();

    detect_vspeed_on_touchdown();
    detect_transition_altitude();
    detect_transition_level();
    detect_upper_traffic_area();
    detect_lower_traffic_area();
    detect_semicircular_fl();
    detect_speed_limit();
    detect_autotrim_on();
    detect_autotrim_off();
    detect_takeoff_v1();
    detect_takeoff_v2();

    #print('==========================================================================');
    #debug.dump(aircraft);
    #print('--------------------------------------------------------------------------');
    #debug.dump(events['transition_altitude']);
    #print('--------------------------------------------------------------------------');
    #debug.dump(events['transition_level']);
    #print('--------------------------------------------------------------------------');
    #debug.dump(events['upper_traffic_area']);
    #print('--------------------------------------------------------------------------');
    #debug.dump(events['lower_traffic_area']);
    #print('--------------------------------------------------------------------------');
    #debug.dump(events['semicircular_fl']);

}
#-------------------------------------------------------------------------------
#                                                                   set_messages
# fonction de gestion des messages
# 
var set_messages = func()
{
    var message = '';
    foreach(var event ; keys(events)) {
        if(events[event]['envoie_message'] == 1) {
            if(size(events[event]['data']) == 0) {
                message = events[event]['message'];
            } elsif(size(events[event]['data']) == 1) {
                message = sprintf(events[event]['message'], events[event]['data'][0]);
            } elsif(size(events[event]['data']) == 2) {
                message = sprintf(events[event]['message'], events[event]['data'][0], events[event]['data'][1]);
            }
            setprop("/sim/messages/copilot", '[copilot] '~ message);
            debug.dump('[copilot] '~ message);
            events[event]['envoie_message'] = 0;
        }
    }
}

#-------------------------------------------------------------------------------
#                                                                        copilot
# 
var copilot = func() {

    var is_enabled = getprop("/controls/copilot") or 0;
    if(is_enabled != 1) {
        return;
    }

    detect_events();
    set_messages();
}

#-------------------------------------------------------------------------------
#                                                                   copilot_loop
# 
var copilot_loop = func()
{
    if(go == 1) {
        copilot();
    }
    settimer(copilot_loop, loop_speed);
}

var go = 0;

# message de presentation
elapsed = elapsed + 12;
settimer(func() {
    var is_enabled = getprop("/controls/copilot") or 0;
    if(is_enabled == 1) {
        setprop("/sim/messages/copilot", '[copilot] Hello, I will help you and give you some feedbacks ! To disable me : menu brsq - Option');
    } else {
        setprop("/sim/messages/copilot", '[copilot] Hello, I am disabled. To enable me : menu brsq - Option');
    }
    go = 1;
}, elapsed);

# message de demarrage si cold and dark
var is_cold_and_dark = getprop('/sim/presets/onground') or 0;
if(is_cold_and_dark) {
    elapsed = elapsed + 4;
    settimer(func() {
        setprop("/sim/messages/copilot", 'To autostart : menu brsq - autostart or faststart');
    }, elapsed);
}

setlistener("/sim/signals/fdm-initialized", copilot_loop);












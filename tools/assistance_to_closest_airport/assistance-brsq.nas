print("*** LOADING tools - assistance-brsq.nas ... ***");

# namespace : tools/assistance

#                               ~~~ README ~~~
#
#
# ORIGINAL FILE : see bourrasque : https://github.com/hardba11/bourrasque
#
# more infos here : https://forum.flightgear.org/viewtopic.php?f=18&t=34137
#
#
# le repere suivant est defini
# l'aeroport a sa piste la plus longue alignee vers le nord et ses coordonnes sont 0, 0
# les coordonnees de l avion ont ete transposees dans le nouveau repere
# on recherche alors dans quelle zone l avion se trouve
# les ordre ATC adequats peuvent etre donnes
#
#                                         N
#  .1  .-------------------------------------------------+-------------------------------.
#      |                                                 |                               |
#      |  zone2_1 ------>                                | zone3    |                    |
#      |  CROSSWIND                                      | DOWNWIND |                    |
#      |  250kt                          |||             | 250kt    |                    |
#      |  2500ft                         |.|             | 1500ft   V                    |
#      |                                 |.|             |                               |
#      |                                 |.|             |                               |
#      |                                 |.|             |                               |
#      |                                 |||             |                               |
#  0  W+--------------------------------+-0-+------------+                               |E
#      |                                |   |            |                               |
#      |  zone1      ^                  | ^ | zone2_2    |                               |
#      |  ENTRANCE   |                  | | | CROSSWIND  |                               |
#      |  250kt      |                  | | | 200kt      |                               |
#      |  2500ft     |                  | | | 1500ft     |                               |
#      |                                |   | ---->      |                               |
#      |                                |z6 |            |                               |
# -.1  |                                | F +------------+                               |
#      |                                | I |            |                               |
#      |                                | N | zone4      |                               |
#      |                                | A | BASE       |                               |
#      |                                | L | 200kt      |                               |
# -.15 |                                |   | 1500ft     +-------------------------------+
#      |                                |   | __         |                               |
#      |                                |   | |\         | zone5  <-----                 |
#      |                                |   |   \        | BASE                          |
#      |                                |   |    \       | 200kt 1500ft                  |
# -.2  '--------------------------------+---+------------+-------------------------------'
#                                         S
#     -.2                          -.015  0 .015       .05                              .2
#
# how to install for another aircraft
# -----------------------------------
#
# 1- copy this file in a directory (tools/assistance_to_closest_airport/ for example) 
#    and rename it to assistance-YOUR-AIRPLANE.nas
#
# 2- add the nasal script in your aircraft -set.xml file :
#     <nasal>
#       ... other scripts
#       <tools-assistance>
#         <file type="string">tools/assistance_to_closest_airport/assistance-YOUR-AIRPLANE.nas</file>
#       </tools-assistance>
#     </nasal>
#
# 3- add a new property in the property tree in your aircraft -set.xml file :
#     <controls>
#       ... other properties
#       <assistance type="bool">0</assistance>
#     </controls>
#
# 4- add a button or a menu gui to enable/disable assistance property
#    example (gui/dialogs/YOUR-AIRPLANE-commands.xml) :
#     <!-- ~~~~~~~~~~~~~~~~~~ assistance -->
#     <group>
#       <layout>table</layout>
#       <halign>left</halign>
#       <button>
#         <row>0</row><col>0</col>
#         <legend>need assistance</legend>
#         <binding>
#           <command>property-assign</command>
#           <property>/controls/assistance</property>
#           <value>1</value>
#         </binding>
#       </button>
#       <button>
#         <row>0</row><col>1</col>
#         <legend>it is ok</legend>
#         <binding>
#           <command>property-assign</command>
#           <property>/controls/assistance</property>
#           <value>0</value>
#         </binding>
#       </button>
#     </group>
#
# 5- tune atc_zone array : speed
#

#===============================================================================
#                                                                 INITIALISATION

var loop_speed = 2;
var nb_cycle = 0;
var welcome = 0;
var hasta_la_vista = 0;
var previous_assistance_message = '';

var coord_airport = geo.Coord.new();
var airport = {
    'id':            '',
    'name':          '',
    'elevation_ft':  0,
    'rwy':           '',
    'rwy_length':    0,
    'heading':       0,
    'lng':           0,
    'lat':           0,
};

var coord_aircraft = geo.aircraft_position();
var aircraft = {
    'callsign':     '',
    'heading':      0,
    'altitude':     0,
    'speed':        0,
    'is_gear_down': 0,
    'is_wow':       0,
};

var atc = {
    'heading': 0,
    'speed':   0,
    'alt':     0,
    'circuit': '',
};

var atc_zone = [
    {
        'id': 'zone1',
        'top_left_x': -.2,
        'top_left_y': 0,
        'bottom_right_x': -.015,
        'bottom_right_y': -.2,
        'speed': 250,
        'heading': 0,
        'alt': 2500,
        'circuit': 'entrance',
    },
    {
        'id': 'zone2_1',
        'top_left_x': -.2,
        'top_left_y': .1,
        'bottom_right_x': .05,
        'bottom_right_y': 0,
        'speed': 250,
        'heading': 90,
        'alt': 2500,
        'circuit': 'crosswind',
    },
    {
        'id': 'zone2_2',
        'top_left_x': .015,
        'top_left_y': 0,
        'bottom_right_x': .05,
        'bottom_right_y': -.1,
        'speed': 200,
        'heading': 90,
        'alt': 1500,
        'circuit': 'crosswind',
    },
    {
        'id': 'zone3',
        'top_left_x': .05,
        'top_left_y': .1,
        'bottom_right_x': .2,
        'bottom_right_y': -.15,
        'speed': 250,
        'heading': 180,
        'alt': 1500,
        'circuit': 'downwind',
    },
    {
        'id': 'zone4',
        'top_left_x': .015,
        'top_left_y': -.1,
        'bottom_right_x': .05,
        'bottom_right_y': -.2,
        'speed': 200,
        'heading': 315,
        'alt': 1500,
        'circuit': 'base',
    },
    {
        'id': 'zone5',
        'top_left_x': .05,
        'top_left_y': -.15,
        'bottom_right_x': .2,
        'bottom_right_y': -.2,
        'speed': 200,
        'heading': 270,
        'alt': 1500,
        'circuit': 'base',
    },
    {
        'id': 'zone6',
        'top_left_x': -.015,
        'top_left_y': 0,
        'bottom_right_x': .015,
        'bottom_right_y': -.2,
        'speed': 150,
        'heading': 0,
        'alt': 1500,
        'circuit': 'final',
    },
];
var zone_outside = {
    'id': 'OUTSIDE',
    'speed': 300,
    'heading': 0,
    'alt': 5000,
    'circuit': 'outside',
};
var zone_landing = {
    'id': 'LANDING',
    'speed': 150,
    'heading': 0,
    'alt': 0,
    'circuit': 'landing',
};

var h = 0;
var d = 0;

var assistance_message            = '';
var assistance_message_header     = '';
var assistance_message_horizontal = '';
var assistance_message_vertical   = '';
var assistance_message_vitesse    = '';
var assistance_message_bonus      = '';


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                             turn_left_or_right
# 
var turn_left_or_right = func(cur_heading, wanted_heading)
{
    return((math.mod(cur_heading - wanted_heading, 360) < 180)
        ? 'LEFT'
        : 'RIGHT');
}

#-------------------------------------------------------------------------------
#                                                              get_aircraft_info
# 
var get_aircraft_info = func()
{
    aircraft['callsign']     = getprop("/sim/multiplay/callsign") or 'callsig';
    aircraft['heading']      = getprop("/orientation/heading-deg") or 0; # true north
    aircraft['altitude']     = getprop("/position/altitude-ft") or 0;
    aircraft['speed']        = getprop("/velocities/airspeed-kt") or 0;
    aircraft['is_gear_down'] = getprop("/controls/gear/gear-down") or 0;
    aircraft['is_wow']       = getprop("/gear/gear[0]/wow") or 0;
}

#-------------------------------------------------------------------------------
#                                                               get_airport_info
# 
var get_airport_info = func()
{

    # get some info on airport
    airport['id'] = getprop("/sim/airport/closest-airport-id") or '';
    var arpt = airportinfo(airport['id']);
    airport['name']         = arpt.name;
    airport['elevation_ft'] = (3.28 * arpt.elevation);

    # get longest runway
    var longest_rwy_id = '';
    var longest_rwy    = 0;
    var runways = arpt.runways;
    var rwy_keys = sort(keys(runways), string.icmp);
    foreach (var rwy_id ; rwy_keys) {
        var r = runways[rwy_id];
        if (r.length > longest_rwy) {
            longest_rwy    = r.length;
            longest_rwy_id = rwy_id;
        }
    }
    my_runway = runways[longest_rwy_id];
    airport['rwy']        = longest_rwy_id;
    airport['heading']    = my_runway.heading; # true north
    airport['lng']        = my_runway.lon;
    airport['lat']        = my_runway.lat;
    airport['rwy_length'] = my_runway.length * 3.28;
}

#-------------------------------------------------------------------------------
#                                                 find_in_which_zone_is_aircraft
# l idee est de faire une rotation puis translation de l ensemble
# l aeroport etant au centre de la zone qui a pour coord gps 0,0
# on doit donc aussi rotationner et translater les coords de l avion
# on recupere l angle + distance actuels de l avion par rapport a
# l aeroport
var find_in_which_zone_is_aircraft = func(lat, lng, heading, aircraft_bearing, aircraft_dist_nm, aircraft_elevation)
{
    var coord = geo.Coord.new();
    coord.set_latlon(lat, lng);

    # on rotationne les coordonnees de l avion
    var rotated_aircraft_position = coord.apply_course_distance((aircraft_bearing - heading), (aircraft_dist_nm * NM2M));

    # et on translate les coordonnees de l avion
    var translated_aircraft_lat = rotated_aircraft_position.lat() - lat;
    var translated_aircraft_lng = rotated_aircraft_position.lon() - lng;

    # a ce moment on a un aeroport avec la piste la plus longue alignee
    # vers le nord, les coordonnes de l aeroport sont 0, 0
    # les coordonnees de l avion ont ete transposees dans le nouveau repere
    # on recherche alors dans quelle zone l avion se trouve
    foreach (var zone ; atc_zone) {
        if ((translated_aircraft_lng > zone['top_left_x'])
            and (translated_aircraft_lng < zone['bottom_right_x'])
            and (translated_aircraft_lat > zone['bottom_right_y'])
            and (translated_aircraft_lat < zone['top_left_y'])
        ) {
            # la zone 2_1 ne va pas jusqu'au sol
            if ((zone['id'] == 'zone2_1') and (aircraft_elevation < 200)) {
                return zone_landing;
            }
            return zone;
        }
    }

    # if not found, return default zone
    return zone_outside;
}

#-------------------------------------------------------------------------------
#                                                                     assistance
# 
var assistance = func()
{

    var is_enabled = getprop("/controls/assistance") or 0;
    if (is_enabled != 1) {
        # assistance disabled
        if (hasta_la_vista == 1) {
            # deja ete enabled, les variables airport et aircraft ont deja ete initialisees ;)
            assistance_message_header = sprintf('atc %s, %s.', airport['id'], aircraft['callsign']);
            assistance_message = sprintf('%s %s',
                assistance_message_header,
                "It's OK, Have a good day ! Over."
            );

            setprop("/sim/messages/atc", assistance_message);
            hasta_la_vista = 0;
        }
        nb_cycle = 0;
        airport['id'] = '';
        return;
    }


    # get some info on aircraft
    get_aircraft_info();

    # on recupere l aeroport le plus proche si il n a pas deja ete choisi
    # on fait ca pour eviter la bascule vers un nouvel aeroport plus proche
    # lorsqu'on navigue dans le circuit
    if (airport['id'] == '') {
        # get some info on airport
        get_airport_info();
        welcome = 1;

        #printf("DEBUG : AIRPORT %s - %s - %s - %s - %d - RUNWAY %s - %d - %d", airport['id'], airport['name'], airport['lng'], airport['lat'], airport['elevation_ft'], airport['rwy'], airport['rwy_length'], airport['heading']);
        #DEBUG : AIRPORT LFRQ - Quimper Pluguffan - -4.1722096 - 47.972947 - 296 - RUNWAY 10 - 7052 - 93
    }

    assistance_message_header = sprintf('atc %s, %s.', airport['id'], aircraft['callsign']);

    # end of assistance if landed
    if (aircraft['is_wow']) {
        is_enabled = 0;
        hasta_la_vista = 0;
        welcome = 0;
        setprop("/controls/assistance", is_enabled);

        assistance_message = sprintf('%s %s',
            assistance_message_header,
            "You landed, congratulations, have a good day ! Over."
        );
        setprop("/sim/messages/atc", assistance_message);

        return;
    }

    # on recupere les coordonnees de l aeroport et de l avion
    coord_airport.set_latlon(airport['lat'], airport['lng']);
    coord_aircraft = geo.aircraft_position();

    var (aircraft_bearing_from_airport, dist_nm) = courseAndDistance(coord_airport, coord_aircraft);
    var airport_bearing_from_aircraft = math.mod((aircraft_bearing_from_airport + 180), 360);
    var zone = find_in_which_zone_is_aircraft(
        airport['lat'],
        airport['lng'],
        airport['heading'],
        aircraft_bearing_from_airport,
        dist_nm,
        aircraft['altitude'] - airport['elevation_ft']
    );

    atc['heading'] = math.mod(airport['heading'] + zone['heading'], 360);
    atc['speed']   = zone['speed'];
    atc['alt']     = (sprintf('%d', zone['alt'] / 100) + sprintf('%d', airport['elevation_ft'] / 100)) * 100;
    atc['circuit'] = zone['circuit'];


# GESTION DES MESSAGES POUR LA PARTIE HORIZONTALE
    # on gere differemment selon si l avion est dans ou hors zone
    if (atc['circuit'] != 'outside') {
        # avion en finale
        # zone final leg :
        if (atc['circuit'] == 'final') {
            # message de correction d alignement avec la piste
            # alignment with runway
            var correction = math.mod((airport_bearing_from_aircraft + (airport_bearing_from_aircraft - airport['heading']) * 2), 360);

            if (sprintf('%d', aircraft['heading']) != sprintf('%d', correction)) {
                assistance_message_horizontal = sprintf('%s leg, align to runway %s, TURN %s heading %03d.',
                    atc['circuit'],
                    airport['rwy'],
                    turn_left_or_right(aircraft['heading'], correction),
                    correction);
            #} else {
            #    assistance_message_horizontal = sprintf('%s leg, align to runway %s, maintain heading %03d.',
            #        atc['circuit'],
            #        airport['rwy'],
            #        correction);
            }
        } elsif (atc['circuit'] == 'landing') {
            assistance_message_horizontal = sprintf('landing.');
        } elsif (math.cos((aircraft['heading'] - atc['heading']) * D2R) > math.cos(5 * D2R)) {
            # autres zones, l avion est au cap correct dans le circuit
            # other zones - maintain
            assistance_message_horizontal = sprintf('%s leg, maintain heading %03d.',
                atc['circuit'],
                atc['heading']);
        } else {
            # autres zones
            # other zones - turn
            assistance_message_horizontal = sprintf('%s leg, TURN %s heading %03d.',
                atc['circuit'],
                turn_left_or_right(aircraft['heading'], atc['heading']),
                atc['heading']);
        }
    } else {
        # avion hors zone, on va donner a l avion le cap direct vers l aeroport

        # on ne fait varier le message que chaque 10 cycles
        if (h == 0) h = airport_bearing_from_aircraft;
        if (d == 0) d = dist_nm;
        if (nb_cycle == 9) {
            h = airport_bearing_from_aircraft;
            d = dist_nm;
        }

        if (math.cos((aircraft['heading'] - airport_bearing_from_aircraft) * D2R) > math.cos(5 * D2R)) {
            assistance_message_horizontal = sprintf('maintain heading %03d - airport at %d NM.',
                h,
                d);
        } else {
            assistance_message_horizontal = sprintf('TURN %s heading %03d - airport at %d NM.',
                turn_left_or_right(aircraft['heading'], airport_bearing_from_aircraft),
                h,
                d);
        }
    }

# GESTION DES MESSAGES POUR LA PARTIE VERTICALE
    # avion en finale
    if ((atc['circuit'] == 'final') and (dist_nm > 5.5)) {

        if (aircraft['altitude'] > (atc['alt'] + 100)) {
            assistance_message_vertical = sprintf('DESCEND to %d ft (%.2f inHg).',
                atc['alt'],
                getprop("/environment/pressure-sea-level-inhg"));
        } elsif (aircraft['altitude'] < (atc['alt'] - 100)) {
            assistance_message_vertical = sprintf('CLIMB to %d ft (%.2f inHg).',
                atc['alt'],
                getprop("/environment/pressure-sea-level-inhg"));
        } else {
            assistance_message_vertical = sprintf('maintain %d ft.',
                atc['alt']);
        }
    } elsif ((atc['circuit'] == 'final') and (dist_nm <= 5.5) and (dist_nm >= 5.4)) {
        assistance_message_vertical = sprintf('5.5 NM from runway, START 3deg descent glide. airport altitude:%d ft.',
            airport['elevation_ft']
        );
    } elsif ((atc['circuit'] == 'final') and (dist_nm <= 3.5) and (dist_nm >= 3.4)) {
        assistance_message_vertical = sprintf('3.5 NM from runway, altitude should be %d ft.',
            (970 + airport['elevation_ft']));
    } elsif ((atc['circuit'] == 'final') and (dist_nm <= 2.5) and (dist_nm >= 2.4)) {
        assistance_message_vertical = sprintf('2.5 NM from runway, altitude should be %d ft.',
            (690 + airport['elevation_ft']));
    } elsif ((atc['circuit'] == 'final') and (dist_nm <= 1.5) and (dist_nm >= 1.4)) {
        assistance_message_vertical = sprintf('1.5 NM from runway, altitude should be %d ft.',
            (415 + airport['elevation_ft']));
    } elsif (atc['circuit'] == 'final') {
        assistance_message_vertical = sprintf('keep 3deg descent glide.');
    } elsif (atc['circuit'] == 'landing') {
        assistance_message_vertical = '';
    } elsif (atc['circuit'] == 'outside') {
        assistance_message_vertical = '';
    } elsif (aircraft['altitude'] > (atc['alt'] + 100)) {
        assistance_message_vertical = sprintf('DESCEND to %d ft (%.2f inHg).',
            atc['alt'],
            getprop("/environment/pressure-sea-level-inhg"));
    } elsif (aircraft['altitude'] < (atc['alt'] - 100)) {
        assistance_message_vertical = sprintf('CLIMB to %d ft (%.2f inHg).',
            atc['alt'],
            getprop("/environment/pressure-sea-level-inhg"));
    } else {
        assistance_message_vertical = sprintf('maintain %d ft.',
            atc['alt']);
    }

# GESTION DES MESSAGES POUR LA PARTIE VITESSE
    if (atc['circuit'] == 'landing') {
        assistance_message_vitesse = '';
    } elsif (aircraft['speed'] > (atc['speed'] + 20)) {
        assistance_message_vitesse = sprintf('LOWER speed to %d kt.',
            atc['speed']);
    } elsif (aircraft['speed'] < (atc['speed'] - 20)) {
        assistance_message_vitesse = sprintf('RAISE speed to %d kt.',
            atc['speed']);
    } else {
        assistance_message_vitesse = sprintf('maintain speed %d kt.',
            atc['speed']);
    }

    if (
        (
            (atc['circuit'] == 'downwind')
            or
            (atc['circuit'] == 'base')
            or (atc['circuit'] == 'final')
        )
        and
        (aircraft['is_gear_down'] != 1)
    ) {
        assistance_message_bonus = 'CHECK gears down.';
    }

# AFFICHAGE DES MESSAGES
    nb_cycle += 1;
    #print("nb_cycle="~ nb_cycle ~" - welcome="~welcome);

    if (welcome == 1) {
        hasta_la_vista = 1;
        if (nb_cycle == 1) {
            assistance_message = sprintf(
                "%s, %s AIRPORT. You asked for assistance...",
                aircraft['callsign'],
                airport['name']
            );
            #print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);
        } elsif (nb_cycle == 3) {
            assistance_message = sprintf(
                "follow my instructions to REACH %s and to land on RUNWAY %s",
                airport['id'],
                airport['rwy']);
            #print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);
        } elsif (nb_cycle == 5) {
            assistance_message = sprintf("HEADING : set true north");
            #print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);
        } elsif (nb_cycle == 7) {
            welcome = 0;
            nb_cycle = 0;
        }
        return;
    }

    assistance_message = sprintf('%s %s %s %s %s',
        assistance_message_header,
        assistance_message_horizontal,
        assistance_message_vertical,
        assistance_message_vitesse,
        assistance_message_bonus);

    # on affiche le message que si il y a un changement mais on rappelle le message tous les 10 cycles
    if ((assistance_message != previous_assistance_message)
        or (nb_cycle > 10)
    ) {
        #print(assistance_message);
        setprop("/sim/messages/atc", assistance_message);
        nb_cycle = 0;
    }

    previous_assistance_message = assistance_message;
}

#-------------------------------------------------------------------------------
#                                                                assistance_loop
# 
var assistance_loop = func()
{
    assistance();
    settimer(assistance_loop, loop_speed);
}

setlistener("/sim/signals/fdm-initialized", assistance_loop);












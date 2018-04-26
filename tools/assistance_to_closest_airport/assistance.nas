print("*** LOADING tools - assistance.nas ... ***");

# namespace : tools

#                               ~~~ README ~~~
#
# more infos here : https://forum.flightgear.org/viewtopic.php?f=18&t=34137
#
# how to install
# --------------
#
# 1- copy this file in a directory (tools/assistance_to_closest_airport for example)
#
# 2- add the nasal script in your aircraft -set.xml file :
#     <nasal>
#       ... other scripts
#       <tools>
#         <file type="string">tools/assistance_to_closest_airport/assistance.nas</file>
#       </tools>
#     </nasal>
#
# 3- add a new property in the property tree in your aircraft -set.xml file :
#     <controls>
#       ... other properties
#       <assistance type="bool">0</assistance>
#     </controls>
#
# 4- add a button or a menu gui to enable/disable assistance property
#    example (gui/dialogs/bourrasque-commands.xml) :
#     <!-- ~~~~~~~~~~~~~~~~~~ assistance -->
#     <group>
#       <layout>table</layout>
#       <halign>left</halign>
#       <button>
#         <row>0</row><col>0</col>
#         <legend>need assistance</legend>
#         <binding>
#           <command>property-assign</command>
#            <property>/controls/assistance</property>
#           <value>1</value>
#         </binding>
#        </button>
#        <button>
#          <row>0</row><col>1</col>
#          <legend>it is ok</legend>
#          <binding>
#            <command>property-assign</command>
#            <property>/controls/assistance</property>
#            <value>0</value>
#          </binding>
#        </button>
#     </group>
#

var assistance_zone = [
    {
        'id': 'zone1',
        'top_left_x': -.2,
        'top_left_y': 0,
        'bottom_right_x': -.015,
        'bottom_right_y': -.2,
        'speed': 200,
        'heading': 0,
        'alt': 2500,
        'circuit': 'entrance',
    },
    {
        'id': 'zone2_1',
        'top_left_x': -.2,
        'top_left_y': .2,
        'bottom_right_x': .1,
        'bottom_right_y': 0,
        'speed': 200,
        'heading': 90,
        'alt': 2500,
        'circuit': 'crosswind',
    },
    {
        'id': 'zone2_2',
        'top_left_x': .015,
        'top_left_y': 0,
        'bottom_right_x': .1,
        'bottom_right_y': -.1,
        'speed': 150,
        'heading': 90,
        'alt': 1500,
        'circuit': 'crosswind',
    },
    {
        'id': 'zone3',
        'top_left_x': .1,
        'top_left_y': .2,
        'bottom_right_x': .2,
        'bottom_right_y': -.15,
        'speed': 150,
        'heading': 180,
        'alt': 1500,
        'circuit': 'downwind',
    },
    {
        'id': 'zone4',
        'top_left_x': .015,
        'top_left_y': -.1,
        'bottom_right_x': .1,
        'bottom_right_y': -.2,
        'speed': 150,
        'heading': 315,
        'alt': 1500,
        'circuit': 'base',
    },
    {
        'id': 'zone5',
        'top_left_x': .1,
        'top_left_y': -.15,
        'bottom_right_x': .2,
        'bottom_right_y': -.2,
        'speed': 150,
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

var airport_id  = '';
var nb_cycle = 1;
var previous_assistance_message = '';

var assistance_loop = func() {

    var is_enabled = getprop("/controls/assistance") or 0;

    # end of assistance if landed
    var is_wow = getprop("/gear/gear[0]/wow") or 0;
    if(is_wow and (is_enabled == 1))
    {
        is_enabled = 0;
        setprop("/controls/assistance", 0);
        assistance_message = sprintf("You landed, congratulations, have a good day ! Over.");
        print(assistance_message);
        setprop("/sim/messages/atc", assistance_message);
    }

    if(is_enabled == 1)
    {
        # get some info on aircraft
        var callsign     = getprop("/sim/multiplay/callsign") or 'callsig';
        var heading      = getprop("/orientation/heading-magnetic-deg") or 0;
        var altitude     = getprop("/position/altitude-ft") or 0;
        var speed        = getprop("/velocities/airspeed-kt") or 0;
        var is_gear_down = getprop("/controls/gear/gear-down") or 0;

        var qnh = getprop("/environment/pressure-sea-level-inhg") or 0;

        if(airport_id == '')
        {
            # on recupere l aeroport le plus proche si il n a pas deja ete choisi
            # on fait ca pour eviter la bascule vers un nouvel aeroport plus proche
            # lorsqu on navigue dans le circuit
            airport_id = getprop("/sim/airport/closest-airport-id") or '';
            assistance_message = sprintf(
                    "%s, You asked for assistance, I will help you to reach the closest airport : %s",
                    callsign,
                    airport_id);
            print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);

            assistance_message = sprintf(
                    "Follow my instructions, heading in magnetic, set altitude %.2f inhg",
                    qnh);
            print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);
        }
        else
        {
            # aeroport trouve, on recupere les infos
            # get some info on airport
            var airport_info                = airportinfo(airport_id);
            var airport_info_name           = airport_info.name;
            var airport_info_elevation_ft   = (3.28 * airport_info.elevation);

            # on choisi la piste la plus longue
            # get longest runway
            var longest_rwy_id = '';
            var longest_rwy    = 0;
            var runways = airport_info.runways;
            var runway_keys = sort(keys(runways), string.icmp);
            foreach(var rwy_id; runway_keys)
            {
                var runway = runways[rwy_id];
                if(runway.length > longest_rwy)
                {
                    longest_rwy    = runway.length;
                    longest_rwy_id = rwy_id;
                }
            }
            var airport_info_runway_id = runways[longest_rwy_id];
            var airport_info_heading = airport_info_runway_id.heading;
            var airport_info_lng     = airport_info_runway_id.lon;
            var airport_info_lat     = airport_info_runway_id.lat;

            #printf("DEBUG : AIRPORT %s - %s - %s - %s - %d - RUNWAY %s - %d - %d",
            #    airport_id,
            #    airport_info_name,
            #    airport_info_lng,
            #    airport_info_lat,
            #    airport_info_elevation_ft,
            #    longest_rwy_id,
            #    airport_info_runway_id.length * 3.28,
            #    airport_info_heading
            #);
            #DEBUG : AIRPORT LFRQ - Quimper Pluguffan - -4.1722096 - 47.972947 - 296 - RUNWAY 10 - 7052 - 93

            # on recupere les coordonnees de l aeroport et de l avion
            var coord_airport = geo.Coord.new();
            coord_airport.set_latlon(airport_info_lat, airport_info_lng);
            var coord_aircraft = geo.aircraft_position();

            # l idee est de faire une rotation puis translation de l ensemble
            # l aeroport etant au centre de la zone qui a pour coord gps 0,0
            # on doit donc aussi rotationner et translater les coords de l avion
            # on recupere l angle + distance actuels de l avion par rapport a
            # l aeroport
            var from = coord_airport;
            var to = coord_aircraft;
            var (course, dist_nm) = courseAndDistance(from, to);

            # on rotationnes les coordonnees de l avion
            var rotated_aircraft_position = coord_airport.apply_course_distance((course - airport_info_heading), (dist_nm * NM2M));

            # et on translate les coordonnees de l avion
            var translated_aircraft_lng = rotated_aircraft_position.lon() - airport_info_lng;
            var translated_aircraft_lat = rotated_aircraft_position.lat() - airport_info_lat;

            # a ce moment on a un aeroport avec la piste la plus longue alignee
            # vers le nord, les coordonnes de l aeroport sont 0, 0
            # les coordonnees de l avion ont ete transposees dans le nouveau repere
            # on recherche alors dans quelle zone l avion se trouve
            var aircraft_in_zone = 0;
            var atc_heading = math.mod((course + 180), 360);
            var atc_speed   = 300;
            var atc_alt     = (sprintf('%d', 5000 / 100) + sprintf('%d', airport_info_elevation_ft / 100)) * 100;
            var atc_circuit = 'NULL';
            var assistance_message            = '';
            var assistance_message_header     = sprintf('atc %s, %s.', airport_id, callsign);
            var assistance_message_horizontal = '';
            var assistance_message_vertical   = '';
            var assistance_message_vitesse    = '';
            var assistance_message_bonus      = '';
            var l_or_r = (math.mod(course + 360 - heading, 360) > 180) ? 'left' : 'right';
            foreach(var zone; assistance_zone)
            {
                if((translated_aircraft_lng > zone['top_left_x'])
                    and (translated_aircraft_lng < zone['bottom_right_x'])
                    and (translated_aircraft_lat > zone['bottom_right_y'])
                    and (translated_aircraft_lat < zone['top_left_y']))
                {
                    aircraft_in_zone = 1;
                    atc_heading = math.mod(airport_info_heading + zone['heading'], 360);
                    atc_speed   = zone['speed'];
                    atc_alt     = (sprintf('%d', zone['alt'] / 100) + sprintf('%d', airport_info_elevation_ft / 100)) * 100;
                    atc_circuit = zone['circuit'];
                    l_or_r = (math.mod(atc_heading + 360 - heading, 360) > 180) ? 'left' : 'right';
                    break;
                }
            }

# GESTION DES MESSAGES POUR LA PARTIE HORIZONTALE
            # on gere differemment selon si l avion est dans ou hors zone
            if(aircraft_in_zone == 1)
            {
                # avion en finale
                # zone final leg :
                if(atc_circuit == 'final')
                {
                    # message de correction d alignement avec la piste
                    # alignment with runway
                    var correction = math.mod(heading - (airport_info_heading - course + 180), 360);
                    l_or_r = ((heading - airport_info_heading - course + 180) < 0) ? 'left' : 'right';
                    assistance_message_horizontal = sprintf('%s leg, align to runway %s, turn %s heading %03d.',
                            atc_circuit,
                            rwy_id,
                            l_or_r,
                            correction);
                }
                # avion dans les autres zones, on va guider l avion pour lui faire faire un circuit
                elsif(math.cos((heading - atc_heading) * D2R) > math.cos(5 * D2R))
                {
                    # autres zones, l avion est au cap correct
                    # other zones - maintain
                    assistance_message_horizontal = sprintf('%s leg, maintain heading %03d.',
                        atc_circuit,
                        atc_heading);
                }
                else
                {
                    # autres zones
                    # other zones - turn
                    assistance_message_horizontal = sprintf('%s leg, turn %s heading %03d.',
                        atc_circuit,
                        l_or_r,
                        atc_heading);
                }
            }
            else
            {
                # avion hors zone, on va donner a l avion le cap direct vers l aeroport
                var l_or_r = (math.mod(course + 360 - heading, 360) > 180) ? 'left' : 'right';
                assistance_message_horizontal = sprintf('turn %s heading %03d.', l_or_r, math.mod((course + 180), 360));
            }

# GESTION DES MESSAGES POUR LA PARTIE VERTICALE
            # avion en finale
            if(atc_circuit == 'final')
            {
                assistance_message_vertical = sprintf('airport altitude:%d ft.',
                    airport_info_elevation_ft);
            }
            elsif(aircraft_in_zone != 1)
            {
                assistance_message_vertical = '';
            }
            elsif(altitude > (atc_alt + 100))
            {
                assistance_message_vertical = sprintf('descend to %d ft.',
                    atc_alt);
            }
            elsif(altitude < (atc_alt - 100))
            {
                assistance_message_vertical = sprintf('climb to %d ft.',
                    atc_alt);
            }
            else
            {
                assistance_message_vertical = sprintf('maintain %d ft.',
                    atc_alt);
            }

# GESTION DES MESSAGES POUR LA PARTIE VITESSE
            # avion en finale
            if(atc_circuit == 'final')
            {
                assistance_message_vitesse = '';
            }
            elsif(speed > (atc_speed + 20))
            {
                assistance_message_vitesse = sprintf('lower speed to %d kt.',
                    atc_speed);
            }
            elsif(speed < (atc_speed - 20))
            {
                assistance_message_vitesse = sprintf('raise speed to %d kt.',
                    atc_speed);
            }
            else
            {
                assistance_message_vitesse = sprintf('maintain speed %d kt.',
                    atc_speed);
            }

            if(((atc_circuit == 'downwind') or (atc_circuit == 'base') or (atc_circuit == 'final'))
                and (is_gear_down == 0))
            {
                assistance_message_bonus = 'check gears down.';
            }

# AFFICHAGE DES MESSAGES
            assistance_message = sprintf('%s %s %s %s %s',
                assistance_message_header,
                assistance_message_horizontal,
                assistance_message_vertical,
                assistance_message_vitesse,
                assistance_message_bonus);

            print(assistance_message);
            if(assistance_message != previous_assistance_message)
            {
                setprop("/sim/messages/atc", assistance_message);
                previous_assistance_message = assistance_message;
            }
            elsif(nb_cycle > 10)
            {
                nb_cycle = 1;
                setprop("/sim/messages/atc", assistance_message);
            }
            nb_cycle += 1;
        }
    }
    else
    {
        # assistance disabled
        airport_id = '' ;
    }
    settimer(assistance_loop, 1);
}

setlistener("/sim/signals/fdm-initialized", assistance_loop);












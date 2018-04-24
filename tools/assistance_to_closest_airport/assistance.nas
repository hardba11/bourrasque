print("*** LOADING tools - assistance.nas ... ***");

# namespace : tools

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

var airport_id = '';
var atc_speed = 300;
var atc_alt = 5000;
var atc_circuit = 'NULL';

var assistance_message_header = '';
var assistance_message = '';
var assistance_message_horizontal = '';
var assistance_message_vertical = '';
var assistance_message_vitesse = '';
var assistance_message_bonus = '';

var previous_assistance_message = '';
var previous_heading = 0;

var assistance_loop = func() {

    var is_enabled = getprop("/controls/assistance") or 0;

    # end of assistance if landed
    var is_wow = getprop("/gear/gear[0]/wow") or 0;
    if(is_wow)
    {
        is_enabled = 0;
        setprop("/controls/assistance", 0);
    }

    if(is_enabled == 1)
    {
        var callsign = getprop("/sim/multiplay/callsign") or 'callsig';
        var heading = getprop("/orientation/heading-magnetic-deg") or 0;
        var altitude = getprop("/position/altitude-ft") or 0;
        var speed = getprop("/velocities/airspeed-kt") or 0;
        var is_gear_down = getprop("/controls/gear/gear-down") or 0;

        var qnh = getprop("/environment/pressure-sea-level-inhg") or 0;

        if(airport_id == '')
        {
            # on recupere l aeroport le plus proche si il n a pas deja ete choisi
            # on fait ca pour eviter la bascule vers un nouvel aeroport plus proche
            # lorsqu on navigue dans le circuit
            airport_id = getprop("/sim/airport/closest-airport-id") or '';
            assistance_message = sprintf("%s, I will help you to reach the closest airport : %s, follow my instructions, heading in magnetic, set altitude %.2f inhg",
                    callsign, airport_id, qnh);
            print(assistance_message);
            setprop("/sim/messages/atc", assistance_message);
        }
        if(airport_id != '')
        {
            # aeroport trouve, on recupere les infos
            var airport_info = airportinfo(airport_id);
            var airport_info_name = airport_info.name;
            var airport_info_lng = airport_info.lon;
            var airport_info_lat = airport_info.lat;
            var airport_info_elevation_ft = (3.28 * airport_info.elevation);

            # on choisi la piste la plus longue
            var longest_rwy_id = '';
            var longest_rwy = 0;
            var runways = airport_info.runways;
            var runway_keys = sort(keys(runways), string.icmp);
            foreach(var rwy_id; runway_keys)
            {
                var runway = runways[rwy_id];
                if(runway.length > longest_rwy)
                {
                    longest_rwy = runway.length;
                    longest_rwy_id = rwy_id;
                }
            }
            var airport_info_runway_id = runways[longest_rwy_id];
            var airport_info_heading = airport_info_runway_id.heading;

            #printf("AIRPORT %s - %s - %s - %s - %s - RUNWAY %s - %s - %s", 
            #    airport_id, 
            #    airport_info_name,
            #    airport_info_lng,
            #    airport_info_lat,
            #    airport_info_elevation_ft,
            #    longest_rwy_id,
            #    airport_info_runway_id.length * 3.28,
            #    airport_info_heading
            #);


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
            var in_zone = 0;
            atc_speed = 300;
            atc_alt = 5000 + airport_info_elevation_ft;
            atc_circuit = 'NULL';
            foreach(var zone; assistance_zone)
            {
                if((translated_aircraft_lng > zone['top_left_x'])
                    and (translated_aircraft_lng < zone['bottom_right_x'])
                    and (translated_aircraft_lat > zone['bottom_right_y'])
                    and (translated_aircraft_lat < zone['top_left_y']))
                {
                    in_zone = 1;
                    var atc_heading = math.mod(airport_info_heading + zone['heading'], 360);
                    var l_or_r = (math.mod(atc_heading + 360 - heading, 360) > 180) ? 'left' : 'right';
                    atc_speed = zone['speed'];
                    atc_circuit = zone['circuit'];
                    atc_alt = zone['alt'] + airport_info_elevation_ft;
                    break;
                }
            }

            assistance_message = '';
            assistance_message_header = sprintf('atc %s, %s.', airport_id, callsign);
            assistance_message_horizontal = '';
            assistance_message_vertical = '';
            assistance_message_vitesse = '';
            assistance_message_bonus = '';

            # GESTION DES MESSAGES POUR LA PARTIE HORIZONTALE
            # on gere differemment selon si l avion est dans ou hors zone
            if(in_zone == 1)
            {
                # avion en finale
                if(atc_circuit == 'final')
                {
                    var l_or_r = (math.mod(course + 360 - heading, 360) > 180) ? 'left' : 'right';
                    assistance_message_horizontal = sprintf('final leg, turn %s heading %03d.', l_or_r, math.mod((course + 180), 360));
                }
                # avion dans les autres zones, on va guider l avion pour lui faire faire un circuit
                elsif(math.cos((heading - atc_heading) * D2R) > math.cos(10 * D2R))
                {
                    assistance_message_horizontal = sprintf('maintain heading %03d.', atc_heading);
                }
                else
                {
                    assistance_message_horizontal = sprintf('turn %s heading %03d.', l_or_r, atc_heading);
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
                assistance_message_vertical = sprintf('begin your descend to land, airport altitude:%d ft.', airport_info_elevation_ft);
            }
            elsif(in_zone != 1)
            {
                assistance_message_vertical = '';
            }
            elsif(altitude > (atc_alt + 100))
            {
                assistance_message_vertical = sprintf('descend to %d ft.', atc_alt);
            }
            elsif(altitude < (atc_alt - 100))
            {
                assistance_message_vertical = sprintf('climb to %d ft.', atc_alt);
            }
            else
            {
                assistance_message_vertical = sprintf('maintain %d ft.', atc_alt);
            }

            # GESTION DES MESSAGES POUR LA PARTIE VITESSE
            # avion en finale
            if(atc_circuit == 'final')
            {
                assistance_message_vitesse = '';
            }
            elsif(speed > (atc_speed + 20))
            {
                assistance_message_vitesse = sprintf('lower speed to %d kt.', atc_speed);
            }
            elsif(speed < (atc_speed - 20))
            {
                assistance_message_vitesse = sprintf('raise speed to %d kt.', atc_speed);
            }
            else
            {
                assistance_message_vitesse = sprintf('maintain speed %d kt.', atc_speed);
            }

            if(((atc_circuit == 'downwind') or (atc_circuit == 'base') or (atc_circuit == 'final'))
                and (is_gear_down == 0))
            {
                assistance_message_bonus = 'check gears down.';
            }

            #if(heading != previous_heading)
            #{
            #    previous_heading = heading;
            #}

            assistance_message = sprintf('%s %s %s %s %s', 
                assistance_message_header, 
                assistance_message_horizontal, 
                assistance_message_vertical, 
                assistance_message_vitesse, 
                assistance_message_bonus);

            print(assistance_message);
            #if(assistance_message != previous_assistance_message)
            #{
                setprop("/sim/messages/atc", assistance_message);
                previous_assistance_message = assistance_message;
            #}
        }
    }
    else
    {
        airport_id = '' ;
    }
    settimer(assistance_loop, 5);
}

setlistener("/sim/signals/fdm-initialized", assistance_loop);












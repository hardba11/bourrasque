print("*** LOADING instrument_hud_target_positions - hud_target_positions.nas ... ***");

# namespace : instrument_hud_target_positions

var my_reticle_radius = 10;
var max_reticle = 10;
var px_factor = 330;

var alpha = .7;
# nombre d'entrees, voir max_reticle
var colors = [
    { 'r':   0, 'g': 238, 'b': 107, }, #00ee6b
    { 'r': 255, 'g': 242, 'b':  54, }, #fff236
    { 'r': 192, 'g':  28, 'b':  40, }, #c01c28
    { 'r': 234, 'g': 102, 'b': 249, }, #ea66f9
    { 'r': 238, 'g': 185, 'b':   0, }, #eeb900
    { 'r': 241, 'g':  26, 'b': 153, }, #f11a99
    { 'r': 255, 'g': 120, 'b':   0, }, #ff7800
    { 'r': 181, 'g': 131, 'b':  90, }, #b5835a
    { 'r': 255, 'g': 255, 'b': 255, }, #ffffff
    { 'r': 179, 'g': 255, 'b': 116, }, #b3ff74
    { 'r':   0, 'g':   0, 'b':   0, }, #000000
];

#===============================================================================
#                                                                      CLASS HUD
var HUD = {
    canvas_settings: {
        'name': 'hud_target_positions',
        'size': [2048, 2048],
        'view': [1024, 1024],
        'mipmapping': 1
    },
    new: func(placement)
    {
        # structure des elements
        # ----------------------
        #   canvas:
        #       my_container:
        #           horizontal_container (t_ : permet la rotation selon le roulis):
        #               debug_*
        #               target (t_ : translation sur x et y pour postionner la cible):
        #                   reticle (t_ : rotation pour afficher le cap relatif):
        #                       repere
        #                       circle
        #                       triangle
        #                   speed_info (translation pour la vitesse relative)
        #                       speed_bar
        #                       text_speed
        #                   text_lbl
        #                   text_info

        var m = {
            parents: [HUD],
            canvas: canvas.new(HUD.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 0);
        m.my_container = m.canvas.createGroup('my_container');

        # container qui restera horizontal (pitch)
        m.horizontal_container = m.my_container.createChild('group');
        m.t_horizontal_container = m.horizontal_container.createTransform();

#        m.debug_rectangle1 = m.horizontal_container.createChild('path').setStrokeLineWidth(2).set('stroke', 'rgba(255, 0, 0, 1)').moveTo(4, 4).lineTo(4, 1020).lineTo(1020, 1020).lineTo(1020, 4).close();
#        m.debug_rectangle2 = m.horizontal_container.createChild('path').setStrokeLineWidth(2).set('stroke', 'rgba(255, 0, 0, 1)').moveTo(256, 256).lineTo(256, 768).lineTo(768, 768).lineTo(768, 256).close();
#        m.debug_ligne1 = m.horizontal_container.createChild('path').setStrokeLineWidth(2).set('stroke', 'rgba(255, 0, 0, 1)').moveTo(508, 512).lineTo(516, 512);
#        m.debug_ligne2 = m.horizontal_container.createChild('path').setStrokeLineWidth(2).set('stroke', 'rgba(255, 0, 0, 1)').moveTo(512, 508).lineTo(512, 516);

        m.targets = [];
        m.t_targets = [];
        m.t_reticles = [];
        m.t_speed_infos = [];

        for(var i = 0; i < max_reticle; i += 1)
        {
            m.target = m.horizontal_container.createChild('group', 'target-'~ i);
            m.t_target = m.target.createTransform();

            # le point est statique et sert de repere
            m.repere = m.target.createChild('path', 'repere-'~ i)
                .setStrokeLineWidth(2)
                .set('stroke', 'rgba('~ colors[i]['r'] ~', '~ colors[i]['g'] ~', '~ colors[i]['b'] ~', '~ alpha ~')')
                .moveTo(0, -my_reticle_radius - 2)
                .lineTo(0, -my_reticle_radius - 6);

            m.reticle = m.target.createChild('group', 'reticle-'~ i);
            m.t_reticle = m.reticle.createTransform();

            # le cercle identifie la cible
            m.circle = m.reticle.createChild('path', 'circle-'~ i)
                .setStrokeLineWidth(2)
                .set('stroke', 'rgba('~ colors[i]['r'] ~', '~ colors[i]['g'] ~', '~ colors[i]['b'] ~', '~ alpha ~')')
                .moveTo(0 - my_reticle_radius, 0)
                .arcSmallCW(my_reticle_radius, my_reticle_radius, 0, (my_reticle_radius * 2), 0)
                .arcSmallCW(my_reticle_radius, my_reticle_radius, 0, -(my_reticle_radius * 2), 0);

            # le triangle donne le cap relatif
            m.triangle = m.reticle.createChild('path', 'triangle-'~ i)
                .setStrokeLineWidth(2)
                .set('stroke', 'rgba('~ colors[i]['r'] ~', '~ colors[i]['g'] ~', '~ colors[i]['b'] ~', '~ alpha ~')')
                .moveTo(-2, 17)
                .lineTo(0, 12)
                .lineTo(2, 17);

            # les barres horizontales donnent le rapprochement relatif
            m.speed_info = m.target.createChild('group', 'speed_info-'~ i);
            m.speed_bar = m.speed_info.createChild('path', 'speed_bar-'~ i)
                .setStrokeLineWidth(2)
                .set('stroke', 'rgba('~ colors[i]['r'] ~', '~ colors[i]['g'] ~', '~ colors[i]['b'] ~', '~ alpha ~')')
                .moveTo(-(my_reticle_radius + 6), 0)
                .lineTo(-my_reticle_radius, 0)
                .moveTo(my_reticle_radius, 0)
                .lineTo(my_reticle_radius + 6, 0);
            m.text_speed = m.speed_info.createChild('text', 'text_speed-'~ i)
                .setTranslation(-18, 0)
                .setAlignment('right-center')
                .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                .setFontSize(7)
                .setColor((colors[i]['r'] / 255), (colors[i]['g'] / 255), (colors[i]['b'] / 255), alpha)
                .setText('VOID'~ i);
            m.t_speed_info = m.speed_info.createTransform();

            # on affiche des infos de la cible a cote du cercle
            m.text_lbl = m.target.createChild('text', 'text_lbl-'~ i)
                .setTranslation(18, 0)
                .setAlignment('left-center')
                .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                .setFontSize(8)
                .setColor((colors[i]['r'] / 255), (colors[i]['g'] / 255), (colors[i]['b'] / 255), alpha)
                .setText('LABEL'~ i);
            m.text_info = m.target.createChild('text', 'text_info-'~ i)
                .setTranslation(18, 10)
                .setAlignment('left-center')
                .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                .setFontSize(7)
                .setColor((colors[i]['r'] / 255), (colors[i]['g'] / 255), (colors[i]['b'] / 255), alpha)
                .setText('INFO'~ i);

            m.target.setTranslation(512, 512);
            m.target.hide();

            append(m.targets, m.target);
            append(m.t_targets, m.t_target);
            append(m.t_reticles, m.t_reticle);
            append(m.t_speed_infos, m.t_speed_info);
            #print('DEBUG new target no:'~ i);
        }

        return m;
    },
    update: func()
    {
        var show_targets = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/enabled") or 0;
        if(show_targets == 1)
        {

            # recuperation de la position de l'avion, on neglige le yaw
            var pitch_deg      = getprop("/orientation/pitch-deg");
            var roll_deg       = getprop("/orientation/roll-deg");
            var velocity       = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
            var my_heading_deg = getprop("/orientation/heading-deg"); # true north
            var my_aoa_deg     = getprop("/orientation/alpha-deg");
            var radar_range    = getprop("/instrumentation/my_aircraft/sfd/controls/radar_range") or 5;

            var pitch_view_deg   = getprop("/instrumentation/my_aircraft/hud_target_positions/view/pitch-offset-deg");
            var heading_view_deg = getprop("/instrumentation/my_aircraft/hud_target_positions/view/heading-offset-deg");

            var coord_y_pitch  = math.tan(pitch_deg * D2R) * px_factor;
            var coord_y_aoa    = math.tan(my_aoa_deg * D2R) * px_factor;

            # recuperation des informations sur les targets
            # les donnees brutes sont dans list_mp_obj
            # les donnees filtrees et transformees qui serviront a l'affichage sont dans targets_datas
            var targets_are_mp = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/targets_are_mp") or 0;
            if(targets_are_mp == 1)
            {
                var list_mp_obj    = props.globals.getNode("/ai/models").getChildren("multiplayer");
            }
            else
            {
                var list_mp_obj    = props.globals.getNode("/ai/models").getChildren("aircraft");
            }
            var list_obj = props.globals.getNode("/ai/models").getChildren("tanker");

            # ajout des objets target aux objets tanker
            for(var i = 0; i < size(list_mp_obj); i += 1)
            {
                var ac_type = list_mp_obj[i].getNode("sim/model/ac-type");
                if((ac_type == nil) or ((ac_type != nil) and (ac_type.getValue() != "brsq-backseat")))
                {
                    append(list_obj, list_mp_obj[i]);
                }
            }

            var targets_datas  = [];
            for(var i = 0; i < size(list_obj); i += 1)
            {
                var target_callsign    = list_obj[i].getNode("callsign").getValue() or '';

                var target_in_range    = list_obj[i].getNode("radar/in-range").getValue() or 0;
                var is_valid           = list_obj[i].getNode("valid").getValue() or 0;
                var target_range       = list_obj[i].getNode("radar/range-nm").getValue() or 1000;
                var vertical_offset    = list_obj[i].getNode("radar/v-offset").getValue() or 0;
                var horizontal_offset  = list_obj[i].getNode("radar/h-offset").getValue() or 0;

#                var target_model       = list_obj[i].getNode("model-short", 1).getValue() or '';
#                var target_model       = list_obj[i].getNode("model/name", 1).getValue() or '';

                var model_path = list_obj[i].getNode("sim/model/path", 1).getValue() or '';
                var paths = split('/', model_path);
                var filename_model = pop(paths);
                var target_model = split('.', filename_model)[0];

                if(target_in_range
                    and is_valid
                    and target_range < radar_range
#                    and (math.mod(math.mod(360 - horizontal_offset, 360) - heading_view_deg, 360) > 240
#                        or math.mod(math.mod(360 - horizontal_offset, 360) - heading_view_deg, 360) < 120
#                    )
                )
                {
                    var target_data = {};

                    target_data.view = 0;
                    if((math.mod(math.mod(360 - horizontal_offset, 360) - heading_view_deg, 360) > 240)
                        or (math.mod(math.mod(360 - horizontal_offset, 360) - heading_view_deg, 360) < 120))
                    {
                        target_data.view = 1;
                    }

                    var target_elevation_deg         = list_obj[i].getNode("radar/elevation-deg").getValue() or 0;
                    var target_heading_deg           = list_obj[i].getNode("orientation/true-heading-deg").getValue() or 0;
                    var target_altitude              = list_obj[i].getNode("position/altitude-ft").getValue() or 0;
                    var target_airspeed              = list_obj[i].getNode("velocities/true-airspeed-kt").getValue() or 0;
                    var target_bearing_deg           = list_obj[i].getNode("radar/bearing-deg").getValue() or 0;

                    var relative_heading_deg         = target_heading_deg - my_heading_deg;

                    # https://fr.wikipedia.org/wiki/Matrice_de_rotation#En_dimension_trois
                    # https://www.mathweb.fr/euclide/2019/07/14/introduction-aux-matrices-de-rotation/
                    # http://www.pierreaudibert.fr/tra/GeometrieSphere.pdf
                    # https://en.wikipedia.org/wiki/Spherical_coordinate_system
                    # https://www.methodephysique.fr/coordonnees_cartesiennes_cylindriques_spheriques/
                    # https://www.random-science-tools.com/maths/coordinate-converter.htm

                    # on transforme les angles v et h en coordonnees x, y, z sur une sphere de rayon 1
                    var x = math.cos((vertical_offset + pitch_deg) * D2R) * math.cos(horizontal_offset * D2R);
                    var y = math.cos((vertical_offset + pitch_deg) * D2R) * math.sin(horizontal_offset * D2R);
                    var z = math.sin((vertical_offset + pitch_deg) * D2R);

                    # on applique une matrice de rotation autour de y pour obtenir les nouvelles coordonnees de la cible en fonction du tangage
                    # on ramene ainsi l'axe du roulis sur x
                    var x_t1 = (z * math.sin(pitch_deg * D2R)) + (x * (math.cos(pitch_deg * D2R)));
                    var y_t1 = y;
                    var z_t1 = (z * math.cos(pitch_deg * D2R)) - (x * (math.sin(pitch_deg * D2R)));

                    # on applique une matrice de rotation autour de x pour obtenir les nouvelles coordonnees de la cible en fonction du roulis
                    var x_t2 = x_t1;
                    var y_t2 = (y_t1 * math.cos(roll_deg * D2R)) - (z_t1 * (math.sin(roll_deg * D2R)));
                    var z_t2 = (y_t1 * math.sin(roll_deg * D2R)) + (z_t1 * (math.cos(roll_deg * D2R)));

                    # on transforme les nouvelles coordonnees en angles
                    var new_vertical_offset = math.asin(math.clamp(z_t2, -1, 1)) / D2R;
                    var new_horizontal_offset = math.atan2(y_t2, x_t2) / D2R;

                    # la vue en se deplacant doit afficher les coordonnees (x diminue dans les hautes latitudes)
                    var coord_x                      = math.tan((new_horizontal_offset + heading_view_deg) * D2R) * px_factor * math.sin((90 - pitch_view_deg) * D2R);
                    var coord_y                      = math.tan((new_vertical_offset - pitch_view_deg) * D2R) * px_factor * -1;

#                    print(sprintf('DEBUG h%d:v%d = [%.2f,%.2f,%.2f] -- r %d --> [%.2f,%.2f,%.2f] - p %d --> [%.2f,%.2f,%.2f] = h%d:v%d', 
#                        horizontal_offset, vertical_offset,
#                        x, y, z,
#                        pitch_deg,
#                        x_t1, y_t1, z_t1,
#                        roll_deg,
#                        x_t2, y_t2, z_t2,
#                        new_horizontal_offset, new_vertical_offset
#                    ));


                    var relative_speed_M             = velocity        * math.cos(horizontal_offset * D2R);
                    var relative_speed_T             = target_airspeed * math.cos((target_heading_deg - target_bearing_deg) * D2R);
                    var relative_speed               = relative_speed_T - relative_speed_M;
#                    var speed_y                      = (sprintf('%d', relative_speed) == 0) ? 0 : math.log10(math.abs(sprintf('%d', relative_speed) / 2)) * 5;
                    var speed_y                      = (sprintf('%d', relative_speed) == 0) ? 0 : math.log10(math.abs(sprintf('%d', relative_speed))) * 5;
                    var positive_or_negative         = (relative_speed >= 0) ? 1 : -1;

                    target_data.speed_bars_y         = positive_or_negative * speed_y;
                    target_data.text_speed           = sprintf('%.1f', -relative_speed);
                    if(target_range > 5)
                    {
                        target_data.text_lbl         = sprintf('%s : %d nm', target_callsign, target_range);
                        target_data.text_info        = "";
                    }
                    else
                    {
                        target_data.text_lbl         = sprintf('%s : %.2f nm [%s]', target_callsign, target_range, target_model);
                        target_data.text_info        = sprintf('%d ft / %d kt', target_altitude, target_airspeed);
                    }
                    target_data.coord_x              = coord_x;
                    target_data.coord_y              = coord_y;
                    target_data.relative_heading_deg = relative_heading_deg;
                    target_data.target_range         = target_range;

                    append(targets_datas, target_data);
                    #print(sprintf('FOUND target %s - %.1f - %d - %d', target_callsign, relative_speed, velocity, target_airspeed));
                    #print(sprintf('DEBUG [%d,%d] - %.3f', coord_x, coord_y, target_elevation_deg));
                    #print(sprintf('DEBUG [%.2f,%.2f] vo:%d - ho:%d | x:%d y:%d | R:%.2f T:%.2f F:%.2F', 
                    #  pitch_deg, roll_deg, 
                    #  vertical_offset, horizontal_offset, 
                    #  coord_x, coord_y, 
                    #  coord_R, coord_T, coord_F));
                }
                if(size(targets_datas) > max_reticle)
                {
                    break;
                }
            }

            # affichage
            for(var i = 0; i < max_reticle; i += 1)
            {
                me.targets[i].hide();
                if(i < size(targets_datas))
                {
                    var td = targets_datas[i];

                    var scale_reticle = ((td.target_range < 10) and (td.target_range > 0))
                        ? ((-.12 * td.target_range) + 1.5)
                        : 0.3;
                    me.text_lbl   = me.targets[i].getElementById('text_lbl-'~ i);
                    me.text_info  = me.targets[i].getElementById('text_info-'~ i);
                    me.reticle    = me.targets[i].getElementById('reticle-'~ i);
                    me.text_speed = me.targets[i].getElementById('text_speed-'~ i);

                    me.t_speed_infos[i].setTranslation(0, -td.speed_bars_y);
                    me.text_lbl.setText(td.text_lbl);
                    me.text_info.setText(td.text_info);
                    me.text_speed.setText(td.text_speed);
                    me.t_targets[i].setTranslation(td.coord_x, td.coord_y);
                    me.t_reticles[i].setRotation(td.relative_heading_deg * D2R);
                    me.t_targets[i].setScale(scale_reticle, scale_reticle);

                    if(td.view == 1)
                    {
                        me.targets[i].show();
                        #print(sprintf('SHOW target %s', td.text_info));
                    }
                }
            }
            #me.t_horizontal_container.setRotation(-(roll_deg * D2R), 512, 512);
        }
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 1;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var hud_pilot = HUD.new({'node': 'fieldOfView'});
    hud_pilot.update();
});






print("*** LOADING instrument_hud_target_positions - hud_target_positions.nas ... ***");

# namespace : instrument_hud_target_positions

var my_reticle_radius = 10;
var max_reticle = 10;

var DEG2PIXEL = 512 / 45;

#===============================================================================
#                                                                      CLASS HUD
var HUD = {
    canvas_settings: {
        "name": "hud_target_positions",
        "size": [2048, 2048],
        "view": [1024, 1024],
        "mipmapping": 1
    },
    new: func(placement)
    {
        # structure des elements
        # ----------------------
        #   canvas:
        #       my_container:
        #           horizontal_container (t_ : permet la rotation selon le roulis):
        #               debug_rectangle:
        #               target (t_ : translation sur x et y pour postionner la cible):
        #                   reticle (t_ : rotation pour afficher le cap relatif):
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
        m.my_container = m.canvas.createGroup("my_container");

        # container qui restera horizontal (pitch)
        m.horizontal_container = m.my_container.createChild("group");
        m.t_horizontal_container = m.horizontal_container.createTransform();

        #m.debug_rectangle = m.horizontal_container.createChild("path").setStrokeLineWidth(1).set("stroke", "rgba(255, 0, 0, 1)").moveTo(0, 0).lineTo(0, 1024).lineTo(1024, 1024).lineTo(1024, 0).close();

        m.targets = [];
        m.t_targets = [];
        m.t_reticles = [];
        m.t_speed_infos = [];

        for(var i = 0; i < max_reticle; i += 1)
        {
            m.target = m.horizontal_container.createChild("group", "target-"~ i);
            m.t_target = m.target.createTransform();

            m.reticle = m.target.createChild("group", "reticle-"~ i);
            m.t_reticle = m.reticle.createTransform();

            # le cercle identifie la cible
            m.circle = m.reticle.createChild("path", "circle-"~ i)
                .setStrokeLineWidth(2)
                .set("stroke", "rgba(255, 255, 220, 0.9)")
                .moveTo(0 - my_reticle_radius, 0)
                .arcSmallCW(my_reticle_radius, my_reticle_radius, 0, (my_reticle_radius * 2), 0)
                .arcSmallCW(my_reticle_radius, my_reticle_radius, 0, -(my_reticle_radius * 2), 0);

            # le triangle donne le cap relatif
            m.triangle = m.reticle.createChild("path", "triangle-"~ i)
                .setStrokeLineWidth(2)
                .set("stroke", "rgba(255, 255, 220, 0.9)")
                .moveTo(-2, 17)
                .lineTo(0, 12)
                .lineTo(2, 17);

            # les barres horizontales donnent le rapprochement relatif
            m.speed_info = m.target.createChild("group", "speed_info-"~ i);
            m.speed_bar = m.speed_info.createChild("path", "speed_bar-"~ i)
                .setStrokeLineWidth(2)
                .set("stroke", "rgba(255, 255, 220, 0.9)")
                .moveTo(-(my_reticle_radius + 8), 0)
                .lineTo(-my_reticle_radius, 0)
                .moveTo(my_reticle_radius, 0)
                .lineTo(my_reticle_radius + 8, 0);
            m.text_speed = m.speed_info.createChild("text", "text_speed-"~ i)
                .setTranslation(-30, 0)
                .setAlignment("right-center")
                .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
                .setFontSize(8)
                .setColor(1, 1, 0.7, 1)
                .setText("VOID"~ i);
            m.t_speed_info = m.speed_info.createTransform();

            # on affiche des infos de la cible a cote du cercle
            m.text_info = m.target.createChild("text", "text_info-"~ i)
                .setTranslation(15, -10)
                .setAlignment("left-center")
                .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
                .setFontSize(9)
                .setColor(1, 1, 0.7, 1)
                .setText("INFO"~ i);
            m.text_lbl = m.target.createChild("text", "text_lbl-"~ i)
                .setTranslation(0, 20)
                .setAlignment("center-center")
                .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
                .setFontSize(8)
                .setColor(1, 1, 0.7, 1)
                .setText("LABEL"~ i);

            m.target.setTranslation(512, 512);
            m.target.hide();

            append(m.targets, m.target);
            append(m.t_targets, m.t_target);
            append(m.t_reticles, m.t_reticle);
            append(m.t_speed_infos, m.t_speed_info);
            #print("DEBUG new target no:"~ i);
        }

        return m;
    },
    update: func()
    {
        var show_targets = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/enabled") or 0;
        if(show_targets == 1)
        {
            # recuperation de la position de l avion
            var pitch_deg      = getprop("/orientation/pitch-deg");
            var roll_deg       = getprop("/orientation/roll-deg");
            var velocity       = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
            var my_heading_deg = getprop("/orientation/heading-deg");
            var my_aoa_deg     = getprop("/orientation/alpha-deg");

            var coord_y_pitch  = pitch_deg * DEG2PIXEL;
            var coord_y_aoa    = my_aoa_deg * DEG2PIXEL;

            # recuperation des informations sur les targets
            # les donnees brutes sont dans list_mp_obj
            # les donnees filtrees et transformees qui serviront a l affichage sont dans targets_datas
            var targets_are_mp = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/targets_are_mp") or 0;
            if(targets_are_mp == 1)
            {
                var list_mp_obj    = props.globals.getNode("/ai/models").getChildren("multiplayer");
            }
            else
            {
                var list_mp_obj    = props.globals.getNode("/ai/models").getChildren("aircraft");
            }
            var targets_datas  = [];

            for(var i = 0; i < size(list_mp_obj); i += 1)
            {
                var target_bearing_deg = list_mp_obj[i].getNode("radar/bearing-deg").getValue() or 0;
                var target_callsign    = list_mp_obj[i].getNode("callsign").getValue() or 0;
                var target_in_range    = list_mp_obj[i].getNode("radar/in-range").getValue() or 0;
                var is_valid           = list_mp_obj[i].getNode("valid").getValue() or 0;

                if(target_in_range
                    and is_valid
                    and math.abs(target_bearing_deg - my_heading_deg) < 40)
                {
                    var target_data = {};

                    var target_elevation_deg         = list_mp_obj[i].getNode("radar/elevation-deg").getValue() or 0;
                    var target_heading_deg           = list_mp_obj[i].getNode("orientation/true-heading-deg").getValue() or 0;
                    var target_altitude              = list_mp_obj[i].getNode("position/altitude-ft").getValue() or 0;
                    var target_airspeed              = list_mp_obj[i].getNode("velocities/true-airspeed-kt").getValue() or 0;
                    var target_range                 = list_mp_obj[i].getNode("radar/range-nm").getValue() or 0;

                    var relative_bearing_deg         = target_bearing_deg + my_heading_deg;
                    var bearing_deg                  = target_bearing_deg - my_heading_deg;
                    var relative_heading_deg         = target_heading_deg - my_heading_deg;

                    var coord_x                      = bearing_deg * DEG2PIXEL;
                    var coord_y                      = target_elevation_deg * DEG2PIXEL;

                    var relative_speed_M             = velocity        * math.cos((my_heading_deg - relative_bearing_deg) * D2R);
                    var relative_speed_T             = target_airspeed * math.cos((target_heading_deg * D2R) - math.pi - (relative_bearing_deg * D2R));
                    var relative_speed               = relative_speed_T + relative_speed_M;
                    var speed_y                      = (relative_speed == 0) ? 0 : math.log10(math.abs(relative_speed)) * 6;
                    var positive_or_negative         = (relative_speed >= 0) ? 1 : -1;

                    target_data.speed_bars_y         = positive_or_negative * speed_y;
                    target_data.text_speed           = sprintf("%.1f", relative_speed);
                    if(target_range > 5)
                    {
                        target_data.text_lbl         = sprintf("%s : %d nm", target_callsign, target_range);
                        target_data.text_info        = "";
                    }
                    else
                    {
                        target_data.text_lbl         = sprintf("%s : %.2f nm", target_callsign, target_range);
                        target_data.text_info        = sprintf("%d ft / %d kt", target_altitude, target_airspeed);
                    }
                    target_data.coord_x              = coord_x;
                    target_data.coord_y              = -(coord_y - coord_y_pitch);
                    target_data.relative_heading_deg = relative_heading_deg;

                    append(targets_datas, target_data);
                    #print(sprintf("FOUND target %s - %.1f - %d - %d", target_callsign, relative_speed, velocity, target_airspeed));
                    #print(sprintf("DEBUG [%d,%d] - %.3f", coord_x, coord_y, target_elevation_deg));
                }
                if(size(targets_datas) >= max_reticle)
                {
                    break;
                }
            }

            # affichage
            for(var i = 0; i < max_reticle; i += 1)
            {
                if(i < size(targets_datas))
                {
                    var td = targets_datas[i];

                    me.text_lbl   = me.targets[i].getElementById("text_lbl-"~ i);
                    me.text_info  = me.targets[i].getElementById("text_info-"~ i);
                    me.reticle    = me.targets[i].getElementById("reticle-"~ i);
                    me.text_speed = me.targets[i].getElementById("text_speed-"~ i);

                    me.t_speed_infos[i].setTranslation(0, -td.speed_bars_y);
                    me.text_lbl.setText(td.text_lbl);
                    me.text_info.setText(td.text_info);
                    me.text_speed.setText(td.text_speed);
                    me.t_targets[i].setTranslation(td.coord_x, td.coord_y);
                    me.t_reticles[i].setRotation(td.relative_heading_deg * D2R);

                    me.targets[i].show();
                    #print(sprintf("SHOW target %s", td.text_info));
                }
                else
                {
                    me.targets[i].hide();
                    #print(sprintf("HIDE target %d", i));
                }
            }
            me.t_horizontal_container.setRotation(-(roll_deg * D2R), 512, 512);
        }
        settimer(func() { me.update(); }, .1);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var hud_pilot = HUD.new({"node": "fieldOfView"});
    hud_pilot.update();
});






print("*** LOADING instrument_sfd_radar - sfd_radar.nas ... ***");

# namespace : instrument_sfd_radar

var max_piste = 30;

var resolution_x = 1024;
var resolution_y = 1024;
var pixel_range = 620;
var margin_top = 120;

var radar_range = getprop("/instrumentation/my_aircraft/sfd/controls/radar_range") or 5;


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                                       draw_arc
# this function draws an arc
# params :
# - element     : canvas object created by createChild()
# - center_x    : coord x of the center of the arc in px
# - center_y    : coord y of the center of the arc in px
# - radius      : radius
# - start_angle : start angle in deg ()
# - end_angle   : end angle in deg ()
# - color       : color
# - line_width  : line_width
#
var draw_arc = func(element, center_x, center_y, radius, start_angle, end_angle, color, line_width)
{
    var coord_start_x = center_x + (radius * math.cos(start_angle * D2R));
    var coord_start_y = center_y - (radius * math.sin(start_angle * D2R));

    var to_x = -(radius * math.cos(start_angle * D2R)) + (radius * math.cos(end_angle * D2R));
    var to_y = (radius * math.sin(start_angle * D2R)) - (radius * math.sin(end_angle * D2R));

    element.setStrokeLineWidth(line_width)
        .set('stroke', color)
        .moveTo(coord_start_x, coord_start_y)
        .arcSmallCCW(radius, radius, 0, to_x, to_y);
}

#-------------------------------------------------------------------------------
#                                                                     draw_piste
# this function creates a piste
#   
# params :
# - element  : canvas object created by createChild()
#
var draw_piste = func(element)
{
    element.setStrokeLineWidth(5)
        .set('stroke', 'rgba(40, 240, 40, 1)')
        .moveTo(-13, 13)
        .lineTo(-13, -13)
        .moveTo(13, 13)
        .lineTo(13, -13);

    # creation du vecteur vitesse+cap de la cible
    element.setStrokeLineWidth(4)
        .set('stroke', 'rgba(40, 240, 40, 1)')
        .moveTo(0, 0)
        .lineTo(0, 0);

    element.setStrokeLineWidth(4)
        .set('stroke', 'rgba(40, 240, 40, 1)')
        .moveTo(-12, 11)
        .lineTo(12, 11)
        .moveTo(-12, -11)
        .lineTo(12, -11);
}

#-------------------------------------------------------------------------------
#                                                                   update_piste
# this function updates piste - length of vector = distance in 15s
#   
# params :
# - element  : canvas object created by createChild()
# - FIXME ...
#
var update_piste = func(element, my_heading, my_alt, target_heading, target_alt, target_speed, pixel_range, radar_range)
{
    var vector_x = ((target_speed * pixel_range / radar_range) / 240) * math.sin((target_heading - my_heading) * D2R);
    var vector_y = ((target_speed * pixel_range / radar_range) / 240) * math.cos((target_heading - my_heading) * D2R);

    if((target_alt - 1000 ) < my_alt)
    {
        element._node.getNode("coord[12]", 1).setValue(-12);
    }
    else
    {
        element._node.getNode("coord[12]", 1).setValue(12);
    }
    if((target_alt + 1000 ) > my_alt)
    {
        element._node.getNode("coord[16]", 1).setValue(-12);
    }
    else
    {
        element._node.getNode("coord[16]", 1).setValue(12);
    }
    element._node.getNode("coord[8]", 1).setValue(vector_x);
    element._node.getNode("coord[9]", 1).setValue(-vector_y);
}

#-------------------------------------------------------------------------------
#                                                                update_piste_fl
# this function updates flight level piste label position
#   
# params :
# - element  : canvas object created by createChild()
# - FIXME ...
#
var update_piste_fl = func(element, my_heading, target_heading)
{
    var vector_x = -30 * math.sin((target_heading - my_heading) * D2R);
    var vector_y =  30 * math.cos((target_heading - my_heading) * D2R);

    element.setTranslation(vector_x, vector_y);
}

#===============================================================================
#                                                               CLASS SFD_CANVAS
var SFD_RADAR = {
    canvas_settings: {
        'name': 'radar',
        'size': [1024, 1024],
        'view': [1024, 1024],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [SFD_RADAR],
            canvas: canvas.new(SFD_RADAR.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 0);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

# CANVAS : CREATION DES ELEMENTS : PARTIE STATIQUE

        # creation du symbole de l'avion
        m.my_aircraft_symbol = m.my_group.createChild('path', 'my_aircraft_symbol');
        m.my_aircraft_symbol.setStrokeLineWidth(10)
            .set('stroke', 'rgba(150, 150, 150, 1)')
            .moveTo(resolution_x / 2, pixel_range + 40 + margin_top)
            .lineTo((resolution_x / 2) + 8, pixel_range + 62 + margin_top)
            .lineTo((resolution_x / 2) - 8, pixel_range + 62 + margin_top)
            .close();

        # creation des arcs 'range'
        m.arc_range1 = m.my_group.createChild('path', 'arc_range1');
        draw_arc(m.arc_range1, resolution_x / 2, pixel_range + 46 + margin_top, pixel_range / 4,     20, 160, 'rgba(100, 100, 100, 1)', 3);
        m.arc_range2 = m.my_group.createChild('path', 'arc_range2');
        draw_arc(m.arc_range2, resolution_x / 2, pixel_range + 46 + margin_top, pixel_range / 2,     20, 160, 'rgba(150, 150, 150, 1)', 3);
        m.arc_range3 = m.my_group.createChild('path', 'arc_range3');
        draw_arc(m.arc_range3, resolution_x / 2, pixel_range + 46 + margin_top, pixel_range * 3 / 4, 30, 150, 'rgba(100, 100, 100, 1)', 3);
        m.arc_range4 = m.my_group.createChild('path', 'arc_range4');
        draw_arc(m.arc_range4, resolution_x / 2, pixel_range + 46 + margin_top, pixel_range,         50, 130, 'rgba(220, 120, 220, 1)', 5);

        # creation du repere cap
        m.repere_cap = m.my_group.createChild('path', 'repere_cap');
        m.repere_cap.setStrokeLineWidth(5)
            .set('stroke', 'rgba(120, 120, 120, 1)')
            .moveTo(resolution_x / 2, 32 + margin_top)
            .lineTo(resolution_x / 2, 60 + margin_top);

        # creation du cadre cap
        m.cadre_cap = m.my_group.createChild('path', 'cadre_cap');
        m.cadre_cap.setStrokeLineWidth(5)
            .set('stroke', 'rgba(120, 120, 120, 1)')
            .rect((resolution_x / 2) - 50, margin_top - 10, 100, 40);

# CANVAS : CREATION DES ELEMENTS : PARTIE DYNAMIQUE

        # creation de l'arc "position dans 1'"
        #m.arc_one_min = m.my_group.createChild('path', 'arc_one_min');
        #draw_arc(m.arc_one_min, resolution_x / 2, pixel_range + 46 + margin_top, (my_speed * pixel_range / radar_range) / 60, 80, 100, 'rgba(40, 220, 40, 1)', 3);

        # creation du label 'range'
        m.radar_range = m.my_group.createChild('text', 'radar_range')
            .setTranslation(resolution_x / 2, pixel_range + 110 + margin_top)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(45)
            .setColor(220/255, 120/255, 220/255, 1)
            .setText(radar_range ~' Nm');

        # creation du label cap
        m.my_heading = m.my_group.createChild('text', 'my_heading')
            .setTranslation(resolution_x / 2, 8 + margin_top)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(38)
            .setColor(40/255, 220/255, 40/255, 1)
            .setText(0);

# CANVAS : CREATION DES ELEMENTS : PARTIE DYNAMIQUE : TARGETS

        m.targets = [];
        m.t_targets = [];
        for(var i = 0; i < max_piste; i += 1)
        {
            # creation des symboles de la cible
            m.target = m.my_group.createChild('group', 'target-'~ i);

            # creation de la piste
            m.piste_symbol = m.target.createChild('path', 'piste_symbol-'~ i);
            draw_piste(m.piste_symbol);

            # creation du label FL de la cible
            m.piste_fl = m.target.createChild('group', 'piste_fl-'~ i);
            m.t_piste_fl = m.piste_fl.createTransform();

            m.label_fl = m.piste_fl.createChild('text', 'label_fl-'~ i)
                .setTranslation(0, 0)
                .setAlignment('center-center')
                .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
                .setFontSize(28)
                .setColor(240/255, 240/255, 240/255, 1)
                .setText(0);

            m.target.setTranslation(0, 0);

            m.target.hide();
            append(m.targets, m.target);
            append(m.t_targets, m.t_piste_fl);
        }

        return m;
    },
    update: func()
    {
        var show_targets     = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/enabled") or 0;
        var displayed_on_sfd = getprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen") or '';

        if((show_targets == 1) and (displayed_on_sfd == 'RADAR'))
        {

# RECUPERATION DES DONNEES : NOTRE AVION
            var radar_range = getprop("/instrumentation/my_aircraft/sfd/controls/radar_range") or 5;
            var my_speed    = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
            var my_heading  = getprop("/orientation/heading-deg");
            var my_alt      = getprop("/instrumentation/altimeter/indicated-altitude-ft");

# RECUPERATION DES DONNEES : TARGETS

            # recuperation des informations sur les targets
            # les donnees brutes sont dans list_mp_obj
            # les donnees filtrees et transformees qui serviront a l affichage sont dans targets_datas
            var targets_are_mp  = getprop("/instrumentation/my_aircraft/hud_target_positions/controls/targets_are_mp") or 0;
            var list_mp_obj     = (targets_are_mp == 1)
                                ? props.globals.getNode("/ai/models").getChildren("multiplayer")
                                : props.globals.getNode("/ai/models").getChildren("aircraft");
            var list_obj = props.globals.getNode("/ai/models").getChildren("tanker");

            # ajout des objets target aux objets tanker
            for(var i = 0; i < size(list_mp_obj); i += 1) { append(list_obj, list_mp_obj[i]); }

            var targets_datas = [];
            for(var i = 0; i < size(list_obj); i += 1)
            {
                var target_bearing  = list_obj[i].getNode("radar/bearing-deg").getValue() or 0;
                var target_in_range = list_obj[i].getNode("radar/in-range").getValue() or 0;
                var is_valid        = list_obj[i].getNode("valid").getValue() or 0;
                var target_range    = list_obj[i].getNode("radar/range-nm").getValue() or 0;

                if(target_in_range
                    and is_valid
                    and math.abs(target_bearing - my_heading) < 80
                    and target_range < radar_range)
                {

                    var target_data = {};
                    target_data.target_heading = list_obj[i].getNode("orientation/true-heading-deg").getValue() or 0;
                    target_data.target_alt     = list_obj[i].getNode("position/altitude-ft").getValue() or 0;
                    target_data.target_speed   = list_obj[i].getNode("velocities/true-airspeed-kt").getValue() or 0;

                    target_data.piste_x        = -(target_range / radar_range * pixel_range * math.sin((my_heading - target_bearing) * D2R)) + (resolution_x / 2);
# TODO : pourquoi + 50 ?
                    target_data.piste_y        = -(target_range / radar_range * pixel_range * math.cos((my_heading - target_bearing) * D2R)) + margin_top + pixel_range + 50;

                    append(targets_datas, target_data);
                }
                if(size(targets_datas) >= max_piste)
                {
                    break;
                }
            }

# CANVAS : MISE A JOUR DES ELEMENTS : PARTIE DYNAMIQUE

            me.my_heading.setText(math.floor(my_heading));
            me.radar_range.setText(radar_range ~' Nm');

# CANVAS : MISE A JOUR DES ELEMENTS : PARTIE DYNAMIQUE : TARGETS

            for(var i = 0; i < max_piste; i += 1)
            {
                if(i < size(targets_datas))
                {
                    var td = targets_datas[i];
                    me.target       = me.targets[i];
                    me.piste_symbol = me.targets[i].getElementById('piste_symbol-'~ i);
                    me.t_piste_fl   = me.t_targets[i];
                    me.label_fl     = me.targets[i].getElementById('label_fl-'~ i);

                    update_piste(me.piste_symbol, my_heading, my_alt, td.target_heading, td.target_alt, td.target_speed, pixel_range, radar_range);
                    update_piste_fl(me.t_piste_fl, my_heading, td.target_heading);
                    me.label_fl.setText(math.floor(td.target_alt / 100));
                    me.target.setTranslation(td.piste_x, td.piste_y);
                    me.targets[i].show();
                }
                else
                {
                    me.targets[i].hide();
                }
            }
        }
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .2 : 4 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var sfd_radar = SFD_RADAR.new({'node': 'sfd_canvas_screen_radar'});
    sfd_radar.update();
});



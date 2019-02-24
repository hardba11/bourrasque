print("*** LOADING instrument_sfd_eicas - sfd_eicas.nas ... ***");

# namespace : instrument_sfd_eicas

#===============================================================================
#                                                                      CONSTANTS
var colors = {
    'light_grey': 'rgba(200, 200, 200, 1)',
    'blue':       'rgba(20, 20, 250, 1)',
    'red':        'rgba(200, 20, 20, 1)',
    'yellow':     'rgba(250, 250, 20, 1)'
};

var rayon_static = 115;
var rayon_gauge = 100;

# col1 gauges
var x_n1_engine0  = 280;
var y_n1_engine0  = 230;
var x_egt_engine0 = 280;
var y_egt_engine0 = 530;
var x_ff_engine0  = 280;
var y_ff_engine0  = 830;

# col2 gauges
var x_n1_engine1  = 720;
var y_n1_engine1  = 230;
var x_egt_engine1 = 720;
var y_egt_engine1 = 530;
var x_ff_engine1  = 720;
var y_ff_engine1  = 830;


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                            draw_circular_gauge
# this function creates a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element  : canvas object created by createChild()
# - center_x : center of the circle in px
# - center_y : center of the circle in px
# - rayon    : radius of the circle in px
# - angle    : angle of the arc in deg
# - color    : color of the arc (light_grey|blue|red)
# - width    : width of the arc in px
#
var draw_circular_gauge = func(element, center_x, center_y, rayon, angle, color, width)
{
    var coord_x_start = center_x + rayon;
    var coord_y_start = center_y;

    angle = (angle > 270) ? 270 : angle;

    var coord_x_end = -rayon + (rayon * math.cos(angle * D2R));
    var coord_y_end =           rayon * math.sin(angle * D2R);

    if(angle > 180)
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcLargeCW(rayon, rayon, 0, coord_x_end, coord_y_end);
    }
    else
    {
        element.setStrokeLineWidth(width)
            .set('stroke', colors[color])
            .moveTo(coord_x_start, coord_y_start)
            .arcSmallCW(rayon, rayon, 0, coord_x_end, coord_y_end);
    }
}

#-------------------------------------------------------------------------------
#                                                          update_circular_gauge
# this function updates the angle of a circular gauge
#   the drawed clockwise arc start on EAST
# params :
# - element  : canvas object created by createChild()
# - center_x : center of the circle in px
# - center_y : center of the circle in px
# - rayon    : radius of the circle in px
# - angle    : angle of the arc in deg
# - color    : color of the arc (light_grey|blue|red)
#
var update_circular_gauge = func(element, center_x, center_y, rayon, angle, color)
{
    var coord_x_start = center_x + rayon;
    var coord_y_start = center_y;

    angle = (angle > 270) ? 270 : angle;

    var coord_x_end = -rayon + (rayon * math.cos(angle * D2R));
    var coord_y_end =           rayon * math.sin(angle * D2R);

    if(angle > 180)
    {
        element._node.getNode("cmd[1]", 1).setValue(23); # 23=arcLargeCW
    }
    else
    {
        element._node.getNode("cmd[1]", 1).setValue(19); # 19=arcSmallCW
    }
    element._node.getNode("stroke", 1).setValue(colors[color]);
    element._node.getNode("coord[5]", 1).setValue(coord_x_end);
    element._node.getNode("coord[6]", 1).setValue(coord_y_end);
}

#-------------------------------------------------------------------------------
#                                                                 draw_rectangle
# this function creates a rectangle
# params :
# - element  : canvas object created by createChild()
# - start_x  : coords of the bottom left angle in px
# - start_y  : coords of the bottom left angle in px
# - color    : color of the rectangle (light_grey|blue|red)
# - width    : width of the rectangle in px
# - height   : height of the rectangle in px
#
var draw_rectangle = func(element, start_x, start_y, color, width, height)
{
    element.setStrokeLineWidth(3)
        .set('stroke', colors['light_grey'])
        .moveTo(start_x, start_y)
        .lineTo(start_x + width, start_y)
        .lineTo(start_x + width, start_y + height)
        .lineTo(start_x, start_y + height)
        .close();
}

#===============================================================================
#                                                                CLASS SFD_EICAS
var SFD_EICAS = {
    canvas_settings: {
        'name': 'sfd_eicas',
        'size': [1024, 1024],
        'view': [1024, 1024],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [SFD_EICAS],
            canvas: canvas.new(SFD_EICAS.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

# dispay N1 label
        m.n1_text = m.my_group.createChild('text', 'n1_text')
            .setTranslation((x_n1_engine0 + x_n1_engine1) / 2, y_n1_engine0 + 80)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(60)
            .setColor(1, 1, 1, 1)
            .setText('N1');

# dispay EGT label
        m.egt_text = m.my_group.createChild('text', 'egt_text')
            .setTranslation((x_egt_engine0 + x_egt_engine1) / 2, y_egt_engine0 + 80)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(60)
            .setColor(1, 1, 1, 1)
            .setText('EGT');

# dispay FF label
        m.ff_text = m.my_group.createChild('text', 'ff_text')
            .setTranslation((x_ff_engine0 + x_ff_engine1) / 2, y_ff_engine0 + 80)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(60)
            .setColor(1, 1, 1, 1)
            .setText('FF');
# dispay FF units
        m.ff_units = m.my_group.createChild('text', 'ff_units')
            .setTranslation((x_ff_engine0 + x_ff_engine1) / 2, y_ff_engine0 + 35)
            .setAlignment('center-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(35)
            .setColor(1, 1, 1, 1)
            .setText('kg/min');

# display ENGINE 0 N1

        # static arc
        m.static_n1_engine0_circle = m.my_group.createChild('path', 'static_n1_engine0_circle');
        draw_circular_gauge(m.static_n1_engine0_circle, x_n1_engine0, y_n1_engine0, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.n1_engine0_circle = m.my_group.createChild('path', 'n1_engine0_circle');
        draw_circular_gauge(m.n1_engine0_circle, x_n1_engine0, y_n1_engine0, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.n1_engine0_frame = m.my_group.createChild('path', 'n1_engine0_frame');
        draw_rectangle(m.n1_engine0_frame, x_n1_engine0 + 20, y_n1_engine0 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.n1_engine0_text = m.my_group.createChild('text', 'n1_engine0_text')
            .setTranslation(x_n1_engine0 + 170, y_n1_engine0 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

# display ENGINE 1 N1

        # static arc
        m.static_n1_engine1_circle = m.my_group.createChild('path', 'static_n1_engine1_circle');
        draw_circular_gauge(m.static_n1_engine1_circle, x_n1_engine1, y_n1_engine1, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.n1_engine1_circle = m.my_group.createChild('path', 'n1_engine1_circle');
        draw_circular_gauge(m.n1_engine1_circle, x_n1_engine1, y_n1_engine1, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.n1_engine1_frame = m.my_group.createChild('path', 'n1_engine1_frame');
        draw_rectangle(m.n1_engine1_frame, x_n1_engine1 + 20, y_n1_engine1 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.n1_engine1_text = m.my_group.createChild('text', 'n1_engine1_text')
            .setTranslation(x_n1_engine1 + 170, y_n1_engine1 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

# display ENGINE 0 EGT

        # static arc
        m.static_egt_engine0_circle = m.my_group.createChild('path', 'static_egt_engine0_circle');
        draw_circular_gauge(m.static_egt_engine0_circle, x_egt_engine0, y_egt_engine0, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.egt_engine0_circle = m.my_group.createChild('path', 'egt_engine0_circle');
        draw_circular_gauge(m.egt_engine0_circle, x_egt_engine0, y_egt_engine0, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.egt_engine0_frame = m.my_group.createChild('path', 'egt_engine0_frame');
        draw_rectangle(m.egt_engine0_frame, x_egt_engine0 + 20, y_egt_engine0 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.egt_engine0_text = m.my_group.createChild('text', 'egt_engine0_text')
            .setTranslation(x_egt_engine0 + 170, y_egt_engine0 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

# display ENGINE 1 EGT

        # static arc
        m.static_egt_engine1_circle = m.my_group.createChild('path', 'static_egt_engine1_circle');
        draw_circular_gauge(m.static_egt_engine1_circle, x_egt_engine1, y_egt_engine1, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.egt_engine1_circle = m.my_group.createChild('path', 'egt_engine1_circle');
        draw_circular_gauge(m.egt_engine1_circle, x_egt_engine1, y_egt_engine1, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.egt_engine1_frame = m.my_group.createChild('path', 'egt_engine1_frame');
        draw_rectangle(m.egt_engine0_frame, x_egt_engine1 + 20, y_egt_engine1 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.egt_engine1_text = m.my_group.createChild('text', 'egt_engine1_text')
            .setTranslation(x_egt_engine1 + 170, y_egt_engine1 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

# display ENGINE 0 FF

        # static arc
        m.static_ff_engine0_circle = m.my_group.createChild('path', 'static_ff_engine0_circle');
        draw_circular_gauge(m.static_ff_engine0_circle, x_ff_engine0, y_ff_engine0, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.ff_engine0_circle = m.my_group.createChild('path', 'ff_engine0_circle');
        draw_circular_gauge(m.ff_engine0_circle, x_ff_engine0, y_ff_engine0, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.ff_engine0_frame = m.my_group.createChild('path', 'ff_engine0_frame');
        draw_rectangle(m.ff_engine0_frame, x_ff_engine0 + 20, y_ff_engine0 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.ff_engine0_text = m.my_group.createChild('text', 'ff_engine0_text')
            .setTranslation(x_ff_engine0 + 170, y_ff_engine0 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

# display ENGINE 1 FF

        # static arc
        m.static_ff_engine1_circle = m.my_group.createChild('path', 'static_ff_engine1_circle');
        draw_circular_gauge(m.static_ff_engine1_circle, x_ff_engine1, y_ff_engine1, rayon_static, 270, 'light_grey', 3);

        # gauge (will be updated)
        m.ff_engine1_circle = m.my_group.createChild('path', 'ff_engine1_circle');
        draw_circular_gauge(m.ff_engine1_circle, x_ff_engine1, y_ff_engine1, rayon_gauge, 0, 'blue', 23);

        # rectangle
        m.ff_engine1_frame = m.my_group.createChild('path', 'ff_engine1_frame');
        draw_rectangle(m.ff_engine0_frame, x_ff_engine1 + 20, y_ff_engine1 - 100, colors['light_grey'], 160, 80);

        # value (will be updated)
        m.ff_engine1_text = m.my_group.createChild('text', 'ff_engine1_text')
            .setTranslation(x_ff_engine1 + 170, y_ff_engine1 - 60)
            .setAlignment('right-center')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(1, 1, 1, 1)
            .setText('');

        return m;
    },
    update: func()
    {
        var displayed_on_sfd = getprop("/instrumentation/my_aircraft/sfd/controls/display_sfd_screen") or 0;

        if(displayed_on_sfd == 'EICAS')
        {
            var n0      = getprop("/engines/engine[0]/n1-true") or 0;
            var n1      = getprop("/engines/engine[1]/n1-true") or 0;
            var egt0    = getprop("/engines/engine[0]/egt") or 0;
            var egt1    = getprop("/engines/engine[1]/egt") or 0;
            var ff0     = getprop("/engines/engine[0]/fuel-flow-gph") or 0;
            var ff1     = getprop("/engines/engine[1]/fuel-flow-gph") or 0;
            var reheat0 = getprop("/engines/engine[0]/reheat") or 0;
            var reheat1 = getprop("/engines/engine[1]/reheat") or 0;
            var jato    = getprop("/controls/jato/enabled") or 0;

            var angle_n0   = n0 * 270 / 109;
            var angle_n1   = n1 * 270 / 109;
            var angle_egt0 = egt0 / 4;
            var angle_egt1 = egt1 / 4;
            var angle_ff0  = (ff0 > 5) ? math.log10(ff0) * 60 : 1;
            var angle_ff1  = (ff1 > 5) ? math.log10(ff1) * 60 : 1;
            var color0     = (jato == 1) ? 'yellow' : ((reheat0 > .1) ? 'red' : 'blue');
            var color1     = (jato == 1) ? 'yellow' : ((reheat1 > .1) ? 'red' : 'blue');

            # gauge + value n1
            update_circular_gauge(me.n1_engine0_circle, x_n1_engine0, y_n1_engine0, rayon_gauge, angle_n0, color0);
            update_circular_gauge(me.n1_engine1_circle, x_n1_engine1, y_n1_engine1, rayon_gauge, angle_n1, color1);
            me.n1_engine0_text.setText(sprintf('%.2f', n0));
            me.n1_engine1_text.setText(sprintf('%.2f', n1));

            # gauge + value egt
            update_circular_gauge(me.egt_engine0_circle, x_egt_engine0, y_egt_engine0, rayon_gauge, angle_egt0, color0);
            update_circular_gauge(me.egt_engine1_circle, x_egt_engine1, y_egt_engine1, rayon_gauge, angle_egt1, color1);
            me.egt_engine0_text.setText(sprintf('%.2f', egt0));
            me.egt_engine1_text.setText(sprintf('%.2f', egt1));

            # gauge + value ff
            update_circular_gauge(me.ff_engine0_circle, x_ff_engine0, y_ff_engine0, rayon_gauge, angle_ff0, color0);
            update_circular_gauge(me.ff_engine1_circle, x_ff_engine1, y_ff_engine1, rayon_gauge, angle_ff1, color1);
            me.ff_engine0_text.setText(sprintf('%.1f', ff0 * 0.0508));
            me.ff_engine1_text.setText(sprintf('%.1f', ff1 * 0.0508));

        }
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 2 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var sfd_eicas = SFD_EICAS.new({'node': 'sfd_canvas_screen_eicas'});
    sfd_eicas.update();
});



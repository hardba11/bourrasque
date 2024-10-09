print("*** LOADING instrument_fuel_canvas - fuel_canvas.nas ... ***");

# namespace : instrument_fuel_canvas

#===============================================================================
#                                                                      CONSTANTS

var colors = {
    'light_grey': 'rgba(200, 200, 200, 1)',
    'blue':       'rgba(20, 20, 250, 1)',
    'red':        'rgba(250, 0, 0, 1)'
};


#===============================================================================
#                                                                      FUNCTIONS

#-------------------------------------------------------------------------------
#                                                                     draw_gauge
# this function creates a gauge
# params :
# - element  : canvas object created by createChild()
# - start_x  : start of the gauge in px
# - start_y  : start of the gauge in px
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the arc (light_grey|blue|red)
# - width    : width of the gauge in px
#
var draw_gauge = func(element, start_x, start_y, end_x, end_y, color, width)
{
        element.moveTo(start_x, start_y)
            .line(end_x, end_y)
            .setStrokeLineWidth(width)
            .set('stroke', colors[color]);
}

#-------------------------------------------------------------------------------
#                                                                   update_gauge
# this function updates the angle of a circular gauge
#   the drawed clockwise arc start on right
# params :
# - element  : canvas object created by createChild()
# - end_x    : relative end of the gauge in px
# - end_y    : relative end of the gauge in px
# - color    : color of the arc (light_grey|blue|red)
#
var update_gauge = func(element, end_x, end_y, color)
{
    element._node.getNode("stroke", 1).setValue(colors[color]);
    element._node.getNode("coord[2]", 1).setValue(end_x);
    element._node.getNode("coord[3]", 1).setValue(end_y);
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
    element.setStrokeLineWidth(2)
        .set('stroke', colors['light_grey'])
        .moveTo(start_x, start_y)
        .lineTo(start_x + width, start_y)
        .lineTo(start_x + width, start_y + height)
        .lineTo(start_x, start_y + height)
        .close();
}

#===============================================================================
#                                                              CLASS FUEL_CANVAS
var FUEL_CANVAS = {
    canvas_settings: {
        'name': 'fuel_canvas',
        'size': [512, 512],
        'view': [512, 512],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [FUEL_CANVAS],
            canvas: canvas.new(FUEL_CANVAS.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

        m.total_fuel_text = m.my_group.createChild('text', 'total_fuel_text')
            .setTranslation(150, 50)
            .setAlignment('right-baseline')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(1, 1, 1, 1)
            .setText('total:');
        m.total_fuel_value = m.my_group.createChild('text', 'total_fuel_value')
            .setTranslation(155, 50)
            .setAlignment('left-baseline')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(0, 1, 0, 1)
            .setText('TOTAL');
        m.time_remaining_text = m.my_group.createChild('text', 'time_remaining_text')
            .setTranslation(150, 100)
            .setAlignment('right-baseline')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(1, 1, 1, 1)
            .setText('rmng:');
        m.time_remaining_value = m.my_group.createChild('text', 'time_remaining_value')
            .setTranslation(155, 100)
            .setAlignment('left-baseline')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(0, 1, 0, 1)
            .setText('RMNG');
        m.bingo_text = m.my_group.createChild('text', 'bingo_text')
            .setTranslation(490, 150)
            .setAlignment('right-baseline')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(42)
            .setColor(1, 0, 1, 1)
            .setText('');

        m.left_fuel_value = m.my_group.createChild('text', 'left_fuel_value')
            .setTranslation(100, 480)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText('');
        m.center_fuel_value = m.my_group.createChild('text', 'center_fuel_value')
            .setTranslation(250, 480)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText('');
        m.right_fuel_value = m.my_group.createChild('text', 'right_fuel_value')
            .setTranslation(400, 480)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText('');

        m.left_frame = m.my_group.createChild('path', 'left_frame');
        draw_rectangle(m.left_frame, 80, 172, colors['light_grey'], 30, 258);
        m.left_gauge = m.my_group.createChild('path', 'left_gauge');
        draw_gauge(m.left_gauge, 95, 425, 0, -100, 'blue', 20);

        m.center_frame = m.my_group.createChild('path', 'center_frame');
        draw_rectangle(m.center_frame, 230, 172, colors['light_grey'], 30, 258);
        m.center_gauge = m.my_group.createChild('path', 'center_gauge');
        draw_gauge(m.center_gauge, 245, 425, 0, -100, 'blue', 20);

        m.right_frame = m.my_group.createChild('path', 'right_frame');
        draw_rectangle(m.right_frame, 380, 172, colors['light_grey'], 30, 258);
        m.right_gauge = m.my_group.createChild('path', 'right_gauge');
        draw_gauge(m.right_gauge, 395, 425, 0, -100, 'blue', 20);

        return m;
    },
    update: func()
    {
        var level_tot       = getprop("/consumables/fuel/total-fuel-m3") or 0;
        var level_left      = getprop("/instrumentation/my_aircraft/fuel/fuel-left-tank-m3") or 0;
        var level_center    = getprop("/instrumentation/my_aircraft/fuel/fuel-center-tank-m3") or 0;
        var level_right     = getprop("/instrumentation/my_aircraft/fuel/fuel-right-tank-m3") or 0;
        var h_remaining     = getprop("/instrumentation/my_aircraft/fuel/h-remaining") or 0;
        var m_remaining     = getprop("/instrumentation/my_aircraft/fuel/m-remaining") or 0;
        var s_remaining     = getprop("/instrumentation/my_aircraft/fuel/s-remaining") or 0;
        var nan_remaining   = getprop("/instrumentation/my_aircraft/fuel/nan-remaining") or 0;
        var bingo_text      = getprop("/instrumentation/my_aircraft/fuel/bingo-text") or "";
        var capacity_0      = getprop("/consumables/fuel/tank[0]/capacity-m3") or 0;
        var capacity_1      = getprop("/consumables/fuel/tank[1]/capacity-m3") or 0;
        var capacity_2      = getprop("/consumables/fuel/tank[2]/capacity-m3") or 0;
        var capacity_3      = getprop("/consumables/fuel/tank[3]/capacity-m3") or 0;

        var t_left   = level_left   / (capacity_1);
        var t_center = level_center / (capacity_0 + capacity_3);
        var t_right  = level_right  / (capacity_2);

        me.total_fuel_value.setText(sprintf('%.1f kg', level_tot * 805));
        if(nan_remaining)
        {
            me.time_remaining_value.setText('--:--:--');
        }
        else
        {
            me.time_remaining_value.setText(sprintf('%02d:%02d:%02d', h_remaining, m_remaining, s_remaining));
        }
        me.left_fuel_value.setText(sprintf('%.1f', level_left * 805));
        me.center_fuel_value.setText(sprintf('%.1f', level_center * 805));
        me.right_fuel_value.setText(sprintf('%.1f', level_right * 805));
        me.bingo_text.setText(sprintf('bingo : %s', bingo_text));

        var color_gauge = ((level_tot * 805) < 900) ? 'red' : 'blue';
        update_gauge(me.left_gauge, 0, -t_left * 250, color_gauge);
        update_gauge(me.center_gauge, 0, -t_center * 250, color_gauge);
        update_gauge(me.right_gauge, 0, -t_right * 250, color_gauge);

        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .5 : 10 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var fuel_canvas = FUEL_CANVAS.new({'node': 'fuel_canvas_screen'});
    fuel_canvas.update();
});



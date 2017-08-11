print("*** LOADING instrument_fuel_canvas - fuel_canvas.nas ... ***");

# namespace : instrument_fuel_canvas

#===============================================================================
#                                                                      CONSTANTS

var LBS2KG = 0.45359237;

var colors = {
    "light_grey": "rgba(200, 200, 200, 1)",
    "blue":       "rgba(20, 20, 250, 1)",
    "red":        "rgba(250, 0, 0, 1)"
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
            .set("stroke", colors[color]);
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
        .set("stroke", colors["light_grey"])
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
        "name": "fuel_canvas",
        "size": [512, 512],
        "view": [512, 512],
        "mipmapping": 1
    },
    new: func(placement)
    {
        var m = {
            parents: [FUEL_CANVAS],
            canvas: canvas.new(FUEL_CANVAS.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup("my_container");
        m.my_group = m.my_container.createChild("group");

        m.total_fuel_text = m.my_group.createChild("text", "total_fuel_text")
            .setTranslation(200, 90)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(42)
            .setColor(1, 1, 1, 1)
            .setText("");
        m.time_remaining_text = m.my_group.createChild("text", "time_remaining_text")
            .setTranslation(200, 140)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(42)
            .setColor(1, 1, 1, 1)
            .setText("");

        m.left_fuel_text = m.my_group.createChild("text", "left_fuel_text")
            .setTranslation(100, 480)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText("");
        m.center_fuel_text = m.my_group.createChild("text", "center_fuel_text")
            .setTranslation(250, 480)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText("");
        m.right_fuel_text = m.my_group.createChild("text", "right_fuel_text")
            .setTranslation(400, 480)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(32)
            .setColor(1, 1, 1, 1)
            .setText("");

        m.left_frame = m.my_group.createChild("path", "left_frame");
        draw_rectangle(m.left_frame, 80, 172, colors["light_grey"], 30, 258);
        m.left_gauge = m.my_group.createChild("path", "left_gauge");
        draw_gauge(m.left_gauge, 95, 425, 0, -100, "blue", 20);

        m.center_frame = m.my_group.createChild("path", "center_frame");
        draw_rectangle(m.center_frame, 230, 172, colors["light_grey"], 30, 258);
        m.center_gauge = m.my_group.createChild("path", "center_gauge");
        draw_gauge(m.center_gauge, 245, 425, 0, -100, "blue", 20);

        m.right_frame = m.my_group.createChild("path", "right_frame");
        draw_rectangle(m.right_frame, 380, 172, colors["light_grey"], 30, 258);
        m.right_gauge = m.my_group.createChild("path", "right_gauge");
        draw_gauge(m.right_gauge, 395, 425, 0, -100, "blue", 20);

        return m;
    },
    update: func()
    {
        var level_tot = getprop('/consumables/fuel/total-fuel-m3')    or 0;
        var level_0   = getprop('/consumables/fuel/tank[0]/level-m3') or 0;
        var level_1   = getprop('/consumables/fuel/tank[1]/level-m3') or 0;
        var level_2   = getprop('/consumables/fuel/tank[2]/level-m3') or 0;
        var level_3   = getprop('/consumables/fuel/tank[3]/level-m3') or 0;
        var level_4   = getprop('/consumables/fuel/tank[4]/level-m3') or 0;
        var level_5   = getprop('/consumables/fuel/tank[5]/level-m3') or 0;
        var level_6   = getprop('/consumables/fuel/tank[6]/level-m3') or 0;
        var level_7   = getprop('/consumables/fuel/tank[7]/level-m3') or 0;

        var level_left   = level_2 + level_4 + level_6;
        var level_center = level_0 + level_1;
        var level_right  = level_3 + level_5 + level_7;
        setprop('/instrumentation/my_aircraft/fuel/total-fuel-m3',       level_tot);
        setprop('/instrumentation/my_aircraft/fuel/fuel-left-tank-m3',   level_left);
        setprop('/instrumentation/my_aircraft/fuel/fuel-center-tank-m3', level_center);
        setprop('/instrumentation/my_aircraft/fuel/fuel-right-tank-m3',  level_right);

        var ff0     = getprop('/engines/engine[0]/fuel-flow-gph') or 0;
        var ff1     = getprop('/engines/engine[1]/fuel-flow-gph') or 0;
        var ff0_kg_s  = ff0 * 0.0508 / 60;
        var ff1_kg_s  = ff1 * 0.0508 / 60;
        var remaining_s = (level_tot * 805) / (ff0_kg_s + ff1_kg_s + 0.0000001);

        var h_remaining = math.floor(remaining_s / 3600);
        var m_remaining = math.floor(math.mod((remaining_s / 60), 60));
        var s_remaining = math.mod(remaining_s, 60);

        me.total_fuel_text.setText(sprintf("total: %.1f kg", level_tot * 805));
        me.time_remaining_text.setText(sprintf("rmng: %02d:%02d:%02d", h_remaining, m_remaining, s_remaining));
        me.left_fuel_text.setText(sprintf("%.1f", level_left * 805));
        me.center_fuel_text.setText(sprintf("%.1f", level_center * 805));
        me.right_fuel_text.setText(sprintf("%.1f", level_right * 805));

        var capacity_0   = getprop('/consumables/fuel/tank[0]/capacity-m3') or 0;
        var capacity_1   = getprop('/consumables/fuel/tank[1]/capacity-m3') or 0;
        var capacity_2   = getprop('/consumables/fuel/tank[2]/capacity-m3') or 0;
        var capacity_3   = getprop('/consumables/fuel/tank[3]/capacity-m3') or 0;
        var capacity_4   = getprop('/consumables/fuel/tank[4]/capacity-m3') or 0;
        var capacity_5   = getprop('/consumables/fuel/tank[5]/capacity-m3') or 0;
        var capacity_6   = getprop('/consumables/fuel/tank[6]/capacity-m3') or 0;
        var capacity_7   = getprop('/consumables/fuel/tank[7]/capacity-m3') or 0;
        var t_left   = level_left / (capacity_2 + capacity_4 + capacity_6);
        var t_center = level_center / (capacity_0 + capacity_1);
        var t_right  = level_right / (capacity_3 + capacity_5 + capacity_7);

        var color_gauge = ((level_tot * 805) < 3000) ? "red" : "blue";
        update_gauge(me.left_gauge, 0, -t_left * 250, color_gauge);
        update_gauge(me.center_gauge, 0, -t_center * 250, color_gauge);
        update_gauge(me.right_gauge, 0, -t_right * 250, color_gauge);

        settimer(func() { me.update(); }, 1);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var fuel_canvas = FUEL_CANVAS.new({"node": "fuel_canvas_screen"});
    fuel_canvas.update();
});






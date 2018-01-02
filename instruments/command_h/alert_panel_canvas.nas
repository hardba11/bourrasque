print("*** LOADING instrument_command_h_canvas - alert_panel_canvas.nas ... ***");

# namespace : instrument_command_h_canvas

#===============================================================================
#                                                               CLASS WARN_PANEL
var WARN_PANEL = {
    canvas_settings: {
        "name": "warn_panel",
        "size": [1024, 1024],
        "view": [1024, 1024],
        "mipmapping": 1
    },
    new: func(placement)
    {
        var m = {
            parents: [WARN_PANEL],
            canvas: canvas.new(WARN_PANEL.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup("my_container");
        m.my_group = m.my_container.createChild("group");

        m.eng1 = m.my_group.createChild("text", "ENG1")
            .setTranslation(64, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("ENG1");
        m.eng2 = m.my_group.createChild("text", "ENG2")
            .setTranslation(64, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("ENG2");

        m.hydr = m.my_group.createChild("text", "HYDR")
            .setTranslation(192, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("HYDR");
        m.fuel = m.my_group.createChild("text", "FUEL")
            .setTranslation(192, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("FUEL");

        m.gear = m.my_group.createChild("text", "GEAR")
            .setTranslation(320, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("GEAR");
        m.hook = m.my_group.createChild("text", "HOOK")
            .setTranslation(320, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("HOOK");

        m.spbk = m.my_group.createChild("text", "SPBK")
            .setTranslation(448, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("SPBK");
        m.pkbk = m.my_group.createChild("text", "PKBK")
            .setTranslation(448, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("PKBK");

        m.cnpy = m.my_group.createChild("text", "CNPY")
            .setTranslation(576, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("CNPY");
        m.epu = m.my_group.createChild("text", "EPU")
            .setTranslation(576, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("EPU");

        m.rht1 = m.my_group.createChild("text", "RHT1")
            .setTranslation(704, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("RHT1");
        m.rht2 = m.my_group.createChild("text", "RHT2")
            .setTranslation(704, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("RHT2");

        m.bngo = m.my_group.createChild("text", "BNGO")
            .setTranslation(832, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("BNGO");
        m.aarf = m.my_group.createChild("text", "AARF")
            .setTranslation(832, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("AARF");

        m.lbl81 = m.my_group.createChild("text", "lbl81")
            .setTranslation(960, 50)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("");
        m.lbl82 = m.my_group.createChild("text", "lbl82")
            .setTranslation(960, 120)
            .setAlignment("center-bottom")
            .setFont("LiberationFonts/LiberationSansNarrow-Bold.ttf")
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText("");

        return m;
    },
    update: func()
    {
        var alpha = 0;

        var engine0_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/status') or 0;
        var engine0_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/warn_blink') or 0;
        var engine0_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine0/alert_blink') or 0;
        if((engine0_warn_blink == 1) or (engine0_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(engine0_status == 0)     { me.eng1.setColor(0, 0, 0, alpha); }
        elsif(engine0_status == 1)  { me.eng1.setColor(1, 1, 0, alpha); }
        elsif(engine0_status == 2)  { me.eng1.setColor(1, 0, 0, alpha); }

        var engine1_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/status') or 0;
        var engine1_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/warn_blink') or 0;
        var engine1_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/engine1/alert_blink') or 0;
        if((engine1_warn_blink == 1) or (engine1_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(engine1_status == 0)     { me.eng2.setColor(0, 0, 0, alpha); }
        elsif(engine1_status == 1)  { me.eng2.setColor(1, 1, 0, alpha); }
        elsif(engine1_status == 2)  { me.eng2.setColor(1, 0, 0, alpha); }

        var hydraulics_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/status') or 0;
        var hydraulics_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/warn_blink') or 0;
        var hydraulics_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/hydraulics/alert_blink') or 0;
        if((hydraulics_warn_blink == 1) or (hydraulics_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(hydraulics_status == 0)     { me.hydr.setColor(0, 0, 0, alpha); }
        elsif(hydraulics_status == 1)  { me.hydr.setColor(1, 1, 0, alpha); }
        elsif(hydraulics_status == 2)  { me.hydr.setColor(1, 0, 0, alpha); }

        var fuel_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/status') or 0;
        var fuel_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/warn_blink') or 0;
        var fuel_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/fuel/alert_blink') or 0;
        if((fuel_warn_blink == 1) or (fuel_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(fuel_status == 0)     { me.fuel.setColor(0, 0, 0, alpha); }
        elsif(fuel_status == 1)  { me.fuel.setColor(1, 1, 0, alpha); }
        elsif(fuel_status == 2)  { me.fuel.setColor(1, 0, 0, alpha); }

        var gear_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/status') or 0;
        var gear_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/warn_blink') or 0;
        var gear_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/gear/alert_blink') or 0;
        if((gear_warn_blink == 1) or (gear_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(gear_status == 0)     { me.gear.setColor(0, 0, 0, alpha); }
        elsif(gear_status == 1)  { me.gear.setColor(1, 1, 0, alpha); }
        elsif(gear_status == 2)  { me.gear.setColor(1, 0, 0, alpha); }

        var hook_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/status') or 0;
        var hook_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/warn_blink') or 0;
        var hook_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/hook/alert_blink') or 0;
        if((hook_warn_blink == 1) or (hook_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(hook_status == 0)     { me.hook.setColor(0, 0, 0, alpha); }
        elsif(hook_status == 1)  { me.hook.setColor(1, 1, 0, alpha); }
        elsif(hook_status == 2)  { me.hook.setColor(1, 0, 0, alpha); }

        var speedbrake_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/status') or 0;
        var speedbrake_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/warn_blink') or 0;
        var speedbrake_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/speedbrake/alert_blink') or 0;
        if((speedbrake_warn_blink == 1) or (speedbrake_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(speedbrake_status == 0)     { me.spbk.setColor(0, 0, 0, alpha); }
        elsif(speedbrake_status == 1)  { me.spbk.setColor(1, 1, 0, alpha); }
        elsif(speedbrake_status == 2)  { me.spbk.setColor(1, 0, 0, alpha); }

        var parkbrake_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/status') or 0;
        var parkbrake_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/warn_blink') or 0;
        var parkbrake_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/parkbrake/alert_blink') or 0;
        if((parkbrake_warn_blink == 1) or (parkbrake_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(parkbrake_status == 0)     { me.pkbk.setColor(0, 0, 0, alpha); }
        elsif(parkbrake_status == 1)  { me.pkbk.setColor(1, 1, 0, alpha); }
        elsif(parkbrake_status == 2)  { me.pkbk.setColor(1, 0, 0, alpha); }

        var canopy_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/status') or 0;
        var canopy_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/warn_blink') or 0;
        var canopy_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/canopy/alert_blink') or 0;
        if((canopy_warn_blink == 1) or (canopy_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(canopy_status == 0)     { me.cnpy.setColor(0, 0, 0, alpha); }
        elsif(canopy_status == 1)  { me.cnpy.setColor(1, 1, 0, alpha); }
        elsif(canopy_status == 2)  { me.cnpy.setColor(1, 0, 0, alpha); }

        var epu_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/status') or 0;
        var epu_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/warn_blink') or 0;
        var epu_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/epu/alert_blink') or 0;
        if((epu_warn_blink == 1) or (epu_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(epu_status == 0)     { me.epu.setColor(0, 0, 0, alpha); }
        elsif(epu_status == 1)  { me.epu.setColor(1, 1, 0, alpha); }
        elsif(epu_status == 2)  { me.epu.setColor(1, 0, 0, alpha); }

        var reheat0_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/status') or 0;
        var reheat0_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/warn_blink') or 0;
        var reheat0_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat0/alert_blink') or 0;
        if((reheat0_warn_blink == 1) or (reheat0_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(reheat0_status == 0)     { me.rht1.setColor(0, 0, 0, alpha); }
        elsif(reheat0_status == 1)  { me.rht1.setColor(1, 1, 0, alpha); }
        elsif(reheat0_status == 2)  { me.rht1.setColor(1, 0, 0, alpha); }

        var reheat1_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/status') or 0;
        var reheat1_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/warn_blink') or 0;
        var reheat1_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/reheat1/alert_blink') or 0;
        if((reheat1_warn_blink == 1) or (reheat1_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(reheat1_status == 0)     { me.rht2.setColor(0, 0, 0, alpha); }
        elsif(reheat1_status == 1)  { me.rht2.setColor(1, 1, 0, alpha); }
        elsif(reheat1_status == 2)  { me.rht2.setColor(1, 0, 0, alpha); }

        var air_refuel_status      = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/status') or 0;
        var air_refuel_warn_blink  = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/warn_blink') or 0;
        var air_refuel_alert_blink = getprop('/instrumentation/my_aircraft/command_h/panel_status/air_refuel/alert_blink') or 0;
        if((air_refuel_warn_blink == 1) or (air_refuel_alert_blink == 1)) { alpha = getprop('/instrumentation/my_aircraft/command_h/blink_alert') or 0; }
        else { alpha = 1; }
        if(air_refuel_status == 0)     { me.aarf.setColor(0, 0, 0, alpha); }
        elsif(air_refuel_status == 1)  { me.aarf.setColor(1, 1, 0, alpha); }
        elsif(air_refuel_status == 2)  { me.aarf.setColor(1, 0, 0, alpha); }

        settimer(func() { me.update(); }, .1);

    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once

    var warn_canvas = WARN_PANEL.new({"node": "alert_panel_canvas_screen"});
    warn_canvas.update();

});








































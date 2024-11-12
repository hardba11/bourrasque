print("*** LOADING instrument_command_h_canvas - alert_panel_canvas.nas ... ***");

# namespace : instrument_command_h_canvas

var OK      = 0;
var INFO    = 1;
var NOTICE  = 2;
var CAUTION = 3;
var WARN    = 4;
var ALERT   = 5;

#===============================================================================
#                                                               CLASS WARN_PANEL
var WARN_PANEL = {
    canvas_settings: {
        'name': 'warn_panel',
        'size': [1024, 1024],
        'view': [1024, 1024],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [WARN_PANEL],
            canvas: canvas.new(WARN_PANEL.canvas_settings),
        };
        m.canvas.addPlacement(placement);
        m.canvas.setColorBackground(0, 0, 0, 1);
        m.my_container = m.canvas.createGroup('my_container');
        m.my_group = m.my_container.createChild('group');

        m.eng1 = m.my_group.createChild('text', 'ENG1')
            .setTranslation(64, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('ENG1');
        m.eng2 = m.my_group.createChild('text', 'ENG2')
            .setTranslation(64, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('ENG2');

        m.hydr = m.my_group.createChild('text', 'HYDR')
            .setTranslation(192, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('HYDR');
        m.avcs = m.my_group.createChild('text', 'AVCS')
            .setTranslation(192, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('AVCS');

        m.gear = m.my_group.createChild('text', 'GEAR')
            .setTranslation(320, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('GEAR');
        m.hook = m.my_group.createChild('text', 'HOOK')
            .setTranslation(320, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('HOOK');

        m.spbk = m.my_group.createChild('text', 'SPBK')
            .setTranslation(448, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('SPBK');
        m.pkbk = m.my_group.createChild('text', 'PKBK')
            .setTranslation(448, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('PKBK');

        m.cnpy = m.my_group.createChild('text', 'CNPY')
            .setTranslation(576, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('CNPY');
        m.epu = m.my_group.createChild('text', 'EPU')
            .setTranslation(576, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('EPU');

        m.rht1 = m.my_group.createChild('text', 'RHT1')
            .setTranslation(704, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('RHT1');
        m.rht2 = m.my_group.createChild('text', 'RHT2')
            .setTranslation(704, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('RHT2');

        m.bngo = m.my_group.createChild('text', 'BNGO')
            .setTranslation(832, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('BNGO');
        m.fuel = m.my_group.createChild('text', 'FUEL')
            .setTranslation(832, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('FUEL');

        m.aarf = m.my_group.createChild('text', 'AARF')
            .setTranslation(960, 50)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('AARF');
        m.trim = m.my_group.createChild('text', 'TRIM')
            .setTranslation(960, 120)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('TRIM');
        m.ap = m.my_group.createChild('text', 'AP')
            .setTranslation(960, 200)
            .setAlignment('center-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(36)
            .setColor(0, 0, 0, 1)
            .setText('A/P');

        return m;
    },
    update: func()
    {
        var blinking = getprop("/instrumentation/my_aircraft/command_h/blink_alert") or 0;

        var engine0_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/engine0_status") or 0;
        if(engine0_status == OK)         { me.eng1.setColor(0, 0, 0, 0); }
        elsif(engine0_status == INFO)    { me.eng1.setColor(0, 1, 0, 1); }
        elsif(engine0_status == NOTICE)  { me.eng1.setColor(1, 1, 0, 1); }
        elsif(engine0_status == CAUTION) { me.eng1.setColor(1, 1, 0, blinking); }
        elsif(engine0_status == WARN)    { me.eng1.setColor(1, 0, 0, 1); }
        elsif(engine0_status == ALERT)   { me.eng1.setColor(1, 0, 0, blinking); }

        var engine1_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/engine1_status") or 0;
        if(engine1_status == OK)         { me.eng2.setColor(0, 0, 0, 0); }
        elsif(engine1_status == INFO)    { me.eng2.setColor(0, 1, 0, 1); }
        elsif(engine1_status == NOTICE)  { me.eng2.setColor(1, 1, 0, 1); }
        elsif(engine1_status == CAUTION) { me.eng2.setColor(1, 1, 0, blinking); }
        elsif(engine1_status == WARN)    { me.eng2.setColor(1, 0, 0, 1); }
        elsif(engine1_status == ALERT)   { me.eng2.setColor(1, 0, 0, blinking); }

        var hydraulics_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/hydraulics_status") or 0;
        if(hydraulics_status == OK)         { me.hydr.setColor(0, 0, 0, 0); }
        elsif(hydraulics_status == INFO)    { me.hydr.setColor(0, 1, 0, 1); }
        elsif(hydraulics_status == NOTICE)  { me.hydr.setColor(1, 1, 0, 1); }
        elsif(hydraulics_status == CAUTION) { me.hydr.setColor(1, 1, 0, blinking); }
        elsif(hydraulics_status == WARN)    { me.hydr.setColor(1, 0, 0, 1); }
        elsif(hydraulics_status == ALERT)   { me.hydr.setColor(1, 0, 0, blinking); }

        var fuel_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/fuel_status") or 0;
        if(fuel_status == OK)         { me.fuel.setColor(0, 0, 0, 0); }
        elsif(fuel_status == INFO)    { me.fuel.setColor(0, 1, 0, 1); }
        elsif(fuel_status == NOTICE)  { me.fuel.setColor(1, 1, 0, 1); }
        elsif(fuel_status == CAUTION) { me.fuel.setColor(1, 1, 0, blinking); }
        elsif(fuel_status == WARN)    { me.fuel.setColor(1, 0, 0, 1); }
        elsif(fuel_status == ALERT)   { me.fuel.setColor(1, 0, 0, blinking); }

        var gear_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/gear_status") or 0;
        if(gear_status == OK)         { me.gear.setColor(0, 0, 0, 0); }
        elsif(gear_status == INFO)    { me.gear.setColor(0, 1, 0, 1); }
        elsif(gear_status == NOTICE)  { me.gear.setColor(1, 1, 0, 1); }
        elsif(gear_status == CAUTION) { me.gear.setColor(1, 1, 0, blinking); }
        elsif(gear_status == WARN)    { me.gear.setColor(1, 0, 0, 1); }
        elsif(gear_status == ALERT)   { me.gear.setColor(1, 0, 0, blinking); }

        var hook_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/hook_status") or 0;
        if(hook_status == OK)         { me.hook.setColor(0, 0, 0, 0); }
        elsif(hook_status == INFO)    { me.hook.setColor(0, 1, 0, 1); }
        elsif(hook_status == NOTICE)  { me.hook.setColor(1, 1, 0, 1); }
        elsif(hook_status == CAUTION) { me.hook.setColor(1, 1, 0, blinking); }
        elsif(hook_status == WARN)    { me.hook.setColor(1, 0, 0, 1); }
        elsif(hook_status == ALERT)   { me.hook.setColor(1, 0, 0, blinking); }

        var speedbrake_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/speedbrake_status") or 0;
        if(speedbrake_status == OK)         { me.spbk.setColor(0, 0, 0, 0); }
        elsif(speedbrake_status == INFO)    { me.spbk.setColor(0, 1, 0, 1); }
        elsif(speedbrake_status == NOTICE)  { me.spbk.setColor(1, 1, 0, 1); }
        elsif(speedbrake_status == CAUTION) { me.spbk.setColor(1, 1, 0, blinking); }
        elsif(speedbrake_status == WARN)    { me.spbk.setColor(1, 0, 0, 1); }
        elsif(speedbrake_status == ALERT)   { me.spbk.setColor(1, 0, 0, blinking); }

        var parkbrake_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/parkbrake_status") or 0;
        if(parkbrake_status == OK)         { me.pkbk.setColor(0, 0, 0, 0); }
        elsif(parkbrake_status == INFO)    { me.pkbk.setColor(0, 1, 0, 1); }
        elsif(parkbrake_status == NOTICE)  { me.pkbk.setColor(1, 1, 0, 1); }
        elsif(parkbrake_status == CAUTION) { me.pkbk.setColor(1, 1, 0, blinking); }
        elsif(parkbrake_status == WARN)    { me.pkbk.setColor(1, 0, 0, 1); }
        elsif(parkbrake_status == ALERT)   { me.pkbk.setColor(1, 0, 0, blinking); }

        var canopy_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/canopy_status") or 0;
        if(canopy_status == OK)            { me.cnpy.setColor(0, 0, 0, 0); }
        elsif(canopy_status == INFO)       { me.cnpy.setColor(0, 1, 0, 1); }
        elsif(canopy_status == NOTICE)     { me.cnpy.setColor(1, 1, 0, 1); }
        elsif(canopy_status == CAUTION)    { me.cnpy.setColor(1, 1, 0, blinking); }
        elsif(canopy_status == WARN)       { me.cnpy.setColor(1, 0, 0, 1); }
        elsif(canopy_status == ALERT)      { me.cnpy.setColor(1, 0, 0, blinking); }

        var epu_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/epu_status") or 0;
        if(epu_status == OK)            { me.epu.setColor(0, 0, 0, 0); }
        elsif(epu_status == INFO)       { me.epu.setColor(0, 1, 0, 1); }
        elsif(epu_status == NOTICE)     { me.epu.setColor(1, 1, 0, 1); }
        elsif(epu_status == CAUTION)    { me.epu.setColor(1, 1, 0, blinking); }
        elsif(epu_status == WARN)       { me.epu.setColor(1, 0, 0, 1); }
        elsif(epu_status == ALERT)      { me.epu.setColor(1, 0, 0, blinking); }

        var reheat0_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/reheat0_status") or 0;
        if(reheat0_status == OK)         { me.rht1.setColor(0, 0, 0, 0); }
        elsif(reheat0_status == INFO)    { me.rht1.setColor(0, 1, 0, 1); }
        elsif(reheat0_status == NOTICE)  { me.rht1.setColor(1, 1, 0, 1); }
        elsif(reheat0_status == CAUTION) { me.rht1.setColor(1, 1, 0, blinking); }
        elsif(reheat0_status == WARN)    { me.rht1.setColor(1, 0, 0, 1); }
        elsif(reheat0_status == ALERT)   { me.rht1.setColor(1, 0, 0, blinking); }

        var reheat1_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/reheat1_status") or 0;
        if(reheat1_status == OK)         { me.rht2.setColor(0, 0, 0, 0); }
        elsif(reheat1_status == INFO)    { me.rht2.setColor(0, 1, 0, 1); }
        elsif(reheat1_status == NOTICE)  { me.rht2.setColor(1, 1, 0, 1); }
        elsif(reheat1_status == CAUTION) { me.rht2.setColor(1, 1, 0, blinking); }
        elsif(reheat1_status == WARN)    { me.rht2.setColor(1, 0, 0, 1); }
        elsif(reheat1_status == ALERT)   { me.rht2.setColor(1, 0, 0, blinking); }

        var bingo_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/bingo_status") or 0;
        if(bingo_status == OK)         { me.bngo.setColor(0, 0, 0, 0); }
        elsif(bingo_status == INFO)    { me.bngo.setColor(0, 1, 0, 1); }
        elsif(bingo_status == NOTICE)  { me.bngo.setColor(1, 1, 0, 1); }
        elsif(bingo_status == CAUTION) { me.bngo.setColor(1, 1, 0, blinking); }
        elsif(bingo_status == WARN)    { me.bngo.setColor(1, 0, 0, 1); }
        elsif(bingo_status == ALERT)   { me.bngo.setColor(1, 0, 0, blinking); }

        var air_refuel_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/air_refuel_status") or 0;
        if(air_refuel_status == OK)         { me.aarf.setColor(0, 0, 0, 0); }
        elsif(air_refuel_status == INFO)    { me.aarf.setColor(0, 1, 0, 1); }
        elsif(air_refuel_status == NOTICE)  { me.aarf.setColor(1, 1, 0, 1); }
        elsif(air_refuel_status == CAUTION) { me.aarf.setColor(1, 1, 0, blinking); }
        elsif(air_refuel_status == WARN)    { me.aarf.setColor(1, 0, 0, 1); }
        elsif(air_refuel_status == ALERT)   { me.aarf.setColor(1, 0, 0, blinking); }

        var avionics_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/avionics_status") or 0;
        if(avionics_status == OK)         { me.avcs.setColor(0, 0, 0, 0); }
        elsif(avionics_status == INFO)    { me.avcs.setColor(0, 1, 0, 1); }
        elsif(avionics_status == NOTICE)  { me.avcs.setColor(1, 1, 0, 1); }
        elsif(avionics_status == CAUTION) { me.avcs.setColor(1, 1, 0, blinking); }
        elsif(avionics_status == WARN)    { me.avcs.setColor(1, 0, 0, 1); }
        elsif(avionics_status == ALERT)   { me.avcs.setColor(1, 0, 0, blinking); }

        var autotrim_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/autotrim_status") or 0;
        if(autotrim_status == OK)         { me.trim.setColor(0, 0, 0, 0); }
        elsif(autotrim_status == INFO)    { me.trim.setColor(0, 1, 0, 1); }
        elsif(autotrim_status == NOTICE)  { me.trim.setColor(1, 1, 0, 1); }
        elsif(autotrim_status == CAUTION) { me.trim.setColor(1, 1, 0, blinking); }
        elsif(autotrim_status == WARN)    { me.trim.setColor(1, 0, 0, 1); }
        elsif(autotrim_status == ALERT)   { me.trim.setColor(1, 0, 0, blinking); }

        var ap_status = getprop("/instrumentation/my_aircraft/command_h/panel_status/ap_status") or 0;
        if(ap_status == OK)         { me.ap.setColor(0, 0, 0, 0); }
        elsif(ap_status == INFO)    { me.ap.setColor(0, 1, 0, 1); }
        elsif(ap_status == NOTICE)  { me.ap.setColor(1, 1, 0, 1); }
        elsif(ap_status == CAUTION) { me.ap.setColor(1, 1, 0, blinking); }
        elsif(ap_status == WARN)    { me.ap.setColor(1, 0, 0, 1); }
        elsif(ap_status == ALERT)   { me.ap.setColor(1, 0, 0, blinking); }

        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? .1 : 5 * time_speed;
        settimer(func() { me.update(); }, loop_speed);
    }
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once

    var warn_canvas = WARN_PANEL.new({'node': 'alert_panel_canvas_screen'});
    warn_canvas.update();

});








































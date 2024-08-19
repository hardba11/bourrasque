print("*** LOADING instrument_nd - nd.nas ... ***");

# namespace : instrument_nd

##
# configure aircraft specific cockpit/ND switches here
# these are to be found in the property branch you specify
# via the NavDisplay.new() call
# the backend code in navdisplay.mfd should NEVER contain any aircraft-specific
# properties, or it will break other aircraft using different properties
# instead, make up an identifier (hash key) and map it to the property used
# in your aircraft, relative to your ND root in the backend code, only ever
# refer to the handle/key instead via the me.get_switch('toggle_range') method
# which would internally look up the matching aircraft property, e.g. '/instrumentation/nd/inputs/range-nm'
#
# note: it is NOT sufficient to just add new switches here, the backend code in navdisplay.mfd also
# needs to know what to do with them !
# refer to incomplete symbol implementations to learn how they work (e.g. WXR, STA)

var myCockpit_switches = {
    # symbolic alias : relative property (as used in bindings), initial value, type
    'toggle_range':         { path: '/range-nm',     value: 40,    type: 'INT'   },
    'toggle_airports':      { path: '/arpt',         value: 1,     type: 'BOOL'  },
    'toggle_stations':      { path: '/sta',          value: 1,     type: 'BOOL'  },
    'toggle_waypoints':     { path: '/wpt',          value: 0,     type: 'BOOL'  },
    'toggle_data':          { path: '/data',         value: 1,     type: 'BOOL'  },
    'toggle_centered':      { path: '/nd-centered',  value: 1,     type: 'BOOL'  },
    'toggle_lh_vor_adf':    { path: '/lh-vor-adf',   value: 1,     type: 'INT'   }, # -1=ADF, 0=OFF, 1=VOR
    'toggle_rh_vor_adf':    { path: '/rh-vor-adf',   value: 1,     type: 'INT'   }, # -1=ADF, 0=OFF, 1=VOR
    'toggle_display_mode':  { path: '/display-mode', value: 'VOR', type: 'STRING'}, # APP, MAP, PLAN, VOR
    'toggle_display_type':  { path: '/display-type', value: 'LCD', type: 'STRING'}, # CRT, LCD
    'toggle_true_north':    { path: '/true-north',   value: 1,     type: 'BOOL'  },
    'toggle_rangearc':      { path: '/rangearc',     value: 1,     type: 'BOOL'  },
    'toggle_track_heading': { path: '/hdg-trk',      value: 0,     type: 'BOOL'  },
    'toggle_tacan':         { path: '/toggle_tacan', value: 0,     type: 'BOOL'  },
};

var _list = setlistener("sim/signals/fdm-initialized", func() {

    # get a handle to the NavDisplay in canvas namespace (for now), see $FG_ROOT/Nasal/canvas/map/navdisplay.mfd
    var ND = canvas.NavDisplay;

    # set up a new ND instance, under 'instrumentation/my_aircraft/nd' and use the
    # myCockpit_switches hash to map control properties
    var NDCpt = ND.new("instrumentation/my_aircraft/nd/inputs", myCockpit_switches);

    nd_display = canvas.new({
        'name':       'ND',
        'size':       [1024, 1024],
        'view':       [1024, 1024],
        'mipmapping': 1
    });

    nd_display.addPlacement({'node': 'nd.screen'});
    var group = nd_display.createGroup();
    NDCpt.newMFD(group, nd_display);
    NDCpt.update();

    removelistener(_list);
});

var nd = func()
{
    # simplier to animate with integer than string
    var nd_display_mode = ['APP', 'VOR', 'MAP', 'PLAN'];
    setprop("instrumentation/my_aircraft/nd/inputs/display-mode", nd_display_mode[getprop("instrumentation/my_aircraft/nd/inputs/display-mode-num")]);

    # coupling tacan with right adf (unused)
    var rh = getprop("instrumentation/my_aircraft/nd/inputs/rh-vor-adf") or 0;
    setprop("instrumentation/my_aircraft/nd/inputs/toggle_tacan", ((rh == -1) ? 1 : 0));
}

var event_click_info = func()
{
    var infos_displayed = getprop("instrumentation/my_aircraft/nd/inputs/arpt") or 0;
    infos_displayed = (infos_displayed) ? 0 : 1;

    setprop("instrumentation/my_aircraft/nd/inputs/arpt", infos_displayed);
    setprop("instrumentation/my_aircraft/nd/inputs/sta",  infos_displayed);
    setprop("instrumentation/my_aircraft/nd/inputs/data", infos_displayed);
}

var event_click_radar = func()
{
    var infos_displayed = getprop("instrumentation/my_aircraft/nd/inputs/inputs/tfc") or 0;
    infos_displayed = (infos_displayed) ? 0 : 1;

    setprop("instrumentation/my_aircraft/nd/inputs/inputs/tfc", infos_displayed);
}

var set_north = func()
{
    var is_true_north = getprop("/instrumentation/my_aircraft/nd/inputs/true-north") or 0;

    var indicated_heading = props.globals.getNode("/instrumentation/my_aircraft/nd/outputs/indicated-heading");
    var heading_bug = props.globals.getNode("/instrumentation/my_aircraft/nd/outputs/heading-bug-deg");
    indicated_heading.unalias();
    heading_bug.unalias();

    if (is_true_north == 1) {
        var indicated_true_heading = props.globals.getNode("/orientation/heading-deg");
        var indicated_bug_true = props.globals.getNode("/instrumentation/my_aircraft/nd/outputs/true-heading-bug-deg");
        indicated_heading.alias(indicated_true_heading);
        heading_bug.alias(indicated_bug_true);
    } else {
        var indicated_mag_heading = props.globals.getNode("/orientation/heading-magnetic-deg");
        var indicated_bug_mag = props.globals.getNode("/autopilot/settings/heading-bug-deg");
        indicated_heading.alias(indicated_mag_heading);
        heading_bug.alias(indicated_bug_mag);
    }
}

var event_toggle_true_north = func()
{
    var is_true_north = getprop("/instrumentation/my_aircraft/nd/inputs/true-north") or 0;
    setprop("/instrumentation/my_aircraft/nd/inputs/true-north", ((is_true_north) ? 0 : 1));

    set_north();
}






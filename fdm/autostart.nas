print("*** LOADING fdm - autostart.nas ... ***");

# namespace : fdm

var do_electrical_master_switch = func(value) {
    printf("  set master switch");
    setprop('/instrumentation/my_aircraft/electricals/controls/master-switch', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_electrical_bus_avionics = func(value) {
    printf("  set bus avionics");
    setprop('/instrumentation/my_aircraft/electricals/controls/bus-avionics', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_electrical_bus_engines = func(value) {
    printf("  set bus engines");
    setprop('/instrumentation/my_aircraft/electricals/controls/bus-engines', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_electrical_bus_commands = func(value) {
    printf("  set bus commands");
    setprop('/instrumentation/my_aircraft/electricals/controls/bus-commands', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine0_fuel_on = func(value) {
    printf("  set engine 0 fuel");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/fuel-on', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine1_fuel_on = func(value) {
    printf("  set engine 1 fuel");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/fuel-on', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine0_pump = func(value) {
    printf("  set engine 0 pump");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/pump', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine1_pump = func(value) {
    printf("  set engine 1 pump");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/pump', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine0_start = func(value) {
    printf("  set engine 0 start -- wait 20 seconds");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engine1_start = func(value) {
    printf("  set engine 1 start -- wait 20 seconds");
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_engines_started = func() {
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping', 0);
    setprop('/engines/engine[0]/stopped', 0);
    setprop('/engines/engine[1]/stopped', 0);
}
var do_lighting_nav = func(value) {
    printf("  set nav light");
    setprop('/controls/lighting/nav-lights', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_pos = func(value) {
    printf("  set position light");
    setprop('/controls/lighting/pos-lights', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_anticoll = func(value) {
    printf("  set anticollision light");
    setprop('/controls/lighting/beacon', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_strobe = func(value) {
    printf("  set strobe light");
    setprop('/controls/lighting/strobe', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_landing = func(value) {
    printf("  set landing and taxi light");
    setprop('/controls/lighting/landing-lights', value);
    setprop('/controls/lighting/taxi-light', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_form = func(value) {
    printf("  set formation light");
    setprop('/controls/lighting/formation-lights', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_lighting_instr = func(value) {
    printf("  set instruments light");
    setprop('/controls/lighting/instruments-norm', value);
}
var do_command_canopy = func(value) {
    printf("  set canopy position");
    setprop('/controls/doors/canopy', value);
    setprop('/sim/model/click', (getprop('/sim/model/click') ? 0 : 1));
}
var do_command_brake_parking = func(value) {
    printf("  set parking brake");
    setprop('/controls/gear/brake-parking', value);
    setprop('/sim/model/lever_parkbrake', (getprop('/sim/model/click') ? 0 : 1));
}
var do_ground_equipment = func(value) {
    printf("  ground equipment");
    setprop('/sim/model/ground-equipment-e', value);
    setprop('/sim/model/ground-equipment-g', value);
    setprop('/sim/model/ground-equipment-s', value);
}
var do_comm0 = func(value) { # 0/1
    printf("  comm0");
    setprop('/instrumentation/comm[0]/serviceable', value);
}
var do_comm1 = func(value) { # 0/1
    printf("  comm1");
    setprop('/instrumentation/comm[1]/serviceable', value);
}
var do_nav0 = func(value) { # 0/1
    printf("  nav0");
    setprop('/instrumentation/nav[0]/serviceable', value);
}
var do_nav1 = func(value) { # 0/1
    printf("  nav1");
    setprop('/instrumentation/nav[1]/serviceable', value);
}
var do_adf0 = func(value) { # 0/2
    printf("  adf0");
    setprop('/instrumentation/adf[0]/func-knob', value);
}
var do_transponder = func(value) { # 0/4
    printf("  transponder");
    setprop('/instrumentation/transponder/inputs/knob-mode', value);
}

var flashlight = func(n) {
    var view_number = getprop('/sim/current-view/view-number') or 0;
    if(view_number == 0)
    {
        setprop('/sim/rendering/als-secondary-lights/use-flashlight', n);
    }
}

var init = func() {
    #printf("init ...");
    do_lighting_landing(0);
    do_lighting_form(0);
    do_lighting_pos(0);
    do_lighting_nav(0);
    do_lighting_strobe(0);
    do_lighting_anticoll(0);
    do_lighting_instr(0);
    do_comm0(0);
    do_comm1(0);
    do_nav0(0);
    do_nav1(0);
    do_adf0(0);
    do_transponder(0);
    do_engine0_pump(0);
    do_engine0_fuel_on(0);
    do_engine1_pump(0);
    do_engine1_fuel_on(0);
    do_electrical_bus_commands(0);
    do_electrical_bus_engines(0);
    do_electrical_bus_avionics(0);
    do_electrical_master_switch(0);

    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_starting', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[0]/is_stopping', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_starting', 0);
    setprop('/instrumentation/my_aircraft/engines/controls/engine[1]/is_stopping', 0);
}

var fast_start = func() {
    printf("fast_start ...");

    do_ground_equipment(0);
    do_electrical_master_switch(1);
    do_electrical_bus_avionics(1);
    do_electrical_bus_engines(1);
    do_electrical_bus_commands(1);
    do_engine0_pump(1);
    do_engine0_fuel_on(1);
    do_engine1_pump(1);
    do_engine1_fuel_on(1);
    do_comm0(1);
    do_comm1(1);
    do_nav0(1);
    do_nav1(1);
    do_adf0(2);
    do_transponder(4);
    do_lighting_instr(1);
    do_lighting_form(1);
    do_lighting_pos(1);
    do_lighting_nav(1);
    do_lighting_strobe(1);
    do_lighting_anticoll(1);
    do_lighting_landing(1);
    do_command_canopy(0);
    settimer(func() { do_engines_started(); do_electrical_master_switch(2); }, 2);

    printf("started. Ready to fly !");
    settimer(func() { setprop('/sim/messages/pilot', "started. Ready to fly !"); }, 6);
}

var stop = func() {
    printf("stop ...");

    my_aircraft_functions.save_current_view();

    var wait = 0;
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_command(); },     wait);
    wait +=  1   ; settimer(func() { do_command_brake_parking(1); },                    wait);
    wait +=  2   ; settimer(func() { do_command_canopy(1); },                           wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_light(); },       wait);
    wait +=  2   ; settimer(func() { do_lighting_landing(0); },                         wait);
    wait +=  1   ; settimer(func() { do_lighting_form(.66); },                          wait);
    wait +=   .2 ; settimer(func() { do_lighting_form(.33); },                          wait);
    wait +=   .2 ; settimer(func() { do_lighting_form(0); },                            wait);
    wait +=  1   ; settimer(func() { do_lighting_pos(0); },                             wait);
    wait +=  1   ; settimer(func() { do_lighting_nav(0); },                             wait);
    wait +=  1   ; settimer(func() { do_lighting_strobe(0); },                          wait);
    wait +=  1   ; settimer(func() { do_lighting_anticoll(0); },                        wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  1   ; settimer(func() { do_electrical_master_switch(1); },                 wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_engines(); },     wait);
    wait +=  1   ; settimer(func() { do_engine0_pump(0); },                             wait);
    wait +=  1   ; settimer(func() { do_engine0_fuel_on(0); },                          wait);
    wait +=  1   ; settimer(func() { do_engine1_pump(0); },                             wait);
    wait +=  1   ; settimer(func() { do_engine1_fuel_on(0); },                          wait);
    wait +=  2   ; settimer(func() { my_aircraft_functions.view_sfd(); },               wait);
    wait +=  0.5 ; settimer(func() { my_aircraft_functions.view_panel_radio(); },       wait);
    wait +=  1   ; settimer(func() { do_comm0(0); },                                    wait);
    wait +=  1   ; settimer(func() { do_comm1(0); },                                    wait);
    wait +=  1   ; settimer(func() { do_nav0(0); },                                     wait);
    wait +=  1   ; settimer(func() { do_nav1(0); },                                     wait);
    wait +=  1   ; settimer(func() { do_adf0(0); },                                     wait);
    wait +=  1   ; settimer(func() { do_transponder(0); },                              wait);
    wait +=  2   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  6   ; settimer(func() { do_electrical_bus_commands(0); },                  wait);
    wait +=  1   ; settimer(func() { do_electrical_bus_engines(0); },                   wait);
    wait +=  1   ; settimer(func() { flashlight(2); },                                  wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_light(); },       wait);
    wait +=  1   ; settimer(func() { do_lighting_instr(0); },                           wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  1   ; settimer(func() { do_electrical_bus_avionics(0); },                  wait);
    wait +=  1   ; settimer(func() { do_electrical_master_switch(0); },                 wait);

    wait +=  1   ; settimer(func() { my_aircraft_functions.load_current_view(); },      wait);
    wait +=  3   ; settimer(func() { printf("stopped."); },                             wait);
    wait +=  1   ; settimer(func() { setprop('/sim/messages/pilot', "stopped"); },      wait);
}

var autostart = func() {
    printf("autostart ...");

    init();
    my_aircraft_functions.save_current_view();

    var wait = 0;
    wait +=  1   ; settimer(func() { do_ground_equipment(0); },                         wait);
    wait +=  1   ; settimer(func() { flashlight(2); },                                  wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  2   ; settimer(func() { do_electrical_master_switch(1); },                 wait);
    wait +=  1   ; settimer(func() { do_electrical_bus_avionics(1); },                  wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_light(); },       wait);
    wait +=  1.4 ; settimer(func() { do_lighting_instr(0.25); },                        wait);
    wait +=   .2 ; settimer(func() { do_lighting_instr(0.5); },                         wait);
    wait +=   .2 ; settimer(func() { do_lighting_instr(0.75); },                        wait);
    wait +=   .2 ; settimer(func() { do_lighting_instr(1); },                           wait);
    wait +=  1   ; settimer(func() { flashlight(0); },                                  wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  2   ; settimer(func() { do_electrical_bus_engines(1); },                   wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_engines(); },     wait);
    wait +=  1   ; settimer(func() { do_engine0_fuel_on(1); },                          wait);
    wait +=  1   ; settimer(func() { do_engine0_pump(1); },                             wait);
    wait +=  1   ; settimer(func() { do_engine0_start(1); },                            wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_sfd(); },               wait);
    wait += 25   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  1   ; settimer(func() { do_electrical_master_switch(2); },                 wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_engines(); },     wait);
    wait +=  1   ; settimer(func() { do_engine1_fuel_on(1); },                          wait);
    wait +=  1   ; settimer(func() { do_engine1_pump(1); },                             wait);
    wait +=  1   ; settimer(func() { do_engine1_start(1); },                            wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_sfd(); },               wait);
    wait +=  4   ; settimer(func() { my_aircraft_functions.view_panel_electrical(); },  wait);
    wait +=  2   ; settimer(func() { do_electrical_bus_commands(1); },                  wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_command(); },     wait);
    wait +=  2   ; settimer(func() { do_command_canopy(.6); },                          wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_light(); },       wait);
    wait +=  2   ; settimer(func() { do_lighting_anticoll(1); },                        wait);
    wait +=  1   ; settimer(func() { do_lighting_strobe(1); },                          wait);
    wait +=  1   ; settimer(func() { do_lighting_nav(1); },                             wait);
    wait +=  1   ; settimer(func() { do_lighting_pos(1); },                             wait);
    wait +=  1   ; settimer(func() { do_lighting_form(.33); },                          wait);
    wait +=   .2 ; settimer(func() { do_lighting_form(.66); },                          wait);
    wait +=   .2 ; settimer(func() { do_lighting_form(1); },                            wait);
    wait +=  1   ; settimer(func() { do_lighting_landing(1); },                         wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_command(); },     wait);
    wait +=  1   ; settimer(func() { do_command_canopy(0); },                           wait);
    wait +=  1   ; settimer(func() { my_aircraft_functions.view_panel_radio(); },       wait);
    wait +=  1   ; settimer(func() { do_comm0(1); },                                    wait);
    wait +=  1   ; settimer(func() { do_comm1(1); },                                    wait);
    wait +=  1   ; settimer(func() { do_nav0(1); },                                     wait);
    wait +=  1   ; settimer(func() { do_nav1(1); },                                     wait);
    wait +=  1   ; settimer(func() { do_adf0(2); },                                     wait);
    wait +=  1   ; settimer(func() { do_transponder(4); },                              wait);

    wait +=  1   ; settimer(func() { my_aircraft_functions.load_current_view(); },      wait);
    wait +=  3   ; settimer(func() { printf("started. Ready to fly !"); },              wait);
    wait +=  1   ; settimer(func() { setprop('/sim/messages/pilot', "started. Ready to fly !"); }, wait);
}

var toggle_autostart = func() {

    var is_stopped_engine0 = getprop('/engines/engine[0]/stopped') or 0;
    var is_stopped_engine1 = getprop('/engines/engine[1]/stopped') or 0;
    var nb_engine_stopped = is_stopped_engine0 + is_stopped_engine1;

    if(nb_engine_stopped == 2)
    {
        printf("all engines stopped : launching autostart ...");
        autostart();
    }
    else
    {
        printf("at least one engine started : launching autostop ...");
        stop();
    }
}


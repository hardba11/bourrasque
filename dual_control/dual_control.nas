print("*** LOADING aircraft_dual_control - dual_control.nas ... ***");

# namespace : aircraft_dual_control

var DCT = dual_control_tools;

# pilot/copilot aircraft identifiers (used by dual_control) :
var pilot_type   = "Aircraft/bourrasque/models/brsq.xml";
var copilot_type = "Aircraft/bourrasque/models/brsq-backseat.xml";

props.globals.initNode("/sim/remote/pilot-callsign", '', 'STRING');

# used by dual_control to set up the mappings for the pilot
var pilot_connect_copilot = func(copilot) {
    print('######## pilot_connect_copilot() ########');
}
var pilot_disconnect_copilot = func() {
    print('######## pilot_disconnect_copilot() ########');
}

# used by dual_control to set up the mappings for the copilot
var copilot_connect_pilot = func(pilot) {
    print('######## copilot_connect_pilot() ########');
    set_copilot_wrappers(pilot);
    return [];
}
var copilot_disconnect_pilot = func() {
    print('######## copilot_disconnect_pilot() ########');
}

# copilot nasal wrappers
var set_copilot_wrappers = func(pilot) {
}


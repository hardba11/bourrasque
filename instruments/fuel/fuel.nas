print("*** LOADING instrument_fuel - fuel.nas ... ***");

# namespace : instrument_fuel

var fuel = func()
{
    var level_tot               = getprop("/consumables/fuel/total-fuel-m3")    or 0;
    var level_0                 = getprop("/consumables/fuel/tank[0]/level-m3") or 0;
    var level_1                 = getprop("/consumables/fuel/tank[1]/level-m3") or 0;
    var level_2                 = getprop("/consumables/fuel/tank[2]/level-m3") or 0;
    var level_3                 = getprop("/consumables/fuel/tank[3]/level-m3") or 0;
    var ff0                     = getprop("/engines/engine[0]/fuel-flow-gph") or 0;
    var ff1                     = getprop("/engines/engine[1]/fuel-flow-gph") or 0;
    var bingo_enabled           = getprop("/instrumentation/my_aircraft/fuel/bingo/is_bingo_enabled") or 0;
    var bingo_choose            = getprop("/instrumentation/my_aircraft/fuel/bingo/choose") or 0;
    var bingo_distance_minute   = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_minute") or 0;
    var bingo_distance_nm       = getprop("/instrumentation/my_aircraft/fuel/bingo/distance_nm") or 0;

    var nan_remaining = 0;
    var level_left   = level_1;
    var level_center = level_0 + level_3;
    var level_right  = level_2;

    var ff0_kg_s  = ff0 * 0.0508 / 60;
    var ff1_kg_s  = ff1 * 0.0508 / 60;
    var remaining_s = (level_tot * 805) / (ff0_kg_s + ff1_kg_s + 0.0000001);

    if(remaining_s > (3600 * 24)) { nan_remaining = 1; }

    var h_remaining = math.floor(remaining_s / 3600);
    var m_remaining = math.floor(math.mod((remaining_s / 60), 60));
    var s_remaining = math.mod(remaining_s, 60);

    var bingo_text = '';
    var is_bingo_alert = 0;
    if(bingo_choose == 0)
    {
        bingo_text = bingo_distance_minute ~' min';
        is_bingo_alert = ((bingo_distance_minute * 60) > remaining_s) ? 1 : 0;
    }
    else
    {
        bingo_text = bingo_distance_nm ~' NM';
        is_bingo_alert = (bingo_distance_nm > (remaining_s / 3600 * 300)) ? 1 : 0;
    }

    is_bingo_alert = bingo_enabled ? is_bingo_alert : 0;

    setprop("/instrumentation/my_aircraft/fuel/fuel-left-tank-m3",      level_left);
    setprop("/instrumentation/my_aircraft/fuel/fuel-center-tank-m3",    level_center);
    setprop("/instrumentation/my_aircraft/fuel/fuel-right-tank-m3",     level_right);
    setprop("/instrumentation/my_aircraft/fuel/h-remaining",            h_remaining);
    setprop("/instrumentation/my_aircraft/fuel/m-remaining",            m_remaining);
    setprop("/instrumentation/my_aircraft/fuel/s-remaining",            s_remaining);
    setprop("/instrumentation/my_aircraft/fuel/bingo-text",             bingo_text);
    setprop("/instrumentation/my_aircraft/fuel/bingo/is_bingo_alert",   is_bingo_alert);
    setprop("/instrumentation/my_aircraft/fuel/nan-remaining",          nan_remaining);
}



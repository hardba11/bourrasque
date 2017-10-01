print("*** LOADING instrument_light - light.nas ... ***");

# namespace : instrument_light
var light = func()
{
    setprop(
        '/controls/lighting/landing-lights',
        getprop('/controls/lighting/taxi-light')
    );

    var is_internal  = getprop('sim/current-view/internal') or 0;
    var is_gear_down = getprop('gear/gear[0]/position-norm') or 0;
    var is_bus_on    = getprop('/systems/electrical/bus/commands') or 0;

    # disable als lights if exterior view and gear up and bus on
    if(is_internal and is_gear_down and is_bus_on)
    {
        # left landing-light :
        setprop(
            '/sim/rendering/als-secondary-lights/use-alt-landing-light',
            getprop('/controls/lighting/taxi-light')
        );
        # right landing-light :
        setprop(
            '/sim/rendering/als-secondary-lights/use-landing-light',
            getprop('/controls/lighting/taxi-light')
        );
    }
    else
    {
        # left landing-light
        setprop('/sim/rendering/als-secondary-lights/use-alt-landing-light', 0);
        # right landing-light
        setprop('/sim/rendering/als-secondary-lights/use-landing-light', 0);
    }
    settimer(light, 1);
}

setlistener('/sim/signals/fdm-initialized', light);


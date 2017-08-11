print("*** LOADING instrument_light - light.nas ... ***");

# namespace : instrument_light
var light = func()
{
    setprop('/controls/lighting/landing-lights',                         getprop('/controls/lighting/taxi-light'));

    var is_internal = getprop('/sim/current-view/internal');

    # disable als lights if exterior view
    if(is_internal)
    {
        setprop('/sim/rendering/als-secondary-lights/use-alt-landing-light', getprop('/controls/lighting/taxi-light'));  # left landing-light
        setprop('/sim/rendering/als-secondary-lights/use-landing-light',     getprop('/controls/lighting/taxi-light'));  # right landing-light
    }
    else
    {
        setprop('/sim/rendering/als-secondary-lights/use-alt-landing-light', 0);  # left landing-light
        setprop('/sim/rendering/als-secondary-lights/use-landing-light',     0);  # right landing-light
    }
    settimer(light, 1);
}

setlistener('/sim/signals/fdm-initialized', light);


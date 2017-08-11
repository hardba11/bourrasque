#!/bin/bash

export FG_SRC_DIR=$HOME/src
export FG_INSTALL_DIR=$HOME/FG-3.4
export FG_DATA_DIR=$HOME/fgfs
export LD_LIBRARY_PATH=$FG_INSTALL_DIR/lib/:$LD_LIBRARY_PATH

$FG_INSTALL_DIR/bin/fgfs \
  --aircraft=bourrasque \
  --fg-root=$FG_INSTALL_DIR/fgdata \
  --fg-scenery=$FG_DATA_DIR/fg_scenery/terrasync \
  --fg-aircraft=$FG_DATA_DIR/fg_aircraft \
  --terrasync-dir=$FG_DATA_DIR/fg_scenery/terrasync \
  --enable-terrasync \
  --prop:/sim/fuel-fraction=0.1 \
  --com1=109.4 \
  --com2=119.95 \
  --nav1=220:110.7 \
  --nav2=78:112.5 \
  --enable-ai-models \
  --enable-ai-traffic \
  --console \
  --disable-random-objects \
  --disable-random-buildings \
  --enable-random-vegetation \
  --enable-distance-attenuation \
  --enable-fuel-freeze \
  --enable-real-weather-fetch \
  --shading-flat \
  --timeofday=real \
  --enable-splash-screen \
  --disable-fgcom \
  --enable-clouds3d \
  --enable-horizon-effect \
  --enable-enhanced-lighting \
  --enable-specular-highlight \
  --log-level=warn



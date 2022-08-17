print("*** LOADING instrument_tablet_map - tablet_map.nas ... ***");

# namespace : instrument_tablet_map

# thx viggen and m2000-5 dev teams ! ;)
#
# url where to take the tiles
# Some alternative can exist
# http://otile1.mqcdn.com/tiles/1.0.0/map
# http://otile1.mqcdn.com/tiles/1.0.0/sat
# (also see https://operations.osmfoundation.org/policies/tiles/)
#var makeUrl  = string.compileTemplate('http://{server}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg');
#var servers = ["otile1", "otile2", "otile3", "otile4"];

var width = 1024;
var height = 1024;

var data_col1_vor_france = "
ABB 108.45 ABBeville
    [LFOI 02/20]
AGN 114.8  AGeN
    [LFBA 291 110.35]
ANG 113.0  ANGers
    [LFJR 261 108.9]
ARE 112.5  monts d ARreE
BMC 113.75 Bordeaux MerignaC
    [LFBD 225 110.3]
BNE 113.8  BoulogNE
    [LFAT 133 110.15]
CAD 115.95 ChAteauDun
    [LFOC 10/28]
CAN 114.45 CAeN
    [LFRK 305 110.95]
CFA 114.35 Clermont-FerrAnd
    [LFLC 260 111.10]
CMB 112.6  CaMBrai
    [LFQI 273 109.3]
CNA 114.65 CogNAc
    [LFBG 229 109.9]
CTL 117.6  ChaTiLlon sur marne
    [LFFH 04/22]
DIN 114.3  DINard
    [LFRD 350 110.75]
DJL 111.45 DiJon Longvic
    [LFSD 353 109.5]
DVL 110.2  DeauViLle
    [LFRG 297 111.55]
EPL 113.0  EPinaL
    [LFSG 265 110.9]
EVX 112.4  EVreuX
    [LFOE 039 111.29]
FJR 114.45 montpellier
    [LFMT 304 108.55]
GAI 115.8  GAIllac
    [LFCI 088 108.7]
GTQ 111.25 GrosTenQuin
    [LFJL 039 111.75]
LGL 115.0  L'aiGLe
    [LFOL 07/25]
";

var data_col2_vor_france = "
LMG 114.5  LiMoGes
    [LFBL 213 110.1]
LSE 114.75 Lyon St Exupery
    [LFLL 355 110.75]
LTP 115.55 La Tour du Pin
    [LFLS 090 109.3]
LUL 117.1  LUxeuiL
    [LFSX 113 108.1]
MDM 108.7  Mont De Marsan
    [LFBM 087 110.5]
MEN 115.3  MENde
    [LFNB 125 111.9]
MMD 109.4  MontMeDy
    [LFGW 10/28]
MOU 116.7  MOUlins
    [LFHY 08/26]
MRM 108.8  MaRseille Marignane
    [LFML 133 110.3]
MTL 113.65 MonTeLimar
    [LFLQ 02/20]
NEV 113.4  NEVers
    [LFQG 12/30]
NIZ 112.4  NIce aZure
    [LFMN 044 110.7]
NTS 115.5  NanTeS
    [LFRS 027 109.9]
POI 113.3  POItiers
    [LFBI 210 110.95]
PPG 116.25 PerPiGnan
    [LFMP 328 111.75]
QPR 117.8  QuimPeR
    [LFRQ 273 111.3]
REM 112.3  REiMs
    [LFQA 07/25]
REN 109.25 RENnes
    [LFRN 280 110.1]
STP 116.5  St TroPez
    [LFTZ 06/24]
TOU 117.7  TOUlouse
    [LFBO 142 110.7]
TRO 116.0  TROyes
    [LFQB 173 111.15]
";

# max 23 lignes par page
# list : 45 char max
var checklists = [
# 1
    {
        'title': 'START 1/2',
        'items': [
            {'list': 'PAGE 1/2',                                      'check': '#'},
            {'list': '================================',              'check': '#'},
            {'list': 'FUEL TRUCK : adjust fuel quantity',             'check': 'ON DEMAND'},
            {'list': 'gui/equipment : fuel truck',                    'check': 'REMOVE'},
            {'list': 'gui/equipment : covers',                        'check': 'REMOVE'},
            {'list': 'gui/equipment : scale',                         'check': 'REMOVE'},
            {'list': 'electrical instrument : switch',                'check': 'BAT or EPU'},
            {'list': 'command panel : canopy',                        'check': 'HALF-CLOSE'},
            {'list': 'electrical instrument : avionics',              'check': 'ON'},
            {'list': 'electrical instrument : cmd',                   'check': 'ON'},
            {'list': 'lights panel : instrument light',               'check': 'ADJUST'},
            {'list': 'radio : NAV1',                                  'check': 'ON'},
            {'list': 'radio : COM1',                                  'check': 'ON'},
            {'list': 'radio : NAV2',                                  'check': 'ON'},
            {'list': 'radio : COM2',                                  'check': 'ON'},
            {'list': 'radio : ADF ',                                  'check': 'ON'},
            {'list': 'radio : TRANSPONDER',                           'check': 'ON'},
            {'list': 'nav/com : frequency',                           'check': 'ADJUST'},
            {'list': 'contact tower, autorization to start engines',  'check': 'REQUEST'},
            {'list': 'transponder adjust squawk',                     'check': 'ON DEMAND'},
            {'list': 'change mod ND',                                 'check': 'TAXI'},
            {'list': 'electrical instrument : engines',               'check': 'ON'},
            {'list': 'lights panel : anti-collision',                 'check': 'ON'},
            {'list': 'NEXT PAGE',                                     'check': '>>>>>'},
        ],
    },
# 2
    {
        'title': 'START 2/2',
        'items': [
            {'list': 'PAGE 2/2',                                      'check': '#'},
            {'list': '================================',              'check': '#'},
            {'list': 'engine 0 instrument : cut',                     'check': 'ON'},
            {'list': 'engine 0 instrument : pump',                    'check': 'ON'},
            {'list': 'engine 0 instrument : start',                   'check': 'PUSH'},
            {'list': 'engine 0 started',                              'check': 'WAIT'},
            {'list': 'electrical instrument : switch',                'check': 'ALT'},
            {'list': 'engine 1 instrument : cut',                     'check': 'ON'},
            {'list': 'engine 1 instrument : pump',                    'check': 'ON'},
            {'list': 'engine 1 instrument : start',                   'check': 'PUSH'},
            {'list': 'lights panel : strobe',                         'check': 'ON'},
            {'list': 'lights panel : navigation',                     'check': 'ON'},
            {'list': 'lights panel : position',                       'check': 'ON'},
            {'list': 'lights panel : formation',                      'check': 'ON DEMAND'},
            {'list': 'lights panel : landing and taxi',               'check': 'ON DEMAND'},
            {'list': 'engine 1 started',                              'check': 'WAIT'},
            {'list': 'ALT Hpa QNH',                                   'check': 'ADJUST'},
            {'list': 'gui/equipment : epu',                           'check': 'REMOVE'},
        ],
    },
# 3
    {
        'title': 'TAXI',
        'items': [
            {'list': 'contact tower, autorization to taxi',           'check': 'REQUEST'},
            {'list': 'change mod ND',                                 'check': 'TAXI'},
            {'list': 'gui/equipment : chocks',                        'check': 'REMOVE'},
            {'list': 'command panel : parkbrake',                     'check': 'RELEASE'},
            {'list': 'brake',                                         'check': 'TEST'},
        ],
    },
# 4
    {
        'title': 'TAKE OFF',
        'items': [
            {'list': 'contact tower, autorization to enter runway',   'check': 'REQUEST'},
            {'list': 'command panel : canopy',                        'check': 'CLOSE'},
            {'list': 'change mod ND',                                 'check': 'APP'},
            {'list': 'PFD : autopilot speed',                         'check': '200kt'},
            {'list': 'ND : autopilot heading',                        'check': 'ADJUST'},
            {'list': 'PFD : autopilot alt',                           'check': '2500ft'},
            {'list': 'PFD : autopilot vs',                            'check': '2000ft/min'},
            {'list': 'HSI : NAV1 radial',                             'check': 'ON DEMAND'},
            {'list': '.--------------------------------------------', 'check': 'info'},
            {'list': '| rotation: 150kts',                            'check': 'info'},
            {'list': '`--------------------------------------------', 'check': 'info'},
            {'list': 'CHRONO : chrono',                               'check': 'START'},
            {'list': 'PFD : autopilot speed',                         'check': 'ACTIVE'},
        ],
    },
# 5
    {
        'title': 'CLIMBING',
        'items': [
            {'list': '.--------------------------------------------', 'check': 'info'},
            {'list': '| reaching 2500ft after 00:01:55 / 6.7NM',      'check': 'info'},
            {'list': '`--------------------------------------------', 'check': 'info'},
            {'list': 'ND : autopilot heading',                        'check': 'ADJUST'},
            {'list': 'PFD : autopilot vs',                            'check': '4000ft/min'},
            {'list': 'PFD : autopilot speed',                         'check': '600kt'},
            {'list': 'PFD : autopilot alt',                           'check': '40000ft'},
            {'list': 'ALT Hpa std',                                   'check': 'STD'},
            {'list': '.--------------------------------------------', 'check': 'info'},
            {'list': '| 2500ft|200kt to 40000ft|600kt',               'check': 'info'},
            {'list': '| - 00:09:45',                                  'check': 'info'},
            {'list': '| - 96NM',                                      'check': 'info'},
            {'list': '`--------------------------------------------', 'check': 'info'},
        ],
    },
# 6
    {
        'title': 'NAVIGATION',
        'items': [
            {'list': 'change mod ND',                                 'check': 'NAV'},
            {'list': 'VOR frequency, radial',                         'check': 'CHOOSE'},
            {'list': 'ND : VOR1',                                     'check': 'ENABLE'},
            {'list': 'PFD : adjust autopilot',                        'check': 'ON DEMAND'},
        ],
    },
# 7
    {
        'title': 'DESCENT',
        'items': [
            {'list': '.--------------------------------------------', 'check': 'info'},
            {'list': '| 40000ft|600kt to 4000ft 400kt',               'check': 'info'},
            {'list': '| - 00:09:30',                                  'check': 'info'},
            {'list': '| - 83NM',                                      'check': 'info'},
            {'list': '`--------------------------------------------', 'check': 'info'},
            {'list': 'PFD : autopilot speed',                         'check': '300kt'},
            {'list': 'PFD : autopilot vs',                            'check': '4000ft/min'},
            {'list': 'PFD : autopilot alt',                           'check': '4000ft'},
            {'list': 'ALT Hpa QNH',                                   'check': 'ADJUST'},
        ],
    },
# 8
    {
        'title': 'LANDING',
        'items': [
            {'list': 'change mod ND',                                 'check': 'APP'},
            {'list': '.--------------------------------------------', 'check': 'info'},
            {'list': '| approach at 140kts use speedbrakes',          'check': 'info'},
            {'list': '| velocity vector on runway s threshold',       'check': 'info'},
            {'list': '| velocity vector -3deg on hud ladder',         'check': 'info!'},
            {'list': '| touchdown at 120kts',                         'check': 'info'},
            {'list': '`--------------------------------------------', 'check': 'info'},
        ],
    },
];

var MAP = {
    canvas_settings: {
        'name': 'map',
        'size': [1024, 1024],
        'view': [width, height],
        'mipmapping': 1
    },
    new: func(placement)
    {
        var m = {
            parents: [MAP],
            canvas: canvas.new(MAP.canvas_settings)
        };

# INIT PROPERTIES

        # data used to create array of tiles
        m.tile_size = 256;
        m.num_tiles = [7, 7];
        m.center_tile_offset = [2, 2];
        m.type = 'map';

        # my aircraft data and settings
        m.myHeadingProp = props.globals.getNode("orientation/heading-deg");
        m.myCoord = geo.aircraft_position();
        m.zoom = getprop("/instrumentation/my_aircraft/tablet/controls/map/zoom") or 6;

        # used where to get and store locally tiles files
        m.home =  props.globals.getNode("/sim/fg-home");
        m.maps_base = m.home.getValue() ~'/cache/maps';
        m.makeUrl  = string.compileTemplate('http://{server}.tile.osm.org/{z}/{x}/{y}.png');
        m.servers = ['a', 'b', 'c'];
        m.makePath = string.compileTemplate(m.maps_base ~'/osm-{type}/{z}/{x}/{y}.png');
        m.filename = 'Aircraft/bourrasque/instruments/tablet/my_aircraft_icon.svg';

        m.filepath_image_menu = 'Aircraft/bourrasque/instruments/tablet/menu.png';
        m.filepath_image_checklist = 'Aircraft/bourrasque/instruments/tablet/bg.png';
        m.filepath_image_vor = 'Aircraft/bourrasque/instruments/tablet/morse.png';
        m.filepath_image_mapvor = 'Aircraft/bourrasque/instruments/tablet/mapvor-fr.png';

# CANVAS STUFF

        # main canvas
        m.canvas.addPlacement(placement);
        m.root = m.canvas.createGroup();

# MENU STUFF
        m.g_page_menu = m.root.createChild('group').set('z-index', 100);
        m.image_menu = m.g_page_menu.createChild('image').setFile(m.filepath_image_menu)
            .setSize(1024, 1024)
            .setTranslation(0, 0);

# MAP STUFF
        m.g_page_map = m.root.createChild('group').set('z-index', 99);

        # text for MAP page
        m.txt_zoom = m.g_page_map.createChild('text', 'txt_zoom')
            .setTranslation(200, 200)
            .setAlignment('left-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(46)
            .setColor(.8, 0, 0, 1)
            .setText('txt_zoom')
            .set('z-index', 1);
        m.txt_coords_lat = m.g_page_map.createChild('text', 'txt_coords_lat')
            .setTranslation(180, 850)
            .setAlignment('left-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(46)
            .setColor(.8, 0, 0, 1)
            .setText('txt_coords_lat')
            .set('z-index', 1);
        m.txt_coords_lng = m.g_page_map.createChild('text', 'txt_coords_lng')
            .setTranslation(180, 900)
            .setAlignment('left-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(46)
            .setColor(.8, 0, 0, 1)
            .setText('txt_coords_lng')
            .set('z-index', 1);
        m.txt_hdg = m.g_page_map.createChild('text', 'txt_hdg')
            .setTranslation(180, 950)
            .setAlignment('left-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(32)
            .setColor(.8, 0, 0, 1)
            .setText('txt_hdg')
            .set('z-index', 1);
        m.txt_alt = m.g_page_map.createChild('text', 'txt_alt')
            .setTranslation(600, 900)
            .setAlignment('left-bottom')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(46)
            .setColor(.8, 0, 0, 1)
            .setText('txt_alt')
            .set('z-index', 1);

        m.g_map = m.root.createChild('group');
        m.root.setCenter(width / 2, height / 2); # center of the canvas

        # simple aircraft icon at current position/center of the map
        m.svg_symbol = m.g_page_map.createChild('group');
        canvas.parsesvg(m.svg_symbol, m.filename);
        m.svg_symbol.setScale(0.025);
        m.svg_symbol.setTranslation((width / 2) - 14, (height / 2) - 16);
        m.myVector = m.svg_symbol.getBoundingBox();
        m.svg_symbol.updateCenter();
        m.svg_symbol.set('z-index', 1);

        # map tiles
        var make_tiles = func(canvas_group) {
            var tiles = setsize([], m.num_tiles[0]);
            for(var x = 0; x < m.num_tiles[0]; x += 1)
            {
                tiles[x] = setsize([], m.num_tiles[1]);
                for(var y = 0; y < m.num_tiles[1]; y += 1)
                {
                    tiles[x][y] = canvas_group.createChild('image', 'map-tile');
                }
            }
            return tiles;
        }

        m.tiles_map = make_tiles(m.g_map);
        m.last_tile = [-1, -1];
        m.last_type = m.type;

# CHECKLIST STUFF
        m.g_page_checklist = m.root.createChild('group').set('z-index', 98);
        m.image_checklist = m.g_page_checklist.createChild('image').setFile(m.filepath_image_checklist)
            .setSize(1024, 1024)
            .setTranslation(0, 0);
        m.txt_checklist_title = m.g_page_checklist.createChild('text', 'checklist_title')
            .setTranslation(200, 120)
            .setAlignment('left-top')
            .setFont('LiberationFonts/LiberationSansNarrow-Bold.ttf')
            .setFontSize(50)
            .setColor(.8, .8, .8, 1)
            .setText('')
            .set('z-index', 1);
        m.txt_list_content = m.g_page_checklist.createChild('text', 'list_content')
            .setTranslation(160, 180)
            .setAlignment('left-top')
            .setFont('LiberationFonts/LiberationSansNarrow-Regular.ttf')
            .setFontSize(34)
            .setColor(.8, .8, .8, 1)
            .setText('')
            .set('z-index', 1);
        m.txt_check_content = m.g_page_checklist.createChild('text', 'check_content')
            .setTranslation(700, 180)
            .setAlignment('left-top')
            .setFont('LiberationFonts/LiberationSansNarrow-Regular.ttf')
            .setFontSize(34)
            .setColor(1, .2, .2, 1)
            .setText('')
            .set('z-index', 1);

# VOR STUFF
        m.g_page_vor = m.root.createChild('group').set('z-index', 97);
        m.image_vor = m.g_page_vor.createChild('image').setFile(m.filepath_image_vor)
            .setSize(1024, 1024)
            .setTranslation(0, 0);
        m.txt_col1_vor_france = m.g_page_vor.createChild('text', 'col1_vor_france')
            .setTranslation(160, 330)
            .setAlignment('left-top')
            .setFont('LiberationFonts/LiberationMono-Regular.ttf')
            .setFontSize(16)
            .setColor(0, .8, 0, 1)
            .setText(data_col1_vor_france).set('z-index', 1);

        m.txt_col2_vor_france = m.g_page_vor.createChild('text', 'col2_vor_france')
            .setTranslation(510, 330)
            .setAlignment('left-top')
            .setFont('LiberationFonts/LiberationMono-Regular.ttf')
            .setFontSize(16)
            .setColor(0, .8, 0, 1)
            .setText(data_col2_vor_france).set('z-index', 1);

# MAPVOR STUFF
        m.g_page_mapvor = m.root.createChild('group').set('z-index', 97);
        m.image_mapvor = m.g_page_mapvor.createChild('image').setFile(m.filepath_image_mapvor)
            .setSize(1024, 1024)
            .setTranslation(0, 0);


        return m;
    },
    update: func() {
        var serviceable = getprop("/instrumentation/my_aircraft/tablet/controls/serviceable") or 0;
        var time_speed = getprop("/sim/speed-up") or 1;
        var loop_speed = (time_speed == 1) ? 1 : 4 * time_speed;
        var page = getprop("/instrumentation/my_aircraft/tablet/controls/page") or 0;
        var no_page_checklist = getprop("/instrumentation/my_aircraft/tablet/controls/checklist/page") or 0;

# page0 = MENU
        if((serviceable == 1) and (page == 0))
        {
            me.g_page_menu.setVisible(1);
            me.g_page_checklist.setVisible(0);
            me.g_page_vor.setVisible(0);
            me.g_page_mapvor.setVisible(0);

            me.g_page_map.setVisible(0);
        }

# page1 = MAP
        elsif((serviceable == 1) and (page == 1))
        {
            me.svg_symbol.setRotation(me.myHeadingProp.getValue() * D2R);
            me.zoom = getprop("/instrumentation/my_aircraft/tablet/controls/map/zoom") or 10;

            me.txt_coords_lat.setText(sprintf('%s', getprop("/position/latitude-string") or ''));
            me.txt_coords_lng.setText(sprintf('%s', getprop("/position/longitude-string") or ''));
            me.txt_alt.setText(sprintf('alt agl : %d ft', getprop("/position/altitude-agl-ft") or 0));
            me.txt_hdg.setText(sprintf('heading true : %d - heading mag : %d', getprop("/orientation/heading-deg") or 0, getprop("/orientation/heading-magnetic-deg") or 0));
            me.txt_zoom.setText(sprintf('zoom : %s', me.zoom));

            # getting position
            me.myCoord = geo.aircraft_position();
            lat = me.myCoord.lat();
            lon = me.myCoord.lon();

            # getting tile number (x, y) from lat/lng
            var n = math.pow(2, me.zoom);
            var offset = [
                (n * (lon + 180) / 360) - me.center_tile_offset[0],
                ((1 - math.ln(math.tan(lat * D2R) + (1 / math.cos(lat * D2R))) / math.pi) / 2 * n) - me.center_tile_offset[1]
            ];
            var tile_index = [int(offset[0]), int(offset[1])];
            var ox = tile_index[0] - offset[0];
            var oy = tile_index[1] - offset[1];

            # placing tiles
            for(var x = 0; x < me.num_tiles[0]; x += 1)
            {
                for(var y = 0; y < me.num_tiles[1]; y += 1)
                {
                    me.tiles_map[x][y].setTranslation(
                        int(((ox + x) * me.tile_size)),
                        int(((oy + y) * me.tile_size))
                    );
                }
            }

            # downloading, using and displaying tiles
            if(tile_index[0] != me.last_tile[0]
                or tile_index[1] != me.last_tile[1]
                or me.type != me.last_type)
            {
                for(var x = 0; x < me.num_tiles[0]; x += 1)
                {
                    for(var y = 0; y < me.num_tiles[1]; y += 1)
                    {
                        var server_index = math.round(rand() * (size(me.servers) - 1));
                        var server_name = me.servers[server_index];
                        var pos = {
                            z: me.zoom,
                            x: tile_index[0] + x,
                            y: tile_index[1] + y,
                            type: me.type,
                            server: server_name
                        };
                        (func() {
                            var img_path = me.makePath(pos);
                            if(io.stat(img_path) == nil)
                            {
                                var img_url = me.makeUrl(pos);
                                http.save(img_url, img_path)
                                    .done(func() {
                                        printf('::map - downloading %s to %s', img_url, img_path);
                                    })
                                    .fail(func(r) {
                                        printf('::map - FAILED downloading %s to %s', img_url, img_path);
                                        me.tiles_map[x - 1][y - 1].setFile("");
                                    });
                            }
                            else
                            {
                                if(pos.z == me.zoom)
                                {
                                    printf('::map - using %s', img_path);
                                    me.tiles_map[x][y].setFile(img_path);
                                }
                            }
                        })();
                    }
                }
                me.last_tile = tile_index;
                me.last_type = me.type;
            }
            me.g_page_menu.setVisible(0);
            me.g_page_checklist.setVisible(0);
            me.g_page_vor.setVisible(0);
            me.g_page_mapvor.setVisible(0);

            me.g_page_map.setVisible(1);

            loop_speed = (time_speed == 1) ? .5 : 4;
        }

# page2 = CHECKLIST
        elsif((serviceable == 1) and (page == 2))
        {
            var list = '';
            var check = '';
            for(var item = 0; item < size(checklists[no_page_checklist]['items']); item += 1)
            {
                list = list ~ checklists[no_page_checklist]['items'][item]['list'] ~'
';
                check = check ~ checklists[no_page_checklist]['items'][item]['check'] ~'
';
            }

            me.txt_checklist_title.setText(checklists[no_page_checklist]['title']);
            me.txt_list_content.setText(list);
            me.txt_check_content.setText(check);

            me.g_page_menu.setVisible(0);
            me.g_page_checklist.setVisible(1);
            me.g_page_vor.setVisible(0);
            me.g_page_mapvor.setVisible(0);

            me.g_page_map.setVisible(0);
            me.g_page_mapvor.setVisible(0);
        }

# page3 = VOR FR
        elsif((serviceable == 1) and (page == 3))
        {
            me.g_page_menu.setVisible(0);
            me.g_page_checklist.setVisible(0);
            if(math.mod(no_page_checklist, 2) == 0)
            {
                me.g_page_vor.setVisible(1);
                me.g_page_mapvor.setVisible(0);
            }
            else
            {
                me.g_page_vor.setVisible(0);
                me.g_page_mapvor.setVisible(1);
            }

            me.g_page_map.setVisible(0);
        }
        settimer(func() { me.update(); }, loop_speed);
    },
};

var init = setlistener("/sim/signals/fdm-initialized", func() {
    removelistener(init); # only call once
    var tablet_map = MAP.new({'node': 'tablet.screen'});
    tablet_map.update();
});


#!/usr/bin/perl -W

# author : hardball
# version : v20171014-01
# description :
#   csv loop to xml scenario

use Term::ANSIColor ;

#===============================================================================
#                                                                     CONSTANTES

# filepath
my $FILENAME_IN_CSV         = 'trace-loop-INPUT.csv' ;
my $FILENAME_INC_HEADER_XML = 'loop-HEADER.inc.xml' ;
my $FILENAME_INC_FOOTER_XML = 'loop-FOOTER.inc.xml' ;
my $FILENAME_OUT_XML        = 'HOMEMADE-timed-loop.xml' ;

my $TPL_ENTRANCE = '
    <entry>
      <name>Line%02d</name>
      <model type="string">AI/HOMEMADE-timed-loop/lineupmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>
' ;

my $TPL_START1 = '
    <entry>
      <name>Start-Marker</name>
      <model type="string">AI/HOMEMADE-timed-loop/startmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>' ;
my $TPL_START2 = '
    <entry>
      <callsign>Start</callsign>
      <name>Start</name>
      <model type="string">AI/HOMEMADE-timed-loop/targetmarker-inactive.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>
' ;

my $TPL_LOOP = '
    <entry>
      <name>%d</name>
      <model type="string">AI/HOMEMADE-timed-loop/targetmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>
' ;

my $TPL_FINISH1 = '
    <entry>
      <callsign>Finish</callsign>
      <name>Finish</name>
      <model type="string">AI/HOMEMADE-timed-loop/targetmarker-inactive.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>' ;
my $TPL_FINISH2 = '
    <entry>
      <name>Finish-Marker</name>
      <model type="string">AI/HOMEMADE-timed-loop/finishmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>
' ;

my $TPL_EXIT = '
    <entry>
      <name>Exit%02d</name>
      <model type="string">AI/HOMEMADE-timed-loop/lineupmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
    </entry>
' ;

#    0: "disabled",
#    1: "recording entrance",
#    2: "recording loop",
#    3: "recording exit",
#    4: "dumped",

#===============================================================================
#                                                       VARIABLES INITIALISATION

#===============================================================================
#                                                                      FUNCTIONS
sub main
{
    @out = ();

    open(IN, $FILENAME_INC_HEADER_XML) or die ;
    @header = <IN> ;
    close(IN) ;
    open(IN, $FILENAME_INC_FOOTER_XML) or die ;
    @footer = <IN> ;
    close(IN) ;

    open(IN, $FILENAME_IN_CSV) or die ;
    @data = <IN> ;
    close(IN) ;

    push @out, @header ;

    $index_entrance = 0 ;
    $index_loop = 0 ;
    $index_exit = 0 ;
    $previous_no_phase = 0 ;
    for(@data)
    {
        chomp ;
        ($no_phase, $lat, $lng, $alt, $hdg) = split(':') ;
        #print join ' - ', ($no_phase, $lat, $lng, $alt, $hdg) ;

        $hdg += 90 ; $hdg %= 360 ;
        $alt *= 3.28 ;

        if($no_phase == 1)
        {
            push @out, sprintf($TPL_ENTRANCE, ++$index_entrance, $lat, $lng, $alt, $hdg) ;
        }
        elsif(($no_phase == 2) && ($previous_no_phase == 1))
        {
            push @out, sprintf($TPL_START1, $lat, $lng, $alt, $hdg) ;
            push @out, sprintf($TPL_START2, $lat, $lng, $alt, $hdg) ;
        }
        elsif($no_phase == 2)
        {
            push @out, sprintf($TPL_LOOP, ++$index_loop, $lat, $lng, $alt, $hdg) ;
        }
        elsif(($no_phase == 3) && ($previous_no_phase == 2))
        {
            push @out, sprintf($TPL_FINISH1, $lat, $lng, $alt, $hdg) ;
            push @out, sprintf($TPL_FINISH2, $lat, $lng, $alt, $hdg) ;
        }
        elsif($no_phase == 3)
        {
            push @out, sprintf($TPL_EXIT, ++$index_exit, $lat, $lng, $alt, $hdg) ;
        }

        $previous_no_phase = $no_phase ;
    }

    push @out, @footer ;

    open(OUT, '>', $FILENAME_OUT_XML) or die ;
    print OUT @out ;
    close(OUT) ;
    print "$FILENAME_OUT_XML generated, copy it in the fgdata/ai/ directory.\n" ;
}

#===============================================================================
#                                                                           MAIN

main();

### EOF






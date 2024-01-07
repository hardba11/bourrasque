#!/usr/bin/perl -W

# author : hardball
# version : v20231115-01
# description :
#   csv loop to xml scenario

# csv columns :
#   0 : phase identification
#   1 : latitude
#   2 : longitude
#   3 : altitude (feet)
#   4 : heading
#   5 : pitch (deg)
#
# phases identification :
#   0: "disabled",
#   1: "recording entrance",
#   2: "recording loop",
#   3: "recording exit",
#   4: "dumped",

use Term::ANSIColor ;

#===============================================================================
#                                                                     CONSTANTES

# filepath
#my $LOOPNAME                = 'LFLG-timed-loop';
my $LOOPNAME                = 'homemade-timed-loop';
my $FILENAME_IN_CSV         = 'trace-loop-INPUT.csv' ;
my $FILENAME_INC_HEADER_XML = 'loop-HEADER.inc.xml' ;
my $FILENAME_INC_FOOTER_XML = 'loop-FOOTER.inc.xml' ;
my $FILENAME_OUT_XML        = $LOOPNAME .'.xml' ;

my $TPL_ENTRANCE = '
    <entry>
      <name>loop-entrance%02d</name>
      <callsign>L-IN%02d</callsign>
      <model type="string">'. $LOOPNAME .'/lineupmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>
' ;

my $TPL_START1 = '
    <entry>
      <name>loop-start-marker</name>
      <callsign>L-STRT</callsign>
      <model type="string">'. $LOOPNAME .'/startmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>' ;
my $TPL_START2 = '
    <entry>
      <name>loop-start</name>
      <callsign>L-STRT</callsign>
      <model type="string">'. $LOOPNAME .'/targetmarker-inactive.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>
' ;

my $TPL_LOOP = '
    <entry>
      <name>loop-gate-%02d</name>
      <callsign>L-GT%02d</callsign>
      <model type="string">'. $LOOPNAME .'/targetmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>
' ;

my $TPL_FINISH1 = '
    <entry>
      <name>loop-finish</name>
      <callsign>L-END</callsign>
      <model type="string">'. $LOOPNAME .'/targetmarker-inactive.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>' ;
my $TPL_FINISH2 = '
    <entry>
      <name>loop-finish-marker</name>
      <callsign>L-END</callsign>
      <model type="string">'. $LOOPNAME .'/finishmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>
' ;

my $TPL_EXIT = '
    <entry>
      <name>loop-exit-%02d</name>
      <callsign>L-EX%02d</callsign>
      <model type="string">'. $LOOPNAME .'/lineupmarker.xml</model>
      <latitude type="double">%s</latitude>
      <longitude type="double">%s</longitude>
      <altitude type="double">%s</altitude>
      <heading type="double">%s</heading>
      <roll type="double">%s</roll>
    </entry>
' ;

#===============================================================================
#                                                                      FUNCTIONS

sub main
{
    @out = ();

    open(IN, $FILENAME_INC_HEADER_XML)
        or die "unable to open file '$FILENAME_INC_HEADER_XML' : EXIT\n" ;
    @header = <IN> ; close(IN) ;

    open(IN, $FILENAME_INC_FOOTER_XML)
        or die "unable to open file '$FILENAME_INC_FOOTER_XML' : EXIT\n" ;
    @footer = <IN> ; close(IN) ;

    open(IN, $FILENAME_IN_CSV)
        or die "unable to open file '$FILENAME_IN_CSV' : EXIT\n" ;
    @data = <IN> ; close(IN) ;

    push @out, @header ;

    $index_entrance = 0 ;
    $index_loop = 0 ;
    $index_exit = 0 ;
    $previous_no_phase = 0 ;
    for(@data)
    {
        chomp ;
        s/\n+//g;
        s/\r+//g;
        ($no_phase, $lat, $lng, $alt, $hdg, $roll) = split(':') ;

        $hdg += 90 ; $hdg %= 360 ;
        $alt *= 3.28 ;

        if($no_phase == 1)
        {
            push @out, sprintf($TPL_ENTRANCE, ++$index_entrance, $index_entrance, $lat, $lng, $alt, $hdg, $roll) ;
        }
        elsif(($no_phase == 2) && ($previous_no_phase == 1))
        {
            push @out, sprintf($TPL_START1, $lat, $lng, $alt, $hdg, $roll) ;
            push @out, sprintf($TPL_START2, $lat, $lng, $alt, $hdg, $roll) ;
        }
        elsif($no_phase == 2)
        {
            push @out, sprintf($TPL_LOOP, ++$index_loop, $index_loop, $lat, $lng, $alt, $hdg, $roll) ;
        }
        elsif(($no_phase == 3) && ($previous_no_phase == 2))
        {
            push @out, sprintf($TPL_FINISH1, $lat, $lng, $alt, $hdg, $roll) ;
            push @out, sprintf($TPL_FINISH2, $lat, $lng, $alt, $hdg, $roll) ;
        }
        elsif($no_phase == 3)
        {
            push @out, sprintf($TPL_EXIT, ++$index_exit, $index_exit, $lat, $lng, $alt, $hdg, $roll) ;
        }

        $previous_no_phase = $no_phase ;
    }

    push @out, @footer ;

    open(OUT, '>', $FILENAME_OUT_XML) or die ;
    print OUT @out ;
    close(OUT) ;
    print "file '$FILENAME_OUT_XML' generated, copy it in the fgdata/AI/ directory.\n" ;
}

#===============================================================================
#                                                                           MAIN

main() ;

### EOF


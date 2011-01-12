
#! /usr/bin/perl
package tCAD::ISOErrMsg;
use Data::Dumper;
use strict;


$RULE = {  'ISO_1' =>  { 'Message'     => 'Power of isolation control pin can be shut-off while isolation cell is power-on',
                         'Description' => '1 Ensures the isolation control signal is powered ON when the receiving domain is ON \
                                           2 Violation of this rule can cause leakage power consumption in the isolation cells  \
                                           3 Similar to Cadence Conformal Low Power Verify: ISO4',                              }, 

           'ISO_2' =>  { 'Message'     => 'Source and destination domains of the isolation cells are the same',
                         'Description' => '1 This rule can find redundant isolation cells in the netlist \
                                           2 Similar to Cadence Conformal Low Power Verify: ISO3.2',                            },

           'ISO_3' =>  { 'Message'     => 'Isolation instance location does not match isolation rule',
                         'Description' => '1 The location of the isolation cell instance is not valid based on user-specified isolation rules \
                                           2 Similar to Conformal Low Power Verify: ISORULE1.8',                                },

           'ISO_4' =>  { 'Message'     => 'Power domain crossing does not have user-defined isolation cell',
                         'Description' => '1 Report error when there is an OFF-ON/ON-OFF crossing between two power domains \
                                             that does not have a user-defined isolation cell                               \
                                           2 Netlist bug can cause tape-out failure                                         \
                                           3 Similar to Cadence Conformal Low Power Verify: ISO7',                              },

           'ISO_5' =>  { 'Message'     => 'Isolation cell control pin is not connected to the specified signal',
                         'Description' => '1 This checks that the control pin of the specified isolation instances are      \
                                             connected to the specified instance port of the corresponding isolation rules  \
                                           2 Check the connectivity of the isolation control to prevent design failure      \
                                           3 Similar to Cadence Conformal Low Power Verify: ISORULE1.1',                        },

#           'ISO_6' => { 'Message'      =>
           };

sub new {
}


1;

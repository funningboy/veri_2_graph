
#! /usr/bin/perl

package tCAD::ISORuleChk;
use tCAD::util;
#use tCAD::ISOErrMsg;
use Data::Dumper;

use strict;

sub new {
     my $class = shift;
     my $self  = {
                    util => shift,
               };
     bless $self, $class;
     return $self;
}

sub Run_Chk_ISO_4 {
    my ($self) = (@_);
}


sub Run_Chk_ISO_rules {
    my ($self,$top) = (@_);

    my $iso_rule_list = $self->{util}->{power}->{isolation_rule}; 
    my $iso_cell_list = $self->{util}->{power}->{isolation_cell};
    my $power_list    = $self->{util}->{power}->{power_domain};

   foreach my $iso_rule ( keys %{$iso_rule_list} ){
           my $from  = $iso_rule_list->{$iso_rule}->{from};
           my $to    = $iso_rule_list->{$iso_rule}->{to};

         foreach my $power_from ( @{$power_list->{$from}->{instances}} ){
            foreach my $power_to ( @{$power_list->{$to}->{instances}} ){

                       print '@ from->to :: '.$power_from.'->'.$power_to."\n";

                       $self->{util}->set_deep_list_module($top,$power_from);
                       $self->{util}->find_deep_list_module($top,$power_from);
                       $self->{util}->set_deep_list_by_from();
                       $self->{util}->free_tmp();

                       $self->{util}->set_deep_list_module($top,$power_to);
                       $self->{util}->find_deep_list_module($top,$power_to);
                       $self->{util}->set_deep_list_by_to();
                       $self->{util}->free_tmp(); 
             
                       #  print Dumper($self->{util}->{deep_list_from});
                       #  print Dumper($self->{util}->{deep_list_to});

                       my $wire = $self->{util}->is_from_to_connected();

                       #check the ISO cell @ each power domain
                       if( $wire ){
                         print Dumper($self->{util}->{deep_list_from});
                         print Dumper($self->{util}->{deep_list_to});


                             my $deep_list = $self->{util}->{deep_list_from};
                             my $deep      = $deep_list->[0];
                             my $module    = $deep->{top_name};
                             if ( $self->{util}->is_ISO_from_exist_by_module($module) == 0 ){ print 'dd\n'; } 
                             
                             my $deep_list = $self->{util}->{deep_list_from};
                             my $deep      = $deep_list->[0];
                             my $module    = $deep->{top_name};
                             if(  $self->{util}->is_ISO_to_exist_by_module($module) ==0 ){ print 'cc\n';}
                       } 
 
                 $self->{util}->free_all(); 
           }
         }
   }
 
}

1;

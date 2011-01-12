#! /usr/bin/perl

package tCAD::RunISO;
use tCAD::util;
use Data::Dumper;

use strict;

sub new {
     my $class = shift;
     my $self  = {
                    util      => shift,
                    ISOTB     => {},
                    ISORSV    => 'CPF_ISO__cell_',
                    ISORSVID  => '0',
                    ISONETID  => '0',
  };
     bless $self, $class;
     return $self;
}

sub get_iso_cell_name {
    my ($self) = (@_);
return $self->{ISORSV}.$self->{ISORSVID};
}

sub inc_iso_cell_name {
    my ($self) = (@_);
    $self->{ISORSVID}++;
}

sub get_iso_wire_name {
   my ($self,$wire) = (@_);
return $wire.'_iso_net'.$self->{ISONETID};
}

sub inc_iso_wire_name {
    my ($self) = (@_);
        $self->{ISONETID}++;
}

sub runISO_INI {
    my ($self,$top) = (@_);

    my $iso_rule_list = $self->{util}->{power}->{isolation_rule}; 
    my $iso_cell_list = $self->{util}->{power}->{isolation_cell};
    my $power_list    = $self->{util}->{power}->{power_domain};

    foreach my $iso_rule ( keys %{$iso_rule_list} ){
            my $iso_from   = $iso_rule_list->{$iso_rule}->{iso_from};
            my $iso_to     = $iso_rule_list->{$iso_rule}->{iso_to};
            my $iso_cond   = $iso_rule_list->{$iso_rule}->{iso_cond};
            my $iso_output = $iso_rule_list->{$iso_rule}->{iso_output};
            my $iso_loc    = ();

               if( $iso_output eq 'high' ){ $iso_loc = $iso_cell_list->{IsoLH}->{iso_loc}; }
            elsif( $iso_output eq 'low'  ){ $iso_loc = $iso_cell_list->{IsoHL}->{iso_loc}; }

            print '@isolation_rule:: '.$iso_rule."\n";

         foreach my $power_from ( @{$power_list->{$iso_from}->{instances}} ){
            foreach my $power_to ( @{$power_list->{$iso_to}->{instances}} ){
 
                     print "  ".'@from->to:: '.$power_from.'->'.$power_to."\n"; 

                       $self->{util}->find_deep_list_module($top,$power_from);
                       $self->{util}->set_deep_list_by_from();
                       $self->{util}->free_tmp();
                   
                       $self->{util}->find_deep_list_module($top,$power_to);
                       $self->{util}->set_deep_list_by_to();
                       $self->{util}->free_tmp(); 

                       my $wire = $self->{util}->is_from_to_connected();
              
#                           print Dumper($self->{util}->{deep_list_from});
#                           print Dumper($self->{util}->{deep_list_to});

                       if( $wire ){
                           print '    @connected found '."\n"; 
                           push ( @{$self->{ISOTB}->{$wire}}, { deep_list_from => $self->{util}->get_all_deep_list_from(),
                                                                deep_list_to   => $self->{util}->get_all_deep_list_to(),
                                                                iso_from       => $iso_from.':'.$power_from,
                                                                iso_to         => $iso_to.':'.$power_to,
                                                                iso_cond       => $iso_cond,
                                                                iso_output     => $iso_output,
                                                                iso_loc        => $iso_loc,
                                                                iso_cell_name  => '',
                                                              });   
                       }
                       $self->{util}->free_all();
              }
         }
     }
 $self->{util}->free_all();
}

sub set_new_input_by_module {
    my ($self,$cond,$top) = (@_);

    my $input_list = $self->{util}->{verilog}->{$top}->{input};
    my $input = join(',', @{$input_list});
    if( $input !~ /$cond/ ){ push (@{$self->{util}->{verilog}->{$top}->{input}}, $cond); } 
}

sub set_new_output_by_module {
    my ($self,$cond,$top) = (@_);

    my $output_list = $self->{util}->{verilog}->{$top}->{output};
    my $output = join(',', @{$output_list});
    if( $output !~ /$cond/ ){ push (@{$self->{util}->{verilog}->{$top}->{output}}, $cond); } 
}

sub set_new_wire_by_module {
    my ($self,$cond,$top) = (@_);

    my $wire_list = $self->{util}->{verilog}->{$top}->{wire};
    my $wire = join(',', @{$wire_list});
    if( $wire !~ /$cond/ ){ push (@{$self->{util}->{verilog}->{$top}->{wire}}, $cond); } 
}


sub set_new_ISOLH_cell_to_by_module {
    my ($self,$cond,$wire,$top) = (@_);

    if( !$self->{util}->{power}->{isolation_cell}->{IsoLH}        ||
         $self->{util}->is_input_exist_by_module('A','IsoLH') !=0 || 
         $self->{util}->is_input_exist_by_module('En','IsoLH')!=0 ||
         $self->{util}->is_output_exist_by_module('Y','IsoLH')!=0 ){ 
         die "RunISO->set_new_ISOLH_cell_to_by_module error\n"; }

    push ( @{$self->{util}->{verilog}->{$top}->{cell}}, { cell_name   => $self->get_iso_cell_name(),
                                                          cell_module => 'IsoLH',
                                                          cell_link   => [ { port_name => 'A',
                                                                             wire_name => $wire,  },
                                                                           { port_name => 'En',
                                                                             wire_name => $cond,  },
                                                                           { port_name => 'Y',
                                                                             wire_name => $self->get_iso_wire_name($wire), }, 
                                                                         ], 
                                                        } ); 
                                                          
}

sub set_new_ISOLH_cell_from_by_module {
    my ($self,$cond,$wire,$top) = (@_);

    if( !$self->{util}->{power}->{isolation_cell}->{IsoLH}        ||
         $self->{util}->is_input_exist_by_module('A','IsoLH') !=0 || 
         $self->{util}->is_input_exist_by_module('En','IsoLH')!=0 ||
         $self->{util}->is_output_exist_by_module('Y','IsoLH')!=0 ){ 
         die "RunISO->set_new_ISOLH_cell_from_by_module error\n"; }

    push ( @{$self->{util}->{verilog}->{$top}->{cell}}, { cell_name   => $self->get_iso_cell_name(),
                                                          cell_module => 'IsoLH',
                                                          cell_link   => [ { port_name => 'A',
                                                                             wire_name => $self->get_iso_wire_name($wire), },
                                                                           { port_name => 'En',
                                                                             wire_name => $cond,  },
                                                                           { port_name => 'Y',
                                                                             wire_name => $wire, }, 
                                                                         ], 
                                                        } ); 
                                                          
}

sub set_new_ISOHL_cell_to_by_module {
    my ($self,$cond,$wire,$top) = (@_);

    if( !$self->{util}->{power}->{isolation_cell}->{IsoHL}        ||
         $self->{util}->is_input_exist_by_module('A','IsoHL') !=0 || 
         $self->{util}->is_input_exist_by_module('En','IsoHL')!=0 ||
         $self->{util}->is_output_exist_by_module('Y','IsoHL')!=0 ){ 
         die "RunISO->set_new_ISOHL_cell_from_by_module error\n"; }

    push ( @{$self->{util}->{verilog}->{$top}->{cell}}, { cell_name   => $self->get_iso_cell_name(),
                                                          cell_module => 'IsoHL',
                                                          cell_link   => [ { port_name => 'A',
                                                                             wire_name => $wire,  },
                                                                           { port_name => 'En',
                                                                             wire_name => $cond,  },
                                                                           { port_name => 'Y',
                                                                             wire_name => $self->get_iso_wire_name($wire), }, 
                                                                         ], 
                                                        } ); 
                                                          
}

sub set_new_ISOHL_cell_from_by_module {
    my ($self,$cond,$wire,$top) = (@_);

    if( !$self->{util}->{power}->{isolation_cell}->{IsoHL}        ||
         $self->{util}->is_input_exist_by_module('A','IsoHL') !=0 || 
         $self->{util}->is_input_exist_by_module('En','IsoHL')!=0 ||
         $self->{util}->is_output_exist_by_module('Y','IsoHL')!=0 ){ 
         die "RunISO->set_new_ISOHL_cell_from_by_module error\n"; }

    push ( @{$self->{util}->{verilog}->{$top}->{cell}}, { cell_name   => $self->get_iso_cell_name(),
                                                          cell_module => 'IsoHL',
                                                          cell_link   => [ { port_name => 'A',
                                                                             wire_name => $self->get_iso_wire_name($wire), },
                                                                           { port_name => 'En',
                                                                             wire_name => $cond,  },
                                                                           { port_name => 'Y',
                                                                             wire_name => $wire, }, 
                                                                         ], 
                                                        } ); 
                                                          
}

sub set_new_cell_wire_by_module {
    my ($self,$cond,$wire,$id,$top) = (@_);

    my $cell = $self->{util}->{verilog}->{$top}->{cell}->[$id];
 
     foreach my $link ( @{$cell->{cell_link}} ){
             if( $link->{wire_name} eq $wire ){
                 $link->{wire_name} = $self->get_iso_wire_name($wire); 
             }
     }
}

sub set_new_cell_by_module {
    my ($self,$cond,$wire,$id,$top) = (@_);

    my $cell = $self->{util}->{verilog}->{$top}->{cell}->[$id];
    my $pass = 0;

     foreach my $link ( @{$cell->{cell_link}} ){
             if( $link->{wire_name} eq $cond ){ $pass=1; last; }
    }
   
    if( $pass==0 ){
        push ( @{$cell->{cell_link}}, { port_name => $cond, 
                                        wire_name => $cond,} ); 
    } 

     foreach my $link ( @{$cell->{cell_link}} ){
             if( $link->{wire_name} eq $wire ){
               return $link->{port_name}; 
             }
     }
}


sub set_insert_ISOLH_to {
    my ($self,$cond,$wire,$deep_list) = (@_);
#    print Dumper($deep_list);

    for( my $i =$#$deep_list; $i>=0; $i-- ){

         my $top = $deep_list->[$i]->{top_name};
            my $id  = $deep_list->[$i]->{cell_id};
            $self->set_new_input_by_module($cond,$top);
            $self->set_new_wire_by_module($cond,$top);
    
         #insert new cell
         if($i==0){
            $self->set_new_ISOLH_cell_to_by_module($cond,$wire,$top);            
            $self->set_new_cell_wire_by_module($cond,$wire,$id,$top);
            $self->set_new_wire_by_module($wire.$self->get_iso_wire_name(),$top);
            $self->inc_iso_wire_name();
          } else {
          # by pass the en signal 
            $wire = $self->set_new_cell_by_module($cond,$wire,$id,$top); 
           }
    }
}

sub set_insert_ISOLH_from {
    my ($self,$cond,$wire,$deep_list) = (@_);

    for( my $i =$#$deep_list; $i>=0; $i-- ){

         my $top = $deep_list->[$i]->{top_name};
            my $id  = $deep_list->[$i]->{cell_id};
            $self->set_new_input_by_module($cond,$top);
            $self->set_new_wire_by_module($cond,$top);
    
         #insert new cell
         if($i==0){
           $self->set_new_ISOLH_cell_from_by_module($cond,$wire,$top);            
            $self->set_new_cell_wire_by_module($cond,$wire,$id,$top);
            $self->set_new_wire_by_module($wire.$self->get_iso_wire_name(),$top);
            $self->inc_iso_wire_name();
          } else {
          # by pass the en signal 
            $wire = $self->set_new_cell_by_module($cond,$wire,$id,$top); 
           }
    }
}

sub set_insert_ISOHL_to {
    my ($self,$cond,$wire,$deep_list) = (@_);
#    print Dumper($deep_list);

    for( my $i =$#$deep_list; $i>=0; $i-- ){

         my $top = $deep_list->[$i]->{top_name};
            my $id  = $deep_list->[$i]->{cell_id};
            $self->set_new_input_by_module($cond,$top);
            $self->set_new_wire_by_module($cond,$top);
    
         #insert new cell
         if($i==0){
           $self->set_new_ISOHL_cell_to_by_module($cond,$wire,$top);            
            $self->set_new_cell_wire_by_module($cond,$wire,$id,$top);
            $self->set_new_wire_by_module($wire.$self->get_iso_wire_name(),$top);
            $self->inc_iso_wire_name();
          } else {
          # by pass the en signal 
            $wire = $self->set_new_cell_by_module($cond,$wire,$id,$top); 
           }
    }
}

sub set_insert_ISOHL_from {
    my ($self,$cond,$wire,$deep_list) = (@_);
#    print Dumper($deep_list);

    for( my $i =$#$deep_list; $i>=0; $i-- ){

         my $top = $deep_list->[$i]->{top_name};
            my $id  = $deep_list->[$i]->{cell_id};
            $self->set_new_output_by_module($cond,$top);
            $self->set_new_wire_by_module($cond,$top);
    
         #insert new cell
         if($i==0){
           $self->set_new_ISOHL_cell_from_by_module($cond,$wire,$top);            
            $self->set_new_cell_wire_by_module($cond,$wire,$id,$top);
            $self->set_new_wire_by_module($wire.$self->get_iso_wire_name(),$top);
            $self->inc_iso_wire_name();
          } else {
          # by pass the en signal 
            $wire = $self->set_new_cell_by_module($cond,$wire,$id,$top); 
           }
    }
}



sub runISO_OPT {
    my ($self) = (@_);

    my $isotb_list = $self->{ISOTB};
 
    foreach my $isotb (keys %{$isotb_list} ){
      foreach my $iso ( @{$isotb_list->{$isotb}} ){
                 $iso->{iso_cond} =~ s/!/INV_/g; 

            if($iso->{iso_output} eq 'high' && $iso->{iso_loc} eq 'to'){
               $self->set_insert_ISOLH_to($iso->{iso_cond},$isotb,$iso->{deep_list_to});        
        }elsif($iso->{iso_output} eq 'high' && $iso->{iso_loc} eq 'from'){
               $self->set_insert_ISOLH_from($iso->{iso_cond},$isotb,$iso->{deep_list_from});
        }elsif($iso->{iso_output} eq 'low'  && $iso->{iso_loc} eq 'to'){
               $self->set_insert_ISOHL_to($iso->{iso_cond},$isotb,$iso->{deep_list_to});        
        }elsif($iso->{iso_output} eq 'low'  && $iso->{iso_loc} eq 'from'){
               $self->set_insert_ISOHL_to($iso->{iso_cond},$isotb,$iso->{deep_list_from});        
        }
        
        $iso->{iso_cell_name} = $self->get_iso_cell_name();
        $self->inc_iso_cell_name();
       }
     }
 }

sub  runEXP_nVerilog {
    my ($self,$path) = (@_);

    my $verilog_list = $self->{util}->{verilog};  
  
    open(OVERI,">$path") or die "output veriolg error\n";

    foreach my $module ( keys %{$verilog_list} ){
            if( $self->{util}->is_cell_module_deep($module) != 0 ){
             my $input_list  = $verilog_list->{$module}->{input};
             my $output_list = $verilog_list->{$module}->{output};
             my $wire_list   = $verilog_list->{$module}->{wire};
             my $cell_list   = $verilog_list->{$module}->{cell} || [];

             my $input_st = join(', ',@{$input_list});
             my $output_st= join(', ',@{$output_list});
             my $wire_st  = join(', ',@{$wire_list});

            ($module   )? print OVERI 'module '.$module.'('.$output_st.','.$input_st.');'."\n" : ();
            ($output_st)? print OVERI 'output '.$output_st.';'."\n"                            : ();
            ($input_st )? print OVERI 'input  '.$input_st.';'."\n"                             : ();
            ($wire_st  )? print OVERI 'wire   '.$wire_st.';'."\n"                              : ();
            
            foreach my $cell ( @{$cell_list} ){
                my $tmp_st = [];
                foreach my $link ( @{$cell->{cell_link}} ){
                         if( !$link->{wire_name} ){
                              push ( @{$tmp_st}, $link->{port_name} );  
                         } else {
                              push ( @{$tmp_st}, '.'.$link->{port_name}.'('.$link->{wire_name}.')' );      
                         }
                  }
             
                        print OVERI $cell->{cell_module}.' '.$cell->{cell_name}.'('.join(', ',@{$tmp_st}).');'."\n";
       }
            ($module )? print OVERI 'endmodule'."\n"                                           : ();
                        print OVERI "\n";
    }
 }
  close(OVERI); 
}

sub runDebug {
    my ($self) = (@_);
# print Dumper($self->{ISOTB});
# print Dumper($self->{util}->{power});
# print Dumper($self->{util}->{verilog});
}


sub runReport {
    my ($self,$path) = (@_);

    my $isotb_list = $self->{ISOTB};
 
    open(ORPT,">$path") or die "output report error\n";

    foreach my $isotb (keys %{$isotb_list} ){
      foreach my $iso ( @{$isotb_list->{$isotb}} ){
              my $rpt = ($iso->{iso_loc} eq 'from')? $iso->{iso_from} : $iso->{iso_to} ;
              my ($domain,$loc) = split(':',$rpt); 
              print ORPT $loc.$iso->{iso_cell_name}."  ".$domain."\n"; 
         }
     }

close(ORPT);
} 

sub free_all {
    my ($self) = (@_);    

    $self->{ISOTB} = {};
}
1;

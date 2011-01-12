#! /usr/bin/perl

package tCAD::util;
use Data::Dumper;

use strict;

sub new {
     my $class = shift;
     my $self  = {
                    verilog => {},
                    power   => {},
                    cell    => {
                                 'or'  => '|',
                                 'and' => '&',
                                 'xor' => '^',
                                 'buf' => '=',
                                 'not' => '~',
                               },
                   top_down_list     => [],
                   top_down_stack    => [],
                   deep_module_stack => [],
                   deep_list_from    => [],
                   deep_list_to      => [],
                   power_domain_list => {},
                };
     bless $self, $class;
     return $self;
}

sub set_verilog_DD {
    my ($self,$veri) = (@_);
    if( !%{$veri} ){ die "util->set_verilog_DD error\n"; }
    $self->{verilog} = $veri;
}

sub set_power_DD {
    my ($self,$power) = (@_);
    if( !%{$power} ){ die "utril->set_power_DD error\n"; }
    $self->{power} = $power;
}

sub is_top_down_stack_empty {
   my ($self) = (@_);
   if( !@{$self->{top_down_stack}} ){ return 0; }
return -1;
}

sub push_top_down_stack {
   my ($self,$name) = (@_);
       push( @{$self->{top_down_stack}},$name);
}

sub pop_top_down_stack {
   my ($self) = (@_);
return pop( @{$self->{top_down_stack}} );
}

sub get_top_top_down_stack {
    my ($self) = (@_);
    my @tmp_st = @{$self->{top_down_stack}}; 
return  $tmp_st[$#tmp_st];
}

sub get_top_down_name {
   my ($self) = (@_);
   return join('/',@{$self->{top_down_stack}}).'/';
}

sub get_top_down_cut_name {
   my ($self) = (@_);
   my @tmp_st = @{$self->{top_down_stack}};
   pop (@tmp_st);
   return join('/',@tmp_st).'/';
}

sub push_deep_module_stack {
   my ($self,$name) = (@_);
   push ( @{$self->{deep_module_stack}},$name);
}

sub pop_deep_module_stack {
   my ($self) = (@_);
return pop ( @{$self->{deep_module_stack}});
}

sub is_deep_module_stack_empty {
   my ($self) = (@_);
    if( !@{$self->{deep_module_stack}} ){ return 0; }
return -1;
}

sub is_deep_list_from_empty {
    my ($self) = (@_);
    if( !@{$self->{deep_list_from}} ){ return 0; }
return -1;
}

sub push_deep_list_from {
    my ($self,$name) = (@_);
    push ( @{$self->{deep_list_from}},$name);
}

sub pop_deep_list_from {
    my ($self) = (@_);
return pop ( @{$self->{deep_list_from}});
}

sub get_top_deep_list_from {
    my ($self) = (@_);
    my $top = $self->pop_deep_list_from();
       $self->push_deep_list_from($top);
return $top;
}

sub get_down_deep_list_from {
    my ($self) = (@_);
return  $self->{deep_list_from}->[0];
}

sub get_all_deep_list_from {
    my ($self) = (@_);
return  $self->{deep_list_from}; 
}

sub is_deep_list_to_empty {
    my ($self) = (@_);
    if( !@{$self->{deep_list_to}} ){ return 0; }
return -1;
}

sub push_deep_list_to {
    my ($self,$name) = (@_);
    push ( @{$self->{deep_list_to}},$name);
}

sub pop_deep_list_to {
    my ($self) = (@_);
return pop ( @{$self->{deep_list_to}});
}

sub get_top_deep_list_to {
    my ($self) = (@_);
    my $top = $self->pop_deep_list_to();
       $self->push_deep_list_to($top);
return $top;
}

sub get_down_deep_list_to {
    my ($self) = (@_);
return  $self->{deep_list_to}->[0];
}

sub get_all_deep_list_to {
    my ($self) = (@_);
return  $self->{deep_list_to}; 
}


sub get_module_by_top_down {
    my ($self,$top_dwn) = (@_);

    foreach my $tp_dn ( @{$self->{top_down_list}} ){
            if($top_dwn eq $tp_dn->{top_down}){  return $tp_dn->{module}; }
    }
return ();
}

sub get_input_list_by_module {
    my ($self,$module) = (@_);

    my $top_list = $self->{verilog};
    my $in_list = [];
 
    foreach my $lv_1 ( @{$top_list->{$module}->{input}} ){     
         push ( @{$in_list}, $lv_1 );  
   }   
    return $in_list;
}

sub get_output_list_by_module {
    my ($self,$module) = (@_);

    my $top_list = $self->{verilog};
    my $out_list = [];
 
    foreach my $lv_1 ( @{$top_list->{$module}->{output}} ){     
         push ( @{$out_list}, $lv_1 );  
   }   
    return $out_list;
}

sub get_wire_list_by_module {
    my ($self,$module) = (@_);

    my $top_list = $self->{verilog};
    my $wire_list = [];
 
    foreach my $lv_1 ( @{$top_list->{$module}->{wire}} ){     
         push ( @{$wire_list}, $lv_1 );  
   }   
    return $wire_list;
}

sub get_cell_list_by_module {
    my ($self,$top) = (@_);
    
    my $top_list  = $self->{verilog};
    my $cell_list = $top_list->{$top}->{cell};
 
    return $cell_list;
}

sub is_output_exist_by_module {
    my ($self,$out,$module) = (@_);

    my $out_list = $self->get_output_list_by_module($module);

   foreach my $lv_1 ( @{$out_list} ){     
          if( $out eq $lv_1 ){ return 0; } 
   }

return -1;
}

sub is_input_exist_by_module {
    my ($self,$in,$module) = (@_);

    my $in_list = $self->get_input_list_by_module($module);
   
    foreach my $lv_1 ( @{$in_list} ){ 
          if( $in eq $lv_1 ){ return 0; } 
      }

return -1;        
}

sub is_wire_exist_by_module {
    my ($self,$wire,$module) = (@_);

    my $wire_list = $self->get_wire_list_by_module($module);

   foreach my $lv_1 ( @{$wire_list} ){     
          if( $wire eq $lv_1 ){ return 0; } 
   }

return -1;        
}

sub is_cell_module_deep {
    my ($self,$cell) = (@_);

       if( $self->{cell}->{$cell} ||
           !$cell                 ) { return 0; }

return -1;
}

sub get_top_down_list {
    my ($self,$top) = (@_);
   
    my $cell_list = $self->get_cell_list_by_module($top);
    if( !$cell_list ){
        my $name = ( $self->is_cell_module_deep($top)!=0 )? $self->get_top_down_name() : $self->get_top_down_cut_name;
        push (@{$self->{top_down_list}},$name); 
    }

    foreach my $cell (@{$cell_list}){
       my $name   = $cell->{cell_name};
       my $module = $cell->{cell_module};
    
       $self->push_top_down_stack($name);
       $self->get_top_down_list($module);
       $self->pop_top_down_stack();
    }
}

sub check_top_down_list {
   my ($self,$name) = (@_); 
   my $top_dwn_list =  $self->{top_down_list};

   foreach my $lt (@{$top_dwn_list}){
      if( $lt =~ /^$name/ ){ return 0; } 
   }  
return -1; 
}

sub check_power_domain_list {
    my ($self,$name) = (@_);
 
   my $top_dwn_list =  $self->{top_down_list};
   my $tmp_st = [];

   foreach my $lt (@{$top_dwn_list}){
      if( $lt =~ /^$name/ ){  push ( @{$tmp_st}, $lt); } 
   }  
return $tmp_st; 
}

sub get_top_down_level {
    my ($self,$name) = (@_);
    my @tmp_st = split('/',$name); 
return $#tmp_st;
}

sub get_check_power_domain_ini {
    my ($self,$top) = (@_);
        
    my $pwr_list = $self->{power}->{power_domain};
    my $tmp_st   = {};

    foreach my $pwr ( @{$pwr_list} ){
      foreach my $inst ( @{$pwr->{instances}} ){
              if( $self->check_top_down_list($inst) != 0 ){ die "util->get_check_power_domain_ini error\n"; }
       }

      foreach my $port ( @{$pwr->{boundary_ports}} ){
              if( !($self->is_input_exist_by_module($port,$top) ==0 || 
                    $self->is_wire_exist_by_module($port,$top)  ==0 ||
                    $self->is_output_exist_by_module($port,$top)==0 )){ die "util->get_cehck_power_domain_ini error\n"; }
       }
            $tmp_st->{$pwr->{name}} = { instances      => $pwr->{instances}, 
                                        boundary_ports => $pwr->{boundary_ports},
                                        default        => $pwr->{default}, };
    }

   $self->{power}->{power_domain} = $tmp_st;
} 

sub set_power_domain_list_ini {
    my ($self) = (@_);

    my $top_dwn_list = $self->{top_down_list};
 
    foreach my $inst ( @{$top_dwn_list} ){
            $self->{power_domain_list}->{$inst} = [-1,'default'];
    }
}


sub set_power_domain_list {
    my ($self,$prio,$inst,$list) = (@_);

    foreach my $lt ( @{$list} ){ 
        if( $prio >= $self->{power_domain_list}->{$lt}->[0] ){
        $self->{power_domain_list}->{$lt} = [ $prio, $inst];
        }
    }
}

sub get_check_power_domain_info {
    my ($self,$top) = (@_);

    $self->set_power_domain_list_ini();
    my $pwr_list = $self->{power}->{power_domain};

    foreach my $pwr ( keys %{$pwr_list} ){
         if( $pwr_list->{$pwr}->{default} ){
             my $top_dwn_list = $self->{top_down_list};
             $self->set_power_domain_list(-1,$pwr,$top_dwn_list);
             next;
         }
         foreach my $inst (@{$pwr_list->{$pwr}->{instances}}){
                  my $rst_list = $self->check_power_domain_list($inst);
                  my $prio     = $self->get_top_down_level($inst);
                     $self->set_power_domain_list($prio,$pwr,$rst_list);
           }
        }
}

sub get_update_power_domain_info {
    my ($self,$top) = (@_);

        $self->{power}->{power_domain} = {};

    foreach my $inst (keys %{$self->{power_domain_list}}){
            my $pwr  =  $self->{power_domain_list}->{$inst}->[1];
            push ( @{$self->{power}->{power_domain}->{$pwr}->{instances}}, $inst );
    }
}

sub get_check_isolation_rule {
    my ($self,$top) = (@_);

    my $iso_rule_list = $self->{power}->{isolation_rule};
    my $pwr_list      = $self->{power}->{power_domain};
    my $tmp_st        = {};

    foreach my $rule ( @{$iso_rule_list} ){
            my $from = $rule->{from};
            my $to   = $rule->{to};
            my $cond = $rule->{condition}; $cond =~ s/!//g;
            my $out  = $rule->{output};

            if( !$pwr_list->{$from}                    ||
                !$pwr_list->{$to}                      ||
                !($out =~ /^high$/ || $out =~/^low$/ ) ||
                 $self->is_input_exist_by_module($cond,$top)!=0 ){
                 die "util->get_check_isolation_rule error \n"; 
                 }

            $tmp_st->{$rule->{name}} = { from      => $rule->{from},
                                         to        => $rule->{to},
                                         condition => $rule->{condition},
                                         output    => $rule->{output}, };
    }
   $self->{power}->{isolation_rule} = $tmp_st;
}

sub get_check_isolation_cell {
    my ($self,$top) = (@_);
    
    my $verilog_list  = $self->{verilog};
    my $iso_cell_list = $self->{power}->{isolation_cell};
    my $tmp_st        = {};
 
   foreach my $cell ( @{$iso_cell_list} ){
           my $module = $cell->{cells};
           my $en     = $cell->{enable};
           my $loc    = $cell->{location};

           if( !$verilog_list->{$module}                 ||
               !($loc =~ /^from$/ || $loc =~ /^to$/ )    ||
                $self->is_input_exist_by_module($en,$module)!=0 ){
                die "util->get_check_isolation_cell error \n";
            }
          
           $tmp_st->{$module} = { enable   => $cell->{enable},
                                  location => $cell->{location}, };
   }

   $self->{power}->{isolation_cell} = $tmp_st;
}

#==========================
# 2 space to 1 space array
#==========================
sub get_check_input {
    my ($self) = (@_);
    my $veri_list = $self->{verilog};
 
   foreach my $veri ( keys %{$veri_list} ){
            my $input_list = $veri_list->{$veri}->{input};
            my $new_input_list = [];

             foreach my $input_1 ( @{$input_list}){
                foreach my $input_2 ( @{$input_1} ){
                    push (@{$new_input_list}, $input_2);
                }
             }
     $self->{verilog}->{$veri}->{input} = $new_input_list;
   }

}

sub get_check_output {
    my ($self) = (@_);
    my $veri_list = $self->{verilog};
 
   foreach my $veri ( keys %{$veri_list} ){
            my $output_list = $veri_list->{$veri}->{output};
            my $new_output_list = [];

             foreach my $output_1 ( @{$output_list}){
                foreach my $output_2 ( @{$output_1} ){
                    push (@{$new_output_list}, $output_2);
                }
             }
     $self->{verilog}->{$veri}->{output} = $new_output_list;
   }
}

sub get_check_wire {
    my ($self) = (@_);
    my $veri_list = $self->{verilog};
 
   foreach my $veri ( keys %{$veri_list} ){
            my $wire_list = $veri_list->{$veri}->{wire};
            my $new_wire_list = [];

             foreach my $wire_1 ( @{$wire_list}){
                foreach my $wire_2 ( @{$wire_1} ){
                    push (@{$new_wire_list}, $wire_2);
                }
             }
     $self->{verilog}->{$veri}->{wire} = $new_wire_list;
   }
}


#sub get_check_level_shifter

sub get_check_rst {
    my ($self,$top) = (@_);

        $self->get_check_input();
        $self->get_check_output();
        $self->get_check_wire();

#        $self->get_top_down_list($top);
#        $self->get_check_power_domain_ini($top);
#        $self->get_check_power_domain_info($top);
#        $self->get_update_power_domain_info($top);
#        $self->get_check_isolation_cell($top);
#        $self->get_check_isolation_rule($top); 
#        $self->get_check_level_shifter_rule($top);
}

sub check_deep_list_to {
    my ($self,$deep_list) = (@_);

    if( $self->is_deep_list_to_empty()==0 ){
        $self->push_deep_list_to($deep_list);
    }else{
        my $top            = $self->get_top_deep_list_to();
        my $deep_cell_link = $deep_list->{cell_link};
        my $tmp_list       = [];

        foreach my $cell ( @{$top->{cell_link}} ){
                my $wire_name = $cell->{wire_name};
                foreach my $dp_cell ( @{$deep_cell_link} ){
                    if( $dp_cell->{port_name} eq $wire_name ){
                        push ( @{$tmp_list}, { port_name => $dp_cell->{port_name},
                                               wire_name => $dp_cell->{wire_name},});
                    }
                }  
        }

         $self->push_deep_list_to  ( { top_name   => $deep_list->{top_name},
                                       cell_name  => $deep_list->{cell_name},
                                       cell_module=> $deep_list->{cell_module},
                                       cell_id    => $deep_list->{cell_id},
                                       cell_link  => $tmp_list, });
    }
}

#=================================
# @ pop back to the top module
#=================================
sub set_deep_list_by_to {
    my ($self) = (@_);

    while( $self->is_deep_module_stack_empty()!=0 ){
        my $tmp_list     = [];
        my $module_tb    = $self->pop_deep_module_stack();
#        print Dumper($module_tb);
        my $cell_module  = $module_tb->{cell_module};
        my $cell_link    = $module_tb->{cell_link};
        my $in_list      = $self->get_input_list_by_module($cell_module);

        foreach my $cell (@{$cell_link}){
           foreach my $in (@{$in_list}){
              if( $cell->{port_name} eq $in ){
                  push ( @{$tmp_list}, { port_name => $cell->{port_name},
                                         wire_name => $cell->{wire_name},} );
            }
           }
        }

       $self->check_deep_list_to(   { top_name   => $module_tb->{top_name},
                                      cell_name  => $module_tb->{cell_name},
                                      cell_module=> $module_tb->{cell_module},
                                      cell_id    => $module_tb->{cell_id},
                                      cell_link  => $tmp_list,   
                                    }); 
  }
}


sub check_deep_list_from {
    my ($self,$deep_list) = (@_);

    if( $self->is_deep_list_from_empty()==0 ){
        $self->push_deep_list_from($deep_list);
    }else{
        my $top            = $self->get_top_deep_list_from();
        my $deep_cell_link = $deep_list->{cell_link};
        my $tmp_list       = [];
      
        foreach my $cell ( @{$top->{cell_link}} ){
                my $wire_name = $cell->{wire_name};
               foreach my $dp_cell ( @{$deep_cell_link} ){
                      
                    if( $dp_cell->{port_name} eq $wire_name ){
                        push ( @{$tmp_list}, { port_name => $dp_cell->{port_name},
                                               wire_name => $dp_cell->{wire_name},});
                    }
                }  
        }

         $self->push_deep_list_from( { top_name   => $deep_list->{top_name},
                                       cell_name  => $deep_list->{cell_name},
                                       cell_module=> $deep_list->{cell_module},
                                       cell_id    => $deep_list->{cell_id},
                                       cell_link  => $tmp_list, });
    }
}

#=================================
# @ pop back to the top module
#=================================
sub set_deep_list_by_from {
    my ($self) = (@_);

    while( $self->is_deep_module_stack_empty()!=0 ){
        my $tmp_list     = [];
        my $module_tb    = $self->pop_deep_module_stack();
#        print Dumper($module_tb);
        my $cell_module  = $module_tb->{cell_module};
        my $cell_link    = $module_tb->{cell_link};
        my $out_list     = $self->get_output_list_by_module($cell_module);

        foreach my $cell (@{$cell_link}){
           foreach my $out (@{$out_list}){
             if( $cell->{port_name} eq $out ){
                  push ( @{$tmp_list}, { port_name => $cell->{port_name},
                                         wire_name => $cell->{wire_name}, });
            }
           }
        }
      $self->check_deep_list_from( { top_name   => $module_tb->{top_name},
                                      cell_name  => $module_tb->{cell_name},
                                      cell_module=> $module_tb->{cell_module},
                                      cell_id    => $module_tb->{cell_id},
                                      cell_link  => $tmp_list,
                                    }); 
  }
}

sub set_deep_list_module {
    my ($self,$top,$inst) = (@_);
    $self->{tmp_inst} = $inst;
}

#=================================
# @ find the deepest module && push
# @ input  I5/I6/I7
# @ return I5(module)/I6(module)/I7(module) name
#=================================
sub find_deep_list_module {
    my ($self,$top,$inst) = (@_);
     
    my $cell_list = $self->get_cell_list_by_module($top);
    if( $self->get_top_down_name() eq $inst ){
        return 0;
     }

       my $cell_id = 0;
    foreach my $cell (@{$cell_list}){
       # fit the power constrain
       my $name   = $cell->{cell_name}.'/';
       my $module = $cell->{cell_module};
       my $link   = $cell->{cell_link};

      if( $self->{tmp_inst} =~ /^$name/ ){
 
          $self->push_deep_module_stack( {  top_name    => $top,
                                            cell_name   => $name,
                                            cell_module => $module,
                                            cell_link   => $link,
                                            cell_id     => $cell_id,} );

           $self->push_top_down_stack($name);
           $self->{tmp_inst} =~ s/^(\w+)\///g;
           $self->find_deep_list_module($module,$inst);
           $self->pop_top_down_stack();
       }
        $cell_id++;
    }
}


sub is_from_to_connected {
    my ($self) = (@_);
    my  $top_list_from = $self->get_top_deep_list_from();
    my  $top_list_to   =  $self->get_top_deep_list_to();

    foreach my $from ( @{$top_list_from->{cell_link}} ){
      foreach my $to ( @{$top_list_to->{cell_link}} ){
         if( $from->{wire_name} eq $to->{wire_name} ){
           return $from->{wire_name};
         } 
     }
   }
return ();
}


sub is_ISO_from_exist_by_module {
   my ($self,$top) = (@_);

   my $cell_list     = $self->get_cell_list_by_module($top);
   my $iso_cell_list = $self->{power}->{isolation_cell};
 
   foreach my $cell (@{$cell_list}){
      if( $iso_cell_list->{$cell} ){
      if($iso_cell_list->{$cell}->{location} eq 'from' ){ return 0; }
    }
  }
return -1;
}

sub is_ISO_to_exist_by_module {
   my ($self,$top) = (@_);

   my $cell_list     = $self->get_cell_list_by_module($top);
   my $iso_cell_list = $self->{power}->{isolation_cell};
 
   foreach my $cell (@{$cell_list}){
      if( $iso_cell_list->{$cell} ){
      if($iso_cell_list->{$cell}->{location} eq 'to' ){ return 0; }
    }
  }
return -1;
}

sub free_tmp {
    my ($self) = (@_); 

    $self->{top_down_stack}    = [];
    $self->{deep_module_stack} = [];

}

sub get_debug {
    my ($self) = (@_);

print Dumper($self->{power});
#print Dumper($self->{verilog});
#die;
} 

sub free_all {
    my ($self) = (@_); 

    $self->{top_down_list}     = [],
    $self->{top_down_stack}    = [];
    $self->{deep_module_stack} = [];
    $self->{deep_list_from}    = [];
    $self->{deep_list_to}      = [];
    $self->{power_domain_list} = {}; 
}

1;

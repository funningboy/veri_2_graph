#!/usr/bin/perl

package tCAD::GRAPH;
use tCAD::DFG;
use tCAD::util;
use Data::Dumper;
use strict;

sub new {
 my $class = shift;
 my $self = { util        => shift,
              Graph_list  => {},
              verilog     => {},
              wire_tb     => {},
           }; 
 bless $self, $class;
 return $self;
}

sub free_wire_tb {
    my ($self) = (@_);
        $self->{wire_tb} = {};
}

sub push_wire_from_tb {
   my ($self,$key,$val) = (@_);
   push (@{$self->{wire_tb}->{$key}->{from}},$val);
}

sub push_wire_to_tb {
   my ($self,$key,$val) = (@_);
   push (@{$self->{wire_tb}->{$key}->{to}},$val);
}

sub get_wire_tb {
   my ($self,$key) = (@_);
return $self->{wire_tb};   
}


sub dump_graphviz_by_module {
   my ($self,$module,$path) = (@_);
   $self->{Graph_list}->{$module}                            || die "dump_graphviz_by_module error \@moulde \n";
   $self->{Graph_list}->{$module}->dump_graphviz_file($path) || die "dump_graphviz_by_module error\n";
}


sub run_deep_graph_by_module {
    my ($self,$module,$deep) = (@_);
    $self->{Graph_list}->{$module}                           || die "run_deep_graph_by_module error \@module\n";

  
  print Dumper($self->{Graph_list}->{'T10_iso2'});

  #foreach
  #      $self->{Graph_list}->{$module}->get_vertex_nxt_stack($);  
  #  foreach my $child (@{$child_list}){
  #          my $cell_name  = $self->{Graph_list}->{$child}->{cell_name};
  #          my $cell_module= $self->{Graph_list}->{$child}->{cell_module};
  #          
  #          $self->{Graph_list}->{$cell_module}                
  #  }
}

sub run_graph_DD {
   my ($self) = (@_);

   my $verilog_list = $self->{util}->{verilog}               || die "run_graph_DD error \@verilog_list\n"; 
#   print Dumper($verilog_list);
 
   # set vertices by each module
   foreach my $module (keys %{$verilog_list}){
                 if( !$self->{Graph_list}->{$module} ){ 
                      $self->{Graph_list}->{$module} = tCAD::DFG->new();
                 }             

      foreach my $input (@{$verilog_list->{$module}->{input}}){
#              my $in_vertex = $module.'/'.$input;
               my $in_vertex = ':'.$input;
                 $self->{Graph_list}->{$module}->set_time_weighted_vertex($in_vertex,0); 
                 $self->{Graph_list}->{$module}->push_input_list($in_vertex);
                 $self->push_wire_from_tb($input,$in_vertex);
       }
   
      foreach my $output (@{$verilog_list->{$module}->{output}}){
#              my $out_vertex = $module.'/'.$output;
               my $out_vertex = ':'.$output;
                 $self->{Graph_list}->{$module}->set_time_weighted_vertex($out_vertex,0);
                 $self->{Graph_list}->{$module}->push_output_list($out_vertex);
                 $self->push_wire_to_tb($output,$out_vertex);
       }

      foreach my $cell (@{$verilog_list->{$module}->{cell}}){
              my $cell_name   = $cell->{cell_name};
              my $cell_module = $cell->{cell_module};
#              my $cell_vertex = $module.'/'.$cell_name;
              my $cell_vertex = $cell_name;

                 $self->{Graph_list}->{$module}->set_time_weighted_vertex($cell_vertex,0);

                 if( !$self->{Graph_list}->{$cell_module} ){ 
                      $self->{Graph_list}->{$cell_module} = tCAD::DFG->new();
                 }

                 # check the deepest module or not
                 if ( $self->{util}->is_cell_module_deep($cell_module) == 0 ){
                       my $i =0;
                       foreach my $link (@{$cell->{cell_link}}){
                               my $wire = $link->{wire_name} || ();
                               my $port = $link->{port_name} || ();
                               if($i==0){
                                  $self->push_wire_from_tb($port,$cell_vertex); $i++;
                               } else {
                                  $self->push_wire_to_tb($port,$cell_vertex);
                               }
                         }
                #    
               } else {
                       foreach my $link (@{$cell->{cell_link}}){
                               my $wire = $link->{wire_name} || ();
                               my $port = $link->{port_name} || ();
                         
                               if( $self->{util}->is_input_exist_by_module($port,$cell_module)==0 ){ 
                                   if( $wire ){ 
                                       $self->push_wire_to_tb($wire,$cell_vertex);
                                   } else {
                                       $self->push_wire_to_tb($port,$cell_vertex);
                                   }
                                } else {
                                   if( $wire ){
                                       $self->push_wire_from_tb($wire,$cell_vertex);
                                   } else {
                                       $self->push_wire_from_tb($port,$cell_vertex);
                                   }
                                }
                           } 
                     }
           }
     
         my $wire_list = $self->get_wire_tb();
#         print Dumper($wire_list);

         # set edges by each module
         foreach my $wire (keys %{$wire_list}){
            foreach my $from ( @{$wire_list->{$wire}->{from}} ){
              foreach my $to ( @{$wire_list->{$wire}->{to}} ){
                $self->{Graph_list}->{$module}->set_time_weighted_edge($from,$to,0);
                }
             }
           }   
          $self->free_wire_tb();
      }
}

sub rpt_paths_by_from_to {
   my ($self,$from,$to) = (@_);


}



1;

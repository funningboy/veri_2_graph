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


sub dump_graphviz_file {
   my ($self,$path) = (@_);
   $self->{Graph_list}->dump_graphviz_file($path) || die "dump_graphviz_by_module error\n";
}



sub set_graph_input_vertices {
    my ($self,$name,$module) = (@_);
    my $verilog_list = $self->{util}->{verilog}; 

    foreach my $input (@{$verilog_list->{$module}->{input}}){
            my $in_vertex = $name.$input;
              $self->{Graph_list}->set_time_weighted_vertex($in_vertex,0);
              $self->push_wire_from_tb($in_vertex,$in_vertex);
    }
}

sub set_graph_output_vertices {
    my ($self,$name,$module) = (@_);
    my $verilog_list = $self->{util}->{verilog}; 

      foreach my $output (@{$verilog_list->{$module}->{output}}){
              my $out_vertex = $name.$output;
                 $self->{Graph_list}->set_time_weighted_vertex($out_vertex,0);
                 $self->push_wire_to_tb($out_vertex,$out_vertex);
       }
}

sub set_graph_cell_vertices {
    my ($self,$name,$module) = (@_);
    my $verilog_list = $self->{util}->{verilog}; 

      foreach my $nw_cell (@{$verilog_list->{$module}->{cell}}){
              my $nw_cell_name   = $nw_cell->{cell_name};
              my $nw_cell_module = $nw_cell->{cell_module};
              my $nw_cell_link   = $nw_cell->{cell_link};
              my $hit            = 0;

              my $cell_define    = $name.$nw_cell_name.'/';
              if( !$self->{cell_define}->{$cell_define} ){ 
                my $nw_cell_vertex = $cell_define.'::'.$nw_cell_module;
                   $self->{Graph_list}->set_time_weighted_vertex($nw_cell_vertex,0);

                foreach my $link (@{$nw_cell_link}){
                        my $lk_cell_port   = $link->{port_name};
                        my $lk_cell_wire   = $link->{wire_name} || $link->{port_name};
                        my $wire = $name.$lk_cell_wire;

                        # deep module case
                        if($self->{util}->is_cell_module_deep($nw_cell_module)==0){
                              if($hit==0){
                                $self->push_wire_from_tb($wire,$nw_cell_vertex); $hit=1;
                              } else {
                                $self->push_wire_to_tb($wire,$nw_cell_vertex);
                             } 
                        # normal case
                        } else {
                              if( $self->{util}->is_output_exist_by_module($lk_cell_port,$nw_cell_module)==0 ){
                                $self->push_wire_from_tb($wire,$nw_cell_vertex);
                              } else {
                                $self->push_wire_to_tb($wire,$nw_cell_vertex);
                              }
                        }
                 }
              } else {
        
                foreach my $link (@{$nw_cell_link}){
                        my $lk_cell_port   = $link->{port_name};
                        my $lk_cell_wire   = $link->{wire_name} || $link->{port_name};
                        my $wire = $name.$lk_cell_wire;

                        my $nw_cell_vertex = $name.$nw_cell_name.'/'.$lk_cell_port;

                        if( $self->{util}->is_output_exist_by_module($lk_cell_port,$nw_cell_module)==0 ){
                            $self->push_wire_from_tb($wire,$nw_cell_vertex);
                        } else {
                            $self->push_wire_to_tb($wire,$nw_cell_vertex);
                        }
                     
              }
          }
 
     }

     $self->{cell_define}->{$name} = 1;
}

sub set_graph_wire_edges {
   my ($self) = (@_);

   my $wire_list = $self->get_wire_tb();
#    print Dumper($wire_list);

   # set edges by each module
   foreach my $wire (keys %{$wire_list}){
      foreach my $from ( @{$wire_list->{$wire}->{from}} ){
        foreach my $to ( @{$wire_list->{$wire}->{to}} ){
          $self->{Graph_list}->set_time_weighted_edge($from,$to,0);
          }
       }
     }   
    $self->free_wire_tb();
}

sub run_graph_DD {
   my ($self,$top,$deep) = (@_);

  my $top_dwn_list = $self->{util}->{top_down_list};

   my @tp_dwn_key   = sort keys %{$top_dwn_list};

   if( $deep!=-1 && $#tp_dwn_key>$deep ){
      for(my $i = $deep+1; $i<=$#tp_dwn_key; $i++){
         delete $top_dwn_list->{$i};
      }
   }

   $self->{Graph_list} = tCAD::DFG->new();

   # set vertices by each module
   foreach my $lvl (reverse sort keys %{$top_dwn_list}){
      foreach my $list (@{$top_dwn_list->{$lvl}}){                
              my $cell_name   = $list->{cell_name};
              my $cell_module = $list->{cell_module};
              
              $self->set_graph_input_vertices($cell_name,$cell_module);
              $self->set_graph_output_vertices($cell_name,$cell_module);
              $self->set_graph_cell_vertices($cell_name,$cell_module);
              $self->set_graph_wire_edges();
      }
   }
}

1;

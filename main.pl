
#=============================================#
# gate level verilog 2 graph viewer 
# author : sean chen
# mail : funningboy@gmail.com
# license: FBS
# publish: 2011/01/12 v1
#=============================================#


use tCAD::PowerParser;
use tCAD::VeriParser;
use tCAD::util;
use tCAD::GRAPH;
use tCAD::ISORuleChk;

use strict;
use Data::Dumper;

my $veri_ptr  = tCAD::VeriParser->new();
my $veri_rst  = $veri_ptr->parser_files('tt.v');

my $util_ptr  = tCAD::util->new();
   $util_ptr->set_verilog_DD($veri_rst);
   $util_ptr->get_check_rst('T10_iso2');
   $util_ptr->get_debug();

my $graph_ptr = tCAD::GRAPH->new($util_ptr);
   $graph_ptr->run_graph_DD('T10_iso2',-1);
   $graph_ptr->dump_graphviz_file('T10.dot');


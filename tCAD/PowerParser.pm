#!/usr/bin/perl

package tCAD::PowerParser;
use Parse::RecDescent;
use Data::Dumper;
use strict;

#    $::RD_TRACE=1;        # if defined, also trace parsers' behaviour
#    $::RD_AUTOSTUB=1;     # if defined, generates "stubs" for undefined rules
#    $::RD_AUTOACTION=1;   # if defined, appends specified action to productions
#    $::RD_HINT=1;

my $InPowerGrammar = q {

{
use Data::Dumper;
my  $InPowerTb ={};
my  $TmpTb     ={};
}

START			: TOKEN_POWER_DOMAIN START(s?)
			{
			 $return = $item[1];
			} 
			| TOKEN_ISO_RULE START(s?)
			{
			 $return = $item[1];
			}
			| TOKEN_ISO_CELL START(s?)
			{
			 $return = $item[1];
			}
			| TOKEN_NOMINAL_CONDITION START(s?) 
			{
			 $return = $item[1];
			}
			| TOKEN_POWER_MODE START(s?)
			{
			 $return = $item[1];
			}
			| TOKEN_LVL_SHFT_CELL START(s?)
			{
			 $return = $item[1];
			}
			| TOKEN_LVL_SHFT_RULE START(s?)
			{
			 $return = $item[1];
			}

TOKEN_ISO_CELL		: 'define_isolation_cell' SLASH(?) TOKEN_ISO_CELL_LIST(s?)
			{
			   push (@{$InPowerTb->{isolation_cell}},$item[3]->[0]);
			   $return = $InPowerTb;
			   $TmpTb  = {};
			}

TOKEN_ISO_CELL_LIST	: '-cells' LFT_BRACES(?) IDENTIFIER RHT_BRACES(?) SLASH(?)
			{
			  $TmpTb->{cells}    = $item[3];
			  $return = $TmpTb;
			}
			| '-enable' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{enable}   = $item[2];
			  $return = $TmpTb; 
			}
			| '-valid_location' IDENTIFIER SLASH(?) 
			{
			  $TmpTb->{location} = $item[2];
			  $return = $TmpTb;
			}

TOKEN_ISO_RULE		: 'create_isolation_rule' SLASH(?) TOKEN_ISO_RULE_LIST(s?)
			{
			  push (@{$InPowerTb->{isolation_rule}},$item[3]->[1]);
			  $return = $InPowerTb;
			  $TmpTb  = {};
			}

TOKEN_ISO_RULE_LIST	: '-name' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{name} = $item[2];
			  $return = $TmpTb;
			}
			| '-from' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{from} = $item[2];
			  $return = $TmpTb;
			}
			| '-to' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{to} = $item[2];
			  $return = $TmpTb;
			}
			| '-isolation_output' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{output} = $item[2];
			  $return = $TmpTb;
			}
			| '-isolation_condition' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{condition} = $item[2];
			  $return = $TmpTb;
			}

TOKEN_POWER_DOMAIN	: 'create_power_domain' SLASH(?) TOKEN_POWER_DOMAIN_LIST(s?)
			{
			  push (@{$InPowerTb->{power_domain}}, $item[3]->[0]);
			  $return = $InPowerTb;
			  $TmpTb ={};
			}

TOKEN_POWER_DOMAIN_LIST	: '-name' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{name} = $item[2];
			  $return = $TmpTb;
			} 
			| '-default' SLASH(?)
			{
			  $TmpTb->{default}  = 'default';
			  $return = $TmpTb;
			}
			| '-instances' LFT_BRACES IDENTIFIER(s?) RHT_BRACES SLASH(?)
			{
			  #=========================
			  # hack constrain 2 our DD ex: I1/I2 -> I1/I2/
			  #=========================
			  my $tmp_st;
                          foreach my $inst (@{$item[3]}){
			       $inst .= '/';
			       push (@{$tmp_st},$inst);
			  }
			  $TmpTb->{instances} = $tmp_st;
			  $return = $TmpTb;
			}
			| '-boundary_ports' LFT_BRACES IDENTIFIER(s?) RHT_BRACES SLASH(?)
			{
			  my $tmp_st;
                          foreach my $inst (@{$item[3]}){
			   #    $inst .= ':';
			       push (@{$tmp_st},$inst);
			  }
			  $TmpTb->{boundary_ports} = $tmp_st;
			  $return = $TmpTb;
			}

TOKEN_NOMINAL_CONDITION	: 'create_nominal_condition' TOKEN_NOR_CND_LIST(s?)
			{
			  push (@{$InPowerTb->{nominal_condition}}, $item[2]->[0]);
			  $return = $InPowerTb;
			  $TmpTb  = {};
			}

TOKEN_NOR_CND_LIST	: '-name' IDENTIFIER SLASH(?)
			{
			  $TmpTb->{name} = $item[2];
			  $return = $TmpTb;
			}
			|  '-voltage' FLOAT SLASH(?)
			{
			  $TmpTb->{voltage} = $item[2];
			  $return = $TmpTb;
			}

TOKEN_POWER_MODE	: 'create_power_mode' TOKEN_POWER_MODE_LIST(s?)
			{
			 push (@{$InPowerTb->{power_mode}},$item[2]->[0]);
			 $return = $InPowerTb;
			 $TmpTb  = {};
			}

TOKEN_POWER_MODE_LIST	: '-name' IDENTIFIER SLASH(?){
			  $TmpTb->{name} = $item[2];
			  $return = $TmpTb;
			}
			| '-domain_conditions' LFT_BRACES(?) TOKEN_PWR_CND_LIST(s?) RHT_BRACES(?) SLASH(?)
			{
			  $TmpTb->{domain_conditions} = $item[3];
			  $return = $TmpTb;
			} 
			| '-default' SLASH(?)
			{
			  $TmpTb->{default} = 'default';
			  $return = $TmpTb;
			}

TOKEN_PWR_CND_LIST	: IDENTIFIER '@' IDENTIFIER SLASH(?)
			{
			  $return = { $item[1] => $item[3] };
			}

TOKEN_LVL_SHFT_CELL	: 'define_level_shifter_cell' TOKEN_LVL_SHFT_CELL_LIST(s?)
			{
			 push(@{$InPowerTb->{level_shifter_cell}},$item[2]->[0]);
			 $return = $InPowerTb;
			 $TmpTb  = {};
			}

TOKEN_LVL_SHFT_CELL_LIST: '-cells' LFT_BRACES(?) IDENTIFIER(s?) RHT_BRACES(?) SLASH(?)
			{
			 $TmpTb->{cells} = $item[3];
			 $return = $TmpTb;
			}
			| '-input_voltage_range' FLOAT ':' FLOAT SLASH(?)
			{
			 $TmpTb->{input_voltage_range} = { begin => $item[2],
			                                   end   => $item[4], };
			 $return = $TmpTb; 
			}
			| '-output_voltage_range' FLOAT ':' FLOAT SLASH(?)
			{
			 $TmpTb->{output_voltage_range} = { begin => $item[2],
			                                    end   => $item[3], };
			 $return = $TmpTb;
			}
			| '-direction' IDENTIFIER SLASH(?)
			{
			 $TmpTb->{direction} = $item[2];
			 $return = $TmpTb;
			}
			| '-valid_location' IDENTIFIER SLASH(?)
			{
			 $TmpTb->{valid_location} = $item[2];
			 $return = $TmpTb;
			}

TOKEN_LVL_SHFT_RULE	: 'create_level_shifter_rule'  TOKEN_LVL_SHFT_RULE_LIST SLASH(?)
			{
			 push (@{$InPowerTb->{level_shift_rule}},$item[2]);
			 $return = $InPowerTb;
			 $TmpTb = {};
			}

TOKEN_LVL_SHFT_RULE_LIST:'-name' IDENTIFIER SLASH(?)
			{
			 $TmpTb->{name} = $item[2];
			 $return = $TmpTb;
			}
			| '-from' IDENTIFIER SLASH(?)
			{
			 $TmpTb->{from} = $item[2];
			 $return = $TmpTb;
			}
			| '-to'   IDENTIFIER SLASH(?)
			{
			 $TmpTb->{to} = $item[2];
			 $return = $TmpTb; 
			}


LFT_BRACKET		: '['   { $return = $item[1]; }
RHT_BRACKET		: ']'   { $return = $item[1]; }
LFT_BRACES		: '{'   { $return = $item[1]; }
RHT_BRACES		: '}'   { $return = $item[1]; }
OR			: '|'   { $return = $item[1]; }
SLASH			: '\\'  { $return = $item[1]; }

IDENTIFIER		: /[\!0-9a-zA-Z\/\_]+/ { $return = $item[1]; }
FLOAT			: /[0-9\.]+/           { $return = $item[1]; }

};

sub new {
    my $class = shift;
    my $self = {};
  
   bless $self, $class;
   return $self;
} 

sub parser_files { 
    my ($self,$path) = (@_);

    open(IPWER,$path) or die "input Power error\n";
    undef $/;
    my $text = <IPWER>;

    my $parse = new Parse::RecDescent($InPowerGrammar) or die 'InPowerGrammar';
    my $parse_tree = $parse->START($text) or die 'Power';
#    print Dumper($parse_tree);

   close(IPWER);
   return $parse_tree;
}

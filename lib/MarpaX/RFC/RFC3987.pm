package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - Marpa Parser

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::BNF;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      BNF_section_data     => MarpaX::RFC::RFC3987::BNF->section_data('BNF'),
      #
      # Only because action rules are hardcoded in the grammar
      #
      _marpa_authority     => '_marpa_iauthority',
      _marpa_path          => '_marpa_ipath',
      _marpa_query         => '_marpa_iquery',
      _marpa_fragment      => '_marpa_ifragment',
      _marpa_hier_part     => '_marpa_ihier_part',
      _marpa_userinfo      => '_marpa_iuserinfo',
      _marpa_host          => '_marpa_ihost',
      _marpa_relative_part => '_marpa_irelative_part',
      _marpa_reg_name      => '_marpa_ireg_name',
      #
      # Rules on which Syntax-based normalization depend
      #
      '<path abempty>'     => '<ipath abempty>',
      '<path absolute>'    => '<ipath absolute>',
      '<path noscheme>'    => '<ipath noscheme>',
      '<path rootless>'    => '<ipath rootless>',
      '<path empty>'       => '<ipath empty>',
     };

1;

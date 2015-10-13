use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

use Moo;
extends 'MarpaX::RFC::RFC3987::_common';

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic'
  => {

      package     => __PACKAGE__,
      BNF_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      start       => '<IRI reference>',
      G1 => {
             '<ihier_part>' => sub { $_[0]->hier_part($_[1]) },
             '<iquery>'     => sub { $_[0]->query    ($_[1]) },
             '<iauthority>' => sub { $_[0]->authority($_[1]) },
             '<iuserinfo>'  => sub { $_[0]->userinfo ($_[1]) },
             '<ihost>'      => sub { $_[0]->host     ($_[1]) },
             '<iport>'      => sub { $_[0]->port     ($_[1]) },
            }
     };

1;

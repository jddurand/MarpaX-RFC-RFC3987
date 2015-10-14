use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_common;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax implementation

# VERSION

# AUTHORITY

use Moo;
BEGIN {
  extends 'MarpaX::RFC::RFC3987';
}
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common'
  => {
      package     => __PACKAGE__,
      BNF_package => 'MarpaX::RFC::RFC3987::_common::BNF',
      start       => '<common>',
      G1 => {
             '<scheme>'   => sub { $_[0]->scheme  ($_[1]) },
             '<opaque>'   => sub { $_[0]->opaque  ($_[1]) },
             '<fragment>' => sub { $_[0]->fragment($_[1]) },
            }
     };

1;

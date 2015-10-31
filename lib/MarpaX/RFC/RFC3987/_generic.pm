use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      #
      # Because class is done at compiled time, and we want to say that
      # Generic is extending Common. But 'extends' is a keyword that is
      # not processed at compile time. Basically I wanted to avoid writing
      # this:
      #
      # BEGIN { extends 'MarpaX::RFC::RFC3987::_common' }
      #
      extends     => [qw/MarpaX::RFC::RFC3987::_common/]
     };

1;


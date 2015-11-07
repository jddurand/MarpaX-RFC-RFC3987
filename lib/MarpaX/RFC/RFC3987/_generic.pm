use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;

extends 'MarpaX::RFC::RFC3987::_common';

with 'MarpaX::RFC::RFC3987::_generic::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic';

1;


use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;

with 'MarpaX::RFC::RFC3987::_generic::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic';

extends 'MarpaX::RFC::RFC3987::_common';

1;


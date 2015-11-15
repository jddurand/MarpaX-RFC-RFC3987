use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::_generic;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_common';
with 'MarpaX::RFC::RFC3987::Role::_generic::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic';

1;


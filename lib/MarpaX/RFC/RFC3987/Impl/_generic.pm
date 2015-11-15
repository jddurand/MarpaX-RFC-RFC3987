use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::_generic;
use Moo;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic implementation

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_generic::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic';

1;


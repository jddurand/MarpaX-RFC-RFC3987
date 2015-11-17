use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::_generic;
use Moo;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic implementation

# VERSION

# AUTHORITY

extends 'MarpaX::RFC::RFC3987::Impl::_common';

with 'MarpaX::RFC::RFC3987::Role::_generic';

1;


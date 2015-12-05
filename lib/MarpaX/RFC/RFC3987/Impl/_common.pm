use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::_common;
use Moo;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common implementation

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_common';
with 'MarpaX::RFC::RFC3987::Role::_common::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common';

1;

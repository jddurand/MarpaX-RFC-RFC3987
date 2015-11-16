use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::Plugins::ftp;
use Moo;

# ABSTRACT: Internationalized Resource Identifier (IRI): ftp implementation

# VERSION

# AUTHORITY

#
# I could have said:
# extends 'MarpaX::RFC::RFC3987::Impl::_generic';
# but this will trigger parent creation as well, an unnecessary overhead
#

with 'MarpaX::RFC::RFC3987::Role::_generic::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::ftp';

1;


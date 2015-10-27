use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_top;

# ABSTRACT: Internationalized Resource Identifier (IRI): top level implementation

# VERSION

# AUTHORITY

#
# There are hacks like MooX::Failover
# Neverthless, I believe it is more portable just to write it
# in the old way
#
use parent qw/MarpaX::Role::Parameterized::ResourceIdentifier::_top/;

1;


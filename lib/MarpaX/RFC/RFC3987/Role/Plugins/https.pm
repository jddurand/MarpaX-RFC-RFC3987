use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::Plugins::https;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): https plugin role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::Plugins::http';

around build_default_port => sub { 443 };

1;


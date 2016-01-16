use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::Plugins::http;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): http plugin role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_generic';

around build_default_port => sub { 80 };

1;


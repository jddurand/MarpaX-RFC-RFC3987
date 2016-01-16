use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::Plugins::ldaps;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): ldaps plugin role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::Plugins::ldap';

around build_default_port => sub { 636 };

1;


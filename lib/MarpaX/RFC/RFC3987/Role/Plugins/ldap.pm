use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::Plugins::ldap;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): ldap plugin role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_generic';

around build_default_port => sub { 389 };

1;


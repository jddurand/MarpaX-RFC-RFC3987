use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::Plugins::ftp;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): ftp plugin role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::_generic';

around build_default_port => sub { 21 };

1;


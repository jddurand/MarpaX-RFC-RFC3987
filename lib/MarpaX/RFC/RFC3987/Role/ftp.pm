use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::ftp;
use Moo::Role;

# ABSTRACT: Internationalized Resource Identifier (IRI): ftp Role

# VERSION

# AUTHORITY

with 'MarpaX::RFC::RFC3987::Role::ftp::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::ftp';

1;


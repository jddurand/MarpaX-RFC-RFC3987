use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::Plugins::https;

# ABSTRACT: Internationalized Resource Identifier (IRI): https implementation

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::Impl::Plugins::http;

#
# Scheme registration
#
sub can_scheme { my ($class, $scheme) = @_; $scheme =~ /\Ahttps\z/i }

our ($ROLE_PARAMS);
BEGIN {
  $ROLE_PARAMS = MarpaX::RFC::RFC3987::Impl::Plugins::http->role_params_clone;
  $ROLE_PARAMS->{whoami}  = __PACKAGE__;
  $ROLE_PARAMS->{start}   = '<https>';
  $ROLE_PARAMS->{bnf}     =~ s/\bhttp\b/https/g;
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

with 'MarpaX::RFC::RFC3987::Role::Plugins::https';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::https';

1;

use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::Plugins::ldaps;

# ABSTRACT: Internationalized Resource Identifier (IRI): ldaps implementation

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::Impl::Plugins::ldap;

#
# Scheme registration
#
sub can_scheme { my ($class, $scheme) = @_; $scheme =~ /\Aldaps\z/i }

our ($ROLE_PARAMS);
BEGIN {
  $ROLE_PARAMS = MarpaX::RFC::RFC3987::Impl::Plugins::ldap->role_params_clone;
  $ROLE_PARAMS->{whoami}  = __PACKAGE__;
  $ROLE_PARAMS->{start}   = '<ldapsurl>';
  $ROLE_PARAMS->{bnf}     =~ s/'ldap'/'ldaps'/g;
  $ROLE_PARAMS->{bnf}     =~ s/\bldapurl\b/ldapsurl/g;
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

with 'MarpaX::RFC::RFC3987::Role::Plugins::ldaps';

1;

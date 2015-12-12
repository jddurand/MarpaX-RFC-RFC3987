use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Impl::Plugins::ldap;

# ABSTRACT: Internationalized Resource Identifier (IRI): ldap implementation

# VERSION

# AUTHORITY

use Carp qw/croak/;
use File::ShareDir::ProjectDistDir 1.0 qw/dist_dir/, strict => 1;
use File::Spec qw//;
use IO::File qw//;
use MarpaX::RFC::RFC3987::Impl::_generic;
use Moo;
#
# Scheme registration
#
sub can_scheme { my ($class, $scheme) = @_; $scheme =~ /\Aldap\z/i }

our ($ROLE_PARAMS);
BEGIN {
  # ---
  # BNF: ldap BNF "inherits" from _generic BNF
  # ---
  my $bnf_file   = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), 'ldap.bnf');
  my $fh         = IO::File->new($bnf_file, 'r');
  my $BNF        = do { local $/; <$fh> };
  $bnf_file      = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), '_generic.bnf');
  $fh            = IO::File->new($bnf_file, 'r');
  $BNF          .= do { local $/; <$fh> };
  $BNF =~ /\A(.*)\z/s || croak 'Failed to untaint';
  $BNF = $1; # We trust our BNF
  # ---------
  # For reuse
  # ---------
  $ROLE_PARAMS = MarpaX::RFC::RFC3987::Impl::_generic->role_params_clone;
  #
  # Overwrite/amend our specifics
  #
  $ROLE_PARAMS->{whoami}      = __PACKAGE__;
  $ROLE_PARAMS->{extends}     = 'MarpaX::RFC::RFC3987::Impl::_generic';
  $ROLE_PARAMS->{start}       = '<ldapurl>';
  $ROLE_PARAMS->{bnf}         = $BNF;
  $ROLE_PARAMS->{server}      = 1;
  $ROLE_PARAMS->{userpass}    = 1;
  $ROLE_PARAMS->{mapping}     = {
                                 '<dn>'         => 'dn',
                                 '<question>'   => 'question',
                                 '<attributes>' => 'attributes',
                                 '<attrdesc>'   => 'attrdesc',
                                 '<scope>'      => 'scope',
                                 '<filter>'     => 'filter',
                                 '<extensions>' => 'extensions',
                                 '<extension>'  => 'extension',
                                };
  $ROLE_PARAMS->{struct_ext} = sub {
    my $struct = {
                  dn         => '',
                  question   => '',
                  attributes => '',
                  attrdesc   => [],
                  scope      => 'base',
                  filter     => '(objectClass=*)',
                  extensions => '',
                  extension  => [],
                 };
    #
    # Extending parent structure would have been done like this:
    #
    # my ($struct) = @_;
    # $struct->{user} = undef;
    # $struct->{password} = undef;
    $struct
  };
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

with 'MarpaX::RFC::RFC3987::Role::Plugins::ldap';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::ldap';

1;

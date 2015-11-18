use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::ftp::BNF;

# ABSTRACT: Internationalized Resource Identifier (IRI): ftp BNF role

# VERSION

# AUTHORITY

use MarpaX::RFC::RFC3987::Role::_generic::BNF;
use File::ShareDir::ProjectDistDir 1.0 qw/dist_dir/, strict => 1;
use File::Spec qw//;
use IO::File qw//;
use Moo::Role;
use Taint::Util;

our ($ROLE_PARAMS);
BEGIN {
  # ---
  # BNF: ftp BNF "inherits" from _generic BNF
  # ---
  my $bnf_file   = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), 'ftp.bnf');
  my $fh         = IO::File->new($bnf_file, 'r');
  my $BNF        = do { local $/; <$fh> };
  $bnf_file      = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), '_generic.bnf');
  $fh            = IO::File->new($bnf_file, 'r');
  $BNF          .= do { local $/; <$fh> };
  untaint $BNF;
  # ---------
  # For reuse
  # ---------
  $ROLE_PARAMS = MarpaX::RFC::RFC3987::Role::_generic::BNF->role_params_clone;
  #
  # Overwrite/amend our specifics
  #
  $ROLE_PARAMS->{whoami}      = __PACKAGE__;
  $ROLE_PARAMS->{start}       = '<ftp uri>';
  $ROLE_PARAMS->{bnf}         = $BNF;
  $ROLE_PARAMS->{mapping}->{'<user>'} = 'user';
  $ROLE_PARAMS->{mapping}->{'<pass>'} = 'password';
  $ROLE_PARAMS->{extension}   = sub {
    my ($struct) = @_;
    $struct->{user} = undef;
    $struct->{password} = undef;
    $struct
  };
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

1;

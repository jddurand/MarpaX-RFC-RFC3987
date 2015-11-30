use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::_common::BNF;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common BNF role

# VERSION

# AUTHORITY

use Carp qw/croak/;
use File::ShareDir::ProjectDistDir 1.0 qw/dist_dir/, strict => 1;
use File::Spec qw//;
use IO::File qw//;
use Moo::Role;

our ($ROLE_PARAMS);
BEGIN {
  # ---
  # BNF
  # ---
  my $bnf_file   = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), '_common.bnf');
  my $fh         = IO::File->new($bnf_file, 'r');
  my $BNF        = do { local $/; <$fh> };
  $BNF =~ /\A(.*)\z/s || croak 'Failed to untaint';
  $BNF = $1; # We trust our BNF
  # ---------
  # For reuse
  # ---------
  $ROLE_PARAMS = {
                  whoami      => __PACKAGE__,
                  type        => '_common',
                  spec        => 'iri',
                  top         => 'MarpaX::RFC::RFC3987',
                  start       => '<common>',
                  bnf         => $BNF,
                  unreserved  => undef,
                  pct_encoded => undef,
                  mapping     => {
                                  '<common>'         => 'output',
                                  '<scheme>'         => 'scheme',
                                  '<opaque>'         => 'opaque',
                                  '<fragment>'       => 'fragment',
                                 }
                 };
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

1;

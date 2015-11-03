use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_common::BNF;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

use File::ShareDir::ProjectDistDir 1.0 qw/dist_dir/, strict => 1;
use File::Spec qw//;
use IO::File qw//;
use Moo::Role;

our ($BNF, $RESERVED, $UNRESERVED);
BEGIN {
  # ---
  # BNF
  # ---
  my $bnf_file   = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), '_common.bnf');
  my $fh         = IO::File->new($bnf_file, 'r');
  $BNF           = do { local $/; <$fh> };
  # -----------------------
  # RESERVED and UNRESERVED
  # -----------------------
  $RESERVED   = qr/[:#]/;
  $UNRESERVED = qr/[^:#]/;
}

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF'
  => {
      whoami      => __PACKAGE__,
      type        => 'common',
      bnf         => $BNF,
      reserved    => $RESERVED,
      unreserved  => $UNRESERVED,
      pct_encoded => undef,
      mapping     => {
                      '<common>'         => 'output',
                      '<scheme>'         => 'scheme',
                      '<opaque>'         => 'opaque',
                      '<fragment>'       => 'fragment',
                     }
     }
  ;

1;

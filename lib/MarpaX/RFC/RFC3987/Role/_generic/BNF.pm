use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::Role::_generic::BNF;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic BNF role

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
  my $bnf_file   = File::Spec->catfile(dist_dir('MarpaX-RFC-RFC3987'), '_generic.bnf');
  my $fh         = IO::File->new($bnf_file, 'r');
  my $BNF        = do { local $/; <$fh> };
  $BNF =~ /\A(.*)\z/s || croak 'Failed to untaint';
  $BNF = $1; # We trust our BNF
  # -----------------------
  # RESERVED and UNRESERVED
  # -----------------------
  my $ALPHA      = qr/(?:[A-Za-z])/;
  my $DIGIT      = qr/(?:[0-9])/;
  my $UCSCHAR    = qr/(?:[\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}])/;
  my $UNRESERVED    = qr/(?:$ALPHA|$DIGIT|[\-._~]|$UCSCHAR)/;
  my $GEN_DELIMS = qr/(?:[\:\/\?\[\]\@\#])/;
  my $SUB_DELIMS = qr/(?:[\!\$\&\'\(\)\*\+\,\;\=])/;
  my $RESERVED      = qr/(?:$GEN_DELIMS|$SUB_DELIMS)/;
  # ---------
  # For reuse
  # ---------
  $ROLE_PARAMS = {
                  whoami      => __PACKAGE__,
                  type        => '_generic',
                  spec        => 'iri',
                  top         => 'MarpaX::RFC::RFC3987',
                  start       => '<IRI reference>',
                  bnf         => $BNF,
                  reserved    => $RESERVED,
                  unreserved  => $UNRESERVED,
                  pct_encoded => '<pct encoded>',
                  mapping     => {
                                  '<IRI reference>'  => 'output',
                                  '<scheme>'         => 'scheme',
                                  '<IRI opaque>'     => 'opaque',
                                  '<rel opaque>'     => 'opaque',
                                  '<ihier part>'     => 'hier_part',
                                  '<iquery>'         => 'query',
                                  '<ifragment>'      => 'fragment',
                                  '<isegments>'      => 'segment',
                                  '<iauthority>'     => 'authority',
                                  '<ipath abempty>'  => 'path',
                                  '<ipath absolute>' => 'path',
                                  '<ipath noscheme>' => 'path',
                                  '<ipath rootless>' => 'path',
                                  '<ipath empty>'    => 'path',
                                  '<irelative ref>'  => 'relative_ref',
                                  '<irelative part>' => 'relative_part',
                                  '<iuserinfo>'      => 'userinfo',
                                  '<ihost>'          => 'host',
                                  '<port>'           => 'port',
                                  '<IP literal>'     => 'ip_literal',
                                  '<IPv6address>'    => 'ipv6_address',
                                  '<IPv4address>'    => 'ipv4_address',
                                  '<ireg name>'      => 'reg_name',
                                  '<IPv6addrz>'      => 'ipv6_addrz',
                                  '<IPvFuture>'      => 'ipvfuture',
                                  '<ZoneID>'         => 'zoneid',
                                  '<isegment>'       => 'segments',
                                  '<isegment nz>'    => 'segments',
                                  '<isegment nz nc>' => 'segments',
                                 }
                 };
}

sub role_params { $ROLE_PARAMS }

use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF' => $ROLE_PARAMS;

1;

use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_common;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax implementation

# VERSION

# AUTHORITY

use Moo;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common'
  => {
      package           => __PACKAGE__,
      BNF_package       => 'MarpaX::RFC::RFC3987::_common::BNF',
      G1 => {
             '<scheme>'   => sub { $_[0]->scheme  ($_[1]) },
             '<opaque>'   => sub { $_[0]->opaque  ($_[1]) },
             '<fragment>' => sub { $_[0]->fragment($_[1]) },
            }
     };

#
# as_uri is specific to the IRI implementation
#
our $ucschar_regexp = qw/[\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}]/;
our $iprivate_regexp = qr/[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}\x{100000}-\x{10FFFD}]/;
our $ucschar_or_private_regexp = qr/(?:$ucschar_regexp|$iprivate_regexp)/;

sub as_uri { $_[0]->percent_encode($_[0]->input, $ucschar_or_private_regexp) }

1;

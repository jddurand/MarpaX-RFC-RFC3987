use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_common;
use Scalar::Util qw/blessed/;
use Moo;
use Unicode::Normalize qw/normalize/;

with 'MarpaX::RFC::RFC3987::_common::BNF';
with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_common';

# --------------------------------------------
# as_uri is specific to the IRI implementation
# --------------------------------------------
our $UCSCHAR = qw/[\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}]/;
our $IPRIVATE = qr/[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}\x{100000}-\x{10FFFD}]/;
our $UCSCHAR_OR_IPRIVATE = qr/(?:$UCSCHAR|$IPRIVATE)/;

sub as_uri {
  # -----------------------------
  # 3.1.  Mapping of IRIs to URIs
  # -----------------------------
  my ($self) = @_;
  #
  # Step 1
  # ------
  #   a  If the IRI is written on paper, read aloud
  # .... not for us
  #
  #   b  If the IRI is in some digital representation (e.g., an
  # octet stream) in some known non-Unicode character encoding, convert
  # the IRI to a sequence of characters from the UCS normalized according to NFC.
  #
  #
  #   c  If the IRI is in a Unicode-based character encoding (for
  #      example, UTF-8 or UTF-16), do not normalize (see section
  #      5.3.2.2 for details).  Apply step 2 directly to the
  #      encoded Unicode character sequence.
  #
  my $input            = $self->input;
  my $normalized_input = $self->is_character_normalized ? $input : normalize('NFC', $input);
  #
  # Systems accepting IRIs MAY convert the ireg-name component of an IRI
  # as follows (before step 2 above) for schemes known to use domain
  # names in ireg-name, if the scheme definition does not allow
  # percent-encoding for ireg-name
  #
  my $converted_input = ($normalized_input eq $input) ?
    #
    # Normalized input is the same as raw input: no need to reparse
    #
    $self->converted
    :
    #
    # Normalized input is not the same as raw input: reparse temporarly
    # I am not sure this is necessary though (I do not know if domain_to_ascii
    # is insensitive to NFC normalization)
    #
    blessed($self)->new($normalized_input)->converted
    ;
  # Step 2
  #
  # For each character in 'ucschar' or 'iprivate', apply steps
  # 2.1 through 2.3 below.
  #
  # 2.1.  Convert the character to a sequence of one or more octets
  #       using UTF-8 [RFC3629].
  # 2.2.  Convert each octet to %HH, where HH is the hexadecimal
  #       notation of the octet value.  Note that this is identical
  #       to the percent-encoding mechanism in section 2.1 of
  #       [RFC3986].  To reduce variability, the hexadecimal notation
  #       SHOULD use uppercase letters.
  # 2.3.  Replace the original character with the resulting character
  #       sequence (i.e., a sequence of %HH triplets).
  $self->percent_encode($converted_input, $UCSCHAR_OR_IPRIVATE)
}

1;

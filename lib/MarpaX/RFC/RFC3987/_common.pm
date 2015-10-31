use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_common;
use Moo;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => '_common',
      bnf_package => 'MarpaX::RFC::RFC3987::_common::BNF',
     };
use Unicode::Normalize qw/normalize/;
#
# as_uri is specific to the IRI implementation
#
our $ucschar_regexp = qw/[\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}]/;
our $iprivate_regexp = qr/[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}\x{100000}-\x{10FFFD}]/;
our $ucschar_or_private_regexp = qr/(?:$ucschar_regexp|$iprivate_regexp)/;

sub as_uri {
  my ($self) = @_;
  #
  # Perl string
  #
  my $input = $self->input;
  #
  # From https://www.ietf.org/rfc/rfc3987.txt:
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
  $input = normalize('NFC', $input) if ! $self->is_character_normalized;
  #
  # c  If the IRI is in a Unicode-based character encoding (for
  #    example, UTF-8 or UTF-16), do not normalize (see section
  #    5.3.2.2 for details).  Apply step 2 directly to the
  #    encoded Unicode character sequence.
  #
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
  $self->percent_encode($input, $ucschar_or_private_regexp)
}

#
# Normalizers semantics are fixed in the Common case
# Arguments are always: ($self, $field, $value, $lhs)
# $lhs   is always either undef or in the form '<xxx>'
# $field is always either undef or in the form 'yyy'
# If $field is not undef, then $lhs is guaranteed to not be undef
# If $field is     undef, then if $lhs is undef $value is the original input
#
sub build_case_normalizer {
  return { scheme => sub {
             lc($_[2]) } }
}

sub build_character_normalizer {
  return { '' => sub { $_[0]->is_character_normalized ? $_[2] : normalize('NFC', $_[2]) } }
}

sub build_percent_encoding_normalizer { return {} }
sub build_path_segment_normalizer { return {} }
sub build_scheme_based_normalizer { return {} }

1;

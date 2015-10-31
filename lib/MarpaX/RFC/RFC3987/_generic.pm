use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;
use MarpaX::RFC::RFC3629;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      #
      # Because class is modified at compiled time, and I wanted to
      # avoid having to say BEGIN { extends 'MarpaX::RFC::RFC3987::_common' }
      #
      extends     => [qw/MarpaX::RFC::RFC3987::_common/]
     };
use Unicode::Normalize qw/normalize/;
#
# 5.3.2.1.  Case Normalization
#
around build_case_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          #
          # Arguments: $self, $field, $value, $lhs
          #
          # For all IRIs, the hexadecimal digits within a percent-encoding
          # triplet (e.g., "%3a" versus "%3A") are case-insensitive and therefore
          # should be normalized to use uppercase letters for the digits A - F.
          #
          '<pct encoded>' => sub { uc($_[2]) },
          #
          # When an IRI uses components of the generic syntax, the component
          # syntax equivalence rules always apply; namely, that the scheme and
          # US-ASCII only host are case insensitive and therefore should be
          # normalized to lowercase.
          scheme => sub { lc($_[2]) },
          host   => sub { $_[2] =~ /[^\x{0}-\x{7F}]/ ? $_[2] : lc($_[2]) }
         }
};
#
# 5.3.2.2.  Character Normalization
#
around build_character_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          #
          # Arguments: $self, $field, $value, $lhs
          #
          # Equivalence of IRIs MUST rely on the assumption that IRIs are
          # appropriately pre-character-normalized rather than apply character
          # normalization when comparing two IRIs.  The exceptions are conversion
          # from a non-digital form, and conversion from a non-UCS-based
          # character encoding to a UCS-based character encoding. In these cases,
          # NFC or a normalizing transcoder using NFC MUST be used for
          # interoperability.
          #
          output => sub { $_[0]->is_character_normalized ? $_[2] : normalize('NFC', $_[2]) }
         }
};
#
# 5.3.2.3.  Percent-Encoding Normalization
#
around build_percent_encoding_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          #
          # Arguments: $self, $field, $value, $lhs
          #
          # ./.. IRIs should be normalized by decoding any
          # percent-encoded octet sequence that corresponds to an unreserved
          # character, as described in section 2.3 of [RFC3986].
          #
          '<pct encoded>' => sub {
            my $octets = '';
            while ($_[2] =~ m/(?<=%)[^%]+/gp) {
              $octets .= chr(hex(${^MATCH}))
            }
            my $decoded = MarpaX::RFC::RFC3629->new($octets)->output;
            $decoded =~ $self->unreserved ? $decoded : $_[2]
          }
         }
};
#
# 5.3.2.4.  Path Segment Normalization
#
around build_path_segment_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          #
          # Arguments: $self, $field, $value, $lhs
          #
          'relative_part' => sub { $_[0]->remove_dot_segments($_[2]) },
          'hier_part'     => sub { $_[0]->remove_dot_segments($_[2]) }
         }
};

1;


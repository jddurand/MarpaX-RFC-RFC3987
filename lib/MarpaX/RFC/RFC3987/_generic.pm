use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Carp qw/croak/;
use Moo;
BEGIN { extends 'MarpaX::RFC::RFC3987::_common' }
use if $] < 5.016, 'Unicode::CaseFold';
use Unicode::CaseFold;
use Unicode::Normalize qw/normalize/;
use Try::Tiny;
use Types::Standard -all;
use Types::Encodings qw/Bytes/;
use Net::IDN::Encode qw/domain_to_ascii/;
use Net::IDN::Nameprep qw/nameprep/;
use MooX::HandlesVia;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      normalizer  => sub {
        my ($self, $field, $value, $lhs) = @_;
        #
        # If field is set it has priority. $lhs is taken only in cases
        # this is a rule not mapped to the external world. As a special case,
        # if $lhs is not set neither, this is a call done done just BEFORE
        # the parsing, using the whole input into $value.
        # It is guaranteed that a $lhs is always in the form <>, which a $field
        # is never enclosed in <>.
        #
        my $criteria = $field || $lhs || '';
        # ------------------
        # Case normalization
        # ------------------
        $value = $self->get_case_normalizer($criteria)->($self, $field, $value, $lhs)
          if ($self->exists_case_normalizer($criteria));
        # -----------------------
        # Character normalization
        # -----------------------
        $value = $self->get_character_normalizer($criteria)->($self, $field, $value, $lhs)
          if ($self->exists_character_normalizer($criteria));
        #
        # ---------------------------------------
        # Percent encoding normalization: builtin
        # ---------------------------------------
        $value = $self->get_percent_encoding_normalizer($criteria)->($self, $field, $value, $lhs)
          if ($self->exists_percent_encoding_normalizer($criteria));
        #
        # ---------------------------------
        # Path segment normalization: TO DO
        # ---------------------------------
        #
        # --------------------------
        # Scheme based normalization
        # --------------------------
        $value = nameprep($value, AllowUnassigned => 0) if $self->exists_idn_must_be_normalized($criteria) && $self->get_idn_must_be_normalized($criteria);

        $value
      }
     };

has case_normalizer      => ( is => 'ro', isa => HashRef[CodeRef], lazy => 1, builder => 'build_case_normalizer',
                              handles_via => 'Hash',
                              handles => {
                                          exists_case_normalizer  => 'exists',
                                          get_case_normalizer     => 'get'
                                         }
                            );
has character_normalizer => ( is => 'ro', isa => HashRef[CodeRef], lazy => 1, builder => 'build_character_normalizer',
                              handles_via => 'Hash',
                              handles => {
                                          exists_character_normalizer => 'exists',
                                          get_character_normalizer => 'get'
                                         }
                            );

has percent_encoding_normalizer => ( is => 'ro', isa => HashRef[CodeRef], lazy => 1, builder => 'build_percent_encoding_normalizer',
                              handles_via => 'Hash',
                              handles => {
                                          exists_percent_encoding_normalizer => 'exists',
                                          get_percent_encoding_normalizer => 'get'
                                         }
                            );

has is_idn => ( is => 'ro', lazy => 1, isa => HashRef[Bool], builder => 'build_is_idn',
                handles_via => 'Hash',
                handles => {
                            exists_is_idn => 'exists',
                            get_is_idn => 'get'
                           }
              );
has idn_must_be_valid => ( is => 'ro', lazy => 1, isa => HashRef[Bool], builder => 'build_idn_must_be_valid',
                           handles_via => 'Hash',
                           handles => {
                                       exists_idn_must_be_valid => 'exists',
                                       get_idn_must_be_valid => 'get'
                                      }
                         );
has idn_must_be_normalized => ( is => 'ro', lazy => 1, isa => HashRef[Bool], builder => 'build_idn_must_be_normalized',
                                handles_via => 'Hash',
                                handles => {
                                            exists_idn_must_be_normalized => 'exists',
                                            get_idn_must_be_normalized => 'get'
                                           }
                              );

# --------------------------
# Default case normalization
# --------------------------
sub build_case_normalizer {
  return
    {
     #
     # '' means this is called just before the parsing
     #
     # Equivalence of IRIs MUST rely on the assumption that IRIs are
     # appropriately pre-character-normalized rather than apply character
     # normalization when comparing two IRIs.  The exceptions are conversion
     # from a non-digital form, and conversion from a non-UCS-based
     # character encoding to a UCS-based character encoding. In these cases,
     # NFC or a normalizing transcoder using NFC MUST be used for
     # interoperability.
     #
     '' => sub
     {
       my ($self, $field, $value, $lhs) = @_;
       $self->is_character_normalized ? $value : normalize('NFC', $value)
     },
     #
     # scheme is always lower-cased (contains only US-ASCII characters per def)
     #
     scheme => sub
     {
       my ($self, $field, $value, $lhs) = @_;
       lc($value)
     },
     #
     # host is always lower-cased if it contains only US-ASCII characters
     #
     host => sub
     {
       my ($self, $field, $value, $lhs) = @_; 
       Bytes->check($value) ? lc($value) : $value
     }
    }
}

# ----------------------------
# Default character normalizer
# ----------------------------
sub build_character_normalizer {
  return {}   # Typically http, ftp, etc... will want IDN normalization on reg_name
}

# -----------------------------------
# Default percent encoding normalizer
# ----------------------------------
sub build_percent_encoding_normalizer {
  return {
          '<pct encoded>' => sub
          {
            my ($self, $field, $value, $lhs) = @_;
            uc($value)
          }
         }
}

sub build_is_idn                           { return {} }
sub build_idn_must_be_valid                { return {} }
sub build_idn_must_be_normalized           { return {} }

sub _fc {
  my ($self, $value) = @_;
  $] < 5.016 ? fc($value) : CORE::fc($value)
}

1;

use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;
BEGIN { extends 'MarpaX::RFC::RFC3987::_common' }
use if $] < 5.016, 'Unicode::CaseFold';
use Unicode::CaseFold;
use Unicode::Normalize qw/normalize/;
use Try::Tiny;
use Types::Standard -all;
use Types::Encodings qw/Bytes/;
use Net::IDN::Encode qw/domain_to_ascii/;
use Net::IDN::IDNA2003 qw/idna2003_to_ascii/;
use Net::IDN::Nameprep qw/nameprep/;
use MooX::HandlesVia;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      normalizer  => sub {
        my ($self, $lhs, $field, $value) = @_;
        # ------------------
        # Case normalization
        # ------------------
        #
        # scheme is always normalized to lowercase, contains only US-ASCII characters per def
        #
        $value = lc($value) if ($field eq '<scheme>');
        #
        # host is normalized to lowercase if it contains only US-ASCII characters
        #
        $value = lc($value) if ($field eq '<host>' && Bytes->check($value));
        #
        # ------------------------------------------------------------------------
        # Character normalization: assume already normalized unless caller said no
        # ------------------------------------------------------------------------
        # '<IRI reference>' is the start rule of the IRI BNF
        #
        $value = normalize($self->character_normalization_strategy, $value) if ($lhs eq '<IRI reference>' && ! $self->is_character_normalized);
        #
        # ---------------------------------------
        # Percent encoding normalization: builtin
        # ---------------------------------------
        #
        # ---------------------------------
        # Path segment normalization: TO DO
        # ---------------------------------
        #
        # --------------------------
        # Scheme based normalization
        # --------------------------
        $value = nameprep(idna2003_to_ascii($value, UseSTD3ASCIIRules => 1, AllowUnassigned => 1), AllowUnassigned => 0) if ($self->exists_idn($field) && $self->get_idn($field));

        $value
      }
     };

has is_idn                           => ( is => 'ro', lazy => 1, isa => HashRef[Bool], builder => 'build_is_idn',
                                          handles_via => 'Hash',
                                          handles => {
                                                      exists_idn => 'exists',
                                                      get_idn => 'get'
                                                     }
                                        );
has is_character_normalized          => ( is => 'ro', lazy => 1, isa => Bool, builder => 'build_is_character_normalized' );
has character_normalization_strategy => ( is => 'ro', lazy => 1, isa => Enum[qw/NFD NFC NFKD NFKC FCD FCC/], builder => 'build_character_normalization_strategy' );

sub build_is_idn { return {} }
sub build_is_character_normalized { return !!1 }
sub build_character_normalization_strategy { return 'NFC' }

sub _fc {
  my ($self, $value) = @_;
  $] < 5.016 ? fc($value) : CORE::fc($value)
}

1;

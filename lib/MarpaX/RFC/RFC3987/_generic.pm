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
use Net::IDN::Encode qw/domain_to_ascii/;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      normalizer  => sub {
        my ($self, $lhs, $value) = @_;

        $value =         lc($value)                                         if ($lhs eq '<scheme>');
        $value = $self->_fc($value)                                         if ($lhs eq '<ihost>');
        $value = normalize($self->character_normalization_strategy, $value) if ($lhs eq '<IRI reference>' && ! $self->is_character_normalized);
        $value
      }
     };

has is_character_normalized          => ( is => 'ro', isa => Bool, default => sub { !!1 } );
has character_normalization_strategy => ( is => 'ro', isa => Enum[qw/NFD NFC NFKD NFKC FCD FCC/], default => sub { 'NFC' } );

sub _fc {
  my ($self, $value) = @_;
  $] < 5.016 ? fc($value) : CORE::fc($value)
}

#
# as_uri is specific to IRI implementation
#
around as_uri => sub {
  my ($orig, $self) = (shift, shift);

  my $as_uri = $self->$orig(@_);
  my $scheme = $self->_scheme;
  if ($self->idn && ! Undef->check($scheme)) {
    try {
      #
      # This MAY fail
      #
      # We are creating an URI: AllowUnassigned must be set to TRUE
      #
      $scheme = domain_to_ascii($scheme, UseSTD3ASCIIRules => 1, AllowUnassigned => 1);
      #
      # Reconstruct a fake IRI
      #
    } catch {
      if ($self->can('_logger')) {
        $self->_logger->warnf('%s', $_);
      }
    }
  }
};

1;

use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Carp qw/croak/;
use MarpaX::Role::Parameterized::ResourceIdentifier::Setup;
use MarpaX::Role::Parameterized::ResourceIdentifier::Setup;
use Moo;
# use SUPER;
use Try::Tiny;
use Types::Encodings qw/Bytes/;
BEGIN {
  extends 'MarpaX::RFC::RFC3987::_common';
}
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF'
     };

our $setup  = MarpaX::Role::Parameterized::ResourceIdentifier::Setup->instance;

around build_case_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          %{$self->$orig},
          #
          # host is always lower-cased if it contains only US-ASCII characters
          #
          host => sub { Bytes->check($_[2]) ? lc($_[2]) : $_[2] }
         }
};

around build_percent_encoding_normalizer => sub {
  my ($orig, $self) = @_;

  return {
          %{$self->$orig},
          #
          # <pct encoded> rule is starting only with the generic syntax
          #
          '<pct encoded>' => sub { uc($_[2]) }
         }
};

1;


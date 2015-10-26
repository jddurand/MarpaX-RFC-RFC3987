use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

use Types::Standard -all;
use Net::IDN::Encode qw/domain_to_ascii/;
use Moo;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => 'Generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      normalizer  => sub {}
     };
use Try::Tiny;

extends 'MarpaX::RFC::RFC3987::_common';

#
# as_uri is specific to IRI implementation
#
around as_uri => sub {
  my ($orig, $self) = (shift, shift);

  my $as_uri = $self->$orig(@_);
  my $scheme = $self->_struct_generic->scheme;
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

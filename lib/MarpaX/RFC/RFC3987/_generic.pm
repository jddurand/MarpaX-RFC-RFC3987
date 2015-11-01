use strict;
use warnings FATAL => 'all';

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

package MarpaX::RFC::RFC3987::_generic;
use Moo;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      whoami      => __PACKAGE__,
      type        => '_generic',
      bnf_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      #
      # Because class is done at compiled time, extends, has etc... are
      # injected like this.
      #
      -extends     => [qw/MarpaX::RFC::RFC3987::_common/]
     };
use Net::IDN::Encode qw/domain_to_ascii/;
use Try::Tiny;

# --------------------------------------
# This is specific to IRI implementation
# --------------------------------------
#
# 3.1.  Mapping of IRIs to URIs
#
# ./.. Replace the ireg-name part of the IRI by the part converted using the
#      ToASCII operation specified in section 4.1 of [RFC3490] on each
#      dot-separated label, and by using U+002E (FULL STOP) as a label
#      separator, with the flag UseSTD3ASCIIRules set to TRUE, and with the
#      flag AllowUnassigned set to FALSE for creating IRIs and set to TRUE
#      otherwise.

sub _domain_to_ascii {
  #
  # Arguments: ($self, $field, $value, $lhs, $AllowUnassigned) = @_
  #
  my $self = $_[0];
  my $rc = $_[2];
  try {
    $rc = domain_to_ascii($rc, UseSTD3ASCIIRules => 1, AllowUnassigned => pop)
  } catch {
    $self->_logger->warnf('%s', $_) if ($self->with_logger);
    return
  };
  $rc
}

around build_uri_convertor => sub {
  #
  # Arguments: ($self, $field, $value, $lhs) = @_
  #
  return { reg_name => sub { _domain_to_ascii(@_, 1) } }
};

around build_iri_convertor => sub {
  #
  # Arguments: ($self, $field, $value, $lhs) = @_
  #
  return { reg_name => sub { _domain_to_ascii(@_, 0) } }
};

1;


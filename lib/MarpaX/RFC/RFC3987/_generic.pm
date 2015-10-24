use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

use Types::Standard -all;
use Net::IDN::Encode qw/domain_to_ascii/;
use if $] < 5.16, 'Unicode::CaseFold';
use Moo;
BEGIN {
  #
  # So that _trigger_input is found in inheritance hierarchy
  #
  extends 'MarpaX::RFC::RFC3987::_common';
}
BEGIN {
  #
  # Because parameterized role is applied at compile time and requires these attributes
  #
  has idn      => ( is => 'rw', isa => Bool, default => sub { !!0 } ); # Is reg-name an IDN
  has nfc      => ( is => 'rw', isa => Bool, default => sub { !!1 } ); # Is input normalized
}
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic'
  => {

      package     => __PACKAGE__,
      BNF_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      G1 => {
             #
             # $_[0] is of type Generic
             #
             '<IRI>'            => sub {
               $_[0]->_set_iri($_[1]);
               my $opaque = '';
               $opaque .=       $_[0]->hier_part if Str->check($_[0]->hier_part);
               $opaque .= '?' . $_[0]->query     if Str->check($_[0]->query);
               $_[0]->_set_opaque($opaque)
             },
             '<scheme>'         => sub {        $_[0]->_set_scheme       ($_[1]) },
             '<ihier part>'     => sub {        $_[0]->_set_hier_part    ($_[1]) },
             '<iquery>'         => sub {        $_[0]->_set_query        ($_[1]) },
             '<ifragment>'      => sub {        $_[0]->_set_fragment     ($_[1]) },
             '<isegments>'      => sub {        $_[0]->_set_segment      ($_[1]) },
             '<iauthority>'     => sub {        $_[0]->_set_authority    ($_[1]) },
             '<ipath>'          => sub {        $_[0]->_set_path         ($_[1]) },
             '<ipath abempty>'  => sub {        $_[0]->_set_path_abempty ($_[1]) },
             '<ipath absolute>' => sub {        $_[0]->_set_path_absolute($_[1]) },
             '<ipath noscheme>' => sub {        $_[0]->_set_path_noscheme($_[1]) },
             '<ipath rootless>' => sub {        $_[0]->_set_path_rootless($_[1]) },
             '<ipath empty>'    => sub {        $_[0]->_set_path_empty   ($_[1]) },
             '<irelative ref>'  => sub {
               $_[0]->_set_relative_ref($_[1]);
               my $opaque = '';
               $opaque .=       $_[0]->relative_part if Str->check($_[0]->relative_part);
               $opaque .= '?' . $_[0]->query         if Str->check($_[0]->query);
               $_[0]->_set_opaque($opaque)
             },
             '<irelative part>' => sub {        $_[0]->_set_relative_part($_[1]) },
             '<iuserinfo>'      => sub {        $_[0]->_set_userinfo     ($_[1]) },
             '<ihost>'          => sub {        $_[0]->_set_host         ($_[1]) },
             '<iport>'          => sub {        $_[0]->_set_port         ($_[1]) },
             '<IP literal>'     => sub {        $_[0]->_set_ip_literal   ($_[1]) },
             '<IPv6address>'    => sub {        $_[0]->_set_ipv6_address ($_[1]) },
             '<IPv4address>'    => sub {        $_[0]->_set_ipv4_address ($_[1]) },
             '<ireg name>'      => sub {        $_[0]->_set_reg_name     ($_[1]) },
             '<IPv6addrz>'      => sub {        $_[0]->_set_ipv6_addrz   ($_[1]) },
             '<IPvFuture>'      => sub {        $_[0]->_set_ipvfuture    ($_[1]) },
             '<ZoneID>'         => sub {        $_[0]->_set_zoneid       ($_[1]) },
             '<isegment>'       => sub { push(@{$_[0]->segments},         $_[1]) },
             '<isegment nz>'    => sub { push(@{$_[0]->segments},         $_[1]) },
             '<isegment nz nc>' => sub { push(@{$_[0]->segments},         $_[1]) },
            },
      normalizer => sub {
        my ($self, $lhs, $value) = @_;
        #
        # Case normalization
        #
        $value = uc($value) if $lhs eq '<pct encoded>';
        $value = lc($value) if $lhs eq '<scheme>';
        $value = fc($value) if $lhs eq '<ihost>';
        #
        # Character normalization
        # - We assume this is already pre-character normalized
        #   unless the user said it is not
        #
        # Nornamized value
        #
        $value
      }
     };
use Try::Tiny;

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

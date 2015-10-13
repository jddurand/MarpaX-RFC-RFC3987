use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_common;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::_common::BNF;
use Types::Standard -all;
use MooX::Struct -rw,
  Common => [
             scheme   => [ isa => Str|Undef, default => sub { undef } ], # Can be undef
             opaque   => [ isa => Str      , default => sub {    '' } ], # Always set
             fragment => [ isa => Str|Undef, default => sub { undef } ]  # Can be undef
            ];
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      package     => __PACKAGE__,
      BNF         => MarpaX::RFC::RFC3987::_common::BNF->new,
      start       => '<common>',
      G1 => {
             '<scheme>'   => sub { $MarpaX::RFC::RFC3987::SELF->_struct->scheme  ($_[1]) },
             '<opaque>'   => sub { $MarpaX::RFC::RFC3987::SELF->_struct->opaque  ($_[1]) },
             '<fragment>' => sub { $MarpaX::RFC::RFC3987::SELF->_struct->fragment($_[1]) },
            }
     };

has input   => ( is => 'ro', isa => Str,    required => 1, trigger => 1);
has _struct => ( is => 'ro', isa => Object, default => sub { Common->new() });

sub BUILDARGS {
  my ($self, @args) = @_;
  unshift(@args, 'input') if @args % 2;
  return { @args };
}

sub _trigger_input {
  my ($self, $input) = @_;
  local $MarpaX::RFC::RFC3987::SELF = $self;
  $self->grammar->parse(\$input, { ranking_method => 'high_rule_only' });
}

sub has_recognized_scheme {
  my ($self) = @_;
  Str->check($self->_struct->scheme)
}

sub scheme {
  my $self = shift;
  $self->_struct->scheme(@_);
}

sub opaque {
  my $self = shift;
  $self->_struct->opaque(@_);
}

sub fragment {
  my $self = shift;
  $self->_struct->fragment(@_);
}

extends 'MarpaX::RFC::RFC3987';

1;

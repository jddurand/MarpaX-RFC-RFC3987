use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax

# VERSION

# AUTHORITY

use Encode::Locale;
use Encode qw/decode/;
use Moo;
use MarpaX::RFC::RFC3987::BNF;
use Types::Standard -all;
use Types::Encodings qw/Bytes Chars/;
use Type::Params qw/compile/;
use Scalar::Does qw/-constants/;
use Throwable::Factory GeneralException => undef;
use Try::Tiny;
use MooX::Struct -rw,
  Common => [
             scheme   => [ isa => Str|Undef, default => sub { undef } ], # Can be undef
             opaque   => [ isa => Str      , default => sub {    '' } ], # Always set
             fragment => [ isa => Str|Undef, default => sub { undef } ]  # Can be undef
            ];
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      BNF         => MarpaX::RFC::RFC3987::BNF->new,
      start       => '<common>',
      G1 => {
             '<scheme>'   => sub { $MarpaX::RFC::RFC3987::SELF->_struct->scheme  ($_[1]) },
             '<opaque>'   => sub { $MarpaX::RFC::RFC3987::SELF->_struct->opaque  ($_[1]) },
             '<fragment>' => sub { $MarpaX::RFC::RFC3987::SELF->_struct->fragment($_[1]) },
            }
     };

has encoding  => ( is => 'ro',  isa => Str,       default => sub { 'locale'}               ); # Bytes encoding - default to user's locale
has input     => ( is => 'rwp', isa => Str,       trigger => 1                             ); # Work area in characters
has bytes     => ( is => 'ro',  isa => Bytes,     default => sub { undef }, predicate => 1 ); # Input as bytes
has _struct   => ( is => 'rw',  isa => Object,    default => sub { Common->new() }         ); # Parse result

sub BUILDARGS {
  my ($class, @args) = @_;

  GeneralException->throw('Exactly one argument is required') if ($#args != 0);

  my $argument = $args[0];

  if (Str->check($argument)) {
    #
    # A string: the URI way.
    #
    @args = (input => $argument );
  } elsif (does($argument, HASH)) {
    #
    # A HASH reference
    #
    # Having both bytes and input is an error
    #
    GeneralException->throw('bytes and input are mutually exclusive') if (exists($argument->{input}) && exists($argument->{bytes}));
    #
    # As well as having none of them
    #
    GeneralException->throw('One of bytes or input is required') if (! exists($argument->{input}) && ! exists($argument->{bytes}));
    #
    @args = ( %{$argument} );
  } else {
    #
    # Not supported
    #
    GeneralException->throw('The argument must be a string or a hash reference');
  }

  return { @args };
}

sub BUILD {
  my ($self) = @_;

  if ($self->has_bytes) {
    $self->_logger->debugf('Decoding bytes using %s encoding', $self->encoding);
    my $bytes = $self->bytes;
    $self->_set_input(decode($self->encoding, $bytes, Encode::FB_CROAK));
  }
}

sub _trigger_input {
  my ($self, $input) = @_;

  local $MarpaX::RFC::RFC3987::SELF = $self;
  $self->__parse($input);
}

sub _newinput {
  my ($self, $scheme, $opaque, $fragment) = @_;

  my $input = '';
  $input .= $self->_struct->scheme   || '';
  $input .= $self->_struct->opaque;
  $input .= $self->_struct->fragment || '';

  $self->_set_input($input);
}

sub has_recognized_scheme {
  my ($self) = @_;
  Str->check($self->_struct->scheme)
}

sub scheme {
  my $self = shift;
  my $scheme = $self->_struct->scheme(@_);

  $self->_newinput() if (@_);

  return $scheme;
}

sub opaque {
  my $self = shift;
  $self->_struct->opaque(@_);
}

sub fragment {
  my $self = shift;
  $self->_struct->fragment(@_);
}

with 'MooX::Role::Logger';

1;

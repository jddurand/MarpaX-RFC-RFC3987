package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common syntax

# VERSION

# AUTHORITY

use Encode qw/decode/;
use Moo;
use MarpaX::RFC::RFC3987::BNF;
use Types::Standard -all;
use Types::Encodings qw/Bytes Chars/;
use Scalar::Does qw/-constants/;
use Throwable::Factory GeneralException => undef;
use MooX::Struct -rw,
  Common => [
             scheme   => [ isa => Str|Undef, default => sub { undef } ],
             opaque   => [ isa => Str      , default => sub {    '' } ],
             fragment => [ isa => Str|Undef, default => sub { undef } ]
            ];
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      'BNF'         => ${MarpaX::RFC::RFC3987::BNF->section_data('BNF')},
      'self_ref'    => \$MarpaX::RFC::RFC3987::SELF,
      'start'       => '<common>',
      G1 => {
             '<scheme>'   => sub { shift; $MarpaX::RFC::RFC3987::SELF->_struct->{scheme}   = join('', @_) },
             '<opaque>'   => sub { shift; $MarpaX::RFC::RFC3987::SELF->_struct->{opaque}   = join('', @_) },
             '<fragment>' => sub { shift; $MarpaX::RFC::RFC3987::SELF->_struct->{fragment} = join('', @_) },
            }
     };

has from     => ( is => 'rw', isa => Str,    default => sub { 'UTF8'}        ); # From encoding
has to       => ( is => 'rw', isa => Str,    default => sub { 'UTF8'}        ); # To encoding
has input    => ( is => 'rw', isa => Str,    trigger => 1                    ); # Work area in characters
has bytes    => ( is => 'rw', isa => Bytes,  trigger => 1                    ); # Input as bytes
has _struct  => ( is => 'rw', isa => Object, default => sub { Common->new() }); # Parse result

sub BUILDARGS {
  my ($self, @args) = @_;

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
    # Having both bytes and input is an error
    #
    GeneralException->throw('bytes and input are mutually exclusive') if (exists($argument->{input}) && exists($argument->{bytes}));
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
  $MarpaX::RFC::RFC3987::SELF = $self;
  $self->grammar->parse(\$self->input, MarpaX::RFC::RFC3987::BNF->grammar_option);
  use Data::Dumper;
  print STDERR Dumper($self->_struct);
}

sub _trigger_bytes {
  my ($self, $bytes) = @_;
  $self->input(decode($self->from, $bytes, Encode::FB_CROAK));
}

sub _trigger_input {
  my ($self, $input) = @_;

  #
  # The most generic syntax is simple: scheme, scheme-specific part, fragment
  #
  if ($input =~ /\A([A-Za-z][A-Za-z0-9+.-]*:)?((?<!:)[^#]*)?(#.*)?\z/s) {
    $self->scheme  (substr($input, $-[1],     $+[1] - 1 - $-[1])) if ($+[1] && $+[1] > $-[1]);  # ':'
    $self->opaque  (substr($input, $-[2],     $+[2]     - $-[2])) if ($+[2] && $+[2] > $-[2]);
    $self->fragment(substr($input, $-[3] + 1, $+[3] - $-[3] - 1)) if ($+[3] && $+[3] > $-[3]); # '#'
  } else {
    GeneralException->throw('input does not match opaque IRI');
  }
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

1;

__DATA__

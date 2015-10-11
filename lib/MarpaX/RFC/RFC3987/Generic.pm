package MarpaX::RFC::RFC3987::Generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - Marpa Parser

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::Generic;
use Types::Standard -all;
local $MarpaX::RFC::RFC3987::Generic::SELF;
use MooX::Struct -rw,
  Common => [
             scheme   => [ isa => Str|Undef, default => sub { undef } ],
             opaque   => [ isa => Str      , default => sub {    '' } ],
             fragment => [ isa => Str|Undef, default => sub { undef } ]
            ];
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      'BNF'         => ${MarpaX::RFC::RFC3987::Generic::BNF->section_data('BNF')},
      'self_ref'    => \$MarpaX::RFC::RFC3987::Generic::SELF,
      'start'       => '<IRI reference>',
      G1 => {
             '<scheme>'         => sub { shift; $MarpaX::RFC::RFC3987::Generic::SELF->_struct->{scheme}   .= join('', @_) },
             '<ihier part>'     => sub { shift; $MarpaX::RFC::RFC3987::Generic::SELF->_struct->{opaque}   .= join('', @_) },
             '<irelative part>' => sub { shift; $MarpaX::RFC::RFC3987::Generic::SELF->_struct->{opaque}   .= join('', @_) },
             '<iquery>'         => sub { shift; $MarpaX::RFC::RFC3987::Generic::SELF->_struct->{opaque}   .= join('', '?', @_) },
             '<ifragment>'      => sub { shift; $MarpaX::RFC::RFC3987::Generic::SELF->_struct->{fragment} .= join('', @_) },
            }
     };

has _input  => ( is => 'ro', isa => Str,    required => 1);
has _struct => ( is => 'ro', isa => Object, default => sub { Common->new() });

sub BUILDARGS {
  my ($self, @args) = @_;
  unshift(@args, '_input') if @args % 2;
  return { @args };
}

sub BUILD {
  my ($self) = @_;
  $MarpaX::RFC::RFC3987::Generic::SELF = $self;
  $self->grammar->parse(\$self->_input, { ranking_method => 'high_rule_only' });
  use Data::Dumper;
  print STDERR Dumper($self->_struct);
}

sub has_recognized_scheme {
  my ($self) = @_;
  Str->check($self->_struct->scheme)
}

sub opaque {
  my ($self) = @_;
  $self->_struct->opaque(@_);
}

1;

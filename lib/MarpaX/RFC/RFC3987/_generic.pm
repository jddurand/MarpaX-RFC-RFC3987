package MarpaX::RFC::RFC3987::_generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - Marpa Parser

# VERSION

# AUTHORITY

use Moo;
use MarpaX::RFC::RFC3987::_generic::BNF;
use Types::Standard -all;
use MooX::Struct -rw,
  Generic => [
              hier_part => [ isa => Str|Undef, default => sub { undef } ],
              query     => [ isa => Str|Undef, default => sub { undef } ],
              authority => [ isa => Str|Undef, default => sub { undef } ],
              userinfo  => [ isa => Str|Undef, default => sub { undef } ],
              host      => [ isa => Str|Undef, default => sub { undef } ],
              port      => [ isa => Str|Undef, default => sub { undef } ],
            ];
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      package     => __PACKAGE__,
      BNF         => MarpaX::RFC::RFC3987::_generic::BNF->new,
      start       => '<IRI reference>',
      G1 => {
             '<ihier_part>' => sub { $MarpaX::RFC::RFC3987::SELF->_struct->hier_part($_[1]) },
             '<iquery>'     => sub { $MarpaX::RFC::RFC3987::SELF->_struct->query    ($_[1]) },
             '<iauthority>' => sub { $MarpaX::RFC::RFC3987::SELF->_struct->authority($_[1]) },
             '<iuserinfo>'  => sub { $MarpaX::RFC::RFC3987::SELF->_struct->userinfo ($_[1]) },
             '<ihost>'      => sub { $MarpaX::RFC::RFC3987::SELF->_struct->host     ($_[1]) },
             '<iport>'      => sub { $MarpaX::RFC::RFC3987::SELF->_struct->port     ($_[1]) },
            }
     };

has input   => ( is => 'ro', isa => Str,    required => 1);
has _struct => ( is => 'rw', isa => Object, default => sub { Generic->new() });

sub BUILDARGS {
  my ($self, @args) = @_;
  unshift(@args, 'input') if @args % 2;
  return { @args };
}

sub BUILD {
  my ($self) = @_;
  local $MarpaX::RFC::RFC3987::SELF = $self;
  $self->grammar->parse(\$self->_input, { ranking_method => 'high_rule_only' });
}

extends 'MarpaX::RFC::RFC3987::_common';

1;

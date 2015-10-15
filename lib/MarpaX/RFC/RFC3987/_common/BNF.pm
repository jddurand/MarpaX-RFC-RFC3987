package MarpaX::RFC::RFC3987::_common::BNF;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

our $DATA = do { local $/; <DATA> };

class_has bnf               => ( is => 'ro', isa => Str,     default => sub { $DATA } );
class_has grammar_option    => ( is => 'ro', isa => HashRef, default => sub { { } } );
class_has recognizer_option => ( is => 'ro', isa => HashRef, default => sub { { ranking_method => 'high_rule_only' } } );
class_has escape            => ( is => 'ro', isa => CodeRef, default => sub { sub { return $_[1] } } );   # Don't know
class_has unescape          => ( is => 'ro', isa => CodeRef, default => sub { sub { return $_[1] } } );   # Don't know

with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::BNF';

1;

__DATA__
<common>  ::= <scheme> ':' <opaque> '#' <fragment> rank =>   0
            |          ':' <opaque> '#' <fragment> rank =>  -1
            | <scheme>     <opaque> '#' <fragment> rank =>  -2
            |              <opaque> '#' <fragment> rank =>  -3
            | <scheme> ':'          '#' <fragment> rank =>  -4
            |          ':'          '#' <fragment> rank =>  -5
            | <scheme>              '#' <fragment> rank =>  -6
            |                       '#' <fragment> rank =>  -7
            | <scheme> ':' <opaque>     <fragment> rank =>  -8
            |          ':' <opaque>     <fragment> rank =>  -9
            | <scheme>     <opaque>     <fragment> rank => -10
            |              <opaque>     <fragment> rank => -11
            | <scheme> ':'              <fragment> rank => -12
            |          ':'              <fragment> rank => -13
            | <scheme>                  <fragment> rank => -14
            |                           <fragment> rank => -15
            | <scheme> ':' <opaque> '#'            rank => -16
            |          ':' <opaque> '#'            rank => -17
            | <scheme>     <opaque> '#'            rank => -18
            |              <opaque> '#'            rank => -19
            | <scheme> ':'          '#'            rank => -20
            |          ':'          '#'            rank => -21
            | <scheme>              '#'            rank => -22
            |                       '#'            rank => -23
            | <scheme> ':' <opaque>                rank => -24
            |          ':' <opaque>                rank => -25
            | <scheme>     <opaque>                rank => -26
            |              <opaque>                rank => -27
            | <scheme> ':'                         rank => -28
            |          ':'                         rank => -29
            | <scheme>                             rank => -30
<common>   ::=

<scheme header>    ::= [A-Za-z]
<scheme trailer>   ::= [A-Za-z0-9+.-]*
<scheme>           ::= <scheme header> <scheme trailer>

<opaque header>    ::= [^:#]
<opaque trailer>   ::= [^#]*
<opaque>           ::= <opaque header> <opaque trailer>

<fragment header>  ::= [^#]
<fragment trailer> ::= [\s\S]*
<fragment>         ::= <fragment header> <fragment trailer>

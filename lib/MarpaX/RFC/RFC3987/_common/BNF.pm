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
class_has escape            => ( is => 'ro', isa => CodeRef, default => sub { \&_escape } );
class_has unescape          => ( is => 'ro', isa => CodeRef, default => sub { \&_unescape } );

sub _escape {}
sub _unescape {}

with 'MarpaX::Role::Parameterized::ResourceIdentifier::BNF';

1;

__DATA__
<common>  ::= <scheme> ':' <opaque> '#' <fragment> rank =>  0
            |              <opaque> '#' <fragment> rank => -1
            | <scheme> ':'          '#' <fragment> rank => -2
            |                       '#' <fragment> rank => -3
            | <scheme> ':' <opaque>                rank => -4
            |              <opaque>                rank => -5
            | <scheme> ':'                         rank => -6
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

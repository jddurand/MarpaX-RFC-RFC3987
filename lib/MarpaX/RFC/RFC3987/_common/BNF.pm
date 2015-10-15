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
lexeme default = latm => 1
<common>  ::= <scheme> ':' <opaque> '#' <fragment> rank =>   0
<common>  ::= <scheme> ':' <opaque>                rank =>  -1
<common>  ::= <scheme> ':'          '#' <fragment> rank =>  -2
<common>  ::= <scheme> ':'                         rank =>  -3
<common>  ::=              <opaque> '#' <fragment> rank =>  -4
<common>  ::=              <opaque>                rank =>  -5
<common>  ::= ;


<scheme>         ::= [^:#]+
<opaque>         ::= [^#]*
<fragment>       ::= [\s\S]*

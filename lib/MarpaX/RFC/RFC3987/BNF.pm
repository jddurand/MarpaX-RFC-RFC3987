package MarpaX::RFC::RFC3987::BNF;
use Data::Section -setup;
use Moo;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

sub grammar_option {
  my ($class) = @_;

  return { ranking_method => 'high_rule_only' };
}

1;

__DATA__
__[ BNF ]__
<common>  ::= <scheme> ':' <opaque> '#' <fragment> rank =>  0
            |              <opaque> '#' <fragment> rank => -1
            | <scheme> ':'          '#' <fragment> rank => -2
            |                       '#' <fragment> rank => -3
            | <scheme> ':' <opaque>                rank => -4
            |              <opaque>                rank => -5
            | <scheme> ':'                         rank => -6
<common>   ::=

<opaque header>  ::= [^:#]
<opaque trailer> ::= [^#]*
<opaque>         ::= <opaque header> <opaque trailer>

<fragment header>  ::= [^#]
<fragment trailer> ::= [\s\S]*
<fragment>         ::= <fragment header> <fragment trailer>

<scheme trailer unit> ::= ALPHA | DIGIT | [+-.]
<scheme header>       ::= ALPHA
<scheme trailer>      ::= <scheme trailer unit>*
<scheme>              ::= <scheme header> <scheme trailer>

#
# No perl meta-character, just to be sure
#
ALPHA              ~ [A-Za-z]
DIGIT              ~ [0-9]

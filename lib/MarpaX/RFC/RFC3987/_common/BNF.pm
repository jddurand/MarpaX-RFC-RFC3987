package MarpaX::RFC::RFC3987::_common::BNF;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

our $DATA = do { local $/; <DATA> };

class_has bnf               => ( is => 'ro', isa => Str, default   => sub { $DATA } );
class_has start_symbol      => ( is => 'ro', isa => Str, default   => sub { '<common>' } );

with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::BNF';

1;

__DATA__
#
# Official for generic syntax is
# my ($scheme, $authority, $path, $query, $fragment) =
#  $uri =~ m|
#            (?:([^:/?#]+):)?
#            (?://([^/?#]*))?
#            ([^?#]*)
#            (?:\?([^#]*))?
#            (?:#(.*))?
#           |x;
#
# The / and ? are assuming the generic behaviour. By removing them
# we are back to the total opaque regexp:
#  $uri =~ m|
#            (?:([^:#]+):)?
#            ([^#]*)
#            (?:#(.*))?
#           |x;
#

<common>         ::= <scheme maybe> <opaque> <fragment maybe>
<scheme maybe>   ::= <scheme> ':'
<scheme maybe>   ::=
<scheme>         ::= [^:#]+
<opaque>         ::= [^#]*
<fragment maybe> ::= '#' <fragment>
<fragment maybe> ::=
<fragment>       ::= [\s\S]*
#
# In its most general form, only [:#] are reserved
#
<gen delims>     ::= [:#]

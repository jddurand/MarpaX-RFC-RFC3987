package MarpaX::RFC::RFC3987::_common::BNF;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

our $DATA = do { local $/; <DATA> };

class_has bnf               => ( is => 'ro', isa => Str,   default   => sub {      $DATA } );
class_has start_symbol      => ( is => 'ro', isa => Str,   default   => sub { '<common>' } );
#
# There is no decoding of %XX syntax in the common BNF
#
class_has pct_encoded       => ( is => 'ro', isa => Undef, default   => sub {      undef } );
class_has utf8_octets       => ( is => 'ro', isa => Undef, default   => sub {      undef } );
#
# There is no escape/unescape mechanism in the common BNF
#
class_has reserved          => ( is => 'ro', isa => Undef, default   => sub {      undef } );
class_has unreserved        => ( is => 'ro', isa => Undef, default   => sub {      undef } );
#
# Normalizer is reduced to its minimum: scheme
#
class_has normalizer        => ( is => 'ro', isa => CodeRef,
                                 default =>
                                 sub
                                 {
                                   sub {
                                     my ($self, $lhs, $value) = @_;

                                     if    ($lhs eq '<scheme>') { return lc($value) }
                                     else                       { return $value     }
                                   }
                                 }
                               );

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

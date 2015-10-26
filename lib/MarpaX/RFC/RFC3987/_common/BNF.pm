package MarpaX::RFC::RFC3987::_common::BNF;
use Marpa::R2;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;

# ABSTRACT: Internationalized Resource Identifier (IRI): Common Syntax - Marpa BNF

# VERSION

# AUTHORITY

our $DATA = do { local $/; <DATA> };

class_has action_name => ( is => 'ro', isa => Str,          default => sub { '_action' } );
class_has grammar     => ( is => 'ro', isa => ScalarRef,    default => sub { Marpa::R2::Scanless::G->new({source => \$DATA}) } );
class_has bnf         => ( is => 'ro', isa => ScalarRef,    default => sub {           $DATA } );
class_has reserved    => ( is => 'ro', isa => Undef,        default => sub {           undef } );
class_has unreserved  => ( is => 'ro', isa => Undef,        default => sub {           undef } );
class_has pct_encoded => ( is => 'ro', isa => Undef,        default => sub {           undef } );
class_has is_utf8     => ( is => 'ro', isa => Bool,         default => sub {             !!0 } );
class_has mapping     => ( is => 'ro', isa => HashRef[Str], default => sub {
                             {
                               '<common>'         => 'output',
                               '<scheme>'         => 'scheme',
                               '<opaque>'         => 'opaque',
                               '<fragment>'       => 'fragment',
                             }
                           }
                         );

with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::BNF';

1;

__DATA__
inaccessible is ok by default
:default ::= action => _action
:start ::= <common>
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

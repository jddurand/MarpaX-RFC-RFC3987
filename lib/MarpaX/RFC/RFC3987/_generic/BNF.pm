package MarpaX::RFC::RFC3987::_generic::BNF;
use Marpa::R2;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - Marpa BNF

# VERSION

# AUTHORITY

our $ALPHA   = qr/(?:[A-Za-z])/;
our $DIGIT   = qr/(?:[0-9])/;
our $UCSCHAR = qr/(?:[\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}])/;
our $GEN_DELIMS = qr/(?:[\:\/\?\[\]\@\#])/;
our $SUB_DELIMS = qr/(?:[\!\$\&\'\(\)\*\+\,\;\=])/;

our $DATA       = do { local $/; <DATA> };
our $RESERVED   = qr/(?:$GEN_DELIMS|$SUB_DELIMS)/;
our $UNRESERVED = qr/(?:$ALPHA|$DIGIT|[\-._~]|$UCSCHAR)/;

class_has action_name => ( is => 'ro', isa => Str,          default => sub { '_action' } );
class_has grammar     => ( is => 'ro', isa => ScalarRef,    default => sub { Marpa::R2::Scanless::G->new({source => \$DATA}) } );
class_has bnf         => ( is => 'ro', isa => ScalarRef,    default => sub {           $DATA } );
class_has reserved    => ( is => 'ro', isa => RegexpRef,    default => sub {       $RESERVED } );
class_has unreserved  => ( is => 'ro', isa => RegexpRef,    default => sub {     $UNRESERVED } );
class_has pct_encoded => ( is => 'ro', isa => Str,          default => sub { '<pct encoded>' } );
class_has is_utf8     => ( is => 'ro', isa => Bool,         default => sub {             !!1 } );
class_has mapping     => ( is => 'ro', isa => HashRef[Str], default => sub {
                             {
                               '<IRI reference>'  => 'output',
                               '<scheme>'         => 'scheme',
                               '<opaque>'         => 'opaque',
                               '<ihier part>'     => 'hier_part',
                               '<iquery>'         => 'query',
                               '<ifragment>'      => 'fragment',
                               '<isegments>'      => 'segment',
                               '<iauthority>'     => 'authority',
                               '<ipath>'          => 'path',
                               '<ipath abempty>'  => 'path_abempty',
                               '<ipath absolute>' => 'path_absolute',
                               '<ipath noscheme>' => 'path_noscheme',
                               '<ipath rootless>' => 'path_rootless',
                               '<ipath empty>'    => 'path_empty',
                               '<irelative ref>'  => 'relative_ref',
                               '<irelative part>' => 'relative_part',
                               '<iuserinfo>'      => 'userinfo',
                               '<ihost>'          => 'host',
                               '<iport>'          => 'port',
                               '<IP literal>'     => 'ip_literal',
                               '<IPv6address>'    => 'ipv6_address',
                               '<IPv4address>'    => 'ipv4_address',
                               '<ireg name>'      => 'reg_name',
                               '<IPv6addrz>'      => 'ipv6_addrz',
                               '<IPvFuture>'      => 'ipvfuture',
                               '<ZoneID>'         => 'zoneid',
                               '<isegment>'       => 'segments',
                               '<isegment nz>'    => 'segments',
                               '<isegment nz nc>' => 'segments',
                             }
                           }
                         );

with 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::BNF';

1;
__DATA__
inaccessible is ok by default
:default ::= action => _action
:start ::= <IRI reference>

<opaque>  ::= <ihier part>     '?' <iquery>
            | <ihier part>
            | <irelative part> '?' <iquery>
            | <irelative part>

<IRI>         ::= <scheme> ':' <opaque> '#' <ifragment>
                | <scheme> ':' <opaque>

<ihier part>     ::= '//' <iauthority> <ipath abempty>
                   | <ipath absolute>
                   | <ipath rootless>
                   | <ipath empty>

<IRI reference> ::= <IRI>
                  | <irelative ref>

<absolute IRI>  ::= <scheme> ':' <opaque>

<irelative ref>  ::= <opaque> '#' <ifragment>
                   | <opaque>

<irelative part> ::= '//' <iauthority> <ipath abempty>
                   | <ipath absolute>
                   | <ipath noscheme>
                   | <ipath empty>

<scheme trailer unit> ::= ALPHA | DIGIT | [+-.]
<scheme header>       ::= ALPHA
<scheme trailer>      ::= <scheme trailer unit>*
<scheme>              ::= <scheme header> <scheme trailer>

<iauthority>     ::= <iuserinfo> '@' <ihost> ':' <port>
                   | <iuserinfo> '@' <ihost>
                   | <ihost> ':' <port>
                   | <ihost>

<iuserinfo unit> ::= <iunreserved> | <pct encoded> | <sub delims> | ':'
<iuserinfo>      ::= <iuserinfo unit>*

#
# As per the RFC:
# he syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.
#
# Please note that <pct encoded> is revisited to catch a SEQUENCE of
# encoded digits
#
<ihost>          ::= <IP literal>
                   | <IPv4address>                            rank => 1
                   | <ireg name>

<port>          ::= DIGIT*

<IP literal>    ::= '[' IPv6address ']'
                  | '[' IPv6addrz   ']'
                  | '[' IPvFuture   ']'

<ZoneID unit>   ::= <iunreserved> | <pct encoded>
<ZoneID>        ::= <ZoneID unit>+

<IPv6addrz>     ::= <IPv6address> '%25' <ZoneID>

<hexdigit many>          ::= HEXDIG+
<IPvFuture trailer unit> ::= <iunreserved> | <sub delims> | ':'
<IPvFuture trailer>      ::= <IPvFuture trailer unit>+
<IPvFuture>              ::= 'v' <hexdigit many> '.' <IPvFuture trailer>

<1 h16 colon>   ::= <h16> ':'
<2 h16 colon>   ::= <1 h16 colon> <1 h16 colon>
<3 h16 colon>   ::= <2 h16 colon> <1 h16 colon>
<4 h16 colon>   ::= <3 h16 colon> <1 h16 colon>
<5 h16 colon>   ::= <4 h16 colon> <1 h16 colon>
<6 h16 colon>   ::= <5 h16 colon> <1 h16 colon>

<at most 1 h16 colon>  ::=                                              rank => 0
<at most 1 h16 colon>  ::=         <1 h16 colon>                        rank => 1
<at most 2 h16 colon>  ::= <at most 1 h16 colon>                        rank => 0
                         | <at most 1 h16 colon> <1 h16 colon>          rank => 1
<at most 3 h16 colon>  ::= <at most 2 h16 colon>                        rank => 0
                         | <at most 2 h16 colon> <1 h16 colon>          rank => 1
<at most 4 h16 colon>  ::= <at most 3 h16 colon>                        rank => 0
                         | <at most 3 h16 colon> <1 h16 colon>          rank => 1
<at most 5 h16 colon>  ::= <at most 4 h16 colon>                        rank => 0
                         | <at most 4 h16 colon> <1 h16 colon>          rank => 1
<at most 6 h16 colon>  ::= <at most 5 h16 colon>                        rank => 0
                         | <at most 5 h16 colon> <1 h16 colon>          rank => 1

<IPv6address>    ::=                                  <6 h16 colon> <ls32>
                   |                             '::' <5 h16 colon> <ls32>
                   |                       <h16> '::' <4 h16 colon> <ls32>
                   |                             '::' <4 h16 colon> <ls32>
                   | <at most 1 h16 colon> <h16> '::' <3 h16 colon> <ls32>
                   |                             '::' <3 h16 colon> <ls32>
                   | <at most 2 h16 colon> <h16> '::' <2 h16 colon> <ls32>
                   |                             '::' <2 h16 colon> <ls32>
                   | <at most 3 h16 colon> <h16> '::' <1 h16 colon> <ls32>
                   |                             '::' <1 h16 colon> <ls32>
                   | <at most 4 h16 colon> <h16> '::'               <ls32>
                   |                             '::'               <ls32>
                   | <at most 5 h16 colon> <h16> '::'               <h16>
                   |                             '::'               <h16>
                   | <at most 6 h16 colon> <h16> '::'
                   |                             '::'

<h16>            ::= HEXDIG
                   | HEXDIG HEXDIG
                   | HEXDIG HEXDIG HEXDIG
                   | HEXDIG HEXDIG HEXDIG HEXDIG

<ls32>           ::= <h16> ':' <h16>
                   | <IPv4address>

IPv4address      ::= <dec octet> '.' <dec octet> '.' <dec octet> '.' <dec octet>

<dec octet>      ::=                      DIGIT # 0-9
                   |      [\x{31}-\x{39}] DIGIT # 10-99
                   | '1'            DIGIT DIGIT # 100-199
                   | '2'  [\x{30}-\x{34}] DIGIT # 200-249
                   | '25' [\x{30}-\x{35}]       # 250-255

<ireg name unit> ::= <iunreserved> | <pct encoded> | <sub delims>
<ireg name>      ::= <ireg name unit>*

<ipath>          ::= <ipath abempty>    # begins with "/" or is empty
                   | <ipath absolute>   # begins with "/" but not "//"
                   | <ipath noscheme>   # begins with a non-colon segment
                   | <ipath rootless>   # begins with a segment
                   | <ipath empty>      # zero character

<isegment unit>  ::= '/' <isegment>
<isegments>      ::= <isegment unit>*
<ipath abempty>  ::= <isegments>

<ipath absolute> ::= '/' <isegment nz> <isegments>
                   | '/'
<ipath noscheme> ::= <isegment nz nc> <isegments>
<ipath rootless> ::= <isegment nz> <isegments>
<ipath empty>    ::=

#
# All possible segments are here
#
<isegment>       ::= <ipchar>*
<isegment nz>    ::= <ipchar>+
<isegment nz nc unit> ::= <iunreserved> | <pct encoded> | <sub delims> | '@'
<isegment nz nc> ::= <isegment nz nc unit>+                            # non-zero-length segment without any colon ":"

<ipchar>         ::= <iunreserved> | <pct encoded> | <sub delims> | [:@]

<iquery unit>    ::= <ipchar> | <iprivate> | [/?]
<iquery>         ::= <iquery unit>*

<ifragment unit> ::= <ipchar> | [/?]
<ifragment>      ::= <ifragment unit>*

<lexeme pct encoded unit> ~ '%' _HEXDIG _HEXDIG
<lexeme pct encoded> ~ <lexeme pct encoded unit>+
<pct encoded>      ::= <lexeme pct encoded>

<iunreserved>    ::= ALPHA | DIGIT | [-._~] | <ucschar>

<ucschar>        ::= [\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}]

<iprivate>       ::= [\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}\x{100000}-\x{10FFFD}]

<sub delims>     ::= [!$&'()*+,;=]

#
# These rules are informative: they are not productive
#
<reserved>       ::= <gen delims> | <sub delims>
<gen delims>     ::= [:/?\[\]@#]
#
# No perl meta-character, just to be sure
#
ALPHA              ~ [A-Za-z]
DIGIT              ~ [0-9]
_HEXDIG            ~ [0-9A-Fa-f]
HEXDIG             ~ _HEXDIG

package MarpaX::RFC::RFC3987::BNF;
use Data::Section -setup;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - Marpa BNF

# VERSION

# AUTHORITY

1;

__DATA__
__[ BNF ]__
inaccessible is ok by default
:default ::= action => MarpaX::RFC::RFC3987::_marpa_concat
:start ::= <IRI reference>

<IRI>         ::= <scheme> ':' <ihier part> '?' <iquery> '#' <ifragment>
                | <scheme> ':' <ihier part> '?' <iquery>
                | <scheme> ':' <ihier part>              '#' <ifragment>
                | <scheme> ':' <ihier part>

<ihier part>     ::= '//' <iauthority> <ipath abempty>                    action => MarpaX::RFC::RFC3987::_marpa_ihier_part
                   | <ipath absolute>                                     action => MarpaX::RFC::RFC3987::_marpa_ihier_part
                   | <ipath rootless>                                     action => MarpaX::RFC::RFC3987::_marpa_ihier_part
                   | <ipath empty>                                        action => MarpaX::RFC::RFC3987::_marpa_ihier_part

<IRI reference> ::= <IRI>
                  | <irelative ref>

<absolute IRI>  ::= <scheme> ':' <ihier part> '?' <iquery>
                  | <scheme> ':' <ihier part>

<irelative ref>  ::= <irelative part> '?' <iquery> '#' <ifragment>
                   | <irelative part> '?' <iquery>
                   | <irelative part>              '#' <ifragment>
                   | <irelative part>

<irelative part> ::= '//' <iauthority> <ipath abempty>                    action => MarpaX::RFC::RFC3987::_marpa_irelative_part
                  | <ipath absolute>                                      action => MarpaX::RFC::RFC3987::_marpa_irelative_part
                  | <ipath noscheme>                                      action => MarpaX::RFC::RFC3987::_marpa_irelative_part
                  | <ipath empty>                                         action => MarpaX::RFC::RFC3987::_marpa_irelative_part

<scheme trailer unit> ::= ALPHA | DIGIT | [+-.]
<scheme header>       ::= ALPHA
<scheme trailer>      ::= <scheme trailer unit>*
<scheme>              ::= <scheme header> <scheme trailer>                 action => MarpaX::RFC::RFC3987::_marpa_scheme

<iauthority>     ::= <iuserinfo> '@' <ihost> ':' <port>                    action => MarpaX::RFC::RFC3987::_marpa_iauthority
                   | <iuserinfo> '@' <ihost>                               action => MarpaX::RFC::RFC3987::_marpa_iauthority
                   |                 <ihost> ':' <port>                    action => MarpaX::RFC::RFC3987::_marpa_iauthority
                   |                 <ihost>                               action => MarpaX::RFC::RFC3987::_marpa_iauthority

<iuserinfo unit> ::= <iunreserved> | <pct encoded> | <sub delims> | ':'
<iuserinfo>      ::= <iuserinfo unit>*                                     action => MarpaX::RFC::RFC3987::_marpa_iuserinfo

#
# As per the RFC:
# he syntax rule for host is ambiguous because it does not completely
# distinguish between an IPv4address and a reg-name.  In order to
# disambiguate the syntax, we apply the "first-match-wins" algorithm:
# If host matches the rule for IPv4address, then it should be
# considered an IPv4 address literal and not a reg-name.

<ihost>          ::= <IP literal>                                        action => MarpaX::RFC::RFC3987::_marpa_ihost
                   | <IPv4address>                            rank => 1  action => MarpaX::RFC::RFC3987::_marpa_ihost
                   | <ireg name>                                         action => MarpaX::RFC::RFC3987::_marpa_ihost

<port>          ::= DIGIT*                                              action => MarpaX::RFC::RFC3987::_marpa_port

<IP literal>    ::= '[' IPv6address ']'                                 action => MarpaX::RFC::RFC3987::_marpa_ip_literal
                  | '[' IPv6addrz   ']'                                 action => MarpaX::RFC::RFC3987::_marpa_ip_literal
                  | '[' IPvFuture   ']'                                 action => MarpaX::RFC::RFC3987::_marpa_ip_literal

<ZoneID unit>   ::= <iunreserved> | <pct encoded>
<ZoneID>        ::= <ZoneID unit>+                                      action => MarpaX::RFC::RFC3987::_marpa_zoneid

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

<IPv6address>   ::=                                  <6 h16 colon> <ls32>
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

<ls32>          ::= <h16> ':' <h16>
                  | <IPv4address>

IPv4address     ::= <dec octet> '.' <dec octet> '.' <dec octet> '.' <dec octet> action => MarpaX::RFC::RFC3987::_marpa_ipv4address

<dec octet>     ::=                      DIGIT # 0-9
                  |      [\x{31}-\x{39}] DIGIT # 10-99
                  | '1'            DIGIT DIGIT # 100-199
                  | '2'  [\x{30}-\x{34}] DIGIT # 200-249
                  | '25' [\x{30}-\x{35}]       # 250-255

<ireg name unit> ::= <iunreserved> | <pct encoded> | <sub delims>
<ireg name>      ::= <ireg name unit>*                                 action => MarpaX::RFC::RFC3987::_marpa_ireg_name

<ipath>          ::= <ipath abempty>    # begins with "/" or is empty
                   | <ipath absolute>   # begins with "/" but not "//"
                   | <ipath noscheme>   # begins with a non-colon segment
                   | <ipath rootless>   # begins with a segment
                   | <ipath empty>      # zero character

<isegment unit> ::= '/' <isegment>
<isegments>     ::= <isegment unit>*
<ipath abempty>  ::= <isegments>                                       action => MarpaX::RFC::RFC3987::_marpa_ipath

<ipath absolute> ::= '/' <isegment nz> <isegments>                      action => MarpaX::RFC::RFC3987::_marpa_ipath
                   | '/'                                                action => MarpaX::RFC::RFC3987::_marpa_ipath
<ipath noscheme> ::= <isegment nz nc> <isegments>                       action => MarpaX::RFC::RFC3987::_marpa_ipath
<ipath rootless> ::= <isegment nz> <isegments>                          action => MarpaX::RFC::RFC3987::_marpa_ipath
<ipath empty>    ::=                                                    action => MarpaX::RFC::RFC3987::_marpa_ipath

#
# All possible segments are here
#
<isegment>       ::= <ipchar>*
<isegment nz>    ::= <ipchar>+
<isegment nz nc unit> ::= <iunreserved> | <pct encoded> | <sub delims> | '@'
<isegment nz nc> ::= <isegment nz nc unit>+                            # non-zero-length segment without any colon ":"

<ipchar>         ::= <iunreserved> | <pct encoded> | <sub delims> | [:@]

<iquery unit>    ::= <ipchar> | <iprivate> | [/?]
<iquery>         ::= <iquery unit>*                                    action => MarpaX::RFC::RFC3987::_marpa_iquery

<ifragment unit> ::= <ipchar> | [/?]
<ifragment>      ::= <ifragment unit>*                                 action => MarpaX::RFC::RFC3987::_marpa_ifragment

<pct encoded>    ::= '%' HEXDIG HEXDIG

<iunreserved>    ::= ALPHA | DIGIT | [-._~] | <ucschar>

<ucschar>        ::= [\x{A0}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFEF}\x{10000}-\x{1FFFD}\x{20000}-\x{2FFFD}\x{30000}-\x{3FFFD}\x{40000}-\x{4FFFD}\x{50000}-\x{5FFFD}\x{60000}-\x{6FFFD}\x{70000}-\x{7FFFD}\x{80000}-\x{8FFFD}\x{90000}-\x{9FFFD}\x{A0000}-\x{AFFFD}\x{B0000}-\x{BFFFD}\x{C0000}-\x{CFFFD}\x{D0000}-\x{DFFFD}\x{E1000}-\x{EFFFD}]

<iprivate>      ::= [\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}\x{100000}-\x{10FFFD}]

<sub delims>    ::= [!$&'()*+,;=]

#
# These rules are informative: they are not productive
#
<reserved>      ::= <gen delims> | <sub delims>
<gen delims>    ::= [:/?#\[\]@]
#
# No perl meta-character, just to be sure
#
ALPHA         ::= [A-Za-z]
DIGIT         ::= [0-9]
HEXDIG        ::= [0-9A-Fa-f]

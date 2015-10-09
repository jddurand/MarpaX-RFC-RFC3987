#!perl -T

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic Syntax - test suite

# VERSION

# AUTHORITY

use strict;
use warnings FATAL => 'all';
use Test::More tests => 15;

BEGIN {
    use_ok( 'MarpaX::RFC::RFC3987' ) || print "Bail out!\n";
}

our @URI_ABSOLUTE_TEST = (
            [ "http://localhost/"                                   => 1 ],
            [ "ftp://ftp.is.co.za/rfc/rfc1808.txt"                  => 1 ],
            [ "http://www.ietf.org/rfc/rfc2396.txt"                 => 1 ],
            [ "ldap://[2001:db8::7]/c=GB?objectClass?one"           => 1 ],
            [ "mailto:John.Doe\@example.com"                        => 1 ],
            [ "news:comp.infosystems.www.servers.unix"              => 1 ],
            [ "tel:+1-816-555-1212"                                 => 1 ],
            [ "telnet://192.0.2.16:80/"                             => 1 ],
            [ "urn:oasis:names:specification:docbook:dtd:xml:4.1.2" => 1 ],
            [ "foo://example.com:8042/over/there?name=ferret#nose"  => 0 ],
            [ "urn:example:animal:ferret:nose"                      => 1 ],
            [ "http://\x{7D0D}\x{8C46}.example.org/%E2%80%AE"       => 1 ],
           );

our @URI_CANONICAL_TEST = (
            [ '/a/b/c/./../../g'                                    => '/a/g' ],
            [ "\x{7D0D}mid/content=5/../6"                          => "\x{7D0D}mid/6"]
           );

foreach (@URI_ABSOLUTE_TEST) {
  my $got;
  ok(($got = MarpaX::RFC::RFC3987->new($_->[0])->is_absolute) == $_->[1], 'MarpaX::RFC::RFC3987->new->("' . _safePrint($_->[0]) . '")->is_absolute returned ' . int($got) . ' == ' . $_->[1] . ' ?');
}

foreach (@URI_CANONICAL_TEST) {
  my $got;
  ok(($got = MarpaX::RFC::RFC3987->new($_->[0])->canonical) eq $_->[1], 'MarpaX::RFC::RFC3987->new->("' . _safePrint($_->[0]) . '")->canonical returned "' . _safePrint($got) . '" eq "' . _safePrint($_->[1]) . '" ?');
}

sub _safePrint {
  my ($string) = @_;
  $string =~ s/([^\x20-\x7E])/sprintf("\\x{%X}", ord($1))/ge;
  $string;
}

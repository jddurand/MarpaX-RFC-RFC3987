#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More tests => 13;

BEGIN {
    use_ok( 'MarpaX::RFC::RFC3987' ) || print "Bail out!\n";
}

our @URI = (
            "http://localhost/",
            "ftp://ftp.is.co.za/rfc/rfc1808.txt",
            "http://www.ietf.org/rfc/rfc2396.txt",
            "ldap://[2001:db8::7]/c=GB?objectClass?one",
            "mailto:John.Doe\@example.com",
            "news:comp.infosystems.www.servers.unix",
            "tel:+1-816-555-1212",
            "telnet://192.0.2.16:80/",
            "urn:oasis:names:specification:docbook:dtd:xml:4.1.2",
            "foo://example.com:8042/over/there?name=ferret#nose",
            "urn:example:animal:ferret:nose",
            "http://\x{7D0D}\x{8C46}.example.org/%E2%80%AE"
           );

foreach (@URI) {
  ok(MarpaX::RFC::RFC3987->new($_)->is_absolute, $_);
}

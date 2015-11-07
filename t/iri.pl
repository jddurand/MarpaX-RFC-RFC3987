#!perl
use strict;
use warnings FATAL => 'all';
use Scalar::Util qw/blessed/;
use Test::More;
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

our $_test_abs_base;
BEGIN {
    use_ok('MarpaX::RFC::RFC3987') || print "Bail out!\n";
    $_test_abs_base = 'http://a/b/c/d;p?q';
}

subtest "Reference Resolution with base as Str"    => \&_test_abs_base_as_Str;
subtest "Reference Resolution with base as Object" => \&_test_abs_base_as_Object;
subtest "Overload with URI compatibility"          => \&_test_overload_with_uri_compatibility;
subtest "Overload without URI compatibility"       => \&_test_overload_without_uri_compatibility;
subtest "is_absolute"                              => \&_test_is_absolute;

done_testing();

sub _test_abs_base_as_Str                    { _test_abs($_test_abs_base) }
sub _test_abs_base_as_Object                 { _test_abs(MarpaX::RFC::RFC3987->new($_test_abs_base)) }
sub _test_overload_with_uri_compatibility    { _test_overload(1) }
sub _test_overload_without_uri_compatibility { _test_overload(0) }

sub _test_abs {
  my $base = shift;

  my %ref2base = (
                  "g:h"           =>  "g:h",
                  "g"             =>  "http://a/b/c/g",
                  "./g"           =>  "http://a/b/c/g",
                  "g/"            =>  "http://a/b/c/g/",
                  "/g"            =>  "http://a/g",
                  "//g"           =>  "http://g",
                  "?y"            =>  "http://a/b/c/d;p?y",
                  "g?y"           =>  "http://a/b/c/g?y",
                  "#s"            =>  "http://a/b/c/d;p?q#s",
                  "g#s"           =>  "http://a/b/c/g#s",
                  "g?y#s"         =>  "http://a/b/c/g?y#s",
                  ";x"            =>  "http://a/b/c/;x",
                  "g;x"           =>  "http://a/b/c/g;x",
                  "g;x?y#s"       =>  "http://a/b/c/g;x?y#s",
                  ""              =>  "http://a/b/c/d;p?q",
                  "."             =>  "http://a/b/c/",
                  "./"            =>  "http://a/b/c/",
                  ".."            =>  "http://a/b/",
                  "../"           =>  "http://a/b/",
                  "../g"          =>  "http://a/b/g",
                  "../.."         =>  "http://a/",
                  "../../"        =>  "http://a/",
                  "../../g"       =>  "http://a/g",
                  #
                  # Abnormal cases
                  #
                  "../../../g"    =>  "http://a/g",
                  "../../../../g" =>  "http://a/g",
                  "/./g"          =>  "http://a/g",
                  "/../g"         =>  "http://a/g",
                  "g."            =>  "http://a/b/c/g.",
                  ".g"            =>  "http://a/b/c/.g",
                  "g.."           =>  "http://a/b/c/g..",
                  "..g"           =>  "http://a/b/c/..g",
                  "./../g"        =>  "http://a/b/g",
                  "./g/."         =>  "http://a/b/c/g/",
                  "g/./h"         =>  "http://a/b/c/g/h",
                  "g/../h"        =>  "http://a/b/c/h",
                  "g;x=1/./y"     =>  "http://a/b/c/g;x=1/y",
                  "g;x=1/../y"    =>  "http://a/b/c/y",
                  "g?y/./x"       =>  "http://a/b/c/g?y/./x",
                  "g?y/../x"      =>  "http://a/b/c/g?y/../x",
                  "g#s/./x"       =>  "http://a/b/c/g#s/./x",
                  "g#s/../x"      =>  "http://a/b/c/g#s/../x",
                  "http:g"        =>  "http:g"
                 );
  plan tests => scalar(keys %ref2base);

  my $blessed_base = blessed($base) || 'Str';

  foreach (keys %ref2base) {
    my $wanted = $ref2base{$_};
    my $got    = MarpaX::RFC::RFC3987->new($_)->abs($base);
    is($got, $wanted, "base '$base' as $blessed_base, ref '$_'");
  }
}

sub _test_overload {
  my $uri_compat = shift;

  plan tests => 2;
  local $ENV{MarpaX_RI_URI_COMPAT} = $uri_compat;

  my @overload_test = (MarpaX::RFC::RFC3987->new("http://example.org/~user"),
                       MarpaX::RFC::RFC3987->new("http://example.org/%7euser"));
  if ($uri_compat) {
    ok($overload_test[0] != $overload_test[1], "'$overload_test[0]' != '$overload_test[1]'");
    ok($overload_test[0] ne $overload_test[1], "'$overload_test[0]' ne '$overload_test[1]'");
  } else {
    ok($overload_test[0] == $overload_test[1], "'$overload_test[0]' == '$overload_test[1]'");
    ok($overload_test[0] ne $overload_test[1], "'$overload_test[0]' ne '$overload_test[1]'");
  }
}

sub _test_is_absolute {
  my @URI = (
             [ "/localhost/?jdd#f±f2"                                => 0 ],
             [ "ftp://ftp.is.co.za/rfc/rfc1808.txt"                  => 1 ],
             [ "http://www.ietf.org/rfc/rfc2396.txt"                 => 1 ],
             [ "ldap://[2001:db8::7]/c=GB?objectClass?one"           => 1 ],
             [ "mailto:John.Doe\@example.com"                        => 1 ],
             [ "news:comp.infosystems.www.servers.unix"              => 1 ],
             [ "tel:+1-816-555-1212"                                 => 1 ],
             [ "telnet://192.0.2.16:80/"                             => 1 ],
             [ "urn:oasis:names:specification:docbook:dtd:xml:4.1.2" => 1 ],
             [ "foo://example.com:8042/over/there?name=ferret#nose"  => 1 ],
             [ "example.com:8042/over/there?name=ferret#nose"        => 1 ],   # example.com looks like a scheme
             [ "urn:example:animal:ferret:nose"                      => 1 ],
             [ "http://\x{7D0D}\x{8C46}.example.org/%E2%80%AE"       => 1 ],
            );
  plan tests => scalar(@URI);

  foreach (@URI) {
    my $is_absolute = MarpaX::RFC::RFC3987->new($_->[0])->is_absolute;
    ok($_->[1] ? $is_absolute : ! $is_absolute, "'$_->[0]' is " . ($_->[1] ? '' : 'not ') . 'absolute');
  }
}

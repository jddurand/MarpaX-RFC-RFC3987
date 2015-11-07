#!perl -T
use strict;
use warnings FATAL => 'all';
use Scalar::Util qw/blessed/;
use Test::More;
use FindBin;
use Test::File::ShareDir
  -root => "$FindBin::Bin/../",
  -share => {
             -module => { 'MarpaX::RFC::RFC3987' => 'share' }
  };
use Taint::Util;

binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

our $_test_abs_base;
BEGIN {
  untaint $ENV{PATH};      # Because of File::ShareDir::ProjectDistDir
  use_ok('MarpaX::RFC::RFC3987') || print "Bail out!\n";
  $_test_abs_base = 'http://a/b/c/d;p?q';
}

subtest "Reference Resolution with base as Str"    => \&_test_abs_base_as_Str;
subtest "Reference Resolution with base as Object" => \&_test_abs_base_as_Object;
subtest "Overload with URI compatibility"          => \&_test_overload_with_uri_compatibility;
subtest "Overload without URI compatibility"       => \&_test_overload_without_uri_compatibility;
subtest "is_absolute"                              => \&_test_is_absolute;
subtest "Cloning "                                 => \&_test_clone;
subtest "canonical and normalized are identical"   => \&_test_canonical;

done_testing();

1;

#
# Proxies
#
sub _test_abs_base_as_Str                    { _test_abs($_test_abs_base) }
sub _test_abs_base_as_Object                 { _test_abs(MarpaX::RFC::RFC3987->new($_test_abs_base)) }
sub _test_overload_with_uri_compatibility    { _test_overload(1) }
sub _test_overload_without_uri_compatibility { _test_overload(0) }
#
# Constants
#
use constant {
  TEST_ABS => {
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
                "http:g"       =>  "http:g"
              }
};
use constant {
  TEST_OVERLOAD => {
                    'equality' => [ "http://example.org/~user", "http://example.org/%7euser" ]
                   }
};
use constant {
  TEST_IS_ABSOLUTE => {
                       "/localhost/?jdd#f±f2"                                => 0,
                       "ftp://ftp.is.co.za/rfc/rfc1808.txt"                  => 1,
                       "http://www.ietf.org/rfc/rfc2396.txt"                 => 1,
                       "ldap://[2001:db8::7]/c=GB?objectClass?one"           => 1,
                       "mailto:John.Doe\@example.com"                        => 1,
                       "news:comp.infosystems.www.servers.unix"              => 1,
                       "tel:+1-816-555-1212"                                 => 1,
                       "telnet://192.0.2.16:80/"                             => 1,
                       "urn:oasis:names:specification:docbook:dtd:xml:4.1.2" => 1,
                       "foo://example.com:8042/over/there?name=ferret#nose"  => 1,
                       "example.com:8042/over/there?name=ferret#nose"        => 1,   # example.com looks like a scheme
                       "urn:example:animal:ferret:nose"                      => 1,
                       "http://\x{7D0D}\x{8C46}.example.org/%E2%80%AE"       => 1
                      }
};
use constant {
  TEST_CLONE => {
                 'test 01' => "http://example.org/~user",
                 'test 02' => "http://example.org/%7euser"
                }
};
use constant {
  TEST_CANONICAL => {
                     'test 01' => "http://example.org/~user",
                     'test 02' => "http://example.org/%7euser"
                    }
};
#
# Tests implementations
#
sub _test_abs {
  plan tests => scalar(keys %{TEST_ABS()});

  my $base = shift;
  my $blessed_base = blessed($base) || 'Str';

  foreach (keys %{TEST_ABS()}) {
    my $wanted = TEST_ABS()->{$_};
    my $got    = MarpaX::RFC::RFC3987->new($_)->abs($base);
    is($got, $wanted, "base '$base' as $blessed_base, ref '$_'");
  }
}

sub _test_overload {
  plan tests => scalar(values %{TEST_OVERLOAD()}) * 2;

  my $uri_compat = shift;
  local $ENV{MarpaX_RI_URI_COMPAT} = $uri_compat;

  foreach (values %{TEST_OVERLOAD()}) {
    my @overload = map { MarpaX::RFC::RFC3987->new($_) } @{$_};
    if ($uri_compat) {
      ok($overload[0] != $overload[1], "'$overload[0]' != '$overload[1]'");
      ok($overload[0] ne $overload[1], "'$overload[0]' ne '$overload[1]'");
    } else {
      ok($overload[0] == $overload[1], "'$overload[0]' == '$overload[1]'");
      ok($overload[0] ne $overload[1], "'$overload[0]' ne '$overload[1]'");
    }
  }
}

sub _test_is_absolute {
  plan tests => scalar(keys %{TEST_IS_ABSOLUTE()});

  foreach (keys %{TEST_IS_ABSOLUTE()}) {
    my $is_absolute = MarpaX::RFC::RFC3987->new($_)->is_absolute;
    ok(TEST_IS_ABSOLUTE->{$_} ? $is_absolute : ! $is_absolute, "'$_' is " . (TEST_IS_ABSOLUTE->{$_} ? '' : 'not ') . 'absolute');
  }
}

sub _test_clone {
  plan tests => scalar(values %{TEST_CLONE()});

  foreach (values %{TEST_CLONE()}) {
    my $orig  = MarpaX::RFC::RFC3987->new($_);
    my $clone = $orig->clone;
    is($orig, $clone, "Cloning of '$_'");
  }
}

sub _test_canonical {
  plan tests => scalar(values %{TEST_CANONICAL()});

  foreach (values %{TEST_CANONICAL()}) {
    my $o = MarpaX::RFC::RFC3987->new($_);
    is($o->canonical, $o->normalized, "'$_' canonical and normalized strings are identical");
  }
}

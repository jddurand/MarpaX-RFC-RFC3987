#!perl
use strict;
use warnings FATAL => 'all';
use Scalar::Util qw/blessed/;
use Test::More;

our $_test_abs_base;
BEGIN {
    use_ok('MarpaX::RFC::RFC3987') || print "Bail out!\n";
    $_test_abs_base = 'http://a/b/c/d;p?q';
}

subtest "Reference Resolution with base as Str"    => \&_test_abs_base_as_Str;
subtest "Reference Resolution with base as Object" => \&_test_abs_base_as_Object;

done_testing();

sub _test_abs_base_as_Str    { _test_abs($_test_abs_base) }
sub _test_abs_base_as_Object { _test_abs(MarpaX::RFC::RFC3987->new($_test_abs_base)) }

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

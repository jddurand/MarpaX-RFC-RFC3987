#!env perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Data::Printer;
use Encode;
use MarpaX::RFC::RFC3987;
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Log4perl qw/:easy/;
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

# ----
# Init
# ----
my $defaultLog4perlConf = <<DEFAULT_LOG4PERL_CONF;
log4perl.rootLogger              = TRACE, Screen
log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr  = 0
log4perl.appender.Screen.layout  = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
DEFAULT_LOG4PERL_CONF
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');

my $base = 'http://a/b/c/d;p?q';
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

foreach (keys %ref2base) {
  my $ref2base = MarpaX::RFC::RFC3987->new($_)->abs($base);
  if ($ref2base eq $ref2base{$_}) {
    print STDERR "OK for $_ => $ref2base\n";
  } else {
    print STDERR "KO for $_ => $ref2base instead of $ref2base{$_}\n";
  }
}
#
# Idem but with an object instead of a string
#
print STDERR "============ Use object instead of a string for $base\n";
$base = MarpaX::RFC::RFC3987->new('http://a/b/c/d;p?q');
foreach (keys %ref2base) {
  my $ref2base = MarpaX::RFC::RFC3987->new($_)->abs($base);
  if ($ref2base eq $ref2base{$_}) {
    print STDERR "OK for $_ => $ref2base\n";
  } else {
    print STDERR "KO for $_ => $ref2base instead of $ref2base{$_}\n";
  }
}

my @overload_test = (MarpaX::RFC::RFC3987->new("http://example.org/~user"), MarpaX::RFC::RFC3987->new("http://example.org/%7euser"));
print STDERR '== test is ' . ($overload_test[0] == $overload_test[1] ? "OK" : "KO") . "\n";
print STDERR '!= test is ' . ($overload_test[0] != $overload_test[1] ? "KO" : "OK") . "\n";
print STDERR '"" test is ' . $overload_test[0] . " and " . $overload_test[1] . "\n";

my $iri = MarpaX::RFC::RFC3987->new((@ARGV)
                                    ||
                                    { input => "HTTp://re\x{301}sume\x{301}.example.org/%7euser", is_character_normalized => 1, reg_name_convert_as_domain_name => 1 }
                                    ||
                                    {
                                     input => "http://\x{7D0D}\x{8C46}.example.org/%41%E2%89%A2%CE%91%2E%ED%95%9C%EA%B5%AD%EC%96%B4-%E6%97%A5%E6%9C%AC%E8%AA%9E-%EF%BB%BF%F0%A3%8E%B4/%7E%7euser#red&blue",
                                     # octets => "HTTp://www.exAMPLe.org:80/re+AwE-sume+AwE-/+ACU-7E+ACU-7euser/a/./b/../b/+ACU-63/+ACU-7bfoo+ACU-7d/ros+ACU-C3+ACU-A9/end",
                                     encoding => 'UTF-7',
                                     decode_strategy => "test",
                                     # is_character_normalized => 0
                                    }
                                    ||
                                    "http://example.com/\x{10300}\x{10301}\x{10302}"
                                    ||
                                    "http://www.example.org/red%09ros\x{E9}#red"
                                    ||
                                    { input => "http://r\x{E9}sum\x{E9}.example.org", is_reg_name_convert_to_IRI => 'X', is_reg_name_as_domain_name => 1 }
                                    ||
                                    "http://www.example.org/red%09ros\x{E9}#red"
                                    ||
                                    { octets => "HTTp://www.exAMPLe.org/re+AwE-sume+AwE-/+ACU-7Euser/a/./b/../b/+ACU-63/+ACU-7bfoo+ACU-7d/ros+ACU-C3+ACU-A9/end", encoding => 'UTF-7' }
                                    ||
                                    "HTTp://www.exAMPLe.org/re\x{301}sume\x{301}/%7Euser"
                                    ||
                                    "HTTp://eXüAMPLe.com?\x{5135}voila1...\&voila2\#~%eF%BF%Bdf"
                                    ||
                                    { octets => "http://www.example.org/resume.html", encoding => 'euc-jp', character_normalization_strategy => 'NFKC', is_character_normalized => 0, decode_strategy => Encode::FB_DEFAULT }
                                    ||
                                    "http://\x{7D0D}\x{8C46}.example.org/%41%E2%89%A2%CE%91%2E%ED%95%9C%EA%B5%AD%EC%96%B4-%E6%97%A5%E6%9C%AC%E8%AA%9E-%EF%BB%BF%F0%A3%8E%B4"
                                    ||
                                    "/foo/bar"
                                   );
p($iri);
my $abs = MarpaX::RFC::RFC3987->new('http://a/b/c/d;p?q');
MarpaX::RFC::RFC3987->new_abs('g:h', $abs);
MarpaX::RFC::RFC3987->new_abs('g', $abs);
MarpaX::RFC::RFC3987->new_abs('../../g', $abs);
print "===> $iri as uri: " . $iri->as_uri . "\n";
print Dumper($iri);
exit;
exit;
# p(MarpaX::RFC::RFC3987->new("http://test?voila1...\&voila2\#f"));
print $iri->_iri . "\n";
print $iri->_iri(1) . "\n";
print $iri->scheme . "\n";
print $iri->scheme('abcd') . "\n";
print $iri->scheme . "\n";
print "Stringified: $iri\n";
print $iri == $iri ? "eq test ok\n" : "eq test ko\n";
my $new1 = MarpaX::RFC::RFC3987->new("http://example.org/~user");
my $new2 = MarpaX::RFC::RFC3987->new("http://example.org/%7Euser");
$new1->scheme('abcd');
$new2->scheme('aBCd');
print $new1 == $new2 ? "'$new1' eq '$new2' test ok\n" : "'$new1' eq '$new2' test ko\n";

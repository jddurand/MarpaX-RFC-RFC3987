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

my $iri = MarpaX::RFC::RFC3987->new(shift
                                    ||
                                    { octets => "HTTp://www.exAMPLe.org:80/re+AwE-sume+AwE-/+ACU-7Euser/a/./b/../b/+ACU-63/+ACU-7bfoo+ACU-7d/ros+ACU-C3+ACU-A9/end", encoding => 'UTF-7',
                                      is_reg_name_convert_to_IRI => 'X', is_reg_name_as_domain_name => 1, is_character_normalized => 0, default_port => 80 }
                                    ||
                                    { input => "HTTp://re\x{301}sume\x{301}.example.org/%7euser", is_character_normalized => 1, is_reg_name_convert_to_IRI => 'X', is_reg_name_as_domain_name => 1 }
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
exit;
my $abs = MarpaX::RFC::RFC3987->new('http://a/b/c/d;p?q');
exit;
MarpaX::RFC::RFC3987->new_abs('g:h', $abs);
MarpaX::RFC::RFC3987->new_abs('g', $abs);
MarpaX::RFC::RFC3987->new_abs('../../g', $abs);
print Dumper($iri->as_uri);
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

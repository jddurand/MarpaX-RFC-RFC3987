#!env perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Data::Printer;
use Encode;
use MarpaX::RFC::RFC3987;
use MarpaX::RFC::RFC3987::_common;
use MarpaX::RFC::RFC3987::_generic;
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Log4perl qw/:easy/;
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

# ----
# Init
# ----
my $defaultLog4perlConf = <<DEFAULT_LOG4PERL_CONF;
log4perl.rootLogger              = DEBUG, Screen
log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr  = 0
log4perl.appender.Screen.layout  = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
DEFAULT_LOG4PERL_CONF
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');

my $iri = MarpaX::RFC::RFC3987->new(shift
                                    ||
                                    { octets => "http://www.example.org/resume.html", encoding => 'euc-jp', character_normalization_strategy => 'NFKC', is_character_normalized => 0, decode_strategy => Encode::FB_DEFAULT }
                                    ||
                                    "HTTp://eXAMPLe.com?\x{5135}voila1...\&voila2\#~%eF%BF%Bdf"
                                    ||
                                    "http://www.example.org/re\x{301}sume\x{301}.html"
                                    ||
                                    "http://\x{7D0D}\x{8C46}.example.org/%41%E2%89%A2%CE%91%2E%ED%95%9C%EA%B5%AD%EC%96%B4-%E6%97%A5%E6%9C%AC%E8%AA%9E-%EF%BB%BF%F0%A3%8E%B4"
                                    ||
                                    "/foo/bar"
                                   );
print Dumper($iri);
use Data::Dumper;
print Dumper($iri->as_uri);
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

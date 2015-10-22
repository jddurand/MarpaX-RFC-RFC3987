#!env perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Data::Printer;
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
                                    "http://test?\x{5135}voila1...\&voila2\#%EF%BF%BDf"
                                    ||
                                    "/foo/bar"
                                    ||
                                    "http://\x{7D0D}\x{8C46}.example.org/%41%E2%89%A2%CE%91%2E%ED%95%9C%EA%B5%AD%EC%96%B4-%E6%97%A5%E6%9C%AC%E8%AA%9E-%EF%BB%BF%F0%A3%8E%B4"
                                    ||
                                    "http://r&#xE9;sum&#xE9;.example.org"
                                   );
use Data::Dumper;
print Dumper($iri);
# p(MarpaX::RFC::RFC3987->new("http://test?voila1...\&voila2\#f"));
print $iri->_iri . "\n";
print $iri->_iri(1) . "\n";

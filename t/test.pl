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

my $iri = MarpaX::RFC::RFC3987->new(shift ||
                                    "http://\x{7D0D}\x{8C46}.example.org/%E2%80%AE" ||
                                    "http://r&#xE9;sum&#xE9;.example.org" ||
                                    "&&http://test?\x{5135}voila1...\&voila2\#f");
print $iri->as_uri . "\n";
 p($iri);
# p(MarpaX::RFC::RFC3987->new("http://test?voila1...\&voila2\#f"));
print $iri->escape($iri->opaque) . "\n";

#!env perl
use strict;
use warnings FATAL => 'all';
use Data::Printer {class => {expand => 'all'}};
use MarpaX::RFC::RFC3987;
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Log4perl qw/:easy/;

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

print STDERR MarpaX::RFC::RFC3987->new("http://test?voila1...\&voila2\#f")->has_recognized_scheme . "\n";;
print STDERR MarpaX::RFC::RFC3987->new("_http://test?voila1...\&voila2\#f")->has_recognized_scheme . "\n";;

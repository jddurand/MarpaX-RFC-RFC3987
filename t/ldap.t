#!perl
use strict;
use warnings FATAL => 'all';
use Scalar::Util qw/blessed/;
use Test::More;
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Log4perl qw/:easy/;

my $defaultLog4perlConf = <<DEFAULT_LOG4PERL_CONF;
log4perl.rootLogger              = TRACE, Screen
log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.layout  = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
DEFAULT_LOG4PERL_CONF
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');

binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

BEGIN {
  use_ok('MarpaX::RFC::RFC3987') || print "Bail out!\n";
}

my $ldap = MarpaX::RFC::RFC3987->new("ldap://host:123/dn=base?cn,sn?sub?(objectClass=*)?!this=that,that=those");
is(      $ldap->host,                              'host', "host is 'host'");
is       ($ldap->port,                                123, "port is 123");
is       ($ldap->dn,                            'dn=base', "dn is 'dn=base'");
is       ($ldap->attribute,                       'cn,sn', "attribute is 'cn,sn'");
is_deeply($ldap->attributes,                 ['cn', 'sn'], "attributes is ['cn', 'sn']");
is       ($ldap->scope,                             'sub', "scope is 'sub'");
is       ($ldap->filter,                '(objectClass=*)', "filter is '(objectClass=*)'");
is       ($ldap->extension,       '!this=that,that=those', "extension is '!this=that,that=those'");
is_deeply($ldap->extensions, ['!this=that', 'that=those'], "extensions is ['!this=that', 'that=those']");

done_testing();

1;

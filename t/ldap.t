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

check(MarpaX::RFC::RFC3987->new("ldap://host:123/dn=base?cn,sn?sub?(objectClass=*)?!this=that,that=those"),
       'host',                      # host
       123,                         # port
       'dn=base',                   # dn
       'cn,sn',                     # attribute
       ['cn', 'sn'],                # attributes
       'sub',                       # scope
       '(objectClass=*)',           # filter
       '!this=that,that=those',     # extension
       ['!this=that', 'that=those'] # extensions
    );
#
# From Ruby MRI/test/uri/test_ldap.rb
#
check(MarpaX::RFC::RFC3987->new('ldap://ldap.jaist.ac.jp/o=JAIST,c=JP?sn?base?(sn=ttate*)'),
       'ldap.jaist.ac.jp',          # host
       undef,                       # port
       'o=JAIST,c=JP',              # dn
       'sn',                        # attribute
       ['sn'],                      # attributes
       'base',                      # scope
       '(sn=ttate*)',               # filter
       undef,                       # extension
       []                           # extensions
    );
#
# In our case, this is always the unescaped version that is returned -;
#
check(MarpaX::RFC::RFC3987->new('ldap:///o=University%20of%20Michigan,c=US'),
       undef,                       # host
       undef,                       # port
       'o=University of Michigan,c=US', # dn
       undef,                       # attribute
       [],                          # attributes
       undef,                       # scope
       undef,                       # filter
       undef,                       # extension
       []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US'),
       'ldap.itd.umich.edu',        # host
       undef,                       # port
       'o=University of Michigan,c=US', # dn
       undef,                       # attribute
       [],                          # attributes
       undef,                       # scope
       undef,                       # filter
       undef,                       # extension
       []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US?postalAddress'),
       'ldap.itd.umich.edu',        # host
       undef,                       # port
       'o=University of Michigan,c=US', # dn
       'postalAddress',             # attribute
       ['postalAddress'],           # attributes
       undef,                       # scope
       undef,                       # filter
       undef,                       # extension
       []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap://host.com:6666/o=University%20of%20Michigan,c=US??sub?(cn=Babs%20Jensen)'),
       'host.com',                  # host
       6666,                        # port
       'o=University of Michigan,c=US', # dn
       undef,                       # attribute
       [],                          # attributes
       'sub',                       # scope
       '(cn=Babs Jensen)',          # filter
       undef,                       # extension
       []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap://ldap.itd.umich.edu/c=GB?objectClass?one'),
       'ldap.itd.umich.edu',        # host
       undef,                       # port
       'c=GB',                      # dn
       'objectClass',               # attribute
       ['objectClass'],             # attributes
       'one',                       # scope
       undef,                       # filter
       undef,                       # extension
       []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap://ldap.question.com/o=Question%3f,c=US?mail'),
       'ldap.question.com',         # host
       undef,                       # port
       'o=Question?,c=US',          # dn
       'mail',                      # attribute
       ['mail'],                    # attributes
       undef,                       # scope
       undef,                       # filter
       undef,                       # extension
       []                           # extensions
    );
#
# I do not understand the Ruby example... for me there is a missing '?'
# C.f. the output of ldapurl -h 'ldap.itd.umich.edu' -b 'o=Babsco,c=US' -f '(int=\00\00\00\04)'
#
check(MarpaX::RFC::RFC3987->new('ldap://ldap.netscape.com/o=Babsco,c=US???(int=%5c00%5c00%5c00%5c04)'),
      'ldap.netscape.com',         # host
      undef,                       # port
      'o=Babsco,c=US',             # dn
      undef,                       # attribute
      [],                          # attributes
      undef,                       # scope
      '(int=\\00\\00\\00\\04)',    # filter
      undef,                       # extension
      []                           # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap:///??sub??bindname=cn=Manager%2co=Foo'),
      undef,                       # host
      undef,                       # port
      '',                          # dn
      undef,                       # attribute
      [],                          # attributes
      'sub',                       # scope
      undef,                       # filter
      'bindname=cn=Manager,o=Foo', # extension
      ['bindname=cn=Manager', 'o=Foo'] # extensions
    );
check(MarpaX::RFC::RFC3987->new('ldap:///??sub??!bindname=cn=Manager%2co=Foo'),
      undef,                       # host
      undef,                       # port
      '',                          # dn
      undef,                       # attribute
      [],                          # attributes
      'sub',                       # scope
      undef,                       # filter
      '!bindname=cn=Manager,o=Foo', # extension
      ['!bindname=cn=Manager', 'o=Foo'] # extensions
    );

done_testing();

sub check {
    my ($ldap, $host, $port, $dn, $attribute, $attributes, $scope, $filter, $extension, $extensions) = @_;

    is       ($ldap->_host,                             $host, "host is " . ($host // 'undef'));
    is       ($ldap->_port,                             $port, "port is " . ($port // 'undef'));
    is       ($ldap->_dn,                                 $dn, "dn is " . ($dn // 'undef'));
    is       ($ldap->_attribute,                   $attribute, "attribute is " . ($attribute // 'undef'));
    is_deeply($ldap->_attributes,                 $attributes, "attributes is [" . join(', ', @{$attributes}) . "]");
    is       ($ldap->_scope,                           $scope, "scope is " . ($scope // 'undef'));
    is       ($ldap->_filter,                         $filter, "filter is " . ($filter // 'undef'));
    is       ($ldap->_extension,                   $extension, "extension is " . ($extension // 'undef'));
    is_deeply($ldap->_extensions,                 $extensions, "extensions is [" . join(', ', @{$extensions}) . "]");
}

1;

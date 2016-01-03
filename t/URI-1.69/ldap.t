use strict;
use warnings;

print "1..24\n";
use Log::Any qw/$log/;
use Log::Any::Adapter;
use Log::Log4perl qw/:easy/;

use MarpaX::RFC::RFC3987;
local $MarpaX::RI::URI_COMPAT = 1;
my $defaultLog4perlConf = <<DEFAULT_LOG4PERL_CONF;
log4perl.rootLogger              = DEBUG, Screen
log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.layout  = PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = %d %-5p %6P %m{chomp}%n
DEFAULT_LOG4PERL_CONF
Log::Log4perl::init(\$defaultLog4perlConf);
Log::Any::Adapter->set('Log4perl');

my $uri;

local $MarpaX::RI::MARPA_TRACE_TERMINALS = 99;
#
# Original ldap.t says: "ldap://host/dn=base?cn,sn?sub?objectClass=*") and
# assumes objectClass=* is the filter.
# I disagree. First this is not a valid LDAP address, and filter must be enclosed in ()
# All in all, URI::ldap generated a confusion with readers and writers:
# readers return only one part, while writers are overwriting what is after
#
$uri = MarpaX::RFC::RFC3987->new("ldap://host/dn=base?cn,sn?sub?(objectClass=*)");

print "not " unless $uri->host eq "host";
print "ok 1\n";

print "not " unless $uri->dn eq "dn=base";
print "ok 2\n";

print "not " unless join("-",$uri->attributes) eq "cn-sn";
print "ok 3\n";

print "not " unless $uri->scope eq "sub";
print "ok 4\n";

print "not " unless $uri->filter eq "objectClass=*";
print "ok 5\n";

$uri = MarpaX::RFC::RFC3987->new("ldap:");
$uri->dn("o=University of Michigan,c=US");

#
# Original ldap.t expects ldap:o=University%20of%20Michigan,c=US"
# I disagree this should be ldap:///o=University%20of%20Michigan,c=US"

print "not " unless "$uri" eq "ldap:///o=University%20of%20Michigan,c=US" &&
    $uri->dn eq "o=University of Michigan,c=US";
print "ok 6\n";

$uri->host("ldap.itd.umich.edu");
print "not " unless $uri->as_string eq "ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US";
print "ok 7\n";

#
# Again I disagree for _scope and _filter: they have no defaults and here clearly they are undef
#
# check defaults
print "not " unless # $uri->_scope  eq "" &&
                    $uri->scope   eq "base" &&
                    # $uri->_filter eq "" &&
                    $uri->filter  eq "(objectClass=*)";
print "ok 8\n";

# attribute
$uri->attributes("postalAddress");
print "not " unless $uri eq "ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US?postalAddress";
print "ok 9\n";

# does attribute escapeing work as it should
# Formally, ",", "?", "# and "\0" cannot be part of attributes
# $uri->attributes($uri->attributes, "foo", ",", "*", "?", "#", "\0");
$uri->attributes($uri->attributes, "foo", "*");

print "not " unless $uri->attributes eq "postalAddress,foo,*" &&
                    join("-", $uri->attributes) eq "postalAddress-foo-*";
print "ok 10\n";
$uri->attributes("");
#
# Once again, setting scope to "sub?#" is non-sense
#
# $uri->scope("sub?#");
$uri->scope("sub");
print "not " unless $uri->query eq "?sub" &&
                    $uri->scope eq "sub";
print "ok 11\n";
$uri->scope("");

$uri->filter("(f=?,#)");
print "not " unless $uri->query eq "??f=%3F,%23" &&
                    $uri->filter eq "f=?,#";
print "... query=" . $uri->query . "\n";
print "... filter=" . $uri->filter . "\n";
use Data::Dumper;
print STDERR Dumper($uri);
exit;
$uri->filter("(int=\\00\\00\\00\\04)");
print "not " unless $uri->query eq "??(int=%5C00%5C00%5C00%5C04)";
print "... query=" . $uri->query . "\n";
print "ok 12\n";


print "ok 13\n";
$uri->filter("");

$uri->extensions("!bindname" => "cn=Manager,co=Foo");
my %ext = $uri->extensions;

print "not " unless $uri->query eq "???!bindname=cn=Manager%2Cco=Foo" &&
                    keys %ext == 1 &&
                    $ext{"!bindname"} eq "cn=Manager,co=Foo";
print "ok 14\n";

$uri = MarpaX::RFC::RFC3987->new("ldap://LDAP-HOST:389/o=University%20of%20Michigan,c=US?postalAddress?base?ObjectClass=*?FOO=Bar,bindname=CN%3DManager%CO%3dFoo");

print "not " unless $uri->canonical eq "ldap://ldap-host/o=University%20of%20Michigan,c=US?postaladdress???foo=Bar,bindname=CN=Manager%CO=Foo";
print "ok 15\n";

print "$uri\n";
print $uri->canonical, "\n";

print "not " if $uri->secure;
print "ok 16\n";

$uri = MarpaX::RFC::RFC3987->new("ldaps://host/dn=base?cn,sn?sub?objectClass=*");

print "not " unless $uri->host eq "host";
print "ok 17\n";
print "not " unless $uri->port eq 636;
print "ok 18\n";
print "not " unless $uri->dn eq "dn=base";
print "ok 19\n";
print "not " unless $uri->secure;
print "ok 20\n";

$uri = MarpaX::RFC::RFC3987->new("ldapi://%2Ftmp%2Fldap.sock/????x-mod=-w--w----");
print "not " unless $uri->authority eq "%2Ftmp%2Fldap.sock";
print "ok 21\n";
print "not " unless $uri->un_path eq "/tmp/ldap.sock";
print "ok 22\n";

$uri->un_path("/var/x\@foo:bar/");
print "not " unless $uri eq "ldapi://%2Fvar%2Fx%40foo%3Abar%2F/????x-mod=-w--w----";
print "ok 23\n";

%ext = $uri->extensions;
print "not " unless $ext{"x-mod"} eq "-w--w----";
print "ok 24\n";


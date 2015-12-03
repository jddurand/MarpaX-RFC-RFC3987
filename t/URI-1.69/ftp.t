use strict;
use warnings;

#print "1..13\n";
print "1..9\n";

use MarpaX::RFC::RFC3987;
local $MarpaX::RI::URI_COMPAT = 1;
my $uri;

$uri = MarpaX::RFC::RFC3987->new("ftp://ftp.example.com/path");

print "not " unless $uri->scheme eq "ftp";
print "ok 1\n";

print "not " unless $uri->host eq "ftp.example.com";
print "ok 2\n";

print "not " unless $uri->port eq 21;
print "ok 3\n";

print "not " unless $uri->user eq "anonymous";
print "ok 4\n";

print "not " unless $uri->password eq 'anonymous@';
print "ok 5\n";

$uri->userinfo("gisle\@aas.no");

print "not " unless $uri eq "ftp://gisle%40aas.no\@ftp.example.com/path";
print "ok 6\n";

print "not " unless $uri->user eq "gisle\@aas.no";
print "ok 7\n";

print "not " if defined($uri->password);
print "ok 8\n";

$uri->password("secret");

print "not " unless $uri eq "ftp://gisle%40aas.no:secret\@ftp.example.com/path";
print "ok 9\n";

#
# I disagree with that, this is not a valid ftp URL
#
#$uri = MarpaX::RFC::RFC3987->new("ftp://gisle\@aas.no:secret\@ftp.example.com/path");
#print "not " unless $uri eq "ftp://gisle%40aas.no:secret\@ftp.example.com/path";
#print "ok 10\n";

#print "not " unless $uri->userinfo eq "gisle\@aas.no:secret";
#print "ok 11 " . $uri->userinfo . "\n";

#print "not " unless $uri->user eq "gisle\@aas.no";
#print "ok 12\n";

#print "not " unless $uri->password eq "secret";
#print "ok 13\n";

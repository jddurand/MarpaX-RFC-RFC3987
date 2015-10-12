use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI)

# VERSION

# AUTHORITY

use Carp qw/croak/;
use Class::Load qw/try_load_class/;
use Encode qw/decode/;
use Encode::Locale;
use MarpaX::RFC::RFC3987::_common;
use MarpaX::RFC::RFC3987::_generic;
use Scalar::Util qw/reftype/;
use Try::Tiny;

#
# Writen like this because I want to control the class
#
sub new {
  my $class = shift;
  my $input = ($#_ <= 0) ? (shift || '') : decode(shift, shift, @_);
  #
  # Try to load the good first class immediately
  #
  my $new;
  if ($input =~ /^[A-Za-z][A-Za-z0-9+.-]*(?=:)/p) {
    #
    # The specific ?
    #
    my $class = sprintf('%s::%s', __PACKAGE__, ${^MATCH});
    try { $new = $class->new($input) };
  }
  if (! $new) {
    #
    # The generic ?
    #
    my $class = sprintf('%s::%s', __PACKAGE__, '_generic');
    try { $new = $class->new($input) };
  }
  if (! $new) {
    #
    # At least common must match
    #
    my $class = sprintf('%s::%s', __PACKAGE__, '_common');
    $new = $class->new($input);
  }

  $new;
}

1;

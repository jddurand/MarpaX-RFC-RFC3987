use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI)

# VERSION

# AUTHORITY

use Carp qw/croak/;
use Class::Load qw/load_class/;
use Encode qw/decode/;
use MarpaX::RFC::RFC3987::_common;
use MarpaX::RFC::RFC3987::_generic;
use Scalar::Does;
use Try::Tiny;
use Types::Standard -all;
use Types::Encodings qw/Bytes/;

#
# Writen like this because we want to control the class
#
my $has_recognized_scheme = 0;

sub new {
  my $class = shift;

  my $input = '';

  if (@_) {
    $input = shift;
    #
    # More than one argument is supported only in the top package
    #
    croak 'Only one argument is supported' if (($#_ != 0) && ($class ne __PACKAGE__));
    #
    # ArrayRef as first argument is supported only in the top package
    #
    if (($class eq __PACKAGE__) && ArrayRef->check($input)) {
      croak 'Referenced array must have a least two elements'   if ($#{$input} < 1);

      my $encoding = shift(@{$input});
      croak 'Referenced array must have a string in first element' if (! Str->check($encoding));

      my $bytes = shift(@{$input});
      croak 'Referenced array must have bytes in second element' if (! Bytes->check($bytes));

      $input = decode($encoding, $bytes, @{$input});
    } else {
      $input = "$input"; # Stringification in any case
    }
  }

  my $new;
  if ($class eq __PACKAGE__) {
    #
    # Copy from URI:
    # Get rid of potential wrapping
    #
    $input =~ s/^<(?:URL:)?(.*)>$/$1/;
    $input =~ s/^"(.*)"$/$1/;
    $input =~ s/^\s+//;
    $input =~ s/\s+$//;
    #
    # Specific, else generic, else common
    #
    if ($input =~ /^[A-Za-z][A-Za-z0-9+.-]*(?=:)/p) {
      my $class = sprintf('%s::%s', __PACKAGE__, ${^MATCH});
      try {
        load_class($class);
        $new = $class->new($input);
        $has_recognized_scheme = 1;
      };
    }
    try { $new = MarpaX::RFC::RFC3987::_generic->new($input) } if (! $new);
    $new = MarpaX::RFC::RFC3987::_common->new($input) if (! $new);
    #
    # scheme argument
    #
    if (@_) {
      my $scheme = shift;
      if (! $new->can('is_relative')) {
        warn 'scheme argument ignored: implementation cannot tell if input is relative';
      } else {
        if ($new->is_relative) {
        }
      }
    }
  } else {
    my $new_method = join('::', $class, 'new');
    goto &$new_method;
  }

  $new
}

sub has_recognized_scheme { $has_recognized_scheme };

1;

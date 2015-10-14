use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987;

# ABSTRACT: Internationalized Resource Identifier (IRI)

# VERSION

# AUTHORITY

use Moo;
BEGIN {
  extends 'MarpaX::RFC::RFC3987::_top';
}
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role'
  => {
      package => __PACKAGE__
     };

1;

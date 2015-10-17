use strict;
use warnings FATAL => 'all';

package MarpaX::RFC::RFC3987::_generic;

# ABSTRACT: Internationalized Resource Identifier (IRI): Generic syntax implementation

# VERSION

# AUTHORITY

use Moo;
BEGIN {
  extends 'MarpaX::RFC::RFC3987::_common'; # So that _trigger_input is found in inheritance hierarchy
}
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier::Role::_generic'
  => {

      package     => __PACKAGE__,
      BNF_package => 'MarpaX::RFC::RFC3987::_generic::BNF',
      G1 => {
             '<IRI>'            => sub { $_[0]->iri               ($_[1])        },
             '<scheme>'         => sub { $_[0]->scheme            ($_[1])        },
             '<ihier_part>'     => sub { $_[0]->hier_part         ($_[1])        },
             '<iquery>'         => sub { $_[0]->query             ($_[1])        },
             '<ifragment>'      => sub { $_[0]->ifragment         ($_[1])        },
             '<isegments>'      => sub { $_[0]->isegment          ($_[1])        },
             '<iauthority>'     => sub { $_[0]->authority         ($_[1])        },
             '<ipath>'          => sub { $_[0]->path              ($_[1])        },
             '<ipath abempty>'  => sub { $_[0]->path_abempty      ($_[1])        },
             '<ipath absolute>' => sub { $_[0]->path_absolute     ($_[1])        },
             '<ipath noscheme>' => sub { $_[0]->path_noscheme     ($_[1])        },
             '<ipath rootless>' => sub { $_[0]->path_rootless     ($_[1])        },
             '<ipath empty>'    => sub { $_[0]->path_empty        ($_[1])        },
             '<irelative_ref>'  => sub { $_[0]->relative_ref      ($_[1])        },
             '<irelative_part>' => sub { $_[0]->relative_part     ($_[1])        },
             '<iuserinfo>'      => sub { $_[0]->userinfo          ($_[1])        },
             '<ihost>'          => sub { $_[0]->host              ($_[1])        },
             '<iport>'          => sub { $_[0]->port              ($_[1])        },
             '<IP literal>'     => sub { $_[0]->ip_literal        ($_[1])        },
             '<IPv6address>'    => sub { $_[0]->ipv6_address      ($_[1])        },
             '<IPv6addrz>'      => sub { $_[0]->ipv6_addrz        ($_[1])        },
             '<IPvFuture>'      => sub { $_[0]->ipvfuture         ($_[1])        },
             '<ZoneID>'         => sub { $_[0]->zoneid            ($_[1])        },
             '<isegment unit>'  => sub { push(@{$_[0]->segments},  $_[1]); $_[1] },
             '<ifragment unit>' => sub { push(@{$_[0]->fragments}, $_[1]); $_[1] },
            }
     };

1;

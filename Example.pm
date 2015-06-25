package Example;

use warnings;
use strict;

# You can test this module from the command line:
# > perl -MTest::Doctest -e run Example.pm

=head1 Example

This is only an example.

  $ 1 + 1
  2

  $ $a = 10
  10

  $ $a *= 2
  20

=head2 foo

It just returns 5.

  $ foo()
  5

=cut
sub foo {
  return 5;
}

1;

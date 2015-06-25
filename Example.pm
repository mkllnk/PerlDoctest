package Test::Example;

use strict;
use warnings;

# You can test this module from the command line:
# > perl -MTest::Doctest -e run Example.pm

=head1 Example

This is only an example.

  $ 1 + 1
  2

Variables that are localized inside one pod block with same name...

  $ my $foo = 10
  10

...are local to the end of block.

  $ $foo *= 2
  20

=head2 foo

Tests are runned in the package namespace, so you can call subs without package name.

  $ foo()
  5

=cut
sub foo {
  return 5;
}

1;

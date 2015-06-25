package Some::Namespace::Example;

use strict;
use warnings;

# You can test this module from the command line:
# > perl -MTest::Doctest -e run Example.pm

=head1 Example

=head2 This is only an example.

  $ 1 + 1
  2

=head2 Checked values are perl expressons.

  $ 'foo'
  'foo'

  $ undef
  undef

=head2 Variables that are localized inside pod block...

  $ my $foo = 10
  10

...are local to the end of the block and consequent blocks with the same name.

  $ $foo *= 2
  20

=head2 Tests are being run in the package namespace, so you can easily call subs.

  $ foo()
  5

=cut
sub foo {
  return 5;
}

1;
package Example;

# You can test this module from the command line:
# > perl -MTest::Doctest -MExample -e 'runtests @ARGV' Example.pm

=head1 Example

This is only an example.

  $ 1 + 1
  2

=head2 foo

It just returns 5.

  $ Example->foo()
  5

=cut
sub foo {
  return 5;
}

1;

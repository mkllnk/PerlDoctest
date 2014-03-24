Doctests for Perl
=================

Doctest verifies your documentation and your code at the same time.
By executing usage examples in your documenation it validates that your documentation is up-to-date and that your code is behaving like documented.

The principle comes from the python community. Python's doctest executes examples in so called docstrings. In perl the usage examples are found in pod.
Your code comment could look like this:

```perl
=head1 Example

  $ 1 + 1
  2

=cut
```

Doctest will execute `1 + 1` and compare the result with `2`. There are three ways to run it.

  # Command line: you have to specify the module to test, here Example.
  perl -MTest::Doctest -MExample -e 'runtests @ARGV' Example.pm

Or in your custom script.

```perl
  use Test::Doctest;
  runtests($filepath);
```
or
```perl
  # or
  use Test::Doctest;
  my $p = Test::Doctest->new;
  $p->parse_from_filehandle(\*STDIN);
  $p->test;
```

This module was written by Bryan Cardillo and published under the same terms as Perl itself.

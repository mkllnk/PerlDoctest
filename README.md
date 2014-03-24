Doctests for Perl
=================

Doctest verifies your documentation and your code at the same time.
By executing usage examples in your documenation it validates that your documentation is up-to-date and that your code is behaving like documented.

The principle comes from the python community. Python's doctest executes examples in so called docstrings. In perl the usage examples are found in pod.
Your code comment could look like this:

```perl
=head1 Addition in Perl is simple

  $ 2 + 3
  5

=cut
```

Doctest will execute `2 + 3` and compare the result to `5`.


Running
-------

There are three ways to run it. The first is directly from the command line. But you have to specify the module to test, in this example the module ist named 'Example'.

    perl -MTest::Doctest -MExample -e 'runtests @ARGV' Example.pm

Or you can write your custom test script.

```perl
  use Test::Doctest;
  runtests($filepath);
```
You can also specify a file handle.
```perl
  # or
  use Test::Doctest;
  my $p = Test::Doctest->new;
  $p->parse_from_filehandle(\*STDIN);
  $p->test;
```

This module was written by Bryan Cardillo and published under the same terms as Perl itself.

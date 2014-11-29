#!/usr/bin/env perl

use 5.005;
use strict;

use Test::More;

# This file verifies some of the test examples

use Test::Doctest;

TODO: {
  todo_skip 'program exits before returning', 1;
  is(runtests, 0, 'running zero tests');
}

{
  my $t = Test::Doctest->new();
  is(@{$t->{tests}}, 0);
}

done_testing

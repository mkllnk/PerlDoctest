#!/usr/bin/env perl

use 5.005;
use strict;

use Test::Doctest;

runtests qw(
  lib/Test/Doctest.pm
  lib/Example.pm
);

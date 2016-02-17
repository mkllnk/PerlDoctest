#!/usr/bin/env perl

use 5.005;
use strict;
use warnings;
use Data::Dumper 'Dumper';

use Test::Doctest;


runtests qw(
	Test/Doctest.pm
	Test/Doctest/Example.pm
);

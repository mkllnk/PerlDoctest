package Test::Doctest;
 
use 5.005;
use strict;
 
require Exporter;
require Pod::Parser;
use vars qw(@ISA @EXPORT $VERSION);
@ISA = qw(Exporter Pod::Parser);
@EXPORT = qw(run runtests);
$VERSION = '0.01';
 
use Carp;
use Test::Builder;
use File::Spec::Functions qw(devnull);
 
=head1 NAME
 
Test::Doctest - extract and evaluate tests from pod fragments
 
=head1 SYNOPSIS
 
  perl -MTest::Doctest -e run lib/Some/Module.pm
 
  - or -
 
  use Test::Doctest;
  runtests($filepath);
 
  - or -
 
  use Test::Doctest;
  my $p = Test::Doctest->new;
  $p->parse_from_filehandle(\*STDIN);
  $p->test;
 
=head1 DESCRIPTION
 
B<runtests> uses B<Pod::Parser> to extract pod text from the files
specified, evaluates each line begining with a prompt ($ by default),
and finally compares the results with the expected output using
B<is_eq> from B<Test::Builder>.
 
=head1 EXAMPLES
 
  $ 1 + 1
  2
 
  $ my @a = qw(2 3 4)
  3
 
  $ use Pod::Parser;
  $ my $p = Pod::Parser->new;
  $ ref $p;
  'Pod::Parser'

  $ $a = 10
  10

  $ $a *= 2
  20
 
=head1 EXPORTS
 
=head2 B<runtests()>
 
Extract and run tests from pod for each file argument.
 
=begin runtests
 
  $ use Test::Doctest
  $ runtests
  0
 
=end
 
=cut

sub runtests {
  my ($total, $success, @tests) = (0, 0);
  my $test = Test::Builder->new;
 
  for (@_) {
    my $t = Test::Doctest->new;
    $t->parse_from_file($_);
    $total += @{$t->{tests}};
    push @tests, $t;
  }
 
  if (!$test->has_plan) {
    $test->plan(tests => $total);
  }
 
  for (@tests) {
    $success += $_->test == @{$_->{tests}}
  }
 
  return $success;
}


sub run { runtests @ARGV }


sub parse_from_file {
  my $self = shift;
  my $module = shift;
  require $module;
  open my $fh, '<', $module or die "Can't open $module: $!";
  while (<$fh>) {
    if (/package\s+([\w:]+)/) {
      $self->{module} = $1;
      last;
    }
  }
  close $fh;
  return $self->SUPER::parse_from_file($module, devnull);
}
 
=head1 METHODS
 
=head2 B<initialize()>
 
Initialize this B<Test::Doctest> pod parser. This method is
not typically called directly, but rather, is called by
B<Pod::Parser::new> when creating a new parser.
 
=begin initialize
 
  $ my $t = Test::Doctest->new
  $ @{$t->{tests}}
  0
 
=end
 
=begin custom prompt
 
  $ my $t = Test::Doctest->new(prompt => 'abc')
  $ $t->{prompt}
  'abc'
 
=end
 
=cut
 
sub initialize {
  my ($self) = @_;
  $self->SUPER::initialize;
  $self->{tests} = [];
}
 
=head2 B<command()>
 
Override B<Pod::Parser::command> to save the name of the
current section which is used to name the tests.
 
=begin command
 
  $ my $t = Test::Doctest->new
  $ $t->command('head1', "EXAMPLES\nthese are examples", 1)
  $ $t->{name}
  'EXAMPLES'
 
=end
 
=cut
 
sub command {
  my ($self, $cmd, $par, $line) = @_;
  $self->{name} = (split /(?:\r|\n|\r\n)/, $par, 2)[0];
}
 
=head2 B<textblock()>
 
Override B<Pod::Parser::textblock> to ignore normal blocks of pod text.
 
=begin textblock
 
  $ my $t = Test::Doctest->new
  $ not defined $t->textblock
  1
 
=end
 
=cut
 
sub textblock { }
 
=head2 B<verbatim()>
 
Override B<Pod::Parser::verbatim> to search verbatim paragraphs for
doctest code blocks.  Each block found, along with information about
its location in the file and its expected output is appended to the
list of tests to be executed.
 
=begin verbatim
 
  $ my $t = Test::Doctest->new
  $ $t->verbatim("  \$ 1+1\n  2", 1)
  1
 
=end
 
=begin verbatim no prompt
 
  $ my $t = Test::Doctest->new
  $ $t->verbatim("abc", 1)
  0
 
=end
 
=begin verbatim custom prompt
 
  $ my $t = Test::Doctest->new(prompt => '#\s+')
  $ $t->verbatim("  # 1+1\n  2", 1)
  1
 
=end
 
=cut
 
sub verbatim {
  my ($self, $par, $line) = @_;
  my $prompt = $self->{prompt} ? $self->{prompt} : '\$\s+';
  my $name = $self->{name} ? $self->{name} : q{};
  my @lines = split /(?:\r|\n|\r\n)/, $par;
  my @code;

  for (@lines) {
    if (/^\s+$prompt(.+)/) {
      # capture code
      push @code, $1;
    } elsif (/^\s+(.+)/ and @code) {
      # on first non-code line, with valid code accumlated
      my $file = $self->input_file ? $self->input_file : 'stdin';
      push @{$self->{tests}}, [$name, $file, $line, eval($1), @code];
      @code = ();
    } elsif (/^=cut/) {
      # stop processing on =cut (even without a leading blank line)
      last;
    }
  }
 
  return @{$self->{tests}};
}

=head2 B<test()>
 
Evaluates each test discovered via parsing and compares the results
with the expected output using B<Test::Builder::is_eq>.
 
=begin test
 
  $ my $t = Test::Doctest->new
  $ $t->test
  0
 
  $ $t->command('begin', 'test', 1)
  $ $t->verbatim("  \$ 1+1\n  2", 2)
  $ @{$t->{tests}}
  1
 
=end
 
=cut


our @group_result;


sub test {
  my ($self) = @_;
  my $tests = $self->{tests};

  my $test = Test::Builder->new;
  $test->plan(tests => scalar @$tests) unless $test->has_plan;

  my (@grouped, $current_group);
  foreach (@$tests) {
    if (!defined($current_group) || $_->[0] ne $current_group->[0][0]) {
      push(@grouped, $current_group = []);
    }
    push(@$current_group, $_);
  }

  my $run = 0;
  foreach my $group (@grouped) {
    my @group_code;
    unshift(@group_code, "package $self->{module}") if $self->{module};
    my @group_expect;
    my $subtest = 0;
    foreach (@$group) {
      my ($name, $file, $line, $expect, @code) = @$_;
      push(@group_expect, [$name, $file, $line, $expect]);
      my $result_line = pop(@code);
      push(@group_code, @code);
      push(@group_code, "\$Test::Doctest::group_result[$subtest] = $result_line");
      $subtest++;
    }

    eval join(";", @group_code);
    croak $@ if $@;

    for (my $i = 0; $i < @group_expect; $i++) {
      my ($name, $file, $line, $expect) = @{$group_expect[$i]};
      my $outof = @group_expect > 1 ? sprintf("%d/%d", $i + 1, scalar @group_expect) : q();
      $test->is_eq($group_result[$i], $expect, "$name $outof ($file, $line)");
    }

    $run += $subtest;
  }

  return $run;
}
 
1;
 
__END__
 
=head1 HISTORY
 
=over 8
 
=item 0.01
 
Original version
 
=back
 
=head1 SEE ALSO
 
L<Pod::Parser>, L<Test::Builder>
 
B<Pod::Parser> defines the parser interface used to extract the tests.
 
B<Test::Builder> is used to plan the tests and determine the results.
 
=head1 AUTHOR
 
Bryan Cardillo E<lt>dillo@cpan.org<gt>
 
=head1 COPYRIGHT AND LICENSE
 
Copyright (C) 2009 by Bryan Cardillo
 
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
 
=cut

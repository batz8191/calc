#!/usr/bin/perl
use strict;
use warnings;
use Calc;
use Calc::Data;
use Parse::RecDescent;
use Term::ReadLine;

my $quiet = 0;
if(@ARGV && $ARGV[0] =~ m/^-q/)
{
	$quiet = 1;
	my $a = shift(@ARGV);
	if($a =~ m/j/)
	{
		@ARGV = (join(' ', @ARGV));
	}
}

if(@ARGV)
{
	handle($_) foreach @ARGV;
}
else
{
	my $term = Term::ReadLine->new('Simple Perl calc');
	while(defined($_ = $term->readline("(\%i" . (@Calc::Data::d+1) . ") ")))
	{
		handle($_);
	}
}

sub handle
{
	my ($l) = @_;
	chomp($l);
	return if length($l) == 0;
	my $d = Calc::calc($l);
	if($Calc::ERROR)
	{
		print STDERR "ERROR: $Calc::ERROR\n";
	}
	elsif(defined $d)
	{
		print "(\%o" . (@Calc::Data::d+1) . ") " unless $quiet;
		print Calc::format($d) if defined $d;
		$d //= '';
		print "\n";
		if($d =~ m/0x/) { push(@Calc::Data::d, Calc::Data::math(sub { hex($_[0]) }, $d)); }
		elsif($d =~ m/0o/) { push(@Calc::Data::d, Calc::Data::math(sub { oct($_[0]) }, $d)); }
		elsif($d =~ m/0b/) { push(@Calc::Data::d, Calc::Data::math(\&Calc::Data::bin2dec, $d)); }
		else { push(@Calc::Data::d, $d); }
	}
	else
	{
		print "Undefined return\n";
	}
}

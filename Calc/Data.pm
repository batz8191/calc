package Calc::Data;

use strict;
use warnings;
use POSIX qw{tan};
#use Math::GammaFunction qw{log_gamma};
#use TR1;

our @d;
our %funcs = (
	'log' => sub
		{
			my ($v, $b) = @_;
			return math(sub { return log($_[0]) / log($b) if $b; return log($_[0]); }, $v);
		},
	'binom' => sub
		{
			my ($n, $k) = @_;
			return math(sub { return TR1::binomial($_[0], $k); }, $n);
		},
	'fact' => sub { return math(sub { return TR1::factorial($_[0]) }, $_[0]); },
	'lg' => sub { return math(sub { return log($_[0]) / log(2); }, $_[0]); },
	'abs' => sub { return math(sub { return abs($_[0]); }, $_[0]); },
	'exp' => sub { return math(sub { return exp($_[0]); }, $_[0]); },
	'sqrt' => sub { return math(sub { return sqrt($_[0]); }, $_[0]); },
	'sign' => sub { return math(sub { return $_[0] < 0 ? -1 : $_[0] > 0 ? 1 : 0; }, $_[0]); },
	'sin' => sub { return math(sub { return sin($_[0]); }, $_[0]); },
	'cos' => sub { return math(sub { return cos($_[0]); }, $_[0]); },
	'tan' => sub { return math(sub { return POSIX::tan($_[0]); }, $_[0]); },
	'asin' => sub { return math(sub { return POSIX::asin($_[0]); }, $_[0]); },
	'acos' => sub { return math(sub { return POSIX::acos($_[0]); }, $_[0]); },
	'atan' => sub { return math(sub { return POSIX::atan($_[0]); }, $_[0]); },
	'round' => sub { return math(sub { return int($_[0] + 0.5); }, $_[0]); },
	'ceil' => sub { return math(sub { return POSIX::ceil($_[0]); }, $_[0]); },
	'floor' => sub { return math(sub { return POSIX::floor($_[0]); }, $_[0]); },
	'hex' => sub { return math(sub {
			if (ref($_[0]) eq 'Calc::Array') {
				return sprintf "0x%0X", $_ foreach @$_[0];
			} else {
				return sprintf "0x%0X", $_[0];
			} }, $_[0]);
	},
	'oct' => sub { return math(sub {
			if (ref($_[0]) eq 'Calc::Array') {
				return sprintf "0x%0O", $_ foreach @$_[0];
			} else {
				sprintf "0o%0O", $_[0];
			}
			}, $_[0]); },
	'bin' => sub { return math(sub {
			if (ref($_[0]) eq 'Calc::Array') {
				return sprintf "0x%s", dec2bin($_) foreach @$_[0];
			} else {
				sprintf "0b%s", dec2bin($_[0]);
			}
			}, $_[0]); },
	'gcd' => sub
		{
			my ($a, $b) = @_;
			return math(sub { gcd($_[0], $b) }, $a);
		},
	'lcm' => sub
		{
			my ($a, $b) = @_;
			return math(sub { $a * $_[0] / gcd($a, $_[0])}, $b);
		},
	'len' => sub
		{
			my ($a) = @_;
			return $a->len if ref($a) eq 'Calc::Array';
			return 1;
		},
	'reverse' => sub
		{
			my ($a) = @_;
			return $a->reverse if ref($a) eq 'Calc::Array';
			return $a;
		},
	'stats' => sub
		{
			my $list;
			if(@_ == 1) { $list = $_[0]; }
			else { $list = \@_; }
			my $n = 0; my $m = 0; my $M = 0;
			foreach my $t(@$list)
			{
				++$n;
				my $d = $t - $m;
				$m += $d / $n;
				$M += $d * ($t - $m);
			}
			my $v = $M / ($n - 1);
			print "mean: $m var: $v stdev: " . sqrt($v) . "\n";
			return 0;
		},
	'min' => sub
		{
			my ($arr) = @_;
			return 0 if ref($arr) ne 'Calc::Array';
			my $min = $arr->[0];
			$min = $min < $_ ? $min : $_ foreach @$arr;
			return $min;
		},
	'max' => sub
		{
			my ($arr) = @_;
			return 0 if ref($arr) ne 'Calc::Array';
			my $max = $arr->[0];
			$max = $max > $_ ? $max : $_ foreach @$arr;
			return $max;
		},
	'pct' => sub
		{
			my ($arr, $p) = @_;
			return 0 if ref($arr) ne 'Calc::Array';
			my @l = sort {$a<=>$b} @$arr;
			return @l[int($p * @l)]; # TODO interprolate
		},
	'sum' => sub
		{
			if(@_ == 1)
			{
				my $v = $_[0]->at(0);
				$v += $_[0]->at($_) for (1..$_[0]->len()-1);
				return $v;
			}
			else
			{
				my $v = $_[0];
				$v += $_[$_] foreach (1..@_-1);
				return $v;
			}
		},
	'prod' => sub
		{
			if(@_ == 1)
			{
				my $v = $_[0]->at(0);
				$v *= $_[0]->at($_) for (1..$_[0]->len()-1);
				return $v;
			}
			else
			{
				my $v = $_[0];
				$v *= $_[$_] foreach (1..@_-1);
				return $v;
			}
		},
);

sub math
{
	my ($f, $a) = @_;
	if(ref($a) eq 'Calc::Array') { return new Calc::Array(map {$f->($_)} @$a); }
	elsif(ref($a) eq 'Calc::Unit') { print STDERR "Cannot use units in functions.\n"; return 0; }
	else { return $f->($a); }
}

sub bin2dec
{
	return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub dec2bin
{
	my $str = unpack("B32", pack("N", shift));
	$str =~ s/^0+(?=\d)//;
	return $str;
}

sub gcd
{
	my ($u, $v) = @_;
	my $shift = 0;
	return $u | $v if $u == 0 || $v == 0;
	for($shift = 0; (($u | $v) & 1) == 0; ++$shift)
	{
		$u >>= 1;
		$v >>= 1;
	}
	while(($u & 1) == 0) { $u >>= 1; }
	do
	{
		while(($v & 1) == 0) { $v >>= 1; }
		if($u < $v) { $v -= $u; }
		else { my $diff = $u - $v; $u = $v; $v = $diff; }
		$v >>= 1;
	} while($v != 0);
	return $u << $shift;
}

1;

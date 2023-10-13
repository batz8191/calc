package Calc::Unit;

use strict;
use warnings;

use constant LENGTH => 0;
use constant MASS => 1;
use constant TIME => 2;
use constant CURRENT => 3;
use constant TEMP => 4;
use constant AMT => 5;
use constant LUMINOUS => 6;
use constant BIT => 7;
use constant MAX_UNIT => 8;

use overload
	'>>' => \&unit_rshift,
	'<<' => \&unit_lshift,
	'&' => \&unit_and,
	'|' => \&unit_or,
	'^' => \&unit_xor,
	'+' => \&add,
	'-' => \&subtract,
	'*' => \&mult,
	'/' => \&div,
	'%' => \&mod,
	'**' => \&pow,
	'<=>' => \&comp,
	'==' => \&unit_eq,
	'!=' => \&unit_ne,
	'<' => \&unit_lt,
	'<=' => \&unit_le,
	'>' => \&unit_gt,
	'>=' => \&unit_ge,
	'bool' => sub { defined($_[0]) ? $_[0]->{val} : 0; },
	'""' => \&str,
;

our %units = (
	                                               #   m k s A K m C B
	'const' =>      new Calc::Unit(1,              [qw/0 0 0 0 0 0 0 0/]),
	# Base units
	'\\m' =>        new Calc::Unit(1,              [qw/1 0 0 0 0 0 0 0/]),
	'\\kg' =>       new Calc::Unit(1,              [qw/0 1 0 0 0 0 0 0/]),
	'\\s' =>        new Calc::Unit(1,              [qw/0 0 1 0 0 0 0 0/]),
	'\\A' =>        new Calc::Unit(1,              [qw/0 0 0 1 0 0 0 0/]),
	'\\K' =>        new Calc::Unit(1,              [qw/0 0 0 0 1 0 0 0/]),
	'\\mole' =>     new Calc::Unit(1,              [qw/0 0 0 0 0 1 0 0/]),
	'\\cd' =>       new Calc::Unit(1,              [qw/0 0 0 0 0 0 1 0/]),
	'\\bits' =>     new Calc::Unit(1,              [qw/0 0 0 0 0 0 0 1/]),
	# Length
	'\\cm' =>       new Calc::Unit(0.01,           [qw/1 0 0 0 0 0 0 0/]),
	'\\km' =>       new Calc::Unit(1000,           [qw/1 0 0 0 0 0 0 0/]),
	'\\in' =>       new Calc::Unit(.0254,          [qw/1 0 0 0 0 0 0 0/]),
	'\\ft' =>       new Calc::Unit(0.3048,         [qw/1 0 0 0 0 0 0 0/]),
	'\\mile' =>     new Calc::Unit(1609.344,       [qw/1 0 0 0 0 0 0 0/]),
	# Volume
	'\\cc' =>       new Calc::Unit(0.000001,       [qw/3 0 0 0 0 0 0 0/]),
	'\\l' =>        new Calc::Unit(0.001,          [qw/3 0 0 0 0 0 0 0/]),
	'\\cup' =>      new Calc::Unit(0.000236588237, [qw/3 0 0 0 0 0 0 0/]),
	'\\gallon' =>   new Calc::Unit(0.00378541178,  [qw/3 0 0 0 0 0 0 0/]),
	'\\pint' =>     new Calc::Unit(0.000473176473, [qw/3 0 0 0 0 0 0 0/]),
	'\\oz' =>       new Calc::Unit(2.95735296E-5,  [qw/3 0 0 0 0 0 0 0/]),
	'\\qt' =>       new Calc::Unit(0.0009463529472,[qw/3 0 0 0 0 0 0 0/]),
	# Weight
	'\\lb' =>       new Calc::Unit(0.45359237,     [qw/0 1 0 0 0 0 0 0/]),
	'\\g' =>        new Calc::Unit(0.001,          [qw/0 1 0 0 0 0 0 0/]),
	'\\ounce' =>    new Calc::Unit(0.02835,        [qw/0 1 0 0 0 0 0 0/]),
	# Time
	'\\Hz' =>       new Calc::Unit(1,              [qw/0 0 -1 0 0 0 0 0/]),
	'\\us' =>       new Calc::Unit(1E-6,           [qw/0 0 1 0 0 0 0 0/]),
	'\\ms' =>       new Calc::Unit(1E-3,           [qw/0 0 1 0 0 0 0 0/]),
	'\\min' =>      new Calc::Unit(60,             [qw/0 0 1 0 0 0 0 0/]),
	'\\hr' =>       new Calc::Unit(3600,           [qw/0 0 1 0 0 0 0 0/]),
	'\\day' =>      new Calc::Unit(86400,          [qw/0 0 1 0 0 0 0 0/]),
	'\\week' =>     new Calc::Unit(604800,         [qw/0 0 1 0 0 0 0 0/]),
	'\\year' =>     new Calc::Unit(3.15569E7,      [qw/0 0 1 0 0 0 0 0/]),
	# Current
	'\\mA' =>       new Calc::Unit(1E-3,          [qw/0 0 0 1 0 0 0 0/]),
	# Temperature
	# NOTE this won't work with convert, not sure best fix
	#'\\degC' =>     new Calc::Unit(sub { return $_[0] + 273.15 }, [qw/0 0 0 0 1 0 0 0/]),
	#'\\degF' =>     new Calc::Unit(sub { return ($_[0] + 459.67) * 5.0/9.0 }, [qw/0 0 0 0 1 0 0 0/]),
	# Ammount
	# Luminous
	# Bits
	'\\bytes' =>    new Calc::Unit(8,              [qw/0 0 0 0 0 0 0 1/]),
	'\\kb' =>       new Calc::Unit(8192,           [qw/0 0 0 0 0 0 0 1/]),
	'\\mb' =>       new Calc::Unit(8388608,        [qw/0 0 0 0 0 0 0 1/]),
	'\\gb' =>       new Calc::Unit(8589934592,     [qw/0 0 0 0 0 0 0 1/]),
	'\\tb' =>       new Calc::Unit(8796093022208,  [qw/0 0 0 0 0 0 0 1/]),
	# Velocity
	'\\mph' =>      new Calc::Unit(.44704,         [qw/1 0 -1 0 0 0 0 0/]),
	# Force
	'\\N' =>        new Calc::Unit(1,              [qw/1 1 -2 0 0 0 0 0/]),
	# Energy
	'\\J' =>        new Calc::Unit(1,              [qw/2 1 -2 0 0 0 0 0/]),
	# Power
	'\\W' =>        new Calc::Unit(1,              [qw/2 1 -3 0 0 0 0 0/]),
	# Electricity
	'\\V' =>        new Calc::Unit(1,              [qw/2 1 -3 -1 0 0 0 0/]),
	'\\Ohm' =>      new Calc::Unit(1,              [qw/2 1 -3 -2 0 0 0 0/]),
	'\\C' =>        new Calc::Unit(1,              [qw/0 0 1 1 0 0 0 0/]),
	'\\henry' =>    new Calc::Unit(1,              [qw/2 1 -2 -2 0 0 0 0/]),
	'\\F' =>        new Calc::Unit(1,              [qw/-2 -1 4 2 0 0 0 0/]),
	                                               #   m G s A K M C B
);

sub new
{
	my ($cls, $v, $arr) = @_;
	my $self = {
		val => $v || 0,
		arr => $arr || [(0) x MAX_UNIT],
	};
	if(!ref($self->{arr}))
	{
		my $u = $units{$arr};
		if(!defined($u))
		{
			print STDERR "Unknown unit \"$arr\" ignoring\n" unless $u;
			return 0;
		}
		elsif(ref($u->{val}) eq 'CODE')
		{
			$self->{arr} = $u->{arr};
			$self->{val} = $u->{val}->($v);
		}
		else
		{
			$self->{arr} = $u->{arr};
			$self->{val} *= $u->{val};
		}
	}
	if(scalar(grep {$_ != 0} @{$self->{arr}}) == 0) { return $v; }
	$self = bless($self, $cls);
	return $self;
}

sub add_unit
{
	my ($name, $unit) = @_;
	if($name !~ m/^\\/)
	{
		print STDERR "Invalid name: $name\n";
		return;
	}
	if(ref($unit) ne 'Calc::Unit')
	{
		print STDERR "To add a unit a unit must be specified: $unit\n";
		return;
	}
	$units{$name} = $unit;
}

sub match
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		my $t = 1;
		for my $i(0..MAX_UNIT-1)
		{
			if($b->{arr}->[$i] != $self->{arr}->[$i])
			{
				$t = 0;
				last;
			}
		}
		if($t) { return 1; }
		else
		{
			$Calc::ERROR = "Invalid units ($self, $b) cannot proceed";
			return 0;
		}
	}
	else { return 0; }
}


sub math
{
	my ($f, $a, $b, $rev) = @_;
	my $t = ref($b);
	($b, $a) = ($a, $b) if $rev;
	if($t eq 'Calc::Unit')
	{
		if(match($a, $b)) { return $f->($a, $b); }
		else { return 0; }
	}
	elsif($t eq 'Calc::Array')
	{
		return new Calc::Array(map {math($f, $a, $_, $rev)} @{$b});
	}
	else
	{
		return $f->($a, $b);
	}
}

sub val
{
	my ($self) = @_;
	if(ref($self) eq 'Calc::Unit') { return $self->{val}; }
	else { return $self; }
}

sub comp
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) <=> val($_[1]) }, $self, $b, $rev);
}

sub unit_eq
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) == val($_[1]) }, $self, $b, $rev);
}

sub unit_ne
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) != val($_[1]) }, $self, $b, $rev);
}

sub unit_lt
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) < val($_[1]) }, $self, $b, $rev);
}

sub unit_le
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) <= val($_[1]) }, $self, $b, $rev);
}

sub unit_gt
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) < val($_[1]) }, $self, $b, $rev);
}

sub unit_ge
{
	my ($self, $b, $rev) = @_;
	return math(sub { val($_[0]) >= val($_[1]) }, $self, $b, $rev);
}

sub unit_lshift
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		$Calc::ERROR = 'Cannot have a unit in the exponent';
		return 0;
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {unit_lshift($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} << $b, $self->{arr}); }
}

sub unit_rshift
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		$Calc::ERROR = 'Cannot have a unit in the exponent';
		return 0;
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {unit_rshift($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} >> $b, $self->{arr}); }
}

sub unit_and
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($self->{val} & $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {unit_and($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} & $b, $self->{arr}); }
}

sub unit_or
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($self->{val} | $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {unit_or($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} | $b, $self->{arr}); }
}

sub unit_xor
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($self->{val} ^ $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {unit_xor($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} ^ $b, $self->{arr}); }
}
sub add
{
	my ($self, $b) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($self->{val} + $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {add($self, $_)} @{$b}); }
	else { return new Calc::Unit($self->{val} + $b, $self->{arr}); }
}

sub subtract
{
	my ($self, $b, $rev) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($rev ? $b->{val} - $self->{val} : $self->{val} - $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {subtract($self, $_, $rev)} @{$b}); }
	else { return new Calc::Unit($rev ? $b - $self->{val} : $self->{val} - $b, $self->{arr}); }
}

sub mult
{
	my ($self, $b, $rev) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		my @arr = (0) x MAX_UNIT;
		for my $i(0..MAX_UNIT-1) { $arr[$i] = $b->{arr}->[$i] + $self->{arr}->[$i]; }
		return new Calc::Unit($self->{val} * $b->{val}, \@arr);
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {mult($self, $_, $rev)} @{$b}); }
	else { return new Calc::Unit($self->{val} * $b, $self->{arr}); }
}

sub div
{
	my ($self, $b, $rev) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		my @arr = (0) x MAX_UNIT;
		for my $i(0..MAX_UNIT-1)
		{
			$arr[$i] = $rev ? $b->{arr}->[$i] - $self->{arr}->[$i] : $self->{arr}->[$i] - $b->{arr}->[$i];
		}
		return new Calc::Unit($rev ? $b->{val} / $self->{val} : $self->{val} / $b->{val}, \@arr);
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {div($self, $_, $rev)} @{$b}); }
	else { return new Calc::Unit($rev ? $b / $self->{val} : $self->{val} / $b, $rev ? [map {-$_} @{$self->{arr}}] : $self->{arr}); }
}

sub mod
{
	my ($self, $b, $rev) = @_;
	if(ref($b) eq 'Calc::Unit')
	{
		if(match($self, $b)) { return new Calc::Unit($rev ? $b->{val} % $self->{val} : $self->{val} % $b->{val}, $self->{arr}); }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {mod($self, $_, $rev)} @{$b}); }
	else { return new Calc::Unit($rev ? $b % $self->{val} : $self->{val} % $b, $self->{arr}); }
}

sub pow
{
	my ($self, $b, $rev) = @_;
	if(ref($b) eq 'Calc::Unit' || $rev)
	{
		$Calc::ERROR = 'Cannot have a unit in the exponent';
		return 0;
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {pow($self, $_, $rev)} @{$b}); }
	else { return new Calc::Unit($rev ? $b ** $self->{val} : $self->{val} ** $b, $rev ? $self->{arr} : [map {$_ * $b} @{$self->{arr}}]); }
}

sub convert
{
	my ($self, $to) = @_;
	return new Calc::Array(map {convert($_, $to)} @{$self}) if ref($self) eq 'Calc::Array';
	return $self unless ref($self) eq 'Calc::Unit';
	if(ref($to) eq 'Calc::Unit')
	{
		if(match($self, $to)) { return $self->{val} / $to->{val}; }
		else { return 0; }
	}
	elsif(ref($b) eq 'Calc::Array') { return new Calc::Array(map {convert($self, $b)} @{$b}); }
	else { return $self->{val}; }
}

sub str
{
	my ($self) = @_;
	my $s = $self->{val} . ' ';
	my @n = qw/\\m \\kg \\s \\A \\K \\mole \\cd \\bits/;
	my @s;
	for (0..MAX_UNIT-1)
	{
		if($self->{arr}->[$_])
		{
			my $t;
			$t = $n[$_];
			$t .= "^$self->{arr}->[$_]" if $self->{arr}->[$_] != 1;
			push(@s, $t);
		}
	}
	return Calc::format($self->{val}) . (@s ? ' ' : '') . join(' * ', @s);
}

1;

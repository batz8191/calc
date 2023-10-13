package Calc::Array;

use strict;
use warnings;

use overload
	'<<' => sub { return math(sub {$_[0] << $_[1]}, @_); },
	'>>' => sub { return math(sub {$_[0] >> $_[1]}, @_); },
	'&' => sub { return math(sub {$_[0] & $_[1]}, @_); },
	'|' => sub { return math(sub {$_[0] | $_[1]}, @_); },
	'^' => sub { return math(sub {$_[0] ^ $_[1]}, @_); },
	'+' => sub { return math(sub {$_[0] + $_[1]}, @_); },
	'-' => sub { return math(sub {$_[0] - $_[1]}, @_); },
	'*' => sub { return math(sub {$_[0] * $_[1]}, @_); },
	'/' => sub { return math(sub {$_[0] / $_[1]}, @_); },
	'%' => sub { return math(sub {$_[0] % $_[1]}, @_); },
	'**' => sub { return math(sub {$_[0] ** $_[1]}, @_); },
	'<=>' => sub { return math(sub {$_[0] <=> $_[1]}, @_); },
	'==' => sub { return math(sub {$_[0] == $_[1] || 0}, @_); },
	'!=' => sub { return math(sub {$_[0] != $_[1] || 0}, @_); },
	'<' => sub { return math(sub {$_[0] < $_[1] || 0}, @_); },
	'>' => sub { return math(sub {$_[0] > $_[1] || 0}, @_); },
	'<=' => sub { return math(sub {$_[0] <= $_[1] || 0}, @_); },
	'>=' => sub { return math(sub {$_[0] >= $_[1] || 0}, @_); },
	'""' => sub
		{
			my ($self) = @_;
			return '[' . join(', ', map {Calc::format($_)} @$self) . ']';
		}
;

sub math
{
	my ($f, $a, $b, $rev) = @_;
	my $r = __PACKAGE__->new();
	if(ref($b) eq __PACKAGE__)
	{
		my $s = @$a < @$b ? @$a : @$b;
		print STDERR __PACKAGE__ . " sizes do not match, ignoring extra elements\n" unless @$a == @$b;
		for (0..$s-1) { $r->push($f->($rev ? $b->[$_] : $a->[$_], $rev ? $a->[$_] : $b->[$_])); }
	}
	else
	{
		for (0..@$a-1) { $r->push($f->($rev ? $b : $a->[$_], $rev ? $a->[$_] : $b)); }
	}
	return $r;
}

sub new
{
	my ($cls, @args) = @_;
	my $self = [@args];
	$self = bless($self, $cls);
	return $self;
}

sub push
{
	my ($self, @v) = @_;
	push(@{$self}, @v);
	return $self;
}

sub at
{
	my ($self, $v) = @_;
	if(ref($v) eq __PACKAGE__)
	{
		if(scalar(grep {$_ >= @$self} @$v))
		{
			$Calc::ERROR = "Invalid index $v must be less than " . @$self;
			return 0;
		}
		my @a = @$self;
		return __PACKAGE__->new(@a[@$v]);
	}
	if($v >= @$self)
	{
		$Calc::ERROR = "Invalid index $v must be less than " . @$self;
		return 0;
	}
	return $self->[$v];
}

sub has
{
	my ($self, $v) = @_;
	return scalar(grep {ref($_) eq __PACKAGE__ ? $_->has($v) : $_ == $v} @$self) > 0;
}

sub len
{
	my ($self) = @_;
	return scalar(@$self);
}

sub reverse
{
	my ($self) = @_;
	return __PACKAGE__->new(reverse(@$self));
}

1;

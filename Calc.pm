package Calc;

use strict;
use warnings;
use Calc::Data;
use Calc::Array;
use Calc::Unit;
use Parse::RecDescent;
use Class::Struct;
use Data::Dumper;

struct(TernaryOp => { left => '$', middle => '$', right => '$', op => '$' });
struct(BinOp => { left => '$', right => '$', op => '$' });
struct(UnaryOp => { left => '$', op => '$' });
struct(Variable => { name => '$' });

$::RD_HINT = 1;
our $DEBUG = 0;

our $grammar = q {
	start:
		statement unitto(?) eof
			{
				if(@{$item[2]})
				{
					$return = new BinOp(left => $item[1], op => '->', right => shift(@{$item[2]}));
				}
				else
				{
					$return = $item[1];
				}
			}
		| <error>

	statement:
		unit ('='...!'=') expression
			{
				print "Add unit: $item[1] $item[3]\n" if $Calc::DEBUG;
				new BinOp(left => $item[1], op => 'def_unit', right => $item[3]);
			}
		| name '(' namelist ')' '=' combine
			{
				print "Define function: $item[1] @{$item[3]} $item[6]\n" if $Calc::DEBUG;
				$return = new TernaryOp(left => $item[1], middle => $item[3], right => $item[6], op => 'def_fun');
			}
		| <rightop: name ('='...!'=') combine>
			{
				my $r = pop(@{$item[1]});
				while(@{$item[1]})
				{
					my $op = pop(@{$item[1]});
					my $t = pop(@{$item[1]});
					$r = new BinOp(left => $t, op => 'assign', right => $r);
				}
				$return = $r;
			}

	combine:
		<leftop: comp ('&&' | '||') comp>
			{
				my $r = shift @{$item[1]};
				print "\tcombine: $r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => $op, right => $t);
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	comp:
		shift ('<=' | '>=' | '<' | '>' | '==' | '!=') shift
			{
				my ($l, $r) = ($item[1], $item[3]);
				$return = new BinOp(left => $l, op => $item[2], right => $r);
			}
		| shift
	
	shift:
		<leftop: expression ('<<' | '>>') expression>
			{
				my $r = shift @{$item[1]};
				print "\tshift: r=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => $op, right => $t);
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	expression:
		<leftop: addition ('&' | '|' | '^^') addition>
			{
				my $r = shift @{$item[1]};
				print "\texpression: r=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => $op, right => $t);
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	addition:
		<leftop: term ('+' | '-') term>
			{
				my $r = shift(@{$item[1]});
				print "\taddition: s=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => $op, right => $t);
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	term:
		<leftop: pow ('*' | '/' | '%') pow>
			{
				my $r = shift(@{$item[1]});
				print "\tterm: s=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => $op, right => $t);
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	pow:
		<leftop: fact ('^' | '**') fact>
			{
				my $r = shift(@{$item[1]});
				print "\tpower: r=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op, $t) = splice @{$item[1]}, 0, 2;
					$r = new BinOp(left => $r, op => '^', right => $t);
				}
				$return = $r;
			}
	
	fact:
		<leftop: seq '!'...!'='>
			{
				my $r = shift(@{$item[1]});
				print "\tfact: r=$r\n" if $Calc::DEBUG;
				while(@{$item[1]})
				{
					my ($op) = splice @{$item[1]}, 0, 1;
					$r = new UnaryOp(left => $r, op => 'factorial');
				}
				print "\t\tret=$r\n" if $Calc::DEBUG;
				$return = $r;
			}

	seq:
		factor (':' factor)(1..2)
			{
				my ($l, $h, $s) = ($item[1], @{$item[2]});
				$s ||= 1;
				$s *= -1 if $h < $l && $s > 0;
				print "\tseq: $l $h $s\n" if $Calc::DEBUG;
				$return = new TernaryOp(left => $l, middle => $s, right => $h, op => 'seq');
			}
		| factor

	factor:
		number unit ('^' number)(?)
			{
				my $r = new Calc::Unit($item[1], $item[2]);
				$r->{arr} = [map {$_ * $item[3]->[0]} @{$r->{arr}}] if @{$item[3]};
				$return = $r;
			}
		| number { $item[1] }
		| unit { new Calc::Unit(1, $item[1]) }
		| name '(' list ')'
			{
				print "\tfactor: $item[1]\n" if $Calc::DEBUG;
				$return = new BinOp(left => $item[1], op => 'call', right => $item[3]);
			}
		| name '[' shift ']'	{ new BinOp(left => $item[1], op => 'at', right => $item[3]); }
		| name			{ new Variable(name => $item[1]); }
		| '+' factor		{ $item[2] }
		| '-' factor		{ new UnaryOp(left => $item[2], op => 'negate') }
		| '%e'			{ exp(1) }
		| '%pi'			{ POSIX::asin(1)*2 }
		| '%%'			{ $Calc::Data::d[@Calc::Data::d - 1] }
		| '%o' m/\d+/		{ $Calc::Data::d[$item[2] - 1] }
		| '(' combine ')'	{ $item[2] }
		| '[' list ']'		{ new UnaryOp(left => $item[2], op => 'array') }

	list: shift(s /,/)	{ [@{$item[1]}] }

	namelist: name(s /,/) { [@{$item[1]}] }

	unitto: '->' expression { $item[2] }

	number:
		m/0x[0-9a-fA-F_]+/	{ $item[1] =~ s/_//g; hex(substr($item[1], 2)) }
		| m/0b[01_]+/		{ $item[1] =~ s/_//g; Calc::Data::bin2dec(substr($item[1], 2)) }
		| m/0o[0-7_]+/		{ $item[1] =~ s/_//g; oct(substr($item[1], 2)) }
		| m/-?[\d_]+(\.[\d_]+)?([eE]-?[\d_]+)?/ { $item[1] =~ s/_//g; $item[1] + 0 }

	name: /[a-zA-Z][a-zA-Z0-9_]*/

	unit: /\\\\[a-zA-Z]+/

	eof: /^\Z/
};

# TODO this should be in a new function
# Need to make all ours into objects
our $ERROR;
our %vars;
our $parser = Parse::RecDescent->new($grammar);
our @stack;

sub format {
	my ($s) = @_;
	if (ref($s) eq 'Calc::Array') {
		return $s;
	} elsif(ref($s) eq 'Calc::Unit') {
		return $s;
	} else {
		$s =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1_/g;
		return $s;
	}
}

sub calc
{
	$Calc::ERROR = undef;
	my $ast = $parser->start(shift);
	print "Ast:\n[" . Dumper($ast) . "]\n" if $DEBUG;
	if(defined $ast)
	{
		my $r = _calc($ast);
		$r = 0 unless defined $r;
		return $r;
	}
	return undef;
}

sub _calc
{
	my ($ast) = @_;
	print "_calc:\n" . Dumper($ast) if $DEBUG;
	if(!ref($ast))
	{
		print "Returning " . $ast . "\n" if $DEBUG;
		return $ast;
	}
	elsif(ref($ast) eq 'BinOp')
	{
		if($ast->op eq 'call')
		{
			if(ref($Calc::Data::funcs{$ast->left}) eq 'CODE')
			{
				return $Calc::Data::funcs{$ast->left}->(map {_calc($_)} @{$ast->right});
			}
			elsif($Calc::Data::funcs{$ast->left})
			{
				my @args = @{$Calc::Data::funcs{$ast->left}->left};
				my @params = @{$ast->right};
				if(@params != @args)
				{
					$Calc::ERROR = "Invalid number of arguments: " . scalar(@params)
						. ". " . $ast->left . " requires "
						. scalar(@args) . " arguments";
					return undef;
				}
				my %v = %Calc::vars;
				push(@Calc::stack, \%v);
				for my $i(0..scalar(@args)-1)
				{
					$Calc::vars{$args[$i]} = _calc($params[$i]);
				}
				my $r = _calc($Calc::Data::funcs{$ast->left}->right);
				%Calc::vars = %{pop(@Calc::stack)};
				return $r;
			}
			else
			{
				$Calc::ERROR = "Unknown function: " . $ast->left;
				return undef;
			}
		}
		elsif($ast->op eq '&&')
		{
			my $l = _calc($ast->left);
			my $r = _calc($ast->right);
			return $l && $r ? 1 : 0;
		}
		elsif($ast->op eq '||')
		{
			my $l = _calc($ast->left);
			my $r = _calc($ast->right);
			return $l || $r ? 1 : 0;
		}
		elsif($ast->op eq '<=')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l <= $r || 0;
		}
		elsif($ast->op eq '>=')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l >= $r || 0;
		}
		elsif($ast->op eq '<')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l < $r || 0;
		}
		elsif($ast->op eq '>')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l > $r || 0;
		}
		elsif($ast->op eq '==')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l == $r || 0;
		}
		elsif($ast->op eq '!=')
		{
			my $r = _calc($ast->right);
			my $l = _calc($ast->left);
			return 0 unless defined($l) && defined($r);
			return $l != $r || 0;
		}
		elsif($ast->op eq '/')
		{
			my $r = _calc($ast->right);
			if(ref($r) eq 'Calc::Array' ? $r->has(0) : $r == 0)
			{
				$Calc::ERROR = "Illegal division by zero";
				return 0;
			}
			return _calc($ast->left) / $r;
		}
		elsif($ast->op eq '%')
		{
			my $r = _calc($ast->right);
			if(ref($r) eq 'Calc::Array' ? $r->has(0) : $r == 0)
			{
				$Calc::ERROR = "Illegal mudulus of zero";
				return 0;
			}
			return _calc($ast->left) % $r;
		}
		elsif($ast->op eq '->') { return Calc::Unit::convert(_calc($ast->left), _calc($ast->right)) }
		elsif($ast->op eq 'def_unit') { return Calc::Unit::add_unit(_calc($ast->left), _calc($ast->right)) }
		elsif($ast->op eq '<<') { return _calc($ast->left) << _calc($ast->right) }
		elsif($ast->op eq '>>') { return _calc($ast->left) >> _calc($ast->right) }
		elsif($ast->op eq '&') { return _calc($ast->left) & _calc($ast->right) }
		elsif($ast->op eq '|') { return _calc($ast->left) | _calc($ast->right) }
		elsif($ast->op eq '^^') { return _calc($ast->left) ^ _calc($ast->right) }
		elsif($ast->op eq '+') { return _calc($ast->left) + _calc($ast->right) }
		elsif($ast->op eq '-') { return _calc($ast->left) - _calc($ast->right) }
		elsif($ast->op eq '*') { return _calc($ast->left) * _calc($ast->right) }
		elsif($ast->op eq '^') { return _calc($ast->left) ** _calc($ast->right) }
		elsif($ast->op eq 'assign') { return $Calc::vars{_calc($ast->left)} = _calc($ast->right) }
		elsif($ast->op eq 'at')
		{
			if(!defined($Calc::vars{_calc($ast->left)}))
			{
				$Calc::ERROR = "Cannot index an undefined variable: " . _calc($ast->left);
				return 0;
			}
			elsif(ref($Calc::vars{_calc($ast->left)}) ne 'Calc::Array')
			{
				$Calc::ERROR = "Variable " . _calc($ast->left) . " is not an array";
				return 0;
			}
			return $Calc::vars{_calc($ast->left)}->at(_calc($ast->right))
		}
		else { $Calc::ERROR = "Unknown op: " . $ast->op; return undef; }
	}
	elsif(ref($ast) eq 'UnaryOp')
	{
		if($ast->op eq 'negate') { return -1 * _calc($ast->left) }
		elsif($ast->op eq 'factorial') { return $Calc::Data::funcs{'fact'}->(_calc($ast->left)) }
		elsif($ast->op eq 'array')
		{
			return new Calc::Array(map {_calc($_)} @{$ast->left});
		}
		else { $Calc::ERROR = "Unknown op: " . $ast->op; return undef; }
	}
	elsif(ref($ast) eq 'Variable')
	{
		if(!defined($Calc::vars{_calc($ast->name)}))
		{
			$Calc::ERROR = "Cannot use an undefined variable: " . _calc($ast->name);
			return 0;
		}
		return $Calc::vars{$ast->name} || 0;
	}
	elsif(ref($ast) eq 'TernaryOp')
	{
		if($ast->op eq 'seq')
		{
			my $l = _calc($ast->left);
			my $s = _calc($ast->middle);
			my $h = _calc($ast->right);
			my @a;
			if($s > 0) { for(my $i = $l; $i <= $h; $i += $s) { push(@a, $i); } }
			else { for(my $i = $l; $i >= $h; $i += $s) { push(@a, $i); } }
			return new Calc::Array(@a);
		}
		elsif($ast->op eq 'def_fun')
		{
			if(ref($Calc::Data::funcs{$ast->left}) eq 'CODE')
			{
				$Calc::ERROR = $ast->left . " is a reserved function";
				return undef;
			}
			$Calc::Data::funcs{$ast->left} = new BinOp(left => $ast->middle, op => 'func', right => $ast->right);
			return 1;
		}
		else { $Calc::ERROR = "Unknown op: " . $ast->op; return undef; }
	}
	else
	{
		print ref($ast) . "\n" if $DEBUG;
		return $ast;
	}
}

1;

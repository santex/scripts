#!/usr/bin/perl

# currently only implements ?, *. [], {} not yet supported. (is {} part of wildcard?)

sub wildcard2re($) {
	my $arg = shift;
	my $state = {
		in_single_quote => 0,
		in_double_quote => 0,
		after_backslash => 0,
	};
	
	my $subst = sub {
		my $arg = shift;
		if ($arg eq '"') {
			if (!$state->{in_single_quote}) {
				$state->{in_double_quote} = not $state->{in_double_quote};
				return "";
			} else {
				return '"';
			}
		} elsif ($arg eq "'") {
			if (!$state->{in_double_quote}) {
				$state->{in_single_quote} = not $state->{in_single_quote};
				return "";
			} else {
				return "'";
			}
		} elsif ($arg eq '*') {
			if ($state->{in_single_quote} || $state->{in_double_quote}) {
				return "\\*";
			} else {
				return ".*";
			}
		} elsif ($arg eq '?') {
			if ($state->{in_single_quote} || $state->{in_double_quote}) {
				return "\\?";
			} else {
				return ".";
			}
		} elsif ($arg eq '.') {
			return "\\.";
		} else {
			return $arg;
		}
	};
	
	$arg =~ s/(\.|'|"|\*|\?|[^\.'"\*\?]+)/$subst->($1)/egs;
	
	"^$arg\$";
}



for(qw/satu* "satu*" "s"atu* sa*tu? '"satu.*"'/) {
	printf "%s = %s\n", $_, wildcard2re($_);
}


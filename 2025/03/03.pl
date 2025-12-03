#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util qw(max uniqstr);

MAIN: {
    my @strings;
    while ( <<>> ) {
        chomp;
        push @strings, [split "", $_];
    }

    my $part1 = 0;
    my $part2 = 0;

    for my $string (@strings) {
        $part1 += largest($string, 2);
        $part2 += largest($string, 12);
    }

    say("Part 1: $part1");
    say("Part 2: $part2");
}

sub largest($string, $sz) {
    if ($sz == 0) {
        return "";
    }
    my $len = scalar(@$string);
    my $lastidx = $len-$sz;

    my @possibles = @$string[0..$lastidx];
    my $max = max(@possibles);

    my $ret = 0;
    my %seen;  # Used as speedup.
    for (my $i=0; $i<=$lastidx; $i++) {
        my $val = $string->[$i];
        if ($val != $max) { next }
        my (@remainder) = @$string[($i+1)..($len-1)];
        if (scalar(@remainder)) {
            if (exists $seen{$val . $remainder[0]}) { next }
            $seen{$val . $remainder[0]} = 1;
        }
        my $x = "$val" . largest(\@remainder, $sz-1);
        if ($x > $ret) {
            $ret = $x;
        }
    }

    return $ret
}

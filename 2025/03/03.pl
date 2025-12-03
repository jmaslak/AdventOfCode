#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util qw(max sum);
use Parallel::WorkUnit;

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
    }
    
    my $wu = Parallel::WorkUnit->new();
    $wu->queueall(\@strings, sub($x) { largest($x, 12) });
    $part2 = sum($wu->waitall());

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

    for (my $i=0; $i<=$lastidx; $i++) {
        my $val = $string->[$i];
        if ($val != $max) { next }
        my (@remainder) = @$string[($i+1)..($len-1)];
        return "$val" . largest(\@remainder, $sz-1);
    }

    die("shouldn't get here");
}

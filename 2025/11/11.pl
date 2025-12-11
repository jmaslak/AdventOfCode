#!/usr/bin/perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(any sum);
use Memoize;

sub traverse($exits, $src="you", $out="out", @must) {
    @must = grep { $_ ne $src } @must;

    if ($src eq $out) {
        if (scalar(@must)) {
            return 0;
        } else {
            return 1;
        }
    }

    return sum map { traverse($exits, $_, $out, @must) } $exits->{$src}->@*;
}
memoize('traverse');

MAIN: {
    my %exits;
    for (<<>>) {
        chomp;
        next if (/^$/);

        my ($source, $dst) = split /: /;
        my (@dsts) = split / /, $dst;

        $exits{$source} = \@dsts;
    }

    say "Part 1: " . traverse(\%exits, "you", "out");
    say "Part 2: " . traverse(\%exits, "svr", "out", "fft", "dac");
}



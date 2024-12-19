#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use Data::Dumper;

sub count_matches($patterns, $towels) {
    my $sum = 0;
    my $line = 0;
    for my $pattern (@$patterns) {
        say "Trying line " . ++$line;
        $sum += check($pattern, "", $towels);
    }

    return $sum;
}

sub check($p, $s, $sources) {
    state %cache;  # Yep, we need to cache...

    my $key = "$p $s";
    if (exists($cache{$key})) { return $cache{$key} };

    my $ret = 0;
    if ($s ne "") {
        my $trial = $p;
        if ($trial =~ s/^$s//) {
            if ($trial eq "") { return 1; }
            $ret = check($trial, "", $sources);
        }
    } else {
        if ($p eq "") { return 1 }
        for my $source (@$sources) {
            $ret += check($p, $source, $sources);
        }
    }
    $cache{$key} = $ret;
    return $ret;
}

sub regex(@towels) {
    return "^(" . join('|', @towels) . ")*\$";
}

MAIN: {
    my @towels;
    my @patterns;
    while (<<>>) {
        chomp;

        if (/,/) {
            @towels = split /, /;
        } elsif ($_ eq "") {
            next;
        } else {
            push @patterns, $_;
        }
    }

    my $regex = regex(@towels);
    my $sum = 0;
    for my $p (@patterns) {
        if ($p =~ /$regex/) { $sum++ }
    }

    # my $part1 = count_matches(\@towels, \@patterns);
    say "Part 1: $sum";

    my $part2 = count_matches(\@patterns, \@towels);
    say "Part 2: $part2";
}



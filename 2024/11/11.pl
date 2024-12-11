#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(sum);

MAIN: {
    my $d = "";
    while (my $line = <<>>) {
        chomp($line);
        $d .= " " . $line;
    }
    $d =~ s/\s+//;
    my (@data) = split /\s+/, $d;

    my $sum = sum map { scalar(blink($_, 25)) } @data;
    say "Part 1: $sum";

    $sum = sum map { scalar(blink($_, 75)) } @data;
    say "Part 2: $sum";
}

sub blink($stone, $times) {
    state %cache;

    my $key = "$stone $times";
    if (exists($cache{$key})) {
        return $cache{$key};
    }
    if ($times == 0) {
        return 1;
    }

    my @new;
    if ($stone eq 0) {
        $cache{$key} = blink(1, $times-1);
    } elsif (length($stone) % 2 == 0) {
        my $sz = length($stone);
        $cache{$key} = blink(substr($stone, 0, $sz/2), $times-1) + blink(0 + substr($stone, $sz/2), $times-1);
    } else {
        $cache{$key} = blink(2024 * $stone, $times-1);
    }
    return $cache{$key};
}


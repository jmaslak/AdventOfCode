#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;
use Data::Dump;
use List::Util qw(max uniqstr sum);
use Parallel::WorkUnit;
use Memoize;

MAIN: {
    memoize('combos');
    my $wu = Parallel::WorkUnit->new();
    $wu->max_children(24);
    my $sum = 0;
    my $cnt = 0;
    while (my $line = <<>>) {
        chomp($line);
        my ($s, $p) = split /\s+/, $line;
        my $springs_str = "$s?$s?$s?$s?$s";
        my $possible_str = "$p,$p,$p,$p,$p";

        my @components = split /,/, $possible_str;

        $wu->queue( sub { say $s; combos($springs_str, @components) }, sub ($r) { $sum += $r } );
    }
    $wu->waitall();
    say("Sum: $sum");
}

sub combos($str, @components) {
    my $start = shift(@components);
    my $remaining = (sum(@components) // 0) + scalar(@components);
    
    $str =~ s/^[.]+//;

    my $sum = 0;
    state %cache;
    for (my $i=0; $i<=length($str)-$remaining-$start; $i++) {
        if ($i > 0 and substr($str, $i-1, 1) eq '#') { return $sum; }
        if (substr($str, $i, $start) =~ m/^[?#]+$/) {
            if (scalar(@components)) {
                if (substr($str, $i+$start, 1) =~ m/[.?]/) {
                    $sum += combos(substr($str, $i+$start+1), @components)
                }
            } else {
                if (length($str) <= ($i+$start)) { return $sum + 1; }
                if (substr($str, $i+$start) =~ m/^[.?]*$/) {
                    $sum++;
                }
            }
        }
    }
    return $sum;
}

__END__

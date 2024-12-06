#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;
use List::Util qw(uniqstr);

MAIN: {
    my $table = Table->new();
    $table->read(\*STDIN);
    $table->add_border(" ");

    my $part1 = scalar mark($table->copy())->find("X");
    say "Part1: $part1";

    my (@pos) = $table->find("^");
    my $start = $pos[0];

    my $mark = mark($table->copy());

    my $part2 = 0;
    for my $pos ($mark->find("X")) {
        if ($pos->string() eq $start->string()) { next; }
        my $t = $table->copy();
        $t->copy()->put($pos, "#");
        $t->put($pos, "#");
        if (!defined(mark($t))) {
            $part2++;
        }
    }
    say "Part2: $part2";
}

sub mark($table) {
    my (@pos) = $table->find("^");
    my $location = $pos[0];

    my $direction = "n";
    my %visited;
    $visited{"n"} = {};
    $visited{"s"} = {};
    $visited{"e"} = {};
    $visited{"w"} = {};
    my $next;
    while (defined($location)) {
        if ($table->get($location) ne "#") {
            if (exists($visited{$direction}{$location->string()})) {
                # Done;
                return undef;  # We return a paradox.
            }
        }
        if ($table->get($location) eq " ") {
            # Also done!
            last;
        }

        $table->put($location, "X");
        $visited{$direction}{$location->string()} = 1;
        if ($direction eq "n") {
            if ($table->get($location->n()) eq "#") {
                $direction = "e";
            } else {
                $location = $location->n();
            }
        } elsif ($direction eq "e") {
            if ($table->get($location->e()) eq "#") {
                $direction = "s";
                $next = $table->get($location->s());
            } else {
                $location = $location->e();
            }
        } elsif ($direction eq "s") {
            if ($table->get($location->s()) eq "#") {
                $direction = "w";
            } else {
                $location = $location->s();
            }
        } elsif ($direction eq "w") {
            if ($table->get($location->w()) eq "#") {
                $direction = "n";
            } else {
                $location = $location->w();
            }
        }
    }

    return $table;
}

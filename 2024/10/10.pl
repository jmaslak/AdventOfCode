#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(sum);

use lib '.';
use Table;

MAIN: {
    my $table = Table->new();
    $table->read(\*STDIN);

    say "Part 1: " . sum map { count_trails($table->copy(), $_, 0, 0) } $table->find("0");
    say "Part 2: " . sum map { count_trails($table->copy(), $_, 0, 1) } $table->find("0");
}

sub count_trails($table, $start, $level, $all_paths) {
    my $mylevel = $table->get($start);

    if ($mylevel eq '.')    { return 0 }
    if ($mylevel != $level) { return 0 }

    if ($level == 9) {
        $table->put($start, '.') unless $all_paths;
        return 1;
    }

    return sum
           map  { count_trails($table, $_, $level + 1, $all_paths) }
           grep { $table->is_in_bounds($_) }
                $table->neighbors4($start);
}



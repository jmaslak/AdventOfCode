#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(min);

class Machine {
    field $ax  :reader;
    field $ay  :reader;
    field $bx  :reader;
    field $by  :reader;

    field $x   :reader;
    field $y   :reader;

    method set_ax($val) { $ax = $val }
    method set_ay($val) { $ay = $val }
    method set_bx($val) { $bx = $val }
    method set_by($val) { $by = $val }

    method set_x($val) { $x = $val }
    method set_y($val) { $y = $val }
}

MAIN: {
    my @machines;
    my $machine = Machine->new();
    while (my $line = <<>>) {
        chomp($line);
        if ($line eq "") {
            push @machines, $machine;
            $machine = Machine->new();
        } elsif ($line =~ /^Button/) {
            my ($button, $x, $y) = $line =~ /^Button ([AB]): X\+(\d+), Y\+(\d+)/;
            if ($button eq 'A') {
                $machine->set_ax($x);
                $machine->set_ay($y);
            } else {
                $machine->set_bx($x);
                $machine->set_by($y);
            }
        } else {
            my ($x, $y) = $line =~ /X=(\d+), Y=(\d+)/;
            $machine->set_x($x);
            $machine->set_y($y);
        }
    }
    push @machines, $machine;

    my $part1 = 0;
    my $part2;
    for $machine (@machines) {
        my @solutions = trial($machine);
        if (scalar(@solutions)) {
            $part1 += min map { $_->[0] * 3 + $_->[1] * 1 } @solutions;
        }
        $part2 += trial2($machine);
    }
    say "Part1: $part1";
    say "Part2: $part2";
}

sub trial($m) {
    my @solutions;

    for (my $a=0; $a<=100; $a++) {
        my $x1 = $m->x - $a * $m->ax;
        my $y1 = $m->y - $a * $m->ay;

        if ($x1 > $m->x) { last; }
        if ($y1 > $m->y) { last; }

        if (($x1 % $m->bx) == 0) {
            my $b = $x1 / $m->bx;

            if ($y1 / $m->by != $b) { next; }

            push @solutions, [$a, $b];
        }
    }
    return @solutions;
}

sub trial2($m) {
    # This took rediculously long.  Simultanious systems of equations
    # are not something that comes easily to someone whose
    # neurodivergence always transposes things.
    my $x = 10_000_000_000_000 + $m->x;
    my $y = 10_000_000_000_000 + $m->y;

    # Trying to use ax/ay/bx/by as I solve the equations...ya, nope. So
    # let's make it slightly easier.
    my $C = $m->ax;
    my $D = $m->ay;
    my $E = $m->bx;
    my $F = $m->by;

    my $a = ($F*$x - $E*$y) / ($C*$F - $D*$E);
    my $b = ($D*$x - $C*$y) / ($D*$E - $C*$F);
    if ((int($a) != $a) or (int($b) != $b)) {
        return 0;
    }

    # For some reason I thought it took 7 tokens for a and 3 for b.
    # Again, see my neurodivergence.
    return $a*3 + $b;
}

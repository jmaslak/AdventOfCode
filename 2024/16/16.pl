#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use lib '.';
use Table;

MAIN: {
    my $table = Table->new();
    $table->read(\*STDIN);

    my $start = $table->find_first('S');
    my $end   = $table->find_first('E');
    $table->put($start, '.');
    $table->put($end, '.');

    my $path = $table->copy();
    $path->fill('.');

    my $part1 = dijkstra($table, $start, $end, $path);
    say "Part 1: $part1";

    my (@coords) = $part1;
    my @stack;
    push @stack, [ $path, $table ];

    my %tested;

    while (@stack) {
        my $ele = shift @stack;
        my $p = $ele->[0];
        my $t = $ele->[1];
        for my $c ($p->find('O')) {
            if ($c->string eq $start->string or $c->string eq $end->string) { next }
            if (exists $tested{$c->string}) { next }

            $tested{$c->string} = 1;
            $t->put($c, '#');

            my $pathcopy = $p->copy();
            $pathcopy->fill('.');
            my $cost = dijkstra($t, $start, $end, $pathcopy);
            if ($cost == $part1) {
                push @stack, [ $pathcopy, $t->copy() ];
                for my $c1 ($pathcopy->find('O')) {
                    $path->put($c1, 'O');
                }
            }
            
            $t->put($c, '.');
        }
    }

    say "Part 2: " . scalar($path->find('O'));
}

sub dijkstra($t, $s, $e, $best) {
    my $costs = $t->copy();
    my $dirs  = $t->copy();
    for my $c ($t->find('.')) {
        $costs->put($c, 0);
    }
    $costs->fill(999_999_999_999_999);
    $costs->put($s, 0);
    $dirs->fill('>');

    my @stack;
    push @stack, $s;

    my (@directions) = ('^', 'v', '<', '>');
    while (@stack) {
        my $c = shift @stack;

        my $dir = $dirs->get($c);
        my $cost = $costs->get($c);

        my @costcalc;
        if ($dir eq '*') {
            @costcalc = (1, 1, 1, 1);
        } elsif ($dir eq '^') {
            @costcalc = (1, 99999, 1001, 1001);
        } elsif ($dir eq 'v') {
            @costcalc = (99999, 1, 1001, 1001);
        } elsif ($dir eq '<') {
            @costcalc = (1001, 1001, 1, 99999);
        } elsif ($dir eq '>') {
            @costcalc = (1001, 1001, 99999, 1);
        } else {
            die($dir);
        }

        # Up
        my $c1 = $c->n();
        if ($t->get($c1) eq '.') {
            if ($costs->get($c1) > $cost + $costcalc[0]) {
                $costs->put($c1, $cost + $costcalc[0]);
                $dirs->put($c1, '^');
                push @stack, $c1;
            }
        }
        # Down
        $c1 = $c->s();
        if ($t->get($c1) eq '.') {
            if ($costs->get($c1) > $cost + $costcalc[1]) {
                $costs->put($c1, $cost + $costcalc[1]);
                $dirs->put($c1, 'v');
                push @stack, $c1;
            }
        }
        # Left
        $c1 = $c->w();
        if ($t->get($c1) eq '.') {
            if ($costs->get($c1) > $cost + $costcalc[2]) {
                $costs->put($c1, $cost + $costcalc[2]);
                $dirs->put($c1, '<');
                push @stack, $c1;
            }
        }
        # Right
        $c1 = $c->e();
        if ($t->get($c1) eq '.') {
            if ($costs->get($c1) > $cost + $costcalc[3]) {
                $costs->put($c1, $cost + $costcalc[3]);
                $dirs->put($c1, '>');
                push @stack, $c1;
            }
        }
    }

    if ($costs->get($e) >= 999_999_999_999_999) {
        return 999_999_999_999_999;;
    }

    # Find path
    my $c = $e;
    $best->put($s, 'O');
    while ($c->row != $s->row or $c->col != $s->col) {
        $best->put($c, 'O');
        my $dir = $dirs->get($c);
        if ($dir eq '^') {
            $c = $c->s();
        } elsif ($dir eq 'v') {
            $c = $c->n();
        } elsif ($dir eq '<') {
            $c = $c->e();
        } else {
            $c = $c->w();
        }
    }

    return $costs->get($e);
}


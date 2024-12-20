#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use lib '.';
use Table;
use List::Util qw(first);

my $MAX = 999_999_999_999;

sub dijkstra ( $table, $start, $end ) {
    my $t = $table->copy();
    my (@stack) = ($start);
    $t->put( $start, 0 );

    while (@stack) {
        my $pos         = shift @stack;
        my $val         = $t->get($pos);
        my (@neighbors) = $t->neighbors( $pos, 0 );

        for my $n (@neighbors) {
            my $c = $t->get($n);
            if ( $c eq '#' ) { next }
            if ( $c eq '.' ) { $c = $MAX }

            if ( $val + 1 < $c ) {
                $t->put( $n, $val + 1 );
                push @stack, $n;
            }
        }
    }

    my $cost = $t->get($end);
    if ( $cost eq '.' ) { return; }
    return $t;
}

MAIN: {
    if ( scalar(@ARGV) != 2 ) {
        say "USAGE: perl 20.pl <threshold> <cheat-len>";
        say "  Example: perl 20.pl 100 2   (for part 1)";
        exit 1;
    }

    my $table = Table->new();
    $table->read( \*STDIN );

    my $start = first { 1 } $table->find('S');
    my $end   = first { 1 } $table->find('E');

    $table->put( $start, '.' );
    $table->put( $end,   '.' );

    my (@empties) = $table->find('.');

    my $t1   = dijkstra( $table, $start, $end );
    my $t2   = dijkstra( $table, $end,   $start );
    my $time = $t1->get($end);

    my $count = 0;
    for my $first (@empties) {
        for my $second ( grep { $first->dist($_) <= $ARGV[1] } @empties ) {
            my $dist = $first->dist($second);

            my $newtime = $t1->get($first) + $dist + $t2->get($second);
            my $saved   = $time - $newtime;
            if ( $saved < $ARGV[0] ) { next }

            if ( $saved >= $ARGV[0] ) { $count++; }
        }
    }

    say "Solution: $count";

}

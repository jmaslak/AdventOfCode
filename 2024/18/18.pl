#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use lib '.';
use Table;
use Parallel::WorkUnit;
use Sys::CpuAffinity;
use IPC::Semaphore;
use IPC::SysV  qw(S_IRUSR S_IWUSR IPC_CREAT IPC_PRIVATE);
use List::Util qw(min);

my $MAX = 999_999_999_999;

sub dijkstra ( $table, $startx, $starty, $endx, $endy ) {
    my $t = $table->copy();
    my (@stack) = ( Coord->new( row => $startx, col => $starty ) );
    $t->put( $stack[0], 0 );

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

    my $cost = $t->get_xy( $endx, $endy );
    if ( $cost eq '.' ) { return undef; }
    return $cost;
}

sub tryit ( $t, $falling, $procs, $instance ) {
    my $count = 1024;

    my $part2 = undef;
    for ( my $i = $count; $i < scalar(@$falling); $i++ ) {
        my $c = Coord->new( row => $falling->[$i]->[1], col => $falling->[$i]->[0] );
        $t->put( $c, "#" );

        if ( ( $i % $procs ) != $instance ) { next; }

        my $cost = dijkstra( $t, 0, 0, $t->row_count - 1, $t->col_count - 1 );
        if ( !defined($cost) ) {
            $part2 = $i;
            last;
        }
    }

    return $part2;
}

MAIN: {
    my $count = 1024;

    my $table = Table->new();
    while ( <<>> ) {
        chomp();
        if ( $_ eq '' ) { last }

        my ( $cols, $rows ) = /(\d+),(\d+)/;
        $table->put_xy( $rows, $cols, '.' );
        $table->fill('.');
    }

    my @falling;
    while ( <<>> ) {
        chomp;
        my ( $col, $row ) = /(\d+),(\d+)/;
        push @falling, [ $row, $col ];
    }

    for ( my $i = 0; $i < $count; $i++ ) {
        $table->put_xy( $falling[$i]->[1], $falling[$i]->[0], '#' );
    }

    my $part1 = dijkstra( $table, 0, 0, $table->row_count - 1, $table->col_count - 1 );
    say "Part 1: $part1";

    my $wu = Parallel::WorkUnit->new();
    $wu->max_children( Sys::CpuAffinity::getNumCpus() );

    my @data = 0 .. ( ( $wu->max_children ) - 1 );
    $wu->queueall( \@data,
        sub ($instance) { tryit( $table, \@falling, $wu->max_children, $instance ) } );
    my (@results) = $wu->waitall();
    my $part2 = min grep { defined } @results;

    say "Part 2: " . $falling[$part2]->[0] . ',' . $falling[$part2]->[1];
}


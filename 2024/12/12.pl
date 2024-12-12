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
    $table->read( \*STDIN );
    $table->add_border('.');

    my $visited = $table->copy();
    $visited->fill('.');

    my $working = $table->copy();

    my $part1 = 0;
    my $part2 = 0;
    for ( my $i = 1; $i < $table->row_count - 1; $i++ ) {
        for ( my $j = 1; $j < $table->col_count - 1; $j++ ) {
            if ( $visited->get_xy( $i, $j ) eq 'x' ) { next }

            my ( $border, $area, $sides ) = find_area( $table, $visited, $i, $j );

            $part1 += $border * $area;
            $part2 += $sides * $area;
        }
    }

    say "Part 1: $part1";
    say "Part 2: $part2";
}

sub find_area( $table, $visited, $row, $col ) {
    my @stack;
    push @stack, Coord->new( row => $row, col => $col );

    my $border = 0;
    my $area   = 0;
    my $sides  = 0;
    my $char   = $table->get_xy( $row, $col );

    my $sidet = $table->copy();
    $sidet->fill('.');

    while ( scalar(@stack) ) {
        my $coord = pop @stack;

        if ( $visited->get($coord) eq 'x' ) { next; }
        $visited->put( $coord, 'x' );
        $area++;

        my %movedir = (
            n => 'e',
            s => 'e',
            e => 's',
            w => 's',
        );

      NEXTDIR: for my $dir ( 'n', 's', 'e', 'w' ) {
            my $c1      = $coord;
            my $c2      = $coord->get_dir($dir);
            my $val1    = $table->get($c1);
            my $val2    = $table->get($c2);
            my $valside = $sidet->get($c2);

            if ( $val2 eq $char )               { next; }
            if ( index( $valside, $dir ) >= 0 ) { next; }

            $sides++;

            while ( ( $val1 eq $char ) and ( $val2 ne $char ) ) {
                if ( index( $valside, $dir ) >= 0 ) {
                    $sides--;
                    next NEXTDIR;
                }
                $sidet->put( $c2, "$valside$dir" );

                $c1      = $c1->get_dir( $movedir{$dir} );
                $c2      = $c2->get_dir( $movedir{$dir} );
                $val1    = $table->get($c1);
                $val2    = $table->get($c2);
                $valside = $sidet->get($c2);
            }
        }

        my (@neighbors) = $table->neighbors( $coord, 0 );
        for my $neighbor (@neighbors) {
            if ( $table->get($neighbor) eq $char ) {
                push @stack, $neighbor;
            } else {
                $border++;
            }
        }
    }

    return ( $border, $area, $sides );
}


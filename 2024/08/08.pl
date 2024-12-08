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

    my $antinodes = find_antinodes($table);
    say "Part1: " . scalar($antinodes->@*);

    my $inline = find_inline($table);
    say "Part2: " . scalar($inline->@*);
}

sub find_antennae($table) {
    my %antennae;
    for (my $row=0; $row < $table->row_count(); $row++) {
        for (my $col=0; $col < $table->col_count(); $col++) {
            my $coord = Coord->new(row => $row, col => $col);
            my $c = $table->get($coord);
            if ($c ne '.') {
                if (!exists($antennae{$c})) {
                    $antennae{$c} = [];
                }
                push $antennae{$c}->@*, $coord
            }
        }
    }
    return \%antennae;
}

sub find_antinodes($table) {
    my $antennae = find_antennae($table);
    my $antinodes = $table->copy();

    for my $ant (values $antennae->%*) {
        for (my $first=0; $first < scalar($ant->@*)-1; $first++) {
            for (my $second=$first + 1; $second < scalar($ant->@*); $second++) {
                my $i = $ant->[$first];
                my $j = $ant->[$second];

                my $delta_row = $j->row() - $i->row();
                my $delta_col = $j->col() - $i->col();

                my $row1 = $i->row() - $delta_row;
                my $row2 = $j->row() + $delta_row;

                my $col1 = $i->col() - $delta_col;
                my $col2 = $j->col() + $delta_col;

                if (($row1 >= 0) && ($row1 < $table->row_count()) &&
                    ($col1 >= 0) && ($col1 < $table->col_count())) {
                    $antinodes->put_xy($row1, $col1, '#');
                }
                if (($row2 >= 0) && ($row2 < $table->row_count()) &&
                    ($col2 >= 0) && ($col2 < $table->col_count())) {
                    $antinodes->put_xy($row2, $col2, '#');
                }
            }
        }
    }
    return [ $antinodes->find("#") ];
}

sub find_inline($table) {
    my $antennae = find_antennae($table);
    my $inline = $table->copy();

    for my $ant (values $antennae->%*) {
        for (my $first=0; $first < scalar($ant->@*)-1; $first++) {
            for (my $second=$first + 1; $second < scalar($ant->@*); $second++) {
                my $i = $ant->[$first];
                my $j = $ant->[$second];

                my $delta_row = $j->row() - $i->row();
                my $delta_col = $j->col() - $i->col();

                my $gcd = gcd($delta_row, $delta_col);
                $delta_row /= $gcd;
                $delta_col /= $gcd;

                my $row = $i->row();
                my $col = $i->col();

                while (($row >= 0) && ($row < $table->row_count()) &&
                       ($col >= 0) && ($col < $table->col_count())) {

                    $inline->put_xy($row, $col, '#');
                    $row -= $delta_row;
                    $col -= $delta_col;
                }

                my $row = $i->row() + $delta_row;
                my $col = $i->col() + $delta_col;

                while (($row >= 0) && ($row < $table->row_count()) &&
                       ($col >= 0) && ($col < $table->col_count())) {

                    $inline->put_xy($row, $col, '#');
                    $row += $delta_row;
                    $col += $delta_col;
                }
            }
        }
    }
    return [ $inline->find("#") ];
}

sub gcd ( $i, $j ) {
    if ( $j == 0 ) { return $i; }
    return gcd( $j, $i % $j );
}

#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

class Coord {
    field $row : param;
    field $col : param;

    method row() {
        return $row;
    }

    method col() {
        return $col;
    }

    method set ( $r, $c ) {
        $row = $r;
        $col = $c;
    }

    method n() {
        return Coord->new( row => $row - 1, col => $col );
    }

    method s() {
        return Coord->new( row => $row + 1, col => $col );
    }

    method e() {
        return Coord->new( row => $row, col => $col + 1 );
    }

    method w() {
        return Coord->new( row => $row, col => $col - 1 );
    }
}

class Table {
    field @rows;

    method row_count() {
        return scalar(@rows);
    }

    method col_count() {
        my $max = 0;
        for my $row (@rows) {
            if ( scalar( $row->@* ) > $max ) {
                $max = scalar( $row->@* );
            }
        }
        return $max;
    }

    method put ( $coord, $node ) {
        my $col = $coord->col();
        my $row = $coord->row();

        $self->put_xy( $row, $col, $node );
    }

    method put_xy ( $x, $y, $node ) {
        my $row = $x;
        my $col = $y;

        for ( my $i = $self->row_count(); $i <= $row; $i++ ) {
            $rows[$i] = [];
        }
        $rows[$row]->[$col] = $node;
    }

    method get ($coord) {
        my $col = $coord->col();
        my $row = $coord->row();

        $self->get_xy( $row, $col );
    }

    method get_xy ( $x, $y ) {
        my $row = $x;
        my $col = $y;

        if ( $row >= $self->row_count() ) {
            return undef;
        }
        if ( $col >= scalar( $rows[$row]->@* ) ) {
            return undef;
        }

        return $rows[$row]->[$col];
    }

    method row ($r) {
        return $rows[$r];
    }

    method rows() {
        return @rows;
    }

    method add_border ($node) {
        my $row_count = $self->row_count();
        my $col_count = $self->col_count();

        my @new_rows;
        for ( my $i = 0; $i < $row_count + 2; $i++ ) {
            $new_rows[$i] = [];
            for ( my $j = 0; $j < $col_count + 2; $j++ ) {

                if ( $i == 0 or $i == $row_count + 1 ) {
                    # Top or bottom
                    $new_rows[$i]->[$j] = $node;
                } elsif ( $j == 0 or $j == $col_count + 1 ) {
                    # Left or right
                    $new_rows[$i]->[$j] = $node;
                } else {
                    my $data = $self->get_xy( $i - 1, $j - 1 );
                    $new_rows[$i]->[$j] = $data;
                }
            }
        }
        @rows = @new_rows;
    }

    method print_table ( $format = "%s", $default = undef ) {
        for ( my $i = 0; $i < $self->row_count(); $i++ ) {
            for ( my $j = 0; $j < $self->col_count(); $j++ ) {
                my $c = $self->get_xy( $i, $j ) // $default;
                printf( $format, $c );
            }
            say("");
        }
    }
}

1;
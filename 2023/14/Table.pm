#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use Storable;

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

    method print() {
        say $row . ", " . $col;
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

    method put_row ( $x, $row ) {
        for ( my $i = 0; $i < scalar(@$row); $i++ ) {
            $self->put_xy( $x, $i, $row->[$i] );
        }
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
            return;
        }
        if ( $col >= scalar( $rows[$row]->@* ) ) {
            return;
        }

        return $rows[$row]->[$col];
    }

    method get_row ($x) {
        if ( $x >= $self->row_count() ) {
            return;
        }
        return $rows[$x]->@*;
    }

    method get_col ($y) {
        my @col;
        if ( $y >= $self->col_count() ) {
            return;
        }
        for my $row (@rows) {
            push @col, $row->[$y];
        }
        return @col;
    }

    method row ($r) {
        return $rows[$r];
    }

    method rows() {
        return @rows;
    }

    method get_matching_coords ($sub) {
        my @ret;
        for ( my $i = 0; $i < $self->row_count(); $i++ ) {
            for ( my $j = 0; $j < $self->col_count(); $j++ ) {
                if ( $sub->( $rows[$i]->[$j] ) ) {
                    push @ret, Coord->new( row => $i, col => $j );
                }
            }
        }
        return @ret;
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

    method neighbors ( $coord, $include_diagonals ) {
        my @out;

        if ( $coord->n()->row() >= 0 ) {
            push @out, $coord->n();
        }
        if ( $coord->s()->row() < $self->row_count() ) {
            push @out, $coord->s();
        }
        if ( $coord->w()->col() >= 0 ) {
            push @out, $coord->w();
        }
        if ( $coord->e()->col() < $self->col_count() ) {
            push @out, $coord->e();
        }

        if ($include_diagonals) {
            my $node;
            $node = $coord->n()->w();
            if ( $node->row() >= 0 and $node->col() >= 0 ) {
                push @out, $node;
            }
            $node = $coord->n()->e();
            if ( $node->row() >= 0 and $node->col() < $self->col_count() ) {
                push @out, $node;
            }
            $node = $coord->s()->w();
            if ( $node->row() < $self->row_count() and $node->col() >= 0 ) {
                push @out, $node;
            }
            $node = $coord->s()->e();
            if ( $node->row() < $self->row_count() and $node->col() < $self->col_count() ) {
                push @out, $node;
            }
        }

        return @out;
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

    method copy ( $deep_copy = undef ) {
        my $t = Table->new();
        for ( my $i = 0; $i < $self->row_count(); $i++ ) {
            for ( my $j = 0; $j < $self->col_count(); $j++ ) {
                my $val = $self->get_xy( $i, $j );
                if ( $deep_copy and ref $val ) {
                    $val = Storable::dclone($val);
                }
                $t->put_xy( $i, $j, $val );
            }
        }
        return $t;
    }

    method copy_swap_xy ( $deep_copy = undef ) {
        my $t = Table->new();
        $t->print_table();
        say "";
        for ( my $i = 0; $i < $self->row_count(); $i++ ) {
            $t->print_table();
            say "";
            for ( my $j = 0; $j < $self->col_count(); $j++ ) {
                my $val = $self->get_xy( $i, $j );
                if ( $deep_copy and ref $val ) {
                    $val = Storable::dclone($val);
                }
                $t->put_xy( $j, $i, $val );
            }
        }
        return $t;
    }

    method read ( $fh, $code = sub { split // } ) {
        @rows = ();
        while (<$fh>) {
            chomp;
            push @rows, [ $code->($_) ];
        }
        close($fh);
    }

}

1;

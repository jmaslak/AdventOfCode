#!/usr/bin/perl

#
# Copyright (C) 2023-2024 Joelle Maslak
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

    method ne() {
        return Coord->new( row => $row - 1, col => $col + 1);
    }

    method se() {
        return Coord->new( row => $row + 1, col => $col + 1);
    }

    method nw() {
        return Coord->new( row => $row - 1, col => $col - 1);
    }

    method sw() {
        return Coord->new( row => $row + 1, col => $col - 1);
    }

    method print() { say $self->string() }

    method string() { "$row,$col" }
}

class Table {
    use List::Util qw(max);

    field @rows;
    field $_col_count = 0;
    field $_row_count = 0;

    method row_count() { $_row_count }

    method col_count() { $_col_count }

    method is_in_bounds_xy($row, $col) {
        if ($row < 0) { return undef }
        if ($col < 0) { return undef }
        if ($row >= $_row_count) { return undef }
        if ($col >= $_col_count) { return undef }

        return 1;
    }

    method is_in_bounds($coord) {
        if ($coord->row() < 0) { return undef }
        if ($coord->col() < 0) { return undef }
        if ($coord->row() >= $_row_count) { return undef }
        if ($coord->col() >= $_col_count) { return undef }

        return 1;
    }

    method put ( $coord, $node ) {
        my $col = $coord->col();
        my $row = $coord->row();

        $self->put_xy( $row, $col, $node );
    }

    method put_xy ( $row, $col, $node ) {
        for ( my $i = $_row_count; $i <= $row; $i++ ) {
            $rows[$i] = [];
        }
        $rows[$row]->[$col] = $node;
        if ( $row + 1 > $_row_count ) { $_row_count = $row + 1; }
        if ( $col + 1 > $_col_count ) { $_col_count = $col + 1; }
    }

    method put_row ( $x, $row ) {
        for ( my $i = 0; $i < scalar(@$row); $i++ ) {
            $self->put_xy( $x, $i, $row->[$i] );
        }
        $_col_count = max scalar(@$row), $_col_count;
        $_row_count = max $x + 1, $_row_count;
    }

    method get ($coord) {
        my $col = $coord->col();
        my $row = $coord->row();

        $self->get_xy( $row, $col );
    }

    method get_xy ( $row, $col ) {
        if ( $row >= $_row_count ) {
            return undef;
        }
        if ( $col >= scalar( $rows[$row]->@* ) ) {
            return undef;
        }

        return $rows[$row]->[$col];
    }

    method get_row ($x) {
        if ( $x >= $_row_count ) {
            return;
        }
        return $rows[$x]->@*;
    }

    method get_col ($y) {
        my @col;
        if ( $y >= $_col_count ) {
            return undef;
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
        for ( my $i = 0; $i < $_row_count; $i++ ) {
            for ( my $j = 0; $j < $_col_count; $j++ ) {
                if ( $sub->( $rows[$i]->[$j] ) ) {
                    push @ret, Coord->new( row => $i, col => $j );
                }
            }
        }
        return @ret;
    }

    method add_border ($node) {
        my @new_rows;
        for ( my $i = 0; $i < $_row_count + 2; $i++ ) {
            $new_rows[$i] = [];
            for ( my $j = 0; $j < $_col_count + 2; $j++ ) {

                if ( $i == 0 or $i == $_row_count + 1 ) {
                    # Top or bottom
                    $new_rows[$i]->[$j] = $node;
                } elsif ( $j == 0 or $j == $_col_count + 1 ) {
                    # Left or right
                    $new_rows[$i]->[$j] = $node;
                } else {
                    my $data = $self->get_xy( $i - 1, $j - 1 );
                    $new_rows[$i]->[$j] = $data;
                }
            }
        }
        @rows = @new_rows;
        $_row_count += 2;
        $_col_count += 2;
    }

    method neighbors ( $coord, $include_diagonals ) {
        my (@c) = ( $coord->row(), $coord->col() );

        if ($include_diagonals) {
            return map { Coord->new( row => $_->[0], col => $_->[1] ) }
              grep { $_->[1] >= 0 and $_->[1] < $_col_count }
              grep { $_->[0] >= 0 and $_->[0] < $_row_count }
              map  { [ $c[0] + $_->[0], $c[1] + $_->[1] ] }
              [ -1,  0 ], [  1, 0 ], [ 0, -1 ], [ 0, 1 ],
              [ -1, -1 ], [ -1, 1 ], [ 1, -1 ], [ 1, 1 ];
        } else {
            return map { Coord->new( row => $_->[0], col => $_->[1] ) }
              grep { $_->[1] >= 0 and $_->[1] < $_col_count }
              grep { $_->[0] >= 0 and $_->[0] < $_row_count }
              map { [ $c[0] + $_->[0], $c[1] + $_->[1] ] }
              [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ];
        }
    }

    method neighbors_xy ( $row, $col, $include_diagonals ) {
        if ($include_diagonals) {
            return
              map  { Coord->new( row => $_->[0], col => $_->[1] ) }
              grep { $_->[1] >= 0 and $_->[1] < $_col_count }
              grep { $_->[0] >= 0 and $_->[0] < $_row_count }
              map  { [ $row  + $_->[0], $col + $_->[1] ] }
              [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ];
        } else {
            return
              grep { $_->[1] >= 0 and $_->[1] < $_col_count }
              grep { $_->[0] >= 0 and $_->[0] < $_row_count }
              map  { [ $row  + $_->[0], $col + $_->[1] ] }
              [ -1,  0 ], [  1, 0 ], [ 0, -1 ], [ 0, 1 ],
              [ -1, -1 ], [ -1, 1 ], [ 1, -1 ], [ 1, 1 ];
        }
    }

    method print_table ( $format = "%s", $default = undef ) {
        for ( my $i = 0; $i < $_row_count; $i++ ) {
            for ( my $j = 0; $j < $_col_count; $j++ ) {
                my $c = $self->get_xy( $i, $j ) // $default;
                printf( $format, $c );
            }
            say("");
        }
    }

    method copy ( $deep_copy = undef ) {
        my $t = Table->new();
        for ( my $i = 0; $i < $_row_count; $i++ ) {
            for ( my $j = 0; $j < $_col_count; $j++ ) {
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
        for ( my $i = 0; $i < $_row_count; $i++ ) {
            for ( my $j = 0; $j < $_col_count; $j++ ) {
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
        @rows       = ();
        $_row_count = $_col_count = 0;
        while (<$fh>) {
            chomp;
            push @rows, [ $code->($_) ];
            $_row_count++;
            $_col_count = max scalar( $rows[-1]->@* ), $_col_count;
        }
        close($fh);
    }

    method get_all_runs_from_xy($row, $col, $len) {
        # Returns word run that is $len long centered at $row, $col
        # Returns:
        #   [0] = NW
        #   [1] = N
        #   [2] = NE
        #   [3] = W
        #   [4] = E
        #   [5] = SW
        #   [6] = S
        #   [7] = SE
        my @words;
        @words[7] = undef;

        if ($row + 1 - $len >= 0) {
            # N
            $words[1] = $self->get_word_xy($len, $row, $col, -1, 0);
            if ($col + 1 - $len >= 0) {
                # NW
                $words[0] = $self->get_word_xy($len, $row, $col, -1, -1);
            }
            if ($col + $len <= $_col_count) {
                # NE
                $words[2] = $self->get_word_xy($len, $row, $col, -1, +1);
            }
        }
        if ($row + $len <= $_row_count) {
            # S
            $words[6] = $self->get_word_xy($len, $row, $col, +1, 0);
            if ($col + 1 - $len >= 0) {
                # SW
                $words[5] = $self->get_word_xy($len, $row, $col, +1, -1);
            }
            if ($col + $len <= $_col_count) {
                # SE
                $words[7] = $self->get_word_xy($len, $row, $col, +1, +1);
            }
        }
        if ($col + 1 - $len >= 0) {
            # W
            $words[3] = $self->get_word_xy($len, $row, $col, 0, -1);
        }
        if ($col + $len <= $_col_count) {
            # E
            $words[4] = $self->get_word_xy($len, $row, $col, 0, +1);
        }

        return @words;
    }

    method get_word_xy($len, $row, $col, $delta_row, $delta_col) {
        my $word = "";
        for (my $i=0; $i < $len; $i++) {
            $word .= $self->get_xy($row, $col);
            $row += $delta_row;
            $col += $delta_col;
        }
        return $word;
    }

    method find($value) {
        my @return;
        for (my $row=0; $row < $_row_count; $row++) {
            for (my $col=0; $col < $_col_count; $col++) {
                if ($self->get_xy($row, $col) eq $value) {
                    push @return, Coord->new(row => $row, col => $col);
                }
            }
        }
        return @return;
    }
}

1;

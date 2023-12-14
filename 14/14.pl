#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;

use Data::Dump;
use List::Util qw(sum);
use Memoize;

MAIN: {
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );
    my $t1 = $t->copy();

    my $d = 0;
    tilt( $t, $d );
    say( "Sum part A: " . weigh($t) );

    my %cycles;
    my @outs;
    push @outs, 'x';
    my $c = 0;
    while (1) {
        $c++;
        cycle($t1);
        my $str = join '', map { join '', $_->@* } $t1->rows();
        if ( exists( $cycles{$str} ) ) {
            my $start  = $cycles{$str};
            my $period = $c - $cycles{$str};
            my $equiv  = $start + ( 1000000000 - $start ) % $period;
            say "Sum part B: " . weigh( $outs[$equiv] );
            last;
        }
        $cycles{$str} = $c;
        push @outs, $t1->copy();
    }
}

sub cycle ($t) {
    map { tilt( $t, $_ ) } 0 .. 3;
    return;
}

sub tilt ( $t, $dir ) {
    my $maxr = $t->row_count();
    my $maxc = $t->col_count();

    if ( ( $dir % 4 ) == 0 ) {
        for ( my $col = 0; $col < $maxc; $col++ ) {
            my $newrow = 0;
            for ( my $row = 0; $row < $maxr; $row++ ) {
                if ( $t->get_xy( $row, $col ) eq '.' ) {
                } elsif ( $t->get_xy( $row, $col ) eq '#' ) {
                    $newrow = $row + 1;
                } elsif ( $t->get_xy( $row, $col ) eq 'O' ) {
                    $t->put_xy( $row,    $col, '.' );
                    $t->put_xy( $newrow, $col, 'O' );
                    $newrow++;
                }
            }
        }
    } elsif ( ( $dir % 4 ) == 1 ) {
        for ( my $row = 0; $row < $maxr; $row++ ) {
            my $newcol = 0;
            for ( my $col = 0; $col < $maxc; $col++ ) {
                if ( $t->get_xy( $row, $col ) eq '.' ) {
                } elsif ( $t->get_xy( $row, $col ) eq '#' ) {
                    $newcol = $col + 1;
                } elsif ( $t->get_xy( $row, $col ) eq 'O' ) {
                    $t->put_xy( $row, $col,    '.' );
                    $t->put_xy( $row, $newcol, 'O' );
                    $newcol++;
                }
            }
        }
    } elsif ( ( $dir % 4 ) == 2 ) {
        for ( my $col = 0; $col < $maxc; $col++ ) {
            my $newrow = $maxr - 1;
            for ( my $row = $maxr - 1; $row >= 0; $row-- ) {
                if ( $t->get_xy( $row, $col ) eq '.' ) {
                } elsif ( $t->get_xy( $row, $col ) eq '#' ) {
                    $newrow = $row - 1;
                } elsif ( $t->get_xy( $row, $col ) eq 'O' ) {
                    $t->put_xy( $row,    $col, '.' );
                    $t->put_xy( $newrow, $col, 'O' );
                    $newrow--;
                }
            }
        }
    } elsif ( ( $dir % 4 ) == 3 ) {
        for ( my $row = 0; $row < $maxr; $row++ ) {
            my $newcol = $maxc - 1;
            for ( my $col = $maxc - 1; $col >= 0; $col-- ) {
                if ( $t->get_xy( $row, $col ) eq '.' ) {
                } elsif ( $t->get_xy( $row, $col ) eq '#' ) {
                    $newcol = $col - 1;
                } elsif ( $t->get_xy( $row, $col ) eq 'O' ) {
                    $t->put_xy( $row, $col,    '.' );
                    $t->put_xy( $row, $newcol, 'O' );
                    $newcol--;
                }
            }
        }
    }
    return;
}

sub weigh ($t) {
    my @weights;
    my $maxr = $t->row_count;
    for ( my $col = 0; $col < $t->col_count(); $col++ ) {
        my (@line) = $t->get_col($col);
        $weights[$col] = 0;

        my $pos = 0;
        for my $c (@line) {
            if ( $c eq '.' ) {
            } elsif ( $c eq '#' ) {
            } elsif ( $c eq 'O' ) {
                $weights[$col] += $maxr - $pos;
            }
            $pos++;
        }
    }
    return sum(@weights);
}

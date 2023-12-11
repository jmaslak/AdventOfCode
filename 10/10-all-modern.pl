#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;
use Data::Dump;

MAIN: {
    my $t   = Table->new();
    my $row = 0;
    while ( my $line = <<>> ) {
        my $col = 0;
        chomp($line);
        for my $c ( split //, $line ) {
            $t->put_xy( $row, $col, $c );
            $col++;
        }
        $row++;
    }
    $t->add_border('.');

    my $max = -1;

    # Find "S" & initialize dist
    my $start;
    my $dist = Table->new();
    for ( my $row = 0; $row < $t->row_count(); $row++ ) {
        for ( my $col = 0; $col < $t->col_count; $col++ ) {
            $dist->put_xy( $row, $col, $max );
            if ( $t->get_xy( $row, $col ) eq "S" ) {
                $start = Coord->new( row => $row, col => $col );
                $dist->put( $start, 0 );
            }
        }
    }

    my @stack;
    my $up = $t->get( $start->n() );
    if ( $up eq '|' or $up eq '7' or $up eq 'F' ) {
        push @stack, [ 1, $start->n() ];
    }
    my $dn = $t->get( $start->s() );
    if ( $dn eq '|' or $dn eq 'L' or $dn eq 'J' ) {
        push @stack, [ 1, $start->s() ];
    }
    my $lt = $t->get( $start->w() );
    if ( $lt eq '-' or $lt eq 'L' or $lt eq 'F' ) {
        push @stack, [ 1, $start->w() ];
    }
    my $rt = $t->get( $start->e() );
    if ( $rt eq '-' or $rt eq '7' or $rt eq 'J' ) {
        push @stack, [ 1, $start->e() ];
    }

    while ( scalar(@stack) ) {
        my ( $d, $coord ) = @{ shift @stack };
        if ( $dist->get($coord) == -1 or $dist < $dist->get($coord) ) {
            $dist->put( $coord, $d );
            my $char = $t->get($coord);
            $d++;
            if ( $char eq '-' ) {
                push @stack, [ $d, $coord->w() ];
                push @stack, [ $d, $coord->e() ];
            } elsif ( $char eq '|' ) {
                push @stack, [ $d, $coord->n() ];
                push @stack, [ $d, $coord->s() ];
            } elsif ( $char eq 'J' ) {
                push @stack, [ $d, $coord->n() ];
                push @stack, [ $d, $coord->w() ];
            } elsif ( $char eq '7' ) {
                push @stack, [ $d, $coord->s() ];
                push @stack, [ $d, $coord->w() ];
            } elsif ( $char eq 'F' ) {
                push @stack, [ $d, $coord->e() ];
                push @stack, [ $d, $coord->s() ];
            } elsif ( $char eq 'L' ) {
                push @stack, [ $d, $coord->e() ];
                push @stack, [ $d, $coord->n() ];
            }
        }
    }

    my $steps = 0;
    for ( my $row = 0; $row < $t->row_count(); $row++ ) {
        for ( my $col = 0; $col < $t->col_count(); $col++ ) {
            if ( $dist->get_xy( $row, $col ) > $steps ) {
                $steps = $dist->get_xy( $row, $col );
            }
        }
    }

    # The "Distances" can be used to determine the loop parameter.
    # As can anywhere with a non-dot.

    my $expanded = Table->new();
    for ( my $i = 0; $i < $dist->row_count(); $i++ ) {
        for ( my $j = 0; $j < $dist->col_count(); $j++ ) {
            $expanded->put_xy( $i * 2,     $j * 2,     ' ' );
            $expanded->put_xy( $i * 2,     $j * 2 + 1, ' ' );
            $expanded->put_xy( $i * 2 + 1, $j * 2,     ' ' );
            $expanded->put_xy( $i * 2 + 1, $j * 2 + 1, ' ' );
            if ( $dist->get_xy( $i, $j ) >= 0 ) {
                $expanded->put_xy( $i * 2, $j * 2, $t->get_xy( $i, $j ) );
                my $char = $t->get_xy( $i, $j );
                if ( $char eq '-' ) {
                    $expanded->put_xy( $i * 2, $j * 2 - 1, '-' );
                    $expanded->put_xy( $i * 2, $j * 2 + 1, '-' );
                } elsif ( $char eq '|' ) {
                    $expanded->put_xy( $i * 2 - 1, $j * 2, '|' );
                    $expanded->put_xy( $i * 2 + 1, $j * 2, '|' );
                } elsif ( $char eq 'J' ) {
                    $expanded->put_xy( $i * 2 - 1, $j * 2,     '|' );
                    $expanded->put_xy( $i * 2,     $j * 2 - 1, '-' );
                } elsif ( $char eq '7' ) {
                    $expanded->put_xy( $i * 2,     $j * 2 - 1, '-' );
                    $expanded->put_xy( $i * 2 + 1, $j * 2,     '|' );
                } elsif ( $char eq 'F' ) {
                    $expanded->put_xy( $i * 2 + 1, $j * 2,     '|' );
                    $expanded->put_xy( $i * 2,     $j * 2 + 1, '-' );
                } elsif ( $char eq 'L' ) {
                    $expanded->put_xy( $i * 2 - 1, $j * 2,     '|' );
                    $expanded->put_xy( $i * 2,     $j * 2 + 1, '-' );
                }
            }
        }
    }

    (@stack) = ();
    push @stack, Coord->new( row => 0, col => 0 );

    while ( scalar(@stack) ) {
        my $coord = shift @stack;
        if ( $expanded->get($coord) eq ' ' ) {
            $expanded->put( $coord, 'O' );

            push @stack, Coord->new( row => $coord->row(),     col => $coord->col() - 1 );
            push @stack, Coord->new( row => $coord->row(),     col => $coord->col() + 1 );
            push @stack, Coord->new( row => $coord->row() - 1, col => $coord->col() );
            push @stack, Coord->new( row => $coord->row() + 1, col => $coord->col() );
        }
    }

    my $inside = 0;
    for ( my $i = 0; $i < $expanded->row_count(); $i += 2 ) {
        for ( my $j = 0; $j < $expanded->col_count(); $j += 2 ) {
            if ( $expanded->get_xy( $i, $j ) eq ' ' ) {
                $inside++;
            }
        }
    }

    say("Steps: $steps");
    say("Inside: $inside");
}

#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my @rows;
    while ( my $line = <<>> ) {
        chomp($line);
        push @rows, [ split //, ".$line." ];
    }
    my @out;
    for ( my $x = 0; $x < scalar( $rows[0]->@* ); $x++ ) {
        push @out, ".";
    }
    push @rows, [@out];
    unshift @rows, [@out];

    my $max = -1;

    # Find "S" & initialize dist
    my $start_row;
    my $start_col;
    my @dist;
    for ( my $row = 0; $row < scalar(@rows); $row++ ) {
        for ( my $col = 0; $col < scalar( $rows[0]->@* ); $col++ ) {
            push $dist[$row]->@*, $max;
            if ( $rows[$row]->[$col] eq "S" ) {
                $start_row          = $row;
                $start_col          = $col;
                $dist[$row]->[$col] = 0;
            }
        }
    }

    my @stack;
    my $up = $rows[ $start_row - 1 ]->[$start_col];
    if ( $up eq '|' or $up eq '7' or $up eq 'F' ) {
        push @stack, [ 1, $start_row - 1, $start_col ];
    }
    my $dn = $rows[ $start_row + 1 ]->[$start_col];
    if ( $dn eq '|' or $dn eq 'L' or $dn eq 'J' ) {
        push @stack, [ 1, $start_row + 1, $start_col ];
    }
    my $lt = $rows[$start_row]->[ $start_col - 1 ];
    if ( $lt eq '-' or $lt eq 'L' or $lt eq 'F' ) {
        push @stack, [ 1, $start_row, $start_col - 1 ];
    }
    my $rt = $rows[$start_row]->[ $start_col + 1 ];
    if ( $rt eq '-' or $rt eq '7' or $rt eq 'J' ) {
        push @stack, [ 1, $start_row, $start_col + 1 ];
    }

    while ( scalar(@stack) ) {
        my ( $dist, $row, $col ) = @{ shift @stack };
        if ( $dist[$row]->[$col] == -1 or $dist < $dist[$row]->[$col] ) {
            $dist[$row]->[$col] = $dist;
            my $char = $rows[$row]->[$col];
            if ( $char eq '-' ) {
                push @stack, [ $dist + 1, $row, $col - 1 ];
                push @stack, [ $dist + 1, $row, $col + 1 ];
            } elsif ( $char eq '|' ) {
                push @stack, [ $dist + 1, $row - 1, $col ];
                push @stack, [ $dist + 1, $row + 1, $col ];
            } elsif ( $char eq 'J' ) {
                push @stack, [ $dist + 1, $row, $col - 1 ];
                push @stack, [ $dist + 1, $row - 1, $col ];
            } elsif ( $char eq '7' ) {
                push @stack, [ $dist + 1, $row, $col - 1 ];
                push @stack, [ $dist + 1, $row + 1, $col ];
            } elsif ( $char eq 'F' ) {
                push @stack, [ $dist + 1, $row, $col + 1 ];
                push @stack, [ $dist + 1, $row + 1, $col ];
            } elsif ( $char eq 'L' ) {
                push @stack, [ $dist + 1, $row, $col + 1 ];
                push @stack, [ $dist + 1, $row - 1, $col ];
            }
        }
    }

    my $steps = 0;
    for ( my $row = 0; $row < scalar(@rows); $row++ ) {
        for ( my $col = 0; $col < scalar( $rows[0]->@* ); $col++ ) {
            if ( $dist[$row]->[$col] > $steps ) {
                $steps = $dist[$row]->[$col];
            }
        }
    }

    # The "Distances" can be used to determine the loop parameter.
    # As can anywhere with a non-dot.

    my (@expanded);
    for ( my $i = 0; $i < scalar(@dist); $i++ ) {
        push @expanded, [];
        push @expanded, [];
        for ( my $j = 0; $j < scalar( $dist[0]->@* ); $j++ ) {
            push $expanded[ $i * 2 ]->@*,     ' ';
            push $expanded[ $i * 2 ]->@*,     ' ';
            push $expanded[ $i * 2 + 1 ]->@*, ' ';
            push $expanded[ $i * 2 + 1 ]->@*, ' ';
            if ( $dist[$i]->[$j] >= 0 ) {
                $expanded[ $i * 2 ]->[ $j * 2 ] = $rows[$i]->[$j];
                my $char = $rows[$i]->[$j];
                if ( $char eq '-' ) {
                    $expanded[ $i * 2 ]->[ $j * 2 - 1 ] = '-';
                    $expanded[ $i * 2 ]->[ $j * 2 + 1 ] = '-';
                } elsif ( $char eq '|' ) {
                    $expanded[ $i * 2 - 1 ]->[ $j * 2 ] = '|';
                    $expanded[ $i * 2 + 1 ]->[ $j * 2 ] = '|';
                } elsif ( $char eq 'J' ) {
                    $expanded[ $i * 2 - 1 ]->[ $j * 2 ] = '|';
                    $expanded[ $i * 2 ]->[ $j * 2 - 1 ] = '-';
                } elsif ( $char eq '7' ) {
                    $expanded[ $i * 2 ]->[ $j * 2 - 1 ] = '-';
                    $expanded[ $i * 2 + 1 ]->[ $j * 2 ] = '|';
                } elsif ( $char eq 'F' ) {
                    $expanded[ $i * 2 + 1 ]->[ $j * 2 ] = '|';
                    $expanded[ $i * 2 ]->[ $j * 2 + 1 ] = '-';
                } elsif ( $char eq 'L' ) {
                    $expanded[ $i * 2 - 1 ]->[ $j * 2 ] = '|';
                    $expanded[ $i * 2 ]->[ $j * 2 + 1 ] = '-';
                }
            }
        }
    }

    (@stack) = ();
    push @stack, [ 0, 0 ];
    while ( scalar(@stack) ) {
        my ( $row, $col ) = @{ shift @stack };
        if ( $expanded[$row]->[$col] eq ' ' ) {
            $expanded[$row]->[$col] = 'O';

            push @stack, [ $row, $col - 1 ];
            push @stack, [ $row, $col + 1 ];
            push @stack, [ $row - 1, $col ];
            push @stack, [ $row + 1, $col ];
        }
    }

    my $inside = 0;
    for ( my $i = 0; $i < scalar(@expanded); $i += 2 ) {
        for ( my $j = 0; $j < scalar( $expanded[0]->@* ); $j += 2 ) {
            if ( $expanded[$i]->[$j] eq ' ' ) {
                $inside++;
            }
        }
    }

    say("Steps: $steps");
    say("Inside: $inside");
}

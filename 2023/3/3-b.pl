#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw/sum/;

MAIN: {
    my @lines;
    while ( my $line = <<>> ) {
        chomp($line);
        my (@symbols) = split //, ".$line.";

        push @lines, [@symbols];
    }
    unshift @lines, [ (".") x scalar( $lines[0]->@* ) ];
    push @lines, [ (".") x scalar( $lines[0]->@* ) ];

    my @gears;
    for ( my $i = 0; $i < scalar(@lines); $i++ ) {
        push @gears, [];
        for ( my $j = 0; $j < scalar( $lines[0]->@* ); $j++ ) {
            push $gears[$i]->@*, [];
        }
    }

    my $candidate = undef;
    my $start     = undef;
    my $end       = undef;
    for ( my $i = 0; $i < scalar(@lines); $i++ ) {
        for ( my $j = 0; $j < scalar( $lines[0]->@* ); $j++ ) {
            if ( $lines[$i][$j] =~ m/\d/ ) {
                if ( !defined($start) ) {
                    $end       = $start = $j;
                    $candidate = int( $lines[$i][$j] );
                } else {
                    $candidate = $candidate * 10 + int( $lines[$i][$j] );
                }
            } else {
                if ( defined($start) ) {
                    $end = $j - 1;
                    add_to_gear( $candidate, $i, $start, $end, \@lines, \@gears );
                    $candidate = undef;
                    $start     = $end = undef;
                }
            }
        }
    }

    my $sum = sum
      map  { $_->[0] * $_->[1] }
      grep { scalar(@$_) == 2 }
      map  { @$_ } @gears;

    say( "Sum of gears: " . $sum );
}

sub add_to_gear ( $candidate, $row, $start, $end, $symbols, $gears ) {
    # Symbol box is defined by $imin, $imin and $jmax, $jmax
    my $imax = $row + 1;
    my $imin = $row - 1;

    my $jmin = $start - 1;
    my $jmax = $end + 1;

    for ( my $i = $imin; $i <= $imax; $i++ ) {
        for ( my $j = $jmin; $j <= $jmax; $j++ ) {
            if ( $symbols->[$i][$j] eq '*' ) {
                push $gears->[$i][$j]->@*, $candidate;
            }
        }
    }
    return;
}


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

    my @parts;
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
                    push @parts, part_check( $candidate, $i, $start, $end, \@lines );
                    $candidate = undef;
                    $start     = $end = undef;
                }
            }
        }
    }

    say( "Sum of part numbers: " . sum(@parts) );
}

sub part_check ( $candidate, $row, $start, $end, $symbols ) {
    # This returns 0 if it's not a candidate (I.E. no symbol nearby)

    # Symbol box is defined by $imin, $imin and $jmax, $jmax
    my $imax = $row + 1;
    my $imin = $row - 1;

    my $jmin = $start - 1;
    my $jmax = $end + 1;

    for ( my $i = $imin; $i <= $imax; $i++ ) {
        for ( my $j = $jmin; $j <= $jmax; $j++ ) {
            if ( $symbols->[$i][$j] =~ m/[^.\d]/ ) {
                return $candidate;
            }
        }
    }

    return 0;
}


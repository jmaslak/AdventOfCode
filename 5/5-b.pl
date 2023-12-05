#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(min);

MAIN: {
    my ( %maps,       @seeds );
    my ( $source_map, $dest_map );
    while ( my $line = <<>> ) {
        chomp($line);

        if ( $line eq "" ) {
            $source_map = undef;
            $dest_map   = undef;
            next;
        }
        if ( $line =~ m/^seeds: / ) {
            (@seeds) = ( split /\s+/, ( $line =~ m/^seeds: ([\d\s]+)$/ )[0] );
            next;
        } elsif ( $line =~ m/-to-.*map:$/ ) {
            ( $source_map, $dest_map ) = $line =~ m/^(.*)-to-(.*)\s+map:$/;
            if ( !exists $maps{$source_map} ) {
                $maps{$source_map} = {};
            }
            $maps{$source_map}{$dest_map} = [];
        } else {
            my ( $dest_start, $source_start, $count ) = split /\s+/, $line;
            push $maps{$source_map}{$dest_map}->@*,
              {
                source_start => $source_start,
                dest_start   => $dest_start,
                count        => $count,
              };
        }
    }

    my @locations;
    for ( my $i = 0; $i < scalar(@seeds); $i += 2 ) {
        my $seed_start = $seeds[$i];
        my $seed_end   = $seeds[$i] + $seeds[ $i + 1 ] - 1;
        my $rets       = get_location( $seed_start, $seed_end, \%maps, 'seed' );
        for my $ret ( $rets->@* ) {
            if ( $ret->[0] eq 'location' ) {
                push @locations, $ret->[1];
            }
        }
    }
    say "Minimum location: " . min(@locations);
}

sub get_location ( $source_id_start, $source_id_end, $maps, $source ) {
    # This is ugly and wrong, but we basically only ever have one
    # destinatio type for any given range, so the for loop with a return
    # at the end actually works.
    for my $dest ( keys $maps->{$source}->%* ) {
        for my $rule ( $maps->{$source}{$dest}->@* ) {
            my $range_start = $rule->{source_start};
            my $range_end   = $rule->{source_start} + $rule->{count} - 1;

            my $delta = $rule->{source_start} - $rule->{dest_start};
            my @ranges;
            my $check;
            if ( $source_id_start >= $range_start and $source_id_end <= $range_end ) {
                $check = [ $source_id_start, $source_id_end ];
            } elsif ( $source_id_start < $range_start
                and $source_id_end >= $range_start
                and $source_id_end <= $range_end )
            {
                # We start before range
                push @ranges, [ $source_id_start, $range_start - 1 ];
                $check = [ $range_start, $source_id_end ];
            } elsif ( $source_id_start >= $range_start and $source_id_start <= $range_end ) {
                # We start inside the range, but end outside it
                $check = [ $source_id_start, $range_end ];
                push @ranges, [ $range_end + 1, $source_id_end ];
            } elsif ( $source_id_start < $range_start and $source_id_end > $range_end ) {
                # We start before, end after
                $check = [ $range_start, $range_end ];
                push @ranges, [ $source_id_start, $range_start - 1 ];
                push @ranges, [ $range_end + 1, $source_id_end ];
            } else {
                next;
            }

            my @rets;
            for my $range (@ranges) {
                push @rets, get_location( $range->[0], $range->[1], $maps, $source )->@*;
            }

            my $countdelta_start = $check->[0] - $rule->{source_start};
            my $countdelta_end   = $check->[1] - $rule->{source_start};
            my $dest_id_start    = $rule->{source_start} - $delta + $countdelta_start;
            my $dest_id_end      = $rule->{source_start} - $delta + $countdelta_end;

            if ( $dest eq 'location' ) {
                push @rets, [ 'location', $dest_id_start, $dest_id_end ];
            } else {
                push @rets, get_location( $dest_id_start, $dest_id_end, $maps, $dest )->@*;
            }
            return \@rets;
        }

        # Don't change the ID.
        if ( $dest eq 'location' ) { return [ [ 'location', $source_id_start, $source_id_end ] ]; }
        return get_location( $source_id_start, $source_id_end, $maps, $dest );
    }
    return [];
}

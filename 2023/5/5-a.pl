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
    for my $seed (@seeds) {
        my $ret = get_location( $seed, \%maps, 'seed' );
        if ( $ret->[0] eq 'location' ) {
            push @locations, $ret->[1];
        }
    }
    say "Minimum location: " . min(@locations);
}

sub get_location ( $source_id, $maps, $source ) {
    # This is ugly and wrong, but we basically only ever have one
    # destinatio type for any given range, so the for loop with a return
    # at the end actually works.
    for my $dest ( keys $maps->{$source}->%* ) {
        for my $rule ( $maps->{$source}{$dest}->@* ) {
            if (    $source_id >= $rule->{source_start}
                and $source_id < ( $rule->{source_start} + $rule->{count} ) )
            {
                my $delta      = $rule->{source_start} - $rule->{dest_start};
                my $countdelta = $source_id - $rule->{source_start};
                my $dest_id    = $rule->{source_start} - $delta + $countdelta;
                if ( $dest eq 'location' ) { return [ 'location', $dest_id ]; }

                return get_location( $dest_id, $maps, $dest );
            }
        }
        # Don't change the ID.
        if ( $dest eq 'location' ) { return [ 'location', $source_id ]; }
        return get_location( $source_id, $maps, $dest );
    }
    return;
}

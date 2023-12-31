#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!

use lib '.';

use Data::Dump;
use List::Util qw(all first);

MAIN: {
    my %network;

    $network{output}->{type} = 'output';

    while ( my $line = <<>> ) {
        chomp($line);

        my ( $type, $label, $deststr ) = $line =~ m/^([&%]?)(\S+) -> (.*)$/;
        if ( $label eq "broadcaster" ) { $type = 'broadcaster' }
        if ( $type eq '%' )            { $type = 'flipflop' }
        if ( $type eq '&' )            { $type = 'conjunction' }

        my %node = (
            type     => $type,
            label    => $label,
            out      => [ split ", ", $deststr ],
            memory   => {},
            highhist => [ 0, -1, 0 ],
            state    => 'l',
        );

        $network{$label} = \%node;
    }

    for my $k ( keys %network ) {
        for my $out ( $network{$k}->{out}->@* ) {
            if ( !exists( $network{$out} ) ) { next }
            $network{$out}->{memory}{$k} = 'l';
        }
    }

    my ( $low, $high ) = ( 0, 0 );
    for ( my $i = 0; $i < 1_000; $i++ ) {
        my ( $l, $h ) = push_button( \%network );
        $low  += $l;
        $high += $h;
    }

    say "Product from Part A: ", $low * $high;

    for my $k ( keys %network ) {
        for my $out ( $network{$k}->{out}->@* ) {
            if ( !exists( $network{$out} ) ) { next }
            $network{$out}->{memory}{$k} = 'l';
        }
        $network{$k}->{state}    = 'l';
        $network{$k}->{highhist} = [ 0, -1, 0 ];
    }

    my (@rx_feed) = grep {
        first { 'rx' eq $_ } $network{$_}->{out}->@*
    } keys %network;
    if ( scalar(@rx_feed) != 1 ) { die "Looks like too many things feed to rx!" }
    my (@interesting) = grep {
        first { $_ eq $rx_feed[0] } $network{$_}->{out}->@*
    } keys %network;

    my $count = 0;
    while ( !all { cycle( $network{$_}->{highhist} ) } @interesting ) {
        $count++;
        my (@parts) = push_button( \%network, $count );

    }

    my (@cycles) = map { cycle( $network{$_}->{highhist} ) } @interesting;
    my $lcm = lcm( \@cycles );

    say "Button presses for Part B: ", $lcm;
}

sub cycle ($list) {
    if ( $list->[2] - $list->[1] == $list->[1] - $list->[0] ) {
        return $list->[2] - $list->[1];
    } else {
        return undef;
    }
}

sub push_button ( $net, $cnt = 0 ) {
    my %pulses = ( h => 0, l => 1 );    # l => 1 is first button pulse
    my @queue;
    push @queue, [ 'broadcaster', 'l', 'button' ];

    while ( my $signal = shift @queue ) {
        my $label = $signal->[0];
        my $level = $signal->[1];
        my $src   = $signal->[2];
        if ( !exists( $net->{$label} ) ) { next }

        my $outlevel;
        if ( $net->{$label}{type} eq 'broadcaster' ) {
            $outlevel = $level;
        } elsif ( $net->{$label}{type} eq 'flipflop' ) {
            if ( $level eq 'l' ) {
                $outlevel = $net->{$label}{state} = $net->{$label}{state} eq 'l' ? 'h' : 'l';
            }
        } elsif ( $net->{$label}{type} eq 'conjunction' ) {
            $net->{$label}{memory}{$src} = $level;
            if ( all { $_ eq 'h' } values $net->{$label}{memory}->%* ) {
                $outlevel = 'l';
            } else {
                $outlevel = 'h';
            }

        }

        if ( defined($outlevel) ) {
            if ( $outlevel eq 'h' ) {
                push $net->{$label}->{highhist}->@*, $cnt;
                shift $net->{$label}->{highhist}->@*, $cnt;
            }
            for my $dst ( $net->{$label}{out}->@* ) {
                push @queue, [ $dst, $outlevel, $label ];
                $pulses{$outlevel}++;
            }
        }
    }

    return $pulses{l}, $pulses{h};
}

sub lcm ($list) {
    my $i = shift(@$list);
    my $j = shift(@$list);

    my $candidate;
    if ( $i > $j ) {
        $candidate = ( $i / gcd( $i, $j ) ) * $j;
    } else {
        $candidate = ( $j / gcd( $i, $j ) ) * $i;
    }

    if ( !scalar(@$list) ) { return $candidate; }
    unshift @$list, $candidate;
    return lcm($list);
}

sub gcd ( $i, $j ) {
    if ( $j == 0 ) { return $i; }
    return gcd( $j, $i % $j );
}

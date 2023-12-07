#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

my (%card_value) = (
    'J' => 1,
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'T' => 10,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
);

MAIN: {
    my @hands;
    while ( my $line = <<>> ) {
        chomp($line);
        my ( $hand, $bid ) = split / /, $line;
        push @hands, [ $hand, $bid ];
    }

    my $sum      = 0;
    my (@sorted) = sort { sort_hands() } @hands;
    my $size     = scalar(@sorted);
    for my $i ( 0 .. ( $size - 1 ) ) {
        $sum += $sorted[$i]->[1] * ( $i + 1 );
    }

    say("Sum of winnings: $sum");
}

sub sort_hands() {
    my $hand1 = $a->[0];
    my $hand2 = $b->[0];

    my $counts1 = get_counts($hand1);
    my $counts2 = get_counts($hand2);

    my $type1 = get_type($counts1);
    my $type2 = get_type($counts2);

    if ( $type1 <=> $type2 ) {
        return ( $type1 <=> $type2 );
    }

    return first_values( $hand1, $hand2 );
}

sub get_counts ($hand) {
    my %cardhash;
    for my $card ( split //, $hand ) {
        if ( !exists $cardhash{$card} ) {
            $cardhash{$card} = 0;
        }
        $cardhash{$card}++;
    }

    my $jokers = 0;
    if ( exists( $cardhash{J} ) and $cardhash{J} != 5 ) {
        $jokers = $cardhash{J};
        delete $cardhash{J};
    }

    my (@counts) = ( [], [], [], [], [], [] );
    foreach my $key ( keys %cardhash ) {
        my $count = $cardhash{$key};
        push $counts[$count]->@*, $key;
    }

    for ( my $i = 5; $i > 0; $i-- ) {
        if ( scalar( $counts[$i]->@* ) ) {
            my $card  = shift $counts[$i]->@*;
            my $times = $jokers + $i;
            push $counts[$times]->@*, $card;
            return \@counts;
        }
    }

    return \@counts;
}

sub get_type ($counts) {
    my $type;
    # 7 = 5 of a kind
    # 6 = 4 of a kind
    # 5 = full house
    # 4 = 3 of a kind
    # 3 = 2 pair
    # 2 = 1 pair
    # 1 = high card
    if ( scalar( $counts->[5]->@* ) ) {
        $type = 7;
    } elsif ( scalar( $counts->[4]->@* ) ) {
        $type = 6;
    } elsif ( scalar( $counts->[3]->@* ) and scalar( $counts->[2]->@* ) ) {
        $type = 5;
    } elsif ( scalar( $counts->[3]->@* ) ) {
        $type = 4;
    } elsif ( scalar( $counts->[2]->@* ) > 1 ) {
        $type = 3;
    } elsif ( scalar( $counts->[2]->@* ) ) {
        $type = 2;
    } else {
        $type = 1;
    }

    return $type;
}

sub first_values ( $hand1, $hand2 ) {
    my (@cards1) = ( split //, $hand1 );
    my (@cards2) = ( split //, $hand2 );
    for ( my $i = 0; $i < scalar(@cards1); $i++ ) {
        if ( $card_value{ $cards1[$i] } <=> $card_value{ $cards2[$i] } ) {
            return ( $card_value{ $cards1[$i] } <=> $card_value{ $cards2[$i] } );
        }
    }
    return 0;
}

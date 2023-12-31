#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;

use Data::Dump;
use List::Util qw(any sum);

MAIN: {
    while ( my $line = <<>> ) {
        chomp $line;
        my (@parts) = split ',', $line;

        my $sum = sum map { hash($_) } @parts;
        say "Sum part A: $sum";

        $sum = hashmap(@parts);
        say "Sum part B: $sum";
    }
}

sub hash ($str) {
    my (@parts) = split //, $str;

    my $sum = 0;
    for my $part (@parts) {
        $sum += ord($part);
        $sum *= 17;
        $sum = $sum % 256;
    }

    return $sum;
}

sub hashmap (@orders) {
    my @boxes = map { [] } 0 .. 255;
    for my $order (@orders) {
        my ( $lens, $op, $focal ) = $order =~ m/^(.+)([-=])(.*)$/;

        my $box = hash($lens);
        if ( $op eq '-' ) {
            my $contents = $boxes[$box];
            my $new      = [];
            for my $ele (@$contents) {
                if ( $ele->[0] ne $lens ) {
                    push @$new, $ele;
                }
            }
            $boxes[$box] = $new;
        } elsif ( $op eq '=' ) {
            my $contents = $boxes[$box];
            my $flag     = undef;
            for ( my $i = 0; $i < scalar(@$contents); $i++ ) {
                if ( $contents->[$i][0] eq $lens ) {
                    $flag = 1;
                    $contents->[$i] = [ $lens, $focal ];
                }
            }
            if ( !$flag ) {
                push @$contents, [ $lens, $focal ];
            }
        }
    }

    my $sum = 0;
    for ( my $box = 0; $box < 256; $box++ ) {
        for ( my $i = 0; $i < scalar( $boxes[$box]->@* ); $i++ ) {
            $sum += ( 1 + $box ) * ( 1 + $i ) * $boxes[$box]->[$i][1];
        }
    }
    return $sum;
}

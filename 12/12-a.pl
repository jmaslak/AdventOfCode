#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw(uniqstr sum);
use Parallel::WorkUnit;
use Memoize;

MAIN: {
    memoize('build_strings');
    my $wu = Parallel::WorkUnit->new();
    while (my $line = <<>>) {
        chomp($line);
        my ($springs_str, $possible_str) = split /\s+/, $line;

        my $parts = scalar(split /,/, $possible_str);

        $wu->async( sub { scalar(grep { $possible_str eq possible($_) } combos($springs_str, $parts)) } );
    }
    my $sum = sum $wu->waitall();
    say("Sum: $sum");
}

sub combos($springs_str, $cnt) {
    my (@parts) = ($springs_str =~ m/(?:[.]+)|(?:[#]+)|(?:[?]+)/g);
    for (my $i=0; $i<scalar(@parts); $i++) {
        my $part = $parts[$i];
        if ($part =~ m/\./) {
            $parts[$i] = [[$part]];
        } elsif ($part =~ m/\#/) {
            $parts[$i] = [[$part]];
        } else {
            $parts[$i] = permeate(length($part), "x", $cnt*3);
        }
    }
    return build_strings(@parts);
}

sub build_strings(@stack) {
    my @ret;
    my $top = shift(@stack);
    for my $part (@$top) {
        if (scalar(@stack)) {
            push @ret, uniqstr map { join("", @$part, $_) } build_strings(@stack);
        } else {
            push @ret, join("", @$part);
        }
    }
    return uniqstr @ret;
}

sub permeate($len, $last, $cnt) {
    # Computes every possible split for a given length
    my @ret;
    $cnt--;
    if ($cnt < 0) { return undef; }

    if ($len >= 0) {
        if ($last ne '#') {
            push @ret, [ '#'x$len ];
        }
        if ($last ne '.') {
            push @ret, [ '.'x$len ];
        }
    }

    for (my $i=1; $i<$len; $i++) {
        if ($last ne '#') {
            my $p = permeate($len-$i, '#', $cnt);
            if (defined($p)) {
                push @ret, map { [ '#'x$i, @$_ ] } @$p;
            }
        }
        if ($last ne '.') {
            my $p = permeate($len-$i, '.', $cnt);
            if (defined($p)) {
                push @ret, map { [ '.'x$i, @$_ ] } @$p;
            }
        }
    }
    return \@ret;
}

sub possible($springs_str) {
    my @runs;
    my $run = 0;
    for my $c (split //, $springs_str) {
        if ($c eq "#") {
            $run++;
        } else {
            if ($run) {
                push @runs, $run;
                $run = 0;
            }
        }
    }
    if ($run) {
        push @runs, $run;
    }
    return join(",", @runs);
}

__END__

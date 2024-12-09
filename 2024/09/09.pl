#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my @map;
    while (my $line = <<>>) {
        chomp($line);
        @map = split //, $line;
    }

    my $state = "FILE";
    my $fileno = 0;
    my @storage;
    for my $ele (@map) {
        if ($state eq "FILE") {
            for (my $i=0; $i<$ele; $i++) {
                push @storage, $fileno;
            }
            $fileno++;
            $state = "FREE";
        } else {
            for (my $i=0; $i<$ele; $i++) {
                push @storage, '.';
            }
            $state = "FILE";
        }
    }

    my (@working) = @storage;

    my $free = 0;
    my $used = scalar(@working) - 1;

    while ($free < $used) {
        if ($working[$used] eq '.') {
            $used--;
            next;
        }
        
        if ($working[$free] ne '.') {
            $free++;
            next;
        }

        $working[$free] = $working[$used];
        $working[$used] = '.';

        $used--;
        $free++;
    }
    say "Part 1: " . checksum(@working);

    @working = @storage;
 
    # Part 2 
    $used = scalar(@working) - 1;

    while ($used >= 0) {
        if ($working[$used] eq '.') {
            $used--;
            next;
        }

        my $start = findstart(\@working, $used);
        my $size = 1 + $used - $start;

        $free = findfree(\@working, $size);

        if (($start < $free) or !defined($free)) {
            $used = $start - 1;
            next;
        }

        my $fileno = $working[$start];
        for (my $i=0; $i<$size; $i++) {
            $working[$start + $i] = '.';
        }
        for (my $i=0; $i<$size; $i++) {
            $working[$free + $i] = $fileno;
        }
        
        $used = $start - 1;
    }
    
    say "Part 2: " . checksum(@working);
}

sub checksum(@storage) {
    my $chksum = 0;
    for (my $i=0; $i<scalar(@storage); $i++) {
        if ($storage[$i] eq '.') {
            next;
        }
        $chksum += $i * $storage[$i];
    }

    return $chksum;
}

sub findfree($storage, $desired_size) {
    my $free = 0;
    my $start = undef;
    my $size = 0;
    while ($free < scalar(@$storage)) {
        if ($storage->[$free] ne '.') {
            $free++;
            $size = 0;
            $start = $free;
            next;
        }

        if ($storage->[$free] eq '.') {
            $free++;
            $size++;
            if ($size >= $desired_size) {
                return $start;
            }
        }
    }
    return undef;
}

sub findstart($storage, $end) {
    my $current = $end;
    my $fileno = $storage->[$end];

    while ($current >= 0) {
        if ($storage->[$current] eq '.' or $storage->[$current] != $fileno) {
            return $current + 1;
        }
        $current--;
    }
    return 0;
}

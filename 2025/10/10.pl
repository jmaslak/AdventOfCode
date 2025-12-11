#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util;

class Button {
    field @toggles;

    method toggles() { @toggles }

    method set(@t) {
        @toggles = @t;
    }
}

class Machine {
    use PDL;
    use PDL::Opt::GLPK;

    field $indicator : param;
    field @buttons;
    field @joltages;
    field %cache;
    field %cachetoggles;

    method indicator() { $indicator }
    method buttons()   { @buttons }
    method joltages()  { @joltages }

    method add_button(@toggles) {
        my $button = Button->new();
        $button->set(@toggles);
        push @buttons, $button;
    }

    method set_joltages(@jolts) {
        @joltages = @jolts;
    }

    method string() {
        my $s = "[$indicator]";
        for my $button (@buttons) {
            $s .= " (" . join( ",", $button->toggles ) . ")";
        }
        return $s;
    }

    method press( $lights, $button_id ) {
        if ( !defined($lights) ) {
            $lights = $indicator;
            $lights =~ s/\#/./g;
        }
        for my $toggle ( $buttons[$button_id]->toggles ) {
            substr( $lights, $toggle, 1 ) = substr( $lights, $toggle, 1 ) eq "#" ? "." : "#";
        }
        return $lights;
    }

    method press_jolts( $jolts, $button_id ) {
        if ( !defined($jolts) ) {
            $jolts = [];
        } else {
            $jolts = [@$jolts];
        }

        for my $toggle ( $buttons[$button_id]->toggles ) {
            $jolts->[$toggle]++;
        }
        return $jolts;
    }

    method search_indicators( $lights, $button_id, $seen ) {
        if ( !defined($seen) ) { $seen = [] }

        if ( defined($lights)    and $lights eq $indicator ) { return 0 }
        if ( defined($button_id) and $seen->[$button_id] )   { return undef }

        my $initial = 0;
        if ( defined($button_id) ) {
            $seen->[$button_id] = 1;
            $lights = $self->press( $lights, $button_id );
            $initial++;
        }

        $seen = [@$seen];

        my $least;
        for my $i ( 0 .. $#buttons ) {
            my $result = $self->search_indicators( $lights, $i, $seen );
            if ( !defined($result) ) { next; }

            if ( ( !defined($least) ) or $result < $least ) {
                $least = $initial + $result;
            }
        }
        return $least;
    }

    method optimize() {
        #
        # I am using the GLPK solver for this, because I suck at linear
        # algebra.
        #
        # Build matrxc of equations.
        #
        # ROWS correspond to joltages.
        # COLUMNS correspond to each button.
        #
        # That's because I don't know how many times a button is
        # pushed, just how the value of joltages so I transform
        # these equations into joltages equations.
        # 
        # I use coefficient of 1 for the button acts on that joltage, 0
        # if it does not.
        my @a;                                             # Coefficients (0 or 1)
        my $b      = [@joltages];                          # Equality vector
        my $c      = [ map { 1 } @buttons ];               # Equation (x1 + x2 + x3 ...)
        my $lb     = zeros( scalar(@buttons) );
        my $ub     = inf( scalar(@buttons) );
        my $ctypes = GLP_FX * ones( scalar @joltages );    # Equality
        my $vtypes = GLP_IV * ones( scalar @buttons );     # Integers

        for my $i ( 0 .. $#joltages ) {
            if ( !exists( $a[$i] ) ) {
                $a[$i] = [];
            }
        }

        for my $j ( 0 .. $#buttons ) {
            my @toggles = $buttons[$j]->toggles;
            for my $i ( 0 .. $#joltages ) {
                $a[$i][$j] = ( List::Util::any { $_ == $i } @toggles ) ? 1 : 0;
            }
        }

        my $xopt = null;    # Solutions by button (array)
        my $fopt = null;    # Sum of solutions
        glpk( pdl($c), pdl( [@a] ),
            pdl($b), pdl($lb), pdl($ub), pdl($ctypes), pdl($vtypes), pdl(GLP_MIN), $xopt, $fopt,
            null,    null,     null, { msglev => 0, save_pb => 0 } );

        return $fopt;
    }
}

MAIN: {
    my @machines;
    while ( <<>> ) {
        chomp;
        next if $_ eq "";
        my (@parts) = m/^\[([\.\#]+)\] \(([0-9,\(\) ]+)\) \{(.+)\}$/;

        my $machine = Machine->new( indicator => $parts[0] );

        for my $b ( split /\) \(/, $parts[1] ) {
            $machine->add_button( split /,/, $b );
        }

        $machine->set_joltages( split /,/, $parts[2] );

        push @machines, $machine;
    }

    my $part1 = 0;
    for my $machine (@machines) {
        $part1 += $machine->search_indicators( undef, undef, undef );
    }

    my $part2 = List::Util::sum map { $_->optimize } @machines;

    say "Part 1: $part1";
    say "Part 1: $part2";
}

#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!

use lib '.';

use List::Util qw(sum);

MAIN: {
    my %workflows;
    my @parts;

    while (my $line = <<>>) {
        state $state = 'workflows';
        
        chomp($line);

        if ($state eq 'workflows') {
            if ($line eq "") {
                $state = 'parts';
                next;
            }
            
            my ($label, $rules) = workflow_decode($line);
            $workflows{$label} = $rules;
        } else {
            # We are in the parts state
            push @parts, part_decode($line);
        }
    }

    my $bins = sort_parts(\%workflows, \@parts);
    my $sum = sum_traits($bins->{A});
    say "Part A sum: $sum";

    my $traits = {
        a => [1, 4000],
        m => [1, 4000],
        s => [1, 4000],
        x => [1, 4000],
    };
    $bins = get_combos(\%workflows, $traits);
    $sum = calc_combos($bins->{A});
    say "Part B sum: $sum";
}

sub sum_traits($parts) {
    return sum map { sum values %$_ } @$parts;
}

sub workflow_decode($line) {
    my ($label, $workflow_str) = $line =~ m/^([^{]+)\{(.*)\}$/;
    my (@workflows) = map { rule_decode($_) } split ",", $workflow_str;

    return $label, \@workflows;
}

sub rule_decode($str) {
    my $rule = {};
    if ($str =~ m/:/) {
        my ($trait, $type, $val, $action) = $str =~ m/^(.*)([><])([0-9]+):(.*)$/;
        return {
            cmd => 'if',
            trait => $trait,
            type => $type,
            value => $val,
            action => $action,
        };
    }

    # Otherwise...
    return {
        cmd => 'goto',
        action => $str,
    };
}

sub part_decode($line) {
    $line =~ s/^.(.*).$/$1/;
    my %traits = map { split /=/, $_ } split /,/, $line;
    return \%traits;
}

sub sort_parts($workflows, $parts) {
    my %bin;
    for my $part (@$parts) {
        my $label = 'in';
        my $action;

        while (!defined($action)) {
            my $workflow = $workflows->{$label};
            for my $rule (@$workflow) {

                if ($rule->{cmd} eq 'if') {
                    if ($rule->{type} eq '>') {
                        # if statement - >
                        if ($part->{$rule->{trait}} > $rule->{value}) {
                            $action = $rule->{action};
                            last;
                        }
                    } else {
                        # if statement - <
                        if ($part->{$rule->{trait}} < $rule->{value}) {
                            $action = $rule->{action};
                            last;
                        }
                    }
                } else {
                    # Goto
                    $action = $rule->{action};
                    last;
                }
            }
            if (defined($action)) {
                if (!exists $workflows->{$action}) {
                    # We put things into a bin.
                    if (!exists $bin{$action}) {
                        $bin{$action} = [];
                    }
                    push $bin{$action}->@*, $part;
                } else {
                    # We go to another rule.
                    $label = $action;
                    $action = undef;
                }
            }
        }
    }
    return \%bin;
}

sub get_combos($workflows, $traits) {
    my %bin;

    my @stack;
    push @stack, [$traits, 'in'];

    while (my $top = shift @stack) {
        my %t = clone($top->[0])->%*;
        my $label = $top->[1];
        my $action;

        while (!defined($action)) {
            my $workflow = $workflows->{$label};
            for my $rule (@$workflow) {

                if ($rule->{cmd} eq 'if') {
                    my $value = $rule->{value};
                    my $trait = $rule->{trait};
                    my $min = $t{$trait}->[0];
                    my $max = $t{$trait}->[1];

                    if ($rule->{type} eq '>') {
                        # if statement - >
                        if ($min > $value) {
                            $action = $rule->{action};
                            last;
                        } elsif ($max <= $value) {
                            # Do nothing, we'll process the next rule
                        } else {
                            # We need to split.
                            my %t2 = clone(\%t)->%*;
                            $t{$trait}->[0] = $value+1;
                            $t2{$trait}->[1] = $value;
                            push @stack, [\%t2, $label];

                            $action = $rule->{action};
                            last;
                        }
                    } else {
                        # if statement - <
                        if ($max < $value) {
                            $action = $rule->{action};
                            last;
                        } elsif ($min >= $value) {
                            # Do nothing, we'll process the next rule
                        } else {
                            # We need to split.
                            my %t2 = clone(\%t)->%*;
                            $t{$trait}->[1] = $value-1;
                            $t2{$trait}->[0] = $value;

                            push @stack, [\%t2, $label];

                            $action = $rule->{action};
                            last;
                        }
                    }
                } else {
                    # Goto
                    $action = $rule->{action};
                    last;
                }
            }
            if (defined($action)) {
                if (!exists $workflows->{$action}) {
                    # We put things into a bin.
                    if (!exists $bin{$action}) {
                        $bin{$action} = [];
                    }
                    push $bin{$action}->@*, \%t;
                } else {
                    # We go to another rule.
                    $label = $action;
                    $action = undef;
                }
            }
        }
    }
    return \%bin;
}

sub calc_combos($bin) {
    use bigint;

    my $sum = 0;
    for my $hash (@$bin) {
        my $total = 1;
        for my $v ( values %$hash ) {
            $total *= 1 + $v->[1] - $v->[0];
        }
        $sum += $total;
    }
    return $sum;
}

sub clone($in) {
    my $out = {};

    for my $k (keys %$in) {
        $out->{$k} = [ $in->{$k}->@* ];
    }

    return $out;
}

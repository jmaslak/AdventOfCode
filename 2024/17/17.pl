#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use Parallel::WorkUnit;
use Sys::CpuAffinity;
use IPC::Semaphore;
use IPC::SysV qw(S_IRUSR S_IWUSR IPC_CREAT IPC_PRIVATE);
use List::Util qw(max);

class Register {
    field $val :reader :param;

    method set($v) {
        $val = $v;
        return undef;
    }

    method inc2() {
        $val += 2;
        return $val;
    }

    method inc() {
        $val++;
        return $val;
    }
}

class Memory {
    field $mem;

    ADJUST {
        $mem = [];
    }

    method get($addr) {
        return $mem->[$addr];
    }

    method set($addr, $val) {
        $mem->[$addr] = int($val % 8);
        return undef;
    }

    method len() {
        my $i = 0;
        while (1) {
            if (!defined($mem->[$i])) { return $i }
            $i++;
        }
    }

    method get_all() {
        return $mem->@*;
    }

    method key() {
        return join(",", $mem->@*);
    }
}

class CPU {
    field $mem :reader;
    field $a :reader;
    field $b :reader;
    field $c :reader;
    field $ip :reader;

    ADJUST {
        $mem = Memory->new();
        $a = Register->new(val => 0);
        $b = Register->new(val => 0);
        $c = Register->new(val => 0);
        $ip = Register->new(val => 0);
    }

    method set_register($reg, $v) {
        if ($reg eq 'A') { $a->set($v) }
        elsif ($reg eq 'B') { $b->set($v) }
        elsif ($reg eq 'C') { $c->set($v) }
        elsif ($reg eq 'IP') { $ip->set($v) }
        else { die("Unknoown register $reg") }
        return undef;
    }

    method set_memory($addr, $v) {
        $mem->set($addr, $v);
        return undef;
    }

    method get_all_memory() {
        return $mem->get_all();
    }

    method copy() {
        my $cp = CPU->new();
        $cp->a->set($a->val);
        $cp->b->set($b->val);
        $cp->c->set($c->val);
        $cp->ip->set($ip->val);

        for (my $i=0; $i<$mem->len(); $i++) {
            $cp->mem->set($i, $mem->get($i));
        }

        return $cp;
    }

    method execute() {
        my @output;

        while (1) {
            my $i = $mem->get($ip->val);
            my $o = $mem->get($ip->val + 1);

            if (!defined($i)) { last }
            if (!defined($o)) { last }

            # say "IP: " . $ip->val . " I: $i OP: $o A: " . $a->val . " B: " . $b->val . " COP: " . $c->val;
            if ($i == 0) {  # ADV (Divide A by [op] -> A)
                # say "A = " . $a->val . " / 2**" . $self->combo($o);
                $a->set(int($a->val / (2 ** $self->combo($o))));
                $ip->inc2();
            } elsif ($i == 1) {  # BXL (Bitwise XOR of B and op -> B)
                # say "B = " . $b->val . " xor " . $o;
                $b->set($b->val ^ $o);
                $ip->inc2();
            } elsif ($i == 2) {  # BST (Set B to [op] % 8)
                # say "B = " . $self->combo($o) . " % 8";
                $b->set($self->combo($o) % 8);
                $ip->inc2();
            } elsif ($i == 3) {  # JNZ (Jump if A is not zero by op instructions)
                if ($a->val == 0) {
                    # say "JNZ NOOP";
                    $ip->inc2();
                } else {
                    # say "JNZ $o";
                    $ip->set($o);
                }
            } elsif ($i == 4) {  # BXC (bitwise XOR of B and C --> B; ignore op)
                # say "B = " . $b->val . " xor " . $c->val;
                $b->set($b->val ^ $c->val);
                $ip->inc2();
            } elsif ($i == 5) {  # OUT (ouptut [op] % 8)
                # say "OUT: " . ($self->combo($o) % 8);
                # say "";
                push @output, $self->combo($o) % 8;
                $ip->inc2();
            } elsif ($i == 6) {  # BDV (Divide A by [op] --> B)
                # say "B = " . $a->val . " / 2**" . $self->combo($o);
                $b->set(int($a->val / (2 ** $self->combo($o))));
                $ip->inc2();
            } elsif ($i == 7) {  # CDV (Divide A by [op] --> C)
                # say "C = " . $a->val . " / 2**" . $self->combo($o);
                $c->set(int($a->val / (2 ** $self->combo($o))));
                $ip->inc2();
            } else {
                die("Invalid instruction ($i)");
            }
        }

        return @output;
    }

    method combo($o) {
        if ($o <= 3) { return $o }

        if ($o == 4) { return $a->val }
        if ($o == 5) { return $b->val }
        if ($o == 6) { return $c->val }

        die("Unknown combo operand ($o)");
    }

    method mem_key() {
        return $mem->key();
    }

    sub read(@lines) {
        my $cpu = CPU->new;
        for (@lines) {
            if (/^Register/) {
                my ($reg, $val) = /^Register (.): (\d+)/;
                $cpu->set_register($reg, $val);
            } elsif (/^Program: /) {
                my ($data) = /^Program: (.*)/;
                my (@vals) = split /,/, $data;
                for (my $i=0; $i<scalar(@vals); $i++) {
                    $cpu->set_memory($i, $vals[$i]);
                }
            }
        }
        return $cpu;
    }
}

sub find_possible($cpu) {
    my $original = $cpu->copy();
    my (@mem) = $cpu->get_all_memory();

    my $len = scalar($cpu->get_all_memory());
    my $first = find_first_len($cpu, 0);
    my $last = find_last_len($cpu, $first);

    my $i=$len-1;
    my @stack;
    while ($i >= 8) {  # This seems to get the answer in a reasonable time. Doing more gives the wrong answer.
        my $candidate = $first;

        my $validate = $cpu->copy();
        $validate->set_register('A', $first);
        my (@result) = $validate->execute();
        my $flag = 0;
        while ($result[$i] != $mem[$i]) {
            $candidate = find_first_change($cpu, $candidate, $last, $i);
            $validate = $cpu->copy();
            $validate->set_register('A', $candidate);
            (@result) = $validate->execute();
            if ($candidate == $last) {
                if ($result[$i] == $mem[$i]) {
                    return $candidate;
                } else {
                    if ($i > 2) {
                        $first = 1 + pop @stack;
                        $last = $stack[-1];
                        $i++;
                        next;
                    } else {
                        return $candidate;
                    }
                }
            }
        }
        $first = $candidate;

        $last = find_first_change($cpu, $first, $last, $i) - 1;
        push @stack, $last;
        $i--;
    }

    return $first;
}

sub find_first_len($cpu, $first) {
    $cpu = $cpu->copy();
    my (@mem) = $cpu->get_all_memory();
    my $b = $cpu->b->val;
    my $c = $cpu->c->val;

    my $found = -1;
    my $step = 1;
    my $curr = $first;
    my $mode = "GROW";
    while ($found == -1 or $first != $curr) {
        $cpu->set_register('A', $curr);
        $cpu->set_register('B', $b);
        $cpu->set_register('C', $c);
        $cpu->set_register('IP', 0);

        my (@result) = $cpu->execute();

        if (scalar(@result) < scalar(@mem)) {
            if ($mode eq "GROW") {
                $step = $step * 2;
                $first = $curr;
                $curr = $curr + $step;
            } else {
                $first = $curr;
                $curr = int(($first + $found) / 2);
            }
        } else {
            if ($mode eq "GROW") {
                $mode = "BINARY";
            }
            $found = $curr;
            $curr = int(($first + $found) / 2);
        }
    }

    return $found;
}

sub find_last_len($cpu, $first) {
    $cpu = $cpu->copy();
    my (@mem) = $cpu->get_all_memory();
    my $b = $cpu->b->val;
    my $c = $cpu->c->val;

    my $found = -1;
    my $step = 1;
    my $curr = $first;
    my $mode = "GROW";
    while ($found == -1 or $first != $curr) {
        $cpu->set_register('A', $curr);
        $cpu->set_register('B', $b);
        $cpu->set_register('C', $c);
        $cpu->set_register('IP', 0);

        my (@result) = $cpu->execute();

        if (scalar(@result) <= scalar(@mem)) {
            if ($mode eq "GROW") {
                $step = $step * 2;
                $first = $curr;
                $curr = $curr + $step;
            } else {
                $first = $curr;
                $curr = int(($first + $found) / 2);
            }
        } else {
            if ($mode eq "GROW") {
                $mode = "BINARY";
            }
            $found = $curr;
            $curr = int(($first + $found) / 2);
        }
    }

    $found--;
    return $found;
}

sub find_first_change($cpu, $first, $last, $i) {
    $cpu = $cpu->copy();
    my (@mem) = $cpu->get_all_memory();
    my $b = $cpu->b->val;
    my $c = $cpu->c->val;

    $cpu->set_register('A', $first);
    my (@result) = $cpu->execute();
    my $val = $result[$i];

    my $step = 1;
    my $curr = ($first + $last) / 2;
    while ($first != $curr) {
        $cpu->set_register('A', $curr);
        $cpu->set_register('B', $b);
        $cpu->set_register('C', $c);
        $cpu->set_register('IP', 0);

        (@result) = $cpu->execute();

        if (scalar(@result) == scalar(@mem) and $result[$i] == $val) {
            $first = $curr;
            $curr = int(($first + $last) / 2);
        } else {
            $last = $curr;
            $curr = int(($first + $last) / 2);
        }
    }

    return $last;
}

sub find_solution($cpu, $lines) {
    my $start = find_possible($cpu);
    my $wu = Parallel::WorkUnit->new();
    $wu->max_children( Sys::CpuAffinity::getNumCpus() );

    my @data = 0..(($wu->max_children)-1);
    $wu->queueall( \@data, sub ($instance) { tryit($lines, $instance, $wu->max_children, $start) } );
    my (@results) = $wu->waitall();
    return max @results;
}

my $sem = IPC::Semaphore->new(IPC_PRIVATE, 1, S_IRUSR | S_IWUSR | IPC_CREAT);
$sem->setval(0, 0);

sub tryit($lines, $instance, $procs, $start) {
    my $cpu = CPU->read(@$lines);

    my $val = $start;
    my $key = $cpu->mem_key();
    my $a = $cpu->a->val;
    my $b = $cpu->b->val;
    my $c = $cpu->c->val;

    while (1) {
        if ($sem->getval(0)) { last }
        if (($val % $procs) != $instance) { $val++; next; }
        if ($val == $a) { $val++; next; }
        $cpu->set_register('B', $b);
        $cpu->set_register('C', $c);
        $cpu->set_register('IP', 0);

        $cpu->set_register('A', $val);
        my $newkey = join ",", $cpu->execute();
        if ($newkey eq $key) { $sem->setval(0, 1); return $val; }

        $val++;
    }

    return -1;
}

MAIN: {
    my @lines;
    while (<<>>) {
        chomp;
        push @lines, $_;
    }
    
    my $cpu = CPU->read(@lines);
    my $cpu2 = $cpu->copy();

    my (@out) = $cpu->execute();
    say "Part 1: " . join(",", @out);

    my $solution = find_solution($cpu2, \@lines);
    say "Part 2: $solution";
}


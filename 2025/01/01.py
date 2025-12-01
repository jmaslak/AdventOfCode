#!/usr/bin/env python

# Copyrigt (C) 2025 Joelle Maslak
# All Rights Reserved - See License

import sys
from typing import List

def main():
    spins: List[int] = []

    # Read spins, storing left ones as negative ints, right ones as positive ints.
    for line in sys.stdin.readlines():
        line = line.strip()

        direction, spin = line[0], int(line[1:])
        if direction == "L":
            spin = -spin

        spins.append(spin)

    # Set up dial position and counter variables
    dial: int = 50
    part1: int = 0
    part2: int = 0

    # Process spins
    for spin in spins:
        old = dial

        hundreds = int(abs(spin)/100)
        part2 += hundreds

        if spin < 0:
            # Left
            spin += hundreds * 100
        else:
            # Right
            spin -= hundreds * 100

        # Spin the dial, note it will need to be normalied back to a number
        # between 0 and 100
        dial += spin

        if (dial % 100) == 0:
            # We ended on a zero, so we increment.
            part1 += 1
            part2 += 1
        else:
            if old != 0:
                # If we started on a zero, we know we don't increment.
                if dial < 0 or dial > 100:
                    # We crossed zero here.
                    # We don't count ending on 0/100 because we count that
                    # higher up, those values never get here.
                    part2 += 1

        # We want to normalize the dial number to a number between 0 and 99,
        # inclusive
        dial = dial % 100

    print(f"Solution for part 1: {part1}")
    print(f"Solution for part 2: {part2}")


if __name__ == "__main__":
    main()
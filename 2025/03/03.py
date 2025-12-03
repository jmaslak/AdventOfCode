#!/usr/bin/env python

# Copyrigt (C) 2025 Joelle Maslak
# All Rights Reserved - See License

import sys
from typing import List


def main():
    batt_list: List[List[int]] = []

    # Read Battery strings
    txt = ""
    for line in sys.stdin.readlines():
        batt_list.append([int(x) for x in line.strip()])

    # Set counter variables
    part1: int = 0
    part2: int = 0

    # Do the work
    for batts in batt_list:
        part1 += int(largest_joltage(batts, 2))
        part2 += int(largest_joltage(batts, 12))

    print(f"Solution for part 1: {part1}")
    print(f"Solution for part 2: {part2}")


def largest_joltage(batts: List[int], sz: int) -> str:
    assert sz >= 0

    if sz == 0:
        return ""

    # These are all the possible first batteries, by value
    possibles = batts[slice(0,len(batts)-sz)]
    maxval = max(possibles)  # The actual biggest possible first battery

    for i in range(0, len(batts)):
        val = batts[i]
        if val == maxval:
            # We have the biggest starting battery size, so now we recurse.
            remainder = batts[slice(i+1, len(batts))]
            return f"{val}{largest_joltage(remainder, sz-1)}"

    assert 0 == 1 # Shouldn't get here.
    return ""


if __name__ == "__main__":
    main()

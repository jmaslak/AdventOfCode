#!/usr/bin/env python

# Copyrigt (C) 2025 Joelle Maslak
# All Rights Reserved - See License

import re
import sys
from dataclasses import dataclass
from typing import List


@dataclass
class Range:
    start: int
    end: int


def main():
    ranges: List[Range] = []

    # Read ranges
    txt = ""
    for line in sys.stdin.readlines():
        txt += line.strip()

    for r in txt.split(","):
        parts = r.split("-")
        if len(parts) != 2:
            raise Exception("invalid input data")

        ranges.append(Range(int(parts[0]), int(parts[1])))

    # Set counter variables
    part1: int = 0
    part2: int = 0

    # Do the work
    for r in ranges:
        for i in range(r.start, r.end + 1):
            # Something repeats exactly once.
            if re.match(r"^(.+)\1$", str(i)):
                part1 += i

            # Something repeats one or more times.
            if re.match(r"^(.+)\1+$", str(i)):
                part2 += i

    print(f"Solution for part 1: {part1}")
    print(f"Solution for part 2: {part2}")


if __name__ == "__main__":
    main()

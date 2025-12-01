package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

// Wrapper to handle panics, as is typically good practice.
// You might want to log errors or similar.
func main() {
	err := doit()
	if err != nil {
		panic(err)
	}
}

// Main computation function
func doit() error {

	spins, err := readData()
	if err != nil {
		return err
	}

	// Set up dial position and counters
	dial := 50
	part1 := 0
	part2 := 0

	// Process spins
	for _, spin := range spins {
		old := dial // We want the starting position

		// Tricky - a >= 100 spin!
		hundreds := spin / 100
		part2 += AbsInt(hundreds)

		// Normalize the number of spins
		spin -= hundreds * 100

		// Spin the dial. Note it will need to be normalized back to
		// a number between 0 & 100
		dial += spin

		if dial%100 == 0 {
			// We ended on a zero
			part1++
			part2++
		} else {
			if old != 0 {
				// We don't count anything that starts at zero
				if dial < 0 || dial > 100 {
					// We crossed zero.
					part2++
				}
			}
		}

		// Normalize the dial value.
		dial = dial % 100
		if dial < 0 {
			dial = dial + 100
		}
	}

	fmt.Printf("Solution for part 1: %d\n", part1)
	fmt.Printf("Solution for part 2: %d\n", part2)

	return nil
}

// Read the file and convert it to an array of integers,
// with negative integers being left spins, positive integers
// being right spins.
func readData() ([]int, error) {
	lines, err := readLines()
	if err != nil {
		return []int{}, err
	}

	spins := []int{}
	for _, line := range lines {
		direction := line[0]
		value, err := strconv.Atoi(line[1:])
		if err != nil {
			return spins, err
		}
		if direction == 'L' {
			value = -value
		}
		spins = append(spins, value)
	}

	return spins, nil
}

// Read all lines from stdin, and get rid of newlines.
func readLines() ([]string, error) {
	lines := []string{}
	reader := bufio.NewReader(os.Stdin)
	for {
		txt, err := reader.ReadString('\n')
		if errors.Is(err, io.EOF) {
			return lines, nil
		} else if err != nil {
			return lines, err
		}

		txt = strings.Replace(txt, "\n", "", 1)
		lines = append(lines, txt)
	}
}

// Compute an absolute value of an integer
// For some unknown reason this isn't part of go, possibly
// because it can actually panic if the you try to negate
// the MININT.  But divide by zero can panic too...
// We assume you won't pass in MININT
func AbsInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

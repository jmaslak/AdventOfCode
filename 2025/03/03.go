package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"math"
	"os"
	"strings"
)

type BatteryString []int

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

	battStrings, err := readData()
	if err != nil {
		return err
	}

	// Set up counters
	part1 := 0
	part2 := 0

	// Process intervals
	for _, batts := range battStrings {
		part1 += largestJoltage(batts, 2)
		part2 += largestJoltage(batts, 12)
	}
	fmt.Printf("Solution for part 1: %d\n", part1)
	fmt.Printf("Solution for part 2: %d\n", part2)

	return nil
}

// Get the largest joltage for sz number of batteries
func largestJoltage(batts BatteryString, sz int) int {
	// Get the biggest battery that could be the first
	// battery.
	maxval, maxpos := maxBattery(batts[0 : len(batts)-sz+1])

	// End condition
	if sz == 1 {
		return maxval
	}

	// Recurse!
	return maxval*(tenToThe(sz-1)) + largestJoltage(batts[maxpos+1:], sz-1)
}

// Get the largest battery index and value
func maxBattery(batts BatteryString) (int, int) {
	var maxval, maxpos int
	for i, val := range batts {
		if val > maxval {
			maxval = val
			maxpos = i
		}
	}
	return maxval, maxpos
}

// Get the power of 10 to the nth
func tenToThe(n int) int {
	return int(math.Pow(10, float64(n)))
}

// Read the file and convert it to a slice of battery strings
func readData() ([]BatteryString, error) {
	lines, err := readLines()
	if err != nil {
		return []BatteryString{}, err
	}

	battStrings := []BatteryString{}
	for _, line := range lines {
		batts := BatteryString{}
		for _, batt := range line {
			// Don't try this on an IBM 360.
			batts = append(batts, int(batt-'0'))
		}
		battStrings = append(battStrings, batts)
	}

	return battStrings, nil
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

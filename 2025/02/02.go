package main

// To run on OSX:
//
//   Install pcre with Homebrew
//	 Install the go modules in go.mod as normal
//	 Then:
//		CGO_CFLAGS="-I/opt/homebrew/include" go run 02.go <sample

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/glenn-brown/golang-pkg-pcre/src/pkg/pcre"
)

type interval struct {
	start int
	end   int
}

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

	intervals, err := readData()
	if err != nil {
		return err
	}

	// Set up counters
	part1 := 0
	part2 := 0

	// Compile REs
	re1 := pcre.MustCompile("^(.+)\\1$", 0)
	re2 := pcre.MustCompile("^(.+)\\1+$", 0)

	// Process intervals
	for _, interval := range intervals {
		for i := interval.start; i <= interval.end; i++ {
			s := strconv.Itoa(i)
			result1 := re1.MatcherString(s, 0)
			if result1.Matches() {
				part1 += i
			}

			result2 := re2.MatcherString(s, 0)
			if result2.Matches() {
				part2 += i
			}
		}
	}
	fmt.Printf("Solution for part 1: %d\n", part1)
	fmt.Printf("Solution for part 2: %d\n", part2)

	return nil
}

// Read the file and convert it to an array of ranges.
func readData() ([]interval, error) {
	lines, err := readLines()
	if err != nil {
		return []interval{}, err
	}

	txt := strings.Join(lines, "")
	ranges := []interval{}
	for _, ele := range strings.Split(txt, ",") {
		parts := strings.Split(ele, "-")
		if len(parts) != 2 {
			return []interval{}, fmt.Errorf("invalid input format")
		}
		s, err := strconv.Atoi(parts[0])
		if err != nil {
			return []interval{}, err
		}
		e, err := strconv.Atoi(parts[1])
		if err != nil {
			return []interval{}, err
		}
		ranges = append(ranges, interval{s, e})
	}

	return ranges, nil
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

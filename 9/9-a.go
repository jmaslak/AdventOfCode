package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	// Data structure
	// sequences[sequence][row][col]
	sequences := make([][][]int, 0, 0)
	for scanner.Scan() {
		line := scanner.Text()
		matches := strings.Fields(line)

		sequences = append(sequences, make([][]int, 1, 1))
		for _, vStr := range matches {
			vInt, _ := strconv.Atoi(vStr)
			sequences[len(sequences)-1][0] = append(sequences[len(sequences)-1][0], vInt)
		}
	}

	// Fill in rows
	for i, sequence := range sequences {
		for anyNonZero(sequence[len(sequence)-1]) {
			seq := sequence[len(sequence)-1]
			prev := seq[0]
			seq = seq[1:]

			var out []int
			for _, num := range seq {
				out = append(out, num-prev)
				prev = num
			}
			sequence = append(sequence, out)

		}

		prevFirst := 0
		prevLast := 0
		for i := len(sequence) - 1; i >= 0; i-- {
			row := sequence[i]
			prevFirst = row[0] - prevFirst
			prevLast = row[len(row)-1] + prevLast

			out := make([]int, len(row)+2)
			out[0] = prevFirst
			copy(out[1:], row)
			out[len(out)-1] = prevLast

			sequence[i] = out
		}

		sequences[i] = sequence

	}

	sumFirst := 0
	sumLast := 0
	for _, sequence := range sequences {
		sumFirst = sumFirst + sequence[0][0]
		sumLast = sumLast + sequence[0][len(sequence[0])-1]
	}

	fmt.Print("Sum last (Part A): ")
	fmt.Println(sumLast)

	fmt.Print("Sum prev (Part B): ")
	fmt.Println(sumFirst)

}

func anyNonZero(seq []int) bool {
	for _, val := range seq {
		if val != 0 {
			return true
		}
	}
	return false
}

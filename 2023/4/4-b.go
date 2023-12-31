package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"

	"golang.org/x/exp/slices"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	reLine := regexp.MustCompile("^Card[ ]+([0-9]+):[ ]+([0-9 ]+) [|][ ]+([0-9 ]+)$")
	reNumber := regexp.MustCompile("[0-9]+")
	cardCounts := map[int]int{}
	for scanner.Scan() {
		line := scanner.Text()
		matches := reLine.FindStringSubmatch(line)
		card, err := strconv.Atoi(matches[1])
		if err != nil {
			fmt.Println(err)
			return
		}
		cardCounts[card]++

		winningStr := matches[2]
		mineStr := matches[3]

		winning := reNumber.FindAllString(winningStr, -1)
		mine := reNumber.FindAllString(mineStr, -1)

		winningNumbers := 0
		for _, num := range mine {
			if slices.Contains(winning, num) {
				winningNumbers++
			}
		}
		for num := card + 1; num <= card+winningNumbers; num++ {
			cardCounts[num] += cardCounts[card]
		}

	}

	sum := 0
	for _, v := range cardCounts {
		sum = sum + v
	}

	fmt.Print("Cards: ")
	fmt.Println(sum)
}

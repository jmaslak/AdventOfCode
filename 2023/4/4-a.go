package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"

	"golang.org/x/exp/slices"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	reLine := regexp.MustCompile("^Card[ ]+([0-9]+):[ ]+([0-9 ]+) [|][ ]+([0-9 ]+)$")
	reNumber := regexp.MustCompile("[0-9]+")
	sum := 0
	for scanner.Scan() {
		line := scanner.Text()
		matches := reLine.FindStringSubmatch(line)
		winningStr := matches[2]
		mineStr := matches[3]

		winning := reNumber.FindAllString(winningStr, -1)
		mine := reNumber.FindAllString(mineStr, -1)

		power := -1
		for _, num := range mine {
			if slices.Contains(winning, num) {
				power++
			}
		}
		if power >= 0 {
			sum = sum + (1 << power)
		}

	}
	fmt.Print("Winning points: ")
	fmt.Println(sum)
}

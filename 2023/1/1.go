package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
)

func main() {
	sum := 0
	scanner := bufio.NewScanner(os.Stdin)
	reFirst := regexp.MustCompile("([0-9]|one|two|three|four|five|six|seven|eight|nine).*")
	reLast := regexp.MustCompile(".*([0-9]|one|two|three|four|five|six|seven|eight|nine)")
	wordToNumMap := map[string]string{
		"one":   "1",
		"two":   "2",
		"three": "3",
		"four":  "4",
		"five":  "5",
		"six":   "6",
		"seven": "7",
		"eight": "8",
		"nine":  "9",
	}

	for scanner.Scan() {
		str := scanner.Text()
		matches := reFirst.FindStringSubmatch(str)
		first := matches[1]
		if wordToNumMap[first] != "" {
			first = wordToNumMap[first]
		}
		matches = reLast.FindStringSubmatch(str)
		last := matches[1]
		if wordToNumMap[last] != "" {
			last = wordToNumMap[last]
		}
		num, err := strconv.Atoi(first + last)
		if err != nil {
			log.Println(err)
			return
		}
		sum = sum + num
	}

	if err := scanner.Err(); err != nil {
		log.Println(err)
		return
	}

	fmt.Println(sum)
}

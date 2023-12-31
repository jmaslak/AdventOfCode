package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	reTime := regexp.MustCompile("^Time:[ ]+([0-9 ]+)$")
	reDistance := regexp.MustCompile("^Distance:[ ]+([0-9 ]+)$")

	times := make([]int, 0, 0)
	distances := make([]int, 0, 0)
	for scanner.Scan() {
		line := scanner.Text()
		if reTime.MatchString(line) {
			timeMatch := reTime.FindStringSubmatch(line)
			for _, v := range strings.Fields(timeMatch[1]) {
				i, err := strconv.Atoi(v)
				if err != nil {
					return
				}
				times = append(times, i)
			}
		} else if reDistance.MatchString(line) {
			distMatch := reDistance.FindStringSubmatch(line)
			for _, v := range strings.Fields(distMatch[1]) {
				i, err := strconv.Atoi(v)
				if err != nil {
					fmt.Println(err)
					return
				}
				distances = append(distances, i)
			}
		}
	}

	product := 1
	for i, maxtime := range times {
		wins := 0
		for time := 1; time < maxtime; time++ {
			dist := (maxtime - time) * time
			if dist > distances[i] {
				wins++
			}
		}
		product = product * wins
	}

	fmt.Print("Product of wins: ")
	fmt.Println(product)

}

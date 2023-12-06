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

	raceTime := 0
	raceDistance := 0
	for scanner.Scan() {
		line := scanner.Text()
		if reTime.MatchString(line) {
			timeMatch := reTime.FindStringSubmatch(line)
			timeStr := strings.Replace(timeMatch[1], " ", "", -1)
			var err error
			raceTime, err = strconv.Atoi(timeStr)
			if err != nil {
				return
			}
		} else if reDistance.MatchString(line) {
			distMatch := reDistance.FindStringSubmatch(line)
			distStr := strings.Replace(distMatch[1], " ", "", -1)
			var err error
			raceDistance, err = strconv.Atoi(distStr)
			if err != nil {
				fmt.Println(err)
				return
			}
		}
	}

	wins := 0
	for time := 1; time < raceTime; time++ {
		dist := (raceTime - time) * time
		if dist > raceDistance {
			wins++
		}
	}

	fmt.Print("Wins: ")
	fmt.Println(wins)

}

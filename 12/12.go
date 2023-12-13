package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

var cache map[string]int = make(map[string]int)

func main() {
	texts1 := make([]string, 0, 0)
	texts2 := make([]string, 0, 0)
	components1 := make([][]int, 0, 0)
	components2 := make([][]int, 0, 0)
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Fields(line)
		texts1 = append(texts1, parts[0])
		texts2 = append(texts2, parts[0]+"?"+parts[0]+"?"+parts[0]+"?"+parts[0]+"?"+parts[0])
		nums1 := strings.Split(parts[1], ",")
		nums2 := strings.Split(parts[1], ",")
		nums2 = append(nums2, strings.Split(parts[1], ",")...)
		nums2 = append(nums2, strings.Split(parts[1], ",")...)
		nums2 = append(nums2, strings.Split(parts[1], ",")...)
		nums2 = append(nums2, strings.Split(parts[1], ",")...)
		numbers1 := make([]int, 0, 0)
		numbers2 := make([]int, 0, 0)
		for _, num := range nums1 {
			num, _ := strconv.Atoi(num)
			numbers1 = append(numbers1, num)
		}
		for _, num := range nums2 {
			num, _ := strconv.Atoi(num)
			numbers2 = append(numbers2, num)
		}
		components1 = append(components1, numbers1)
		components2 = append(components2, numbers2)
	}

	sum1 := 0
	sum2 := 0
	for i, _ := range texts1 {
		sum1 = sum1 + combos(texts1[i], components1[i])
		sum2 = sum2 + combos(texts2[i], components2[i])
	}
	fmt.Print("Sum Part A: ")
	fmt.Println(sum1)
	fmt.Print("Sum Part B: ")
	fmt.Println(sum2)
}

func combos(str string, comp []int) int {
	key := str + ":"
	for _, v := range comp {
		key = key + string(v) + ":"
	}
	_, ok := cache[key]
	if ok {
		return cache[key]
	}

	reTrim := regexp.MustCompile("^[.]+")

	start := comp[0]
	comp = comp[1:]

	remaining := len(comp)
	for _, ele := range comp {
		remaining += ele
	}
	str = reTrim.ReplaceAllString(str, "")

	sum := 0

	for i := 0; i <= len(str)-remaining-start; i++ {
		if i > 0 && str[i-1] == '#' {
			cache[key] = sum
			return sum
		}
		flag := true
		for j := i; j < i+start; j++ {
			if str[j] == '.' {
				flag = false
			}
		}
		if flag {
			if len(comp) > 0 {
				if str[i+start] == '.' || str[i+start] == '?' {
					sum += combos(str[i+start+1:], comp)
				}
			} else {
				if len(str) <= (i + start) {
					cache[key] = sum + 1
					return sum + 1
				}
				flag := true
				for j := i + start; j < len(str); j++ {
					if str[j] == '#' {
						flag = false
					}
				}
				if flag {
					sum++
				}
			}
		}
	}
	cache[key] = sum
	return sum
}

package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Game struct {
	hand string
	bet  int
}

func (g *Game) SetBet(s string) (int, error) {
	bet, err := strconv.Atoi(s)
	if err != nil {
		return 0, err
	}
	g.bet = bet
	return bet, nil
}

type GameRune rune

func (r GameRune) Value() int {
	switch r {
	case 'J':
		return 1
	case '2':
		return 2
	case '3':
		return 3
	case '4':
		return 4
	case '5':
		return 5
	case '6':
		return 6
	case '7':
		return 7
	case '8':
		return 8
	case '9':
		return 9
	case 'T':
		return 10
	case 'Q':
		return 12
	case 'K':
		return 13
	case 'A':
		return 14
	}
	return 0
}

func (g Game) GetCounts() [][]GameRune {
	count := make(map[GameRune]int)
	jokers := 0
	for _, v := range g.hand {
		r := GameRune(v)
		if r != 'J' {
			_, ok := count[r]
			if !ok {
				count[r] = 0
			}
			count[r]++
		} else {
			jokers++
		}
	}

	if jokers == 5 {
		count['J'] = 5
		jokers = 0
	}

	invert := make([][]GameRune, 6, 6)
	for k, v := range count {
		invert[v] = append(invert[v], k)
	}

	for i := 5; i > 0; i-- {
		if jokers > 0 {
			if len(invert[i]) > 0 {
				invert[i+jokers] = append(invert[i+jokers], invert[i][0])
				invert[i] = invert[i][1:]
				jokers = 0
			}
		}
	}

	return invert
}

func (g Game) GetHandTypeVal() int {
	// 7 = 5 of a kind
	// 6 = 4 of a kind
	// 5 = full house
	// 4 = 3 of a kind
	// 3 = 2 pair
	// 2 = 1 pair
	// 1 = high card

	c := g.GetCounts()
	if len(c[5]) > 0 {
		return 7
	} else if len(c[4]) > 0 {
		return 6
	} else if len(c[3]) > 0 && len(c[2]) > 0 {
		return 5
	} else if len(c[3]) > 0 {
		return 4
	} else if len(c[2]) >= 2 {
		return 3
	} else if len(c[2]) > 0 {
		return 2
	}
	return 1
}

type Games []Game

func (g Games) Len() int      { return len(g) }
func (g Games) Swap(i, j int) { g[i], g[j] = g[j], g[i] }

func (g Games) Less(i, j int) bool {
	t1 := g[i].GetHandTypeVal()
	t2 := g[j].GetHandTypeVal()

	if t1 < t2 {
		return true
	} else if t1 > t2 {
		return false
	}

	for k, _ := range g[i].hand {
		v1 := GameRune(g[i].hand[k]).Value()
		v2 := GameRune(g[j].hand[k]).Value()

		if v1 < v2 {
			return true
		} else if v1 > v2 {
			return false
		}
	}
	return false
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	games := make(Games, 0, 0)
	for scanner.Scan() {
		line := scanner.Text()
		matches := strings.Fields(line)

		g := Game{hand: matches[0]}
		_, err := g.SetBet(matches[1])
		if err != nil {
			fmt.Println(err)
			return
		}
		games = append(games, g)
	}

	sort.Sort(games)

	sum := 0
	for i, g := range games {
		sum = sum + g.bet*(i+1)
	}

	fmt.Print("Sum of winnings: ")
	fmt.Println(sum)
}

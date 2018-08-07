package main

import (
	"fmt"

	"github.com/teamci/builder/test/fixtures/gometalinter/code/pass/mypkg"
)

func main() {
	fmt.Printf("Hello %s\n", mypkg.World())
}

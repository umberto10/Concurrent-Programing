package conf

import "time"

var Silent = true

var SizeM = 10
var SizeE = 10

var Workers = 2
var Customers = 3

var BossSleep = 500 * time.Millisecond
var CustomerSleep = 800 * time.Millisecond
var WorkerSleep = time.Second

var Operations = map[int]string{
	0: "Add",
	1: "Mul",
	2: "Sub",
	3: "Div",
}

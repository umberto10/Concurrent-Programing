package conf

import "time"

var Silent = true

var SizeM = 10
var SizeE = 10

const Workers = 2
var Customers = 3

const AddMachines = 3
const MulMachines = 3

var BossSleep = 500 * time.Millisecond
var CustomerSleep = 800 * time.Millisecond
var WorkerSleep = time.Second
const AddMachineSleep = 300 * time.Millisecond
const MulMachineSleep = 300 * time.Millisecond

var Operations = map[int]string{
	0: "Add",
	1: "Mul",
	2: "Sub",
	3: "Div",
}

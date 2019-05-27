package conf

import "time"

var Silent = true

var SizeM = 25
var SizeE = 25

const Workers = 10
const ServiceWorkers = 5
var Customers = 3

const AddMachines = 4
const MulMachines = 4

var BossSleep = 1 * time.Millisecond
var CustomerSleep = 800 * time.Millisecond
var WorkerSleep = 700 * time.Millisecond
const AddMachineSleep = 300 * time.Millisecond
const MulMachineSleep = 300 * time.Millisecond
const ServiceWorkerSleep = 100 * time.Millisecond

var Operations = map[int]string{
	0: "Add",
	1: "Mul",
	2: "Sub",
	3: "Div",
}

const AddMachineReliability int = 65
const MulMachineReliability int = 65

const ADD_MACHINE = 0
const MUL_MACHINE = 1

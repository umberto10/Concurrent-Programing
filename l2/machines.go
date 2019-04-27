package main

import (
	op "./conf"
	"time"
)

type sendTask struct {
	task *Task
	res  chan bool
}

type AddMachine struct {
	request chan sendTask
}

type MulMachine struct {
	request chan sendTask
}

func (m AddMachine)runAddMachine(id int) {
	for {
		current := <- m.request
		time.Sleep(op.AddMachineSleep)
		task := current.task
		switch task.operation {
		case op.Operations[0]:
			task.result = task.arg1 + task.arg2
		case op.Operations[2]:
			task.result = task.arg1 - task.arg2
		}
		
		current.res <- true
	}
}

func (m MulMachine)runMulMachine(id int) {
	for {
		current := <- m.request
		time.Sleep(op.MulMachineSleep)
		task := current.task
		
		task.result = task.arg1 * task.arg2
			
		current.res <- true
	}
}

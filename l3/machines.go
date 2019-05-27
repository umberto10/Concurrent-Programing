package main

import (
	op "./conf"
	"fmt"
	"math/rand"
	"time"
)

type sendTask struct {
	task *Task
	res  chan bool
}

type AddMachine struct {
	id         int
	request    chan sendTask
	broken     bool
	backdoor   chan bool
	collisions int
}

type MulMachine struct {
	id         int
	request    chan sendTask
	backdoor   chan bool
	broken     bool
	collisions int
}

type All_Machines struct {
	add [op.AddMachines]*AddMachine
	mul [op.AddMachines]*MulMachine
}

func (m *AddMachine) runAddMachine() {
	for {
		select {
		case <-m.backdoor:
			//fmt.Println("machine ", m.id, " fixed")
			m.broken = false
		case current := <-m.request:
			if !m.broken {
				time.Sleep(op.AddMachineSleep)
				task := current.task
				switch task.operation {
				case op.Operations[0]:
					if task.arg1-task.arg2 == 0 {
						task.result = -1
					} else {
						task.result = task.arg1 + task.arg2
					}

				case op.Operations[2]:
					if task.arg1-task.arg2 == 0 {
						task.result = -1
					} else {
						task.result = task.arg1 - task.arg2
					}
				}

				rel := rand.Int() % 100
				if rel >= op.AddMachineReliability {
					m.broken = true
					m.collisions += 1
					if !op.Silent {
						fmt.Println("Add Machine: ", m.id, " is broken now")
					}
				}
			} else {
				task := current.task
				task.result = 0
				//fmt.Println("add machine ", m.id, " not correct")
			}
			current.res <- true
		}
	}
}

func (m *MulMachine) runMulMachine() {
	for {
		select {
		case <-m.backdoor:
			m.broken = false
			//fmt.Println("machine ", m.id, " fixed")
		case current := <-m.request:
			if !m.broken {
				time.Sleep(op.MulMachineSleep)
				task := current.task
				if task.arg1 == 0 || task.arg2 == 0 {
					task.result = -1
				} else {
					task.result = task.arg1 * task.arg2
				}
				
				rel := rand.Int() % 100
				if rel >= op.MulMachineReliability {
					m.broken = true
					m.collisions += 1
					if !op.Silent {
						fmt.Println("Mul Machine: ", m.id, " is broken now")
					}
				}
			} else {
				task := current.task
				task.result = 0
				//fmt.Println("mul machine ", m.id, " not correct")
			}
			current.res <- true
		}
	}
}

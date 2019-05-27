package main

import (
	op "./conf"
	"fmt"
	"math/rand"
	"time"
)

func boss(e chan writeE) {

	cond := make(chan bool)

	for {
		time.Sleep(op.BossSleep)
		rand.Seed(time.Now().UTC().UnixNano())
		task := Task{op.Operations[rand.Intn(3)], rand.Intn(100), rand.Intn(100), 0} //(rand.Float64() * 100) + 100, (rand.Float64() * 100) + 100}

		if !op.Silent {
			fmt.Println("BOSS TASK: ", task)
		}

		write := writeE{cond, task}
		e <- write
		<-write.res //waiting for response
	}
}

type Worker struct {
	id           int
	accomplished int
	patience     int
	all_machines *All_Machines
}

func (w *Worker) worker(e chan readE, m chan writeE, service chan *ToFix) {

	cond := make(chan bool)
	cond1 := make(chan bool)
	w.accomplished = 0
	w.patience = rand.Intn(2)
	taskDone := false

	for {
		time.Sleep(op.WorkerSleep)
		ex := make(chan Task)
		request := readE{ex, cond}
		e <- request
		task := <-request.res

		toDo := sendTask{&task, make(chan bool)}
		done := false
		taskDone = false
		amount := 0

		if !op.Silent {
			fmt.Println("WORKER ", w.id, " TASK: ", task, "ACCOMPLISHED: ", w.accomplished)
		}

		for !taskDone {
			if !op.Silent {
				fmt.Println("Worker ", w.id, " trying ", task)
			}
			time.Sleep(100 * time.Millisecond)
			done = false
			switch task.operation {
			case op.Operations[1]:
				idx := rand.Intn(op.MulMachines)
				machine := w.all_machines.mul[idx]

				if w.patience == 1 {
					//fmt.Println("Worker ", w.id, " trying ", task, "inpatience")
					for !done {
						select {
						case machine.request <- toDo:
							done = <-toDo.res
						case <-time.After(500 * time.Millisecond):
							idx = rand.Intn(op.MulMachines)
							machine = w.all_machines.mul[idx]
						}
					}
				} else {
					//fmt.Println("Worker ", w.id, " trying ", task, " patience")
					machine.request <- toDo
					<-toDo.res
				}

				//fmt.Println("machine ", machine.id, " status ", machine.broken)

				if task.result != 0 {
					taskDone = true
					amount = 0
				} else {
					complain := &ToFix{machineType: op.MUL_MACHINE, machineIdx: idx, collisions: machine.collisions}
					service <- complain
					if !op.Silent && amount < 5 {
						fmt.Println("Worker: ", w.id, " complained to mul machine ", machine.id)
						amount++
					}
				}

			default:

				idx := rand.Intn(op.AddMachines)
				machine := w.all_machines.add[idx]

				if w.patience == 1 {
					//fmt.Println("Worker ", w.id, " trying ", task, " inpatience")
					for !done {
						select {
						case machine.request <- toDo:
							done = <-toDo.res
						case <-time.After(500 * time.Millisecond):
							idx = rand.Intn(op.AddMachines)
							machine = w.all_machines.add[idx]
						}
					}
				} else {
					//fmt.Println("Worker ", w.id, " trying ", task, " patience")
					machine.request <- toDo
					<-toDo.res
				}

				//fmt.Println("machine ", machine.id, " status ", machine.broken)

				if task.result != 0 {
					taskDone = true
					amount = 0

				} else {
					complain := &ToFix{machineType: op.ADD_MACHINE, machineIdx: idx, collisions: machine.collisions}
					service <- complain
					if !op.Silent && amount < 5 {
						fmt.Println("Worker: ", w.id, " complained to add machine ", machine.id)
						amount++
					}
				}
			}
		}
		//fmt.Println("Worker: ", w.id ," didn't finish")
		w.accomplished++

		write := writeE{cond1, task}
		if !op.Silent {
			fmt.Println("WORKER ", w.id, "RESULT: ", task, "ACCOMPLISHED: ", w.accomplished)
		}
		m <- write
		<-cond1
		<-cond
		close(ex)
	}
}

func customer(id int, in chan readE) {

	for {
		time.Sleep(op.CustomerSleep)
		done := make(chan bool)
		resultChan := make(chan Task, 10)
		result := readE{resultChan, done}

		in <- result

		<-done

		close(resultChan)

		for k := range resultChan {
			if !op.Silent {
				fmt.Println("CUSTOMER ", id, "GETTING RESULT: ", k.result)
			}
		}
	}
}

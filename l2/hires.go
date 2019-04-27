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
	id int
	accomplished int
	patience int
	addMachines *[op.AddMachines]AddMachine
	mulMachines *[op.MulMachines]MulMachine
}

func (w *Worker)worker(e chan readE, m chan writeE) {

	cond := make(chan bool)
	cond1 := make(chan bool)
	w.accomplished = 0
	w.patience = rand.Intn(2)

	for {
		time.Sleep(op.WorkerSleep)
		ex := make(chan Task)
		request := readE{ex, cond}
		e <- request
		task := <-request.res

		if !op.Silent {
			fmt.Println("WORKER ", w.id, " TASK: ", task, "ACCOMPLISHED: ", w.accomplished)
		}

		toDo := sendTask{&task, make(chan bool)}
		done := false

		switch task.operation {
		case op.Operations[1]:
			machine := w.mulMachines[rand.Intn(op.MulMachines)]
			if w.patience == 1 {
				for !done {
					select {
					case machine.request <- toDo:
						done = <- toDo.res
					case <- time.After(500 * time.Millisecond):
						machine = w.mulMachines[rand.Intn(op.MulMachines)]
					}
				}
			} else {
				machine.request <- toDo
				<- toDo.res
			}
		default:
			machine := w.addMachines[rand.Intn(op.AddMachines)]
			if w.patience == 0 {
				for !done {
					select {
					case machine.request <- toDo:
						done = <- toDo.res
					case <- time.After(500 * time.Millisecond):
						machine = w.addMachines[rand.Intn(op.AddMachines)]
					}
				}
			} else {
				machine.request <- toDo
				<- toDo.res
			}
		}
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

package main

import (
	op "./conf"
	"container/list"
	"fmt"
	"math/rand"
	"time"
)

type readE struct {
	res  chan Task
	done chan bool
}

type writeE struct {
	res  chan bool
	task Task
}

type Magazine struct {
	magazine *list.List
}

type Exercises struct {
	exercises *list.List
}

type Task struct {
	operation string
	arg1      int //float64
	arg2      int //float64
	result    int
}

func guardExercisesIn(cond bool, res chan writeE) chan writeE {
	if cond {
		return res
	}
	return nil
}

func guardExercisesOut(cond bool, res chan readE) chan readE {
	if cond {
		return res
	}
	return nil
}

func (e *Exercises) runExServ(inE chan writeE, outE chan readE) {
	for {
		select {
		case request := <-guardExercisesIn(e.exercises.Len() < op.SizeE, inE):
			e.exercises.PushBack(request.task)
			request.res <- true

		case response := <-guardExercisesOut(e.exercises.Len() > 0, outE):
			task := e.exercises.Front().Value.(Task)
			e.exercises.Remove(e.exercises.Front())
			response.res <- task
			response.done <- true
		}
	}
}

func guardMagazineIn(cond bool, res chan writeE) chan writeE {
	if cond {
		return res
	}
	return nil
}

func guardMagazineOut(cond bool, res chan readE) chan readE {
	if cond {
		return res
	}
	return nil
}

func (m *Magazine) runMagServ(inM chan writeE, outM chan readE) {
	for {
		select {
		case request := <-guardMagazineIn(m.magazine.Len() < op.SizeM, inM):
			m.magazine.PushBack(request.task)
			request.res <- true

		case response := <-guardMagazineOut(m.magazine.Len() > 0, outM):
			m.getResults(response.res)
			response.done <- true
		}
	}
}

func (m *Magazine) getResults(out chan Task) {
	for e := m.magazine.Front(); e != nil; e = e.Next() {
		rand.Seed(time.Now().UTC().UnixNano())
		if rand.Intn(2) != 0 {
			a := e.Value.(Task)
			m.magazine.Remove(e)
			out <- a
		}
	}
}

func main() {

	var e = Exercises{list.New()}
	var m = Magazine{list.New()}

	var workers [op.Workers]*Worker

	var inE = make(chan writeE, 1)
	var outE = make(chan readE, 1)

	var inR = make(chan writeE, 1)
	var outR = make(chan readE, 1)

	var addMachines [op.AddMachines]AddMachine
	var mulMachines [op.MulMachines]MulMachine
	addChannel := make(chan sendTask)
	mulChannel := make(chan sendTask)

	go e.runExServ(inE, outE)
	go m.runMagServ(inR, outR)

	for i := 0; i < op.AddMachines; i++ {
		addMachines[i] = AddMachine{addChannel}
	}

	for i := 0; i < op.MulMachines; i++ {
		mulMachines[i] = MulMachine{mulChannel}
	}

	for i := 0; i < op.Workers; i++ {
		workers[i] = &Worker{i, 0, 0, &addMachines, &mulMachines}
	}
	
	for i, m := range addMachines {
		go m.runAddMachine(i)
	}
	
	for i, m := range mulMachines {
		go m.runMulMachine(i)
	}

	go boss(inE)

	for _, w := range workers {
		go w.worker(outE, inR)
	}

	for i := 0; i < op.Customers; i++ {
		go customer(i, outR)
	}

	var choose int
	for {
		if op.Silent {
			fmt.Println("Welcome!")
			fmt.Println("0 - print magazine")
			fmt.Println("1 - print taskas")
			fmt.Println("2 - print workers")
			fmt.Println("3 - change mode")

			fmt.Scanf("%d", &choose)
			switch choose {
			case 0:
				fmt.Println("MAGAZINE: ")
				for m := m.magazine.Front(); m != nil; m = m.Next() {
					fmt.Printf("%v\n", m.Value)
				}
			case 1:
				fmt.Println("TASKS: ")
				for e := e.exercises.Front(); e != nil; e = e.Next() {
					fmt.Printf("%v\n", e.Value)
				}
			case 2:
				fmt.Println("WORKERS: ")
				for _, w := range workers {
					fmt.Println("id: ", w.id, "accomplished: ", w.accomplished, " patience: ", w.patience)
				}
			case 3:
				fmt.Println("Changing mode...")
				op.Silent = false
				time.Sleep(time.Second)
			default:
				op.Silent = true
			}
		} else {
			fmt.Scanf("%d", &choose)
			op.Silent = true
		}
	}
}

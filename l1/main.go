package main

import (
	op "./conf"
	"container/list"
	"fmt"
	"math/rand"
	"time"
)

type readM struct {
	res  chan Result
	done chan bool
}

type readE struct {
	res chan Task
}

type writeM struct {
	res    chan bool
	result Result
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
}

type Result struct {
	operation string
	result    int //float64
}

func (t *Task) makeResult() Result {
	r := Result{}
	switch t.operation {
	case op.Operations[0]:
		r.result = t.arg1 + t.arg2
		r.operation = "Add"
	case op.Operations[1]:
		r.result = t.arg1 * t.arg2
		r.operation = "Mul"
	case op.Operations[2]:
		r.result = t.arg1 - t.arg2
		r.operation = "Sub"
		//case op.Operations[3]:
		//	r.result = t.arg1 / t.arg2
		//	r.operation = "Div"
	}
	return r
}

func boss(e chan writeE) {

	cond := make(chan bool)

	for {
		time.Sleep(op.BossSleep)
		rand.Seed(time.Now().UTC().UnixNano())
		task := Task{op.Operations[rand.Intn(3)], rand.Intn(100), rand.Intn(100)} //(rand.Float64() * 100) + 100, (rand.Float64() * 100) + 100}

		if !op.Silent {
			fmt.Println("BOSS TASK: ", task)
		}

		write := writeE{cond, task}
		e <- write
		<-write.res //waiting for response
	}
}

func worker(id int, e chan readE, m chan writeM) {

	cond := make(chan bool)

	for {
		time.Sleep(op.WorkerSleep)
		ex := make(chan Task)
		request := readE{ex}
		e <- request
		task := <-request.res

		if !op.Silent {
			fmt.Println("WORKER ", id, " TASK: ", task)
		}
		r := task.makeResult()

		write := writeM{cond, r}
		if !op.Silent {
			fmt.Println("WORKER ", id, "RESULT: ", r)
		}
		m <- write
		<-cond
		close(ex)
	}
}

func customer(id int, in chan readM) {

	for {
		time.Sleep(op.CustomerSleep)
		done := make(chan bool)
		resultChan := make(chan Result, 10)
		result := readM{resultChan, done}

		in <- result

		<-done

		close(resultChan)

		for k := range resultChan {
			if !op.Silent {
				fmt.Println("CUSTOMER ", id, "GETTING RESULT: ", k)
			}
		}
	}
}

func (m *Magazine) getResults(out chan Result) {
	for e := m.magazine.Front(); e != nil; e = e.Next() {
		rand.Seed(time.Now().UTC().UnixNano())
		if rand.Intn(2) != 0 {
			a := e.Value.(Result)
			m.magazine.Remove(e)
			out <- a
		}
	}
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
		}
	}
}

func guardMagazineIn(cond bool, res chan writeM) chan writeM {
	if cond {
		return res
	}
	return nil
}

func guardMagazineOut(cond bool, res chan readM) chan readM {
	if cond {
		return res
	}
	return nil
}

func (m *Magazine) runMagServ(inM chan writeM, outM chan readM) {
	for {
		select {
		case request := <-guardMagazineIn(m.magazine.Len() < op.SizeM, inM):
			m.magazine.PushBack(request.result)
			request.res <- true

		case response := <-guardMagazineOut(m.magazine.Len() > 0, outM):
			m.getResults(response.res)
			response.done <- true
		}
	}
}

func main() {

	var e = Exercises{list.New()}
	var m = Magazine{list.New()}

	var inE = make(chan writeE, 1)
	var outE = make(chan readE, 1)

	var inR = make(chan writeM, 1)
	var outR = make(chan readM, 1)

	go e.runExServ(inE, outE)
	go m.runMagServ(inR, outR)

	go boss(inE)

	for i := 0; i < op.Workers; i++ {
		go worker(i, outE, inR)
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
			fmt.Println("2 - change mode")

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
				fmt.Println("Changeing mode...")
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

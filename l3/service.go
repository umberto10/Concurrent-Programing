package main

import (
	op "./conf"
	"fmt"
	"time"
)

type ToFix struct {
	machineIdx  int
	machineType int
	collisions  int
}

type ServiceWorker struct {
	id int
	isBusy bool
	all_machines *All_Machines
}

type Service struct {
	toFix     chan *ToFix
	res       chan *ToFix
	s_workers [op.ServiceWorkers]*ServiceWorker

	addMachines [op.AddMachines]bool
	addStatus   [op.AddMachines]bool
	addHistory  [op.AddMachines]int

	mulMachines [op.MulMachines]bool
	mulStatus   [op.MulMachines]bool
	mulHistory  [op.MulMachines]int
}

func (s *Service) deputeWorker() *ServiceWorker {
	for _, sw := range s.s_workers {
		if !sw.isBusy {
			return sw
		}
	}
	return nil
}

func (s *Service) start() {
	s.res = make(chan *ToFix)

	for i := 0; i < op.AddMachines; i++ {
		s.addMachines[i] = true
		s.addStatus[i] = false
		s.addHistory[i] = 0
	}

	for i := 0; i < op.AddMachines; i++ {
		s.mulMachines[i] = true
		s.mulStatus[i] = false
		s.mulHistory[i] = 0
	}

	for {
		select {
		case com := <-s.toFix:

			curColl := com.collisions

			switch com.machineType {
			case op.ADD_MACHINE:	
				if s.addMachines[com.machineIdx] && s.addHistory[com.machineIdx] < curColl {
					//fmt.Println("send to add")
					s.addHistory[com.machineIdx] = curColl
					s.addMachines[com.machineIdx] = false
				}
			case op.MUL_MACHINE:
				if s.mulMachines[com.machineIdx] && s.mulHistory[com.machineIdx] < curColl {
					//fmt.Println("send to mul")
					s.mulHistory[com.machineIdx] = curColl
					s.mulMachines[com.machineIdx] = false
				}
			}
			
		case res := <-s.res:
			switch res.machineType {
			case op.ADD_MACHINE:
				s.addMachines[res.machineIdx] = true
				s.addStatus[res.machineIdx] = false
			case op.MUL_MACHINE:
				s.mulMachines[res.machineIdx] = true
				s.mulStatus[res.machineIdx] = false
			}
		}

		serviceWorker := s.deputeWorker()

		if serviceWorker != nil {
			for i := 0; i < op.AddMachines; i++ {
				if !s.addStatus[i] && !s.addMachines[i] {
					serviceWorker.isBusy = true
					s.addStatus[i] = true
					//fmt.Println("to_fiix for: ", i)
					go serviceWorker.fix_this(&ToFix{machineIdx: i, machineType: op.ADD_MACHINE}, s.res)
					break
				}
			}
		}

		serviceWorker = s.deputeWorker()

		if serviceWorker != nil {
			for i := 0; i < op.MulMachines; i++ {
				if !s.mulStatus[i] && !s.mulMachines[i] {
					serviceWorker.isBusy = true
					s.mulStatus[i] = true
					//fmt.Println("to_fiix for: ", i)
					go serviceWorker.fix_this(&ToFix{machineIdx: i, machineType: op.MUL_MACHINE}, s.res)
					break
				}
			}
		}
	}
}

func (sw *ServiceWorker) fix_this(failure *ToFix, res chan *ToFix) {
	time.Sleep(op.ServiceWorkerSleep)

	machType := failure.machineType
	idx := failure.machineIdx

	//fmt.Println("fixing...")
	switch machType {
	case op.ADD_MACHINE:
		tmpMach := sw.all_machines.add[idx]
		tmpMach.backdoor <- true

		if !op.Silent {
			fmt.Println("Service Worker: ", sw.id, "fixed add machine nr: ", tmpMach.id)
		}
	case op.MUL_MACHINE:
		tmpMach := sw.all_machines.mul[idx]
		tmpMach.backdoor <- true

		if !op.Silent {
			fmt.Println("Service Worker: ", sw.id, "fixed add machine nr: ", tmpMach.id)
		}
	}

	res <- failure
	sw.isBusy = false
}



package body Hires is
   
   task body Boss is
	  SimpleEx : Ex;
	  B_Delay : Ada.Numerics.Float_Random.Generator;
	  OpRnd : Op_Rnd.Generator;
	  ArgRnd : Boss_Rnd.Generator;
   begin
	  Op_Rnd.Reset(OpRnd);
	  Boss_Rnd.Reset(ArgRnd);
	  Ada.Numerics.Float_Random.Reset(B_Delay);
	  loop
		 SimpleEx.Arg1 := Boss_Rnd.Random(ArgRnd);
		 SimpleEx.Arg2 := Boss_Rnd.Random(ArgRnd);
		 SimpleEx.Operation := (case Op_Rnd.Random(OpRnd) is
			when 0 => '+',
		    when 1 => '-',
			when 2 => '*');
		 
		 ExServ.AddTask(SimpleEx);
		 if (not Conf.Silent) then
			Put_Line("[ Boss " & Integer'Image(SimpleEx.Arg1) & " " & SimpleEx.Operation & Integer'Image(SimpleEx.Arg2) & " ]");
		 end if;
		 delay Duration(Conf.BossSleep * 3.0 * Ada.Numerics.Float_Random.Random(B_Delay));
	  end loop;
	end Boss;	

   task body Customer is
      ToDisplay : Ex;
      C_Delay : Ada.Numerics.Float_Random.Generator;
   begin
	  Ada.Numerics.Float_Random.Reset(C_Delay);
	  loop	 
	  MagServ.GetResult(ToDisplay);
	   if (not Conf.Silent) then
			Put_Line("[ Customer " & Integer'Image(ToDisplay.Res) & " " & ToDisplay.Operation & " ]");
	   end if;
	   delay Duration(Conf.CustomerSleep * 2.0 * Ada.Numerics.Float_Random.Random(C_Delay));
	   end loop;
   end Customer;
    
   task body Worker_Start is
	  subtype range100 is Integer range 0 .. 100;
      package Rand_Int is new Ada.Numerics.Discrete_Random(range100);
      use Rand_Int;
      gen : Rand_Int.Generator;
      r : Integer;
      
	  ExToDo : Ex;
	  Going : Ex_Acc;
      done : Boolean;
	  JobDone : Boolean := False;
	  Amount : Integer;
	  
      Curr_AddMachine : AddMachine_Acc;
	  Curr_MulMachine : MulMachine_Acc;
   begin
		 loop
			delay Conf.WorkerDelay;
			ExServ.GetTask(ExToDo);
			Going := new Ex'(Operation => ExToDo.Operation, Arg1 => ExToDo.Arg1, Arg2 => ExToDo.Arg2, Res => 0);
			Done := False;
			JobDone := False;
            amount := 0;
			
            while not JobDone loop
			   done := False;
				
			   case ExToDo.Operation is 
				  when '*' =>
					 r := Random(gen) mod Conf.No_MulMachines + 1;
					 Curr_MulMachine := Curr.mulMachines(r);
					 if Curr.Patience = 0 then
						Curr_MulMachine.Compute(Going);
					 else
						while not done loop
						   select
							  Curr_MulMachine.Compute(Going);
							  done := True;
						   else
							  delay Conf.delayedPatience;
							  r := Random(gen) mod Conf.No_MulMachines + 1;
							  Curr_MulMachine := Curr.mulMachines(R);
						   end select;
						end loop;
					 end if;
					 
					 if Going.Res = 0 then
						ServiceTask.Com(Fail => new Failure'(MachineType => Conf.MUL_MACHINE,
														 MachineIdx => R,
														 Collisions => Curr_MulMachine.getCollisions));
						if not Conf.Silent and amount < 5 then
                        Ada.Text_IO.Put_Line("Worker(id:" & Integer'Image(Curr.id) & ") is complainig on mul machine {" & Integer'Image(r) & "} ");
                         amount := amount + 1;
                     end if;
                  else
                      JobDone := True;
					 end if;
					 
			   when others =>
				  r := Random(gen) mod Conf.No_AddMachines + 1;
                   Curr_AddMachine := Curr.AddMachines(R);
                   if Curr.Patience = 0 then
                     Curr_AddMachine.Compute(Going);
                   else
                     while not done loop
                        select
                           Curr_AddMachine.Compute(Going);
                           done := True;
                        else
                           delay Conf.delayedPatience;
                           r := Random(gen) mod Conf.No_AddMachines + 1;
                           Curr_AddMachine := Curr.AddMachines(R);
                        end select;
                     end loop;
                   end if;
				   
				   if Going.Res = 0 then
						ServiceTask.Com(Fail => new Failure'(MachineType => Conf.ADD_MACHINE,
														 MachineIdx => R,
														 Collisions => Curr_AddMachine.getCollisions));
						if not Conf.Silent and amount < 5 then
                        Ada.Text_IO.Put_Line("Worker(id:" & Integer'Image(curr.id) & ") is complainig on add machine {" & Integer'Image(r) & "} ");
                         amount := amount + 1;
                     end if;
                  else
                      JobDone := True;
					 end if;
				   
			   end case;
			end loop;	
			
			Curr.Accomplished := Curr.Accomplished + 1;
			ExToDo.Res := Going.Res;
			MagServ.AddResult(ExToDo);
			
			if (not Conf.Silent) then
			Put_Line("[ Worker id: " & Integer'Image(Curr.Id) & " " & Integer'Image(ExToDo.Arg1) & " " & ExToDo.Operation & Integer'Image(ExToDo.Arg2) & " = "  & Integer'Image(ExToDo.Res) & "]");
end if;		   
	     end loop;
   end Worker_Start;
   
    task body Customer_Start is
	  type Customer_Acc_Arr is array (1 .. Conf.Customers) of Customer_Acc;
	  Customers : Customer_Acc_Arr;
   begin
	  for I in 1 .. Conf.Workers loop
		 Customers(I) := new Customer(I);
	  end loop;
   end Customer_Start;

end Hires;

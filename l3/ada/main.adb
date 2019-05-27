with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Hires; use Hires;
with Servs; use Servs;
with Service; use Service;
with Machines; use Machines;
with Conf;

procedure Main is
   subtype range2 is Integer range 1..2;
   package Rand_Int is new Ada.Numerics.Discrete_Random(range2);
   use Rand_Int;
   gen : Rand_Int.Generator;
   bool : range2;
   Rnd_Patience : Integer;
   
   addMachines_array : AddMachines_Acc := AddMachinesArr'Access;
   mulMachines_array : MulMachines_Acc := MulMachinesArr'Access;
   
   Begin_Boss : Boss;
   Begin_Customers : Customer_Start;
   
   User_Choice : Character;
begin
   
   
    for I in 1..Conf.No_AddMachines loop
      addMachines_array(I) := new AddMachine;
      addMachines_array(I).SetId(identity => I);
   end loop;

   for I in 1..Conf.No_MulMachines loop
      mulMachines_array(I) := new MulMachine;
      mulMachines_array(I).SetId(identity => I);
end loop;
   
   for I in 1..Conf.ServiceWorkers loop
         sw_array(I) :=
           new ServiceWorker'(id        => I,
                            isBusy      => False,
                            addMachines => addMachines_array,
                            mulMachines => mulMachines_array);

   end loop;
   
   for I in 1..Conf.Workers loop
	  Rand_Int.Reset(gen);
	  bool := Random(gen);
	  
	  if (bool = 1) then
         Rnd_Patience := 1;
      else
         Rnd_Patience := 0;
	  end if;
	  
	  workers_arr(I) := new Worker'(id => I-1, accomplished => 0, patience => Rnd_Patience, addMachines => addMachines_array, mulMachines => mulMachines_array);
      end loop;
	  
	  for J in 1..Conf.Workers loop
		 workers_tasks(J) := new Worker_Start(Curr => workers_arr(J));
	  end loop;
	  
	  for I in 1..Conf.ServiceWorkers loop
         S_Tasks(I) :=  new ServiceWorkerStart(curr => sw_array(I));
	  end loop;
		 
	  loop
	     Put_Line("Welcome!");
	     Put_Line("0 - print magazine");
	     Put_Line("1 - print taskas");
		 Put_Line("2 - print workers");
	     Put_Line("3 - change mode");
		 Put_Line("4 - machine status");
		 Put_Line("5 - service workers");
	  
         get(User_Choice);  
         case User_Choice is
            when '0'    => MagServ.Show;
            when '1'    => ExServ.Show;
			when '2'    => 
                  for I in 1..Conf.Workers loop
                     Put_Line("{Worker Id:" & Integer'Image(workers_arr(I).Id) & ", Completed: " & Integer'Image(workers_arr(I).accomplished) & ", isPatient: " & Integer'Image(workers_arr(I).Patience) & "}");
                  end loop;
            when '3'    => Conf.Silent := False;
			when '4' => Put("Add Machines : [");
               for I in 1..Conf.No_AddMachines loop
                  Put("{ id:" & Integer'Image(I) &  ", isBroken: " & Boolean'Image(addMachines_array(I).IsBroken) & ", collisions: " & Integer'Image(addMachines_array(I).GetCollisions) & "}");
               end loop;
               Put_Line("]");
               Put("Mul Machines : [");
               for I in 1..Conf.No_MulMachines loop
                  Put("{ id:" & Integer'Image(I) & ", isBroken: " & Boolean'Image(mulMachines_array(I).IsBroken) & ", collisions: " & Integer'Image(mulMachines_array(I).GetCollisions) & "}");
               end loop;
			   Put_Line("]");
			when '5' =>
			   Put("Service workers :[");
                  for I in 1..Conf.ServiceWorkers loop
                     Put("{ id:" & Integer'Image(sw_array(I).id) &  ", isBusy: " & Boolean'Image(sw_array(I).isBusy) & "}");
                  end loop;
				  Put_Line("]");
            when others => Conf.Silent := True;
               null;
         end case;
      end loop;

end Main;

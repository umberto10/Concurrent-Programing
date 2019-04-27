with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Hires; use Hires;
with Servs; use Servs;
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
		 
	  loop
	     Put_Line("Welcome!");
	     Put_Line("0 - print magazine");
	     Put_Line("1 - print taskas");
		 Put_Line("2 - print workers");
	     Put_Line("3 - change mode");
	  
         get(User_Choice);  
         case User_Choice is
            when '0'    => MagServ.Show;
            when '1'    => ExServ.Show;
			when '2'    => 
                  for I in 1..Conf.Workers loop
                     Put_Line("{Worker Id:" & Integer'Image(workers_arr(I).Id) & ", Completed: " & Integer'Image(workers_arr(I).accomplished) & ", isPatient: " & Integer'Image(workers_arr(I).Patience) & "}");
                  end loop;
            when '3'    => Conf.Silent := False;
            when others => Conf.Silent := True;
               null;
         end case;
      end loop;

end Main;

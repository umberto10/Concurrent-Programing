with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Servs; use Servs;
with Machines; use Machines;
with Conf;

package Hires is
   
   type Worker is record
	  Id : Integer;
	  accomplished : Integer;
	  patience : Integer;
	  addMachines : AddMachines_Acc;
	  mulMachines : MulMachines_Acc;
   end record;
   
   type Worker_Acc is access Worker;
   
   task type Boss;
   task type Customer(Id : Integer);
   task type Worker_Start(Curr : Worker_Acc);
   task type Customer_Start;
   
   
   type Customer_Acc is access Customer;
   
   type Worker_Start_Acc is access Worker_Start;
   type WorkersTasks is array (1..Conf.Workers) of Worker_Start_Acc;
   type workers is array (1..Conf.Workers) of Worker_Acc;
   
   workers_arr: workers;
   workers_tasks: WorkersTasks;
   
   subtype Int_Range is Integer range 0 .. 1000;
   subtype Op_Range is Integer range 0 .. 2;
     	
   package Boss_Rnd is new Ada.Numerics.Discrete_Random
	 (Result_Subtype => Int_Range);
	 
   package Op_Rnd is new Ada.Numerics.Discrete_Random
	 (Result_Subtype => Op_Range);
   
end Hires;

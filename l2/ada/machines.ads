with Servs; use Servs;
with Conf;

package Machines is
   protected type AddMachine is
	  entry Compute(Ex : in Ex_Acc);
   end AddMachine;
   
   protected type MulMachine is
	  entry Compute(Ex : in Ex_Acc);
   end MulMachine;
   
   type AddMachine_Acc is access AddMachine;
   type MulMachine_Acc is access MulMachine;
      
   type AddMachines is array (1..Conf.No_AddMachines) of AddMachine_Acc;
   type AddMachines_Acc is access all AddMachines;
   type MulMachines is array (1..Conf.No_MulMachines) of MulMachine_Acc;
   type MulMachines_Acc is access all MulMachines;
   
   AddMachinesArr: aliased AddMachines := (others => new AddMachine);
   MulMachinesArr: aliased MulMachines := (others => new MulMachine);
end Machines;

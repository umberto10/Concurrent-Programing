with Servs; use Servs;
with Ada.Text_IO;
with Ada; use Ada;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;
with Conf;

package Machines is
   
   subtype range100Machines is Integer range 0 .. 100;
   package Rand_Int_M is new Ada.Numerics.Discrete_Random(range100Machines);
   use Rand_Int_M;
   
   protected type AddMachine is
	  entry Compute(Ex : in Ex_Acc);
	  procedure SetId(identity : Integer);
	  entry Backdoor;
	  function GetCollisions return Integer;
	  function isBroken return Boolean;
   private
	  Id: Integer;
	  Broken: Boolean := False;
	  Collisions: Integer := 0;
	  gen : Rand_Int_M.Generator;
	  sensitive: Range100Machines;	
	  R: Integer;
   end AddMachine;
   
   protected type MulMachine is
	  entry Compute(Ex : in Ex_Acc);
	  procedure SetId(identity : Integer);
	  entry Backdoor;
	  function GetCollisions return Integer;
	  function isBroken return Boolean;
   private
	  Id: Integer;
	  Broken: Boolean := False;
	  Collisions: Integer := 0;
	  gen : Rand_Int_M.Generator;
	  sensitive: Range100Machines;	
	  R: Integer;
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

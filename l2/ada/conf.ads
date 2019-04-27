package Conf is
   
   Silent : Boolean := True;

   SizeM : constant Integer := 10;
   SizeE : constant Integer := 10;

   Workers : constant Integer := 2;
   Customers : constant Integer := 3;
   
   No_AddMachines : constant Integer := 3;
   No_MulMachines : constant Integer := 3;
   
   delayedPatience : Duration := 0.3;
   
   BossSleep : constant float := 0.1;
   CustomerSleep : constant float := 1.5;
   WorkerDelay : constant Duration := 1.0;
   AddMachineSleep : constant Duration := 0.8;
   MulMachineSleep : constant Duration := 0.8;
	 
 end Conf;

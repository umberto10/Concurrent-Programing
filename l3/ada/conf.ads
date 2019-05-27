package Conf is
   
   Silent : Boolean := True;

   SizeM : constant Integer := 10;
   SizeE : constant Integer := 10;
   
   ServiceWorkers : constant Integer := 2;
   Workers : constant Integer := 3;
   Customers : constant Integer := 2;
   
   No_AddMachines : constant Integer := 3;
   No_MulMachines : constant Integer := 3;
   
   delayedPatience : Duration := 0.3;
   ServiceWorker_Delay : Duration := 0.2;
   
   BossSleep : constant float := 0.1;
   CustomerSleep : constant float := 1.5;
   WorkerDelay : constant Duration := 1.0;
   AddMachineSleep : constant Duration := 0.8;
   MulMachineSleep : constant Duration := 0.8;
   
   AddMachineReliability : constant Integer := 65;
   MulMachineReliability : constant Integer := 65;
   
   ADD_MACHINE : constant Integer := 0;
   MUL_MACHINE : constant Integer := 1;
 end Conf;

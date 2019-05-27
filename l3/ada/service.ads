with Conf;
with Servs; use Servs;
with Machines; use Machines;

package Service is
   pragma Elaborate_Body (Service);
   
   type Failure is record
	  machineType: Integer;
	  machineIdx: Integer;
	  collisions: Integer;
   end record;
   
   type Fail_Acc is access Failure;
   
   type ServiceWorker is record
	  Id: Integer;
	  IsBusy: Boolean;
	  AddMachines: AddMachines_Acc;
	  MulMachines: MulMachines_Acc;
   end record;
   
   type SW_Acc is access ServiceWorker;
   type S_Workers is array (1..Conf.ServiceWorkers) of SW_Acc;
   
   task type ServiceWorkerStart(curr: SW_Acc) is
	  entry Fix_This(Fail: in Fail_Acc);
   end ServiceWorkerStart;
   
   type SW_Start_Acc is access ServiceWorkerStart;
  
   type ServicesTask is array (1..Conf.ServiceWorkers) of SW_Start_Acc;
   
   task ServiceTask is
	  entry Res(Fail: in Fail_Acc);
	  entry Com(Fail: in Fail_Acc);
   end ServiceTask;
   
   Sw_Array: S_Workers;
   S_Tasks: ServicesTask;
end Service;

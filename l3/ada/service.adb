with Conf;
with Machines; use Machines;
with Servs; use Servs;
with Ada.Text_IO;

Package body Service is
   
   task body ServiceWorkerStart is
	  Current : Fail_Acc;
   begin
	  loop
		 select
			accept Fix_This(Fail: in Fail_Acc) do
			   Current := Fail;
			end Fix_This;
			
			delay Conf.ServiceWorker_Delay;
			
			case Current.MachineType is
			   when Conf.ADD_MACHINE =>
				  Curr.AddMachines(Current.machineIdx).Backdoor;
				  if not Conf.Silent then
                     Ada.Text_IO.Put_Line("Service Worker: {" & Integer'Image(curr.id) & " } fix {" & Integer'Image(current.machineIdx) & "} add machine");
				  end if;
				  
			   when Conf.MUL_MACHINE =>
				  Curr.MulMachines(Current.machineIdx).Backdoor;
				  if not Conf.Silent then
					 Ada.Text_IO.Put_Line("Service Worker: {" & Integer'Image(curr.id) & " } fix {" & Integer'Image(current.machineIdx) & "} mul machine");
				  end if;
				  
			   when others =>
				  if not Conf.Silent then
					 Ada.Text_IO.Put_Line("No such machine type.");
				  end if;
				  
			end case;
			
			ServiceTask.Res(Fail => Current);
			Curr.IsBusy := False;
			
		 end select;
	  end loop;
   end ServiceWorkerStart;
   
   task body ServiceTask is
	  type AddMachineStatus is array (1..Conf.No_AddMachines) of Boolean;
	  type MulMachineStatus is array (1..Conf.No_MulMachines) of Boolean;
	  
	  type AddMachinesHistory is array (1..Conf.No_AddMachines) of Integer;
	  type MulMachinesHistory is array (1..Conf.No_MulMachines) of Integer;
	  
	  AddStatus: AddMachineStatus := (others => false);
	  MulStatus: MulMachineStatus := (others => false);
	  
	  AddWorking: AddMachineStatus := (others => true);
	  MulWorking: MulMachineStatus := (others => true);
	  
	  AddHistory: AddMachinesHistory := (others => 0);
	  MulHistory: MulMachinesHistory := (others => 0);
	  
	  cw: SW_Acc;
	  Current: Fail_Acc;
	  Found: Boolean;
	  
   begin
	  loop
		 select
			accept Res(Fail: in Fail_Acc) do
			   Current := Fail;
			end Res;
			
			case Current.MachineType is
			   when Conf.ADD_MACHINE =>
				  AddStatus(Current.machineIdx) := False;
				  AddWorking(Current.machineIdx) := True;
			   when Conf.MUL_MACHINE =>
				  MulStatus(Current.machineIdx) := False;
				  MulWorking(Current.machineIdx) := True;
			   when others =>
				   if not Conf.Silent then
					 Ada.Text_IO.Put_Line("No such machine type.");
				   end if;
			end case;
			
		 or
			accept Com(Fail: in Fail_Acc) do
			   Current := Fail;
			end Com;
			
			case Current.MachineType is
			   when Conf.ADD_MACHINE =>
				  if AddHistory(Current.machineIdx) < Current.Collisions and AddWorking(Current.machineIdx) then
					 AddHistory(Current.machineIdx) := Current.Collisions;
					 AddWorking(Current.machineIdx) := False;
				  end if;
				  
			   when Conf.MUL_MACHINE =>
				  if MulHistory(Current.machineIdx) < Current.Collisions and MulWorking(Current.machineIdx) then
					 MulHistory(Current.machineIdx) := Current.Collisions;
					 MulWorking(Current.machineIdx) := False;
				  end if;
				  
			   when others =>
				  if not Conf.Silent then
					 Ada.Text_IO.Put_Line("No such machine type.");
				  end if;
			end case;
			
		 end select;
		 
		 Found := False;
		 cw := null;
		 
		 for I in 1..Conf.ServiceWorkers loop
            if not sw_array(I).isBusy then
               cw := sw_array(I);
            end if;
            exit when cw /= null ;            
		 end loop;
		 
		 if cw /= null then
            for I in 1..Conf.No_AddMachines loop
               if not addStatus(I) and not addWorking(I) then
                  found := True;
                  sw_array(cw.id).isBusy := True;
                  S_tasks(cw.id).
                    fix_this(fail => new Failure'(machineType  => Conf.ADD_MACHINE,
                                                  machineIdx => I,
                                                  collisions    => cw.addMachines(I).GetCollisions));
               end if;
               exit when found;
            end loop;
		 end if;
		 
		 Found := False;
		 cw := null;
		 
		 for I in 1..Conf.ServiceWorkers loop
            if not sw_array(I).isBusy then
               cw := sw_array(I);
            end if;
            exit when cw /= null ;            
		 end loop;
		 
		 if cw /= null then
            for I in 1..Conf.No_MulMachines loop
               if not mulStatus(I) and not mulWorking(I) then
                  found := True;
                  sw_array(cw.id).isBusy := True;
                  S_tasks(cw.id).
                    fix_this(fail => new Failure'(machineType  => Conf.MUL_MACHINE,
                                                  machineIdx => I,
                                                  collisions    => cw.mulMachines(I).GetCollisions));
               end if;
               exit when found;
            end loop;
		 end if;
			  
				  
	  end loop;
   end ServiceTask;
	  
end Service; 

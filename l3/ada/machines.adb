package body Machines is
   
   protected body AddMachine is
	  procedure SetId(identity : Integer) is
      begin
         id := identity;
	  end SetId;
	  
	  entry Backdoor
        when True is
      begin
         Broken := False;       
	  end Backdoor;
	  
	  function GetCollisions return Integer is
      begin
         return collisions;
	  end GetCollisions;
	  
	  function isBroken return Boolean is
      begin
         return Broken;
	  end isBroken;
	  
	  entry Compute(Ex : in Ex_Acc)
	    when True is
	  begin
		 delay Conf.AddMachineSleep;
		 
		 if Broken then
			Ex.Res := 0;
		 else
			Ex.Res := (case Ex.Operation is
			   when '+' => Ex.Arg1 + Ex.Arg2,
			   when '-' => Ex.Arg1 - Ex.Arg2,
			   when others => 0);
			
			Rand_Int_M.Reset(gen);
            r := Rand_Int_M.Random(gen);
            if r > Conf.AddMachineReliability then
               Broken := True;
               collisions := collisions + 1;
               if not Conf.Silent then
                  Ada.Text_IO.Put_Line("AddMachine: {" & Integer'Image(id) & " } is broken now");
               end if;               
            end if;
		 end if;
		 end Compute;		 		 
   end AddMachine;

   protected body MulMachine is
	  procedure SetId(identity : Integer) is
      begin
         id := identity;
	  end SetId;
	  
	  entry Backdoor
        when True is
      begin
         Broken := False;       
	  end Backdoor;
	  
	  function GetCollisions return Integer is
      begin
         return collisions;
	  end GetCollisions;
	  
	  function isBroken return Boolean is
      begin
         return Broken;
	  end isBroken;
	  
	  entry Compute(Ex : in Ex_Acc)
	    when True is
	  begin
		 delay Conf.MulMachineSleep;
		 
		 if Broken then
			Ex.Res := 0;
		 else
			Ex.Res := Ex.Arg1 * Ex.Arg2;
			
			Rand_Int_M.Reset(gen);
            r := Rand_Int_M.Random(gen);
            if r > Conf.AddMachineReliability then
               Broken := True;
               collisions := collisions + 1;
               if not Conf.Silent then
                  Ada.Text_IO.Put_Line("MulMachine: {" & Integer'Image(id) & " } is broken now");
               end if;               
            end if;
		 end if;
	   end Compute;
   end MulMachine;
   
end Machines;

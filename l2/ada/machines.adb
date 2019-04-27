package body Machines is
   
   protected body AddMachine is
	  entry Compute(Ex : in Ex_Acc)
	    when True is
	  begin
		 delay Conf.AddMachineSleep;
		 Ex.Res := (case Ex.Operation is
			when '+' => Ex.Arg1 + Ex.Arg2,
		    when '-' => Ex.Arg1 - Ex.Arg2,
		    when others => 0);
	  end Compute;
   end AddMachine;

   protected body MulMachine is
	  entry Compute(Ex : in Ex_Acc)
	    when True is
	  begin
		 delay Conf.MulMachineSleep;
		 Ex.Res := Ex.Arg1 * Ex.Arg2;
	   end Compute;
   end MulMachine;
   
end Machines;

package body Servs is
   protected body MagServ is
	  procedure Show is
		 Cursor : Results_List.Cursor;
		 Curr : Ex;
	  begin
		 if Results.Is_Empty then
			Put_Line("...");
		 else
			Cursor := Results.First;
			while Results_List.Has_Element(Cursor) loop
			   Curr := Results_List.Element(Cursor);
			   Put_Line(Integer'Image(Curr.Res) & " : "  & Curr.Operation);
			   Results_List.Next(Cursor);
			end loop;
		 end if;
	  end Show;
	  
      entry AddResult(R : in Ex)
	  when Integer(Results.Length) < Conf.SizeM is
	  begin
		 Results.Append(R);
	  end AddResult; 
	  
	  entry GetResult(R : out Ex)
	  when not Results.Is_Empty is
	  begin
		 R := Results.First_Element;
		 Results.Delete_First;
	  end GetResult; 
   end MagServ;
   
   protected body ExServ is
	  procedure Show is
		 Cursor : Exercises_List.Cursor;
		 Curr : Ex;
	  begin
		 if Exercises.Is_Empty then
			Put_Line("...");
		 else
			Cursor := Exercises.First;
			while Exercises_List.Has_Element(Cursor) loop
			   Curr := Exercises_List.Element(Cursor);
			   Put_Line(Integer'Image(Curr.Arg1)& " : "  & Curr.Operation & " : " & Integer'Image(Curr.Arg2));
			   Exercises_List.Next(Cursor);
			end loop;
		 end if;
		 end Show;
	  
      entry AddTask(E : in Ex)
	  when Integer(Exercises.Length) < Conf.SizeE is
	  begin
		 Exercises.Append(E);
	  end AddTask; 
	  
	  entry GetTask(E : out Ex)
	  when not Exercises.Is_Empty is
	  begin
		 E := Exercises.First_Element;
		 Exercises.Delete_First;
	  end GetTask; 
   end ExServ;
end Servs;

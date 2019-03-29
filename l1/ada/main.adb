with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Conf;

procedure Main is
   
   subtype Int_Range is Integer range 0 .. 1000;
   subtype Op_Range is Integer range 0 .. 2;
   
   type Ex is record
	 Operation : Character;
	 Arg1 : Integer;
	 Arg2 : Integer;
   end record;
   	 
   type Result is record
	 Operation : Character;
	 Result : Integer;
   end record; 
   
   task type Boss;
   task type Worker(Id : Integer);
   task type Customer(Id : Integer);
   task type Worker_Start;
   task type Customer_Start;
   type Worker_Acc is access Worker;
   type Customer_Acc is access Customer;
   
   package Results_List is new Ada.Containers.Doubly_Linked_Lists
	 (Element_Type => Result);
   
   package Exercises_List is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Ex);
	
   package Boss_Rnd is new Ada.Numerics.Discrete_Random
	 (Result_Subtype => Int_Range);
	 
   package Op_Rnd is new Ada.Numerics.Discrete_Random
	 (Result_Subtype => Op_Range);
   
   protected MagServ is
	  procedure Show;
	  entry AddResult(R : in Result);
	  entry GetResult(R : out Result);
   private
	  Results : Results_List.List;
   end MagServ;
   
   protected ExServ is
	  procedure Show;
	  entry AddTask(E : in Ex);
	  entry GetTask(E : out Ex);
   private
	  Exercises : Exercises_List.List;
   end ExServ;
   
   task body Boss is
	  SimpleEx : Ex;
	  B_Delay : Ada.Numerics.Float_Random.Generator;
	  OpRnd : Op_Rnd.Generator;
	  ArgRnd : Boss_Rnd.Generator;
   begin
	  Op_Rnd.Reset(OpRnd);
	  Boss_Rnd.Reset(ArgRnd);
	  Ada.Numerics.Float_Random.Reset(B_Delay);
	  loop
		 SimpleEx.Arg1 := Boss_Rnd.Random(ArgRnd);
		 SimpleEx.Arg2 := Boss_Rnd.Random(ArgRnd);
		 SimpleEx.Operation := (case Op_Rnd.Random(OpRnd) is
			when 0 => '+',
		    when 1 => '-',
			when 2 => '*');
		 
		 ExServ.AddTask(SimpleEx);
		 if (not Conf.Silent) then
			Put_Line("[ Boss " & Integer'Image(SimpleEx.Arg1) & " " & SimpleEx.Operation & Integer'Image(SimpleEx.Arg2) & " ]");
		 end if;
		 delay Duration(Conf.BossSleep * 3.0 * Ada.Numerics.Float_Random.Random(B_Delay));
	  end loop;
	end Boss;	

   task body Worker is
	  ExToDo : Ex;
	  DoneRes : Result;
	  W_Delay : Ada.Numerics.Float_Random.Generator;
   begin
	  Ada.Numerics.Float_Random.Reset(W_Delay);
	  loop
		 ExServ.GetTask(ExToDo);
		 DoneRes.Result := (case ExToDo.Operation is
			when '+' => ExToDo.Arg1 + ExToDo.Arg2,
			when '*' => ExToDo.Arg1 * ExToDo.Arg2,
			when '-' => ExToDo.Arg1 - ExToDo.Arg2,
			when others => 0);
		 DoneRes.Operation := ExToDo.Operation;
		 
		 MagServ.AddResult(DoneRes); 
		 if (not Conf.Silent) then
			Put_Line("[ Worker " & Integer'Image(ExToDo.Arg1) & " " & ExToDo.Operation & Integer'Image(ExToDo.Arg2) & " = "  & Integer'Image(DoneRes.Result) & "]");
		 end if;
		 delay Duration(Conf.WorkerSleep * 2.0 * Ada.Numerics.Float_Random.Random(W_Delay));
		 end loop;
	  end Worker;

   task body Customer is
      ToDisplay : Result;
      C_Delay : Ada.Numerics.Float_Random.Generator;
   begin
	  Ada.Numerics.Float_Random.Reset(C_Delay);
	  loop	 
	  MagServ.GetResult(ToDisplay);
	   if (not Conf.Silent) then
			Put_Line("[ Customer " & Integer'Image(ToDisplay.Result) & " " & ToDisplay.Operation & " ]");
	   end if;
	   delay Duration(Conf.CustomerSleep * 2.0 * Ada.Numerics.Float_Random.Random(C_Delay));
	   end loop;
   end Customer;
   
   protected body MagServ is
	  procedure Show is
		 Cursor : Results_List.Cursor;
		 Curr : Result;
	  begin
		 if Results.Is_Empty then
			Put_Line("...");
		 else
			Cursor := Results.First;
			while Results_List.Has_Element(Cursor) loop
			   Curr := Results_List.Element(Cursor);
			   Put_Line(Integer'Image(Curr.Result) & " : "  & Curr.Operation);
			   Results_List.Next(Cursor);
			end loop;
		 end if;
	  end Show;
	  
      entry AddResult(R : in Result)
	  when Integer(Results.Length) < Conf.SizeM is
	  begin
		 Results.Append(R);
	  end AddResult; 
	  
	  entry GetResult(R : out Result)
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
   
   task body Worker_Start is
	  type Worker_Acc_Arr is array (1 .. Conf.Workers) of Worker_Acc;
	  Workers : Worker_Acc_Arr;
   begin
	  for I in 1 .. Conf.Workers loop
		 Workers(I) := new Worker(I);
	  end loop;
   end Worker_Start;
   
    task body Customer_Start is
	  type Customer_Acc_Arr is array (1 .. Conf.Customers) of Customer_Acc;
	  Customers : Customer_Acc_Arr;
   begin
	  for I in 1 .. Conf.Workers loop
		 Customers(I) := new Customer(I);
	  end loop;
   end Customer_Start;
   
   Begin_Workers : Worker_Start;
   Begin_Boss : Boss;
   Begin_Customers : Customer_Start;
   
   User_Choice : Character;
   begin
	  loop
	  Put_Line("Welcome!");
	  Put_Line("0 - print magazine");
	  Put_Line("1 - print taskas");
	  Put_Line("2 - change mode");
	  
      get(User_Choice);  
      case User_Choice is
         when '0'    => MagServ.Show;
         when '1'    => ExServ.Show;
         when '2'    => Conf.Silent := False;
         when others => Conf.Silent := True;
            null;
      end case;
   end loop;

end Main;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Conf;

package Servs is
   type Ex is record
	 Operation : Character;
	 Arg1 : Integer;
	 Arg2 : Integer;
	 Res : Integer;
   end record;
   
   type Ex_Acc is access Ex;
   
   package Results_List is new Ada.Containers.Doubly_Linked_Lists
	 (Element_Type => Ex);
   
   package Exercises_List is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Ex);
   
   protected MagServ is
	  procedure Show;
	  entry AddResult(R : in Ex);
	  entry GetResult(R : out Ex);
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
   
end Servs;

with Sporadic_and_Protected;
with System.IO;

--  For debugging process
with System.BB.Deadlines;
with System.Task_Primitives.Operations;
with Ada.Real_Time; use Ada.Real_Time;

with System.BB.Time;

procedure Unit02 is
   pragma Priority (1);
begin
   System.Task_Primitives.Operations.Set_Relative_Deadline (
        System.Task_Primitives.Operations.Self, 900000000);
   --
   System.IO.Put_Line ("|------------------|");
   System.IO.Put_Line ("|-- Unit02 BEGIN --|");
   System.IO.Put_Line ("|------------------|");
   Sporadic_and_Protected.Init;
end Unit02;

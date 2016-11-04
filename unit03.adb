with Sporadic_And_Protected_Procedure;
with System.IO;

--  For debugging process
with System.BB.Deadlines;
with System.Task_Primitives.Operations;
with Ada.Real_Time; use Ada.Real_Time;

with System.BB.Time;

procedure Unit02 is
   --  pragma Priority (0);
begin
   Sporadic_And_Protected_Procedure.Init;
end Unit02;

with Interrupt_and_Protected;
with System.IO;

--  For debugging process
with System.BB.Deadlines;
with System.Task_Primitives.Operations;
with Ada.Real_Time; use Ada.Real_Time;

with System.BB.Time;

procedure Unit03 is
   --  pragma Priority (0);
begin
   Interrupt_and_Protected.Init;
end Unit03;

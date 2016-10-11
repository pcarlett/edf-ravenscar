with Cyclic_Tasks;
with System.IO;

--  For debugging process
with System.BB.Deadlines;
with System.Task_Primitives.Operations;
with Ada.Real_Time; use Ada.Real_Time;

with System.BB.Time;

procedure Unit01 is
   -- pragma Priority (0);
begin
   Cyclic_Tasks.Init;
end Unit01;

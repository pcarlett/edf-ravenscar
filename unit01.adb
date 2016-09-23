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
   System.Task_Primitives.Operations.Set_Relative_Deadline (
        System.Task_Primitives.Operations.Self,
        System.BB.Time.Milliseconds (90000));

   System.IO.Put_Line ("|------------------------------------------------|");
   System.IO.Put_Line ("|--  UNIT01 BEGIN  -->  R_Dead "
        & Duration'Image (System.BB.Time.To_Duration
        (System.BB.Time.Milliseconds (90000))) & " ---|");
   System.IO.Put_Line ("|------------------------------------------------|");
   Cyclic_Tasks.Init;
end Unit01;

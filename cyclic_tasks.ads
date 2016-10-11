with System.IO;
with System;
with System.BB.Deadlines;
with Ada.Real_Time;

package Cyclic_Tasks is

   task type Cyclic
          (Pri : System.Priority;
           Dead : Positive;
           Cycle_Time : Positive;
           T_Num : Integer) is
      -- pragma Priority(1);
      -- pragma Relative_Deadline (Ada.Real_Time.Milliseconds(Dead));
   end Cyclic;

   procedure Init;
   pragma No_Return (Init);

end Cyclic_Tasks;

with System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Task_Primitives.Operations;
with System.BB.Time;

with System.Address_Image;

with System_Time;

package body Cyclic_Tasks is

  task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);

      Start_T, Ended_T : Ada.Real_Time.Time;

      Result : Integer := 0;
      x : Integer := 0;
      -- Other declarations
  begin
    -- Initialization code
    -- Setting artificial deadline: it forces system to read deadlines and use
    -- it as main ordering
    System.IO.Put_Line ("|------------------------------------------------|");
    System.IO.Put_Line ("|--> Setting R_Dead "
          & Duration'Image (System.BB.Time.To_Duration (System.BB.Time.Microseconds (Dead)))
               & " for Task n." & Integer'Image(T_Num) & " --|");
    System.IO.Put_Line ("|------------------------------------------------|");

    System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Microseconds (Dead));

    loop
      delay until Next_Period;

      Start_T := Ada.Real_Time.Clock;

      System.IO.Put_Line ("Task n." & Integer'Image(T_Num) & " Real_Time In: "
         & Duration'Image (Ada.Real_Time.To_Duration (Start_T - Ada.Real_Time.Time_First)));

      for i in 1..Times loop
         while x < (Gauss / 2) loop
            Result := Result + x + (Gauss - x + 1);
            x := x + 1;
         end loop;
      end loop;

      if T_Num = 1 then
         System.IO.Put_Line ("|--- 1 ---|---------|---------|  --> Task n. 1");
      elsif T_Num = 2 then
         System.IO.Put_Line ("|---------|--- 2 ---|---------|  --> Task n. 2");
      elsif T_Num = 3 then
         System.IO.Put_Line ("|---------|---------|--- 3 ---|  --> Task n. 3");
      end if;

      -- wait one whole period before executing
      -- Non-suspending periodic response code
      -- May include calls to protected procedures
      Next_Period := Next_Period + Period;

      Ended_T := Ada.Real_Time.Clock;

      System.IO.Put_Line ("Task n." & Integer'Image(T_Num) & " Real_Time Out: "
         & Duration'Image (Ada.Real_Time.To_Duration (Ended_T - Ada.Real_Time.Time_First)));

      System.IO.Put_Line ("==> Task n." & Integer'Image(T_Num) & " Real_Time Diff: "
         & Duration'Image (Ada.Real_Time.To_Duration (Ended_T - Start_T)));

    end loop;
  end Cyclic;

  procedure Init is
     -- Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
     --     + Ada.Real_Time.Milliseconds (90000000000);

  begin
     -- delay until Next_Period;
     loop
        -- System.IO.Put_Line ("|---------|---------|---------|  --> Init Task");
        null;
     end loop;
  end Init;

  ----------------------------------------
  -- TESTED SEQUENCE OF TASK SCHEDULING --
  C1 : Cyclic(0, 10000000, 10000000, 1, 1000000, 1000000);--
  -- C2 : Cyclic(0, 6000000, 6000000, 2, 2, 3);--
  -- C3 : Cyclic(0, 9000000, 9000000, 3, 1, 3);--
  ----------------------------------------

end Cyclic_Tasks;

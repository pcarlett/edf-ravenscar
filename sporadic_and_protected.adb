with System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Task_Primitives.Operations;
with System.BB.Time;

with System_Time;

package body Sporadic_and_Protected is

   task body Periodic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (0);
      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;
      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);
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
         if T_Num = 1 then
            System.IO.Put_Line("|--- 1 ---|---------|---------|  --> Task n. 1");
         elsif T_Num = 2 then
            System.IO.Put_Line("|---------|--- 2 ---|---------|  --> Task n. 2");
         elsif T_Num = 3 then
            System.IO.Put_Line("|---------|---------|--- 3 ---|  --> Task n. 3");
         end if;

         -- wait one whole period before executing
         -- Non-suspending periodic response code
         -- May include calls to protected procedures
         Event.Signal;

         Next_Period := Next_Period + Period;
      end loop;
   end Periodic;

   task body Sporadic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Microseconds (0);
      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;
      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Microseconds (Cycle_Time);

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
         Event.Wait;
         System.IO.Put_Line("|---------|---------|--- 3 ---|  --> Task n. 3 --> Sporadic");
      end loop;

   end Sporadic;

   protected body Event is
      procedure Signal is
      begin
         System.IO.Put_Line (">>> Signaled: Cycle num. " & Integer'Image (Integer (Cycle)));
         Cycle := Cycle + 1;
         if Cycle = 5 then
            Cycle := 0;
            Occurred := True;
         end if;
      end Signal;

      entry Wait when Occurred is
      begin
         System.IO.Put_Line (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Waited");
         Occurred := False;
      end Wait;
   end Event;

   procedure Init is
   begin
      loop
         -- System.IO.Put_Line("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- --> Init Procedure");
         null;
      end loop;
   end Init;

   ----------------------------------------
   -- TESTED SEQUENCE OF TASK SCHEDULING --
   C1 : Periodic(1, 3000000, 3000000, 1);--
   C2 : Periodic(1, 5000000, 5000000, 2);--
   C3 : Sporadic(1, 2000000, 2000000, 3);--
   ----------------------------------------

end Sporadic_and_Protected;

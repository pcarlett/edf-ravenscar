with System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Tasking;
with Ada.Task_Identification;
with System.Task_Primitives.Operations;
with System.BB.Time;
with Force_External_Interrupt_2;

with System_Time;

package body Interrupt_and_Protected is

   Offset : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (500);

   Time_Zero : constant Ada.Real_Time.Time := Ada.Real_Time.Time_of
            (0, Ada.Real_Time.Time_Span_Zero) + Offset;

   task body Cyclic is
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
            Interrupt_Semaphore.Wait;
            System.IO.Put_Line("|--- 1 ---|---------|---------|  --> Task n. 1");
         elsif T_Num = 2 then
            System.IO.Put_Line("|---------|--- 2 ---|---------|  --> Task n. 2");
         elsif T_Num = 3 then
            System.IO.Put_Line("|---------|---------|--- 3 ---|  --> Task n. 3");
         end if;

         -- wait one whole period before executing
         -- Non-suspending periodic response code
         -- May include calls to protected procedures
         Next_Period := Next_Period + Period;
      end loop;
   end Cyclic;

   task body Interrupt is
      Task_Static_Offset : constant Time_Span :=
      Ada.Real_Time.Microseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
      + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period_Interrupt : constant Ada.Real_Time.Time_Span :=
            Ada.Real_Time.Microseconds (Cycle_Time);
   begin
      System.IO.Put_Line ("|------------------------------------------------|");
      System.IO.Put_Line ("|--> Setting R_Dead "
      & Duration'Image (System.BB.Time.To_Duration (System.BB.Time.Microseconds (Dead)))
      & " for Task_Inte --|");
      System.IO.Put_Line ("|------------------------------------------------|");

      System.Task_Primitives.Operations.Set_Relative_Deadline
            (System.Task_Primitives.Operations.Self,
                  System.BB.Time.Microseconds (Dead));

      loop
         delay until Next_Period;
         System.IO.Put_Line("|----I----|----I----|----I----|  --> Interrupt ***");
         Force_External_Interrupt_2;
         Next_Period := Next_Period + Period_Interrupt;
      end loop;
   end Interrupt;

   protected body Interrupt_Semaphore is
      entry Wait when Signaled is
      begin
         Signaled := False;
      end Wait;

      procedure Signal is
      begin
         Signaled := True;
      end Signal;
   end Interrupt_Semaphore;

   procedure Init is
   begin
      loop
         null;
      end loop;
   end Init;

   ----------------------------------------
   -- TESTED SEQUENCE OF TASK SCHEDULING --
   C1 : Cyclic     (1, 3000000, 3000000, 1);--
   C2 : Cyclic     (1, 6000000, 6000000, 2);--
   C3 : Cyclic     (1, 9000000, 9000000, 3);--
   Int : Interrupt (1, 5000000, 5000000, 4);--
   ----------------------------------------

end Interrupt_and_Protected;

with System.IO; use System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Tasking;
with Ada.Task_Identification;
with System.Task_Primitives.Operations;
with System.BB.Time;
with Force_External_Interrupt_2;

with System_Time;

package body Interrupt_and_Protected is

   task body Cyclic is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Milliseconds (0);

      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;

      Period : constant Ada.Real_Time.Time_Span :=
               Ada.Real_Time.Milliseconds (Cycle_Time);
      -- Other declarations
      type Proc_Access is access procedure(X : in out Integer);
      function Time_It(Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action(Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;
      procedure Gauss(Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1..Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Gauss_Access : Proc_Access := Gauss'access;
   begin
      -- Initialization code
      -- Setting artificial deadline: it forces system to read deadlines and use
      -- it as main ordering
      Put ("                   ");
      Put_Line ("|-|-|-|-|-|-|-|-> Setting R_Dead "
            & Duration'Image (System.BB.Time.To_Duration (System.BB.Time.Milliseconds (Dead)))
                          & " for Task " & Integer'Image(T_Num) & " --|");

      System.Task_Primitives.Operations.Set_Relative_Deadline
           (System.Task_Primitives.Operations.Self,
            System.BB.Time.Milliseconds (Dead));

      loop
         delay until Next_Period;
         delay until Next_Period;
         if T_Num = 1 then
            Interrupt_Semaphore.Wait;
            Put_Line("                   Begin Calc for Task n. " & Integer'Image(T_Num));
            Put("                   Gauss(2026600) takes"
                & Duration'Image(Time_It(Gauss_Access, 2026600))
                & " seconds on Task n. " & Integer'Image(T_Num));
            Put_Line("... Done.");
            Put_Line("                   End of Task n. " & Integer'Image(T_Num));
         elsif T_Num = 2 then
            Put_Line("                   Begin Calc for Task n. " & Integer'Image(T_Num));
            Put("                   Gauss(2026600) takes"
                & Duration'Image(Time_It(Gauss_Access, 2026600))
                & " seconds on Task n. " & Integer'Image(T_Num));
            Put_Line("... Done.");
            Put_Line("                   End of Task n. " & Integer'Image(T_Num));
         elsif T_Num = 3 then
            Put_Line("                   Begin Calc for Task n. " & Integer'Image(T_Num));
            Put("                   Gauss(2026600) takes"
                & Duration'Image(Time_It(Gauss_Access, 2026600))
                & " seconds on Task n. " & Integer'Image(T_Num));
            Put_Line("... Done.");
            Put_Line("                   End of Task n. " & Integer'Image(T_Num));
         end if;

         -- wait one whole period before executing
         -- Non-suspending periodic response code
         -- May include calls to protected procedures
         Next_Period := Next_Period + Period;
      end loop;
   end Cyclic;

   task body Interrupt is
      Task_Static_Offset : constant Time_Span :=
               Ada.Real_Time.Milliseconds (0);
      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time
            + System_Time.Task_Activation_Delay + Task_Static_Offset;
      Period_Interrupt : constant Ada.Real_Time.Time_Span :=
            Ada.Real_Time.Milliseconds (Cycle_Time);
      -- Other declarations
      type Proc_Access is access procedure(X : in out Integer);
      function Time_It(Action : Proc_Access; Arg : Integer) return Duration is
         Start_Time : Time := Clock;
         Finis_Time : Time;
         Func_Arg : Integer := Arg;
      begin
         Action(Func_Arg);
         Finis_Time := Clock;
         return To_Duration (Finis_Time - Start_Time);
      end Time_It;
      procedure Gauss(Times : in out Integer) is
         Num : Integer := 0;
      begin
         for I in 1..Times loop
            Num := Num + I;
         end loop;
      end Gauss;
      Gauss_Access : Proc_Access := Gauss'access;
   begin
      Put ("                   ");
      Put_Line ("|-|-|-|-|-|-|-|-> Setting R_Dead "
            & Duration'Image (System.BB.Time.To_Duration (System.BB.Time.Milliseconds (Dead)))
                          & " for Task " & Integer'Image(T_Num) & " --|");

      System.Task_Primitives.Operations.Set_Relative_Deadline
           (System.Task_Primitives.Operations.Self,
            System.BB.Time.Milliseconds (Dead));

      loop
         delay until Next_Period;
         Force_External_Interrupt_2;
         Put_Line("                   Begin Calc for Task n. " & Integer'Image(T_Num));
         Put("                   Gauss(2026600) takes"
             & Duration'Image(Time_It(Gauss_Access, 2026600))
             & " seconds on Task n. " & Integer'Image(T_Num));
         Put_Line("... Done.");
         Put_Line("                   End of Task n. " & Integer'Image(T_Num));
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
     System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
         System.BB.Time.Milliseconds (900000));

     System.IO.Put ("                   ");
     System.IO.Put_Line ("|-|-|-|-|-|-|-|->  UNIT01 BEGIN  -->  R_Dead "
        & Duration'Image (System.BB.Time.To_Duration
        (System.BB.Time.Milliseconds (900000))) & " ---|");
     loop
        null;
     end loop;
   end Init;


   ----------------------------------------
   -- TESTED SEQUENCE OF TASK SCHEDULING --
   -- C1  : Cyclic    (1, 4000, 4000, 1);--
   -- C2  : Cyclic    (1, 6000, 6000, 2);--
   -- C3  : Cyclic    (1, 9000, 9000, 3);--
   Int : Interrupt (1, 5000, 5000, 4);--
   ----------------------------------------

end Interrupt_and_Protected;

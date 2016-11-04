with System.IO; use System.IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with System.Task_Primitives.Operations;
with System.BB.Time;

with System_Time;

package body Cyclic_Tasks is

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
    Put_Line ("---> Setting R_Dead "
        & Duration'Image (System.BB.Time.To_Duration
          (System.BB.Time.Milliseconds (Dead)))
        & " for Task " & Integer'Image(T_Num));

    System.Task_Primitives.Operations.Set_Relative_Deadline
         (System.Task_Primitives.Operations.Self,
          System.BB.Time.Milliseconds (Dead));

    loop
      delay until Next_Period;

      Put_Line("Begin Calc for Task n. " & Integer'Image(T_Num));
      Put("Gauss(" & Integer'Image(Gauss_Num) & ") takes"
          & Duration'Image(Time_It(Gauss_Access, Gauss_Num))
          & " seconds on Task n. " & Integer'Image(T_Num));
      Put_Line("... Done.");
      Put_Line("End Calc for Task n. " & Integer'Image(T_Num));

      -- wait one whole period before executing
      -- Non-suspending periodic response code
      -- May include calls to protected procedures
      Next_Period := Next_Period + Period;
    end loop;
  end Cyclic;

  procedure Init is
  begin
     System.Task_Primitives.Operations.Set_Relative_Deadline
        (System.Task_Primitives.Operations.Self,
         System.BB.Time.Milliseconds (900000));

     System.IO.Put_Line ("--->  Unit01 Start  -->  R_Dead "
        & Duration'Image (System.BB.Time.To_Duration
        (System.BB.Time.Milliseconds (900000))));
     loop
        null;
     end loop;
  end Init;

  ----------------------------------------
  -- TESTED SEQUENCE OF TASK SCHEDULING --
  C1 : Cyclic(0,  4000,  4000, 1, 2011100); -- Exec 3sec
  C2 : Cyclic(0, 20000, 20000, 2, 6033300); -- Exec 9sec
  -- C3 : Cyclic(0, 4000, 5000, 3, 2011100); -- Exec 3sec
  ----------------------------------------

end Cyclic_Tasks;

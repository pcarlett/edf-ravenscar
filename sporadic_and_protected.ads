with System.IO;
with System;
with System.BB.Time;
with System.BB.Deadlines;
-- with Ada.Interrupts.Names;

package Sporadic_and_Protected is

   -- Task and protected object declarations

   task type Periodic
          (Pri : System.Priority;
           Dead : Positive;
           Cycle_Time : Positive;
           T_Num : Integer) is
      --  pragma Priority(1);
   end Periodic;

   task type Sporadic
           (Pri : System.Priority;
            Dead : Positive;
            Cycle_Time : Positive;
            T_Num : Integer) is
      --  pragma Priority(1);
   end Sporadic;

   protected Event is
      pragma Priority (50000000);
      --> in valore del floor deve essere il piu' basso di tutti
      --> in quanto deve garantire l'accesso senza prerilascio!!!
      --> in questo caso il valore e' maggiore rispetto a quello
      --> definito nei task in quanto e' un valore Positive e non Time

      procedure Signal;
      entry Wait;
   private
      Occurred : Boolean := False;
      Cycle : Integer := 0;
   end Event;

  procedure Init;
  pragma No_Return (Init);

end Sporadic_and_Protected;

with System.IO;
with System;

with System.BB.Time;
with Ada.Interrupts.Names;
with System.BB.Deadlines;

package Interrupt_and_Protected is

  Priority_Of_External_Interrupt_2 : constant System.Interrupt_Priority
                                    := System.Interrupt_Priority'First + 5;

  task type Cyclic
          (Pri : System.Priority;
           Dead : Positive;
           Cycle_Time : Positive;
           T_Num : Integer) is
     pragma Priority (1);
  end Cyclic;

  task type Interrupt
          (Pri : System.Priority;
           Dead : Positive;
           Cycle_Time : Positive;
           T_Num : Integer) is
     pragma Priority (System.Priority'Last);
  end Interrupt;

  protected Interrupt_Semaphore is
     pragma Priority (250); -- (Priority_Of_External_Interrupt_2);
     entry Wait;
     procedure Signal;
     pragma Attach_Handler (Signal, Ada.Interrupts.Names.External_Interrupt_2);
  private
     Signaled : Boolean := False;
  end Interrupt_Semaphore;

  procedure Init;
  pragma No_Return (Init);

end Interrupt_and_Protected;

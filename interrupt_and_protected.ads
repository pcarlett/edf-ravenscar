with System.IO;
with System;

with System.BB.Time;
with Ada.Interrupts.Names;
with System.BB.Deadlines;

package Interrupt_and_Protected is

  task type Periodic
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer;
      Gauss_Num  : Integer) is
  end Periodic;

  task type Interrupt
     (Pri        : System.Priority;
      Dead       : Positive;
      Cycle_Time : Positive;
      T_Num      : Integer) is
     pragma Priority (System.Priority'Last);
  end Interrupt;

  protected Interrupt_Semaphore is
     pragma Interrupt_Priority (250);
     procedure Busy_Handler;
     pragma Attach_Handler (Busy_Handler, Ada.Interrupts.Names.External_Interrupt_2);
  end Interrupt_Semaphore;

  procedure Init;
  pragma No_Return (Init);

end Interrupt_and_Protected;

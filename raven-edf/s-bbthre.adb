------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                       S Y S T E M . B B . T H R E A D S                  --
--                                                                          --
--                                  B o d y                                 --
--                                                                          --
--        Copyright (C) 1999-2002 Universidad Politecnica de Madrid         --
--             Copyright (C) 2003-2005 The European Space Agency            --
--                     Copyright (C) 2003-2012, AdaCore                     --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion. GNARL is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNARL was developed by the GNARL team at Florida State University.       --
-- Extensive contributions were provided by Ada Core Technologies, Inc.     --
--                                                                          --
-- The port of GNARL to bare board targets was initially developed by the   --
-- Real-Time Systems Group at the Technical University of Madrid.           --
--                                                                          --
------------------------------------------------------------------------------

pragma Restrictions (No_Elaboration_Code);

with System.Storage_Elements;
with System.BB.Parameters;
with System.BB.Board_Support;
with System.BB.Protection;
with System.BB.Threads.Queues;
with System.BB.CPU_Primitives.Multiprocessors;

with Ada.Unchecked_Conversion;

-----------------
--  Used in debugging process
with System.IO;
with System.BB.Debug; use System.BB.Debug;
-----------------

package body System.BB.Threads is

   use System.Multiprocessors;
   use System.BB.CPU_Primitives;
   use System.BB.CPU_Primitives.Multiprocessors;
   use System.BB.Deadlines;   --  To use deadlines namespaces
   use System.BB.Time;
   use System.BB.Parameters;
   use Board_Support;

   use type System.Address;
   use type System.Parameters.Size_Type;
   use type System.Storage_Elements.Storage_Offset;

   type Slave_Stack_Space is
     new Storage_Elements.Storage_Array
       (1 .. Storage_Elements.Storage_Offset (1024));
   for Slave_Stack_Space'Alignment use 8;
   --  A minimum stack for the slave CPUs

   subtype Slave_CPUs is Multiprocessors.CPU
     range Multiprocessors.CPU'First + 1 .. Multiprocessors.CPU'Last;
   --  List of slave CPUs (all CPUs excluding the master which is the first
   --  one).

   Slave_Stacks : array (Slave_CPUs) of Slave_Stack_Space;
   --  Array that contains the stack of slave CPUs (all CPUs except the first
   --  one which is considered the master). This is a null array on
   --  monoprocessor systems.

   Slave_Stacks_Table : array (Slave_CPUs) of System.Address;
   pragma Export (Asm, Slave_Stacks_Table, "slave_stack_table");

   -----------------------
   -- Stack information --
   -----------------------

   --  Boundaries of the stack for the environment task, defined by the linker
   --  script file.

   Top_Of_Environment_Stack : constant System.Address;
   pragma Import (Asm, Top_Of_Environment_Stack, "__stack_end");
   --  Top of the stack to be used by the environment task

   Bottom_Of_Environment_Stack : constant System.Address;
   pragma Import (Asm, Bottom_Of_Environment_Stack, "__stack_start");
   --  Bottom of the stack to be used by the environment task

   ------------------
   -- Get_Affinity --
   ------------------

   function Get_Affinity (Thread : Thread_Id) return CPU_Range is
   begin
      pragma Assert (Thread /= Null_Thread_Id);

      return Thread.Base_CPU;
   end Get_Affinity;

   -------------
   -- Get_CPU --
   -------------

   function Get_CPU (Thread : Thread_Id) return CPU is
   begin
      pragma Assert (Thread /= Null_Thread_Id);

      if Thread.Base_CPU = Not_A_Specific_CPU then
         --  Return the implementation specific default CPU

         return CPU'First;
      else
         return CPU (Thread.Base_CPU);
      end if;
   end Get_CPU;

   --------------
   -- Get_ATCB --
   --------------

   function Get_ATCB return System.Address is
   begin
      return System.BB.Threads.Queues.Running_Thread.ATCB;
   end Get_ATCB;

   ------------------
   -- Get_Priority --
   ------------------

   --  Removed from Ravenscar EDF version
   --  function Get_Priority (Id : Thread_Id) return System.Any_Priority is
   --  begin
      --  This function does not need to be protected by Enter_Kernel and
      --  Leave_Kernel, because the Active_Priority value is only updated
      --  by Set_Priority (atomically). Moreover, Active_Priority is
      --  marked as Volatile.

   --     return Id.Active_Priority;
   --  end Get_Priority;

   ---------------------------
   -- Get_Relative_Deadline --
   ---------------------------

   function Get_Relative_Deadline (Id : Thread_Id)
        return System.BB.Deadlines.Relative_Deadline is
   begin
      --  This function does not need to be protected by Enter_Kernel and
      --  Leave_Kernel, because the Active_Relative_Deadline value is only
      --  updated by Set_Relative_Deadline (atomically). Moreover,
      --  Active_Relative_Deadline is marked as Volatile.

      return Id.Active_Relative_Deadline;
   end Get_Relative_Deadline;

   ---------------------------
   -- Get_Absolute_Deadline --
   ---------------------------

   function Get_Absolute_Deadline (Id : Thread_Id)
        return System.BB.Deadlines.Absolute_Deadline is
   begin
      --  This function does not need to be protected by Enter_Kernel and
      --  Leave_Kernel, because the Active_Absolute_Deadline value is only
      --  updated by Set_Absolute_Deadline (atomically). Moreover,
      --  Active_Absolute_Deadline is marked as Volatile.

      return Id.Active_Absolute_Deadline;
   end Get_Absolute_Deadline;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Environment_Thread : Thread_Id;
      --  Removed from Ravenscar EDF version
      --  Main_Priority      : System.Any_Priority;
      Main_Rel_Deadline  : Relative_Deadline)
   is
      Main_CPU : constant System.Multiprocessors.CPU := Current_CPU;
      --  Now : System.BB.Time.Time := System.BB.Time.Clock;
   begin
      --  Perform some basic hardware initialization (clock, timer, and
      --  interrupt handlers).

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... Begin.");
      end if;

      Board_Support.Initialize_Board;
      Interrupts.Initialize_Interrupts;
      Time.Initialize_Timers;

      --  Set addresses of the stacks allocated to main procedures for the
      --  slave CPUs.

      pragma Warnings (Off, "loop range is null*");
      --  On monoprocessor targets, the following loop will never execute (no
      --  slave CPUs).

      for CPU_Id in Slave_CPUs loop
         Slave_Stacks_Table (CPU_Id) :=
           Slave_Stacks (CPU_Id)(Slave_Stack_Space'First)'Address;
      end loop;

      pragma Warnings (On, "loop range is null*");

      --  Initialize internal queues and the environment task

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... Initialized.");
      end if;

      Protection.Enter_Kernel;

      --  The environment thread executes the main procedure of the program

      --  CPU of the environment thread is current one (initialization CPU)

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... Entered.");
      end if;

      Environment_Thread.Base_CPU := Main_CPU;

      --  The active priority is initially equal to the base priority

      --  Removed from Ravenscar EDF version
      --  System.IO.Put_Line
      --          ("Threads Initialization Process... Init Priority.");

      --  Removed from Ravenscar EDF version
      --  Environment_Thread.Base_Priority   := Main_Priority;
      --  Environment_Thread.Active_Priority := Main_Priority;

      --  The active relative deadline is initially equal to the base
      --  relative deadline

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process..."
               & " Init Rel_Dead.");
      end if;

      Environment_Thread.Base_Relative_Deadline   := Main_Rel_Deadline;
      Environment_Thread.Active_Relative_Deadline := Main_Rel_Deadline;

      --  The active absolute deadline is initially equal to the base relative
      --  deadline plus a NOW time value: it's necessary to convert relative
      --  deadline Time_Span value to absolute deadline Time value

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... "
                           & "Init Abs_Dead.");
      end if;

      Environment_Thread.Active_Absolute_Deadline :=
      --          Main_Rel_Deadline + Now;
              Main_Rel_Deadline + System.BB.Time.Clock;

      --  The currently executing thread (and the only one) is the
      --  environment thread.

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... "
                           & "Task + Queues.");
      end if;

      Queues.Running_Thread_Table (Main_CPU) := Environment_Thread;
      Queues.First_Thread_Table (Main_CPU)   := Environment_Thread;
      Queues.Global_List                     := Environment_Thread;

      Environment_Thread.Next        := Null_Thread_Id;
      Environment_Thread.Global_List := Null_Thread_Id;

      --  Store stack information

      Environment_Thread.Top_Of_Stack := Top_Of_Environment_Stack'Address;

      Environment_Thread.Bottom_Of_Stack :=
        Bottom_Of_Environment_Stack'Address;

      --  The initial state is Runnable

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... State.");
      end if;

      Environment_Thread.State := Runnable;

      --  No wakeup has been yet signaled

      Environment_Thread.Wakeup_Signaled := False;

      --  Initialize alarm status

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... Alarm.");
      end if;

      Environment_Thread.Alarm_Time :=
        System.BB.Time.Time'Last;
      Environment_Thread.Next_Alarm := Null_Thread_Id;

      --  Initialize the saved registers. We can ignore the stack and code to
      --  execute because the environment task is already executing. We are
      --  interested in the initialization of the rest of the state, such as
      --  the interrupt nesting level and the cache state.

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... "
                           & "Init Context.");
      end if;

      Initialize_Context
        (Environment_Thread.Context'Access,
         Null_Address,
         Null_Address,
         Environment_Thread.Top_Of_Stack);

      --  Enable use of the floating point unit in a multitasking environment

      Initialize_Floating_Point;

      --  The tasking executive is initialized

      Initialized := True;

      Protection.Leave_Kernel;

      if Debug_Thre then
         System.IO.Put_Line ("Threads Initialization Process... Ended.");
      end if;

   end Initialize;

   ----------------------------------
   -- Initialize_Slave_Environment --
   ----------------------------------

   procedure Initialize_Slave_Environment (Environment_Thread : Thread_Id) is
      CPU_Id : constant System.Multiprocessors.CPU := Current_CPU;

   begin
      --  Initialize internal queues and the environment task

      if Debug_Thre then
         System.IO.Put_Line ("Slave Environment Initialization Process... "
                           & "Begin");
      end if;
      Protection.Enter_Kernel;

      Environment_Thread.Base_CPU        := CPU_Id;

      --  Removed from Ravenscar EDF version
      Environment_Thread.Base_Priority   := Any_Priority (0);
      Environment_Thread.Active_Priority := Any_Priority (0);

      --  Necessary to replicate same structure for Base_Relative_Deadline,
      --  Active_Relative_Deadline and Active_Absolute_Deadline for
      --  Slave_Environment

      Environment_Thread.Base_Relative_Deadline :=
                                    System.BB.Time.Milliseconds (1000000000);
                                    --  Relative_Deadline'Last;
      Environment_Thread.Active_Relative_Deadline :=
                                    System.BB.Time.Milliseconds (1000000000);
                                    --  Relative_Deadline'Last;

      Environment_Thread.Active_Absolute_Deadline :=
         (System.BB.Time.Clock + System.BB.Time.Milliseconds (1000000000));
                              --  Absolute_Deadline'Last;

      Queues.Running_Thread_Table (CPU_Id) := Environment_Thread;

      Environment_Thread.Next        := Null_Thread_Id;
      Environment_Thread.Global_List := Null_Thread_Id;

      --  Set a minimal stack

      Environment_Thread.Top_Of_Stack :=
        Slave_Stacks (CPU_Id)(Slave_Stack_Space'First)'Address;

      Environment_Thread.Bottom_Of_Stack :=
        Slave_Stacks (CPU_Id)(Slave_Stack_Space'Last)'Address;

      --  The state is Runnable

      Environment_Thread.State := Runnable;

      --  No wakeup

      Environment_Thread.Wakeup_Signaled := False;

      --  No Alarm

      Environment_Thread.Alarm_Time :=
        System.BB.Time.Time'Last;
      Environment_Thread.Next_Alarm := Null_Thread_Id;

      --  Initialize the saved registers. We can ignore the stack and code to
      --  execute because the environment will never realy execute any code.
      --  We are interested in the initialization of the rest of the state,
      --  such as the interrupt nesting level and the cache state.

      Initialize_Context
        (Environment_Thread.Context'Access,
         Null_Address,
         Null_Address,
         Environment_Thread.Top_Of_Stack);

      Protection.Leave_Kernel;
      if Debug_Thre then
         System.IO.Put_Line ("Slave Environment Initialization Process... "
                     & "Ended");
      end if;
   end Initialize_Slave_Environment;

   --------------
   -- Set_ATCB --
   --------------

   procedure Set_ATCB (ATCB : System.Address) is
   begin
      --  Set_ATCB is only called in the initialization of the task, and just
      --  by the owner of the thread, so there is no need of explicit kernel
      --  protection when calling this function.

      System.BB.Threads.Queues.Running_Thread.ATCB := ATCB;
   end Set_ATCB;

   ------------------
   -- Set_Priority --
   ------------------

   --  Removed from Ravenscar EDF version
   --  procedure Set_Priority (Priority  : System.Any_Priority) is
   --  begin
   --     Protection.Enter_Kernel;

      --  The Ravenscar profile does not allow dynamic priority changes. Tasks
      --  change their priority only when they inherit the ceiling priority of
      --  a PO (Ceiling Locking policy). Hence, the task must be running when
      --  changing the priority. It is not possible to change the priority of
      --  another thread within the Ravenscar profile, so that is why
      --  Running_Thread is used.

      --  Priority changes are only possible as a result of inheriting the
      --  ceiling priority of a protected object. Hence, it can never be set
      --  a priority which is lower than the base priority of the thread.

   --     System.IO.Put_Line ("Threads Setting Priority Process... Begin.");

   --     pragma Assert (Priority >= Queues.Running_Thread.Base_Priority);

   --     System.IO.Put_Line ("Threads Setting Priority Process... Changing.");

   --     Queues.Change_Priority (Queues.Running_Thread, Priority, False);

   --     Protection.Leave_Kernel;

   --     System.IO.Put_Line ("Threads Setting Priority Process... Ended.");

   --  end Set_Priority;

   ---------------------------
   -- Set_Relative_Deadline --
   ---------------------------

   procedure Set_Relative_Deadline (Rel_Deadline : Relative_Deadline) is
   begin
      Protection.Enter_Kernel;

      --  The Ravenscar profile does not allow dynamic priority changes. Tasks
      --  change their priority only when they inherit the ceiling priority of
      --  a PO (Ceiling Locking policy). Hence, the task must be running when
      --  changing the priority. It is not possible to change the priority of
      --  another thread within the Ravenscar profile, so that is why
      --  Running_Thread is used.

      --  Priority changes are only possible as a result of inheriting the
      --  ceiling priority of a protected object. Hence, it can never be set
      --  a priority which is lower than the base priority of the thread.

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting R_Deadline Process... Begin.");
      end if;

      pragma Assert (Rel_Deadline >=
              Queues.Running_Thread.Base_Relative_Deadline);

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting R_Deadline Process... Changing.");
      end if;

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting R_Deadline Process... R_Dead: "
               & Duration'Image (To_Duration (Rel_Deadline)));
      end if;

      Queues.Change_Relative_Deadline
              (Queues.Running_Thread, Rel_Deadline);

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting R_Deadline Process... Ended.");
      end if;

      Protection.Leave_Kernel;
   end Set_Relative_Deadline;

   ---------------------------
   -- Set_Absolute_Deadline --
   ---------------------------

   procedure Set_Absolute_Deadline (Abs_Deadline : Absolute_Deadline) is
   begin
      Protection.Enter_Kernel;

      --  The Ravenscar profile does not allow dynamic priority changes. Tasks
      --  change their priority only when they inherit the ceiling priority of
      --  a PO (Ceiling Locking policy). Hence, the task must be running when
      --  changing the priority. It is not possible to change the priority of
      --  another thread within the Ravenscar profile, so that is why
      --  Running_Thread is used.

      --  Priority changes are only possible as a result of inheriting the
      --  ceiling priority of a protected object. Hence, it can never be set
      --  a priority which is lower than the base priority of the thread.

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting A_Deadline Process... Begin.");
      end if;

      pragma Assert (Abs_Deadline >=
              Queues.Running_Thread.Active_Absolute_Deadline);

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting A_Deadline Process... Changing.");
      end if;

      Queues.Change_Absolute_Deadline
              (Queues.Running_Thread, Abs_Deadline);

      if Debug_Thre then
         System.IO.Put_Line ("Thread Setting A_Deadline Process... Ended.");
      end if;

      Protection.Leave_Kernel;
   end Set_Absolute_Deadline;

   -----------
   -- Sleep --
   -----------

   procedure Sleep is
      Self_Id : constant Thread_Id := Queues.Running_Thread;
   begin
      if Debug_Thre then
         System.IO.Put_Line ("Thread Sleep Process... Begin.");
      end if;
      Protection.Enter_Kernel;

      if Self_Id.Wakeup_Signaled then

         --  Another thread has already executed a Wakeup on this thread so
         --  that we just consume the token and continue execution. It means
         --  that just before this call to Sleep the task has been preempted
         --  by the task that is awaking it. Hence the Sleep/Wakeup calls do
         --  not happen in the expected order, and we use the Wakeup_Signaled
         --  to flag this event so it is not lost.

         --  The situation is the following:

         --    1) a task A is going to wait in an entry for a barrier
         --    2) task A releases the lock associated to the protected object
         --    3) task A calls Sleep to suspend itself
         --    4) a task B opens the barrier and awakes task A (calls Wakeup)

         --  This is the expected sequence of events, but 4) may happen
         --  before 3) because task A decreases its priority in step 2) as a
         --  consequence of releasing the lock (Ceiling_Locking). Hence, task A
         --  may be preempted by task B in the window between releasing the
         --  protected object and actually suspending itself, and the Wakeup
         --  call by task B in 4) can happen before the Sleep call in 3).

         if Debug_Thre then
            System.IO.Put_Line ("Thread Sleep Process... "
                  & "Wakeup Signaled False.");
         end if;
         Self_Id.Wakeup_Signaled := False;

      else
         --  Update status

         if Debug_Thre then
            System.IO.Put_Line ("Thread Sleep Process... Changing State.");
         end if;
         Self_Id.State := Suspended;

         --  Extract from the list of ready threads

         if Debug_Thre then
            System.IO.Put_Line ("Thread Sleep Process... Extract from Ready.");
         end if;
         Queues.Extract (Self_Id);

         --  The currently executing thread is now blocked, and it will leave
         --  the CPU when executing the Leave_Kernel procedure.

      end if;

      Protection.Leave_Kernel;

      --  Now the thread has been awaken again and it is executing
      if Debug_Thre then
         System.IO.Put_Line ("Thread Sleep Process... Ended.");
      end if;

   end Sleep;

   -------------------
   -- Thread_Create --
   -------------------

   procedure Thread_Create
     (Id            : Thread_Id;
      Code          : System.Address;
      Arg           : System.Address;
      --  Removed from Ravenscar EDF version
      --  Priority      : System.Any_Priority;
      Relative_Deadline : System.BB.Deadlines.Relative_Deadline;
      --  New attibute: relative deadline which manage specific task behaviour
      Base_CPU      : System.Multiprocessors.CPU_Range;
      Stack_Address : System.Address;
      Stack_Size    : System.Parameters.Size_Type)
   is
   begin

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Begin.");
      end if;

      Protection.Enter_Kernel;

      --  Set the CPU affinity

      Id.Base_CPU := Base_CPU;

      --  Set the base and active priority

      --  System.IO.Put_Line ("Threads Creation Process... Setting Prio.");

      Id.Base_Priority   := Any_Priority (0);
      Id.Active_Priority := Any_Priority (0);

      --  Set the base and active relative deadline

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Setting Rel_Dead.");
      end if;

      Id.Base_Relative_Deadline   := Relative_Deadline;
      Id.Active_Relative_Deadline := Relative_Deadline;

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Setting Abs_Dead.");
      end if;

      --  Set the active absolute deadline
      Id.Active_Absolute_Deadline := --  System.BB.Time.Time
                     (Relative_Deadline) + System.BB.Time.Clock;

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Insert in G_List.");
      end if;

      --  Insert in the global list

      Id.Global_List := Queues.Global_List;
      Queues.Global_List := Id;

      --  Insert task inside the ready list (as last within its priority)

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... "
                        & "Insert Ready Queue.");
      end if;

      Queues.Insert (Id);

      --  Store stack information

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Stack Operations.");
      end if;

      Id.Top_Of_Stack :=
        ((Stack_Address + Storage_Elements.Storage_Offset (Stack_Size))
          / Standard'Maximum_Alignment) * Standard'Maximum_Alignment;

      Id.Bottom_Of_Stack := Stack_Address;

      --  The initial state is Runnable

      Id.State := Runnable;

      --  No wakeup has been yet signaled

      Id.Wakeup_Signaled := False;

      --  Initialize the saved registers, including the program counter and
      --  stack pointer. The thread will execute the Thread_Caller procedure
      --  and the stack pointer points to the top of the stack assigned to the
      --  thread.

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... "
                     & "Initialize Context.");
      end if;

      Initialize_Context (Id.Context'Access, Code, Arg, Id.Top_Of_Stack);

      --  Initialize alarm status

      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Initialize Alarm.");
      end if;

      Id.Alarm_Time := System.BB.Time.Time'Last;
      Id.Next_Alarm := Null_Thread_Id;

      Id.Execution_Time := System.BB.Time.Time'First;

      Protection.Leave_Kernel;
      if Debug_Thre then
         System.IO.Put_Line ("Threads Creation Process... Ended.");
      end if;
   end Thread_Create;

   -----------------
   -- Thread_Self --
   -----------------

   function Thread_Self return Thread_Id is
   begin
      --  Return the thread that is currently executing

      return Queues.Running_Thread;
   end Thread_Self;

   ------------
   -- Wakeup --
   ------------

   procedure Wakeup (Id : Thread_Id) is
   begin
      Protection.Enter_Kernel;

      if Id.State = Suspended then

         --  The thread is already waiting so that we awake it

         --  Update status

         Id.State := Runnable;

         --  Insert the thread at the tail of its active priority so that the
         --  thread will resume execution.

         Queues.Insert (Id);

      else
         --  The thread is not yet waiting so that we just signal that the
         --  Wakeup command has been executed. We are waking up a task that
         --  is going to wait in an entry for a barrier, but before calling
         --  Sleep it has been preempted by the task awaking it.

         Id.Wakeup_Signaled := True;
      end if;

      Protection.Leave_Kernel;
   end Wakeup;

end System.BB.Threads;

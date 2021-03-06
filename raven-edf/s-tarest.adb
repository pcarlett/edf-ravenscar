------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--     S Y S T E M . T A S K I N G . R E S T R I C T E D . S T A G E S      --
--                                                                          --
--                                  B o d y                                 --
--                                                                          --
--                     Copyright (C) 1999-2011, AdaCore                     --
--                                                                          --
-- GNARL is free software; you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
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
------------------------------------------------------------------------------

--  This is a simplified version of the System.Tasking.Stages package, for use
--  with the ravenscar/HI-E profile.

--  This package represents the high level tasking interface used by the
--  compiler to expand Ada 95 tasking constructs into simpler run time calls.

pragma Style_Checks (All_Checks);
--  Turn off subprogram alpha order check, since we group soft link bodies and
--  also separate off subprograms for restricted GNARLI.

pragma Polling (Off);
--  Turn off polling, we do not want ATC polling to take place during
--  tasking operations. It causes infinite loops and other problems.

with System.Task_Primitives.Operations;
--  used for Enter_Task
--           Wakeup
--           Get_Priority
--           Set_Priority
--           Sleep
--  updated with procedures:
--           Get_Relative_Deadline
--           Set_Relative_Deadline
--  to manage EDF scheduling

with System.Secondary_Stack;
--  used for SS_Init
--           Default_Secondary_Stack_Size

with System.Storage_Elements;
--  used for Storage_Array

package body System.Tasking.Restricted.Stages is

   use System.Secondary_Stack;
   use System.Task_Primitives.Operations;
   use System.Task_Info;

   use System.BB.Time;
   use System.BB.Deadlines;
   --  for deadlines reference

   -----------------------
   -- Local Subprograms --
   -----------------------

   procedure Task_Wrapper (Self_ID : Task_Id);
   --  This is the procedure that is called by the GNULL from the new context
   --  when a task is created. It waits for activation and then calls the task
   --  body procedure. When the task body procedure completes, it terminates
   --  the task.

   ------------------
   -- Task_Wrapper --
   ------------------

   --  The task wrapper is a procedure that is called first for each task
   --  task body, and which in turn calls the compiler-generated task body
   --  procedure. The wrapper's main job is to do initialization for the task.

   --  The variable ID in the task wrapper is used to implement the Self
   --  function on targets where there is a fast way to find the stack
   --  base of the current thread, since it should be at a fixed offset
   --  from the stack base.

   procedure Task_Wrapper (Self_ID : Task_Id) is
      use type System.Storage_Elements.Storage_Offset;

      Sec_Stack_Size : constant Storage_Elements.Storage_Offset :=
                         Self_ID.Common.Compiler_Data.Pri_Stack_Info.Size
                           * SSE.Storage_Offset
                              (Parameters.Sec_Stack_Percentage)
                           / 100;

      Secondary_Stack : aliased Storage_Elements.Storage_Array
                          (1 .. Sec_Stack_Size);

      TH : Termination_Handler := null;

   begin
      Self_ID.Common.Compiler_Data.Sec_Stack_Addr := Secondary_Stack'Address;
      SS_Init (Secondary_Stack'Address, Integer (Sec_Stack_Size));

      --  Initialize low-level TCB components, that cannot be initialized by
      --  the creator.

      Enter_Task (Self_ID);

      --  Call the task body procedure

      Self_ID.Common.Task_Entry_Point (Self_ID.Common.Task_Arg);

      --  Look for a fall-back handler. There is a single task termination
      --  procedure for all the tasks in the partition.

      --  This package is part of the restricted run time which supports
      --  neither task hierarchies (No_Task_Hierarchy) nor specific task
      --  termination handlers (No_Specific_Termination_Handlers).

      --  Raise the priority to prevent race conditions when using
      --  System.Tasking.Fall_Back_Handler.

      --  Set_Priority (Self_ID, Any_Priority'Last);

      --  Lower the relative deadline (as done for priority) to prevent race
      --  conditions when using System.Tasking.Fall_Back_Handler.

      Set_Relative_Deadline (Self_ID,
                             System.BB.Deadlines.Relative_Deadline (0));

      TH := System.Tasking.Fall_Back_Handler;

      --  Restore original priority after retrieving shared data

      --  Set_Priority (Self_ID, Self_ID.Common.Base_Priority);

      --  Restore original relative deadline after retrieving shared data

      Set_Relative_Deadline (Self_ID, Self_ID.Common.Base_Relative_Deadline);

      --  Execute the task termination handler if we found it

      if TH /= null then
         TH.all (Self_ID);
      end if;

      --  We used to raise a Program_Error here to signal the task termination
      --  event in order to avoid silent task death. It has been removed
      --  because the Ada.Task_Termination functionality serves the same
      --  purpose in a more flexible (and standard) way. In addition, this
      --  exception triggered a second execution of the termination handler
      --  (if any was installed). We simply ensure that the task does not
      --  execute any more.

      Sleep (Self_ID, Terminated);
   end Task_Wrapper;

   -----------------------
   -- Restricted GNARLI --
   -----------------------

   -------------------------------
   -- Activate_Restricted_Tasks --
   -------------------------------

   procedure Activate_Restricted_Tasks
     (Chain_Access : Activation_Chain_Access)
   is
      Self_ID : constant Task_Id := Task_Primitives.Operations.Self;
      C       : Task_Id;
      Next_C  : Task_Id;
      Success : Boolean;

   begin
      --  Raise the priority to prevent activated tasks from racing ahead
      --  before we finish activating the chain.

      --  Set_Priority (Self_ID, System.Any_Priority'Last);

      --  Lower the relative deadline to prevent activated tasks from
      --  racing ahead before we finish activating the chain.

      Set_Relative_Deadline (Self_ID,
               System.BB.Deadlines.Relative_Deadline (0));

      --  Activate all the tasks in the chain

      --  Creation of the thread of control was deferred until activation.
      --  So create it now.

      --  Note that since all created tasks will be blocked trying to get our
      --  (environment task) lock, there is no need to lock C here.

      C := Chain_Access.T_ID;
      while C /= null loop
         Next_C := C.Common.Activation_Link;

         C.Common.Activation_Link := null;

         Task_Primitives.Operations.Create_Task
           (T                 => C,
            Wrapper           => Task_Wrapper'Address,
            Stack_Size        => Parameters.Size_Type
                            (C.Common.Compiler_Data.Pri_Stack_Info.Size),
            --  Removed from Ravenscar EDF version
            --  Priority          => C.Common.Base_Priority,
            Relative_Deadline => C.Common.Base_Relative_Deadline,
            Base_CPU          => C.Common.Base_CPU,
            Succeeded         => Success);

         if Success then
            C.Common.State := Runnable;
         else
            raise Program_Error;
         end if;

         C := Next_C;
      end loop;

      Self_ID.Common.State := Runnable;

      --  Restore the original priority

      --  Set_Priority (Self_ID, Self_ID.Common.Base_Priority);

      --  Restore the original relative deadline
      Set_Relative_Deadline (Self_ID, Self_ID.Common.Base_Relative_Deadline);

      --  Remove the tasks from the chain
      Chain_Access.T_ID := null;

   end Activate_Restricted_Tasks;

   ------------------------------------
   -- Complete_Restricted_Activation --
   ------------------------------------

   procedure Complete_Restricted_Activation is
   begin
      --  Nothing to be done

      null;
   end Complete_Restricted_Activation;

   ------------------------------
   -- Complete_Restricted_Task --
   ------------------------------

   procedure Complete_Restricted_Task is
   begin
      --  Mark the task as terminated. Do not suspend the task now
      --  because we need to allow for the task termination procedure
      --  to execute (if needed) in the Task_Wrapper.

      Task_Primitives.Operations.Self.Common.State := Terminated;
   end Complete_Restricted_Task;

   ----------------------------
   -- Create_Restricted_Task --
   ----------------------------

   procedure Create_Restricted_Task
     (Priority          : Integer;
      --  Relative_Deadline : System.BB.Deadlines.Relative_Deadline;
      --  introduced relative deadline attribute
      Stack_Address     : System.Address;
      Size              : System.Parameters.Size_Type;
      Task_Info         : System.Task_Info.Task_Info_Type;
      CPU               : Integer;
      State             : Task_Procedure_Access;
      Discriminants     : System.Address;
      Elaborated        : Access_Boolean;
      Chain             : in out Activation_Chain;
      Task_Image        : String;
      Created_Task      : Task_Id)
   is
      pragma Unreferenced (Task_Image, Elaborated);

      Base_Priority : constant System.Any_Priority := Any_Priority (0);

      Base_Relative_Deadline : System.BB.Deadlines.Relative_Deadline;
      --  for relative deadline assignment

      Base_CPU               : System.Multiprocessors.CPU_Range;
      Success                : Boolean;

      PPP : Any_Priority;
   begin

      PPP := Priority;
      if PPP = 0 then
         PPP := Base_Priority;
      end if;

      --  Base_Priority := Any_Priority (0);

      --  same as priority but related to assign a correct relative deadline
      --  value

      --  IT WILL BE MODIFIED WHEN WE WILL HAVE A WORKING CALL FROM
      --  COMPILER TO THIS METHOD
      Base_Relative_Deadline := System.BB.Deadlines.Relative_Deadline (0);
      --  Base_Relative_Deadline :=
      --    (if Relative_Deadline =
      --             System.BB.Deadlines.Unspecified_Relative_Deadline
      --     then System.BB.Deadlines.Default_Relative_Deadline
      --     else Relative_Deadline);

      if CPU /= Unspecified_CPU
        and then (CPU < Integer (System.Multiprocessors.CPU_Range'First)
                    or else
                  CPU > Integer (System.Multiprocessors.CPU_Range'Last)
                    or else
                  CPU > Integer (System.Multiprocessors.Number_Of_CPUs))
      then
         raise Tasking_Error with "CPU not in range";

      --  Normal CPU affinity

      else
         Base_CPU :=
           (if CPU = Unspecified_CPU
            then Self.Common.Base_CPU
            else System.Multiprocessors.CPU_Range (CPU));
      end if;

      --  No need to lock Self_ID here, since only environment task is running

      Initialize_ATCB  --  called in in s-taskin.adb
        (State, Discriminants,

         Base_Priority,
         Base_Relative_Deadline,
         --  have to be restored after debugging process

         Base_CPU, Task_Info, Stack_Address, Size, Created_Task, Success);

      if not Success then
         raise Program_Error;
      end if;

      Created_Task.Entry_Call.Self := Created_Task;

      --  Append this task to the activation chain

      Created_Task.Common.Activation_Link := Chain.T_ID;
      Chain.T_ID := Created_Task;

   end Create_Restricted_Task;

   ---------------------------
   -- Finalize_Global_Tasks --
   ---------------------------

   --  Dummy version since this procedure is not used in true ravenscar mode

   procedure Finalize_Global_Tasks is
   begin
      raise Program_Error;
   end Finalize_Global_Tasks;

   ---------------------------
   -- Restricted_Terminated --
   ---------------------------

   function Restricted_Terminated (T : Task_Id) return Boolean is
   begin
      return T.Common.State = Terminated;
   end Restricted_Terminated;

begin
   Tasking.Initialize;
end System.Tasking.Restricted.Stages;

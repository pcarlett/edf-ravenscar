------------------------------------------------------------------------------
--                                                                          --
--                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                 --
--                                                                          --
--                        S Y S T E M . T A S K I N G                       --
--                                                                          --
--                                  B o d y                                 --
--                                                                          --
--                     Copyright (C) 2001-2011, AdaCore                     --
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
------------------------------------------------------------------------------

--  This is the Ravenscar/HI-E version of this package

pragma Restrictions (No_Elaboration_Code);

pragma Polling (Off);
--  Turn off polling, we do not want ATC polling to take place during tasking
--  operations. It causes infinite loops and other problems.

with System.Task_Primitives.Operations;
--  used for Self

with System.IO;  --  For debugging process
with System.BB.Debug; use System.BB.Debug;

with System.Secondary_Stack;
--  used for SS_Init
--           Default_Secondary_Stack_Size

package body System.Tasking is

   use System.Secondary_Stack;
   use System.Multiprocessors;

   use System.BB.Deadlines;
   use System.BB.Time;

   ------------------------
   -- Local Declarations --
   ------------------------

   Main_Priority : Integer := Unspecified_Priority;
   pragma Export (C, Main_Priority, "__gl_main_priority");
   --  Priority associated with the environment task. By default, its value is
   --  undefined, and can be set by using pragma Priority in the main program.

   Main_Relative_Deadline : Relative_Deadline :=
     Unspecified_Relative_Deadline;

   pragma Export (C, Main_Relative_Deadline, "__gl_main_relative_deadline");
   --  Relative deadline associated with the environment task. By default,
   --  its value is undefined, and can be set by using pragma Relative_Deadline
   --  in the main program.

   Main_CPU : Integer := Unspecified_CPU;
   pragma Export (C, Main_CPU, "__gl_main_cpu");
   --  Affinity associated with the environment task. By default, its value is
   --  undefined, and can be set by using pragma CPU in the main program.
   --  Switching the environment task to the right CPU is left to the user.

   Environment_Task : array (Multiprocessors.CPU) of
                         aliased Ada_Task_Control_Block (Entry_Num => 0);
   --  ATCB for the environment tasks. The environment task for the main CPU
   --  is the real one, while the others are phantom tasks only present to
   --  correctly handle interrupts (changing the current priority). The name
   --  is of this array is 'Environment_Task' so that there is a nice display
   --  of the environmental task in GDB (which uses the suffix of the symbol).

   -------------------
   -- Get_Sec_Stack --
   -------------------

   function Get_Sec_Stack return Address is
   begin
      return Self.Common.Compiler_Data.Sec_Stack_Addr;
   end Get_Sec_Stack;

   ---------------------
   -- Initialize_ATCB --
   ---------------------

   procedure Initialize_ATCB
     (Task_Entry_Point       : Task_Procedure_Access;
      Task_Arg               : System.Address;
      Base_Priority          : System.Any_Priority;
      Base_Relative_Deadline : System.BB.Deadlines.Relative_Deadline;
      --  have to be restored after debugging process
      Base_CPU               : System.Multiprocessors.CPU_Range;
      Task_Info              : System.Task_Info.Task_Info_Type;
      Stack_Address          : System.Address;
      Stack_Size             : System.Parameters.Size_Type;
      T                      : Task_Id;
      Success                : out Boolean)
   is
   begin
      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Begin.");
      end if;

      T.Common.State := Unactivated;

      --  Initialize T.Common.LL

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... TCB.");
      end if;

      Task_Primitives.Operations.Initialize_TCB (T, Success);

      if not Success then
         return;
      end if;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Prio.");
      end if;

      T.Common.Base_Priority := Base_Priority;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Rel_Dead.");
      end if;

      T.Common.Base_Relative_Deadline := Base_Relative_Deadline;
      --  for relative deadline

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... CPU.");
      end if;

      T.Common.Base_CPU := Base_CPU;
      T.Common.Protected_Action_Nesting := 0;
      T.Common.Task_Arg := Task_Arg;
      T.Common.Task_Entry_Point := Task_Entry_Point;
      T.Common.Task_Info := Task_Info;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Addresses.");
      end if;

      T.Common.Compiler_Data.Pri_Stack_Info.Start_Address :=
        Stack_Address;

      T.Common.Compiler_Data.Pri_Stack_Info.Size :=
        Storage_Elements.Storage_Offset
          (Parameters.Adjust_Storage_Size (Stack_Size));

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Storage Size: " &
                      System.Parameters.Size_Type'Image (Storage_Size (T)));
      end if;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Init ATCB Process... Ended.");
      end if;

   end Initialize_ATCB;

   ----------------
   -- Initialize --
   ----------------

   Secondary_Stack : aliased Storage_Elements.Storage_Array
                       (1 .. Storage_Elements.Storage_Offset
                               (Default_Secondary_Stack_Size));
   for Secondary_Stack'Alignment use Standard'Maximum_Alignment;
   pragma Warnings (Off, Secondary_Stack);

   Initialized : Boolean := False;
   --  Used to prevent multiple calls to Initialize

   procedure Initialize is
      Base_Priority : constant Any_Priority := System.Any_Priority (0);

      Base_Relative_Deadline : Relative_Deadline;
      --  have to be restored after debugging process
      --  for relative deadline

      Base_CPU      : System.Multiprocessors.CPU;

      Success : Boolean;
      pragma Warnings (Off, Success);

      CPU_Not_In_Range : Boolean := False;

   begin
      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... Begin.");
      end if;

      if Initialized then
         return;
      end if;

      Initialized := True;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... CPU.");
      end if;

      if Main_CPU /= Unspecified_CPU
        and then (Main_CPU < Integer (System.Multiprocessors.CPU_Range'First)
                    or else
                  Main_CPU > Integer (System.Multiprocessors.CPU_Range'Last)
                    or else
                  Main_CPU > Integer (System.Multiprocessors.Number_Of_CPUs))
      then
         --  Invalid CPU, will raise Tasking_Error after the environment task
         --  is initialized (as exception propagation is supported in full
         --  ravenscar profile)

         CPU_Not_In_Range := True;

         --  Use the default CPU as Main_CPU

         Base_CPU := CPU'First;

      else
         Base_CPU :=
           (if Main_CPU = Unspecified_CPU
              or else CPU_Range (Main_CPU) = Not_A_Specific_CPU
            then CPU'First -- Default CPU
            else CPU (Main_CPU));
      end if;

      --  Set Main_CPU with the selected CPU value
      --  (instead of Unspecified_CPU or Not_A_Specific_CPU)

      Main_CPU := Integer (Base_CPU);

      --  Base_Priority := System.Any_Priority (0);

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... Rel_Dead.");
      end if;

      --  For Relative_Deadline configuration
      --  have to be restored after debugging process
      if Main_Relative_Deadline = Unspecified_Relative_Deadline then
         Base_Relative_Deadline := Default_Relative_Deadline;
      else
         Base_Relative_Deadline := Main_Relative_Deadline;
      end if;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... ATCB.");
      end if;

      Initialize_ATCB
        (null, Null_Address,

         Base_Priority,
         Base_Relative_Deadline,
         --  have to be restored after debugging process
         --  for relative deadline attribute

         Base_CPU, Task_Info.Unspecified_Task_Info, Null_Address, 0,
         Environment_Task (Base_CPU)'Access, Success);

      if Debug_Tasks then
         System.IO.Put_Line
               ("Tasking Initialization Process... Environment_Task.");
      end if;

      Task_Primitives.Operations.Initialize
        (Environment_Task (Base_CPU)'Access);

      --  Note: we used to set the priority at this point, but it is already
      --  done in Enter_Task via s-taprop.Initialize.

      Environment_Task (Base_CPU).Common.State := Runnable;
      Environment_Task (Base_CPU).Entry_Call.Self :=
        Environment_Task (Base_CPU)'Access;

      --  Initialize the secondary stack

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... Addresses.");
      end if;

      Environment_Task (Base_CPU).Common.Compiler_Data.Sec_Stack_Addr :=
        Secondary_Stack'Address;
      SS_Init (Secondary_Stack'Address, Default_Secondary_Stack_Size);

      --  No fall back handler by default

      Fall_Back_Handler := null;

      --  Deferred exception if CPU is invalid

      if CPU_Not_In_Range then
         raise Tasking_Error with "Main CPU not in range";
      end if;

      if Debug_Tasks then
         System.IO.Put_Line ("Tasking Initialization Process... Ended.");
      end if;

   end Initialize;

   ----------------------
   -- Initialize_Slave --
   ----------------------

   procedure Initialize_Slave (CPU_Id : CPU) is
      Base_Priority : constant Any_Priority := System.Any_Priority (0);

      Base_Relative_Deadline : constant Relative_Deadline :=
                  System.BB.Deadlines.Relative_Deadline (0);

      Success  : Boolean;
      pragma Warnings (Off, Success);

   begin
      --  Initialize a fake environment task for this slave CPU

      if Debug_Tasks then
         System.IO.Put_Line ("Slave Tasking Initialization Process... Begin.");
      end if;

      if Debug_Tasks then
         System.IO.Put_Line ("Slave Tasking Initialization Process... ATCB.");
      end if;

      Initialize_ATCB
        (null, Null_Address,

         Base_Priority,
         Base_Relative_Deadline,
         --  have to be restored after debugging process
         --  for relative deadline

         CPU_Id, Task_Info.Unspecified_Task_Info, Null_Address, 0,
         Environment_Task (CPU_Id)'Access, Success);

      if Debug_Tasks then
         System.IO.Put_Line ("Slave Tasking Initialization Process... CPU.");
      end if;

      Task_Primitives.Operations.Initialize_Slave
        (Environment_Task (CPU_Id)'Access);

      --  Task_Primitives.Operations.Set_Priority
      --    (Environment_Task (CPU_Id)'Access, Base_Priority);

      if Debug_Tasks then
         System.IO.Put_Line
               ("Slave Tasking Initialization Process... Rel_Dead.");
      end if;

      Task_Primitives.Operations.Set_Relative_Deadline
        (Environment_Task (CPU_Id)'Access, Base_Relative_Deadline);
      --  for init relative deadline in slave environment

      Environment_Task (CPU_Id).Entry_Call.Self :=
        Environment_Task (CPU_Id)'Access;

      --  The task has no code to execute and will stay in an unactivated state

      if Debug_Tasks then
         System.IO.Put_Line
               ("Slave Tasking Initialization Process... Deactivate.");
      end if;

      Environment_Task (CPU_Id).Common.State := Unactivated;

      --  This call to the sleep procedure will force the current CPU to start
      --  execution of its tasks.

      Task_Primitives.Operations.Sleep
        (Environment_Task (CPU_Id)'Access, Unactivated);

      if Debug_Tasks then
         System.IO.Put_Line ("Slave Tasking Initialization Process... Ended.");
      end if;

   end Initialize_Slave;

   ----------
   -- Self --
   ----------

   function Self return Task_Id renames System.Task_Primitives.Operations.Self;

   ------------------
   -- Storage_Size --
   ------------------

   function Storage_Size (T : Task_Id) return System.Parameters.Size_Type is
   begin
      return
        System.Parameters.Size_Type
          (T.Common.Compiler_Data.Pri_Stack_Info.Size);
   end Storage_Size;

end System.Tasking;

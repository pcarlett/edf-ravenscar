pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~unit02.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~unit02.adb");

package body ada_main is
   pragma Warnings (Off);

   E033 : Short_Integer; pragma Import (Ada, E033, "ada__tags_E");
   E084 : Short_Integer; pragma Import (Ada, E084, "system__bb__timing_events_E");
   E108 : Short_Integer; pragma Import (Ada, E108, "system__tasking__protected_objects_E");
   E112 : Short_Integer; pragma Import (Ada, E112, "system__tasking__protected_objects__multiprocessors_E");
   E114 : Short_Integer; pragma Import (Ada, E114, "system__tasking__restricted__stages_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__real_time_E");
   E104 : Short_Integer; pragma Import (Ada, E104, "sporadic_and_protected_entry_E");
   E116 : Short_Integer; pragma Import (Ada, E116, "system_time_E");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");
   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      s_stalib_adafinal;
   end adafinal;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Zero_Cost_Exceptions : Integer;
      pragma Import (C, Zero_Cost_Exceptions, "__gl_zero_cost_exceptions");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");

      procedure Install_Handler;
      pragma Import (C, Install_Handler, "__gnat_install_handler");

      Handler_Installed : Integer;
      pragma Import (C, Handler_Installed, "__gnat_handler_installed");
   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := 0;
      WC_Encoding := 'b';
      Locking_Policy := 'C';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := 'F';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Zero_Cost_Exceptions := 0;
      Detect_Blocking := 1;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      if Handler_Installed = 0 then
         Install_Handler;
      end if;

      System.Bb.Timing_Events'Elab_Spec;
      E084 := E084 + 1;
      Ada.Tags'Elab_Body;
      E033 := E033 + 1;
      System.Tasking.Protected_Objects'Elab_Body;
      E108 := E108 + 1;
      System.Tasking.Protected_Objects.Multiprocessors'Elab_Body;
      E112 := E112 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E114 := E114 + 1;
      Ada.Real_Time'Elab_Spec;
      Ada.Real_Time'Elab_Body;
      E006 := E006 + 1;
      Sporadic_And_Protected_Entry'Elab_Spec;
      System_Time'Elab_Spec;
      E116 := E116 + 1;
      Sporadic_And_Protected_Entry'Elab_Body;
      E104 := E104 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_unit02");

   procedure main is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
   end;

--  BEGIN Object file/option list
   --   ./ada.o
   --   ./interfac.o
   --   ./i-c.o
   --   ./system.o
   --   ./s-bb.o
   --   ./s-bbdebu.o
   --   ./s-casuti.o
   --   ./s-imgint.o
   --   ./s-imgdec.o
   --   ./s-imglli.o
   --   ./s-imglld.o
   --   ./s-maccod.o
   --   ./s-parame.o
   --   ./s-bbpara.o
   --   ./s-multip.o
   --   ./s-bcprmu.o
   --   ./s-bbdead.o
   --   ./s-musplo.o
   --   ./s-osinte.o
   --   ./s-mufalo.o
   --   ./s-stoele.o
   --   ./s-bbinte.o
   --   ./s-bbcppr.o
   --   ./s-bbtiev.o
   --   ./s-strhas.o
   --   ./s-htable.o
   --   ./s-tasinf.o
   --   ./s-taspri.o
   --   ./s-soflin.o
   --   ./s-tasdeb.o
   --   ./s-taprop.o
   --   ./s-io.o
   --   ./s-traent.o
   --   ./s-unstyp.o
   --   ./s-textio.o
   --   ./s-bbsule.o
   --   ./s-bbbosu.o
   --   ./s-imguns.o
   --   ./s-bbtime.o
   --   ./s-valuti.o
   --   ./s-valuns.o
   --   ./s-wchcon.o
   --   ./s-wchjis.o
   --   ./s-wchcnv.o
   --   ./s-wchstw.o
   --   ./s-bbthqu.o
   --   ./s-bbthre.o
   --   ./s-bbprot.o
   --   ./s-memory.o
   --   ./s-stalib.o
   --   ./s-taskin.o
   --   ./a-tags.o
   --   ./s-secsta.o
   --   ./s-addima.o
   --   ./a-exctra.o
   --   ./s-taprob.o
   --   ./s-tpobmu.o
   --   ./s-tposen.o
   --   ./s-tasres.o
   --   ./s-tarest.o
   --   ./a-except.o
   --   ./s-traceb.o
   --   ./a-reatim.o
   --   ./a-retide.o
   --   ./unit02.o
   --   ./system_time.o
   --   ./sporadic_and_protected_entry.o
   --   -L./
   --   -L./raven-edf/
   --   -L/usr/gnat-rvs/lib/gcc/leon-elf/4.5.4/rts-ravenscar/adalib/
   --   -static
   --   -lgnarl
   --   -lgnat
--  END Object file/option list   

end ada_main;

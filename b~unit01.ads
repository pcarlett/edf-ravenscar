pragma Ada_95;
with System;
package ada_main is
   pragma Warnings (Off);


   GNAT_Version : constant String :=
                    "GNAT Version: GPL 2012 (20120509)" & ASCII.NUL;
   pragma Export (C, GNAT_Version, "__gnat_version");

   Ada_Main_Program_Name : constant String := "_ada_unit01" & ASCII.NUL;
   pragma Export (C, Ada_Main_Program_Name, "__gnat_ada_main_program_name");

   procedure adainit;
   pragma Export (C, adainit, "adainit");

   procedure adafinal;
   pragma Export (C, adafinal, "adafinal");

   procedure main;
   pragma Export (C, main, "main");

   type Version_32 is mod 2 ** 32;
   u00001 : constant Version_32 := 16#fb0a1f46#;
   pragma Export (C, u00001, "unit01B");
   u00002 : constant Version_32 := 16#dec386da#;
   pragma Export (C, u00002, "system__standard_libraryB");
   u00003 : constant Version_32 := 16#4d31c507#;
   pragma Export (C, u00003, "system__standard_libraryS");
   u00004 : constant Version_32 := 16#3ffc8e18#;
   pragma Export (C, u00004, "adaS");
   u00005 : constant Version_32 := 16#a7778822#;
   pragma Export (C, u00005, "ada__real_timeB");
   u00006 : constant Version_32 := 16#72fea5c4#;
   pragma Export (C, u00006, "ada__real_timeS");
   u00007 : constant Version_32 := 16#9f5cb267#;
   pragma Export (C, u00007, "systemS");
   u00008 : constant Version_32 := 16#aad5da11#;
   pragma Export (C, u00008, "system__task_primitivesS");
   u00009 : constant Version_32 := 16#5a0913e4#;
   pragma Export (C, u00009, "system__os_interfaceS");
   u00010 : constant Version_32 := 16#176bdab1#;
   pragma Export (C, u00010, "system__bbS");
   u00011 : constant Version_32 := 16#9742fdbf#;
   pragma Export (C, u00011, "system__bb__board_supportB");
   u00012 : constant Version_32 := 16#ca671f83#;
   pragma Export (C, u00012, "system__bb__board_supportS");
   u00013 : constant Version_32 := 16#6fd51f31#;
   pragma Export (C, u00013, "system__bb__board_support__leonS");
   u00014 : constant Version_32 := 16#f5bdee11#;
   pragma Export (C, u00014, "system__unsigned_typesS");
   u00015 : constant Version_32 := 16#b40fe8c7#;
   pragma Export (C, u00015, "system__bb__cpu_primitivesB");
   u00016 : constant Version_32 := 16#7f2fd76e#;
   pragma Export (C, u00016, "system__bb__cpu_primitivesS");
   u00017 : constant Version_32 := 16#ba3a2f9b#;
   pragma Export (C, u00017, "ada__exceptionsB");
   u00018 : constant Version_32 := 16#187df3a2#;
   pragma Export (C, u00018, "ada__exceptionsS");
   u00019 : constant Version_32 := 16#83c02e81#;
   pragma Export (C, u00019, "ada__exceptions__tracebackB");
   u00020 : constant Version_32 := 16#f1ec4e3b#;
   pragma Export (C, u00020, "ada__exceptions__tracebackS");
   u00021 : constant Version_32 := 16#5e68c1f5#;
   pragma Export (C, u00021, "system__secondary_stackB");
   u00022 : constant Version_32 := 16#c141a5bd#;
   pragma Export (C, u00022, "system__secondary_stackS");
   u00023 : constant Version_32 := 16#ace32e1e#;
   pragma Export (C, u00023, "system__storage_elementsB");
   u00024 : constant Version_32 := 16#6591cfff#;
   pragma Export (C, u00024, "system__storage_elementsS");
   u00025 : constant Version_32 := 16#ada34a87#;
   pragma Export (C, u00025, "system__traceback_entriesB");
   u00026 : constant Version_32 := 16#cd7d5c26#;
   pragma Export (C, u00026, "system__traceback_entriesS");
   u00027 : constant Version_32 := 16#4be59f3d#;
   pragma Export (C, u00027, "system__soft_linksB");
   u00028 : constant Version_32 := 16#e11c16a3#;
   pragma Export (C, u00028, "system__soft_linksS");
   u00029 : constant Version_32 := 16#da07b740#;
   pragma Export (C, u00029, "system__bb__deadlinesS");
   u00030 : constant Version_32 := 16#2d8278f1#;
   pragma Export (C, u00030, "system__bb__timeB");
   u00031 : constant Version_32 := 16#ffcfe598#;
   pragma Export (C, u00031, "system__bb__timeS");
   u00032 : constant Version_32 := 16#e65e2cb6#;
   pragma Export (C, u00032, "ada__tagsB");
   u00033 : constant Version_32 := 16#36684837#;
   pragma Export (C, u00033, "ada__tagsS");
   u00034 : constant Version_32 := 16#84debe5c#;
   pragma Export (C, u00034, "system__htableB");
   u00035 : constant Version_32 := 16#1cf4fc69#;
   pragma Export (C, u00035, "system__htableS");
   u00036 : constant Version_32 := 16#8b7dad61#;
   pragma Export (C, u00036, "system__string_hashB");
   u00037 : constant Version_32 := 16#b9c06af3#;
   pragma Export (C, u00037, "system__string_hashS");
   u00038 : constant Version_32 := 16#e6965fe6#;
   pragma Export (C, u00038, "system__val_unsB");
   u00039 : constant Version_32 := 16#e515032a#;
   pragma Export (C, u00039, "system__val_unsS");
   u00040 : constant Version_32 := 16#46a1f7a9#;
   pragma Export (C, u00040, "system__val_utilB");
   u00041 : constant Version_32 := 16#94f12778#;
   pragma Export (C, u00041, "system__val_utilS");
   u00042 : constant Version_32 := 16#b7fa72e7#;
   pragma Export (C, u00042, "system__case_utilB");
   u00043 : constant Version_32 := 16#3240d2ef#;
   pragma Export (C, u00043, "system__case_utilS");
   u00044 : constant Version_32 := 16#907d882f#;
   pragma Export (C, u00044, "system__wch_conB");
   u00045 : constant Version_32 := 16#20b79c5a#;
   pragma Export (C, u00045, "system__wch_conS");
   u00046 : constant Version_32 := 16#22fed88a#;
   pragma Export (C, u00046, "system__wch_stwB");
   u00047 : constant Version_32 := 16#0da6b05b#;
   pragma Export (C, u00047, "system__wch_stwS");
   u00048 : constant Version_32 := 16#b8a9e30d#;
   pragma Export (C, u00048, "system__wch_cnvB");
   u00049 : constant Version_32 := 16#3e491a8c#;
   pragma Export (C, u00049, "system__wch_cnvS");
   u00050 : constant Version_32 := 16#129923ea#;
   pragma Export (C, u00050, "interfacesS");
   u00051 : constant Version_32 := 16#75729fba#;
   pragma Export (C, u00051, "system__wch_jisB");
   u00052 : constant Version_32 := 16#6a3b8198#;
   pragma Export (C, u00052, "system__wch_jisS");
   u00053 : constant Version_32 := 16#f22a3c08#;
   pragma Export (C, u00053, "system__bb__cpu_primitives__multiprocessorsB");
   u00054 : constant Version_32 := 16#50824d5f#;
   pragma Export (C, u00054, "system__bb__cpu_primitives__multiprocessorsS");
   u00055 : constant Version_32 := 16#5a83c3a4#;
   pragma Export (C, u00055, "system__multiprocessorsB");
   u00056 : constant Version_32 := 16#1276684e#;
   pragma Export (C, u00056, "system__multiprocessorsS");
   u00057 : constant Version_32 := 16#a684cb17#;
   pragma Export (C, u00057, "system__bb__parametersS");
   u00058 : constant Version_32 := 16#59f21dc8#;
   pragma Export (C, u00058, "system__parametersB");
   u00059 : constant Version_32 := 16#cffbc5ba#;
   pragma Export (C, u00059, "system__parametersS");
   u00060 : constant Version_32 := 16#df102973#;
   pragma Export (C, u00060, "system__bb__debugS");
   u00061 : constant Version_32 := 16#82adf9a1#;
   pragma Export (C, u00061, "system__bb__interruptsB");
   u00062 : constant Version_32 := 16#8cd54782#;
   pragma Export (C, u00062, "system__bb__interruptsS");
   u00063 : constant Version_32 := 16#091f64a7#;
   pragma Export (C, u00063, "system__bb__threadsB");
   u00064 : constant Version_32 := 16#67020162#;
   pragma Export (C, u00064, "system__bb__threadsS");
   u00065 : constant Version_32 := 16#5eeee5bf#;
   pragma Export (C, u00065, "system__bb__protectionB");
   u00066 : constant Version_32 := 16#7cbd1653#;
   pragma Export (C, u00066, "system__bb__protectionS");
   u00067 : constant Version_32 := 16#cb0a5d34#;
   pragma Export (C, u00067, "system__bb__threads__queuesB");
   u00068 : constant Version_32 := 16#8312413b#;
   pragma Export (C, u00068, "system__bb__threads__queuesS");
   u00069 : constant Version_32 := 16#b012ff50#;
   pragma Export (C, u00069, "system__img_intB");
   u00070 : constant Version_32 := 16#9d8752a5#;
   pragma Export (C, u00070, "system__img_intS");
   u00071 : constant Version_32 := 16#276453b7#;
   pragma Export (C, u00071, "system__img_lldB");
   u00072 : constant Version_32 := 16#6c7ebb0e#;
   pragma Export (C, u00072, "system__img_lldS");
   u00073 : constant Version_32 := 16#8da1623b#;
   pragma Export (C, u00073, "system__img_decB");
   u00074 : constant Version_32 := 16#3171bbbc#;
   pragma Export (C, u00074, "system__img_decS");
   u00075 : constant Version_32 := 16#9777733a#;
   pragma Export (C, u00075, "system__img_lliB");
   u00076 : constant Version_32 := 16#8e13e7b6#;
   pragma Export (C, u00076, "system__img_lliS");
   u00077 : constant Version_32 := 16#f12dc122#;
   pragma Export (C, u00077, "system__ioB");
   u00078 : constant Version_32 := 16#011e4528#;
   pragma Export (C, u00078, "system__ioS");
   u00079 : constant Version_32 := 16#6eec0579#;
   pragma Export (C, u00079, "system__text_ioB");
   u00080 : constant Version_32 := 16#ea6ee296#;
   pragma Export (C, u00080, "system__text_ioS");
   u00081 : constant Version_32 := 16#e7885ff1#;
   pragma Export (C, u00081, "system__bb__timing_eventsB");
   u00082 : constant Version_32 := 16#e31959dd#;
   pragma Export (C, u00082, "system__bb__timing_eventsS");
   u00083 : constant Version_32 := 16#194ccd7b#;
   pragma Export (C, u00083, "system__img_unsB");
   u00084 : constant Version_32 := 16#6a49d2e6#;
   pragma Export (C, u00084, "system__img_unsS");
   u00085 : constant Version_32 := 16#735ddf8e#;
   pragma Export (C, u00085, "system__multiprocessors__fair_locksB");
   u00086 : constant Version_32 := 16#a70e2885#;
   pragma Export (C, u00086, "system__multiprocessors__fair_locksS");
   u00087 : constant Version_32 := 16#51eaa4e5#;
   pragma Export (C, u00087, "system__multiprocessors__spin_locksB");
   u00088 : constant Version_32 := 16#9ac42bf1#;
   pragma Export (C, u00088, "system__multiprocessors__spin_locksS");
   u00089 : constant Version_32 := 16#90e7c9a9#;
   pragma Export (C, u00089, "system__machine_codeS");
   u00090 : constant Version_32 := 16#1eeef42a#;
   pragma Export (C, u00090, "system__task_primitives__operationsB");
   u00091 : constant Version_32 := 16#041e10af#;
   pragma Export (C, u00091, "system__task_primitives__operationsS");
   u00092 : constant Version_32 := 16#45ef19a1#;
   pragma Export (C, u00092, "system__taskingB");
   u00093 : constant Version_32 := 16#349a2d9f#;
   pragma Export (C, u00093, "system__taskingS");
   u00094 : constant Version_32 := 16#81c6b8c3#;
   pragma Export (C, u00094, "system__task_infoB");
   u00095 : constant Version_32 := 16#7e7c505d#;
   pragma Export (C, u00095, "system__task_infoS");
   u00096 : constant Version_32 := 16#0f8eba36#;
   pragma Export (C, u00096, "system__tasking__debugB");
   u00097 : constant Version_32 := 16#1144053f#;
   pragma Export (C, u00097, "system__tasking__debugS");
   u00098 : constant Version_32 := 16#ffd0e681#;
   pragma Export (C, u00098, "system__tracebackB");
   u00099 : constant Version_32 := 16#1e81dd04#;
   pragma Export (C, u00099, "system__tracebackS");
   u00100 : constant Version_32 := 16#ff8c918e#;
   pragma Export (C, u00100, "interfaces__cS");
   u00101 : constant Version_32 := 16#f1b1a855#;
   pragma Export (C, u00101, "cyclic_tasksB");
   u00102 : constant Version_32 := 16#f9abaf2c#;
   pragma Export (C, u00102, "cyclic_tasksS");
   u00103 : constant Version_32 := 16#aa332a8f#;
   pragma Export (C, u00103, "ada__real_time__delaysB");
   u00104 : constant Version_32 := 16#4d02654a#;
   pragma Export (C, u00104, "ada__real_time__delaysS");
   u00105 : constant Version_32 := 16#fbdeb058#;
   pragma Export (C, u00105, "system__tasking__restricted__stagesB");
   u00106 : constant Version_32 := 16#5eca94a0#;
   pragma Export (C, u00106, "system__tasking__restricted__stagesS");
   u00107 : constant Version_32 := 16#d0068a3e#;
   pragma Export (C, u00107, "system__tasking__restrictedS");
   u00108 : constant Version_32 := 16#ccc6d0aa#;
   pragma Export (C, u00108, "system_timeS");
   u00109 : constant Version_32 := 16#6b556097#;
   pragma Export (C, u00109, "system__memoryB");
   u00110 : constant Version_32 := 16#55d70e72#;
   pragma Export (C, u00110, "system__memoryS");
   --  BEGIN ELABORATION ORDER
   --  ada%s
   --  interfaces%s
   --  interfaces.c%s
   --  system%s
   --  system.bb%s
   --  system.bb.debug%s
   --  system.bb.protection%s
   --  system.case_util%s
   --  system.case_util%b
   --  system.htable%s
   --  system.img_dec%s
   --  system.img_int%s
   --  system.img_int%b
   --  system.img_dec%b
   --  system.img_lld%s
   --  system.img_lli%s
   --  system.img_lli%b
   --  system.img_lld%b
   --  system.io%s
   --  system.machine_code%s
   --  system.parameters%s
   --  system.parameters%b
   --  system.bb.parameters%s
   --  system.bb.cpu_primitives%s
   --  system.multiprocessors%s
   --  system.multiprocessors%b
   --  system.bb.cpu_primitives.multiprocessors%s
   --  system.bb.cpu_primitives.multiprocessors%b
   --  system.bb.interrupts%s
   --  system.bb.board_support%s
   --  system.bb.time%s
   --  system.bb.deadlines%s
   --  system.bb.threads%s
   --  system.bb.threads.queues%s
   --  system.bb.threads.queues%b
   --  system.bb.protection%b
   --  system.multiprocessors.spin_locks%s
   --  system.multiprocessors.spin_locks%b
   --  system.multiprocessors.fair_locks%s
   --  system.os_interface%s
   --  system.multiprocessors.fair_locks%b
   --  system.standard_library%s
   --  ada.exceptions%s
   --  system.soft_links%s
   --  system.storage_elements%s
   --  system.storage_elements%b
   --  system.bb.threads%b
   --  system.bb.interrupts%b
   --  system.bb.cpu_primitives%b
   --  ada.tags%s
   --  system.bb.timing_events%s
   --  system.bb.timing_events%b
   --  system.string_hash%s
   --  system.string_hash%b
   --  system.htable%b
   --  system.task_info%s
   --  system.task_info%b
   --  system.task_primitives%s
   --  system.tasking%s
   --  system.task_primitives.operations%s
   --  system.soft_links%b
   --  system.tasking.debug%s
   --  system.tasking.debug%b
   --  system.task_primitives.operations%b
   --  system.text_io%s
   --  system.io%b
   --  system.traceback_entries%s
   --  system.traceback_entries%b
   --  system.unsigned_types%s
   --  system.text_io%b
   --  system.bb.board_support.leon%s
   --  system.bb.board_support%b
   --  system.img_uns%s
   --  system.img_uns%b
   --  system.bb.time%b
   --  system.val_uns%s
   --  system.val_util%s
   --  system.val_util%b
   --  system.val_uns%b
   --  system.wch_con%s
   --  system.wch_con%b
   --  system.wch_cnv%s
   --  system.wch_jis%s
   --  system.wch_jis%b
   --  system.wch_cnv%b
   --  system.wch_stw%s
   --  system.wch_stw%b
   --  ada.exceptions.traceback%s
   --  system.memory%s
   --  system.memory%b
   --  system.standard_library%b
   --  system.secondary_stack%s
   --  system.tasking%b
   --  ada.tags%b
   --  system.secondary_stack%b
   --  ada.exceptions.traceback%b
   --  system.tasking.restricted%s
   --  system.tasking.restricted.stages%s
   --  system.tasking.restricted.stages%b
   --  system.traceback%s
   --  ada.exceptions%b
   --  system.traceback%b
   --  ada.real_time%s
   --  ada.real_time%b
   --  ada.real_time.delays%s
   --  ada.real_time.delays%b
   --  cyclic_tasks%s
   --  unit01%b
   --  system_time%s
   --  cyclic_tasks%b
   --  END ELABORATION ORDER


end ada_main;

with System.BB.Board_Support.LEON;
--  to get definitions of MEC registers such as:
--    Test_Control
--    Interrupt_Mask
--    Interrupt_Force

with System.IO;
with Ada.Interrupts.Names;

procedure Force_External_Interrupt_2 is

   package SPR renames System.BB.Board_Support.LEON;

   --  The MEC registers must be accesses as a whole.
   --  The workaround used to force GNAT to generate proper instructions is:
   --  Registers type definition are qualified with pragma Atomic
   --  and auxiliary objects are used to write the MEC registers

   Interrupt_Mask_Auxiliary : SPR.Interrupt_Mask_and_Priority_Register := SPR.Interrupt_Mask_and_Priority;
   Interrupt_Force_Auxiliary : SPR.Interrupt_Register := SPR.Interrupt_Force;
   Interrupt_Clear_Auxiliary : SPR.Interrupt_Register := SPR.Interrupt_Clear;

begin

   System.IO.Put_Line ("Interruption Loading: " &
                    Ada.Interrupts.Interrupt_ID'Image (Ada.Interrupts.Names.External_Interrupt_2) & ".");

   Interrupt_Mask_Auxiliary.External_2 := True;
   Interrupt_Clear_Auxiliary.External_2 := True;
   Interrupt_Force_Auxiliary.External_2 := True;

   SPR.Interrupt_Mask_and_Priority := Interrupt_Mask_Auxiliary;
   SPR.Interrupt_Clear := Interrupt_Clear_Auxiliary;
   SPR.Interrupt_Force := Interrupt_Force_Auxiliary;

end Force_External_Interrupt_2;

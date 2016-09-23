with System.IO; use System.IO;

package body System.BB.Write is

   procedure Write_Out (S : String) is
      --  Output : File_Type;
   begin
      Set_Output (Standard_Output);
      loop
         begin
            Put_Line (S);
         end;
      end loop;
   end Write_Out;

end System.BB.Write;

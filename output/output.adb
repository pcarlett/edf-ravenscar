with System.IO;

procedure Output is

   Outfile : System.IO.File_Type := ;

begin

   System.IO.Set_Output (Outfile);

   System.IO.Put_Line ("TEST OF OUTPUT!");

end Output;

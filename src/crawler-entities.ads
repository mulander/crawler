with Terminal_Interface.Curses;

package Crawler.Entities is
   package Curses renames Terminal_Interface.Curses;

   type Character is limited private;

   function Make(Symbol : Standard.Character;
                 Row : Curses.Line_Position;
                 Col : Curses.Column_Position) return Character;

   procedure Set_Position (This : out Character;
                          Row  : Curses.Line_Position;
                           Col  : Curses.Column_Position);

   function Get_Row (This : in Character) return Curses.Line_Position;
   function Get_Col (This : in Character) return Curses.Column_Position;
   function Get_Symbol (This : in Character) return Standard.Character;
private
   type Character is limited record
      Row    : Curses.Line_Position;
      Col    : Curses.Column_Position;
      Symbol : Standard.Character;
   end record;
end Crawler.Entities;

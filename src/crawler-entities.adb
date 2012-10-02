package body Crawler.Entities is

   function Make(Symbol : Standard.Character;
                 Row : Curses.Line_Position;
                 Col : Curses.Column_Position) return Character
   is
   begin
      return (Symbol => Symbol, Row => 10, Col => 10);
   end Make;

   procedure Set_Position(This : out Character;
                          Row  : Curses.Line_Position;
                          Col  : Curses.Column_Position)
   is
   begin
      This.Row := Row;
      This.Col := Col;
   end Set_Position;

   function Get_Row (This : in Character) return Curses.Line_Position
   is
   begin
      return This.Row;
   end Get_Row;

   function Get_Col (This : in Character) return Curses.Column_Position
   is
   begin
      return This.Col;
   end Get_Col;

   function Get_Symbol (This : in Character) return Standard.Character
   is
   begin
      return This.Symbol;
   end Get_Symbol;

end Crawler.Entities;

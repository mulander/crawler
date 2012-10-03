-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Terminal_Interface.Curses;


package body Crawler_Interface is


   overriding procedure Initialize (This : in out Screen)
   is
      package Curses renames Terminal_Interface.Curses;
      Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   begin
      -- Initialize ncurses
      Curses.Init_Screen; --initscr;
      Curses.Set_NL_Mode; --  (False);
      Curses.Clear; --clear;
      Curses.Set_Echo_Mode (False);
      Curses.Set_Cbreak_Mode (True);
      Curses.Set_Keypad_Mode;
      Curses.Set_Cursor_Visibility (Cursor_Visibility);

      Curses.Get_Size (Number_Of_Lines   => This.Height,
                       Number_Of_Columns => This.Width);
   end Initialize;



   overriding procedure Finalize (This : in out Screen)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      -- Clear ncurses data structures
      Curses.End_Windows;
   end Finalize;



   procedure Add (This : in Screen;
                  Str  : in String)
   is
   begin
      Curses.Add (Str => Str);
   end Add;



   function Get_Height(This : in Screen) return Curses.Line_Count
   is
   begin
      return This.Height;
   end Get_Height;



   function Get_Width(This : in Screen) return Curses.Column_Count
   is
   begin
      return This.Width;
   end Get_Width;





   -- Frame
   procedure Make (This   : in out Frame;
                  Height : Curses.Line_Count;
                  Width  : Curses.Column_Count;
                  Row    : Curses.Line_Position;
                  Col    : Curses.Column_Position)
   is
   begin
      This.Height := Height;
      This.Width  := Width;
      This.Row := Row;
      This.Col := Col;
      This.Has_Parent_Window := False;
      This.Window := Curses.Create(Number_Of_Lines => Height
                                   ,Number_Of_Columns => Width
                                   ,First_Line_Position => Row
                                   ,First_Column_Position => Col);
      This.Parent := Curses.Null_Window;
   end Make;

   procedure Make_Sub_Window (This   : in out Frame;
                              Parent : Frame;
                              Height : Curses.Line_Count;
                              Width  : Curses.Column_Count;
                              Row    : Curses.Line_Position;
                              Col    : Curses.Column_Position)
   is
   begin
      This.Height := Height;
      This.Width  := Width;
      This.Row := Row;
      This.Col := Col;
      This.Has_Parent_Window := True;
      This.Window := Curses.Derived_Window(Parent.Window,
                                           Number_Of_Lines => Height
                                           ,Number_Of_Columns => Width
                                           ,First_Line_Position => Row
                                           ,First_Column_Position => Col);
      This.Parent := Parent.Get_Window;
   end Make_Sub_Window;

   function Get_Window (This : in Frame) return Curses.Window
   is
   begin
      return This.Window;
   end Get_Window;

   function Get_Parent_Window (This : in Frame) return Curses.Window
   is
   begin
      return This.Parent;
   end Get_Parent_Window;

   function Has_Parent_Window (This : in Frame) return Boolean
   is
   begin
      return This.Has_Parent_Window;
   end Has_Parent_Window;

   function Get_Height (This : in Frame) return Curses.Line_Count
   is
   begin
      return This.Height;
   end Get_Height;

   function Get_Width (This : in Frame) return Curses.Column_Count
   is
   begin
      return This.Width;
   end Get_Width;

   function Get_Row (This : in Frame) return Curses.Line_Position
   is
   begin
      return This.Row;
   end Get_Row;

   function Get_Col (This : in Frame) return Curses.Column_Position
   is
   begin
      return This.Col;
   end Get_Col;



   procedure internal_Add (This : in Frame;
                           Char : in Character;
                           Row : in Curses.Line_Position;
                           Col : in Curses.Column_Position)
   is
      package Entities renames Crawler.Entities;
      use type Curses.Line_Position,
               Curses.Column_Position;
   begin
      -- tbd: Fix below to only ignore exception in bottom corner case.
      --      Alternately, use 'insert' rather than 'add' for corner case.

--        if         Row = This.Height - 1
--          and then Col = This.Width  - 1
--        then
--           Curses.Add (Win     => This.Window,
--                       Line    => Row,
--                       Column => Col,
--                       Ch => Char);
--        else
         begin
            Curses.Add (Win     => This.Window,
                        Line    => Row
                        ,Column => Col
                        ,Ch => Char);
         exception
            when Curses.Curses_Exception =>
               null;
         end;
--        end if;
   end;





   procedure Add (This : in Frame;
                  Character : in Crawler.Entities.Character)
   is
      package Entities renames Crawler.Entities;
   begin
      This.internal_Add (Char => Entities.Get_Symbol (Character),
                         Row  => Entities.Get_Row (Character),
                         Col  => Entities.Get_Col (Character));
   end Add;




   procedure Add (This : in Frame;
                  Character : in out Crawler.Entities.Character;
                  Row : in Curses.Line_Position;
                  Col : in Curses.Column_Position)
   is
      use type Curses.Line_Position;
      use type Curses.Column_Position;
      package Entities renames Crawler.Entities;
   begin
      if         ((Row >= 0 and then Row < This.Height)
         and then (Col >= 0 and then Col < This.Width))
      then
         This.Erase (Character);
         This.internal_Add (Char => Entities.Get_Symbol (Character),
                            Row  => Row,
                            Col  => Col);
         Crawler.Entities.Set_Position (Character, Row => Row, Col => Col);
      end if;
   end Add;



   procedure Center(This : in out Frame;
                    Character : in Crawler.Entities.Character)
   is
   begin
      if This.Has_Parent_Window
      then
         declare
            package Curses renames Terminal_Interface.Curses;
            use type Curses.Line_Position;
            use type Curses.Column_Position;

            Parent_Lines   : Curses.Line_Count;
            Parent_Columns : Curses.Column_Count;

            Row : Curses.Line_Position   := This.Row;
            R   : Integer                := Integer (Crawler.Entities.Get_Row (Character) - (This.Height/2));
            Col : Curses.Column_Position := This.Col;
            C   : Integer                := Integer (Crawler.Entities.Get_Col (Character) - (This.Width/2));

         begin
            Curses.Get_Size(Win => This.Parent
                            ,Number_Of_Lines   => Parent_Lines
                            ,Number_Of_Columns => Parent_Columns);

            if C + Integer (This.Width) >= Integer (Parent_Columns)
            then
               declare
                  Col_Delta : Integer := Integer (Parent_Columns - (Curses.Column_Position (C) + This.Width));
               begin
                  C := C + Col_Delta;
               end;
            end if;

            if R + Integer (This.Height)  >=  Integer (Parent_Lines)
            then
               declare
                  Row_Delta : Integer := Integer (Parent_Lines - (Curses.Line_Position (R) + This.Height));
               begin
                  R := R + Row_Delta;
               end;
            end if;

            if R < 0 then
               Row := 0;
            else
               Row := Curses.line_Position (R);
            end if;

            if C < 0 then
               Col := 0;
            else
               Col := Curses.Column_Position (C);
            end if;

            This.Move (Row => Row, Col => Col);
         end;
      end if;
   end Center;





   procedure Fill_Window (This : in out Frame)
   is
      package Curses renames Terminal_Interface.Curses;
      use type Curses.Line_Position;
      use type Curses.Column_Position;

      Max_Height : Curses.Line_Position   := This.Height / 2;
      Max_Width  : Curses.Column_Position := This.Width  / 2;

      test : exception;

   begin
      Terminal_Interface.Curses.Leave_Cursor_After_Update (This.Window);

      -- Fill the first region with 0's
      for y in 0 .. Max_Height-1
      loop
         for x in 0 .. Max_Width-1
         loop
            This.internal_Add (Char => '0',
                               Row  => y,
                               Col  => x);
         end loop;
      end loop;


      -- Fill the second region with 1's
      for y in 0 .. Max_Height-1
      loop
         for x in Max_Width .. This.Width-1
         loop
            This.internal_Add (Char => '1',
                               Row  => y,
                               Col  => x);
         end loop;
      end loop;


      -- Fill the third region with 2's
      for y in Max_Height .. This.Height-1
      loop
         for x in 0 .. This.Width-1
         loop
            This.internal_Add (Char => '2',
                               Row  => y,
                               Col  => x);
         end loop;
      end loop;



      -- Fill the fourth region with 3's
      for y in Max_Height .. This.Height-1
      loop
         for x in Max_Width .. This.Width-1
         loop
            This.internal_Add (Char => '3',
                               Row  => y,
                               Col  => x);
         end loop;
      end loop;



      for y in 0 .. This.Height-1
      loop
         This.internal_Add (Char => '-',
                            Row  => y,
                            Col  => 0);

         This.internal_Add (Char => '-',
                            Row  => y,
                            Col  => This.Width - 1);
      end loop;



      for x in 0 .. This.Width-1
      loop
         This.internal_Add (Char => '|',
                            Row  => 0,
                            Col  => x);

         This.internal_Add (Char => '|',
                            Row  => This.Height - 1,
                            Col  => x);
      end loop;

   end Fill_Window;





   procedure Move (This : in out Frame;
                   Row  : Curses.Line_Position;
                   Col  : Curses.Column_Position)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      if This.Has_Parent_Window
      then
         Curses.Move_Derived_Window (This.Window, Line => Row, Column => Col);
         This.Row := Row;
         This.Col := Col;
         This.Refresh;
      end if;
   end Move;





   procedure Refresh (This : in out Frame)
   is
   begin
      if This.Has_Parent_Window
      then
         Curses.Touch (Win => This.Parent);
      end if;
      Curses.Refresh (Win => This.Window);
   end Refresh;





   procedure Erase (This : in Frame;
                    Character : in Crawler.Entities.Character)
   is
      package Entities renames Crawler.Entities;
   begin
      This.internal_Add (Char => ' ',
                         Row  => Entities.Get_Row (Character),
                         Col  => Entities.Get_Col (Character));
   end Erase;




   overriding
   procedure Finalize (This : in out Frame)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      -- Clear ncurses data structures
      Curses.Delete(This.Window);
   end Finalize;

end Crawler_Interface;

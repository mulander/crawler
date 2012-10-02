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
      Curses.Clear; --clear;
      Curses.Set_Echo_Mode (False);
      Curses.Set_Cbreak_Mode (True);
      Curses.Set_Keypad_Mode;
      Curses.Set_Cursor_Visibility (Cursor_Visibility);

      Curses.Get_Size(Number_Of_Lines => This.Height
                      ,Number_Of_Columns => This.Width);
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
      This.Window := Curses.Derived_Window(Number_Of_Lines => Height
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

   procedure Add (This : in Frame;
                  Character : in Crawler.Entities.Character)
   is
      package Entities renames Crawler.Entities;
   begin
      Curses.Add (Line => Entities.Get_Row (Character)
                  ,Column => Entities.Get_Col (Character)
                  ,Ch => Entities.Get_Symbol (Character));
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
      if ((Row >= 0 and then Row < This.Height)
         and then (Col >= 0 and then Col < This.Width))
      then
         This.Erase (Character);
         Curses.Add (Line => Row
                     ,Column => Col
                     ,Ch => Entities.Get_Symbol (Character));
         Crawler.Entities.Set_Position (Character, Row => Row, Col => Col);
      end if;
   end Add;

   procedure Center(This : in out Frame;
                    Character : in Crawler.Entities.Character)
   is
      package Curses renames Terminal_Interface.Curses;
      use type Curses.Line_Position;
      use type Curses.Column_Position;
      Parent_Lines : Curses.Line_Count;
      Parent_Columns : Curses.Column_Count;
      Row : Curses.Line_Position := This.Row;
      R : Curses.Line_Position := Crawler.Entities.Get_Row (Character) - (This.Height/2);
      Col : Curses.Column_Position := This.Col;
      C : Curses.Column_Position := Crawler.Entities.Get_Col (Character) - (This.Width/2);
   begin
      if This.Has_Parent_Window
      then
         Curses.Get_Size(Win => This.Parent
                         ,Number_Of_Lines => Parent_Lines
                         ,Number_Of_Columns => Parent_Columns);

         if (C + This.Width >= Parent_Columns)
         then
            declare
               Col_Delta : Curses.Column_Position := Parent_Columns - (C + This.Width);
            begin
               Col := C + Col_Delta;
            end;
         else
            Col := C;
         end if;

         if (R + This.Height >= Parent_Lines)
         then
            declare
               Row_Delta : Curses.Line_Position := Parent_Lines - (R + This.Height);
            begin
               Row := R + Row_Delta;
            end;
         else
            Row := R;
         end if;

         if (R < 0)
         then
            Row := 0;
         end if;

         if (C < 0)
         then
            Col := 0;
         end if;

         This.Move (Row => Row, Col => Col);
      end if;
   end Center;

   procedure Fill_Window (This : in out Frame)
   is
      package Curses renames Terminal_Interface.Curses;
      use type Curses.Line_Position;
      use type Curses.Column_Position;
      Max_Height : Curses.Line_Position := This.Height - 10/2;
      Max_Width  : Curses.Column_Position := This.Width - 10/2;
      test : exception;
   begin
      -- Fill the first region with 0's
      for y in 0 .. Max_Height
      loop
         for x in 0 .. Max_Width
         loop
            Curses.Add (Win => This.Window
                        ,Line => y
                        ,Column => x
                        ,Ch => '0');
         end loop;
      end loop;
      -- Exception here -- FIXME
      -- Fill the second region with 1's
--      for y in 0 .. Max_Height
--      loop
--         for x in Max_Width .. This.Width
 --        loop
 --          Curses.Add (Win => This.Window
 --                       ,Line => y
 --                       ,Column => x
 --                       ,Ch => '1');
 --        end loop;
 --     end loop;

      -- Fill the third region with 2's
--      for y in Max_Height .. This.Height
--      loop
--         for x in 0 .. This.Width
 --        loop
 --           Curses.Add (Win => This.Window
 --                       ,Line => y
 --                       ,Column => x
 --                       ,Ch => '2');
 --        end loop;
 --     end loop;

      -- Fill the fourth region with 3's
--      for y in Max_Height .. This.Height
--      loop
--         for x in Max_Width .. This.Width
--         loop
--            Curses.Add (Win => This.Window
--                        ,Line => y
--                        ,Column => x
--                        ,Ch => '3');
--         end loop;
--      end loop;

      for y in 0 .. Max_Height
      loop
         Curses.Add (Win => This.Window
                     ,Line => y
                     ,Column => 0
                     ,Ch => '-');
         Curses.Add (Win => This.Window
                     ,Line => y
                     ,Column => This.Width - 1
                     ,Ch => '-');
      end loop;

      for x in 0 .. Max_Width
      loop
         Curses.Add (Win => This.Window
                     ,Line => 0
                     ,Column => x
                     ,Ch => '|');
         Curses.Add (Win => This.Window
                     ,Line => This.Height - 1
                     ,Column => x
                     ,Ch => '|');
      end loop;
      Curses.Add (Win => This.Window
                  ,Line => 0
                  ,Column => 0
                  ,Ch => 'X');
      Curses.Refresh(This.Window);

   end Fill_Window;

   procedure Move (This : in out Frame;
                   Row  : Curses.Line_Position;
                   Col  : Curses.Column_Position)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      if This.Has_Parent_Window
      then
         -- exception here -- FIXME
         --Curses.Move_Derived_Window (This.Window, Line => Row, Column => Col);
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
      Curses.Add (Line => Entities.Get_Row (Character)
                  ,Column => Entities.Get_Col (Character)
                  ,Ch => ' ');
   end Erase;

   overriding procedure Finalize (This : in out Frame)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      -- Clear ncurses data structures
      Curses.Delete(This.Window);
   end Finalize;

end Crawler_Interface;

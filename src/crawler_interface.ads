-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Ada.Finalization;
with Terminal_Interface.Curses;
with Crawler.Entities;

package Crawler_Interface is
   package Curses renames Terminal_Interface.Curses;

   type Screen is new Ada.Finalization.Limited_Controlled with private;

   -- Print a message on the screen
   procedure Add (This : in Screen;
                  Str  : in String);

   function Get_Height (This : in Screen) return Curses.Line_Count;
   function Get_Width (This : in Screen) return Curses.Column_Count;

   type Frame is new Ada.Finalization.Limited_Controlled with private;

   -- Initialize a main window (no parent)
   procedure Make (This   : in out Frame;
                  Height : Curses.Line_Count;
                  Width  : Curses.Column_Count;
                  Row    : Curses.Line_Position;
                   Col    : Curses.Column_Position);

   -- Initialize a subwindow (viewport) with a parent window
   procedure Make_Sub_Window (This   : in out Frame;
                              Parent : Frame;
                              Height : Curses.Line_Count;
                              Width  : Curses.Column_Count;
                              Row    : Curses.Line_Position;
                              Col    : Curses.Column_Position);

   -- Get the window
   function Get_Window (This : in Frame) return Curses.Window;

   -- Get the window
   function Get_Parent_Window (This : in Frame) return Curses.Window;

   -- Get window type, if TRUE we have a subwindow, if FALSE we have a main window
   function Has_Parent_Window (This : in Frame) return Boolean;

   -- Get height
   function Get_Height (This : in Frame) return Curses.Line_Count;

   -- Get Width
   function Get_Width (This : in Frame) return Curses.Column_Count;

   -- Get the row (y) position of the window
   function Get_Row (This : in Frame) return Curses.Line_Position;

   -- Get the col (x) position of the window
   function Get_Col (This : in Frame) return Curses.Column_Position;

   -- Add a character to the window
   procedure Add (This : in Frame;
                  Character : in Crawler.Entities.Character);

   -- Add a character at a specific position to the window
   procedure Add (This : in Frame;
                  Character : in out Crawler.Entities.Character;
                  Row : in Curses.Line_Position;
                  Col : in Curses.Column_Position);

   -- Center the viewport around a character
   procedure Center (This : in out Frame;
                     Character : in Crawler.Entities.Character);

   -- Fill a window with numbers - the window is split in four equal regions,
   -- each region is filled with a single number, so 4 regions and 4 numbers.
   -- This is a suggestion of how this will look:
   -- 0 | 1
   -- -----
   -- 2 | 3
   -- This function is used only for debugging purposes.
   procedure Fill_Window (This : in out Frame);

   -- Move a window in a new position (r, c)
   procedure Move (This : in out Frame;
                   Row  : Curses.Line_Position;
                   Col  : Curses.Column_Position);

   -- Refresh the window
   procedure Refresh (This : in out Frame);

   -- Define the "erase" character, use an empty character for cleaning a cell or a
   -- visible character for showing the trace of a game character
   procedure Erase (This : in Frame;
                    Character : in Crawler.Entities.Character);


private

   type Screen is new Ada.Finalization.Limited_Controlled with record
      Height    : Curses.Line_Position;
      Width     : Curses.Column_Position;
   end record;

   overriding procedure Initialize (This: in out Screen);
   overriding procedure Finalize (This: in out Screen);

   type Frame is new Ada.Finalization.Limited_Controlled with record
      Height            : Curses.Line_Count;
      Width             : Curses.Column_Count;
      Row               : Curses.Line_Position;
      Col               : Curses.Column_Position;
      Has_Parent_Window : Boolean;
      Window            : Curses.Window;
      Parent            : Curses.Window;
   end record;

   overriding procedure Finalize (This: in out Frame);


   procedure Internal_Add (This : in Frame;
                           Char : in Character;
                           Row : in Curses.Line_Position;
                           Col : in Curses.Column_Position);

end Crawler_Interface;

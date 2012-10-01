-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Terminal_Interface.Curses;

package body Crawler_Interface is
   overriding procedure Initialize (This: in out Screen)
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
   end Initialize;

   overriding procedure Finalize (This: in out Screen)
   is
      package Curses renames Terminal_Interface.Curses;
   begin
      -- Clear ncurses data structures
      Curses.End_Windows;
   end Finalize;
end Crawler_Interface;

-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Ada.Finalization;
with Terminal_Interface.Curses;

package Crawler_Interface is
   package Curses renames Terminal_Interface.Curses;

   type Screen is new Ada.Finalization.Limited_Controlled with private;

   function Get_Height (This : in Screen) return Curses.Line_Count;
   function Get_Width (This : in Screen) return Curses.Column_Count;
private

   type Screen is new Ada.Finalization.Limited_Controlled with record
      Height    : Curses.Line_Position;
      Width     : Curses.Column_Position;
   end record;

   overriding procedure Initialize (This: in out Screen);
   overriding procedure Finalize (This: in out Screen);
end Crawler_Interface;

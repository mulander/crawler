-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Terminal_Interface.Curses;

procedure Crawler
is
   package Curses renames Terminal_Interface.Curses;

   Key : Curses.Key_Code;
   Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   -- Define the main character initial position and symbol
   Row : Curses.Line_Position := 10;
   Col : Curses.Column_Position := 10;
   Main_Character : Character:= '@';

   procedure Initialize_NCurses
   is
   begin
      -- Initialize ncurses
      Curses.Init_Screen; --initscr;
      Curses.Clear; --clear;
      Curses.Set_Echo_Mode (False);
      Curses.Set_Cbreak_Mode (True);
      Curses.Set_Keypad_Mode;
      Curses.Set_Cursor_Visibility (Cursor_Visibility);
   end Initialize_NCurses;

   procedure Game_Loop
   is
   begin
      loop
         -- Wait until the user presses a key
         Key := Curses.Get_Keystroke; --getch();
         -- Clear the screen
         Curses.Clear;

         case Key is
         when  Curses.Real_Key_Code(Character'Pos('q')) | Curses.Real_Key_Code(Character'Pos('Q')) =>
            exit;
         when others => -- If the user choses to stay, show the main character at position (Row,Col)
            Curses.Add (Line => Row, Column => Col, Ch => Main_Character);
         end case;
      end loop;
   end Game_Loop;
begin
   -- Start ncurses
   Initialize_NCurses;
   -- Printw is not ported binded by design
   -- Print a welcome message on the screen
   Curses.Add (Str => "Welcome to RR game." & Standard.ASCII.LF);
   Curses.Add (Str => "Press any key to start." & Standard.ASCII.LF);
   Curses.Add (Str => "If you want to quit press ""q"" or ""Q""");

   -- Start the game loop
   Game_Loop;
   -- Clear ncurses data structures
   Curses.End_Windows; --endwin();
end Crawler;

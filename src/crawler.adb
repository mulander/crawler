-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Terminal_Interface.Curses;
with Crawler_Interface;

procedure Crawler
is
   package Curses renames Terminal_Interface.Curses;

   Key : Curses.Key_Code;
   Cursor_Visibility : Curses.Cursor_Visibility := Curses.Invisible;
   -- Define the main character initial position and symbol
   Row : Curses.Line_Position := 10;
   Col : Curses.Column_Position := 10;
   Main_Character : Character:= '@';

   -- Start ncurses
   Screen : Crawler_Interface.Screen;

   procedure Erase(Row : in Curses.Line_Position;
                   Col : in Curses.Column_Position)
   is
   begin
      Curses.Add (Line => Row, Column => Col, Ch => '#');
   end Erase;

   procedure Game_Loop(Main_Character : in Character;
                       Row : in out Curses.Line_Position;
                       Col : in out Curses.Column_Position)
   is
      use type Curses.Line_Position;
      use type Curses.Column_Position;
      Key : Curses.Key_Code := Curses.Key_Home;
      Lines : Curses.Line_Count;
      Columns : Curses.Column_Count;
   begin
      loop
	 Curses.Get_Size(Number_Of_Lines => Lines, Number_Of_Columns => Columns);
         -- Wait until the user presses a key
         -- Clear the screen
         -- Curses.Clear;

         -- We have one Erase call as we need to perform it before each move command
         -- no need to repeat if four times.
         Erase(Row,Col);
         -- Compared to the original snippet, we drop refresh()
         -- as it seems to be not needed if we don't use the printw family
         -- of functions. Refresh draws the 'virtual' screen to the display
         -- and it seems to be also done by Curses.Add in our example.
         case Key is
            when Curses.Real_Key_Code(Character'Pos('q')) | Curses.Real_Key_Code(Character'Pos('Q')) =>
               exit;
            when Curses.KEY_LEFT =>
               if not (Col - 1 < 0)
               then
                  Col := Col - 1;
               end if;
            when Curses.KEY_RIGHT =>
               if not (Col >= Columns -2)
               then
                  Col := Col + 1;
               end if;
            when Curses.KEY_UP =>
               if not (Row - 1 < 0)
               then
                  Row := Row - 1;
               end if;
            when Curses.KEY_DOWN =>
               if not (Row >= Lines -2)
               then
                  Row := Row + 1;
               end if;
            when others => -- If the user choses to stay, show the main character at position (Row,Col)
               null;
         end case;
         -- Compared to the original, just one print of the main characer is
         -- all we need to update our current position as all of our options
         -- are related to the player updating his position.
         Curses.Add (Line => Row, Column => Col, Ch => Main_Character);
         Key := Curses.Get_Keystroke; --getch();
      end loop;
   end Game_Loop;
begin
   -- Printw is not ported binded by design
   -- Print a welcome message on the screen
   Curses.Add (Str => "Welcome to RR game." & Standard.ASCII.LF);
   Curses.Add (Str => "Press any key to start." & Standard.ASCII.LF);
   Curses.Add (Str => "If you want to quit press ""q"" or ""Q""");
   Key := Curses.Get_Keystroke;
   if Integer(Key) not in Character'Pos('Q')|Character'Pos('q')
   then
      Curses.Clear;
      -- Start the game loop
      Game_Loop(Main_Character => Main_Character,
                Row => Row,
                Col => Col);
   end if;
end Crawler;

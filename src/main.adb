-- Copyright (c) 2012, mulander <netprobe@gmail.com>
-- All rights reserved.
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.
with Terminal_Interface.Curses;
with Crawler_Interface;
with Crawler.Entities;

procedure Main
is
   package Curses renames Terminal_Interface.Curses;
   package Entities renames Crawler.Entities;

   Key : Curses.Key_Code;

   -- Start ncurses
   Screen : Crawler_Interface.Screen;


   procedure Game_Loop
   is
      use type Curses.Line_Position;
      use type Curses.Column_Position;

      Key : Curses.Key_Code := Curses.Key_Home;

      -- The C++ implementation doesn't refresh on each
      -- tick so we also retrieve the dimensions on start.
--        Lines : Curses.Line_Count := Screen.Get_Height;
--        Columns : Curses.Column_Count := Screen.Get_Width;

      Game_Map : Crawler_Interface.Frame;
      Viewport : Crawler_Interface.Frame;

   begin
      -- Create an ncurses window to store the game map. This will be twice the size
      -- of the screen and it will be positioned at (0,0) in screen coordinates
      Game_Map.Make (Height => 2 * Screen.Get_Height + 1
                     ,Width => 2 * Screen.Get_Width
                     ,Row => 0
                     ,Col => 0);

      -- Create an ncurses subwindow of the game map. This will have the size
      -- of the user screen and it will be initially postioned at (0, 0)
      Viewport.Make_Sub_Window (Parent  => Game_Map
                                ,Height => Screen.Get_Height
                                ,Width  => Screen.Get_Width
                                ,Row => 0
                                ,Col => 0);

      -- Initialize the main character. We are going to put this in the middle of
      -- the game map (for now)
      declare
         Main_Character : Entities.Character := Entities.Make (Symbol => '@',
                                                               Row    => Game_Map.Get_Height / 2,
                                                               Col    => Game_Map.Get_Width  / 2);
         Row : Curses.Line_Position;
         Col : Curses.Column_Position;

      begin
         -- Fill the game map with numbers
         Game_Map.Fill_Window;



         -- Compared to the original, just one print of the main characer is
         -- all we need to update our current position as all of our options
         -- are related to the player updating his position.
         Game_Map.Add (Character => Main_Character);
--                         ,Row => Row
--                         ,Col => Col);

         Viewport.Center (Character => Main_Character);
         Viewport.Refresh;

         -- Start the game loop
         loop
            -- Wait until the user presses a key
            Key := Curses.Get_Keystroke; --getch();

            Row := Entities.Get_Row (Main_Character);
            Col := Entities.Get_Col (Main_Character);

            -- Clear the screen
            -- Curses.Clear;

            -- We have one Erase call as we need to perform it before each move command
            -- no need to repeat if four times.
            ---Erase(Entities.Get_Row(Main_Character),Entities.Get_Col(Main_Character));
            -- Compared to the original snippet, we drop refresh()
            -- as it seems to be not needed if we don't use the printw family
            -- of functions. Refresh draws the 'virtual' screen to the display
            -- and it seems to be also done by Curses.Add in our example.


            case Key is
            when Curses.Real_Key_Code(Character'Pos('q')) | Curses.Real_Key_Code(Character'Pos('Q')) =>
               exit;

            when Curses.KEY_LEFT =>
               Game_Map.add (Main_Character,  Row, Col-1);

            when Curses.KEY_RIGHT =>
               Game_Map.add (Main_Character,  Row, Col+1);

            when Curses.KEY_UP =>
               Game_Map.add (Main_Character,  Row-1, Col);

            when Curses.KEY_DOWN =>
               Game_Map.add (Main_Character,  Row+1, Col);

            when others => -- If the user choses to stay, show the main character at position (Row,Col)
               null;

            end case;


            Viewport.Center (Character => Main_Character);
            Viewport.Refresh;

         end loop;
      end;
   end Game_Loop;

begin

   -- Printw is not ported binded by design
   -- Print a welcome message on the screen
   Screen.Add (Str => "Welcome to RR game." & Standard.ASCII.LF);
   Screen.Add (Str => "Press any key to start." & Standard.ASCII.LF);
   Screen.Add (Str => "If you want to quit press ""q"" or ""Q""");

   Key := Curses.Get_Keystroke;

   if Integer(Key) not in Character'Pos('Q')|Character'Pos('q')
   then
      Curses.Clear;
      -- Start the game loop
      Game_Loop;
   end if;
end Main;

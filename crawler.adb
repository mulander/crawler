with Terminal_Interface.Curses;

procedure Crawler
is
	package Curses renames Terminal_Interface.Curses;
	Key : Curses.Real_Key_Code;
begin
	Curses.Init_Screen; --initscr;
	Curses.Clear; --clear;
	--printw("Seems that you can use ncurses...\nPress any key to exit!");
	Key := Curses.Get_Keystroke; --getch();
	Curses.End_Windows; --endwin();
end Crawler;
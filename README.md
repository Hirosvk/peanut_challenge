# Coding Challenge: Computer Terminal
Hello! I completed [this challenge][link] for my application to Peanut Labs. I used Ruby, and it runs on a terminal. Since the program uses 'colorize' gem, please run the command ```bundle install``` or install it manually with ```gem install colorize``` before running the program.

To run the code, clone the repo, move the the directroy, and type in terminal ```ruby main.rb```. You can also load any text file by adding the path ```ruby main.rb test.txt```, for example. It will preload the content of the text file.

[link]:https://www.codeeval.com/public_sc/108/

# Instructions
* ^c - clear the entire screen; the cursor row and column do not change
* ^h - move the cursor to row 0, column 0; the image on the screen is not changed
* ^b - move the cursor to the beginning of the current line; the cursor row does not change
* ^d - move the cursor down one row if possible; the cursor column does not change
* ^u - move the cursor up one row, if possible; the cursor column does not change
* ^l - move the cursor left one column, if possible; the cursor row does not change
* ^r - move the cursor right one column, if possible; the cursor row does not change
* ^e - ~~erase characters to the right of, and including, the cursor column on the cursor's row; the cursor row and column do not change~~ **On my implementation, it erases the character on the cursor position. If it's in insert mode, it will shift the proceeding characters up**
* ^i - enter insert mode
* ^o - enter overwrite mode
* ^^ - write a circumflex (^) at the current cursor location, exactly as if it was not a special character; this is subject to the actions of the current mode (insert or overwrite)
* ^DD - move the cursor to the row and column specified; each D represents a decimal digit; the first D represents the new row number, and the second D represents the new column number

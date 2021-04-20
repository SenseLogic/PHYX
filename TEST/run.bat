copy ORIGINAL\CODE\STYLE\* FIXED\CODE\STYLE\
copy ORIGINAL\CODE\VIEW\* FIXED\CODE\VIEW\
..\phyx --newline --include "FIXED//*.phx"
..\phyx --newline --media --style --unit 16 --include "FIXED//*.pht" --include "FIXED//*.styl"
pause

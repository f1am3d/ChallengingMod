if exist "csprogs.dat" del "csprogs.dat"

fteqcc64 -src ./src/csqc -srcfile csprogs.src -std=fteqcc

if not exist "../build/mod" md "../build/mod"
copy "csprogs.dat" "../build/mod"

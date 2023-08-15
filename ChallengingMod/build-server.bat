if exist "progs.dat" del "progs.dat"

fteqcc64 -src ./src/ssqc -srcfile progs.src -std=fteqcc

if not exist "../build/mod" md "../build/mod"
copy "progs.dat" "../build/mod"
if exist "progs.dat" del "progs.dat"

fteqcc64 -src ./src -srcfile progs.src

copy "progs.dat" "./../cmake-build-debug/mod"
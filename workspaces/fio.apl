⍝!/usr/local/bin/apl --script

⍝ zlib license
⍝
⍝ Copyright (c) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi
⍝
⍝ This software is provided ‘as-is’, without any express or implied
⍝ warranty. In no event will the authors be held liable for any damages
⍝ arising from the use of this software.
⍝
⍝ Permission is granted to anyone to use this software for any purpose,
⍝ including commercial applications, and to alter it and redistribute it
⍝ freely, subject to the following restrictions:
⍝
⍝ 1. The origin of this software must not be misrepresented; you must not
⍝ claim that you wrote the original software. If you use this software
⍝ in a product, an acknowledgment in the product documentation would be
⍝ appreciated but is not required.
⍝
⍝ 2. Altered source versions must be plainly marked as such, and must not be
⍝ misrepresented as being the original software.
⍝
⍝ 3. This notice may not be removed or altered from any source
⍝ distribution.

⍝ In GnuAPL, interations with the operating system (file handling, spawning
⍝ processes, opening ports, etc.) are done with ⎕FIO.
⍝ The problem is that the specific command in ⎕FIO is specified with an axis
⍝ argument (i.e. ⎕FIO[3],) which results in hard-to-read code. Additionally,
⍝ some of the functions are also annoying to use (i.e. ⎕FIO[20], mkdir, requires
⍝ the file permissions to be converted from octal to decimal numbers before
⍝ calling.)
⍝
⍝ This file provides a small layer of abstraction to give proper names to the
⍝ functions provided by ⎕FIO, and some extra utlities that go along with it.
⍝
⍝ Note: functions have been added as-needed, so it will not cover everything in
⍝ ⎕FIO.



⍝ See <https://www.gnu.org/software/apl/Library-Guidelines-GNU-APL.html> for
⍝ details.
FIO⍙metadata←"Author" "BugEmail" "Documentation" "Download" "LICENSE" "Portability" "Provides" "Requires" "Version",⍪"ona li toki e jan Epiphany tawa mi" "" "" "" "ZLIB" "L3" "FIO" "" "0.1.0"



⍝ Zh ← As ⎕FIO[ 3] Bs    fopen(Bs, As) filename Bs mode As
⍝ Opens a file with fopen.
⍝ →⍺ - mode (i.e. "w", "r+", etc..)
⍝ →⍵ - file path.
⍝ ←The file descriptor, or a scalar number less than 1 on failure.
FIO∆FOPEN←{⍺ ⎕FIO[3] ⍵}

⍝ Ze ←    ⎕FIO[ 4] Bh    fclose(Bh)
⍝ Closes a file descriptor.
⍝ →⍵ - file descriptor.
⍝ ←Error code.
FIO∆FCLOSE←{⎕FIO[4] ⍵}

⍝ Zb ←    ⎕FIO[ 6] Bh    fread(Zi, 1, 5000, Bh) 1 byte per Zb
⍝ Reads up to 5,000 bytes in from the file descriptor as a byte vector.
FIO∆FREAD←{⎕FIO[6] ⍵}
⍝ Zb ← Ai ⎕FIO[ 6] Bh    fread(Zi, 1, Ai, Bh) 1 byte per Zb
⍝ Reads bytes up to specified number of bytes from the file descriptor as a byte
⍝ vector.
⍝ →⍵ - file descriptor.
⍝ →⍺ - maximum number of bytes to read in.
FIO∆FREAD_SIZED←{⍺ ⎕FIO[6] ⍵}

⍝ Zi ← Ab ⎕FIO[ 7] Bh    fwrite(Ab, 1, ⍴Ai, Bh) 1 byte per Ai
⍝ Writes to a file descriptor.
⍝ →⍵ - file descriptor.
⍝ →⍺ - data as byte vector.
FIO∆FWRITE←{⍺ ⎕FIO[7] ⍵}

⍝ Zi ←    ⎕FIO[10] Bh    feof(Bh)
⍝ →⍵ - file descriptor.
⍝ ←Non-zero if EOF was reached for the file descriptor.
FIO∆FEOF←{⎕FIO[10] ⍵}

⍝ Ze ←    ⎕FIO[11] Bh    ferror(Bh)
⍝ →⍵ - file descriptor.
⍝ ←Non-zero if an error ocurred reading file descriptor.
FIO∆FERROR←{⎕FIO[11] ⍵}

⍝ Zi ← Ai ⎕FIO[20] Bh    mkdir(Bc, Ai)
⍝ Creates the given directory if it doesn't exist with file mode 0755. Does not
⍝ recurse.
⍝ →⍵ - file path.
⍝ ←Non zero if an error occured.
FIO∆MKDIR←{(8⊥0 7 5 5) ⎕FIO[20] ⍵}
⍝ Creates the given directory if it doesn't exist. Does not recurse.
⍝ →⍵ - file path.
⍝ →⍺ - octal mode for the directory as an integer vector (i.e. 0 7 5 5.)
⍝ ←Non zero if an error occured.
FIO∆MKDIR_MODE←{(8⊥⍺) ⎕FIO[20] ⍵}

⍝ Zi ← Ac ⎕FIO[23] Bh    fwrite(Ac, 1, ⍴Ac, Bh) 1 Unicode per Ac, Output UTF8
⍝ Writes a character vector to a file descriptor.
⍝ →⍵ - file descriptor.
⍝ →⍺ - characte vector.
⍝ ←Error code.
FIO∆FWRITE_CVECTOR←{⍺ ⎕FIO[23] ⍵}

⍝ Zh ← As ⎕FIO[24] Bs    popen(Bs, As) command Bs mode As
⍝ Stars the given command in a subprocess.
⍝ →⍵ - command.
⍝ ←The process' read-only file descriptor, or a scalar 0 on failure.
FIO∆POPEN_READ←{⎕FIO[24] ⍵}
⍝ Stars the given command in a subprocess.
⍝ →⍵ - command.
⍝ ←The process' write-only file descriptor, or a scalar 0 on failure.
FIO∆POPEN_WRITE←{"w" ⎕FIO[24] ⍵}

⍝ Ze ←    ⎕FIO[25] Bh    pclose(Bh)
⍝ Closes a file descripter opened with FIO∆POPEN_READ.
⍝ →⍵ - process file descriptor.
⍝ ←Process exit code, or a scalar ¯1 on failure.
FIO∆PCLOSE←{⎕FIO[25] ⍵}

⍝ Zb ←    ⎕FIO[26] Bs    return entire file Bs as byte vector
⍝ Reads in the enitrety of the file a byte vector.
⍝ →FILE_PATH - file path to read from.
⍝ BYTE_VECTOR← - The byte vector, or a scalar ¯2 on failure.
∇BYTE_VECTOR←FIO∆READ_ENTIRE_FILE PATH
  BYTE_VECTOR←⎕FIO[26] PATH

  →(¯2≡BYTE_VECTOR) ⍴ LERROR
    ⍝ ⎕FIO[26] actually returns a character vector of the bytes, so ⎕UCS is used
    ⍝ to convert them to actual numbers like whats returned from ⎕FIO[6].
    BYTE_VECTOR←⎕UCS BYTE_VECTOR
  LERROR:
∇

⍝ Zn ←    ⎕FIO[29] Bs    return file names in directory Bs
⍝ →⍵ - directory file path.
⍝ ←The filenames in the directory, or a scalar ¯2 on failure.
FIO∆LIST_DIRECTORY←{⎕FIO[29] ⍵}

⍝ Zi ←    ⎕FIO[50] Bu    gettimeofday()
⍝ Returns the current time since the Epoch in either seconds, milliseconds, or
⍝ microseconds.
⍝ →⍵ - the time divisor. 1 - seconds, 1000 - milliseconds, 1000000 -
⍝ microseconds.
FIO∆GET_TIME_OF_DAY←{⎕FIO[50] ⍵}



⍝ Converts a byte vector to a UTF-8 encoded character vector.
FIO∆BYTES_TO_UTF8←{19 ⎕CR ⎕UCS ⍵}
⍝ Converts a UTF-8 encoded character vector to a byte vector.
FIO∆UTF8_TO_BYTES←{⎕UCS 18 ⎕CR ⍵}

⍝ Reads input from the file descriptor until EOF is reached and outputs the
⍝ contents as a byte vector.
∇BYTE_VECTOR←FIO∆READ_ENTIRE_FD FILE_DESCRIPTOR
  BYTE_VECTOR←⍬

  LREAD_LOOP:
    BYTE_VECTOR←BYTE_VECTOR,FIO∆FREAD FILE_DESCRIPTOR
    →(0≢FIO∆FEOF   FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →(0≢FIO∆FERROR FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →LREAD_LOOP
  LEND_READ_LOOP:
∇

⍝ Checks is the file path exists and is a directory.
⍝ →⍵ - directory file path.
⍝ ←1 if the file path represents a directory, else 0.
FIO∆IS_DIRECTORY←{¯2≢FIO∆LIST_DIRECTORY ⍵}

⍝ Splits a vector by a delimiter value into a nested vector of vectors. If a
⍝ vector ends up being empty, it will still be included in the result (i.e.
⍝ VALUE VALUE DELIMETER DELIMETER VALUE -> (VALUE VALUE) () (VALUE).) The
⍝ delimiter value will not appear in the resulting vectors.
∇RESULT←DELIMETER FIO∆SPLIT VECTOR
  RESULT←{⍵~DELIMETER}¨ VECTOR ⊂⍨1++\ DELIMETER ⍷ VECTOR
∇
⍝ Splits a vector by a delimiter value into a nested vector of vectors. If a
⍝ vector ends up being empty, it will not be included in the result (i.e. VALUE
⍝ VALUE DELIMETER DELIMETER VALUE -> (VALUE VALUE) (VALUE).) The delimiter value
⍝ will not appear in the resulting vectors.
∇RESULT←DELIMETER FIO∆SPLIT_CLEAN VECTOR
  RESULT←{⍵~DELIMETER}¨ VECTOR ⊂⍨1++ DELIMETER ⍷ VECTOR
∇

⍝ Splits a file path into it's seperate parts and removes the seperators (i.e.
⍝ FIO∆SPLIT_PATH "../a/p///apples" → ".." "a" "p" "apples"
FIO∆SPLIT_PATH←{'/' FIO∆SPLIT_CLEAN ⍵}
⍝ Joins two file paths together with a seperator.
FIO∆JOIN_PATHS←{⍺,'/',⍵}

⍝ Creates the given directory and it's parent directories if they don't exist.
⍝ →PATH - file path.
⍝ →MODE - octal mode for the directory as an integer vector (i.e. 0 7 5 5.)
⍝ ←ERROR_CODES - The list of error codes from FIO∆MKDIR_MODE for each directory
⍝ level, non-zero if an error occured.
∇ERROR_CODES←MODE FIO∆MKDIRS_MODE PATH; DIRECTORIES
  DIRECTORIES←FIO∆JOIN_PATHS\ FIO∆SPLIT_PATH PATH
  ERROR_CODES←{MODE FIO∆MKDIR_MODE ⍵}¨ DIRECTORIES
∇
⍝ Creates the given directory and it's parent directories if they don't exist
⍝ with file mode 0755.
⍝ →⍵ - file path.
⍝ ←Non zero if an error occured.
⍝ ←The list of error codes from FIO∆MKDIRS_MODE for each directory level,
⍝ non-zero if an error occured.
FIO∆MKDIRS←{(0 7 5 5) FIO∆MKDIRS_MODE ⍵}



⍝ Common file descriptors.
FIO∆STDIN←0
FIO∆STDOUT←1
FIO∆STDERR←2

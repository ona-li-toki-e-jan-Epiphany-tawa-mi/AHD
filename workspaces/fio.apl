⍝!/usr/local/bin/apl --script

⍝ This file is part of fio.apl.
⍝
⍝ Copyright (c) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi
⍝
⍝ fio.apl is free software: you can redistribute it and/or modify it under the
⍝ terms of the GNU General Public License as published by the Free Software
⍝ Foundation, either version 3 of the License, or (at your option) any later
⍝ version.
⍝
⍝ fio.apl is distributed in the hope that it will be useful, but WITHOUT ANY
⍝ WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
⍝ A PARTICULAR PURPOSE. See the GNU General Public License for more details.
⍝
⍝ You should have received a copy of the GNU General Public License along with
⍝ fio.apl. If not, see <https://www.gnu.org/licenses/>.

⍝ fio.apl GNU APL ⎕FIO abstraction library.
⍝
⍝ SYNOPSIS:
⍝   TL;DR - ⎕FIO is too low-level IMO for use in APL and this library is my
⍝   highly-biased reimagining of it.
⍝
⍝   In GNU APL, interations with the operating system (file handling, spawning
⍝   processes, opening ports, etc.) are done with ⎕FIO. However, I find that
⍝   there are several problems with it.
⍝
⍝   Prior to version GNU APL 1.9, ⎕FIO functions were specified with an axis
⍝   argument, i.e. ⎕FIO[3] (fopen,) which lead to code that was hard to read.
⍝   Now you can specify them by name, i.e. ⎕FIO['fopen'] or ⎕FIO.fopen. This is
⍝   the reason I orignally developed this library, but there are still other
⍝   things for which I think this library has value.
⍝
⍝   The ⎕FIO functions are replicas of C functions, whose error handling methods
⍝   vary considerably between functions. This is fine in C, but APL is far more
⍝   abstract than C with a completely different way to represent logic. This
⍝   library provides, what I consider, to be a more consistent and sensible
⍝   error handling scheme through the use of a vector that replicates the
⍝   optional data type from other languages, like ? in Zig or std::optional<T>
⍝   in C++.
⍝
⍝   Many of the functions that handle file descriptors throw an exception on an
⍝   unopened file descriptor, instead of returning some kind of error code. I
⍝   think that this is kind of weird, and I have replaced it with the
⍝   aforementioned optionals.
⍝
⍝   Some of the functions are also annoying to use. For example, ⎕FIO[20],
⍝   mkdir, requires the file permissions to be converted from octal to decimal
⍝   numbers before calling. Functions such as these are given a more
⍝   user-friendly interface.
⍝
⍝   Additionally, this library provides a number of extra functions you will
⍝   probably like, such as recursively creating and deleting directories, and a
⍝   defer system akin to what Zig has.
⍝
⍝   Note: functions have been added as-needed, so it will not cover everything
⍝   in ⎕FIO.
⍝
⍝ USAGE:
⍝   Either include it into your project on one of the library search paths (run
⍝   ')LIBS' to see them,) and use ')COPY_ONCE fio.apl' to load it, or include it
⍝   directly via path, i.e. ')COPY_ONCE ./path/to/fio.apl'.
⍝
⍝   If the inclusion of ')COPY_ONCE' in scripts results in text output that you
⍝   don't want replace the command with '⊣ ⍎")COPY_ONCE <name or path>"'.
⍝
⍝ DATA TYPES:
⍝  string - a character vector.
⍝  bytes - a number vector whose elements, N, are 0≤N≤255.
⍝  fd - a scalar number representing a file descriptor.
⍝  errno - a scalar number representing an error a la C's ERRNO.
⍝  boolean - a scalar 0, for false, or a 1, for true.
⍝  any - any value of any type.
⍝  void - used in optionals to indicate no value is returned.
⍝  uint - scalar whole number.
⍝  optional<TYPE>:
⍝    Error handling type. An optional is a nested vector, where
⍝    the first value is guaranteed to exist and is a boolean representing
⍝    whether the function succeeded.
⍝    If 1, the function succeded. If the function returned a result, it will be
⍝    the second value and of type TYPE. You can unwrap this value from an
⍝    optional O by doing "↑1↓O"
⍝    If 0, the function failed. The second value is a string describing the
⍝    issue.
⍝
⍝ CHANGELOG:
⍝   Upcoming:
⍝   - Fixed FIO∆READ_FD not reading from given file descriptor.
⍝   - Swapped arugments for dyadic functions that work with file descriptors for
⍝     a better user experience.
⍝   - Added FIO∆PRINT_FD and FIO∆PRINT for easily outputting strings without
⍝     needing to convert them to bytes first.
⍝   - Renamed FIO∆FPRINTF -> FIO∆PRINTF_FD.
⍝   - Changed meta for unwrapping optionals from "↑O[2]" to "↑1↓V".
⍝   1.0.0:
⍝   - Relicensed as GPLv3+ (orignally zlib.)
⍝   - Code cleanup.
⍝   - Completely redid error handling in a more APL-friendly manner.
⍝   - Verified behavior with unit testing.
⍝   - Made FIO∆POPEN_READ and FIO∆POPEN_WRITE escape shell commands
⍝     automatically.
⍝   - Added FIO∆DEFER and FIO∆DEFER_END which replicate the defer statement in
⍝     languages like Zig.
⍝   - FIO∆MAKE_DIRECTORY (was FIO∆MKDIR) now fails if PATH is a file.
⍝   - Made functions that work with file descriptors no longer throw APL
⍝     exceptions on unopen file descriptors.
⍝   - Added FIO∆PERROR, FIO∆LIST_FDS, FIO∆STRERROR, FIO∆ERRNO, FIO∆READ_LINE_FD,
⍝     FIO∆REMOVE, FIO∆REMOVE_RECURSIVE, FIO∆FPRINTF, FIO∆PRINTF,
⍝     FIO∆CURRENT_DIRECTORY.
⍝     FIO∆IS_FILE.
⍝   - Renamed FIO∆FOPEN -> FIO∆OPEN_FILE, FIO∆FLOSE -> FIO∆CLOSE_FD, FIO∆FEOF ->
⍝     FIO∆EOF_FD, FIO∆FERROR -> FIO∆ERROR_FD, FIO∆FREAD -> FIO∆READ_FD,
⍝     FIO∆FWRITE -> FIO∆WRITE_FD, FIO∆MKDIR -> FIO∆MAKE_DIRECTORY, FIO∆MKDIRS ->
⍝     FIO∆MAKE_DIRECTORIES,
⍝   - Split FIO∆GET_TIME_OF_DAY into FIO∆TIME_S, FIO∆TIME_MS, and FIO∆TIME_US.
⍝   - Removed FIO∆IS_DIRECTORY; FIO∆LIST_DIRECTORY makes it redundant.
⍝   0.1.0:
⍝   - Intial release.

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Metadata                                                                     ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ See for details: https://www.gnu.org/software/apl/Library-Guidelines-GNU-APL.html
FIO⍙metadata←"Author" "BugEmail" "Documentation" "Download" "LICENSE" "Portability" "Provides" "Requires" "Version",⍪"ona li toki e jan Epiphany tawa mi" "" "https://paltepuk.xyz/cgit/fio.apl.git/about/" "https://paltepuk.xyz/cgit/fio.apl.git/plain/fio.apl" "GPLv3+" "L3" "FIO" "" "1.0.0"

⍝ Links:
⍝ - paltepuk - https://http://paltepuk.xyz/cgit/fio.apl.git/about/
⍝ - paltepuk (I2P) - http://oytjumugnwsf4g72vemtamo72vfvgmp4lfsf6wmggcvba3qmcsta.b32.i2p/cgit/fio.apl.git/about/
⍝ - paltepuk (Tor) - http://4blcq4arxhbkc77tfrtmy4pptf55gjbhlj32rbfyskl672v2plsmjcyd.onion/cgit/fio.apl.git/about/
⍝ - GitHub - https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/fio.apl/



⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Utilities                                                                    ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ Converts bytes to a UTF-8 encoded string.
⍝ BYTES: bytes.
⍝ UTF8: string.
∇UTF8←FIO∆BYTES_TO_UTF8 BYTES
  UTF8←19 ⎕CR ⎕UCS BYTES
∇

⍝ Converts a UTF-8 encoded string to bytes.
⍝ UTF8: string.
⍝ BYTES: bytes.
∇BYTES←FIO∆UTF8_TO_BYTES UTF8
  BYTES←⎕UCS 18 ⎕CR UTF8
∇

⍝ Splits VECTOR by DELIMITER into a nested vector of vectors. If any of the
⍝ resulting vectors are empty, they will still be included in RESULT (i.e.
⍝ value value delimeter delimeter value -> (value value) () (value).)  DELIMITER
⍝  will not appear in RESULT.
⍝ VECTOR: vector<any>.
⍝ DELIMETER: vector<any>.
⍝ RESULT: vector<vector<any>>.
∇RESULT←DELIMITER FIO∆SPLIT VECTOR
  RESULT←DELIMITER~⍨¨VECTOR⊂⍨1++\VECTOR∊DELIMITER
∇

⍝ Splits VECTOR by DELIMITER into a nested vector of vectors. If a any of
⍝ the resulting vectors are empty, they will not be included in RESULT (i.e.
⍝ value value delimeter delimeter value -> (value value) (value).) DELIMITER
⍝ will not appear in RESULT.
⍝ VECTOR: vector<any>.
⍝ DELIMITER: vector<any>.
⍝ RESULT: vector<vector<any>>.
∇RESULT←DELIMITER FIO∆SPLIT_CLEAN VECTOR
  RESULT←VECTOR⊂⍨~VECTOR∊DELIMITER
∇

⍝ Prints a string out to stdout.
⍝ STRING: string.
∇SUCCESS←FIO∆PRINT STRING
  SUCCESS←FIO∆STDOUT FIO∆PRINT_FD STRING
∇

⍝ Prints formatted output to stdout, like C printf.
⍝ FORMAT_ARGUMENTS: vector<[1]string, any> - a vector with the format as the
⍝                   first element, and the arguments as the rest.
⍝ BYTES_WRITTEN: optional<uint> - the number of bytes written.
∇BYTES_WRITTEN←FIO∆PRINTF FORMAT_ARGUMENTS
  BYTES_WRITTEN←FIO∆STDOUT FIO∆PRINTF_FD FORMAT_ARGUMENTS
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Defer                                                                        ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ TODO add DEFER_START to segment defers by function.

FIO∆DEFERS←⍬

⍝ Defers the given APL code until FIO∆DEFER_END is called.
⍝ CODE: string.
∇FIO∆DEFER CODE
  FIO∆DEFERS←FIO∆DEFERS,⍨⊂CODE
∇

⍝ Runs all deferred code in the reverse order by which they were added via
⍝ FIO∆DEFER
∇FIO∆DEFER_END; DEFERRED
  LLOOP:
    →(0≡≢FIO∆DEFERS) ⍴ LEND
    DEFERRED←↑FIO∆DEFERS ◊ FIO∆DEFERS←1↓FIO∆DEFERS
    ⍎DEFERRED
    →LLOOP
  LEND:
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ ERRNO                                                                        ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ Returns the value of ERRNO for the previous ⎕FIO C function.
⍝ ERRNO: errno.
∇ERRNO←FIO∆ERRNO
  ⍝ Zi ←    ⎕FIO[ 1] ''    errno (of last call)
  ERRNO←⎕FIO[1] ''
∇

⍝ Returns a description of the provided ERRNO.
⍝ ERRNO: errno.
⍝ DESCRIPTION: string.
∇DESCRIPTION←FIO∆STRERROR ERRNO
  ⍝ Zs ←    ⎕FIO[ 2] Be    strerror(Be)
  ⍝ ⎕FIO[2] actually returns a character vector of bytes, so ⎕UCS is used to
  ⍝ convert them to bytes.
  DESCRIPTION←FIO∆BYTES_TO_UTF8 ⎕UCS (⎕FIO[2] ERRNO)
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ File and Directory Handling                                                  ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ Splits a file path into it's seperate parts and removes the seperators (i.e.
⍝ FIO∆SPLIT_PATH "../a/p///apples" → ".." "a" "p" "apples".)
⍝ PATH: string.
⍝ PATHS: vector<string>.
∇PATHS←FIO∆SPLIT_PATH PATH
  PATHS←'/' FIO∆SPLIT_CLEAN PATH
∇
⍝ FRONT_PATH: string.
⍝ BACK_PATH: string.
⍝ PATH: string.
⍝ Joins two paths together with a seperator.
∇PATH←FRONT_PATH FIO∆JOIN_PATH BACK_PATH
  PATH←FRONT_PATH,'/',BACK_PATH
∇

⍝ Returns a vector of strings with the contents of the directory at the given
⍝ path.
⍝ PATH: string.
⍝ CONTENTS: optional<vector<string>>.
∇CONTENTS←FIO∆LIST_DIRECTORY PATH
  ⍝ Zn ←    ⎕FIO[29] Bs    return file names in directory Bs
  CONTENTS←⎕FIO[29] PATH

  →(1≤≡CONTENTS) ⍴ LSUCCESS
    ⍝ Failed to list PATH.
    CONTENTS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    CONTENTS←1 CONTENTS
  LSWITCH_END:
∇

⍝ Returns path of the current working directory.
⍝ DIRECTORY: optional<string>.
∇PATH←FIO∆CURRENT_DIRECTORY
  ⍝ Zs ←    ⎕FIO 30        getcwd()
  PATH←⎕FIO 30

  →(1≤≡PATH) ⍴ LSUCCESS
    ⍝ Failed to list directory.
    PATH←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    PATH←1 PATH
  LSWITCH_END:
∇

⍝ Creates a directory at the given path if it doesn't exist. Does not recurse.
⍝ MODE: vector<uint> - octal mode for the directory (i.e. 7 5 5.)
⍝ SUCCESS: optional<void>.
∇SUCCESS←MODE FIO∆MAKE_DIRECTORY PATH
  →(FIO∆IS_FILE PATH) ⍴ LIS_FILE
  ⍝ Zi ← Ai ⎕FIO[20] Bh    mkdir(Bc, AI)
  SUCCESS←PATH ⎕FIO[20]⍨ 8⊥MODE
  →(0≡SUCCESS) ⍴ LSUCCESS
    ⍝ Failed to make directory.
    SUCCESS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LIS_FILE:
    SUCCESS←0 "Path already exists and is a file" ◊ →LSWITCH_END
  LSUCCESS:
    SUCCESS←⍬,1
  LSWITCH_END:
∇

⍝ Creates a directory at the given path and it's parent directories if they
⍝ don't exist.
⍝ MODE: vector<uint> - octal mode for the directory as an integer vector (i.e.
⍝       7 5 5.)
⍝ SUCCESS: optional<void>.
∇SUCCESS←MODE FIO∆MAKE_DIRECTORIES PATH; DIRECTORIES
  DIRECTORIES←FIO∆JOIN_PATH\ FIO∆SPLIT_PATH PATH
  →(0≡≢DIRECTORIES) ⍴ LINVALID_PATH

  SUCCESS←↑DIRECTORIES FIO∆MAKE_DIRECTORY⍨¨ (≢DIRECTORIES)/⊂MODE

  →LSUCCESS
LINVALID_PATH:
  SUCCESS←0 "Invalid path"
LSUCCESS:
∇

⍝ Common file descriptors.
FIO∆STDIN←0
FIO∆STDOUT←1
FIO∆STDERR←2

⍝ Returns open file descriptors.
⍝ FDS: vector<fd>.
∇FDS←FIO∆LIST_FDS
  ⍝ ⎕FIO     0     return a list of open file descriptors
  FDS←⎕FIO 0
∇

⍝ Checks if a file (not a directory) exists at the given path and can be opened.
⍝ NOTE - if you plan on opening the file, just use FIO∆OPEN_FILE.
⍝ PATH: string.
⍝ RESULT: boolean.
∇RESULT←FIO∆IS_FILE PATH; FD
  →(↑FIO∆LIST_DIRECTORY PATH) ⍴ LIS_DIRECTORY
  FD←"r" FIO∆OPEN_FILE PATH ◊ →(↑FD) ⍴ LIS_FILE
    ⍝ An error occured, probably not a file.
    RESULT←0 ◊ →LSWITCH_END
  LIS_DIRECTORY:
    RESULT←0 ◊ →LSWITCH_END
  LIS_FILE:
    ⊣ FIO∆CLOSE_FD ↑1↓FD
    RESULT←1
  LSWITCH_END:
∇

⍝ Opens a file.
⍝ MODE: string - open mode (i.e. "w", "r+", etc..). See 'man fopen' for details.
⍝ FD: optional<fd> - the descriptor of the opened file.
∇FD←MODE FIO∆OPEN_FILE PATH
  ⍝ Zh ← As ⎕FIO[ 3] Bs    fopen(Bs, As) filename Bs mode As
  FD←MODE ⎕FIO[3] PATH

  →(1≤FD) ⍴ LSUCCESS
    FD←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LFAIL
  LSUCCESS:
    FD←1 FD
  LFAIL:
∇

⍝ Closes a file descriptor.
⍝ FD: fd.
⍝ SUCCESS: optional<void>.
∇SUCCESS←FIO∆CLOSE_FD FD
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Ze ←    ⎕FIO[ 4] Bh    fclose(Bh)
  SUCCESS←⎕FIO[4] FD
  →(0≡SUCCESS) ⍴ LSUCCESS
    ⍝ Failed to close FD.
    SUCCESS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LUNOPEN_FD:
    SUCCESS←0 "Not an open file descriptor" ◊ →LSWITCH_END
  LSUCCESS:
    SUCCESS←⍬,1
  LSWITCH_END:
∇

⍝ Returns whether EOF was reached for the file descriptor. If the file
⍝ descriptor is not open, returns true.
⍝ FD: fd.
⍝ EOF_REACHED: boolean.
∇EOF_REACHED←FIO∆EOF_FD FD
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Zi ←    ⎕FIO[10] Bh    feof(Bh).
  EOF_REACHED←0≢(⎕FIO[10] FD)

  →LSUCCESS
LUNOPEN_FD:
  EOF_REACHED←1
LSUCCESS:
∇

⍝ Returns whether an error ocurred with the file descriptor. If the file
⍝ descriptor is not open, returns true.
⍝ FD: fd.
⍝ HAS_ERROR: boolean.
∇HAS_ERROR←FIO∆ERROR_FD FD
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Ze ←    ⎕FIO[11] Bh    ferror(Bh)
  HAS_ERROR←0≢(⎕FIO[11] FD)

  →LSUCCESS
LUNOPEN_FD:
  HAS_ERROR←1
LSUCCESS:
∇

⍝ Reads bytes up to specified number of bytes from the file descriptor.
⍝ MAXIMUM_BYTES: uint - the maximum number of bytes to read.
⍝ BYTES: optional<bytes>.
⍝ FD: fd.
∇BYTES←FD FIO∆READ_FD MAXIMUM_BYTES
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Zb ← Ai ⎕FIO[ 6] Bh    fread(Zi, 1, Ai, Bh) 1 byte per Zb
  BYTES←MAXIMUM_BYTES ⎕FIO[6] FD
  →(0≢BYTES) ⍴ LSUCCESS
    ⍝ Failed to read FD.
    BYTES←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LUNOPEN_FD:
    BYTES←0 "Not an open file descriptor" ◊ →LSWITCH_END
  LSUCCESS:
    BYTES←1 BYTES
  LSWITCH_END:
∇

⍝ Reads bytes up to a newline or EOF. Newlines are not included in the output.
⍝ FD: fd.
⍝ BYTES: optional<bytes>.
∇BYTES←FIO∆READ_LINE_FD FD; NEWLINE;BUFFER
  →(FD∊FIO∆LIST_FDS) ⍴ LOPEN_FD
    BYTES←0 "Not an open file descriptor" ◊ →LEND
  LOPEN_FD:
  →(~FIO∆EOF_FD FD) ⍴ LNOT_EOF
    BYTES←0 "Reached EOF" ◊ →LEND
  LNOT_EOF:

  BYTES←⍬
  NEWLINE←FIO∆UTF8_TO_BYTES "\n"
  LREAD_LOOP:
    ⍝ Zb ← Ai ⎕FIO[ 8] Bh    fgets(Zb, Ai, Bh) 1 byte per Zb
    BUFFER←5000 ⎕FIO[8] FD
    →(0≡≢BUFFER) ⍴ LREAD_LOOP_END
    BYTES←BYTES,BUFFER
    →(NEWLINE≢¯1↑BYTES) ⍴ LNO_NEWLINE
      BYTES←¯1↓BYTES ◊ →LREAD_LOOP_END
    LNO_NEWLINE:
    →LREAD_LOOP
  LREAD_LOOP_END:

  →(0≢≢BYTES) ⍴ LREAD_SUCCESS
    BYTES←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LEND
  LREAD_SUCCESS:

  BYTES←1 BYTES

LEND:
∇

⍝ Reads bytes from a file descriptor until EOF is reached.
⍝ FD: fd.
⍝ BYTES: optional<bytes>.
∇BYTES←FIO∆READ_ENTIRE_FD FD; BUFFER
  →(~FIO∆EOF_FD FD) ⍴ LNOT_EOF
    BYTES←0 "Reached EOF" ◊ →LEND
  LNOT_EOF:

  BYTES←⍬
  LREAD_LOOP:
    BUFFER←FD FIO∆READ_FD 5000
    →(~↑BUFFER) ⍴ LEND_READ_LOOP
    BYTES←BYTES,↑1↓BUFFER ◊ →LREAD_LOOP
  LEND_READ_LOOP:

  →(~FIO∆ERROR_FD FD) ⍴ LSUCCESS
    BYTES←0 BYTES ◊ →LFAIL
  LSUCCESS:
    BYTES←1 BYTES
  LFAIL:

LEND:
∇

⍝ Reads in an entire file as bytes.
⍝ PATH: string - path to the file.
⍝ Bytes: optional<bytes>.
∇BYTES←FIO∆READ_ENTIRE_FILE PATH
  ⍝ Zb ←    ⎕FIO[26] Bs    return entire file Bs as byte vector
  ⍝ ⎕FIO[26] throws an APL exception on directories, and probably some other
  ⍝ things.
  BYTES←"→LEXCEPTION" ⎕EA "⎕FIO[26] PATH"
  →(1≤≡BYTES) ⍴ LSUCCESS
    ⍝ Failed to read file.
    BYTES←0 "File does not exist" ◊ →LSWITCH_END
  LEXCEPTION:
    BYTES←0 "Either APL exception or not a file" ◊ →LSWITCH_END
  LSUCCESS:
    ⍝ ⎕FIO[26] actually returns a string of bytes, so ⎕UCS is used to convert
    ⍝ them to numbers.
    BYTES←1 (⎕UCS BYTES)
  LSWITCH_END:
∇

⍝ Writes bytes to the file descriptor.
⍝ FD: fd.
⍝ BYTES: bytes.
⍝ SUCCESS: optional<void>.
∇SUCCESS←FD FIO∆WRITE_FD BYTES
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Zi ← Ab ⎕FIO[ 7] Bh    fwrite(Ab, 1, ⍴Ai, Bh) 1 byte per Ai
  SUCCESS←BYTES ⎕FIO[7] FD
  →((≢BYTES)≡SUCCESS) ⍴ LSUCCESS
    ⍝ Failed to write to FD.
    SUCCESS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LUNOPEN_FD:
    SUCCESS←0 "Not an open file descriptor" ◊ →LSWITCH_END
  LSUCCESS:
    SUCCESS←⍬,1
  LSWITCH_END:
∇

⍝ Prints a string out to a file descriptor.
⍝ FD: fd.
⍝ STRING: string.
∇SUCCESS←FD FIO∆PRINT_FD STRING
  SUCCESS←FD FIO∆WRITE_FD FIO∆UTF8_TO_BYTES STRING
∇

⍝ Prints formatted output to a file descriptor, like C fprintf.
⍝ FD: fd.
⍝ FORMAT_ARGUMENTS: vector<[1]string, any> - a vector with the format as the
⍝                   first element, and the arguments as the rest.
⍝ BYTES_WRITTEN: optional<uint> - the number of bytes written.
∇BYTES_WRITTEN←FD FIO∆PRINTF_FD FORMAT_ARGUMENTS
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Zi ← A  ⎕FIO[22] Bh    fprintf(Bh,     A1, A2...) format A1
  BYTES_WRITTEN←FORMAT_ARGUMENTS ⎕FIO[22] FD
  →(0≤BYTES_WRITTEN) ⍴ LSUCCESS
    ⍝ Failed to write to FD.
    BYTES_WRITTEN←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LUNOPEN_FD:
    BYTES_WRITTEN←0 "Not an open file descriptor"
    →LSWITCH_END
  LSUCCESS:
    BYTES_WRITTEN←1 BYTES_WRITTEN
  LSWITCH_END:
∇

⍝ If PATH points to a file, it will be unlinked, possibly deleting it.
⍝ If PATH points to a directory, it will be deleted if empty.
⍝ PATH: string.
⍝ SUCCESS: optional<void>.
∇SUCCESS←FIO∆REMOVE PATH
  →(↑FIO∆LIST_DIRECTORY PATH) ⍴ LDIRECTORY
    ⍝ Zi ←    ⎕FIO[19] Bh    unlink(Bc)
    SUCCESS←⎕FIO[19] PATH ◊ →LFILE
  LDIRECTORY:
    ⍝ Zi ←    ⎕FIO[21] Bh    rmdir(Bc)
    SUCCESS←⎕FIO[21] PATH
  LFILE:

  →(0≡SUCCESS) ⍴ LSUCCESS
    ⍝ Failed to remove path.
    SUCCESS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    SUCCESS←⍬,1
  LSWITCH_END:
∇

⍝ If PATH points to a file, it will be unlinked, possibly deleting it.
⍝ If PATH points to a directory, it, and all of its contents, will be deleted.
⍝ PATH: string.
⍝ SUCCESS: optional<void>.
∇SUCCESS←FIO∆REMOVE_RECURSIVE PATH; CONTENTS;OTHER_PATH
  CONTENTS←FIO∆LIST_DIRECTORY PATH
  →(~↑CONTENTS) ⍴ LIS_NOT_DIRECTORY
    CONTENTS←↑1↓CONTENTS
    LDELETE_LOOP:
      →(0≡≢CONTENTS) ⍴ LDELETE_LOOP_END
      OTHER_PATH←PATH FIO∆JOIN_PATH ↑CONTENTS ◊ CONTENTS←1↓CONTENTS
      ⊣ FIO∆REMOVE_RECURSIVE OTHER_PATH
      →LDELETE_LOOP
    LDELETE_LOOP_END:
  LIS_NOT_DIRECTORY:

  SUCCESS←FIO∆REMOVE PATH
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Process Handling                                                             ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ Escapes the given shell argument with quotes.
⍝ ARGUMENT: string.
⍝ ESCAPED_ARUGMENT: string.
∇ESCAPED_ARUGMENT←FIO∆ESCAPE_SHELL_ARGUMENT ARGUMENT
  ESCAPED_ARUGMENT←"'",⍨"'",∊(ARGUMENT,⍨⊂"'\\''")[1+(⍳⍨ARGUMENT)×~ARGUMENT∊"'"]
∇

⍝ Joins two shell arguments together with a space.
⍝ FRONT_ARGUMENT: string.
⍝ BACK_ARGUMENT: string.
⍝ RESULT: string.
∇RESULT←FRONT_ARGUMENT FIO∆JOIN_SHELL_ARGUMENTS BACK_ARGUMENT
  RESULT←FRONT_ARGUMENT,' ',BACK_ARGUMENT
∇

⍝ Runs the given command in the user's shell in a subprocess. Close with FD
⍝ FIO∆PCLOSE.
⍝ EXE_ARGUMENTS: vector<string> - a vector with the executable to run as the
⍝                first element, and the arguments to it as the rest.
⍝ FD: optional<fd> - the process' read-only file descriptor.
∇FD←FIO∆POPEN_READ EXE_ARGUMENTS
  ⍝ Zh ← As ⎕FIO[24] Bs    popen(Bs, As) command Bs mode As
  FD←"r" ⎕FIO[24] ↑FIO∆JOIN_SHELL_ARGUMENTS/ FIO∆ESCAPE_SHELL_ARGUMENT¨ EXE_ARGUMENTS

  →(1≤FD) ⍴ LSUCCESS
    ⍝ Failed to run popen.
    FD←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    FD←1 FD
  LSWITCH_END:
∇

⍝ Runs the given command in the user's shell in a subprocess. Close with FD
⍝ FIO∆PCLOSE.
⍝ EXE_ARGUMENTS: vector<string> - a vector with the executable to run as the
⍝                first element, and the arguments to it as the rest.
⍝ FD: optional<fd> - The process' write-only file descriptor.
∇FD←FIO∆POPEN_WRITE EXE_ARGUMENTS
  ⍝ Zh ← As ⎕FIO[24] Bs    popen(Bs, As) command Bs mode As
  FD←"w" ⎕FIO[24] ↑FIO∆JOIN_SHELL_ARGUMENTS/ FIO∆ESCAPE_SHELL_ARGUMENT¨ EXE_ARGUMENTS

  →(1≤FD) ⍴ LSUCCESS
    ⍝ Failed to run popen.
    FD←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    FD←1 FD
  LSWITCH_END:
∇

⍝ Closes a file descriptor opened with FIO∆POPEN_{READ,WRITE}.
⍝ FD: fd.
⍝ SUCCESS: optional<uint> - process exit code.
∇ERROR←FIO∆PCLOSE FD
  →(~FD∊FIO∆LIST_FDS) ⍴ LUNOPEN_FD
  ⍝ Ze ←    ⎕FIO[25] Bh    pclose(Bh)
  ERROR←⎕FIO[25] FD
  →(0≤ERROR) ⍴ LSUCCESS
    ⍝ Failed to run pclose.
    ERROR←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LUNOPEN_FD:
    ERROR←0 "Not an open file descriptor" ◊ →LSWITCH_END
  LSUCCESS:
    ERROR←1 ERROR
  LSWITCH_END:
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Time                                                                         ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ Returns the current time since the Epoch in seconds.
⍝ S: optional<uint>.
∇S←FIO∆TIME_S
  ⍝ Zi ←    ⎕FIO[50] Bu    gettimeofday()
  S←⎕FIO[50] 1

  →(0≢S) ⍴ LSUCCESS
    ⍝ Failed to get time.
    S←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    S←1 S
  LSWITCH_END:
∇

⍝ Returns the current time since the Epoch in milliseconds.
⍝ MILLISECONDS: optional<uint>.
∇MS←FIO∆TIME_MS
  ⍝ Zi ←    ⎕FIO[50] Bu    gettimeofday()
  MS←⎕FIO[50] 1000

  →(0≢MS) ⍴ LSUCCESS
    ⍝ Failed to get time.
    MS←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    MS←1 MS
  LSWITCH_END:
∇

⍝ Returns the current time since the Epoch in microseconds.
⍝ MICROSECONDS: optional<uint>.
∇US←FIO∆TIME_US
  ⍝ Zi ←    ⎕FIO[50] Bu    gettimeofday()
  US←⎕FIO[50] 1000000

  →(0≢US) ⍴ LSUCCESS
    ⍝ Failed to get time.
    US←0 (FIO∆STRERROR FIO∆ERRNO) ◊ →LSWITCH_END
  LSUCCESS:
    US←1 US
  LSWITCH_END:
∇

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

⍝ TODO Consider adding the following ⎕FIO functions:
⍝ TODO ⎕FIO[51] mktime
⍝ TODO ⎕FIO[52] localtime
⍝ TODO ⎕FIO[53] gmtime
⍝ TODO ⎕FIO[54] chdir
⍝ TODO ⎕FIO[55] sscanf
⍝ TODO ⎕FIO[56] write nested lines to file
⍝ TODO ⎕FIO[57] fork and execve
⍝ TODO ⎕FIO[58] snprintf
⍝ TODO ⎕FIO[59] fcntl
⍝ TODO ⎕FIO[60] random byte vector
⍝ TODO ⎕FIO[61] seconds since Epoch; Bv←YYYY [MM DD [HH MM SS]]   ???????
⍝ TODO FIO[12] - ftell
⍝ TODO FIO[13,14,15] - fseek
⍝ TODO FIO[16] - fflush.
⍝ TODO FIO[17] - fsync.
⍝ TODO FIO[18] - fstat.
⍝ TODO ⎕FIO[31] access
⍝ TODO ⎕FIO[32] socket
⍝ TODO ⎕FIO[33] bind
⍝ TODO ⎕FIO[34] listen
⍝ TODO ⎕FIO[35] accept
⍝ TODO ⎕FIO[36] connect
⍝ TODO ⎕FIO[37] recv
⍝ TODO ⎕FIO[38] send
⍝ TODO ⎕FIO[40] select
⍝ TODO ⎕FIO[41] read
⍝ TODO ⎕FIO[42] write
⍝ TODO ⎕FIO[44] getsockname
⍝ TODO ⎕FIO[45] getpeername
⍝ TODO ⎕FIO[46] getsockopt
⍝ TODO ⎕FIO[47] setsockopt
⍝ TODO ⎕FIO[48] fscanf
⍝ TODO ⎕FIO[49] read entire file as nested lines
⍝ TODO ⎕FIO[27] rename file.

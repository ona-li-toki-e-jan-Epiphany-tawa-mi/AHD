#!/usr/bin/apl --script --

⍝ This file is part of AHD.
⍝
⍝ Copyright (c) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi
⍝
⍝ AHD is free software: you can redistribute it and/or modify it under the terms
⍝ of the GNU General Public License as published by the Free Software
⍝ Foundation, either version 3 of the License, or (at your option) any later
⍝ version.
⍝
⍝ AHD is distributed in the hope that it will be useful, but WITHOUT ANY
⍝ WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
⍝ A PARTICULAR PURPOSE. See the GNU General Public License for more details.
⍝
⍝ You should have received a copy of the GNU General Public License along with
⍝ AHD. If not, see <https://www.gnu.org/licenses/>.



⍝ Reads in the enitrety of the file with name ⍵ as a byte vector. Returns ¯2 on
⍝ failure. ⎕FIO[26] actually returns a character vector of the bytes, so ⎕UCS is
⍝ used to convert them to actual number like whats returned from ⎕FIO[6].
FIO∆READ_ENTIRE_FILE←{⎕UCS (⎕FIO[26] ⍵)}
⍝ Reads up to 5,000 bytes in from file descriptor ⍵ as a byte vector.
FIO∆FREAD←{⎕FIO[6] ⍵}
⍝ Returns non-zero if EOF was reached for file descriptor ⍵.
FIO∆FEOF←{⎕FIO[10] ⍵}
⍝ Returns non-zero if an error ocurred reading file descriptor ⍵.
FIO∆FERROR←{⎕FIO[11] ⍵}

⍝ The file descriptor for stdin.
FIO∆STDIN←0
⍝ Reads input from stdin until EOF is reached and outputs the contents as a
⍝ byte vector.
∇BYTE_VECTOR←FIO∆READ_ENTIRE_STDIN
  BYTE_VECTOR←⍬

  LREAD_LOOP:
    BYTE_VECTOR←BYTE_VECTOR,FIO∆FREAD FIO∆STDIN
    →(0≢FIO∆FEOF   FIO∆STDIN) ⍴ LEND_READ_LOOP
    →(0≢FIO∆FERROR FIO∆STDIN) ⍴ LEND_READ_LOOP
    →LREAD_LOOP
  LEND_READ_LOOP:
∇



ARGS∆HELP←⊃"""
Usages:
  ahd [options...] [FILE...]
  ./ahd.apl [options...] [FILE...]
  apl --script ahd.apl -- [options...] [FILE...]

Displays FILE contents (or input from stdin if no FILEs were specified) in
hexidecimal.

Options:
 +h, ++help    display this help information.
 +v, ++version display version.
"""
ARGS∆VERSION←"ahd 0.1.1"

⍝ A vector of filenames given via the command line.
ARGS∆FILENAMES←⍬
⍝ If 1, the program should abort, else 0. This would either be due to an error
⍝ or a command line argument that serves some other purpose.
ARGS∆ABORT←0
⍝ Whether "++" was encountered, meaning all following option-like arguments are
⍝ to be treated as files.
ARGS∆END_OF_OPTIONS←0

⍝ Parses a single command line ARGUMENT and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARG ARGUMENT
  →ARGS∆ABORT ⍴ LABORT

  ⍝ If "++" was encountered, we just treat everything as a file.
  →ARGS∆END_OF_OPTIONS ⍴ LFILE
  ⍝ Test for known options.
  →({ARGUMENT≡⍵}¨ "+h" "++help" "+v" "++version" "++") / LHELP LHELP LVERSION LVERSION LDOUBLE_PLUS
  ⍝ Jumps to error print if ARGUMENT is an unknown option.
  →(('+'≡↑ARGUMENT)∨"++"≡2↑ARGUMENT) ⍴ LINVALID_OPTION
    ⍝ Anything leftover is a file.
    LFILE: ARGS∆FILENAMES←ARGS∆FILENAMES,⊂ARGUMENT
    →LSWITCH_END
  LINVALID_OPTION:
    ⍞←"Error: unknown option '",ARGUMENT,"'\nTry 'ahd ++help' for more information\n"
    ARGS∆ABORT←1 ◊ →LSWITCH_END
  LHELP:        ⍝ +h, ++help
    ⍞←ARGS∆HELP
    ARGS∆ABORT←1 ◊ →LSWITCH_END
  LVERSION:     ⍝ +v, ++version
    ⍞←ARGS∆VERSION
    ARGS∆ABORT←1 ◊ →LSWITCH_END
  LDOUBLE_PLUS: ⍝ ++
    ARGS∆END_OF_OPTIONS←1
    →LSWITCH_END
  LSWITCH_END:

LABORT:
∇

⍝ Parses the command line ARGUMENTS and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS
  ⍝ ⎕ARG looks like "apl --script <script> --" plus whatever the user put.
  →(4≥≢ARGUMENTS) ⍴ LNO_ARGUMENTS
    ARGS∆PARSE_ARG¨ 4↓ARGUMENTS
  LNO_ARGUMENTS:
∇



⍝ The number of digits to use to print the line's byte offset.
OFFSET_DIGITS←7
⍝ The number of hexidecimal digits needed to represent a byte.
BYTE_DIGITS←2
⍝ The number of bytes to print out per line.
BYTES_PER_LINE←16
⍝ The number of hexidecimal digits to group together without spaces.
HEX_DIGITS_PER_BLOCK←2
⍝ The bvte-value of a space character.
SPACE_BYTE←⎕UCS ' '

⍝ Splits a vector ⍵ into partitions of size ⍺. If there is not enough elements
⍝ left for a full partition, the remaining elements will simply be placed in the
⍝ last partition.
SIZED_PARTITION←{⍵⊂⍨(≢⍵)⍴⍺/⍳⌈⍺÷⍨≢⍵}

⍝ Converts a number ⍵ into a uppercase-hexidecimal character vector with ⍺
⍝ hexidecimal digits.
HEXIFY←{{⍵⌷"0123456789ABCDEF"}¨1+⍵⊤⍨⍺/16}

⍝ Accepts a byte ⍵. If ⍵ represents an ASCII character, which is guaranteed to
⍝ be displayable, and not a control character, 1 will be returned, else 0.
IS_DISPLAYABLE←{(126≥⍵)∧32≤⍵}

⍝ Prints out a line of hexdump output of the BYTE_VECTOR. OFFSET is the current
⍝ line's byte offset and is also the return value.
∇OFFSET←OFFSET HEXDUMP_LINE BYTE_VECTOR
  ⍝ Offset.
  ⍞←OFFSET_DIGITS HEXIFY OFFSET ◊ ⍞←":"
  ⍝ Bytes.
  ⊣ {⍞←⍵ ⊣ ⍞←" "}¨ HEX_DIGITS_PER_BLOCK SIZED_PARTITION ↑,/ BYTE_DIGITS HEXIFY¨ BYTE_VECTOR
  ⍝ Characters.
  ⍞←" |",⍨ ⎕UCS SPACE_BYTE /⍨ (BYTE_DIGITS+1)×BYTES_PER_LINE - ≢BYTE_VECTOR
  ⍞←⎕UCS {(SPACE_BYTE ⍵)⌷⍨1+ IS_DISPLAYABLE ⍵}¨ BYTE_VECTOR
  ⍞←"|"

  ⍞←"\n"
∇

⍝ Prints out a hexdump of BYTE_VECTOR.
∇HEXDUMP BYTE_VECTOR; OFFSET
  OFFSET←0
  ⊣ {OFFSET←BYTES_PER_LINE+ OFFSET HEXDUMP_LINE ⍵}¨ BYTES_PER_LINE SIZED_PARTITION BYTE_VECTOR
∇

⍝ Prints out a hexdump of the contents of file FILENAME. If PRINT_FILENAME is 1,
⍝ the name of the file will be printed beforehand, else it won't if 0.
∇PRINT_FILENAME HEXDUMP_FILE FILENAME; BYTE_VECTOR
  →(~PRINT_FILENAME) ⍴ LDONT_PRINT_FILENAME
    ⎕←FILENAME,":"
  LDONT_PRINT_FILENAME:

  BYTE_VECTOR←FIO∆READ_ENTIRE_FILE FILENAME
  →(¯2≡BYTE_VECTOR) ⍴ LREAD_ERROR
    HEXDUMP BYTE_VECTOR ◊ →LSUCCESS
  LREAD_ERROR:
    ⍞←"ERROR: failed to open file '",FILENAME,"'\n"
  LSUCCESS:
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG
  →ARGS∆ABORT ⍴ LABORT

  →(0≡≢ARGS∆FILENAMES) ⍴ LREAD_STDIN
    ⍝ If we have more than one file, we print out the file name to identify each
    ⍝ hexdump.
    (1≢≢ARGS∆FILENAMES) HEXDUMP_FILE¨ ARGS∆FILENAMES
    →LDONT_READ_STDIN
  LREAD_STDIN:
    HEXDUMP FIO∆READ_ENTIRE_STDIN
  LDONT_READ_STDIN:

LABORT:
∇
MAIN



)OFF

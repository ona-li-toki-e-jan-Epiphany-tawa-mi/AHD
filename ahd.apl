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



⍝ Reads in the enitrety of the file with name ⍵ as a byte vector.
FIO∆READ_ENTIRE_FILE←{⎕FIO[26] ⍵}
⍝ Reads up to 5,000 bytes in from file descriptor ⍵ as a byte vector.
FIO∆FREAD←{⎕FIO[6] ⍵}
⍝ Returns non-zero if EOF was reached for file descriptor ⍵.
FIO∆FEOF←{⎕FIO[10] ⍵}
⍝ Returns non-zero if an error occured in file descriptor ⍵.
FIO∆FERROR←{⎕FIO[11] ⍵}
⍝ Returns errno of last ⎕FIO call.
FIO∆ERRNO←{⎕FIO[1] ''}
⍝ Returns the string describing errno ⍵.
FIO∆STRERROR←{⎕FIO[2] ⍵}

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



⍝ Filenames given via the command line.
ARGS∆FILENAMES←⍬

⍝ Parses a single command line ARGUMENT and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARG ARGUMENT
  ⍝ For now, everything is a file name.
  ARGS∆FILENAMES←ARGS∆FILENAMES,⊂ARGUMENT
∇

⍝ Parses the command line ARGUMENTS and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS
  ⍝ ⎕ARG looks like "apl --script <script> --" plus whatever the user put.
  →(4≥≢ARGUMENTS) ⍴ LNO_ARGUMENTS
    ARGS∆PARSE_ARG¨ 4↓ARGUMENTS
  LNO_ARGUMENTS:
∇



⍝ Splits a vector ⍵ into partitions of size ⍺. If there is not enough elements
⍝ left for a full partition, the remaining elements will simply  be placed in
⍝ the last partition.
SIZED_PARTITION←{⍵⊂⍨(≢⍵)⍴⍺/⍳⌈⍺÷⍨≢⍵}

⍝ Converts a byte vector ⍵ into an uppercase-hexidecimal character vector.
HEXIFY_BYTES←{5 ⎕CR ⍵}

⍝ Prints out a hexdump of BYTE_VECTOR.
∇HEXDUMP BYTE_VECTOR; LINE_BYTE_NUMBER
  LINE_BYTE_NUMBER←0
  ⊣ {⍞←"\n" ⊣ ⍞←⍵ ⊣ ⍞←": " ⊣ LINE_BYTE_NUMBER←16+⍞←LINE_BYTE_NUMBER}¨ 16 SIZED_PARTITION HEXIFY_BYTES BYTE_VECTOR
∇

⍝ Prints out a hexdump of the contents of file FILENAME. If PRINT_FILENAME is 1,
⍝ the name of the file will be printed beforehand, else it won't if 0.
∇PRINT_FILENAME HEXDUMP_FILE FILENAME
  →(~PRINT_FILENAME) ⍴ LDONT_PRINT_FILENAME
    ⎕←FILENAME,":"
  LDONT_PRINT_FILENAME:

  HEXDUMP FIO∆READ_ENTIRE_FILE FILENAME
∇


∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →(0≡≢ARGS∆FILENAMES) ⍴ LREAD_STDIN
    ⍝ If we have more than one file we print out the file name to identify each
    ⍝ hexdump.
    (1≢≢ARGS∆FILENAMES) HEXDUMP_FILE¨ ARGS∆FILENAMES
    →LDONT_READ_STDIN
  LREAD_STDIN:
    HEXDUMP FIO∆READ_ENTIRE_STDIN
  LDONT_READ_STDIN:
∇
MAIN



)OFF

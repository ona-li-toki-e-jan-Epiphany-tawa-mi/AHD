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



⍝ Reads in the enitrety of the file a byte vector. ⎕FIO[26] actually returns a
⍝ character vector of the bytes, so ⎕UCS is used to convert them to actual
⍝ numbers like whats returned from ⎕FIO[6].
⍝ →⍵ - the name of the file.
⍝ →a byte vector, or ¯2 on failure.
FIO∆READ_ENTIRE_FILE←{⎕UCS (⎕FIO[26] ⍵)}
⍝ Reads up to 5,000 bytes in from the file descriptor as a byte vector.
FIO∆FREAD←{⎕FIO[6] ⍵}
⍝ Returns non-zero if EOF was reached for the file descriptor.
FIO∆FEOF←{⎕FIO[10] ⍵}
⍝ Returns non-zero if an error ocurred reading file descriptor.
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



⍝ A vector of filenames given via the command line.
ARGS∆FILENAMES←⍬
⍝ If 1, the program should abort, else 0. This would either be due to an error
⍝ or a command line argument that serves some other purpose.
ARGS∆ABORT←0
⍝ Whether "++" was encountered, meaning all following option-like arguments are
⍝ to be treated as files.
ARGS∆END_OF_OPTIONS←0
⍝ If of tally > 0, the code generator should be used. The value of this variable
⍝ will be the name of the language to generate for as a character vector.
ARGS∆CODE_GENERATOR_LANGUAGE←⍬

⍝ For options with arguments. When set to 1, the next argument is evaluated as
⍝ the repsective option's argument.
ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←0

⍝ Displays and error message and exits.
∇ARGS∆FATAL_ERROR MESSAGE
  ⍞←"Error: "
  ⍞←MESSAGE
  ⍞←"\nTry 'ahd +h' for more information"
  ARGS∆ABORT←1
∇

⍝ Displays help information and exits.
∇ARGS∆DISPLAY_HELP
  ⍞←"Usages:\n"
  ⍞←"  ahd [options...] [FILE...]\n"
  ⍞←"  ./ahd.apl [options...] [FILE...]\n"
  ⍞←"  apl --script ahd.apl -- [options...] [FILE...]\n"
  ⍞←"\n"
  ⍞←"Displays FILE contents (or input from stdin if no FILEs were specified) in\n"
  ⍞←"hexidecimal.\n"
  ⍞←"\n"
  ⍞←"Options:\n"
  ⍞←"  +h, ++help    display this help information.\n"
  ⍞←"  +v, ++version display version.\n"
  ⍞←"  +c, ++code-generator\n"
  ⍞←"    Outputs code to bake the data into a program. Expects a language as an\n"
  ⍞←"    argument. Supported Languages: c"
  ARGS∆ABORT←1
∇

⍝ Displays the version and exits.
∇ARGS∆DISPLAY_VERSION
  ⍞←"ahd 0.1.2"
  ARGS∆ABORT←1
∇

⍝ Enables the code generator and tries to and set it to use the given language.
∇ARGS∆SET_CODE_GENERATOR_LANGUAGE LANGUAGE
  →("c"≡LANGUAGE) ⍴ LKNOWN_LANGUAGE
    ARGS∆FATAL_ERROR "language '",LANGUAGE,"' does not support code generation"
    ARGS∆ABORT←1 ◊ →LABORT
  LKNOWN_LANGUAGE:

  ARGS∆CODE_GENERATOR_LANGUAGE←LANGUAGE
  ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←0

LABORT:
∇

⍝ Parses a single character option (anything aftoptioner a "+") and updates ARGS∆*
⍝ accordingly.
∇ARGS∆PARSE_SHORT_OPTION OPTION
  →ARGS∆ABORT ⍴ LABORT

  →({OPTION≡⍵}¨'h' 'v' 'c') / LHELP LVERSION LCODE_GENERATOR
  LDEFAULT:        ARGS∆FATAL_ERROR "unknown option '+",OPTION,"'" ◊ →LSWITCH_END
  LHELP:           ARGS∆DISPLAY_HELP                               ◊ →LSWITCH_END
  LVERSION:        ARGS∆DISPLAY_VERSION                            ◊ →LSWITCH_END
  LCODE_GENERATOR: ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←1           ◊ →LSWITCH_END
  LSWITCH_END:

LABORT:
∇

⍝ Parses a command line argument and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARG ARGUMENT
  →ARGS∆ABORT ⍴ LABORT

  ⍝ If "++" was encountered, we just treat everything as a file.
  →ARGS∆END_OF_OPTIONS ⍴ LFILE
  ⍝ Handles arguments to options with arguments.
  →ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE ⍴ LSET_CODE_GENERATOR_LANGUAGE
  ⍝ Handles "++".
  →("++"≡ARGUMENT) ⍴ LDOUBLE_PLUS
  ⍝ Handles short options
  →((1<≢ARGUMENT)∧('+'≡↑ARGUMENT)∧"++"≢2↑ARGUMENT) ⍴ LSHORT_OPTION
  ⍝ Test for known long options.
  →({ARGUMENT≡⍵}¨ "++help" "++version" "++code-generator") / LHELP LVERSION LCODE_GENERATOR
  ⍝ Jumps to error print if ARGUMENT is an unknown long option.
  →("++"≡2↑ARGUMENT) ⍴ LINVALID_LONG_OPTION
  LDEFAULT:
  LFILE:
    ⍝ Anything leftover is a file.
    ARGS∆FILENAMES←ARGS∆FILENAMES,⊂ARGUMENT
    →LSWITCH_END
  LINVALID_LONG_OPTION: ARGS∆FATAL_ERROR "unknown option '",ARGUMENT,"'" ◊ →LSWITCH_END
  LSHORT_OPTION:        ARGS∆PARSE_SHORT_OPTION¨ 1↓ARGUMENT              ◊ →LSWITCH_END
  LDOUBLE_PLUS:         ARGS∆END_OF_OPTIONS←1                            ◊ →LSWITCH_END
  LSET_CODE_GENERATOR_LANGUAGE:
    ARGS∆SET_CODE_GENERATOR_LANGUAGE ARGUMENT
    →LSWITCH_END
  LHELP:                ARGS∆DISPLAY_HELP                                ◊ →LSWITCH_END
  LVERSION:             ARGS∆DISPLAY_VERSION                             ◊ →LSWITCH_END
  LCODE_GENERATOR:      ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←1            ◊ →LSWITCH_END
  LSWITCH_END:

LABORT:
∇

⍝ Parses command line arguments and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS
  ⍝ ⎕ARG looks like "apl --script <script> --" plus whatever the user put.
  →(4≥≢ARGUMENTS) ⍴ LNO_ARGUMENTS
    ARGS∆PARSE_ARG¨ 4↓ARGUMENTS
  LNO_ARGUMENTS:

  →ARGS∆ABORT ⍴ LABORT

  ⍝ Tests for any options with arguments that were not supplied an argument.
  →(~ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE) ⍴ LNO_INVALID_OPTIONS
    ARGS∆FATAL_ERROR "options '+c' and '++code-generator' expect an argument"
    →LABORT
  LNO_INVALID_OPTIONS:

LABORT:
∇



⍝ Converts a number into a uppercase-hexidecimal character vector.
⍝ →⍵ - the number.
⍝ →⍺ - the number of digits the resulting vector should have.
⍝ ←The character vector.
HEXIFY←{{⍵⌷"0123456789ABCDEF"}¨1+⍵⊤⍨⍺/16}

⍝ Splits a vector into partitions of the specified size. If there is not enough elements
⍝ left for a full partition, the remaining elements will simply be placed in the
⍝ last partition.
⍝ →⍵ - the vector to partition.
⍝ →⍺ - the size of the paritions.
SIZED_PARTITION←{⍵⊂⍨(≢⍵)⍴⍺/⍳⌈⍺÷⍨≢⍵}



⍝ The number of digits to use to print the line's byte offset.
OFFSET_DIGITS←7
⍝ The number of hexidecimal digits needed to represent a byte.
BYTE_DIGITS←2
⍝ The number of bytes to print out per line.
BYTES_PER_LINE←16
⍝ The bvte-value of a space character.
SPACE_BYTE←⎕UCS ' '

⍝ Returns whether the given byte is a displayable, non-control ASCII character.
⍝ →⍵ - a byte.
⍝ ←1 if the byte matches the criteria, else 0.
IS_DISPLAYABLE←{(126≥⍵)∧32≤⍵}

⍝ Prints out a line of hexdump output of the byte vector.
⍝ →BYTE_VECTOR - the byte vector.
⍝ →OFFSET - the current line's byte offset.
⍝ ←OFFSET - OFFSET.
∇OFFSET←OFFSET HEXDUMP_LINE BYTE_VECTOR
  ⍝ Offset.
  ⍞←OFFSET_DIGITS HEXIFY OFFSET ◊ ⍞←":"
  ⍝ Bytes.
  ⊣ {⍞←⍵ ⊣ ⍞←" "}¨ BYTE_DIGITS HEXIFY¨ BYTE_VECTOR
  ⍝ Characters.
  ⍞←" |",⍨ ⎕UCS SPACE_BYTE /⍨ (BYTE_DIGITS+1)×BYTES_PER_LINE - ≢BYTE_VECTOR
  ⍞←⎕UCS {(SPACE_BYTE ⍵)⌷⍨1+ IS_DISPLAYABLE ⍵}¨ BYTE_VECTOR
  ⍞←"|"

  ⍞←"\n"
∇

⍝ Prints out a hexdump of the given byte vector.
∇HEXDUMP BYTE_VECTOR; OFFSET
  OFFSET←0
  ⊣ {OFFSET←BYTES_PER_LINE+ OFFSET HEXDUMP_LINE ⍵}¨ BYTES_PER_LINE SIZED_PARTITION BYTE_VECTOR
∇



⍝ Prints out a line of C code output of the byte vector.
⍝ →BYTE_VECTOR - the byte vector to print.
⍝ ←IGNORE - magic return value so the function works in defuns.
∇IGNORE←GENERATE_C_LINE BYTE_VECTOR
  ⍞←"    "
  ⊣ {⍞←", " ⊣ ⍞←⍵ ⊣ ⍞←"0x"}¨ 2 HEXIFY¨ BYTE_VECTOR
  ⍞←"\n"

  IGNORE←⍬
∇

⍝ Prints out C code of the byte vector.
∇GENERATE_C BYTE_VECTOR
  ⍞←"unsigned char data[] = {\n"
  ⊣ {GENERATE_C_LINE ⍵}¨ 16 SIZED_PARTITION BYTE_VECTOR
  ⍞←"};\n"
  ⍞←"unsigned int data_length = " ◊ ⍞←≢BYTE_VECTOR ◊ ⍞←";\n"
∇



⍝ Handles printing the output of the given file (hexdump, code, etc..).
⍝ →FILENAME - the filename to print. A value with a tally of 0 means don't
⍝ print.
⍝ →BYTE_VECTOR - the raw byte contents of the file.
⍝ ←IGNORE - magic return value so the function works in defuns.
∇IGNORE←FILENAME HANDLE_FILE BYTE_VECTOR
  →(0≡≢FILENAME) ⍴ LDONT_PRINT_FILENAME
    ⎕←FILENAME,":"
  LDONT_PRINT_FILENAME:

  →(¯2≢BYTE_VECTOR) ⍴ LNO_READ_ERROR
    ⍞←"Error: failed to open file\n"
    →LABORT
  LNO_READ_ERROR:

  ⍝ If a code generator is selected, we use that, else we just do a hexdump.
  →("c"≡ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LGENERATE_C
  LDEFAULT:
    →(0≡≢ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LNO_SET_LANGUAGE
      ⍞←"Error: HANDLE_FILE: unexpected code generator language '",ARGS∆CODE_GENERATOR_LANGUAGE,"'"
      →LABORT
    LNO_SET_LANGUAGE:
    HEXDUMP BYTE_VECTOR ◊ →LSWITCH_END
  LGENERATE_C: GENERATE_C BYTE_VECTOR ◊ →LSWITCH_END
  LSWITCH_END:

LABORT:
  IGNORE←⍬
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG
  →ARGS∆ABORT ⍴ LABORT

  →(0≡≢ARGS∆FILENAMES) ⍴ LREAD_STDIN
  →(1≡≢ARGS∆FILENAMES) ⍴ LREAD_FILE
    ⍝ We only add the filenames when there are multiple fixes to output, to
    ⍝ differentiate them.
    ⊣ {⍵ HANDLE_FILE FIO∆READ_ENTIRE_FILE ⍵}¨ ARGS∆FILENAMES
    →LSWITCH_END
  LREAD_FILE:  ⊣ ⍬ HANDLE_FILE FIO∆READ_ENTIRE_FILE ↑ARGS∆FILENAMES ◊ →LSWITCH_END
  LREAD_STDIN: ⊣ ⍬ HANDLE_FILE FIO∆READ_ENTIRE_STDIN                ◊ →LSWITCH_END
  LSWITCH_END:

LABORT:
∇
MAIN



)OFF

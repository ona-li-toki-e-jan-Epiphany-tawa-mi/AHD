#!/usr/local/bin/apl --script

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

⍝ AHD - A HexDuper. Hex dump utility.



⊣ ⍎")COPY_ONCE fio.apl"
⊣ ⍎")COPY_ONCE logging.apl"



⍝ The path to the apl interpreter used to call this program.
ARGS∆APL_PATH←⍬
⍝ The name of this file/program.
ARGS∆PROGRAM_NAME←⍬
⍝ A vector of filenames given via the command line.
ARGS∆FILENAMES←⍬
⍝ Whether "++" was encountered, meaning all following option-like arguments are
⍝ to be treated as files.
ARGS∆END_OF_OPTIONS←0
⍝ If of tally > 0, the code generator should be used. The value of this variable
⍝ will be the name of the language to generate for as a character vector.
ARGS∆CODE_GENERATOR_LANGUAGE←⍬

⍝ For options with arguments. When set to 1, the next argument is evaluated as
⍝ the repsective option's argument.
ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←0

⍝ Displays a short help message.
∇ARGS∆DISPLAY_SHORT_HELP
  ⍞←"Try '",ARGS∆PROGRAM_NAME," -- +h' for more information\n"
  ⍞←"Try '",ARGS∆APL_PATH," --script ",ARGS∆PROGRAM_NAME," -- +h' for more information\n"
∇

⍝ Displays help information.
∇ARGS∆DISPLAY_HELP
  ⍞←"Usages:\n"
  ⍞←"  ",ARGS∆PROGRAM_NAME," -- [options...] [FILE...]\n"
  ⍞←"  ",ARGS∆APL_PATH," --script ",ARGS∆PROGRAM_NAME," -- [options...] [FILE...]\n"
  ⍞←"\n"
  ⍞←"Displays FILE contents (or input from stdin if no FILEs were specified) in\n"
  ⍞←"hexidecimal.\n"
  ⍞←"\n"
  ⍞←"Options:\n"
  ⍞←"  +h, ++help    display this help information.\n"
  ⍞←"  +v, ++version display version.\n"
  ⍞←"  +c, ++code-generator\n"
  ⍞←"    Outputs code to bake the data into a program. Expects a language as an\n"
  ⍞←"    argument. Supported Languages: c\n"
∇

⍝ Displays the version.
∇ARGS∆DISPLAY_VERSION
  ⍞←"ahd 0.1.4"
∇

⍝ Enables the code generator and tries to and set it to use the given language.
∇ARGS∆SET_CODE_GENERATOR_LANGUAGE LANGUAGE
  →("c"≡LANGUAGE) ⍴ LKNOWN_LANGUAGE
    ARGS∆DISPLAY_SHORT_HELP
    PANIC "language '",LANGUAGE,"' does not support code generation"
  LKNOWN_LANGUAGE:

  ARGS∆CODE_GENERATOR_LANGUAGE←LANGUAGE
  ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←0
∇

⍝ Parses a single character option (anything after a single "+") and updates
⍝ ARGS∆* accordingly.
∇ARGS∆PARSE_SHORT_OPTION OPTION
  →({OPTION≡⍵}¨'h' 'v' 'c') / LHELP LVERSION LCODE_GENERATOR
  LDEFAULT:
    ARGS∆DISPLAY_SHORT_HELP
    PANIC "unknown option '+",OPTION,"'"
  LHELP:           ARGS∆DISPLAY_HELP    ◊ ⍎")OFF"        ◊ →LSWITCH_END
  LVERSION:        ARGS∆DISPLAY_VERSION ◊ ⍎")OFF"        ◊ →LSWITCH_END
  LCODE_GENERATOR: ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←1 ◊ →LSWITCH_END
  LSWITCH_END:
∇

⍝ Parses a command line argument and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARG ARGUMENT
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
  LINVALID_LONG_OPTION:
    ARGS∆DISPLAY_SHORT_HELP
    PANIC "unknown option '",ARGUMENT,"'"
  LSHORT_OPTION:        ARGS∆PARSE_SHORT_OPTION¨ 1↓ARGUMENT   ◊ →LSWITCH_END
  LDOUBLE_PLUS:         ARGS∆END_OF_OPTIONS←1                 ◊ →LSWITCH_END
  LSET_CODE_GENERATOR_LANGUAGE:
    ARGS∆SET_CODE_GENERATOR_LANGUAGE ARGUMENT
    →LSWITCH_END
  LHELP:                ARGS∆DISPLAY_HELP                     ◊ →LSWITCH_END
  LVERSION:             ARGS∆DISPLAY_VERSION                  ◊ →LSWITCH_END
  LCODE_GENERATOR:      ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←1 ◊ →LSWITCH_END
  LSWITCH_END:
∇

⍝ Parses command line arguments and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS
  ⍝ ARGUMENTS looks like "apl --script <script> -- [user arguments...]".

  ARGS∆APL_PATH←↑ARGUMENTS[1]
  ARGS∆PROGRAM_NAME←↑ARGUMENTS[3]
  →(4≥≢ARGUMENTS) ⍴ LNO_ARGUMENTS
    ARGS∆PARSE_ARG¨ 4↓ARGUMENTS
  LNO_ARGUMENTS:

  ⍝ Tests for any options with arguments that were not supplied an argument.
  →(~ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE) ⍴ LNO_INVALID_OPTIONS
    ARGS∆DISPLAY_SHORT_HELP
    PANIC "options '+c' and '++code-generator' expect an argument"
  LNO_INVALID_OPTIONS:
∇



⍝ Converts a number into a uppercase-hexidecimal character vector.
⍝ →⍵ - the number.
⍝ →⍺ - the number of digits the resulting vector should have.
⍝ ←The character vector.
HEXIFY←{{⍵⌷"0123456789ABCDEF"}¨1+⍵⊤⍨⍺/16}

⍝ Returns whether the given byte is a displayable, non-control ASCII character.
⍝ →⍵ - a byte.
⍝ ←1 if the byte matches the criteria, else 0.
IS_DISPLAYABLE←{(126≥⍵)∧32≤⍵}


⍝ The bvte-value of a space character.
SPACE_BYTE←⎕UCS ' '



⍝ The number of bytes to print out per line.
HEXDUMP_BYTES_PER_LINE←16
⍝ The number of hexidecimal digits needed to represent a byte.
HEXDUMP_BYTE_DIGITS←2

⍝ Prints out a line of hexdump output of the byte vector.
⍝ →BYTE_VECTOR - the byte vector.
⍝ →OFFSET - the current line's byte offset.
∇OFFSET HEXDUMP_LINE BYTE_VECTOR
  ⍝ Offset.
  ⍞←7 HEXIFY OFFSET ◊ ⍞←":"
  ⍝ Bytes.
  ⊣ {⍞←HEXDUMP_BYTE_DIGITS HEXIFY ⍵ ⊣ ⍞←" "}¨ BYTE_VECTOR
  ⍝ Characters.
  ⍞←⎕UCS SPACE_BYTE/⍨(HEXDUMP_BYTE_DIGITS+1)×HEXDUMP_BYTES_PER_LINE-≢BYTE_VECTOR
  ⍞←" |"
  ⍞←⎕UCS {(SPACE_BYTE ⍵)⌷⍨1+ IS_DISPLAYABLE ⍵}¨ BYTE_VECTOR
  ⍞←"|\n"
∇

⍝ Prints out a hexdump.
⍝ →FILE_DESCRIPTOR - the file descriptor to generate the hexdump from.
∇HEXDUMP FILE_DESCRIPTOR; OFFSET;BYTE_VECTOR
  OFFSET←0

  LREAD_LOOP:
    BYTE_VECTOR←HEXDUMP_BYTES_PER_LINE FIO∆FREAD_SIZED FILE_DESCRIPTOR
    OFFSET HEXDUMP_LINE BYTE_VECTOR
    OFFSET←OFFSET+≢BYTE_VECTOR

    →(0≢FIO∆FEOF   FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →(0≢FIO∆FERROR FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →LREAD_LOOP
  LEND_READ_LOOP:
∇



⍝ Prints out a line of C code output of the byte vector.
⍝ →BYTE_VECTOR - the byte vector to print.
∇GENERATE_C_LINE BYTE_VECTOR
  ⍞←"    "
  ⊣ {⍞←", " ⊣ ⍞←⍵ ⊣ ⍞←"0x"}¨ 2 HEXIFY¨ BYTE_VECTOR
  ⍞←"\n"
∇

⍝ Prints out C code.
⍝ →FILE_DESCRIPTOR - the file descriptor to generate C from.
∇GENERATE_C FILE_DESCRIPTOR; BYTE_VECTOR;BYTE_COUNT
  BYTE_COUNT←0

  ⍞←"unsigned char data[] = {\n"
  LREAD_LOOP:
    BYTE_VECTOR←16 FIO∆FREAD_SIZED FILE_DESCRIPTOR
    BYTE_COUNT←BYTE_COUNT+≢BYTE_VECTOR
    GENERATE_C_LINE BYTE_VECTOR

    →(0≢FIO∆FEOF   FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →(0≢FIO∆FERROR FILE_DESCRIPTOR) ⍴ LEND_READ_LOOP
    →LREAD_LOOP
  LEND_READ_LOOP:
  ⍞←"};\n"

  ⍞←"unsigned int data_length = " ◊ ⍞←BYTE_COUNT ◊ ⍞←";\n"
∇



⍝ Handles printing the output of the given file descriptor (hexdump, code,
⍝ etc..).
⍝ →FILE_DESCRIPTOR - the file descriptor to read from. Will not be closed.
∇HANDLE_FD FILE_DESCRIPTOR
  ⍝ If a code generator is selected, we use that, else we just do a hexdump.
  →("c"≡ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LGENERATE_C
    →(0≡≢ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LNO_SET_LANGUAGE
      PANIC "HANDLE_FILE: unreachable"
    LNO_SET_LANGUAGE:

    HEXDUMP FILE_DESCRIPTOR
    →LSWITCH_END

  LGENERATE_C: GENERATE_C FILE_DESCRIPTOR ◊ →LSWITCH_END
  LSWITCH_END:

LREAD_ERROR:
∇

⍝ Handles printing the output of the given file (hexdump, code, etc..).
⍝ →PATH - the path of the file.
⍝ →PRINT_PATH - whether to print the path along with the output. A scalar 1
⍝ means print, 0 means don't.
⍝ ←IGNORE - magic return value so the function works in defuns.
∇IGNORE←PRINT_PATH HANDLE_FILE PATH; DESCRIPTOR
  →(~PRINT_PATH) ⍴ LDONT_PRINT_PATH
    ⍞←PATH,":\n"
  LDONT_PRINT_PATH:

  DESCRIPTOR←"r" FIO∆FOPEN PATH
  →(0<DESCRIPTOR) ⍴ LNO_READ_ERROR
    ERROR "failed to open file" ◊ →LREAD_ERROR
  LNO_READ_ERROR:

  HANDLE_FD DESCRIPTOR

LREAD_ERROR:
  IGNORE←⍬
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →(0≡≢ARGS∆FILENAMES) ⍴ LREAD_STDIN
  →(1≡≢ARGS∆FILENAMES) ⍴ LREAD_FILE
    ⍝ We only add the filenames when there are multiple fixes to output, to
    ⍝ differentiate them.
    ⊣ {1 HANDLE_FILE ⍵}¨ ARGS∆FILENAMES
    →LSWITCH_END
  LREAD_FILE:  ⊣ 0 HANDLE_FILE ↑ARGS∆FILENAMES ◊ →LSWITCH_END
  LREAD_STDIN: ⊣ HANDLE_FD FIO∆STDIN           ◊ →LSWITCH_END
  LSWITCH_END:
∇
MAIN



)OFF

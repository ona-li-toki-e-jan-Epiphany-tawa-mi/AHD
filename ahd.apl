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
  ⍞←"ahd 0.1.5"
∇

⍝ Enables the code generator and tries to and set it to use the given language.
∇ARGS∆SET_CODE_GENERATOR_LANGUAGE LANGUAGE
  →("c"≡LANGUAGE) ⍴ LKNOWN_LANGUAGE
    ARGS∆DISPLAY_SHORT_HELP
    ⊣ FIO∆STDERR FIO∆FPRINTF⍨ "ERROR: language '%s' does not support code generation\n" LANGUAGE
    ⍎")OFF 1"
  LKNOWN_LANGUAGE:

  ARGS∆CODE_GENERATOR_LANGUAGE←LANGUAGE
  ARGS∆EXPECT_CODE_GENERATOR_LANGUAGE←0
∇

⍝ Parses a single character option (anything after a single "+") and updates
⍝ ARGS∆* accordingly.
∇ARGS∆PARSE_SHORT_OPTION OPTION
  →(OPTION≡¨'h' 'v' 'c') / LHELP LVERSION LCODE_GENERATOR
  LDEFAULT:
    ARGS∆DISPLAY_SHORT_HELP
    ⊣ FIO∆STDERR FIO∆FPRINTF⍨ "ERROR: unknown option +'%s'\n" OPTION
    ⍎")OFF 1"
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
  →((⊂ARGUMENT)⍷"++help" "++version" "++code-generator") / LHELP LVERSION LCODE_GENERATOR
  ⍝ Jumps to error print if ARGUMENT is an unknown long option.
  →("++"≡2↑ARGUMENT) ⍴ LINVALID_LONG_OPTION
  LDEFAULT:
  LFILE:
    ⍝ Anything leftover is a file.
    ARGS∆FILENAMES←ARGS∆FILENAMES,⊂ARGUMENT
    →LSWITCH_END
  LINVALID_LONG_OPTION:
    ARGS∆DISPLAY_SHORT_HELP
    ⊣ FIO∆STDERR FIO∆FPRINTF⍨ "ERROR: unknown option '%s'\n" ARGUMENT
    ⍎")OFF 1"
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
    ⊣ FIO∆STDERR FIO∆WRITE_FD⍨ FIO∆UTF8_TO_BYTES "ERROR: options '+c' and '++code-generator' expect an argument\n"
    ⍎")OFF 1"
  LNO_INVALID_OPTIONS:
∇



⍝ Converts a number into a uppercase-hexidecimal character vector.
⍝ →N - the number.
⍝ →DIGITS - the number of digits the resulting vector should have.
⍝ ←HEX - the character vector.
∇HEX←DIGITS HEXIFY N
  HEX←"0123456789ABCDEF"[1+N⊤⍨DIGITS/16]
∇

⍝ Returns whether the given byte is a displayable, non-control ASCII character.
⍝ →⍵ - a byte.
⍝ ←1 if the byte matches the criteria, else 0.
∇RESULT←IS_DISPLAYABLE BYTE
  RESULT←(126≥BYTE)∧32≤BYTE
∇

⍝ The bvte-value of a space character.
SPACE_BYTE←⎕UCS " "



⍝ The number of bytes to print out per line.
HEXDUMP_BYTES_PER_LINE←16
⍝ The number of hexidecimal digits needed to represent a byte.
HEXDUMP_BYTE_DIGITS←2

⍝ Prints out a hexdump.
⍝ →FD - the file descriptor to generate the hexdump from.
∇HEXDUMP FD; OFFSET;BYTES
  OFFSET←0

  LREAD_LOOP:
    BYTES←16 FIO∆READ_FD FD
    →(~↑BYTES) ⍴ LEND_READ_LOOP ◊ BYTES←↑1↓BYTES
    OFFSET HEXDUMP_LINE BYTES
    OFFSET←OFFSET+≢BYTES
    →LREAD_LOOP
  LEND_READ_LOOP:
∇
∇OFFSET HEXDUMP_LINE BYTES
  ⍝ Offset.
  ⊣ FIO∆PRINTF "%s:" (7 HEXIFY OFFSET)
  ⍝ Bytes.
  HEXDUMP_BYTE¨ BYTES
  ⍝ Characters.
  ⍞←⎕UCS SPACE_BYTE/⍨(HEXDUMP_BYTE_DIGITS+1)×HEXDUMP_BYTES_PER_LINE-≢BYTES
  ⍞←" |"
  ⍞←⎕UCS (SPACE_BYTE,BYTES)[1+(⍳⍨BYTES)×IS_DISPLAYABLE¨BYTES]
  ⍞←"|\n"
∇
∇HEXDUMP_BYTE BYTE
  ⊣ FIO∆PRINTF " %s" (HEXDUMP_BYTE_DIGITS HEXIFY BYTE)
∇



⍝ Prints out C code.
⍝ →FD - the file descriptor to generate C from.
∇GENERATE_C FD; BYTES;BYTE_COUNT
  BYTE_COUNT←0

  ⍞←"unsigned char data[] = {\n"
  LREAD_LOOP:
    BYTES←16 FIO∆READ_FD FD
    →(~↑BYTES) ⍴ LEND_READ_LOOP ◊ BYTES←↑1↓BYTES
    BYTE_COUNT←BYTE_COUNT+≢BYTES
    GENERATE_C_LINE BYTES
    →LREAD_LOOP
  LEND_READ_LOOP:
  ⍞←"};\n"

  ⍞←"unsigned int data_length = " ◊ ⍞←BYTE_COUNT ◊ ⍞←";\n"
∇
∇GENERATE_C_LINE BYTES
  ⍞←"    "
  GENERATE_C_BYTE¨ 2 HEXIFY¨ BYTES
  ⍞←"\n"
∇
∇GENERATE_C_BYTE BYTE
  ⊣ FIO∆PRINTF "0x%s, " BYTE
∇



⍝ Handles printing the output of the given file descriptor (hexdump, code,
⍝ etc..).
⍝ →FD - the file descriptor to read from. Will not be closed.
∇HANDLE_FD FD
  ⍝ If a code generator is selected, we use that, else we just do a hexdump.
  →("c"≡ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LGENERATE_C
    →(0≡≢ARGS∆CODE_GENERATOR_LANGUAGE) ⍴ LNO_SET_LANGUAGE
      ⊣ FIO∆STDERR FIO∆FPRINTF⍨ "ERROR: HANDLE_FILE: unhandled language '%s'\n" ARGS∆CODE_GENERATOR_LANGUAGE
      ⍎")OFF 1"
    LNO_SET_LANGUAGE:
    HEXDUMP FD               ◊ →LSWITCH_END
  LGENERATE_C: GENERATE_C FD ◊ →LSWITCH_END
  LSWITCH_END:

LREAD_ERROR:
∇

⍝ Handles printing the output of the given file (hexdump, code, etc..).
⍝ →PATH - the path of the file.
⍝ →PRINT_PATH - whether to print the path along with the output. A scalar 1
⍝ means print, 0 means don't.
∇PRINT_PATH HANDLE_FILE PATH; FD
  →(~PRINT_PATH) ⍴ LDONT_PRINT_PATH
    ⊣ FIO∆PRINTF "%s:\n" PATH
  LDONT_PRINT_PATH:

  FD←"r" FIO∆OPEN_FILE PATH ◊ →(↑FD) ⍴ LNO_READ_ERROR
    ⊣ FIO∆STDERR FIO∆FPRINTF⍨ "ERROR: Failed to open file '%s': %s\n" PATH (↑1↓FD)
    →LEND
  LNO_READ_ERROR:
  FD←↑1↓FD ◊ FIO∆DEFER "⊣ FIO∆CLOSE_FD FD"

  HANDLE_FD DESCRIPTOR

LEND:
  FIO∆DEFER_END
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →(0≡≢ARGS∆FILENAMES) ⍴ LREAD_STDIN
  →(1≡≢ARGS∆FILENAMES) ⍴ LREAD_FILE
    ⍝ We only add the filenames when there are multiple fixes to output, to
    ⍝ differentiate them.
    1 HANDLE_FILE¨ ARGS∆FILENAMES
    →LSWITCH_END
  LREAD_FILE:  ⊣ 0 HANDLE_FILE ↑ARGS∆FILENAMES ◊ →LSWITCH_END
  LREAD_STDIN: HANDLE_FD FIO∆STDIN             ◊ →LSWITCH_END
  LSWITCH_END:
∇
MAIN

)OFF

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

⍝ AHD integration testing script.



⊣ ⍎")COPY_ONCE fio.apl"



⍝ The path to the apl interpreter used to call this program.
ARGS∆APL_PATH←⍬
⍝ The name of this file/program.
ARGS∆PROGRAM_NAME←⍬
⍝ The action/subcommand to preform.
ARGS∆ACTION←⍬
⍝ The path of the sources folder.
ARGS∆SOURCES_FOLDER←⍬
⍝ The paths of the files in the sources folder.
ARGS∆SOURCES_FILENAMES←⍬
⍝ The name of the outputs folder.
ARGS∆OUTPUTS_FOLDER←⍬

⍝ TODO make accept FD.
⍝ Displays help information.
∇ARGS∆DISPLAY_HELP
  ⍞←"Usages:\n"
  ⍞←"  ",ARGS∆PROGRAM_NAME," -- (record|test) SOURCES OUTPUTS\n"
  ⍞←"  ",ARGS∆APL_PATH," --script ",ARGS∆PROGRAM_NAME," -- (record|test) SOURCES OUTPUTS\n"
  ⍞←"\n"
  ⍞←"Subcommand record:\n"
  ⍞←"  Run AHD on the files in the SOURCES directory and record the output into\n"
  ⍞←"  files in the OUTPUTS directory, overwriting existing files.\n"
  ⍞←"\n"
  ⍞←"  Note that the OUTPUTS directory will not be created if it doesn't exist.\n"
  ⍞←"\n"
  ⍞←"Subcommand test:\n"
  ⍞←"  Run AHD on the files in the SOURCES directory compare their output to\n"
  ⍞←"  files created by record in the OUTPUTS directory. If the outputs differ,\n"
  ⍞←"  error message will be printed out on stderr. I couldn't get exit error codes\n"
  ⍞←"  working right (GnuAPL amirite?,) so some external logic will be required.\n"
  ⍞←"\n"
  ⍞←"Note: this tool will not recurse through directories, so all files must be at\n"
  ⍞←"the top-level of the supplied directories."
∇

⍝ Parses command line arguments and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS
  ⍝ ARGUMENTS looks like "<apl path> --script <script> -- [user arguments...]"

  ARGS∆APL_PATH←↑ARGUMENTS[1]
  ARGS∆PROGRAM_NAME←↑ARGUMENTS[3]

  ⍝ 4 for APL and it's arguments.
  ⍝ 3 for user arguments.
  →((3+4)≤≢ARGUMENTS) ⍴ LSUFFICIENT_ARGUMENTS
    ⊣ FIO∆STDERR FIO∆PRINT_FD "ERROR: insufficient arguments\n"
    ARGS∆DISPLAY_HELP
    ⍎")OFF 1"
  LSUFFICIENT_ARGUMENTS:

  ARGS∆ACTION←↑ARGUMENTS[5]
  ARGS∆SOURCES_FOLDER←↑ARGUMENTS[6]
  ARGS∆OUTPUTS_FOLDER←↑ARGUMENTS[7]

  →((⊂ARGS∆ACTION)∊"record" "test") ⍴ LVALID_ACTION
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: invalid action '%s'\n" ARGS∆ACTION
    ARGS∆DISPLAY_HELP
    ⍎")OFF 1"
  LVALID_ACTION:

  ⍝ Checks if sources folder exists and gets filenames.
  ARGS∆SOURCES_FILENAMES←FIO∆LIST_DIRECTORY ARGS∆SOURCES_FOLDER
  →(↑ARGS∆SOURCES_FILENAMES) ⍴ LSOURCES_FOLDER_EXISTS
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: unable to read source folder '%s': %s\n" ARGS∆SOURCES_FOLDER (↑1↓ARGS∆SOURCES_FILENAMES)
    ⍎")OFF 1"
  LSOURCES_FOLDER_EXISTS:
  ARGS∆SOURCES_FILENAMES←↑1↓ARGS∆SOURCES_FILENAMES
∇



⍝ Opens, truncates, and writes data to a file.
⍝ →FILE_PATH - the file.
⍝ →BYTES - the data.
∇BYTES WRITE_FILE FILE_PATH; FD
  ⊣ FIO∆PRINTF "Writing to '%s'...\n" FILE_PATH

  FD←"w" FIO∆OPEN_FILE FILE_PATH
  →(↑FD) ⍴ LSUCCESS
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: failed to open file '%s' for writing: %s\n" FILE_PATH (↑1↓FD)
  LSUCCESS:
  FD←↑1↓FD
  ⊣ FD FIO∆WRITE_FD BYTES

  ⊣ FIO∆CLOSE_FD FD
∇

⍝ Performs an individual recording of a file.
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the source file path, 2 - the
⍝ output destination file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_RECORD FILE_PATHS; SOURCE_FILE;RECORDING_FILE
  SOURCE_FILE←↑FILE_PATHS[1]
  OUTPUT_FILE←↑FILE_PATHS[2]
  ⊣ FIO∆PRINTF "Record '%s' -> '%s'...\n" SOURCE_FILE OUTPUT_FILE

  OUTPUT_FILE WRITE_FILE⍨ RUN_AHD ARGUMENTS,⊂SOURCE_FILE
∇

⍝ Performs the "record" action of this testing script, running AHD and recording
⍝ the results.
⍝ →FILENAME - the file in the sources directory to record.
∇RECORD FILENAME; SOURCE_FILE;OUTPUT_FILE_BASE
  SOURCE_FILE←ARGS∆SOURCES_FOLDER FIO∆JOIN_PATH FILENAME
  OUTPUT_FILE_BASE←ARGS∆OUTPUTS_FOLDER FIO∆JOIN_PATH FILENAME

  ⍝ Records hexdump.
  ⍬ RUN_RECORD SOURCE_FILE (OUTPUT_FILE_BASE,".hex")
  ⍝ Records c code generator output.
  "+c" "c" RUN_RECORD SOURCE_FILE (OUTPUT_FILE_BASE,".h")

  ⍝ Output newline for a space between this and the next recording output.
  ⍞←"\n"
∇



⍝ Counters to show how many tests passed.
TEST_COUNT←0
PASSED_TEST_COUNT←0

⍝ The byte value of a newline.
NEWLINE_BYTE←⎕UCS "\n"

⍝ Performs an individual testing of a file.
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the source file path, 2 - the
⍝ output file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_TEST FILE_PATHS; SOURCE_FILE;OUTPUT_FILE;EXPECTED_RESULT_LINES;ACTUAL_RESULT_LINES;EXPECTED_RESULT_LINE;ACTUAL_RESULT_LINE;LINE_NUMBER
  TEST_COUNT←1+TEST_COUNT

  SOURCE_FILE←↑FILE_PATHS[1]
  OUTPUT_FILE←↑FILE_PATHS[2]
  ⊣ FIO∆PRINTF "Testing '%s' -> '%s'...\n" SOURCE_FILE OUTPUT_FILE

  ⍝ Reads in what we expect as nested lines.
  EXPECTED_RESULT_LINES←FIO∆READ_ENTIRE_FILE OUTPUT_FILE
  →(↑EXPECTED_RESULT_LINES) ⍴ LREAD_SUCCESS
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: unable to read file '%s': %s\n" OUTPUT_FILE (↑1↓EXPECTED_RESULT_LINES)
    ⍎")OFF 1"
  LREAD_SUCCESS:
  EXPECTED_RESULT_LINES←NEWLINE_BYTE FIO∆SPLIT ↑1↓EXPECTED_RESULT_LINES

  ⍝ Reads in what we got as nested lines.
  ACTUAL_RESULT_LINES←NEWLINE_BYTE FIO∆SPLIT RUN_AHD ARGUMENTS,⊂SOURCE_FILE

  ⍝ Check if line counts differ.
  →((≢EXPECTED_RESULT_LINES)≡≢ACTUAL_RESULT_LINES) ⍴ LSAME_LINE_COUNT
    ⊣ FIO∆STDERR FIO∆PRINT_FD "ERROR: line count of output from AHD differs in line count of expected results\n"
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "Got:      %d lines\n" (≢ACTUAL_RESULT_LINES)
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "Expected: %d lines\n" (≢EXPECTED_RESULT_LINES)
    ⊣ FIO∆STDERR FIO∆PRINT_FD "Test failed\n"
    →LFAILED
  LSAME_LINE_COUNT:

  LINE_NUMBER←1
  ⍝ Compare line-by-line.
  LCHECK_LOOP:
    →(LINE_NUMBER>≢EXPECTED_RESULT_LINES) ⍴ LCHECK_LOOP_END

    EXPECTED_RESULT_LINE←↑EXPECTED_RESULT_LINES[LINE_NUMBER]
    ACTUAL_RESULT_LINE←↑ACTUAL_RESULT_LINES[LINE_NUMBER]

    →(EXPECTED_RESULT_LINE≡ACTUAL_RESULT_LINE) ⍴ LEQUAL
      ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: Contents of AHD output differs from expected results on line %d\n" LINE_NUMBER
      ⊣ FIO∆STDERR FIO∆PRINTF_FD "Got:      '%s'\n" (FIO∆BYTES_TO_UTF8 ACTUAL_RESULT_LINE)
      ⊣ FIO∆STDERR FIO∆PRINTF_FD "Expected: '%s'\n" (FIO∆BYTES_TO_UTF8 EXPECTED_RESULT_LINE)
      ⊣ FIO∆STDERR FIO∆PRINT_FD "Test failed\n"
      →LFAILED
    LEQUAL:

    LINE_NUMBER←1+LINE_NUMBER
    →LCHECK_LOOP
  LCHECK_LOOP_END:

  ⍞←"Test passed\n"
  PASSED_TEST_COUNT←1+PASSED_TEST_COUNT

LFAILED:
  ⍝ Output newline for a space between this and the next test output.
  ⍞←"\n"
∇

⍝ Performs the "test" action of this testing script, running AHD and comparing
⍝ the results to what was previously recorded.
⍝ →FILENAME - the file in the sources directory to test.
∇TEST FILENAME; SOURCE_FILE;OUTPUT_FILE_BASE
  SOURCE_FILE←ARGS∆SOURCES_FOLDER FIO∆JOIN_PATH FILENAME
  OUTPUT_FILE_BASE←ARGS∆OUTPUTS_FOLDER FIO∆JOIN_PATH FILENAME

  ⍝ Tests hexdump.
  ⍬ RUN_TEST SOURCE_FILE (OUTPUT_FILE_BASE,".hex")
  ⍝ Tests c code generator output.
  "+c" "c" RUN_TEST SOURCE_FILE (OUTPUT_FILE_BASE,".h")
∇



⍝ Spawns an instance of AHD.
⍝ →ARGUMENTS - a vector of character vectors of the arguments to pass to AHD.
⍝ ←The resulting output.
∇OUTPUT←RUN_AHD ARGUMENTS; AHD_FD;COMMAND;CURRENT_TIME_MS
  COMMAND←ARGUMENTS,⍨ARGS∆APL_PATH "--script" "ahd.apl" "--"
  ⊣ FIO∆PRINTF "Running '%s'...\n" (↑FIO∆JOIN_SHELL_ARGUMENTS/ COMMAND)

  CURRENT_TIME_MS←↑1↓FIO∆TIME_MS

  AHD_FD←FIO∆POPEN_READ COMMAND
  →(↑AHD_FD) ⍴ LSUCCESS
    ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: failed to launch AHD: %s\n" (↑1↓AHD_FD)
    ⍎")OFF 1"
  LSUCCESS:
  AHD_FD←↑1↓AHD_FD
  OUTPUT←↑1↓FIO∆READ_ENTIRE_FD AHD_FD
  ⊣ FIO∆PCLOSE AHD_FD

  ⊣ FIO∆PRINTF "AHD took %.2f seconds\n" (1000÷⍨CURRENT_TIME_MS-⍨↑1↓FIO∆TIME_MS)
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →((⊂ARGS∆ACTION)⍷"record" "test") / LRECORD LTEST
    ⊣ FIO∆STDERR FIO∆PRINT_FD "ERROR: MAIN: unreachable\n"
    ⍎")OFF 1"
  LRECORD:
    ⍝ TODO check status
    ⊣ 7 5 5 FIO∆MAKE_DIRECTORIES ARGS∆OUTPUTS_FOLDER

    RECORD¨ARGS∆SOURCES_FILENAMES
    ⍞←"Recording complete\n"
    →LSWITCH_END
  LTEST:
    →(↑FIO∆LIST_DIRECTORY ARGS∆OUTPUTS_FOLDER) ⍴ LOUTPUTS_DIRECTORY_EXISTS
      ⊣ FIO∆STDERR FIO∆PRINTF_FD "ERROR: outputs folder '%s' does not exist\n" ARGS∆OUTPUTS_FOLDER
      ⍎")OFF 1"
    LOUTPUTS_DIRECTORY_EXISTS:

    TEST¨ARGS∆SOURCES_FILENAMES
    ⊣ FIO∆PRINTF "%d/%d tests passed - " PASSED_TEST_COUNT TEST_COUNT
    →(PASSED_TEST_COUNT≡TEST_COUNT) ⍴ LALL_TESTS_PASSED
      ⍞←"FAIL\n" ◊ →LTESTS_FAILED
    LALL_TESTS_PASSED: ⍞←"OK\n"
    LTESTS_FAILED:
    →LSWITCH_END
  LSWITCH_END:
∇
MAIN

)OFF

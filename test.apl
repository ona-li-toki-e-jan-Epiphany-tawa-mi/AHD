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


⍝ ⎕FIO functions abstraction layer.
⊣ ⍎")COPY_ONCE fio.apl"



⍝ Displays an error message.
∇ERROR MESSAGE
  ⊣ FIO∆STDERR FIO∆FWRITE_CVECTOR⍨ "error: ",MESSAGE,"\n"
∇

⍝ Displays an error message and exits.
∇PANIC MESSAGE
  ⊣ FIO∆STDERR FIO∆FWRITE_CVECTOR⍨ "fatal: ",MESSAGE,"\n"
  ⍎")OFF"
∇



⍝ The path to the apl interpreter used to call this program.
ARGS∆APL_PATH←⍬
⍝ The name of this file/program.
ARGS∆PROGRAM_NAME←⍬
⍝ The action/subcommand to preform.
ARGS∆ACTION←⍬
⍝ The names of the examples folder.
ARGS∆EXAMPLES_FOLDER←⍬
⍝ The names of the files in the examples folder.
ARGS∆EXAMPLES_FILENAMES←⍬
⍝ The name of the recordings folder.
ARGS∆RECORDINGS_FOLDER←⍬

⍝ Displays help information.
∇ARGS∆DISPLAY_HELP
  ⍞←"Usages:\n"
  ⍞←"  ",ARGS∆PROGRAM_NAME," -- (record|test) EXAMPLES RECORDINGS\n"
  ⍞←"  ",ARGS∆APL_PATH," --script ",ARGS∆PROGRAM_NAME," -- (record|test) EXAMPLES RECORDINGS\n"
  ⍞←"\n"
  ⍞←"Subcommand record:\n"
  ⍞←"  Run AHD on the files in the EXAMPLES directory and record the output into\n"
  ⍞←"  files in the RECORDINGS directory, overwriting existing files.\n"
  ⍞←"\n"
  ⍞←"  Note that the RECORDINGS directory will not be created if it doesn't exist.\n"
  ⍞←"\n"
  ⍞←"Subcommand test:\n"
  ⍞←"  Run AHD on the files in the EXAMPLES directory compare their output to\n"
  ⍞←"  files created by record in the RECORDINGS directory. If the outputs differ,\n"
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
    ARGS∆DISPLAY_HELP
    ⍞←"\n" ◊ PANIC "insufficient arguments"
  LSUFFICIENT_ARGUMENTS:

  ARGS∆ACTION←↑ARGUMENTS[5]
  ARGS∆EXAMPLES_FOLDER←↑ARGUMENTS[6]
  ARGS∆RECORDINGS_FOLDER←↑ARGUMENTS[7]

  →((⊂ARGS∆ACTION)∊"record" "test") ⍴ LVALID_ACTION
    ARGS∆DISPLAY_HELP
    ⍞←"\n" ◊ PANIC "invalid action '",ARGS∆ACTION,"'"
  LVALID_ACTION:

  ⍝ Checks if examples folder exists and gets filenames.
  ARGS∆EXAMPLES_FILENAMES←FIO∆LIST_DIRECTORY ARGS∆EXAMPLES_FOLDER
  →(¯2≢ARGS∆EXAMPLES_FILENAMES) ⍴ LEXAMPLES_FOLDER_EXISTS
    PANIC "examples folder '",ARGS∆EXAMPLES_FOLDER,"' does not exist"
  LEXAMPLES_FOLDER_EXISTS:
∇



⍝ Opens, truncates, and writes data to a file.
⍝ →FILE_PATH - the file.
⍝ →BYTE_VECTOR - the data.
∇BYTE_VECTOR WRITE_FILE FILE_PATH; FILE_DESCRIPTOR
  ⍞←"Writing to '",FILE_PATH,"'\n"

  FILE_DESCRIPTOR←"w" FIO∆FOPEN FILE_PATH
  →(0<FILE_DESCRIPTOR) ⍴ LSUCCESS
    PANIC "failed to open file '",FILE_PATH,"' for writing"
  LSUCCESS:
  ⊣ BYTE_VECTOR FIO∆FWRITE FILE_DESCRIPTOR

  ⊣ FIO∆FCLOSE FILE_DESCRIPTOR
∇

⍝ Performs an individual recording of a file.
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the example file path, 2 - the
⍝ recording destination file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_RECORD FILE_PATHS; EXAMPLE_FILE;RECORDING_FILE
  EXAMPLE_FILE←↑FILE_PATHS[1]
  RECORDING_FILE←↑FILE_PATHS[2]
  ⍞←"Recording ",EXAMPLE_FILE," -> ",RECORDING_FILE,"\n"

  RECORDING_FILE WRITE_FILE⍨ RUN_AHD ARGUMENTS,⊂EXAMPLE_FILE
∇

⍝ Performs the "record" action of this testing script, running AHD and recording
⍝ the results.
⍝ →FILENAME - the file in the examples directory to record.
∇RECORD FILENAME; EXAMPLE_FILE;RECORDING_FILE_BASE
  EXAMPLE_FILE←ARGS∆EXAMPLES_FOLDER,"/",FILENAME
  RECORDING_FILE_BASE←ARGS∆RECORDINGS_FOLDER,"/",FILENAME

  ⍝ Records hexdump.
  ⍬ RUN_RECORD EXAMPLE_FILE (RECORDING_FILE_BASE,".hex")
  ⍝ Records c code generator output.
  "+c" "c" RUN_RECORD EXAMPLE_FILE (RECORDING_FILE_BASE,".h")
∇



⍝ Performs an individual testing of a file.
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the example file path, 2 - the
⍝ recording file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_TEST FILE_PATHS; EXAMPLE_FILE;RECORDING_FILE;EXPECTED_RESULT
  EXAMPLE_FILE←↑FILE_PATHS[1]
  RECORDING_FILE←↑FILE_PATHS[2]
  ⍞←"Testing ",EXAMPLE_FILE," -> ",RECORDING_FILE,"\n"

  EXPECTED_RESULT←FIO∆READ_ENTIRE_FILE RECORDING_FILE
  →(¯2≢EXPECTED_RESULT) ⍴ LREAD_SUCCESS
    PANIC "unable to read file '",RECORDING_FILE,"'"
  LREAD_SUCCESS:

  →(EXPECTED_RESULT≡ RUN_AHD ARGUMENTS,⊂EXAMPLE_FILE) ⍴ LTEST_PASS
    ERROR "output from AHD on '",EXAMPLE_FILE,"' differs from contents of '",RECORDING_FILE,"'"
    →LTEST_END
  LTEST_PASS:
    ⍞←"Test passed\n" ◊ →LTEST_END
  LTEST_END:
∇

⍝ TODO Output line contents for user to see.
⍝ Performs the "test" action of this testing script, running AHD and comparing
⍝ the results to what was previously recorded.
⍝ →FILENAME - the file in the examples directory to test.
∇TEST FILENAME; EXAMPLE_FILE;RECORDING_FILE_BASE
  EXAMPLE_FILE←ARGS∆EXAMPLES_FOLDER,"/",FILENAME
  RECORDING_FILE_BASE←ARGS∆RECORDINGS_FOLDER,"/",FILENAME

  ⍝ Tests hexdump.
  ⍬ RUN_TEST EXAMPLE_FILE (RECORDING_FILE_BASE,".hex")
  ⍝ Tests c code generator output.
  "+c" "c" RUN_TEST EXAMPLE_FILE (RECORDING_FILE_BASE,".h")
∇



⍝ Spawns an instance of AHD.
⍝ →ARGUMENTS - a vector of character vectors of the arguments to pass to AHD.
⍝ ←The resulting output.
∇OUTPUT←RUN_AHD ARGUMENTS; AHD_FD;COMMAND
  COMMAND←ARGS∆APL_PATH," --script ahd.apl -- ",↑{⍺," ",⍵}/ARGUMENTS
  ⍞←"Running '",COMMAND,"'\n"

  AHD_FD←FIO∆POPEN_READ COMMAND
  →(0≢AHD_FD) ⍴ LSUCCESS
    PANIC "failed to launch AHD"
  LSUCCESS:

  OUTPUT←FIO∆READ_ENTIRE_FD AHD_FD

  ⊣ FIO∆PCLOSE AHD_FD
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →({ARGS∆ACTION≡⍵}¨"record" "test") / LRECORD LTEST
    PANIC "unreachable"
  LRECORD: RECORD¨ARGS∆EXAMPLES_FILENAMES ◊ →LSWITCH_END
  LTEST:   TEST¨ARGS∆EXAMPLES_FILENAMES   ◊ →LSWITCH_END
  LSWITCH_END:
∇
MAIN



)OFF

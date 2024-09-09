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
⊣ ⍎")COPY_ONCE logging.apl"



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
    ARGS∆DISPLAY_HELP
    ⍞←"\n" ◊ PANIC "insufficient arguments"
  LSUFFICIENT_ARGUMENTS:

  ARGS∆ACTION←↑ARGUMENTS[5]
  ARGS∆SOURCES_FOLDER←↑ARGUMENTS[6]
  ARGS∆OUTPUTS_FOLDER←↑ARGUMENTS[7]

  →((⊂ARGS∆ACTION)∊"record" "test") ⍴ LVALID_ACTION
    ARGS∆DISPLAY_HELP
    ⍞←"\n" ◊ PANIC "invalid action '",ARGS∆ACTION,"'"
  LVALID_ACTION:

  ⍝ Checks if sources folder exists and gets filenames.
  ARGS∆SOURCES_FILENAMES←FIO∆LIST_DIRECTORY ARGS∆SOURCES_FOLDER
  →(¯2≢ARGS∆SOURCES_FILENAMES) ⍴ LSOURCES_FOLDER_EXISTS
    PANIC "sources folder '",ARGS∆SOURCES_FOLDER,"' does not exist"
  LSOURCES_FOLDER_EXISTS:
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
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the source file path, 2 - the
⍝ output destination file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_RECORD FILE_PATHS; SOURCE_FILE;RECORDING_FILE
  SOURCE_FILE←↑FILE_PATHS[1]
  OUTPUT_FILE←↑FILE_PATHS[2]
  ⍞←"Recording '",SOURCE_FILE,"' -> '",OUTPUT_FILE,"'\n"

  OUTPUT_FILE WRITE_FILE⍨ RUN_AHD ARGUMENTS,⊂SOURCE_FILE
∇

⍝ Performs the "record" action of this testing script, running AHD and recording
⍝ the results.
⍝ →FILENAME - the file in the sources directory to record.
∇RECORD FILENAME; SOURCE_FILE;OUTPUT_FILE_BASE
  SOURCE_FILE←ARGS∆SOURCES_FOLDER,"/",FILENAME
  OUTPUT_FILE_BASE←ARGS∆OUTPUTS_FOLDER,"/",FILENAME

  ⍝ Records hexdump.
  ⍬ RUN_RECORD SOURCE_FILE (OUTPUT_FILE_BASE,".hex")
  ⍝ Records c code generator output.
  "+c" "c" RUN_RECORD SOURCE_FILE (OUTPUT_FILE_BASE,".h")
∇



⍝ Performs an individual testing of a file.
⍝ →FILE_PATHS - a 2-element nested vector of: 1 - the source file path, 2 - the
⍝ output file path.
⍝ →ARGUMENTS - a nested vector of additional arguments to pass to AHD.
∇ARGUMENTS RUN_TEST FILE_PATHS; SOURCE_FILE;OUTPUT_FILE;EXPECTED_RESULT
  SOURCE_FILE←↑FILE_PATHS[1]
  OUTPUT_FILE←↑FILE_PATHS[2]
  ⍞←"Testing '",SOURCE_FILE,"' -> '",OUTPUT_FILE,"'\n"

  EXPECTED_RESULT←FIO∆READ_ENTIRE_FILE OUTPUT_FILE
  →(¯2≢EXPECTED_RESULT) ⍴ LREAD_SUCCESS
    PANIC "unable to read file '",OUTPUT_FILE,"'"
  LREAD_SUCCESS:

  →(EXPECTED_RESULT≡ RUN_AHD ARGUMENTS,⊂SOURCE_FILE) ⍴ LTEST_PASS
    ERROR "output from AHD on '",SOURCE_FILE,"' differs from contents of '",OUTPUT_FILE,"'"
    →LTEST_END
  LTEST_PASS:
    ⍞←"Test passed\n" ◊ →LTEST_END
  LTEST_END:
∇

⍝ TODO Output line contents for user to see.
⍝ Performs the "test" action of this testing script, running AHD and comparing
⍝ the results to what was previously recorded.
⍝ →FILENAME - the file in the sources directory to test.
∇TEST FILENAME; SOURCE_FILE;OUTPUT_FILE_BASE
  SOURCE_FILE←ARGS∆SOURCES_FOLDER,"/",FILENAME
  OUTPUT_FILE_BASE←ARGS∆OUTPUTS_FOLDER,"/",FILENAME

  ⍝ Tests hexdump.
  ⍬ RUN_TEST SOURCE_FILE (OUTPUT_FILE_BASE,".hex")
  ⍝ Tests c code generator output.
  "+c" "c" RUN_TEST SOURCE_FILE (OUTPUT_FILE_BASE,".h")
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
    PANIC "MAIN: unreachable"
  LRECORD: RECORD¨ARGS∆SOURCES_FILENAMES ◊ →LSWITCH_END
  LTEST:   TEST¨ARGS∆SOURCES_FILENAMES   ◊ →LSWITCH_END
  LTEST:
    →(FIO∆IS_DIRECTORY ARGS∆OUTPUTS_FOLDER) ⍴ LOUTPUTS_DIRECTORY_EXISTS
      PANIC "outputs folder '",ARGS∆OUTPUTS_FOLDER,"' does not exist"
    LOUTPUTS_DIRECTORY_EXISTS:
    TEST¨ARGS∆SOURCES_FILENAMES
    →LSWITCH_END
  LSWITCH_END:
∇
MAIN



)OFF

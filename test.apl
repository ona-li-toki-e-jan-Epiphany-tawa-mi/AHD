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



⍝ TODO Abstract out FIO stuff to separate file.
⍝ Zn ←    ⎕FIO[29] Bs    return file names in directory Bs
⍝ Returns the names of the files and directories in the given directory.
FIO∆LIST_DIRECTORY←{⎕FIO[29] ⍵}
⍝ Zh ← As ⎕FIO[ 3] Bs    fopen(Bs, As) filename Bs mode As
⍝ Opens a file with fopen.
⍝ →⍺ - mode (i.e. "w", "r+", etc..)
⍝ →⍵ - file path.
⍝ ←The file descriptor.
FIO∆FOPEN←{⍺ ⎕FIO[3] ⍵}
⍝ Ze ←    ⎕FIO[ 4] Bh    fclose(Bh)
⍝ Closes a file descriptor.
⍝ →⍵ - file descriptor.
⍝ ←Error code.
FIO∆FCLOSE←{⎕FIO[4] ⍵}
⍝ Writes to a file descriptor.
⍝ →⍵ - file descriptor.
⍝ →⍺ - data as byte vector.
FIO∆FWRITE←{⍺ ⎕FIO[7] ⍵}
⍝ Returns non-zero if EOF was reached for the file descriptor.
FIO∆FEOF←{⎕FIO[10] ⍵}
⍝ Returns non-zero if an error ocurred reading file descriptor.
FIO∆FERROR←{⎕FIO[11] ⍵}
⍝ Reads up to 5,000 bytes in from the file descriptor as a byte vector.
FIO∆FREAD←{⎕FIO[6] ⍵}
⍝ Starts the given process and returns a read-only file descriptor representing
⍝ the output.
FIO∆POPEN_READ←{⎕FIO[24] ⍵}
⍝ Closes a file descripter opened with FIO∆POPEN_READ.
⍝ →⍵ - process file descriptor.
⍝ ←Error code.
FIO∆PCLOSE←{⎕FIO[25] ⍵}

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



⍝ TODO use '⊣ MESSAGE ⎕FIO[23] 2' (where 2 ≡ stderr)
⍝ Displays an error message.
∇ERROR MESSAGE
  ⎕←"error: ",MESSAGE
∇

⍝ Displays an error message and exits.
∇PANIC MESSAGE
  ⎕←"fatal: ",MESSAGE
  ⍎")OFF"
∇



⍝ The path to the apl interpreter used to call this program.
ARGS∆APL_PATH←⍬
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
  ⍞←"  ./test.apl (record|test) EXAMPLES RECORDINGS\n"
  ⍞←"  ./apl --script test.apl -- (record|test) EXAMPLES RECORDINGS\n"
  ⍞←"\n"
  ⍞←"record:\n"
  ⍞←"  Run AHD on the files in the EXAMPLES directory and record the output into\n"
  ⍞←"  files in the RECORDINGS directory, overwriting existing files.\n"
  ⍞←"\n"
  ⍞←"test:\n"
  ⍞←"  Run AHD on the files in the EXAMPLES directory compare their output to\n"
  ⍞←"  files created by record in the RECORDINGS directory. If the outputs differ,\n"
  ⍞←"  error message will be printed out. I couldn't get exit error codes or\n"
  ⍞←"  stderr printing working right (GnuAPL amirite?,) so some parsing will be\n"
  ⍞←"  required."
∇

⍝ Parses command line arguments and updates ARGS∆* accordingly.
∇ARGS∆PARSE_ARGS ARGUMENTS; USER_ARGUMENTS
  ARGS∆APL_PATH←↑ARGUMENTS[1]

  ⍝ ⎕ARG looks like "apl --script <script> --" plus whatever the user put.
  →((3+4)≤≢ARGUMENTS) ⍴ LSUFFICIENT_ARGUMENTS
    ARGS∆DISPLAY_HELP
    ⍞←"\n" ◊ PANIC "insufficient arguments"
  LSUFFICIENT_ARGUMENTS:

  USER_ARGUMENTS←4↓ARGUMENTS
  ARGS∆ACTION           ←↑USER_ARGUMENTS ◊ USER_ARGUMENTS←1↓USER_ARGUMENTS
  ARGS∆EXAMPLES_FOLDER  ←↑USER_ARGUMENTS ◊ USER_ARGUMENTS←1↓USER_ARGUMENTS
  ARGS∆RECORDINGS_FOLDER←↑USER_ARGUMENTS

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



⍝ Spawns an instance of AHD.
⍝ →ARGUMENTS - a vector of character vectors of the arguments to pass to AHD.
⍝ ←The resulting output.
∇OUTPUT←RUN_AHD ARGUMENTS; AHD_FD
  ⍝ TODO check if popen failed.
  AHD_FD←FIO∆POPEN_READ ARGS∆APL_PATH," --script ahd.apl -- ",↑{⍺," ",⍵}/ARGUMENTS
  OUTPUT←FIO∆READ_ENTIRE_FD AHD_FD
  ⊣ FIO∆PCLOSE AHD_FD
∇

⍝ Opens, truncates, and writes data to a file.
⍝ →FILE_PATH - the file.
⍝ →BYTE_VECTOR - the data.
∇BYTE_VECTOR WRITE_FILE FILE_PATH; FILE_DESCRIPTOR
  ⍝ TODO check if fopen failed.
  FILE_DESCRIPTOR←"w" FIO∆FOPEN FILE_PATH
  ⊣ BYTE_VECTOR FIO∆FWRITE FILE_DESCRIPTOR
  ⊣ FIO∆FCLOSE FILE_DESCRIPTOR
∇

⍝ Performs the "record" action of this testing script, running AHD and recording
⍝ the results.
⍝ →FILENAME - the file to record.
∇RECORD FILENAME; EXAMPLE_FILE;RECORDING_FILE_BASE;RECORDING_FILE_HEX;RECORDING_FILE_C_CODE
  EXAMPLE_FILE←ARGS∆EXAMPLES_FOLDER,"/",FILENAME
  RECORDING_FILE_BASE←ARGS∆RECORDINGS_FOLDER,"/",FILENAME

  ⍝ Records hexdump.
  RECORDING_FILE_HEX←RECORDING_FILE_BASE,".hex"
  ⍞←"Recording ",EXAMPLE_FILE," -> ",RECORDING_FILE_HEX,"\n"
  RECORDING_FILE_HEX WRITE_FILE⍨ RUN_AHD ⊂EXAMPLE_FILE

  ⍝ Records c code generator output.
  RECORDING_FILE_C_CODE←RECORDING_FILE_BASE,".h"
  ⍞←"Recording ",EXAMPLE_FILE," -> ",RECORDING_FILE_C_CODE," with '+c c'\n"
  RECORDING_FILE_C_CODE WRITE_FILE⍨ RUN_AHD "+c c" EXAMPLE_FILE
∇

∇TEST FILENAME
  ⍝ TODO
∇

∇MAIN
  ARGS∆PARSE_ARGS ⎕ARG

  →({ARGS∆ACTION≡⍵}¨"record" "test") / LRECORD LTEST
    PANIC "unreachable"
  LRECORD: RECORD¨ARGS∆EXAMPLES_FILENAMES
  LTEST:   TEST¨ARGS∆EXAMPLES_FILENAMES
∇
MAIN



)OFF

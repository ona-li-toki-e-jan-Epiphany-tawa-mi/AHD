#!/usr/bin/env bqn

# This file is part of AHD.
#
# Copyright (c) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi
#
# AHD is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# AHD is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# AHD. If not, see <https://www.gnu.org/licenses/>.

# AHD - A HexDumper. Hex dump utility.

################################################################################
# Utilities                                                                    #
################################################################################

# Converts a number to it's uppercase hexidecimal representation as a string of
# a specified length, left-padding with zeros.
# 𝕩: number - to convert.
# 𝕨: number - length.
# ←: string.
Hexify ← (⥊⟜16)⊸{"0123456789ABCDEF"⊏˜𝕨|⌊÷`⌾⌽𝕨«˜<𝕩}

# Splits a list into groups of a specified size. Leftover data that could not
# fit in will be placed into the last group.
# 𝕩: list.
# 𝕨: number - size.
# ←: list of lists.
GroupEvery ← {𝕩⊔˜⌊𝕨÷˜↕≠𝕩}

################################################################################
# Hexdump Generator                                                            #
################################################################################

hexdumpBytesPerLine ← 16

# Pairs each element in a list with a number starting at 0 and increasing by n
# for it's index (i.e. ⟨⟨0,'a'⟩,⟨5,'b'⟩,⟨10,'c'⟩⟩ ← 5 𝕊 "abc").
# 𝕩: list.
# 𝕨: number - step.
# ←: number⋈element list.
EnumerateBy ← {𝕩⋈¨˜𝕨×↕≠𝕩}

# Returns whether the given number(s), converted to character(s), represent
# printable ASCII.
# 𝕩: number or number list.
# ←: boolean or boolean list.
IsDisplayable ← (32⊸≤)∧(126⊸≥)

# Prints out a hexdump of the given bytes.
# 𝕩: number list, where 0≤number≤255.
Hexdump ← {
    lineNumberString ← 7 Hexify ⊑𝕩
    bytesHexString ← ∾⟜(' '⥊˜(3×hexdumpBytesPerLine)-≠)∾(' '∾2⊸Hexify)¨1⊑𝕩
    bytesCharacterString ← @+IsDisplayable◶⟨' '-@,⊢⟩¨1⊑𝕩

    •Out lineNumberString ∾ ':' ∾ bytesHexString ∾ " |" ∾ bytesCharacterString ∾ "|"
}¨ hexdumpBytesPerLine EnumerateBy hexdumpBytesPerLine⊸GroupEvery

################################################################################
# C Code Generator                                                             #
################################################################################

cBytesPerLine ← 12

# Prints out code in C for embedding the given bytes in a program.
# 𝕩: number list, where 0≤number≤255.
GenerateC ← {
    dataLength ← 0

    •Out "unsigned char data[] = {"
    {
        dataLength +↩ ≠𝕩
        •Out "   "∾∾(" 0x"∾','∾˜2⊸Hexify)¨𝕩
    }¨ cBytesPerLine GroupEvery 𝕩
    •Out "}"

    •Out "unsigned int data_length = "∾(•Fmt dataLength)∾";"
}

################################################################################
# BQN Code Generator                                                           #
################################################################################

bqnBytesPerLine ← 14

# Prints out code in BQN for embedding the given bytes in a program.
# 𝕩: number list, where 0≤number≤255.
GenerateBQN ← {
    •Out "data ← ⟨"
    (•Out∘("   "⊸∾∾)((' '⊸∾∾⟜',')•Fmt)¨)¨ bqnBytesPerLine GroupEvery 𝕩
    •Out "⟩"
}

################################################################################
# Command Line Interface                                                       #
################################################################################

help ← "Usage:
  "∾•name∾" [options...] [FILE]

Displays FILE contents in hexidecimal.

If FILE is not specified, reads input from stdin.

Options:
  -h, --help      display this help information and exits.
  -v, --version   display version and exits.
  -l, --license   display license and exits.

  -c, --code-generator <langauge>
    Outputs code, instead of a hexdump, to bake the data into a program.
    Supported Languages: c, bqn"

version ← "ahd 0.1.6"

license ← "Copyright (C) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/.

Source (paltepuk):
  https://paltepuk.xyz/cgit/AHD.git/about/
  http://oytjumugnwsf4g72vemtamo72vfvgmp4lfsf6wmggcvba3qmcsta.b32.i2p/cgit/AHD.git/about/
  http://4blcq4arxhbkc77tfrtmy4pptf55gjbhlj32rbfyskl672v2plsmjcyd.onion/cgit/AHD.git/about/

Source (GitHub):,
  https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD/"

# Outputs an error message, some help information, and then exits.
# 𝕩: string - the error message.
Error ← {
    •Out "Error: "∾𝕩
    •Out "Try '"∾•name∾" --help' for more information"
    •Exit 1
}

# Argument parser code generator state.
# 𝕩: string list - remaining command line arguments.
ParseCodeGenerator ← {
    []: Error "--code-generator specified without argument" ⋄ •Exit 1 ;
    𝕩: ((1⊸↓){
        𝕨𝕊"c": codeGeneratorLanguage↩𝕩 ⋄ ParseArguments 𝕨 ;
        𝕨𝕊"bqn": codeGeneratorLanguage↩𝕩 ⋄ ParseArguments 𝕨 ;
        ·𝕊𝕩: Error "Unknown language '"∾𝕩∾"' specified with --code-generator"
    }⊑) 𝕩
}

# Attempts to set the file extracted from command line arguments.
# 𝕩: string.
SetFile ← {
    0≢file ? Error "Only one file may be specified but multiple were present" ;
    file ↩ 𝕩
}

# Argument parser post "--" argument file state.
# 𝕩: string list - remaining command line arguments.
ParseAllAsFiles ← {
    []: @ ;
    𝕩: (1⊸↓{
        𝕨𝕊[]: ParseAllAsFiles 𝕨 ;
        𝕨𝕊𝕩: SetFile 𝕩 ⋄ ParseAllAsFiles 𝕨
    }⊑) 𝕩
}

# Argument parser file state.
# 𝕩: string list - remaining command line arguments.
ParseFile ← {
    []: @ ;
    𝕩: (1⊸↓{
        𝕨𝕊[]: ParseArguments 𝕨 ;
        𝕨𝕊𝕩: SetFile 𝕩 ⋄ ParseArguments 𝕨
    }⊑) 𝕩
}

# Argument parser short options state.
# 𝕩: string - short options without leading '-'.
# 𝕨: string list - remaining command line arguments.
ParseShortOptions ← {
    ·𝕊[]: Error "ParseShortOptions: unreachable";
    𝕨𝕊𝕩: 𝕨 {
        ·𝕊'h'‿·: •Out help ⋄ •Exit 0 ;
        ·𝕊'v'‿·: •Out version ⋄ •Exit 0 ;
        ·𝕊'l'‿·: •Out license ⋄ •Exit 0 ;
        𝕨𝕊'c'‿[]: ParseCodeGenerator 𝕨;
        𝕨𝕊'c'‿rest: ParseCodeGenerator 𝕨∾˜<rest
    } (⊑⋈1⊸↓) 𝕩
}

# Recursively parses a list of command line arguments with a finite state
# machine.
# 𝕩: string list - remaining command line arguments.
ParseArguments ← {
    []: @ ;
    𝕩: (1⊸↓{
        ·𝕊[]: ParseArguments 𝕨 ;
        ·𝕊"--help": •Out help ⋄ •Exit 0 ;
        ·𝕊"--version": •Out version ⋄ •Exit 0 ;
        ·𝕊"--license": •Out license ⋄ •Exit 0 ;
        𝕨𝕊"--code-generator": ParseCodeGenerator 𝕨 ;
        𝕨𝕊"--": ParseAllAsFiles 𝕨 ;
        𝕨𝕊"-": ParseFile 𝕨∾˜<𝕩 ;
        𝕨𝕊𝕩: "--"≡2↑𝕩 ? Error "Unknown option '"∾𝕩∾"'"
            ; '-'≡⊑𝕩 ? 𝕨 ParseShortOptions 1↓𝕩
            ; ParseFile 𝕨∾˜<𝕩
    }⊑) 𝕩
}

# Returns the contents of a file as bytes.
# 𝕩: string - file name.
# ←: number list.
ReadFileBytes ← @-˜•file.MapBytes

# Returns the contents of stdin as bytes. Blocks until EOF is reached.
# 𝕩: any - dummy value to make this a function.
# ←: number list.
ReadStdinBytes ← { 𝕩:
    # Cursed, but •term.CharB reads only one character at a time and I couldn't
    # find a better way to read from stdin.
    result ← ⟨⟩
    @•_while_{𝕩: result ∾↩ •term.CharB @ ⋄ 0≢¯1⊑result}@
    # Converts to bytes, dropping the 0 from •term.CharB.
    @-˜¯1↓result
}

# File to read from. Set by ParseArguments. 0 means no file.
file←0
# Code generator language to use. Set by ParseArguments. 0 means output hexdump.
codeGeneratorLanguage←0

main ← {
    ParseArguments •args

    data ← ⟨⟩
    { 0≡file ? data ↩ ReadStdinBytes @
    ; •file.Exists file ? data ↩ ReadFileBytes file
    ; Error "Failed to open '"∾file∾"': no such file or directory"
    }

    { 0: Hexdump data ;
      "c": GenerateC data ;
      "bqn": GenerateBQN data
    } codeGeneratorLanguage
}

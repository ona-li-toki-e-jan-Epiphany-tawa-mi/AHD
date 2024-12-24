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
# Hexdump Generator                                                            #
################################################################################

# Splits a list into groups of a specified size. Leftover data that could not
# fit in will be placed into the last group.
# 𝕩: list.
# 𝕨: number - size.
# ←: list of lists.
GroupEvery ← {𝕩⊔˜⌊𝕨÷˜↕≠𝕩}

# Pairs each element in a list with a number starting at 0 and increasing by n
# for it's index (i.e. ⟨⟨0,'a'⟩,⟨5,'b'⟩,⟨10,'c'⟩⟩ ← 5 𝕊 "abc").
# 𝕩: list.
# 𝕨: number - step.
# ←: number⋈element list.
EnumerateBy ← {𝕩⋈¨˜𝕨×↕≠𝕩}

# Converts a number to it's uppercase hexidecimal representation as a string of
# a specified length, left-padding with zeros.
# 𝕩: number - to convert.
# 𝕨: number - length.
# ←: string.
Hexify ← (⥊⟜16)⊸{"0123456789ABCDEF"⊏˜𝕨|⌊÷`⌾⌽𝕨«˜<𝕩}

# Returns whether the given number(s), converted to character(s), represent
# printable ASCII.
# 𝕩: number or number list.
# ←: boolean or boolean list.
IsDisplayable ← (32⊸≤)∧(126⊸≥)

bytesPerLine ← 16

# Prints out a hexdump of the given bytes.
# 𝕩: number list, where 0≤number≤255 .
Hexdump ← {
    lineNumberString ← 7 Hexify ⊑𝕩
    bytesHexString ← ∾⟜(' '⥊˜(3×bytesPerLine)-≠)∾(' '∾2⊸Hexify)¨1⊑𝕩
    bytesCharacterString ← @+IsDisplayable◶⟨' '-@,⊢⟩¨1⊑𝕩

    •Out lineNumberString ∾ ':' ∾ bytesHexString ∾ " |" ∾ bytesCharacterString ∾ "|"
}¨ bytesPerLine EnumerateBy bytesPerLine⊸GroupEvery

################################################################################
# Command Line Interface                                                       #
################################################################################

# Joins a string list into a string with newlines in-between.
# 𝕩: string list.
# ←: string.
Unlines ← (∾⟜(@+10)⊸∾)´

help ← Unlines ⟨
    "Usage:",
    "  "∾•name∾" [options...] FILE",
    "",
    "Displays FILE contents in hexidecimal.",
    "",
    "Options:",
    "  --help       display this help information and exits.",
    "  --version    display version and exits.",
    "  --license    display license and exits.",
⟩


version ← "ahd 0.1.6"

license ← Unlines ⟨
    "Copyright (C) 2024 ona-li-toki-e-jan-Epiphany-tawa-mi.",
    "",
    "This program is free software: you can redistribute it and/or modify it",
    "under the terms of the GNU General Public License as published by the Free",
    "Software Foundation, either version 3 of the License, or (at your option)",
    "any later version.",
    "",
    "This program is distributed in the hope that it will be useful, but WITHOUT",
    "ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or",
    "FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for",
    "more details.",
    "",
    "You should have received a copy of the GNU General Public License along",
    "with this program. If not, see http://www.gnu.org/licenses/.",
    "",
    "Source (paltepuk):",
    "  https://http://paltepuk.xyz/cgit/AHD.git/about/",
    "  http://oytjumugnwsf4g72vemtamo72vfvgmp4lfsf6wmggcvba3qmcsta.b32.i2p/cgit/AHD.git/about/",
    "  http://4blcq4arxhbkc77tfrtmy4pptf55gjbhlj32rbfyskl672v2plsmjcyd.onion/cgit/AHD.git/about/",
    "",
    "Source (GitHub):",
    "  https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD/"
⟩

Error ← •Out "Error: "⊸∾

file←0
codeGeneratorLanguage←0

# TODO: add single character options.
ParseArguments ← {
    []: @;
    𝕩: (1↓𝕩) {
        𝕨𝕊[]: ParseArguments 𝕨 ;
        𝕨𝕊"--help": •Out help ⋄ •Exit 0 ;
        𝕨𝕊"--version": •Out version ⋄ •Exit 0 ;
        𝕨𝕊"--license": •Out license ⋄ •Exit 0 ;
        𝕨𝕊𝕩: '-'≡⊑𝕩 ? Error "unknown option '"∾𝕩∾"'" ⋄ •Exit 1;
              0≡file ? file ↩ 𝕩 ⋄ ParseArguments 𝕨 ;
                       Error "Only one file may be specified but multiple were present"
                       ⋄ •Exit 1
    } ⊑𝕩
}

# Returns the contents of a file as bytes.
# 𝕩: string - file name.
# ←: number list.
ReadBytes ← @-˜•file.MapBytes

main ← {
    ParseArguments •args

    # TODO: add C code generator.

    { 0: Error "No file specified" ⋄ •Out help ⋄ •Exit 1 ;
      𝕩: Hexdump ReadBytes file
    } file
}

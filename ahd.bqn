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

# Returns the contents of a file as bytes.
# 𝕩: string - file name.
# ←: number list.
ReadBytes ← @-˜•file.MapBytes

# Splits a list into groups of a specified size. Leftover data that could not
# fit in will be placed into the last group.
# 𝕩: list.
# 𝕨: number - size.
# ←: list of lists.
GroupEvery ← {𝕩⊔˜⌊𝕨÷˜↕≠𝕩}

# Pairs each element in a list with a number starting at 0 and increasing by n for it's
# index (i.e. ⟨⟨0,'a'⟩,⟨5,'b'⟩,⟨10,'c'⟩⟩ ← 5 𝕊 "abc").
# 𝕩: list.
# 𝕨: number - step.
# ←: number⋈element list.
EnumerateBy ← {𝕩⋈¨˜𝕨×↕≠𝕩}

# Converts a number to it's uppercase hexidecimal representation as a string of a
# specified length, left-padding with zeros.
# 𝕩: number - to convert.
# 𝕨: number - length.
# ←: string.
Hexify ← (⥊⟜16)⊸{"0123456789ABCDEF"⊏˜𝕨|⌊÷`⌾⌽𝕨«˜<𝕩}

# Returns whether the given number(s), converted to character(s), represent
# printable ASCII.
# 𝕩: number or number list.
# ←: boolean or boolean list.
IsDisplayable ← (32⊸≤)∧(126⊸≥)

spaceByte ← ' '-@

bytesPerLine ← 16

Hexdump ← {
    lineNumberString ← 7 Hexify ⊑𝕩
    bytesHexString ← ∾⟜(' '⥊˜(3×bytesPerLine)-≠)∾(' '∾2⊸Hexify)¨1⊑𝕩
    bytesCharacterString ← @+IsDisplayable◶⟨spaceByte,⊢⟩¨1⊑𝕩
    •Out lineNumberString ∾ ':' ∾ bytesHexString ∾ " |" ∾ bytesCharacterString ∾ "|"
}¨ bytesPerLine EnumerateBy bytesPerLine⊸GroupEvery

main ← {
    Hexdump ReadBytes "ahd.apl"
}
main

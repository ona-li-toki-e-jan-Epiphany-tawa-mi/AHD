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
# fit in will be placed into the last group
# 𝕩: list.
# 𝕨: number - size.
# ←: list of lists.
GroupEvery ← {𝕩⊔˜⌊𝕨÷˜↕≠𝕩}

# Converts a number to it's uppercase hexidecimal representation as a string of a
# specified length, left-padding with zeros.
# 𝕩: number - to convert.
# 𝕨:number - length.
Hexify ← (⥊⟜16)⊸{"0123456789ABCDEF"⊏˜𝕨|⌊÷`⌾⌽𝕨«˜<𝕩}

Hexdump ← {
    •Out (7 Hexify ⊑𝕩) ∾ ':' ∾ (∾(' '∾2⊸Hexify)¨1⊑𝕩)
}¨∘((16⊸×○↕≠)⋈¨⊢)16⊸GroupEvery

main ← {
    Hexdump ReadBytes "ahd.apl"
    # •Out 5 Hexify 12427
}
main

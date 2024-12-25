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

# AHD integration testing script.
#
# Run './test.bqn' to run tests.
# Run './test.bqn' to regenerate tests.

newline ← @+10

sourceDirectory ← "tests/sources"
outputDirectory ← "tests/outputs"

# Runs AHD with the given arguments.
# 𝕩: string list.
# ←: number‿string‿string - exitCode‿stdout‿stderr from AHD.
RunAHD ← {
    command ← "bqn"‿"ahd.bqn"∾𝕩
    •Out "+ "∾(∾⟜" "⊸∾)´command
    •SH command
}

# Generates a report from the output of AHD that can be used for comparison in
# tests.
# 𝕩: number‿string‿strin - exitCode‿stdout‿stderr from AHD.
# ←: string.
GenerateReport ← {
    exitCode‿stdout‿stderr ← 𝕩

    report←":exitcode "∾(•Fmt exitCode)∾newline
    report↩report∾":stdout"∾newline∾stdout
    report↩report∾":stderr"∾newline∾stderr
    report
}

# Takes a file name and arguments used in the AHD command and generates a path
# to a corresponding and unique file in the output directory.
# 𝕩: string - file name.
# 𝕨: string list - arguments.
# ←: string.
OutputFile ← {
    path ← outputDirectory •file.At 𝕩

    𝕨 { 0≢≠𝕨 ?
        ".out"∾˜𝕩∾"."∾(∾⟜"_"⊸∾)´𝕨 ;
        𝕩∾".out"
    } path
}

# Runs AHD on the given source file with the given arguments and records the
# result to the output directory.
# 𝕩: string - file name (without the directory path.)
# 𝕨: string list - arguments to AHD.
Record ← {
    sourceFile ← sourceDirectory •file.At 𝕩
    outputFile ← 𝕨 OutputFile 𝕩

    report ← GenerateReport RunAHD 𝕨∾<sourceFile

    •Out "Saving output to '"∾outputFile∾"'..."
    outputFile •file.Chars report
}

# TODO: make print offending line.
# Runs AHD on the given source file with the given arguments and compares it
# against the previously recorded result from the output directory.
# 𝕩: string - file name (without the directory path.)
# 𝕨: string list - arguments to AHD.
Test ← {
    sourceFile ← sourceDirectory •file.At 𝕩
    outputFile ← 𝕨 OutputFile 𝕩

    report ← GenerateReport RunAHD 𝕨∾<sourceFile
    previousReport ← •file.Chars outputFile

    outputFile { ≡´𝕩 ?
        •Out "Test passed" ;
        •Out "Test failed: output differs from previously recorded output in '"∾𝕨∾"'"
        •Out "Actual output:"
        •Out ⊑𝕩
        •Exit 1
    } report‿previousReport
}

# To be used on Record or Test. Specifies the inputs to be recorded/tested.
# 𝔽: Record or Test.
_run ← {
    sourceFiles ← •file.List sourceDirectory

    # Positive tests.
    ⟨⟩⊸𝔽¨ sourceFiles
    ⟨"--code-generator","c"⟩⊸𝔽¨ sourceFiles

    # Negative tests.
    ⟨"--code-generator"⟩ 𝔽 "no-language-specified"
    ⟨"--code-generator","unsupported"⟩ 𝔽 "unsupported-language"
    ⟨⟩ 𝔽 "nonexistant-file"
    ⟨"file2"⟩ 𝔽 "duplicate-files"
}

main ← {
    ⊑•args∊˜<"record" ? Record _run ; Test _run
}

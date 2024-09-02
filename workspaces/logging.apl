⍝!/usr/local/bin/apl --script

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

⍝ Logging module.
⍝ Depends on fio.apl.



⍝ Displays an error message.
∇ERROR MESSAGE
  ⊣ FIO∆STDERR FIO∆FWRITE_CVECTOR⍨ "error: ",MESSAGE,"\n"
∇

⍝ Displays an error message and exits.
∇PANIC MESSAGE
  ⊣ FIO∆STDERR FIO∆FWRITE_CVECTOR⍨ "fatal: ",MESSAGE,"\n"
  ⍎")OFF"
∇

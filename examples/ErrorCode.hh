/*
    This file is part of GNU APL, a free implementation of the
    ISO/IEC Standard 13751, "Programming Language APL, Extended"

    Copyright © 2008-2023  Dr. Jürgen Sauermann

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/** @file
*/

#ifndef __ERRORCODE_HH_DEFINED__
#define __ERRORCODE_HH_DEFINED__

/**
    Errors that can occur in the APL interpreter.
 **/
enum ErrorCode
{
#define err_def(c, t, maj, min) /** c **/ E_ ## c = (maj) << 16 | (min),
#include "Error.def"
};

#endif // __ERRORCODE_HH_DEFINED__

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

SOURCE := ahd.apl
OUT    := ahd



# Dummy main goal since there's nothing to build.
.PHONY: all
all:



prefix      ?= /usr/local
exec_prefix ?= $(prefix)
bindir      ?= $(exec_prefix)/bin

INSTALL         ?= install
INSTALL_PROGRAM ?= $(INSTALL) -m 755

.PHONY: install
install:
	$(INSTALL_PROGRAM) -D $(SOURCE) $(DESTDIR)$(bindir)/$(OUT)

.PHONY: uninstall
uninstall:
	rm $(DESTDIR)$(bindir)/$(OUT)

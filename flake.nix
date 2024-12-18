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

{
  description = "AHD development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let inherit (nixpkgs.lib) genAttrs systems;

        forAllSystems = f: genAttrs systems.flakeExposed (system: f {
          pkgs = import nixpkgs { inherit system; };
        });
    in {
      devShells = forAllSystems ({ pkgs }: {
        default = with pkgs; mkShell {
          packages = [
            gnuapl
          ];
        };
      });
    };
}

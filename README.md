# AHD - A HexDumper

A simple hexdump utility I wrote. That's it.

## How to run

You will need the GnuAPL interpreter (https://www.gnu.org/software/apl)
installed on your system. There is a `flake.nix` you can use with
`nix develop path:.` to get it.

Then, run one of the following commands to get started:

```
./ahd.apl +h
apl --script ahd.apl -- +h
```

#### Options

- +h, ++help

Displays help information.

- +v, ++version

Displays version.

- +c, ++code-generator

Outputs code to bake the data into a program. Expects a language as an argument.
Supported Languages: c.

## How to install

You can install it with Nix from the NUR (https://github.com/nix-community/NUR)
with the following attribute:

```nix
nur.repos.ona-li-toki-e-jan-Epiphany-tawa-mi.ahd
```

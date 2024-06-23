# AHD - A HexDumper

A simple hexdump utility I wrote. That's it.

## How to run

You will need the GnuAPL interpreter (https://www.gnu.org/software/apl)
installed on your system. There is a `flake.nix` you can use with
`nix develop path:.` to get it.

Then, run one of the following commands to run AHD:

```
./ahd.apl [options...] [FILE...]
apl --script ahd.apl -- [options...] [FILE...]
```

#### Options

- +h, ++help

Displays help information.

- +v, ++version

Displays version.

## How to install

You can  install it with Nix from the NUR (https://github.com/nix-community/NUR)
with the following attribute:

```nix
nur.repos.ona-li-toki-e-jan-Epiphany-tawa-mi.ahd
```

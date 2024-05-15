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

If you would like to install it, you do so with the following make command:

```
make install
```

Note that the script expects GnuAPL to be in /usr/bin/apl. Modify the shebang
before-hand if your setup differs.

You can also install it with Nix from the NUR
(https://github.com/nix-community/NUR) with the following attribute:

```nix
nur.repos.ona-li-toki-e-jan-Epiphany-tawa-mi.ahd
```

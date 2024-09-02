# AHD - A HexDumper

A simple hexdump utility I wrote. That's it.

## How to run

Dependencies:

- GnuAPL: ([https://www.gnu.org/software/apl](https://www.gnu.org/software/apl))

There is a `flake.nix` you can use with `nix develop path:.` to generate a
development enviroment.

Then, run one of the following commands to get started:

```sh
./ahd.apl +h
apl --script ahd.apl -- +h
```

## How to run tests

Get the dependencies as specified in the `How to run` section.

Then, run one of the following commands:

```sh
./test.apl -- test examples recordings
apl --script test.apl -- test examples recordings
```

If breaking changes are desired, regenerate the test cases with one of the
following commands:

```sh
./test.apl -- record examples recordings
apl --script test.apl -- record examples recordings
```

## How to install

You can install it with Nix from the NUR ([https://github.com/nix-community/NUR](https://github.com/nix-community/NUR))
with the following attribute:

```nix
nur.repos.ona-li-toki-e-jan-Epiphany-tawa-mi.ahd
```

## Release notes

- Added C code generator.

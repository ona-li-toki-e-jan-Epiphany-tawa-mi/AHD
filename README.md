# AHD - A HexDumper

A simple hexdump utility I wrote. That's it.

## How to run

Dependencies:

- CBQN - [https://github.com/dzaima/CBQN](https://github.com/dzaima/CBQN)

There is a `flake.nix` you can use with `nix develop` to generate a development
enviroment.

Then, run the following command(s) to get started:

```sh
./ahd.bqn -h
```

## How to run tests

Get the dependencies as specified in the `How to run` section.

Then, run the following command(s):

```sh
./test.bqn
```

If breaking changes are desired, regenerate the test cases with the following
command(s):

```sh
./test.bqn record
```

## How to install

You can install it with Nix from the NUR ([https://github.com/nix-community/NUR](https://github.com/nix-community/NUR))
with the following attribute:

```nix
nur.repos.ona-li-toki-e-jan-Epiphany-tawa-mi.ahd
```

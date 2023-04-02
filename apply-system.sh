#!/bin/sh

pushd ~/.setup
sudo nixos-rebuild switch --flake .#
popd
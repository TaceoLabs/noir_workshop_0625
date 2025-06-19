#!/usr/bin/env bash

rm -rf out
rm verification_key.dat
mkdir out
mkdir out/proofs
mkdir out/secret-shared-inputs
mkdir out/witness
mkdir out/merged-inputs

touch out/proofs/.gitkeep
touch out/secret-shared-inputs/.gitkeep
touch out/witness/.gitkeep
touch out/merged-inputs/.gitkeep

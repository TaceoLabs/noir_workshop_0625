# Shuffling Cards with MPC - Noircon2

This README provides complementary material for the Noircon2 workshop.

## Installation

To participate in the workshop, the recommended approach is to run the provided Docker image.

### Docker

Run the following command in the root directory of the repository:

```bash
docker build -t co-snarks . && docker run -it co-snarks
```

### Manual Installation

If you'd prefer to install everything manually, follow the instructions from our [GitHub](https://github.com/TaceoLabs/co-snarks). Additionally, you will need to install [Noir](https://noir-lang.org/docs/getting_started/quick_start).

By the end of this setup, you should have the following tools installed:

* `coNoir`
* `Noir` (`nargo`)

## Shuffling a Deck for two Players

In this example, we'll shuffle a deck of [Doppel-Deutsche](https://en.wikipedia.org/wiki/German-suited_playing_cards) playing cards. To make things easier, we’ve provided a `justfile` that automates all the necessary commands. Since you’ll need to run specific commands on all "MPC-nodes" simultaneously, it can be a bit cumbersome to manage this in Docker. That's why we’ve included the `justfile` — and don't worry, the container already comes with `just` pre-installed to streamline the process.

### Compiling the Circuit

The first step is to compile the circuit with `nargo`. To do that we `cd` into the `doppel_deutsche/` folder and, run:

```bash
nargo compile
```

If you are familiar with Noir (which I think you are being at Noircon), this command should look familiar. We now have the compiled circuit at `target/doppel_deutsche.json`.

### Secret Sharing the Input

Now, let’s prepare the inputs for the circuit. Since we are simulating two parties, we have two input files: `input.alice.json` and `input.bob.json`. They want to play a game with the Doppeldeutsche deck. We go back to our root directory and inspect the inputs from Alice and Bob.

To view the input files, use the following command:

```bash
bat input.alice.toml
```

Now split the input (secret-share):

```bash
#split input Alice
co-noir split-input --circuit doppel_deutsche/target/doppel_deutsche.json --input input.alice.toml --protocol REP3 --out-dir out/secret-shared-inputs/

#split input Bob
co-noir split-input --circuit doppel_deutsche/target/doppel_deutsche.json --input input.bob.toml --protocol REP3 --out-dir out/secret-shared-inputs/
```

or use the `justfile`

```bash
just split-input
```

You’ll now find 6 files in the `out/secret-shared-inputs` directory. Each file contains the secret-shared inputs for the respective parties. For example,
`input.alice.toml.0.shared` holds Alice's secret-shared input for party 0, and `input.bob.toml.1.shared` contains Bob’s secret-shared input for party 1, and so on.

Keep in mind, this process is typically done on two separate machines in a real-world setting!

### Merging the Input

Once the input is secret-shared, the next step is to merge the secret-shared inputs on each of the MPC nodes. In a real-world scenario, Alice and Bob would send their secret-shared inputs to the MPC nodes. However, for this example, we’ll simulate this process by merging the inputs on a single machine. We’ll need to do this three times—once for each node.

```bash
#merge input for party 0
co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.0.shared --inputs out/secret-shared-inputs/input.bob.toml.0.shared --protocol REP3 --out out/merged-inputs/Prover.toml.0.shared

#merge input for party 1
co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.1.shared --inputs out/secret-shared-inputs/input.bob.toml.1.shared --protocol REP3 --out out/merged-inputs/Prover.toml.1.shared

#merge input for party 2
co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.2.shared --inputs out/secret-shared-inputs/input.bob.toml.2.shared --protocol REP3 --out out/merged-inputs/Prover.toml.2.shared
```

or

```bash
just merge-input
```

We now have three files in the `out/merged-inputs` directory.

### Generating the Extended Witness

Now that all the MPC nodes have the secret-shared, merged input, the next step is to generate the extended witness. This step involves running a specific command on each MPC node. Since this is a dedicated process, you’ll either need to open three terminal sessions or simply use the provided `justfile` to streamline the process.

```bash
# start party 0
co-noir generate-witness --input out/merged-inputs/Prover.toml.0.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party0.toml --out out/witness/witness.gz.0.shared

# start party 1
co-noir generate-witness --input out/merged-inputs/Prover.toml.1.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party1.toml --out out/witness/witness.gz.1.shared

# start party 2
co-noir generate-witness --input out/merged-inputs/Prover.toml.2.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party2.toml --out out/witness/witness.gz.2.shared
```

or

```bash
just run-witness-generation
```

This step might take a few seconds (~2 seconds on my machine). Once it’s complete, you’ll find the secret-shared witness in the `out/witness` folder.

### Generating the Proof

Now for the final step — generating the proof! This step may take again a couple of seconds. On my machine it took ~5 seconds. This is single-threaded and not optimized. We will tackle performance over the next couple of months, as we focused on being feature complete over performance.
Anyways, you can do generate the proof by running the following commands on each MPC-node:

```bash
# start party 0
co-noir build-and-generate-proof --witness out/witness/witness.gz.0.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party0.toml --out out/proofs/proof.0.dat --public-input out/proofs/public-input.0.dat

# start party 1
co-noir build-and-generate-proof --witness out/witness/witness.gz.1.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party1.toml --out out/proofs/proof.1.dat --public-input out/proofs/public-input.1.dat

# start party 2
co-noir build-and-generate-proof --witness out/witness/witness.gz.2.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party2.toml --out out/proofs/proof.2.dat --public-input out/proofs/public-input.2.dat
```

or use the `justfile`

```bash
just run-prove
```

Congratulations! 🎉 You’ve successfully generated the proof! You can find three proof files in the
`out/proofs` directory. The public input is also stored in the same location.

### Verifying the Proof with coNoir

You can easily verify the proof using the `coNoir` tool. Similar as with barettenberg, you have to create a verification key. You can do this with:

```bash
co-noir create-vk --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --vk verification_key.dat --hasher keccak
```

Finally, you can verify the proof:
```bash
co-noir verify --proof out/proofs/proof.0.dat --public-input out/proofs/public-input.0.dat --vk verification_key.dat --hasher keccak --crs crs/bn254_g2.dat
```

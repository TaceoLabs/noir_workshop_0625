# secret shares the inputs for the three MPC nodes
split-input:
	co-noir split-input --circuit doppel_deutsche/target/doppel_deutsche.json --input input.alice.toml --protocol REP3 --out-dir out/secret-shared-inputs/
	co-noir split-input --circuit doppel_deutsche/target/doppel_deutsche.json --input input.bob.toml --protocol REP3 --out-dir out/secret-shared-inputs/

# For each MPC node, merges the secret shared inputs of Alice and Bob
merge-input:
	co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.0.shared --inputs out/secret-shared-inputs/input.bob.toml.0.shared --protocol REP3 --out out/merged-inputs/Prover.toml.0.shared
	co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.1.shared --inputs out/secret-shared-inputs/input.bob.toml.1.shared --protocol REP3 --out out/merged-inputs/Prover.toml.1.shared
	co-noir merge-input-shares --inputs out/secret-shared-inputs/input.alice.toml.2.shared --inputs out/secret-shared-inputs/input.bob.toml.2.shared --protocol REP3 --out out/merged-inputs/Prover.toml.2.shared

# runs the extended witness generation on three nodes
run-witness-generation:
	co-noir generate-witness --input out/merged-inputs/Prover.toml.0.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party0.toml --out out/witness/witness.gz.0.shared &
	RUST_LOG="error" co-noir generate-witness --input out/merged-inputs/Prover.toml.1.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party1.toml --out out/witness/witness.gz.1.shared &
	RUST_LOG="error" co-noir generate-witness --input out/merged-inputs/Prover.toml.2.shared --circuit doppel_deutsche/target/doppel_deutsche.json --protocol REP3 --config configs/party2.toml --out out/witness/witness.gz.2.shared

# runs the proof generation on three nodes
run-prove:
	co-noir build-and-generate-proof --witness out/witness/witness.gz.0.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party0.toml --out out/proofs/proof.0.dat --public-input out/proofs/public-input.0.dat &
	RUST_LOG="error" co-noir build-and-generate-proof --witness out/witness/witness.gz.1.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party1.toml --out out/proofs/proof.1.dat --public-input out/proofs/public-input.1.dat &
	RUST_LOG="error" co-noir build-and-generate-proof --witness out/witness/witness.gz.2.shared --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --protocol REP3 --hasher keccak --config configs/party2.toml --out out/proofs/proof.2.dat --public-input out/proofs/public-input.2.dat

# runs the verification key generation
generate-vkey:
    co-noir create-vk --circuit doppel_deutsche/target/doppel_deutsche.json --crs crs/bn254_g1.dat --vk verification_key.dat --hasher keccak

# runs the verification key generation
run-verify:
    co-noir verify --proof out/proofs/proof.0.dat --public-input out/proofs/public-input.0.dat --vk verification_key.dat --hasher keccak --crs crs/bn254_g2.dat

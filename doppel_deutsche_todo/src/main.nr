mod shuffle;

global UNSHUFFLED_DECK: [u16; 32] = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
    26, 27, 28, 29, 30, 31,
];

#[derive(Eq)]
pub(crate) struct DoppelDeutscheCards {
    deck: [u16; 32],
}

impl DoppelDeutscheCards {
    // In a real application, commitments should also have randomness
    fn commit(self) -> Field {
        let mut current_hash = 0;
        for i in 0..16 {
            let mut poseidon_input =
                [current_hash, self.deck[i * 2] as Field, self.deck[i * 2 + 1] as Field, 0];
            current_hash = std::hash::poseidon2_permutation(poseidon_input, 4)[0];
        }
        current_hash
    }

    pub(crate) fn shuffle(player1: Field, player2: Field) -> Self {
        Self { deck: shuffle::shuffle(UNSHUFFLED_DECK, [player1, player2]) }
    }
}

// In a real application, commitments should also have randomness
fn commit(input: Field) -> Field {
    std::hash::poseidon2_permutation([input, 0, 0, 0], 4)[0]
}

// TODO main function - verify commitments to inputs and shuffle the deck
fn main_inner() -> DoppelDeutscheCards {}

// TODO call the main_inner function but only return the commitment to the shuffled deck
fn main() -> pub Field {}

#[test]
pub fn test_deterministic() {
    let deck1 = main_inner(
        1,
        2,
        0x02a04ea402711ced2d4bc39608cc5350a7db4af98ec2950d4d1ec30334d6c2b4,
        0x01fc64bed90c55b193ec54e851cd13888d45293f2a2e4efdf83581f39df9c615,
    );
    let deck2 = main_inner(
        1,
        2,
        0x02a04ea402711ced2d4bc39608cc5350a7db4af98ec2950d4d1ec30334d6c2b4,
        0x01fc64bed90c55b193ec54e851cd13888d45293f2a2e4efdf83581f39df9c615,
    );
    assert(deck1 == deck2);
}

#[test]
pub fn test_random() {
    let deck1 = main_inner(
        1,
        2,
        0x02a04ea402711ced2d4bc39608cc5350a7db4af98ec2950d4d1ec30334d6c2b4,
        0x01fc64bed90c55b193ec54e851cd13888d45293f2a2e4efdf83581f39df9c615,
    );
    let deck2 = main_inner(
        1,
        3,
        0x02a04ea402711ced2d4bc39608cc5350a7db4af98ec2950d4d1ec30334d6c2b4,
        0x242625e88b1aae5923a32b65ae620a8fd0830822031e994d6c241f06eb899c69,
    );
    let deck3 = main_inner(
        2,
        3,
        0x01fc64bed90c55b193ec54e851cd13888d45293f2a2e4efdf83581f39df9c615,
        0x242625e88b1aae5923a32b65ae620a8fd0830822031e994d6c241f06eb899c69,
    );
    let deck4 = main_inner(
        30,
        3,
        0x08bfd7e317fffab495cb2381fec38d7239b328290787aee42eb0c9dd264930ef,
        0x242625e88b1aae5923a32b65ae620a8fd0830822031e994d6c241f06eb899c69,
    );
    assert(deck1 != deck2);
    assert(deck1 != deck3);
    assert(deck1 != deck4);

    assert(deck2 != deck3);
    assert(deck2 != deck4);

    assert(deck3 != deck4);
}

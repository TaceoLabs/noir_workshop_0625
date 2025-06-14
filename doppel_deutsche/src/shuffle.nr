use dep::poseidon2;

mod detail;

pub(crate) struct ShuffleRandomness {
    coins: [u1; 254],
    counter: u32,
}

impl ShuffleRandomness {
    fn new(player1: Field, player2: Field) -> Self {
        Self { coins: poseidon2::bn254::hash_2([player1, player2]).to_le_bits(), counter: 0 }
    }

    fn coin(self: &mut Self) -> bool {
        let coin = self.coins[self.counter] as bool;
        self.counter = self.counter + 1;
        coin
    }
}

pub(crate) fn shuffle(arr: [u16; 32], r: [Field; 2]) -> [u16; 32] {
    let mut r = ShuffleRandomness::new(r[0], r[1]);
    detail::bitonic_shuffle32(arr, &mut r)
}

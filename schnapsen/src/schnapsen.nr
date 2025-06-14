mod shuffle;

global PADDING: u16 = 0xFFFF;

global UNSHUFFLED_DECK: [u16; 32] = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, PADDING, PADDING, PADDING,
    PADDING, PADDING, PADDING, PADDING, PADDING, PADDING, PADDING, PADDING, PADDING,
];

#[derive(Eq)]
pub(crate) struct DoppelDeutscheCards {
    deck: [u16; 20],
}

impl DoppelDeutscheCards {

    pub(crate) fn shuffle(player1: Field, player2: Field) -> Self {
        let deck = shuffle::shuffle(UNSHUFFLED_DECK, [player1, player2]);
        Self { deck: filter_padding(deck) }
    }
}

fn filter_padding(arr: [u16; 32]) -> [u16; 20] {
    let mut result = [0; 20];
    let mut idx = 0;
    for ele in arr {
        if ele != PADDING {
            result[idx] = ele;
            idx += 1;
        }
    }
    result
}

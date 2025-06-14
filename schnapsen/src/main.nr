mod schnapsen;

use schnapsen::DoppelDeutscheCards;

fn main(
    player1: Field,
    player2: Field,
    player1_c: pub Field,
    player2_c: pub Field,
) -> pub DoppelDeutscheCards {
    assert(std::hash::pedersen_hash([player1]) == player1_c);
    assert(std::hash::pedersen_hash([player2]) == player2_c);
    DoppelDeutscheCards::shuffle(player1, player2)
}

#[test]
pub fn test_deterministic() {
    let deck1 = main(
        1,
        2,
        0x03542cb720369f19a74fd05b4edfbedb27a78514ad3283f1b3270a1656cced8e,
        0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8,
    );
    let deck2 = main(
        1,
        2,
        0x03542cb720369f19a74fd05b4edfbedb27a78514ad3283f1b3270a1656cced8e,
        0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8,
    );
    assert(deck1 == deck2);
}

#[test]
pub fn test_random() {
    let deck1 = main(
        1,
        2,
        0x03542cb720369f19a74fd05b4edfbedb27a78514ad3283f1b3270a1656cced8e,
        0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8,
    );
    let deck2 = main(
        1,
        3,
        0x03542cb720369f19a74fd05b4edfbedb27a78514ad3283f1b3270a1656cced8e,
        0x24013340c052ebf847e0d7081f84e6a8e92f54e2e1726a1e559ac46a8f242007,
    );
    let deck3 = main(
        2,
        3,
        0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8,
        0x24013340c052ebf847e0d7081f84e6a8e92f54e2e1726a1e559ac46a8f242007,
    );
    let deck4 = main(
        30,
        3,
        0x27619099f440bf0989b7220bd41ef216bdceb367238441638486a431bda01d28,
        0x24013340c052ebf847e0d7081f84e6a8e92f54e2e1726a1e559ac46a8f242007,
    );
    assert(deck1 != deck2);
    assert(deck1 != deck3);
    assert(deck1 != deck4);

    assert(deck2 != deck3);
    assert(deck2 != deck4);

    assert(deck3 != deck4);
}

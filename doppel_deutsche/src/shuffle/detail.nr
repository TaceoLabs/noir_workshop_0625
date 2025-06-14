use super::ShuffleRandomness;

fn compare_and_swap<let L: u32>(
    mut arr: [u16; L],
    i: u32,
    j: u32,
    r: &mut ShuffleRandomness,
) -> [u16; L] {
    if r.coin() {
        let temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
    arr
}

pub(crate) fn bitonic_sort32(arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N = 32
    let m = 16;
    let arr = bitonic_sort16(arr, lo, r);
    let arr = bitonic_sort16(arr, lo + m, r);
    bitonic_merge32(arr, lo, r)
}

fn bitonic_sort16(arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    let m = 8;
    let arr = bitonic_sort8(arr, lo, r);
    let arr = bitonic_sort8(arr, lo + m, r);
    bitonic_merge16(arr, lo, r)
}

fn bitonic_sort8(arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    let m = 4;
    let arr = bitonic_sort4(arr, lo, r);
    let arr = bitonic_sort4(arr, lo + m, r);
    bitonic_merge8(arr, lo, r)
}

fn bitonic_sort4(arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    let m = 2;
    let arr = bitonic_sort2(arr, lo, r);
    let arr = bitonic_sort2(arr, lo + m, r);
    bitonic_merge4(arr, lo, r)
}

fn bitonic_sort2(arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    bitonic_merge2(arr, lo, r)
}

//==============================
// bitonic merge
//==============================

fn bitonic_merge32(mut arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N == 32
    let m = 16;
    for i in lo..lo + m {
        arr = compare_and_swap(arr, i, i + m, r);
    }
    let arr = bitonic_merge16(arr, lo, r);
    bitonic_merge16(arr, lo + m, r)
}

fn bitonic_merge16(mut arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N == 16
    let m = 8;
    for i in lo..lo + m {
        arr = compare_and_swap(arr, i, i + m, r);
    }
    let arr = bitonic_merge8(arr, lo, r);
    bitonic_merge8(arr, lo + m, r)
}

fn bitonic_merge8(mut arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N == 8
    let m = 4;
    for i in lo..lo + m {
        arr = compare_and_swap(arr, i, i + m, r);
    }
    let arr = bitonic_merge4(arr, lo, r);
    bitonic_merge4(arr, lo + m, r)
}

fn bitonic_merge4(mut arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N == 4
    let m = 2;
    for i in lo..lo + m {
        arr = compare_and_swap(arr, i, i + m, r);
    }
    let arr = bitonic_merge2(arr, lo, r);
    bitonic_merge2(arr, lo + m, r)
}

fn bitonic_merge2(mut arr: [u16; 32], lo: u32, r: &mut ShuffleRandomness) -> [u16; 32] {
    // N == 2
    let m = 1;
    for i in lo..lo + m {
        arr = compare_and_swap(arr, i, i + m, r);
    }
    arr
}

pub(crate) fn bitonic_shuffle32(arr: [u16; 32], r: &mut ShuffleRandomness) -> [u16; 32] {
    bitonic_sort32(arr, 0, r)
}

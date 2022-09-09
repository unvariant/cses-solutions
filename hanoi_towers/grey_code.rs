use std::fmt::Write;
 
fn main() {
    let mut input = String::new();
    let _ = std::io::stdin().read_line(&mut input);
    let n: u8 = input.trim_end().parse().unwrap();

    let mut buffer = String::new();
    let iterations: u32 = (1 << n) - 1;
    let mut old: u32 = 0;
    let mut state: [u32; 3] = [iterations, 0, 0];
    let mut last = 0;
    let init = if n % 2 == 0 {
        [1, 2, 0]
    } else {
        [2, 1, 0]
    };
    let mut cycle = init.iter().cycle();
	let _ = write!(buffer, "{}\n", iterations);

    for i in 1..iterations+1 {
        let new = i ^ (i >> 1);
        let shift = (old ^ new).trailing_zeros();
        let weight = 1 << shift;
        let mask = (weight << 1) - 1;

        let (src, dst) = if weight == 1 {
            let src = last;
            last = *cycle.next().unwrap();
            (src, last)
        } else {
            let src = state.iter().enumerate().find(|(_, stack)| **stack & weight != 0).unwrap().0;
            let dst = state.iter().enumerate().find(|(_, stack)| **stack & mask == 0).unwrap().0;
            (src, dst)
        };

        let _ = write!(buffer, "{} {}\n", src + 1, dst + 1);

        state[src] ^= weight;
        state[dst] |= weight;
        old = new;
    }

    print!("{}", buffer);
}
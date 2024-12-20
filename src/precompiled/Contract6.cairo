#[starknet::contract]
pub mod Contract6 {
    use risc0_starknet::interfaces::IContract6::{IContract6};
    use core::integer::u512;
    use core::integer::u256_wide_mul;
    use core::integer::u512_safe_div_rem_by_u256;
    use core::zeroable::NonZero;
    use core::integer::u256_overflow_sub;
    
    const r: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    const a: u8 = 0;

    #[storage]
    struct Storage {
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        
    }

    impl Contract6 of IContract6<ContractState> {
        fn ecAdd(self: @ContractState, x1: u256, y1: u256, x2: u256, y2: u256) -> (u256, u256) {
            if x1 == 0 && y1 == 0 {
                return (x2, y2);
            }
            if x2 == 0 && y2 == 0 {
                return (x1, y1);
            }
            let (dxs, _) = u256_overflow_sub(x2.clone(),x1.clone());
            let dx = dxs % r;
            let (dys,_) = u256_overflow_sub(y2.clone(),y1.clone());
            let dy = dys % r;
            let mut lambda: u256 = 0;
            if dx == 0 {
                if dy == 0 {
                    // Doubling case: P1 == P2
                    let res = safe_mul_mod(@x1, @x1);
                    let numerator = (3 * res + a.into()) % r;
                    let denominator = (2 * y1) % r;
                    lambda = modularInverse(numerator, denominator);
                } else {
                    // Points cancel each other
                    return (0, 0);
                }
    
            } else {
                // General case: P1 != P2
                lambda = modularInverse(dy, dx);
            }
            // Compute x3 and y3
            let res = safe_mul_mod(@lambda, @lambda);
            let (res1, _) = u256_overflow_sub(res, x1.clone());
            let (res2, _) = u256_overflow_sub(res1, x2.clone()); 
            let x3: u256 = res2 % r;
            let x3s = @x3;
            let (res3, _) = u256_overflow_sub(x1.clone(), *x3s);
            let (res4, _) = u256_overflow_sub(res3, y1.clone());
            let y3 = res4 % r;
            return (x3, y3);
        }    
    }

    fn safe_mul_mod(a: @u256, b: @u256) -> u256{
        let mut re = u256_wide_mul(*a, *b);
        let nzm: NonZero<u256> = r.try_into().unwrap();
        let (_, res) = u512_safe_div_rem_by_u256(re, nzm);
        re.destruct();
        nzm.destruct();
        return res;
    }

    /// Modular inverse using Fermat's Little Theorem
    fn modularInverse(numerator: u256, denominator: u256) -> u256 {
        let numerator_mod = numerator % r;
        let denominator_mod = denominator % r;

        // Compute the modular inverse using exponentiation
        let rs = r - 2;
        let rs = pow(@denominator_mod, @rs);
        return safe_mul_mod(@numerator_mod, @rs) % r;
    }
    
    // modular pow
    fn pow(base: @u256, exp: @u256) -> u256 {
        let mut result = 1;

        let mut current_base = *base % r;
        let mut current_exp = *exp;
        while current_exp > 0 {
            if current_exp % 2 == 1 {
                println!("linha 531");
                result = safe_mul_mod(@result, @current_base);
                println!("linha 533");
            }
            println!(" linha 535");
            current_base = safe_mul_mod(@current_base, @current_base);
            println!("linha 537");
            println!("ceb {current_exp}");

            current_exp = current_exp / 2;
            println!("ce {current_exp}")
        };

        return result;
    }
}
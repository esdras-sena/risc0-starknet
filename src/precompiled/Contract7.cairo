#[starknet::contract]
pub mod Contract7 {
    use risc0_starknet::interfaces::IContract7::{IContract7};
    use core::integer::u512;
    use core::integer::u256_wide_mul;
    use core::integer::u512_safe_div_rem_by_u256;
    use core::zeroable::NonZero;
    use core::integer::u256_overflow_sub;
    

    const r: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    const a: u8 = 0;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl Contract7 of IContract7<ContractState> {
        // This is a Cairo implementation of the precompiled contract 7 (EIP-196) from Ethereum
        fn BN256ScalarMultiplication(self: @ContractState, x: u256, y: u256, s: u256) -> (u256, u256) {
            let mut result_x: u256 = 0;
            let mut result_y: u256 = 0;
            let mut base_x: u256 = x;
            let mut base_y: u256 = y;
            let mut s_copy: u256 = s;
            loop {
                if s_copy & 1 == 1 {
                    let (r_x, r_y) = pointAdd(@result_x, @result_y, @base_x, @base_y);
                    result_x = r_x;
                    result_y = r_y;
                }
                let (b_x, b_y) = pointAdd(@base_x, @base_y, @base_x, @base_y);
                base_x = b_x;
                base_y = b_y;
                s_copy = s_copy / 2;
                if(s_copy == 0){
                    break;
                }
            };
            return (result_x, result_y);
        }
    }

    fn pointAdd(x1: @u256, y1: @u256, x2: @u256, y2: @u256) -> (u256, u256) {
        let mut lambda = 0;
        if x1 == x2 && y1 == y2 {
            let leftSide = (3 * safe_mul_mod(x1,x1) + a.into());
            let cs = 2 * *y1;
            let rightSide = modular_inverse(@cs);
            lambda = safe_mul_mod(@leftSide, @rightSide) % r;
        } else {
            let (res1, _) = u256_overflow_sub(*y2,*y1);
            let (res2, _) = u256_overflow_sub(*x2,*x1);
            let rs = modular_inverse(@res2);
            lambda = safe_mul_mod(@res1, @rs);
        }
        let (res1, _) = u256_overflow_sub(safe_mul_mod(@lambda, @lambda), *x1);
        let (res2, _) = u256_overflow_sub(res1, *x2);
        let x3 = res2 % r;
        let x3r = @x3;
        let (rig, _) = u256_overflow_sub(*x1, *x3r);
        
        let (sr, _) = u256_overflow_sub(safe_mul_mod(@lambda, @rig),*y1);
        
        let y3 = sr % r;
        return (x3, y3);
    }

    fn safe_mul_mod(a: @u256, b: @u256) -> u256{
        let mut re = u256_wide_mul(*a, *b);
        let nzm: NonZero<u256> = r.try_into().unwrap();
        let (_, res) = u512_safe_div_rem_by_u256(re, nzm);
        
        return res;
    }

    fn extended_gcd(a: u256) -> (u256, u256, u256) {
        let mut old_r = a;
        let mut ra = r;
        let mut old_s = 1_u256;
        let mut s = 0_u256;
        let mut old_t = 0_u256;
        let mut t = 1_u256;
    
        while r != 0 {
            let quotient = old_r / ra;
    
            // Update remainders
            let new_r = old_r - quotient * ra;
            old_r = ra;
            ra = new_r;
    
            // Update s coefficients
            let new_s = old_s - quotient * s;
            old_s = s;
            s = new_s;
    
            // Update t coefficients
            let new_t = old_t - quotient * t;
            old_t = t;
            t = new_t;
        };
    
        return (old_r, old_s, old_t); // Returns gcd, x (modular inverse candidate), y
    }
    
    fn modular_inverse(a: @u256) -> u256 {
        let (gcd, x, _) = extended_gcd(*a);
    
        // Modular inverse exists only if gcd == 1
        if gcd != 1_u256 {
            return 1;
        }
    
        // x might be negative, so ensure it is positive in the modulus range
        return (x % r + r) % r;
    }
    

    // fn inv(x: @u256) -> u256 {
    //     let rs = r - 2;
    //     return pow(x, @rs);
    // }


    // // modular pow
    // fn pow(base: @u256, exp: @u256) -> u256 {
    //     let mut result = 1;

    //     let mut current_base = *base % r;
    //     let mut current_exp = *exp;
    //     loop{

    //         if current_exp % 2 == 1 {
    //             result = safe_mul_mod(@result, @current_base);
    //         }
    //         current_base = safe_mul_mod(@current_base, @current_base);
    //         current_exp = current_exp / 2;
    //         println!("ce {current_exp}");
    //         if(current_exp <= 0){
    //             break;
    //         }
    //     };

    //     return result;
    // }
}

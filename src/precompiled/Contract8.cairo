#[starknet::contract]
pub mod Contract8 {
    use risc0_starknet::interfaces::IContract8::{IContract8};
    use core::integer::u512;
    use core::integer::u256_wide_mul;
    use core::integer::u512_safe_div_rem_by_u256;
    use core::zeroable::NonZero;
    use core::integer::u256_overflow_sub;

    const r: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    const a: u8 = 0;

    #[derive(Drop, Copy)]
    struct Point {
        x: u256,
        y: u256,
    }

    #[derive(Drop, Copy, Clone)]
    struct G1 {
        x: u256,
        y: u256,
    }

    #[derive(Drop, Copy, Clone)]
    struct G2 {
        x1: u256,
        x2: u256,
        y1: u256,
        y2: u256,
    }

    // Point at infinity (identity element)
    const POINT_INFINITY: Point = Point { x: 0, y: 0 };


    #[storage]
    struct Storage {
    }

    impl Contract8 of IContract8<ContractState> {
        fn pairing_check(self: @ContractState, input: Array<u256>) -> u256 {
            // Ensure input length is a multiple of 6
    
            let mut result = 1; // Start with the identity element
    
            // Process each pair
            for i in 0..(input.len() / 6) {
                let g1 = G1 { x: *input.at(6 * i), y: *input.at(6 * i + 1) };
                let g2 = G2 {
                    x1: *input.at(6 * i + 2),
                    x2: *input.at(6 * i + 3),
                    y1: *input.at(6 * i + 4),
                    y2: *input.at(6 * i + 5),
                };
    
                // Perform Miller loop
                let miller_result = miller_loop(g1, g2);
    
                // Multiply result into the accumulated result
                result = mod_mul(result, miller_result, r);
            };
    
            // Perform the final exponentiation
            let final_result = final_exponentiation(result, r);
    
            // Return 1 if the pairing check is valid, otherwise 0
            if final_result == 1 {
                return 1;
            } else {
                return 0;
            }
        }   
    }

    // Elliptic curve point doubling
    fn point_double(x: @u256, y: @u256) -> (u256, u256) {
        let mut ls = (3 * safe_mul_mod(x, x) + a.into());
        let ya = 2 * *y;
        let mut rs = mod_inv(@ya, @r);
        let lambda = safe_mul_mod(@ls, @rs) % r;
        ls = safe_mul_mod(@lambda,@lambda) - 2;
        let x3 = safe_mul_mod(@ls, x) % r;
        let (res, _) = u256_overflow_sub(*x, x3);
        let (res1, _) = u256_overflow_sub(safe_mul_mod(@lambda, @res), *y);
        let y3 = res1 % r;
        (x3, y3)
    }

    // Modular inverse using Extended Euclidean Algorithm
    fn mod_inv(a: @u256, p: @u256) -> u256 {
        let mut t = 0;
        let mut new_t = 1;
        let mut r = *p;
        let mut new_r = *a;

        while new_r != 0 {
            let quotient = r / new_r;
            t = new_t;
            let (res, _) = u256_overflow_sub(t, safe_mul_mod(@quotient, @new_t));
            new_t = res;
            r = new_r;
            new_r = r % new_r;
        };

        if t < 0 {
            t += *p;
        }
        t
    }


    // Miller loop implementation
    fn miller_loop(g1: G1, g2: G2) -> u256 {
        let mut f = 1; // Identity element
        let mut x = g1.x;
        let mut y = g1.y;
        let (mut x2, mut y2) = (g2.x1, g2.y1);
        for i in 0..256_u32 { // Iterate over bits of the scalar
            // Double the point
            println!("linha 410");
            let (ax, ay) = point_double(@x, @y); // BN256 curve has a = 0
            x = ax;
            y = ay;
            ax.destruct();
            ay.destruct();
            // Check the i-th bit of the scalar using the get_bit function
            println!("linha 415");
            let bit = get_bit(r, i);
            // If the bit is 1, add the point
            println!("linha 418");
            if bit == 1 {
                // Add the point
                let (ax2, ay2) = pointAdd(@x, @y, @x2, @y2);
                x = ax2;
                y = ay2;
            }
        };

        f
    }

    // Final exponentiation
    fn final_exponentiation(value: u256, p: u256) -> u256 {
        // The final exponentiation step typically involves modular exponentiation
        mod_exp(value, p - 2, p)
    }

    // Modular exponentiation
    fn mod_exp(base: u256, exp: u256, p: u256) -> u256 {
        let mut result = 1;
        let mut base = base;
        let mut exp = exp;

        while exp > 0 {
            if exp % 2 == 1 {
                result = (result * base) % p;
            }
            base = (base * base) % p;
            exp /= 2;
        };

        result
    }

    fn inv(x: @u256) -> u256 {
        let rs = r - 2;
        return pow(x, @rs);
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

    fn pointAdd(x1: @u256, y1: @u256, x2: @u256, y2: @u256) -> (u256, u256) {
        let mut lambda = 0;
        if x1 == x2 && y1 == y2 {
            let leftSide = (3 * safe_mul_mod(x1,x1) + a.into());
            let cs = 2 * *y1;
            let rightSide = inv(@cs);
            lambda = safe_mul_mod(@leftSide, @rightSide) % r;
        } else {
            let (res1, _) = u256_overflow_sub(*y2,*y1);
            let (res2, _) = u256_overflow_sub(*x2,*x1);
            let rs = inv(@res2);
            lambda = safe_mul_mod(@res1, @rs);
            res1.destruct();
            res2.destruct();
        }
        let (res1, _) = u256_overflow_sub(safe_mul_mod(@lambda, @lambda), *x1);
        let (res2, _) = u256_overflow_sub(res1, *x2);
        res1.destruct();
        let x3 = res2 % r;
        let x3r = @x3;
        res2.destruct();
        let (rig, _) = u256_overflow_sub(*x1, *x3r);
        
        let (sr, _) = u256_overflow_sub(safe_mul_mod(@lambda, @rig),*y1);
        rig.destruct();
        let y3 = sr % r;
        sr.destruct();
        return (x3, y3);
    }

    fn safe_mul_mod(a: @u256, b: @u256) -> u256{
        let mut re = u256_wide_mul(*a, *b);
        let nzm: NonZero<u256> = r.try_into().unwrap();
        let (_, res) = u512_safe_div_rem_by_u256(re, nzm);
        re.destruct();
        nzm.destruct();
        return res;
    }

    fn power_of_two(i: u32) -> u256 {
        let mut result = 1; // Start with 2^0 = 1

        for _ in 0..i {
            result = result * 2; // Multiply by 2 iteratively
        };

        result
    }

    fn get_bit(n: u256, i: u32) -> u256 {
        // Compute n // (2^i), and check the remainder when divided by 2 to get the bit
        let divisor = power_of_two(i);
        let bit_value = (n / divisor) % 2;
        bit_value
    }

    fn mod_mul(a: u256, b: u256, p: u256) -> u256 {
        (a * b) % p
    }
}
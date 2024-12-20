#[starknet::contract]
pub mod Groph16Verifier {
    use super::super::super::interfaces::IContract8::IContract8DispatcherTrait;
use super::super::super::interfaces::IContract6::IContract6DispatcherTrait;
use super::super::super::interfaces::IContract7::IContract7DispatcherTrait;
use starknet::storage::StoragePointerReadAccess;
use starknet::storage::StoragePointerWriteAccess;
use risc0_starknet::interfaces::IGroph16Verifier::{IGroph16Verifier};
    use risc0_starknet::interfaces::IContract7::{IContract7Dispatcher};
    use risc0_starknet::interfaces::IContract6::{IContract6Dispatcher};
    use risc0_starknet::interfaces::IContract8::{IContract8Dispatcher};
    use starknet::{ContractAddress};
    use core::integer::u512;
    use core::integer::u256_wide_mul;
    use core::integer::u512_safe_div_rem_by_u256;
    use core::zeroable::NonZero;
    use core::integer::u256_overflow_sub;
    



    const max_u128: u128 = 0xffffffffffffffffffffffffffffffff_u128;
    const max_u256: u256 = u256 { low: max_u128, high: max_u128 };

    const a: u8 = 0;

    const b: u8 = 3;
    // Scalar field size
    const max: u256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    const compac: u256 =
        100000000000000000000000000000000000000000000000000000000000000000000000000000;
    const r: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    const q: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    const alphax: u256 =
        20491192805390485299153009773594534940189261866228447918068658471970481763042;
    const alphay: u256 =
        9383485363053290200918347156157836566562967994039712273449902621266178545958;
    const betax1: u256 =
        4252822878758300859123897981450591353533073413197771768651442665752259397132;
    const betax2: u256 =
        6375614351688725206403948262868962793625744043794305715222011528459656738731;
    const betay1: u256 =
        21847035105528745403288232691147584728191162732299865338377159692350059136679;
    const betay2: u256 =
        10505242626370262277552901082094356697409835680220590971873171140371331206856;
    const gammax1: u256 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    const gammax2: u256 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    const gammay1: u256 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    const gammay2: u256 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;
    const deltax1: u256 =
        1668323501672964604911431804142266013250380587483576094566949227275849579036;
    const deltax2: u256 =
        12043754404802191763554326994664886008979042643626290185762540825416902247219;
    const deltay1: u256 =
        7710631539206257456743780535472368339139328733484942210876916214502466455394;
    const deltay2: u256 =
        13740680757317479711909903993315946540841369848973133181051452051592786724563;

    const IC0x: u256 = 8446592859352799428420270221449902464741693648963397251242447530457567083492;
    const IC0y: u256 = 1064796367193003797175961162477173481551615790032213185848276823815288302804;

    const IC1x: u256 = 3179835575189816632597428042194253779818690147323192973511715175294048485951;
    const IC1y: u256 =
        20895841676865356752879376687052266198216014795822152491318012491767775979074;

    const IC2x: u256 = 5332723250224941161709478398807683311971555792614491788690328996478511465287;
    const IC2y: u256 =
        21199491073419440416471372042641226693637837098357067793586556692319371762571;

    const IC3x: u256 =
        12457994489566736295787256452575216703923664299075106359829199968023158780583;
    const IC3y: u256 =
        19706766271952591897761291684837117091856807401404423804318744964752784280790;

    const IC4x: u256 =
        19617808913178163826953378459323299110911217259216006187355745713323154132237;
    const IC4y: u256 =
        21663537384585072695701846972542344484111393047775983928357046779215877070466;

    const IC5x: u256 = 6834578911681792552110317589222010969491336870276623105249474534788043166867;
    const IC5y: u256 =
        15060583660288623605191393599883223885678013570733629274538391874953353488393;


    #[storage]
    struct Storage {
        contract6: ContractAddress,
        contract7: ContractAddress,
        contract8: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, c6: ContractAddress, c7: ContractAddress, c8: ContractAddress) {
        self.contract6.write(c6);
        self.contract7.write(c7);
        self.contract8.write(c8);
    }

    #[abi(embed_v0)]
    impl Groph16Verifier of IGroph16Verifier<ContractState> {
        fn verifyProof(
            self: @ContractState,
            _pA: Array<u256>,
            _pB: Array<Array<u256>>,
            _pC: Array<u256>,
            _pubSignals: Array<u256>,
        ) -> bool {
            let result = checkPairing(self,_pA, _pB, _pC, _pubSignals);
            if (result == 1) {
                return true;
            } else {
                return false;
            }
        }
    }

    fn checkField(self: @ContractState, v: @u256) -> bool {
        if (*v < r) {
            return true;
        } else {
            return false;
        }
    }

    fn checkPairing(
        self: @ContractState, _pA: Array<u256>, _pB: Array<Array<u256>>, _pC: Array<u256>, _pubSignals: Array<u256>,
    ) -> u256 {
        let mut _pVk: Array<u256> = ArrayTrait::new();
        let mut _pPairing: Array<u256> = ArrayTrait::new();
        _pVk.append(IC0x);
        _pVk.append(IC0y);
        _pVk = g1MulAccC(self,@_pVk, @IC1x, @IC1y, _pubSignals[0]);
        _pVk = g1MulAccC(self,@_pVk, @IC2x, @IC2y, _pubSignals[1]);
        _pVk = g1MulAccC(self,@_pVk, @IC3x, @IC3y, _pubSignals[3]);
        _pVk = g1MulAccC(self,@_pVk, @IC4x, @IC4y, _pubSignals[4]);
        _pVk = g1MulAccC(self,@_pVk, @IC5x, @IC5y, _pubSignals[5]);

        // -A
        _pPairing.append(*_pA.at(0));
        let lessA = (q - *_pA.at(1)) % q;
        _pPairing.append(lessA);
        lessA.destruct();
        // B
        _pPairing.append(*_pB.at(0).at(0));
        _pPairing.append(*_pB.at(0).at(1));
        _pPairing.append(*_pB.at(1).at(0));
        _pPairing.append(*_pB.at(1).at(1));

        // alpha1
        _pPairing.append(alphax);
        _pPairing.append(alphay);

        // beta2
        _pPairing.append(betax1);
        _pPairing.append(betax2);
        _pPairing.append(betay1);
        _pPairing.append(betay2);

        // vk_x
        _pPairing.append(*_pVk.at(0));
        _pPairing.append(*_pVk.at(1));
        _pVk.destruct();

        // gamma2
        _pPairing.append(gammax1);
        _pPairing.append(gammax2);
        _pPairing.append(gammay1);
        _pPairing.append(gammay2);

        // C
        _pPairing.append(*_pC.at(0));
        _pPairing.append(*_pC.at(1));

        // delta2
        _pPairing.append(deltax1);
        _pPairing.append(deltax2);
        _pPairing.append(deltay1);
        _pPairing.append(deltay2);
        let result = IContract8Dispatcher{contract_address: self.contract8.read()}.pairing_check(_pPairing);
        return result;
    }

    fn g1MulAccC(self: @ContractState,pR: @Array<u256>, x: @u256, y: @u256, s: @u256) -> Array<u256> {
        let mut mIn = ArrayTrait::new();
        let mut result: Array<u256> = ArrayTrait::new();
        mIn.append(*x);
        mIn.append(*y);
        mIn.append(*s);

        let (result_x, result_y) = IContract7Dispatcher{contract_address: self.contract7.read()}.BN256ScalarMultiplication(*x,*y,*s);
        mIn = updateElement(@mIn, 0, result_x);
        mIn = updateElement(@mIn, 1, result_y);

        mIn = updateElement(@mIn, 2, *pR.at(0));
        mIn.append(*pR.at(1));
        let (x3, y3) = IContract6Dispatcher{contract_address: self.contract6.read()}.ecAdd(*mIn.at(0), *mIn.at(1), *mIn.at(2), *mIn.at(3));
        result.append(x3);
        result.append(y3);
        return result;
    }

    fn updateElement(array: @Array<u256>, index: u256, newElement: u256) -> Array<u256> {
        let mut new_arr = ArrayTrait::new();

        let arr_len = array.len();
        for i in 0..arr_len {
            if i.into() == index {
                new_arr.append(newElement);
            } else {
                new_arr.append(*array.at(i));
            }
        };
        return new_arr;
    }


    

    
}

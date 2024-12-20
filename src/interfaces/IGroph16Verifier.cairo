#[starknet::interface]
pub trait IGroph16Verifier<TContractState> {
    fn verifyProof(self: @TContractState, _pA: Array<u256>, _pB: Array<Array<u256>>, _pC: Array<u256>, _pubSignals: Array<u256>) -> bool;
}
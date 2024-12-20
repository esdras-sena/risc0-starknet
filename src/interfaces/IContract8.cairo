#[starknet::interface]
pub trait IContract8<TContractState> {
    fn pairing_check(self: @TContractState, input: Array<u256>) -> u256;
}
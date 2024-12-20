#[starknet::interface]
pub trait IContract7<TContractState> {
    fn BN256ScalarMultiplication(self: @TContractState, x: u256, y: u256, s: u256) -> (u256, u256);
}
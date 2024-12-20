#[starknet::interface]
pub trait IContract6<TContractState> {
    fn ecAdd(self: @TContractState, x1: u256, y1: u256, x2: u256, y2: u256) -> (u256, u256);
}
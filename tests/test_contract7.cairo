use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use risc0_starknet::interfaces::IContract7::{
    IContract7Dispatcher, IContract7SafeDispatcher, IContract7DispatcherTrait,
    IContract7SafeDispatcherTrait,
};


fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
#[available_gas(9_000_000)]
fn test_verifyProof_validProof() {
    let contract_address = deploy_contract("Contract7");
    let dispatcher = IContract7Dispatcher { contract_address: contract_address };
    let x: u256 = 8446592859352799428420270221449902464741693648963397251242447530457567083492;
    
    let y: u256 = 1064796367193003797175961162477173481551615790032213185848276823815288302804;
   
    let s: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    let (x,y)=dispatcher.BN256ScalarMultiplication(x,y,s);

    println!("x {x}");
    println!("y {y}");
}
// #[test]
// fn test_increase_balance() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let dispatcher = IHelloStarknetDispatcher { contract_address };

//     let balance_before = dispatcher.get_balance();
//     assert(balance_before == 0, 'Invalid balance');

//     dispatcher.increase_balance(42);

//     let balance_after = dispatcher.get_balance();
//     assert(balance_after == 42, 'Invalid balance');
// }

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }


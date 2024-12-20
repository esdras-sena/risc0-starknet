// use starknet::ContractAddress;

// use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// // use risc0_starknet::IHelloStarknetSafeDispatcher;
// // use risc0_starknet::IHelloStarknetSafeDispatcherTrait;
// // use risc0_starknet::IHelloStarknetDispatcher;
// // use risc0_starknet::IHelloStarknetDispatcherTrait;
// use risc0_starknet::interfaces::IGroph16Verifier::{IGroph16VerifierSafeDispatcher};
// use risc0_starknet::interfaces::IGroph16Verifier::{IGroph16VerifierSafeDispatcherTrait};
// use risc0_starknet::interfaces::IGroph16Verifier::{IGroph16VerifierDispatcher};
// use risc0_starknet::interfaces::IGroph16Verifier::{IGroph16VerifierDispatcherTrait};


// fn deploy_contract(name: ByteArray) -> ContractAddress {
//     let contract = declare(name).unwrap().contract_class();
//     let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
//     contract_address
// }

// #[test]
// fn test_verifyProof_validProof() {
//     let contract_address = deploy_contract("Groph16Verifier");
//     let dispatcher = IGroph16VerifierDispatcher { contract_address: contract_address };
//     // Inputs for a valid proof
//     let mut pA: Array<u256> = ArrayTrait::new();
//     pA.append(1234);
//     pA.append(5678);
//     let mut pB: Array<Array<u256>> = ArrayTrait::new();
//     let mut pB1: Array<u256> = ArrayTrait::new();
//     pB1.append(91011);
//     pB1.append(121314);
//     let mut pB2 = ArrayTrait::new();
//     pB2.append(151617);
//     pB2.append(181920);
//     pB.append(pB1);
//     pB.append(pB2);
//     let mut pC: Array<u256> = ArrayTrait::new();
//     pC.append(212223);
//     pC.append(242526);
//     let mut pubSignals: Array<u256> = ArrayTrait::new();
//     pubSignals.append(1);
//     pubSignals.append(2);
//     pubSignals.append(3);
//     pubSignals.append(4);
//     pubSignals.append(5);
//     pubSignals.append(6);

//     let result = dispatcher.verifyProof(pA, pB, pC, pubSignals);
//     assert!(result == true);
// }

// // #[test]
// // fn test_increase_balance() {
// //     let contract_address = deploy_contract("HelloStarknet");

// //     let dispatcher = IHelloStarknetDispatcher { contract_address };

// //     let balance_before = dispatcher.get_balance();
// //     assert(balance_before == 0, 'Invalid balance');

// //     dispatcher.increase_balance(42);

// //     let balance_after = dispatcher.get_balance();
// //     assert(balance_after == 42, 'Invalid balance');
// // }

// // #[test]
// // #[feature("safe_dispatcher")]
// // fn test_cannot_increase_balance_with_zero_value() {
// //     let contract_address = deploy_contract("HelloStarknet");

// //     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

// //     let balance_before = safe_dispatcher.get_balance().unwrap();
// //     assert(balance_before == 0, 'Invalid balance');

// //     match safe_dispatcher.increase_balance(0) {
// //         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
// //         Result::Err(panic_data) => {
// //             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
// //         }
// //     };
// // }

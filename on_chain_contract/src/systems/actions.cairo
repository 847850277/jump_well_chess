use dojo_starter::models::{Direction};

// define the interface
#[starknet::interface]
trait IActions<T> {
    fn create_game(ref self: T);
    fn joining_game(ref self: T);
    fn move(ref self: T, direction: Direction, position: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions, Direction};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Players, Position};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        fn create_game(ref self: ContractState) {

        }

        fn joining_game(ref self: ContractState) {

        }

        fn move(ref self: ContractState, direction: Direction, position: u32) -> bool{

            true
        }

    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"dojo_starter")
        }
    }
}


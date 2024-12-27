use dojo_starter::models::{Direction};

// define the interface
#[starknet::interface]
trait IActions<T> {
    // create_game
    fn create_game(ref self: T);
    // joining_game
    fn joining_game(ref self: T);

    // game move function
    fn move(ref self: T, direction: Direction, position: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions, Direction};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Players, Position,Container,Item};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        fn create_game(ref self: ContractState) {

            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // init container
            let mut grids: Array<Item> = array![];
            let item_a = Item {  name: 'A',occupied: true};
            let item_b = Item {  name: 'B',occupied: false};
            let item_c = Item {  name: 'C',occupied: false};
            let item_d = Item {  name: 'D',occupied: true};
            let item_e = Item {  name: 'E',occupied: false};
            grids.append(item_a);
            grids.append(item_b);
            grids.append(item_c);
            grids.append(item_d);
            grids.append(item_e);

            let container = Container { last_move_player: player, grids };
            world.write_model(@container);
            // init position
            let position_one = Position { player, x: -1, y: 1, name: 'A' };
            let position_two = Position { player, x: 1, y: 1, name: 'D' };
            world.write_model(@position_one);
            world.write_model(@position_two);


            // init player

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

// fn next_position(mut position: Position, direction: Direction) -> Position {
//     match direction {
//         Direction::Left => { position.x -= 1; },
//         Direction::Right => { position.x += 1; },
//         Direction::Up => { position.y += 1; },
//         Direction::Down => { position.y -= 1; },
//         Direction::LeftDown => {
//             position.x -= 1;
//             position.y -= 1;
//         },
//         Direction::LeftUp => {
//             position.x -= 1;
//             position.y += 1;
//         },
//         Direction::RightDown => {
//             position.x += 1;
//             position.y -= 1;
//         },
//         Direction::RightUp => {
//             position.x += 1;
//             position.y += 1;
//         },
//     };
//     position
// }

use dojo_starter::models::{Direction};

// define the interface
#[starknet::interface]
trait IActions<T> {
    // create_game
    fn create_game(ref self: T) -> u32;
    // joining_game
    fn joining_game(ref self: T, game_id: u32);

    // game move function,then return the game result true means you win, false means game continue
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

        // account_1_create_game
        fn create_game(ref self: ContractState) -> u32{

            let game_id = 1;
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            //TODO exist_player
            //let exist_player: Players = world.read_model(player);
            //assert(exist_player.player == player, 'Player already exist');

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

            let container = Container { game_id,last_move_player: player, grids };
            world.write_model(@container);
            // init position
            let position_one = Position { player, x: -1, y: 1, name: 'A' };
            let position_two = Position { player, x: 1, y: 1, name: 'D' };
            world.write_model(@position_one);
            world.write_model(@position_two);

            // init player
            let players_one = Players {
                        player,
                        position_one,
                        position_two,
                        can_move: false,
            };
            world.write_model(@players_one);

            game_id
        }

        // account_2_joining_game
        fn joining_game(ref self: ContractState, game_id: u32) {

            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            //TODO check_exist_container
            let mut exist_container: Container = world.read_model(game_id);
            assert!(exist_container.game_id != game_id, "container not exist");


            //TODO exist_player
            //let exist_player: Players = world.read_model(player);
            //assert(exist_player.player == player, 'Player already exist');



            let position_three = Position { player, x: -1, y: -1, name: 'B' };
            let position_four = Position { player, x: 1, y: -1, name: 'C' };
            world.write_model(@position_three);
            world.write_model(@position_four);
            // update container
            //for i in 0..exist_container.grids.len() {
            //    let mut grid_item = exist_container.grids.index(i);
            //    if grid_item.name == 'B' {
            //        grid_item.occupied = true;
            //    }
            //    if grid_item.name == 'C' {
            //        grid_item.occupied = true;
            //    }
            //    exist_container.grids.set(i, grid_item);
            //}
            exist_container.last_move_player = player;
            world.write_model(@exist_container);


            // player_one can move
            let mut players_one: Players = world.read_model(exist_container.last_move_player);
            players_one.can_move = true;
            world.write_model(@players_one);

            // init player_two
            let players_two = Players {
                        player,
                        position_one: position_three,
                        position_two: position_four,
                        can_move: false,
            };
            world.write_model(@players_two);

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

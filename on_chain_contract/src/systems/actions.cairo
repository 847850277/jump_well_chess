use dojo_starter::models::{Position};
use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
trait IActions<T> {
    // create_game
    fn create_game(ref self: T) -> u8;
    // joining_game
    fn joining_game(ref self: T, game_id: u8);

    // game move function,then return the game result true means you win, false means game continue
    fn move(ref self: T, from: u8, to: u8, game_id: u8) -> bool;
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions,same_address};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Players, Position, Container, Item, Counter, CounterTrait};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GameStatusEvent {
        #[key]
        pub game_id: u8,
        pub status: u8,
    }

    // #[derive(Copy, Drop, Serde)]
    // #[dojo::event]
    // pub struct TestEventTwo {
    //     #[key]
    //     pub player: ContractAddress,
    //     pub p: Players,
    // }


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        // account_1_create_game
        fn create_game(ref self: ContractState) -> u8{

            let game_status: u8 = 0;
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

             // Get or create counter
            let mut session_counter: Counter = world.read_model(('id',));
            session_counter.increment();
            let game_id = session_counter.get_value();
            // Write the counter back to the world
            world.write_model(@session_counter);

            //exist_player
            //let exist_player: Players = world.read_model(player);
            //assert(exist_player.player == player, 'player existed');

            //let contract_zero: ContractAddress  = 0;
            let contract_zero = starknet::contract_address_const::<0x0>();
            // init container
            let mut grids: Array<Item> = array![];
            let item_0 = Item {  name: 0,occupied: true,player: player};
            let item_1 = Item {  name: 1,occupied: false,player: contract_zero};
            let item_2 = Item {  name: 2,occupied: false,player: contract_zero};
            let item_3 = Item {  name: 3,occupied: true,player: player};
            let item_4 = Item {  name: 4,occupied: false,player: contract_zero};
            grids.append(item_0);
            grids.append(item_1);
            grids.append(item_2);
            grids.append(item_3);
            grids.append(item_4);

            let container = Container { game_id,status: game_status,creator: player,last_move_player: player,winner: contract_zero, grids };
            world.write_model(@container);
            // init position
            let position_one = Position { player,name: 0};
            let position_two = Position { player,name: 3};

            // init player
            let players_one = Players {
                        player,
                        game_id,
                        position_one,
                        position_two,
                        can_move: false,
                        color: 'Green',
                        is_winner: false,
            };
            world.write_model(@players_one);
            world.emit_event(@GameStatusEvent { game_id, status: game_status});
            game_id
        }

        // account_2_joining_game
        fn joining_game(ref self: ContractState, game_id: u8) {

            let game_status: u8 = 1;
            let contract_zero = starknet::contract_address_const::<0x0>();
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // if container not init ,will set default value
            let mut exist_container: Container = world.read_model(game_id);
            world.write_model(@exist_container);
            //check null by creator == 0
            assert(exist_container.creator.is_non_zero(), 'game must create');
            let same_player = same_address(player, exist_container.creator);
            assert(!same_player, 'player must not creator');
            assert!(exist_container.status == 0 , "status must 0");
            let position_three = Position { player,name: 1};
            let position_four = Position { player,name: 2};

            let mut grids: Array<Item> = array![];
            // update container
            for i in 0..exist_container.grids.len() {
                let mut grid_item = *exist_container.grids.at(i);
                if grid_item.name == 1 {
                    grid_item.occupied = true;
                    grid_item.player = player;
                }
                if grid_item.name == 2 {
                    grid_item.occupied = true;
                    grid_item.player = player;
                }
                grids.append(grid_item);
            };
            let container = Container { game_id, status: game_status,creator: exist_container.creator,last_move_player: player, winner: contract_zero,grids };
            world.write_model(@container);

            // player_one can move
            // can not get players_one
            let last_move_player = exist_container.last_move_player;
            let mut players_one: Players = world.read_model((last_move_player,game_id));
            let players_one = Players {
                        player: last_move_player,
                        game_id,
                        position_one: players_one.position_one,
                        position_two: players_one.position_two,
                        can_move: true,
                        color: players_one.color,
                        is_winner: false,
            };
            world.write_model(@players_one);

            // init player_two
            let players_two = Players {
                player,
                game_id,
                position_one: position_three,
                position_two: position_four,
                can_move: false,
                color: 'ORANGE',
                is_winner: false,
            };
            world.write_model(@players_two);
            world.emit_event(@GameStatusEvent { game_id, status: game_status});

        }

        // move
        fn move(ref self: ContractState, from: u8, to: u8, game_id: u8) -> bool{

            let mut game_status: u8 = 1;
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let mut player = get_caller_address();

            //let game_id: u32 = 1;
            let mut exist_container: Container = world.read_model(game_id);

            assert(exist_container.creator.is_non_zero(), 'game must create');
            // check game end status
            assert!(exist_container.status == 1, "game not ing");

            let mut players: Players = world.read_model((player,game_id));
            // check can move
            assert!(players.can_move == true, "current players can not move");
            //create  an array to check result
            let mut result_arr: Array<u8> = array![];
            let mut grids: Array<Item> = array![];

            // can not move 0 --> 3 || 3 --> 0
            if(from == 0 && to == 3){
                assert(true, 'can not move 0 --> 3');
            }
            if(from == 0 && to == 2){
                assert(true, 'can not move 0 --> 2');
            }
            if(from == 1 && to == 3){
                assert(true, 'can not move 1 --> 3');
            }
            if(from == 2 && to == 0){
                assert(true, 'can not move 2 --> 0');
            }
            if(from == 3 && to == 0){
                assert(true, 'can not move 3 --> 0');
            }
            if(from == 3 && to == 1){
                assert(true, 'can not move 3 --> 1');
            }

            // check from is valid position
            let mut valid_position = false;
            if(from == players.position_one.name || from == players.position_two.name){
                valid_position = true;
            }
            assert!(valid_position == true, "from position is invalid");
            // check to is valid position
            let mut valid_to_position = false;
            for i in 0..exist_container.grids.len() {
                let mut grid_item = *exist_container.grids.at(i);
                if(grid_item.name == to && grid_item.occupied == false){
                    valid_to_position = true;
                }
            };
            assert!(valid_to_position == true, "to position is invalid");

            // change player status
            if(players.position_one.name == from){
                players.position_one = Position { player, name: to };
            }
            if(players.position_two.name == from){
                players.position_two = Position { player, name: to };
            }
            players.can_move = false;

            // change container status
            let contract_zero = starknet::contract_address_const::<0x0>();
            for i in 0..exist_container.grids.len() {
                let mut grid_item = *exist_container.grids.at(i);
                if grid_item.name == from {
                    grid_item.occupied = false;
                    grid_item.player = contract_zero;
                }
                if grid_item.name == to {
                    grid_item.occupied = true;
                    grid_item.player = player;
                }
                if grid_item.occupied == true {
                    result_arr.append(1);
                }else{
                    result_arr.append(0);
                }
                grids.append(grid_item);
            };
            //let container = Container { game_id, status: game_status, creator: exist_container.creator, last_move_player: player, grids };
            // change player_two status
            let last_move_player = exist_container.last_move_player;
            let mut players_two: Players = world.read_model((last_move_player,game_id));
            let players_two = Players {
                player: last_move_player,
                game_id,
                position_one: players_two.position_one,
                position_two: players_two.position_two,
                can_move: true,
                color: players_two.color,
                is_winner: false,
            };
            world.write_model(@players_two);
            // if can move return false else return true
            let mut winner = starknet::contract_address_const::<0x0>();
            // check game result
            // array [1,0,1,1,1] or [1,1,1,0,1] means game over
            let mut result = false;
            let first_check_value: u8 = *result_arr.at(1);
            let last_check_value: u8 = *result_arr.at(3);
            if(first_check_value == 0){
                // players in position 0、4
                if(players.position_one.name == 0 && players.position_two.name == 4){
                    result = true;
                    game_status = 2;
                }

                if(players.position_one.name == 4 && players.position_two.name == 0){
                    result = true;
                    game_status = 2;
                }

            }
            if(last_check_value == 0){
                // players in position 2、4
                if(players.position_one.name == 2 && players.position_two.name == 4){
                    result = true;
                    game_status = 2;
                }
                if(players.position_one.name == 4 && players.position_two.name == 2){
                    result = true;
                    game_status = 2;
                }
            }
            if(game_status == 2){
                players.is_winner = true;
                winner = players.player
            }
            world.write_model(@players);
            let container = Container { game_id, status: game_status, creator: exist_container.creator, last_move_player: player,winner, grids };
            world.write_model(@container);
            //game end event
            world.emit_event(@GameStatusEvent { game_id, status: game_status});
            result
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


fn same_address(p1: ContractAddress,p2: ContractAddress) -> bool {
    if(p1 == p2){
        return true;
    }
    false
}


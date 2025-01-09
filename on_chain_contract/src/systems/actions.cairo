use starknet::{ContractAddress};

// define the interface
#[starknet::interface]
trait IActions<T> {
    // create_game
    fn create_game(ref self: T) -> u32;
    // joining_game
    fn joining_game(ref self: T, game_id: u32);

    // game move function,then return the game result true means you win, false means game continue
    fn move(ref self: T, from: u8, to: u8, game_id: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions,same_address};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Container, Item, Counter, CounterTrait};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GameStatusEvent {
        #[key]
        pub game_id: u32,
        pub status: u8,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        // account_1_create_game
        fn create_game(ref self: ContractState) -> u32{

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
            world.emit_event(@GameStatusEvent { game_id, status: game_status});
            game_id
        }

        // account_2_joining_game
        fn joining_game(ref self: ContractState, game_id: u32) {

            let game_status: u8 = 1;
            let contract_zero = starknet::contract_address_const::<0x0>();
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // if container not init ,will set default value
            let mut exist_container: Container = world.read_model(game_id);
            //check null by creator == 0
            assert(exist_container.creator.is_non_zero(), 'game must create');
            assert!(exist_container.status == 0 , "status must 0");
            let same_player = same_address(player, exist_container.creator);
            assert(!same_player, 'player must not creator');

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
            world.emit_event(@GameStatusEvent { game_id, status: game_status});

        }

        // move
        fn move(ref self: ContractState, from: u8, to: u8, game_id: u32) -> bool{

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

            let same_player = same_address(player, exist_container.last_move_player);
            assert(!same_player, 'move can not last_move_player');
            //create  an array to check result
            let mut result_arr: Array<u8> = array![];
            let mut grids: Array<Item> = array![];

            // can not move 0 --> 3
            if(from == 0 && to == 3){
                assert(true, 'can not move 0 --> 3');
            }
            if(from == 1 && to == 2){
                assert(true, 'can not move 1 --> 2');
            }
            if(from == 1 && to == 3){
                assert(true, 'can not move 1 --> 3');
            }
            if(from == 2 && to == 1){
                assert(true, 'can not move 2 --> 1');
            }
            if(from == 3 && to == 0){
                assert(true, 'can not move 3 --> 0');
            }
            if(from == 3 && to == 1){
                assert(true, 'can not move 3 --> 1');
            }

            // check from is valid position
            //let mut valid_from_position = false;
            // check to is valid position
            //let mut valid_to_position = false;
            //for i in 0..exist_container.grids.len() {
            //    let mut grid_item = *exist_container.grids.at(i);
            //    if(grid_item.name == to && grid_item.occupied == false){
            //        valid_to_position = true;
            //    }
            //    if(grid_item.name == from && grid_item.occupied == true && same_address(grid_item.player, player)){
            //        valid_from_position = true;
            //    }
            //};
            //assert!(valid_to_position == true, "to position is invalid");
            //assert!(valid_from_position == true, "from position is invalid");

            // change container status
            let contract_zero = starknet::contract_address_const::<0x0>();
            // move
            let mut position_one: u8 = 5;
            let mut position_two: u8 = 5;
            for i in 0..exist_container.grids.len() {
                let mut grid_item = *exist_container.grids.at(i);
                if grid_item.name == from {
                    grid_item.occupied = false;
                    grid_item.player = contract_zero;
                }
                if grid_item.name == to {
                    grid_item.occupied = true;
                    grid_item.player = player;
                    position_one = grid_item.name;
                }
                // p2 position
                if(grid_item.occupied == true && same_address(grid_item.player, player) && grid_item.name != to){
                    position_two = grid_item.name;
                }
                if grid_item.occupied == true {
                    result_arr.append(1);
                }else{
                    result_arr.append(0);
                }
                grids.append(grid_item);
            };
            // if can move return false else return true
            let mut winner = starknet::contract_address_const::<0x0>();
            // check game result
            // array [1,0,1,1,1] or [1,1,1,0,1] means game over
            let mut result = false;
            let first_check_value: u8 = *result_arr.at(1);
            let last_check_value: u8 = *result_arr.at(3);
            if(first_check_value == 0){
                // players in position 0、4
                if(position_one == 0 && position_two == 4){
                    result = true;
                    game_status = 2;
                }
                if(position_one == 4 && position_two == 0){
                    result = true;
                    game_status = 2;
                }
            }
            if(last_check_value == 0){
                // players in position 2、4
                if(position_one == 2 && position_two == 4){
                    result = true;
                    game_status = 2;
                }
                if(position_one == 4 && position_two == 2){
                    result = true;
                    game_status = 2;
                }
            }
            if(game_status == 2){
                winner = player;
            }
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


use dojo_starter::models::{Position};

// define the interface
#[starknet::interface]
trait IActions<T> {
    // create_game
    fn create_game(ref self: T) -> u32;
    // joining_game
    fn joining_game(ref self: T);

    // game move function,then return the game result true means you win, false means game continue
    fn move(ref self: T, direction: u32, position: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions,next_position};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Players, Position,Container,Item};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct TestEvent {
        #[key]
        pub player: ContractAddress,
        pub game_id: u32,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct TestEventTwo {
        #[key]
        pub player: ContractAddress,
        pub p: Players,
    }


    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        // account_1_create_game
        fn create_game(ref self: ContractState) -> u32{

            let game_id: u32 = 1;
            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            //exist_player
            let exist_player: Players = world.read_model(player);
            assert(exist_player.player == player, 'player existed');

            // init container
            let mut grids: Array<Item> = array![];
            let item_a = Item {  name: 0,occupied: true};
            let item_b = Item {  name: 1,occupied: false};
            let item_c = Item {  name: 2,occupied: false};
            let item_d = Item {  name: 3,occupied: true};
            let item_e = Item {  name: 4,occupied: false};
            grids.append(item_a);
            grids.append(item_b);
            grids.append(item_c);
            grids.append(item_d);
            grids.append(item_e);

            let container = Container { game_id,last_move_player: player, grids };
            world.write_model(@container);
            // init position
            let position_one = Position { player,name: 0};
            let position_two = Position { player,name: 3};

            // init player
            let players_one = Players {
                        player,
                        position_one,
                        position_two,
                        can_move: false,
                        color: 'Green',
            };
            world.write_model(@players_one);
            //world.emit_event(@TestEvent { player, game_id });
            game_id
        }

        // account_2_joining_game
        fn joining_game(ref self: ContractState) {

            let game_id: u32 = 1;

            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            //TODO check_exist_container
            let mut exist_container: Container = world.read_model(game_id);
            //assert(exist_container.game_id != game_id, "container not exist");
            let position_three = Position { player,name: 1};
            let position_four = Position { player,name: 2};

            let mut grids: Array<Item> = array![];
            // update container
            for i in 0..exist_container.grids.len() {
                let mut grid_item = *exist_container.grids.at(i);
                if grid_item.name == 1 {
                    grid_item.occupied = true;
                }
                if grid_item.name == 2 {
                    grid_item.occupied = true;
                }
                grids.append(grid_item);
            };
            let container = Container { game_id,last_move_player: player, grids };
            world.write_model(@container);

            // player_one can move
            // can not get players_one
            let last_move_player = exist_container.last_move_player;
            let mut players_one: Players = world.read_model(last_move_player);
            let players_one = Players {
                        player: last_move_player,
                        position_one: players_one.position_one,
                        position_two: players_one.position_two,
                        can_move: true,
                        color: players_one.color,
            };
            world.write_model(@players_one);

            // init player_two
            let players_two = Players {
                player,
                position_one: position_three,
                position_two: position_four,
                can_move: false,
                color: 'ORANGE',
            };
            world.write_model(@players_two);

            //world.emit_event(@TestEventTwo { player, p: players_two});
            //world.emit_event(@TestEventTwo { player, p: players_one});

        }

        // move
        fn move(ref self: ContractState, direction: u32, position: u32) -> bool{
            assert!(position == 1 || position == 2, "position must be 1 or 2");

            // Get the default world.
            let mut world = self.world_default();
            // Get the address of the current caller, possibly the player's address.
            let mut player = get_caller_address();

            let game_id: u32 = 1;
            let mut exist_container: Container = world.read_model(game_id);

            let mut players: Players = world.read_model(player);
            // check can move
            assert!(players.can_move == true, "current players can not move");

            let mut result = false;

            if(position == 1){
                let mut position = players.position_one;
                let new_position = next_position(position, direction);
                players.position_one = new_position;
                players.can_move = false;
                world.write_model(@players);

                // update container
                let mut grids: Array<Item> = array![];
                for i in 0..exist_container.grids.len() {
                    let mut grid_item = *exist_container.grids.at(i);
                    if grid_item.name == position.name {
                        grid_item.occupied = false;
                    }
                    if grid_item.name == new_position.name {
                        grid_item.occupied = true;
                    }
                    grids.append(grid_item);
                };
                let container = Container { game_id,last_move_player: player, grids };
                world.write_model(@container);

                // last_move_player
                let last_move_player = exist_container.last_move_player;
                let mut players_two: Players = world.read_model(last_move_player);
                let players_two = Players {
                            player: last_move_player,
                            position_one: players_two.position_one,
                            position_two: players_two.position_two,
                            can_move: true,
                            color: players_two.color,
                };
                world.write_model(@players_two);
            }
            if(position == 2){
                let mut position = players.position_two;
                let new_position = next_position(position, direction);
                players.position_two = new_position;
                players.can_move = false;
                world.write_model(@players);

                // update container
                let mut grids: Array<Item> = array![];
                for i in 0..exist_container.grids.len() {
                    let mut grid_item = *exist_container.grids.at(i);
                    if grid_item.name == position.name {
                        grid_item.occupied = false;
                    }
                    if grid_item.name == new_position.name {
                        grid_item.occupied = true;
                    }
                    grids.append(grid_item);
                };
                let container = Container { game_id,last_move_player: player, grids };
                world.write_model(@container);

                // last_move_player
                let last_move_player = exist_container.last_move_player;
                let mut players_one: Players = world.read_model(last_move_player);
                let players_one = Players {
                            player: last_move_player,
                            position_one: players_one.position_one,
                            position_two: players_one.position_two,
                            can_move: true,
                            color: players_one.color,
                };
                world.write_model(@players_one);
            }
            // if can move return false else return true
            // TODO check game result


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


fn next_position(mut position: Position, direction: u32) -> Position {
    if(position.name == 0){
        if(direction == 2){
            return Position { player: position.player, name: 3 };
        }
        if(direction == 4){
           return Position { player: position.player, name: 1 };
        }
        if(direction == 7){
            return Position { player: position.player, name: 4 };
        }
    }
    if(position.name == 1){
            if(direction == 2){
                return Position { player: position.player, name: 2 };
            }
            if(direction == 3){
                return Position { player: position.player,  name: 0 };
            }
            if(direction == 8){
                return Position { player: position.player,  name: 4 };
            }
    }

    if(position.name == 2){
        if(direction == 1){
            return Position { player: position.player, name: 1 };
        }
        if(direction == 3){
            return Position { player: position.player, name: 3 };
        }
        if(direction == 6){
            return Position { player: position.player,  name: 4 };
        }

    }

    if(position.name == 3){

        if(direction == 1){
            return Position { player: position.player,  name: 0 };
        }
        if(direction == 4){
            return Position { player: position.player,  name: 2 };
        }
        if(direction == 5){
            return Position { player: position.player, name: 4 };
        }
    }

    if(position.name == 4){
        if(direction == 5){
            return Position { player: position.player, name: 1 };
        }
        if(direction == 6){
            return Position { player: position.player,  name: 0 };
        }
        if(direction == 7){
            return Position { player: position.player,  name: 2 };
        }
        if(direction == 8){
            return Position { player: position.player,  name: 3 };
        }
    }

    position
}

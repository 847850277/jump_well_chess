use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Players {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub game_id: u64,
    pub position_one: Position,
    pub position_two: Position,
    pub can_move: bool,
    pub color: felt252,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Position {
    pub player: ContractAddress,
    pub name: u8,
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct Container {
    #[key]
    pub game_id: u64,
    // game status 0: created, 1: joined, 2: finished
    pub status: u8,
    pub creator: ContractAddress,
    pub last_move_player: ContractAddress,
    pub grids: Array<Item>,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Item {
    pub name: u8,
    pub occupied: bool,
    pub player: ContractAddress,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Counter {
    #[key]
    pub global_key: felt252,
    value: u64
}

#[generate_trait]
impl CounterImpl of CounterTrait {
    fn get_value(self: Counter) -> u64 {
        self.value
    }

    fn increment(ref self: Counter) -> () {
        self.value += 1;
    }

    fn decrement(ref self: Counter) -> () {
        self.value -= 1;
    }

    fn reset(ref self: Counter) -> () {
        self.value = 0;
    }
}





use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Players {
    #[key]
    pub player: ContractAddress,
    pub position_one: Position,
    pub position_two: Position,
    pub can_move: bool,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Position {
    pub player: ContractAddress,
    pub x: i32,
    pub y: i32,
    pub name: felt252,
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct Container {
    #[key]
    pub game_id: u32,
    pub last_move_player: ContractAddress,
    pub grids: Array<Item>,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Item {
    pub name: felt252,
    pub occupied: bool
}

#[derive(Serde, Copy, Drop, PartialEq, Debug)]
pub enum Direction {
    Left,
    Right,
    Up,
    Down,
    LeftDown,
    LeftUp,
    RightDown,
    RightUp,
}



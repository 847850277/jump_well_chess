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
    pub x: i32,
    pub y: i32,
    pub name: felt252
}



#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
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




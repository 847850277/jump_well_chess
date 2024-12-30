use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Players {
    #[key]
    pub player: ContractAddress,
    pub position_one: Position,
    pub position_two: Position,
    pub can_move: bool,
    pub color: felt252,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Position {
    pub player: ContractAddress,
    pub name: u32,
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
    pub name: u32,
    pub occupied: bool
}

//#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
//pub enum Direction {
//    Left,      //1
//    Right,     //2
//    Up,        //3
//    Down,      //4
//    LeftDown,  //5
//    LeftUp,    //6
//    RightDown, //7
//    RightUp,   //8
//}




# query graphql

## torii index

```bash

 torii --world 0x01709f97d37e99cfc33607e89728836399b33993892770a56b0cdc6697a95ad6  --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7  --http.cors_origins "*" --db-dir indexer.db

```

browse to http://localhost:8080/graphql


## query

### query Container

```bash

query DojostarterContainerModels {
  dojoStarterContainerModels {
    totalCount
    edges {
      node {
        game_id
        status
        last_move_player,
        grids{
          name,
          occupied
        }
      }
    }
  }
}

```

### query Player

```bash

query DojostarterPlayersModels {
  dojoStarterPlayersModels {
    totalCount
    edges {
      node {
        player
        position_one{
          player,
          name
        }
        position_two{
          player,
          name
        }
        can_move
        color
      }
    }
  }
}

```

### query event

```bash

query DojostarterGameStatusEventEvents {
  dojoStarterGameStatusEventModels {
    totalCount
    edges {
      node {
        game_id,
        status
      }
    }
  }
}

```

## Subscription

### Subscription modelRegistered

```bash

subscription modelRegistered {
    modelRegistered {
        id
        name
    }
}

```

### Subscription dojo_starter_Container

```bash

subscription {
    entityUpdated(
        id: "0x579e8877c7755365d5ec1ec7d3a94a457eff5d1f40482bbe9729c064cdead2"
    ) {
        id
        keys
        eventId
        createdAt
        updatedAt
        models {
            __typename
            ... on dojo_starter_Container{
                game_id,
              	grids{
                  name,
                  occupied
                }
            }
            
        }
    }
}

```
# IDs and Normalization

In the previous lesson, we reviewed how when joining tables together, we have to be mindful of [Cartesian joins](https://github.com/tmolitor002/SQL-for-Data-Viz/blob/main/Week-3/03_01-JOINs.md#cartesian-joins) expanding the results of query beyond the actual scope of what is intended. This is one of the reasons that tables should have a primary key whenever possible.

The other reason to use IDs is to help with data normalization. In a nutshell, normalization is the process of minimizing the redundant existence of data within a database.

Taking a closer look at the `raw_pbp2023` table, it certainly makes sense that so many fields exist to describe what happened on the play. An argument could be that more fields could be added to the table, describing other aspects of the play. Conversely however, there are many fields that show reptitive information, usually on a game-by-game basis. Our first clue to this is the second (and third) field in the table: `game_id`.

```sql
SELECT a.game_id        -- Unique for each game played
    , a.home_team
    , a.away_team
    , a.season_type     -- Regular or post season
    , a.week            -- Week of the season, which starts on Thursday
    , a.game_date
    , a.season          -- Season year
    , a.start_time
    , a.stadium
    , a.weather         -- A description of the weather at the game
    , a.nfl_api_id
    , a.away_score      -- Number of points the away team scored
    , a.home_score      -- Number of points the home team scored
    , a.location        -- Game played at home team's stadium or neutral site
    , a.result          -- The difference in the score. Away team win will be a negative number
    , a.total
    , a.spread_line
    , a.total_line
    , a.div_game        -- Indicates the game was played by teams in the same division
    , a.roof
    , a.surface
    , a.temp
    , a.wind
    , a.home_coach
    , a.away_coach
    , a.stadium_id      -- Unique ID for each stadium. Teams that share a stadium will have the same stadium_id for home games
    , a.game_stadium    -- Name of the stadium
FROM raw_pbp2023 a
;
```

When executing the above query, notice how records repeat themselves without change for large chunks before jumping to the next game. These fields would be great candidates split out and moved into their own table using `game_id` as a unique field and Primary Key for each game played. Fortunately, SQL has an easy way to do this.

## DISTINCT

The `DISTINCT` instruction is a great way to get records with a unique combination. The instruction is added immediately after `SELECT` and before the names of any fields in the `SELECT` clause. Below is an example with a revision to the field order

```sql
/* Games */
SELECT DISTINCT a.game_id  -- Primary Key
    -- Participants
    , a.home_team
    , a.away_team
    , a.home_coach
    , a.away_coach
    , a.div_game
    -- Date
    , a.season
    , a.season_type
    , a.week
    , a.game_date
    , a.start_time
    -- Scores
    , a.home_score
    , a.away_score
    , a.total
    , a.result
    -- Odds
    , a.spread_line
    , a.total_line
    -- Other
    , a.nfl_api_id
    -- Field Conditions
    , a.weather
    , a.temp
    , a.wind
    , a.roof            -- Some stadiums have retractable roofs
    -- Location
    , a.location        -- Game played at home team's stadium or neutral site
    , a.stadium_id
    , a.stadium
    , a.game_stadium
    , a.surface
FROM raw_pbp2023 a
;
```

Now instead of thousands of reptitive records being returned for each play in a game, we have a table with just 285 records, one for each game that was played in the 2023 season. In the `pbp_2023` table, the field `game_id` has become a foreign key that can be used to relate it back to this query. When bringing constructing queries for a use in a data visualization tool, we can dnow bring these queries in separately, and define the relationship on the field `game_id` in the tool.

When normalizing data, it is important to also consider the long term implications and possible changes to the data structure in the future. In this example, while currently weather reading are only taken once per game, it is not unreasonable to believe that at some point, weather measurements might be taken more frequently throughout a game.

## Reducing Dependency

Another goal of normalization is to reduce transitive dependency across different fields. For example, if the field `stadium_id` was unique to each venue a game could be played in (it is not a proper id field in `pbp_2023`, but lets pretend), the fields `stadium`, `game_stadium`, and `surface` would all be candidates to be moved to a separate `stadiums` table. Additional fields could be added here such at the lat/long or street address for each stadium, or other information such as max capacity original construction date.

Another example where we could possible reduce dependency is remove the fields `season`, `week`, `home_team`, and `away_team` from the table, as they can all be inferred values inside the `game_id`, which is formatted as `year_week_away_home`. This is an example of a composite key, which is a primary key made from the values of a select set of fields that will always be unique for each record.

Before reducing dependency like this, be mindful of how your data might be used. In the context of NFL stadiums, teams change stadiums here and there, which might make things complicated if looking at things over a historical period. Stadiums also have other uses, such as hosting college football games, baseball games, or even Taylor Swift concerts that may change depending on the usage.

## 3NF

For our purposes, having a separate query for games will statisfy everything we need to do. A good goal to aim for the third notational form, often referred to as [3NF](https://en.wikipedia.org/wiki/Database_normalization#Satisfying_3NF). Although further normalization is often possible, it eventually becomes resource intensive and difficult to manage. Higher notational forms may also not work well with visualization tools.

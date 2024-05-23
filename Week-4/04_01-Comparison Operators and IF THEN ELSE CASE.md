# IF THEN ELSE CASE

Often in SQL we need to transform or create new data based on the value of other fields. This is where `IF` and `CASE` statements come into play. Both allow you to evaluate a set of instructions to arrive at a determined value.

## IF statement

Althought the `IF` statement is supported in some versions of SQL, it is more commonly used in other programming languages. The `IF` statement is typically broken into three section, the expression to be evaluated, the results if the expression is true, and the result if the expression is not true.

For example, let's pretend we have a table with a list of players and thier position abbreviation like the one below, and we want to add a new field that has their position spelled out.

| player         | pos_abbr |
| :------------- | :------- |
| Justin Fields  | QB       |
| Caleb Williams | QB       |
| Rome Odunze    | WR       |

We could use an `IF` statement to evaluate the contents of `pos_abbr` to create a new field

```sql
SELECT a.player
    , a.pos_abbr
    -- IF Statement
    , IF a.pos_abbr = 'QB' THEN 'Quarterback' --Expression, and result if true
      ELSE `Wide Receiver` -- result if false
      END as position
FROM players a
;
```

Our resulting table would look like this:

| player         | pos_abbr | position      |
| :------------- | :------- | :------------ |
| Justin Fields  | QB       | Quarterback   |
| Caleb Williams | QB       | Quarterback   |
| Rome Odunze    | WR       | Wide Receiver |

This is a great start, but with `IF` (and `CASE`) statements, we need to consider what happens when a value we are not expecting populates the field in the expression. For example, lets add another player to our original table, Travice Kelce, who plays Tight End (TE), and see what the output of our table would look like:

| player         | pos_abbr | position      |
| :------------- | :------- | :------------ |
| Justin Fields  | QB       | Quarterback   |
| Caleb Williams | QB       | Quarterback   |
| Rome Odunze    | WR       | Wide Receiver |
| Travis Kelce   | TE       | Wide Receiver |

Knowing that Travis Kelce is not a Wide Receiver, we should adjust our IF statement to accomadate the many values that could be in the pos_abbr field. This is done by using `ELSEIF`.

```sql
SELECT a.player
    , a.pos_abbr
    -- IF Statement
    , IF a.pos_abbr = 'QB'      THEN 'Quarterback' --Expression, and result if true, otherwise...
      ELSEIF a.pos_abbr = 'WR'  THEN 'Wide Receiver' -- Result if second expression is true, otherwise...
      ELSEIF a.pos_abbr = 'TE'  THEN 'Tight End' -- Result if third expression is true, otherwise...
      ELSE null -- field will have no value
      END as position
FROM players a
;
```

Lets add one more player, running back David Montgomery, and see how our latest query would resolve.

| player           | pos_abbr | position      |
| :--------------- | :------- | :------------ |
| Justin Fields    | QB       | Quarterback   |
| Caleb Williams   | QB       | Quarterback   |
| Rome Odunze      | WR       | Wide Receiver |
| Travis Kelce     | TE       | Tight End     |
| David Montgomery | RB       | _null_        |

It can be difficult to anticipate all of the values that might show up in a field, so it is common practice to end an `IF` statement with `ELSE null`.

## CASE statement

`CASE` statements in SQL are similar to `IF` statements in SQL, however they are more robustly supported with different database engines, and are the preferred method for writing conditional logic in a query. Using the same scenario as above, lets see what a `CASE` statement looks like

```sql
SELECT a.player
    , a.pos_abbr
    -- CASE Statement
    , CASE a.pos_abbr -- The field we want to evaluate
        WHEN 'QB'   THEN 'Quarterback' -- when the value is QB then new field equals Quarterback
        WHEN 'WR'   THEN 'Wide Receiver'
        WHEN 'TE'   THEN 'Tight End'
        ELSE null -- when the value is something else, then new field is null
        END as position
FROM players a
;
```

We can also have each `WHEN` clause evaluate different fields in a particular order, althought this is unusual

```sql
SELECT a.player
    , a.pos_abbr
    -- CASE Statement
    , CASE
        WHEN a.player = 'Caleb Williams'    THEN 'A Quarterback'
        WHEN a.pos_abbr = 'QB'              THEN 'Quarterback'
        WHEN a.pos_abbr = 'WR'              THEN 'Wide Receiver'
        WHEN a.player = 'Travis Kelce'      THEN 'Taylor Swift BF'
        WHEN a.pos_abbr = 'TE'              THEN 'Tight End'
        ELSE null -- when the value is something else, then new field is null
        END as position
FROM players a
;
```

| player           | pos_abbr | position        |
| :--------------- | :------- | :-------------- |
| Caleb Williams   | QB       | A Quarterback   |
| Justin Fields    | QB       | Quarterback     |
| Rome Odunze      | WR       | Wide Receiver   |
| Travis Kelce     | TE       | Taylor Swift BF |
| David Montgomery | RB       | _null_          |

## Passer Rating

Returning to the [passer rating](../Week-3/03_04-Project%20Update%20and%20Arithmetic.md#passer-rating) calculation from the previous lesson, we have already completed the first step in calculating four distinct values.

<details>
<summary>Passer Rating Step 1</summary>

$$ a = \Bigg( \frac{CMP}{ATT} - 0.3 \Bigg) \times 5 $$
$$ b = \Bigg( \frac{YDS}{ATT} - 3 \Bigg) \times 0.25 $$
$$ c = \Bigg( \frac{TD}{ATT} \Bigg) \times 20 $$
$$ d = 2.375 - \Bigg( \frac{INT}{ATT} \times 25 \Bigg) $$

where:

- ATT = `pass_attempts`
- CMP = `completions`
- YDS = `total_yards_gained`
- TD = `pass_touchdowns`
- INT = `interceptions`
</details>

To complete the calculation first we need to ensure that each value we calculated is no smaller than 0 and no larger than 2.375. Any value below or above this range is set to 0 or 2.375 respectively. Once all four values have been set, the final calculation to determine passer rating is:

$$ Passer Rating = \Bigg( \frac{a+b+c+d}{6} \Bigg) \times 100 $$

Step 2 then will be to update each rating field to a minium of 0 and a maximum of 2.375. We will do this calculation in a new CTE `passing_rating_step_2`, and then in our final select statement, we will calculate passer rating and drop the four initial calculations.

```sql
WITH passing_2023 AS (
    SELECT a.passer_player_id       AS player_id
        , 2023                      AS season
        , a.game_id
        , b.display_name
        , b.position
        , b.team_abbr               AS team
        , SUM(a.air_yards)          AS total_air_yards
        , SUM(a.yards_after_catch)  AS total_yards_after_catch
        , SUM(a.yards_gained)       AS total_yards_gained
        , SUM(a.pass_touchdown)     AS pass_touchdowns
        , SUM(a.interception)       AS interceptions
        , SUM(a.pass_attempt)       AS pass_attempts
        , SUM(a.complete_pass)      AS completions
    FROM raw_pbp2023 a
    LEFT JOIN raw_players b
    ON a.passer_player_id = b.gsis_id
    WHERE a.play_type = 'pass'
        AND b.position = 'QB'
    GROUP BY a.passer_player_id
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

, passing_2022 AS (
    SELECT a.passer_player_id       AS player_id
        , 2022                      AS season
        , a.game_id
        , b.display_name
        , b.position
        , b.team_abbr               AS team
        , SUM(a.air_yards)          AS total_air_yards
        , SUM(a.yards_after_catch)  AS total_yards_after_catch
        , SUM(a.yards_gained)       AS total_yards_gained
        , SUM(a.pass_touchdown)     AS pass_touchdowns
        , SUM(a.interception)       AS interceptions
        , SUM(a.pass_attempt)       AS pass_attempts
        , SUM(a.complete_pass)      AS completions
    FROM raw_pbp2022 a
    LEFT JOIN raw_players b
    ON a.passer_player_id = b.gsis_id
    WHERE a.play_type = 'pass'
        AND b.position = 'QB'
    GROUP BY a.passer_player_id
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

, passing_stats AS (  -- Creating a new CTE: pass_stats
    SELECT c.player_id
        , c.season
        , c.game_id
        , c.display_name
        , c.position
        , c.team
        , c.total_yards_gained - c.total_yards_after_catch  AS total_air_yards
        , c.total_yards_after_catch
        , c.total_yards_gained
        , c.pass_touchdowns
        , c.interceptions
        , c.pass_attempts
        , c.completions
    FROM passing_2023 c
    UNION
    SELECT d.player_id
        , d.season
        , d.game_id
        , d.display_name
        , d.position
        , d.team
        , d.total_yards_gained - d.total_yards_after_catch  AS total_air_yards
        , d.total_yards_after_catch
        , d.total_yards_gained
        , d.pass_touchdowns
        , d.interceptions
        , d.pass_attempts
        , d.completions
    FROM passing_2022 d
)

, passing_rating_step_1 AS
(
    SELECT e.*
        , ((CAST(e.completions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) - 0.3) * 5         AS rating_a
        , ((CAST(e.total_yards_gained AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) - 3) * 0.25 AS rating_b
        , (CAST(e.pass_touchdowns AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) * 20            AS rating_c
        , 2.375 - ((CAST(e.interceptions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) * 25)    AS rating_d
    FROM passing_stats e
)

WITH passing_rating_step_2 AS ( --creating new CTE passer_rating_step_2
    SELECT a.player_id
        , a.season
        , a.game_id
        , a.display_name
        , a.position
        , a.team
        , a.total_air_yards
        , a.total_yards_after_catch
        , a.total_yards_gained
        , a.pass_touchdowns
        , a.interceptions
        , a.pass_attempts
        , a.completions
        , CASE -- min value = 0, max value = 2.375
            WHEN a.rating_a < 0     THEN 0
            WHEN a.rating_a > 2.375   THEN 2.375
            ELSE a.rating_a
            END AS rating_a
        , CASE -- min value = 0, max value = 2.375
            WHEN a.rating_b < 0     THEN 0
            WHEN a.rating_b > 2.375   THEN 2.375
            ELSE a.rating_b
            END AS rating_b
        , CASE -- min value = 0, max value = 2.375
            WHEN a.rating_c < 0     THEN 0
            WHEN a.rating_c > 2.375   THEN 2.375
            ELSE a.rating_c
            END AS rating_c
        , CASE -- min value = 0, max value = 2.375
            WHEN a.rating_d < 0     THEN 0
            WHEN a.rating_d > 2.375   THEN 2.375
            ELSE a.rating_d
            END AS rating_d
    FROM passing_rating_step_1 a
)

SELECT b.player_id -- final select statment
    , b.season
    , b.game_id
    , b.display_name
    , b.position
    , b.team
    , b.total_air_yards
    , b.total_yards_after_catch
    , b.total_yards_gained
    , b.pass_touchdowns
    , b.interceptions
    , b.pass_attempts
    , b.completions
    -- dropped the step_1 ratings calcs and add passer_rating
    , ((b.rating_a + b.rating_b + b.rating_c + b.rating_d) / 6) * 100 AS passer_rating
FROM passing_rating_step_2 b
;
```

# Aggregation in SQL

One of the of the most powerful features of SQL is the ability to aggregate multiple records of data to give us a higher level summary. This can be a helpful way to measure performance. If you were the manager of a store, you wouldn't look at every transaction's receipt to judge if a certain item was selling well. You would likely start with adding up the total sales over a period of time, or looking the number of sales per day.

The same can be said with our football data. Imagine you're working for the General Manager for your favorite football team, and wanted to understand who the most succesfull quarterbacks are. You wouldn't judge them on an individual pass attempt, but rather look at how they performed overall in a game or a season.

## Preparing the data

Assume there are eight key metrics we want to use when evaluating a quarterback's performance over the course of the 2023 season: Total Air Yards, Total Yards after the Catch, Total Yards, Total Touchdowns, Total Interceptions, Total Attempts, Total Completions, and Completion Percentage. We can calculate all of those metrics by querying the `raw_pbp2023` table. First, let's narrow down the fields and records we will actually need to calculate these metrics.

<details>
<Summary>Metrics definitions</Summary>

- Air Yards: The number of yards the ball traveled from the line of scrimmage to where the receiver caught the ball.
- Yards after the Catch (YaC): The distance the receiver ran after catching the ball.
- (Passing) Yards: The total distance gained (or lost) by the offensive team from throwing the ball. Passing Yards should always equal Air Yards + Yards after the Catch.
- (Passing) Touchdowns: The pass play resulted in the offensive team reaching the end zone and scoring points.
- Interceptions: The pass play was picked off or "Intercepted" by a player on defense. Quarterbacks try to avoid interceptions.
- Attempts: The number of times the quarterback attempted to complete a succussful passing play, even if the ball was not caught by a receiver.
- Completions: The number of successful passing plays by the quarterback.
- COmpletion Percentage: The ratio of completions to attempts.

</details>

```sql
SELECT play_id              -- Primary Key denoting a unique play
    , passer_player_id      -- Foreign Key denoting the player throwing the ball
    , air_yards
    , yards_after_catch
    , pass_touchdown
    , interception
    , pass_attempt
    , complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| play_id | passer_player_id | air_yards | yards_after_catch | pass_touchdown | interception | pass_attempt | complete_pass |
| ------: | :--------------- | :-------- | :---------------- | :------------- | :----------- | :----------- | :------------ |
|      77 | 00-0037077       | 6         | 0                 | 0              | 0            | 1            | 1             |
|     124 | 00-0037077       | 10        |                   | 0              | 0            | 1            | 0             |
|     147 | 00-0037077       | 12        | 0                 | 0              | 0            | 1            | 1             |
|     ... | ...              | ...       | ...               | ...            | ...          | ...          | ...           |

We now have a great starting point to aggregate our data. Lets look at the `SUM()` function to start seeing performance in 2023.

## SUM()

The `SUM()` function is one of the most commonly used function in SQL. It can be used to add up all the values within a field to give a total. Let's look at a subset of our query to see how we can get the total Air Yards in a season. To do this, we will temporarily comment-out the other fields in the query

```sql
SELECT --play_id
    --, passer_player_id
    SUM(air_yards)          -- Add all the values in air_yards to get a total
    --, yards_after_catch
    --, pass_touchdown
    --, interception
    --, pass_attempt
    --, complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| (fieldname) |
| ----------: |
|      148891 |

If you are using DB Browser and copied the query above, you might've noticed the comments went into the name of the field. In other IDEs such as SSMS, you might see something like `(no name)`. This is a result of the query not specifying a name for the calculation we just performed. The database will reuse the same field names when they are not being manipulated, but requries an `AS` clause to be used when creating new fields as we did here. To clean this up, we can add `AS total_air_yards` after the `SUM()` function.

```sql
SELECT --play_id
    --, passer_player_id
    SUM(air_yards) AS total_air_yards   -- Add all the values in air_yards to get a total
    --, yards_after_catch
    --, pass_touchdown
    --, interception
    --, pass_attempt
    --, complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| total_air_yards |
| --------------: |
|          148891 |

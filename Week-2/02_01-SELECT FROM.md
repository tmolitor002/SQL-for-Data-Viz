# SELECT \* FROM

`SELECT * FROM` is often the starting point of most SQL queries. Add the name of the [table](../Week-1/01_02-Starting%20DB%20Browser.md#what-is-a-table) in your database and you will quickly see data in your results window. To better understand what is happening here, let's break down our first query: `SELECT * FROM raw_players`.

## SELECT \*

Our query can be broken into two parts. The first, `SELECT *`, is where we are telling the database what data we want returned to us. The word `SELECT` is an instruction to the database, letting it know that we are about to select certain fields to be returned. The `*` in this statement acts as a wildcard, telling the database that we want to see _every_ field within the table.

## FROM \<table>

While we are able to select every field at once, a SQL query must limit the scope of where it selecting it's field from. This is where the `FROM` instruction comes into play, it tells the database engine which table we would like our data to come from. Without a source to execute our query against, we would see an error, and no data would come back to us.

Take a minute and try writing queries against the three raw tables we have already loaded into the database. What happens when you execute these queries?

<details>
<summary>Queries</summary>

```sql
SELECT *            -- Select all fields...
FROM raw_players    -- from the table <raw_players>
;
```

```sql
SELECT *            -- Select all fields...
FROM raw_pbp2022    -- from the table <raw_pbp2022>
;
```

```sql
SELECT *            -- Select all fields...
FROM raw_pbp2023    -- from the table <raw_pbp2023>
```

</details>

When running the first query against the `raw_players` table, you should see something similar to the excerpt below:

<details>
<summary>raw_players results</summary>

| status | display_name     | first_name | last_name | esb_id    | gsis_id    | ... |
| :----- | :--------------- | :--------- | :-------- | :-------- | :--------- | :-: |
| RET    | 'Omar Ellison    | 'Omar      | Ellison   | ELL711319 | 00-0004866 | ... |
| ACT    | A'Shawn Robinson | A'Shawn    | Robinson  | ROB367960 | 00-0032889 | ... |
| ACT    | A.J. Arcuri      | A.J.       | Arcuri    | ARC716900 | 00-0037845 | ... |
| ...    | ...              | ...        | ...       | ...       | ...        |

</details>

And when executing against one of the play-by-play tables, you should see a similar structure to this:

<details>
<summary>raw_pbp2022 results</summary>

| play_id | game_id         | old_game_id | home_team | away_team | season_type | ... |
| ------: | :-------------- | ----------: | :-------- | :-------- | :---------- | :-: |
|       1 | 2022_01_BAL_NYJ |  2022091107 | NYJ       | BAL       | REG         | ... |
|      43 | 2022_01_BAL_NYJ |  2022091107 | NYJ       | BAL       | REG         | ... |
|      68 | 2022_01_BAL_NYJ |  2022091107 | NYJ       | BAL       | REG         | ... |
|     ... | ...             |         ... | ...       | ...       | ...         | ... |

</details>

## Selecting specific fields

If you scrolled through some of the results from the queries above, you might have noticed that there **a lot** of fields in each table. The players and play-by-play tables have 33 and **382** fields respectively. Fortunately, SQL makes it easy for us to select only the fields we want to see by adjusting our select statement. Simply replace the `*` with the field names and only the fields requested will be returned.

```sql
SELECT status
    , display_name
    , gsis_id
    , position
    , jersey_number
FROM raw_players
;
```

Now the data returned to us is limited to the fields selected

| status | display_name     | gsis_id    | position | jersey_number |
| :----- | :--------------- | :--------- | :------- | ------------: |
| RET    | 'Omar Ellison    | 00-0004866 | WR       |            84 |
| ACT    | A'Shawn Robinson | 00-0032889 | DT       |            91 |
| ACT    | A.J. Arcuri      | 00-0037845 | T        |            61 |
| ...    | ...              | ...        | ...      |           ... |

Note that the fields we didn't select in this query are still available to be queried, but must be added to the list of fields in the `SELECT` part of the query. For example, if we wanted to add the `headshot` field to our results, it would be as simple as adding it to the end of the SELECT instruction:

```sql
SELECT status
    , display_name
    , gsis_id
    , position
    , jersey_number
    , headshot      -- url to player headshot
FROM raw_players
;
```

## Select best practices

Making your query legilbe is an important part of writing quality code. It allows other developers to quickly understand your query and the logic you put into developing it. Here are a couple things I like to do before I complete any code.

- Always make the ID field the first field selected
  - Almost every table in your database will likely have an [ID or Primary Key](../Week-1/01_02-Starting%20DB%20Browser.md#keys-and-ids) field that is unique to every record. Having that Primary Key field as the first in your SELECT statement makes it clear what fields can be used to determine unique records that may otherwise appear similar.
- Include foreign keys immediately after the ID field
  - Having foreign keys at the top of statement helps identify what fields might be used by other tables.
- Utilize indentation and page breaks
  - Indenting the additional fields you are selecting drastically increases legibility. While SQL is fairly agnostic about spaces, tabs, and page breaks, it makes it much easier to identify different components of a query.
  - `SELECT gsis_id, status, display_name, position, jersey_number, headshot from raw_players` works exactly the same as the queries above, but will be needlessly difficult to edit and troubleshoot.
- Capitalize SQL instructions
  - This again helps with legibility. Keeping SQL instructions capitalized and everything else in either lowercase or camel case makes code much easier to read and understand.

poor sql

### Field names and spaces

SQL allows you to use spaces in the names of your fields by surrounding them with square brackets `[]`. This is something that most developers tend to avoid. However, when using SQL to pull data into a visualization tool, it can be helpful to have the field names standardized in the SQL query rather than in each instance of the tool.

```sql
SELECT gsis_id
    , status
    , display_name      AS [Display Name]
    , position          AS [pos]
    , jersey_number     AS [Jersey Number]
    , [headshot]
FROM [raw_players]
;
```

| gsis_id    | status | Display Name     | pos | Jersey Number | headshot |
| :--------- | :----- | :--------------- | :-- | ------------: | :------- |
| 00-0004866 | RET    | 'Omar Ellison    | WR  |            84 |          |
| 00-0032889 | ACT    | A'Shawn Robinson | DT  |            91 | _url_    |
| 00-0037845 | ACT    | A.J. Arcuri      | T   |            61 |          |
| ...        | ...    | ...              | ... |           ... | ...      |

---

There is plenty more to learn about the SELECT statement in a SQL query that will be covered in future lessons, but before we get to that, we're going to look at how we can begin to filter and manipulate the data that is returned in our queries by looking at a new part of the SQL query: [The WHERE clause](../Week-2/02_02-The%20WHERE%20clause.md).

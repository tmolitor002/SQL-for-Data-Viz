# Explore DB Browser

DB Browser has many powerful tools at its disposal that are beyond the scope of this course. We've already interacted with the `Dataabase Structure` tab in the [previous lesson](https://github.com/tmolitor002/SQL-for-Data-Viz/blob/main/Week-1/02-Starting%20DB%20Browser.md#what-is-a-table), and we'll be primarily focused on the `Browse Data` and `Execute SQL` tabs going forward.

## Browse Data

Similar to how the `Database Structure` tab is a great place to review what tables exist in the the database, the `Browse Data` tab is a great place to review what data exists within a single table. Underneath the four tabs, there is a `Table` drop down that allows you to select any table in the database for review. Select `raw_player`, and take a moment to the table's contents in the window below. This should look familiar as it is the same data we reviewed when opening the `players.csv` file in the [previous lesson](https://github.com/tmolitor002/SQL-for-Data-Viz/blob/main/Week-1/02-Starting%20DB%20Browser.md#what-is-a-table).

## Execute SQL

For now we will skip past the `Edit Pragmas` tab and head straight to the `Execute SQL` tab. This is where we will spend the majority of our time.

There are three main windows on this tab. The first pane is the SQL editor, where you will write and edit your queries. This is as good a time as ever to write you first SQL query in the editor.

```sql
SELECT *
FROM raw_players
```

Copy and paste or transcribe the query above into the first window, and click either the play button, `F5` on Windows, or `Command` + `r` on Mac. This will execute the query against the table. We will cover more about what the above query means in a <later lesson>.

Below the editor, after running the query you should see data appear in the results window. The results window gives you a preview of the data you returned from the query. For the query we just ran, `SELECT * FROM raw_players`, the results window should look exactly like `players.csv` and the `raw_players` table seen in the Browse Data tab.

We are all set up now. In the next lesson, we will begin to dive into the SQL language, and start to manipulate our raw tables into useable data for a visualization. In the next section, we will begin to look at the basic structure of a SQL query starting with a simple [Select From](../Week-2/02_01-SELECT%20FROM.md) statement.

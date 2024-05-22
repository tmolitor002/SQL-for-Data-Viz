SELECT
    a.passer_player_id AS player_id,
    b.display_name, -- Additional fields from the raw_players table
    b.position,
    b.team_abbr AS team,
    SUM(a.air_yards) AS total_air_yards,
    SUM(a.yards_after_catch) AS total_yards_after_catch,
    SUM(a.yards_gained) AS total_yards_gained,
    SUM(a.pass_touchdown) AS pass_touchdowns,
    SUM(a.interception) AS interceptions,
    SUM(a.pass_attempt) AS pass_attempts,
    SUM(a.complete_pass) AS completions
FROM
    raw_pbp2023 a
    LEFT JOIN raw_players b ON a.passer_player_id = b.gsis_id
WHERE
    a.play_type = 'pass'
    AND b.position = 'QB'
GROUP BY
    a.passer_player_id,
    b.display_name -- Additional fields from the raw_players table
,
    b.position,
    b.team_abbr
ORDER BY
    SUM(a.pass_touchdown) DESC;
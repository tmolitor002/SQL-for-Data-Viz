SELECT
    passer_player_id,
    SUM(air_yards) AS total_air_yards,
    SUM(yards_after_catch) AS total_yards_after_catch,
    SUM(yards_gained) AS total_yards_gained,
    SUM(pass_touchdown) AS pass_touchdowns,
    SUM(interception) AS interceptions,
    SUM(pass_attempt) AS pass_attempts,
    SUM(complete_pass) AS completions
FROM
    raw_pbp2023
WHERE
    play_type = 'pass'
GROUP BY
    posteam -- One record for each passer/team combination
,
    passer_player_id;
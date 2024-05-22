SELECT
    gsis_id,
    status,
    display_name,
    position,
    jersey_number,
    headshot
FROM
    raw_players
WHERE
    status = 'ACT' -- Only Active players and...
    AND position IN ('QB', 'HB', 'RB', 'WR', 'TE') -- Only these positions
;
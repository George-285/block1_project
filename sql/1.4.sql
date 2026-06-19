-- 1.4.a
SELECT listen_time FROM listening_logs LIMIT 5;



WITH listening_logs_cte AS (
	SELECT ll.song_id, STRFTIME('%Y-%m', listen_time) AS year_month
	FROM listening_logs ll 
)

SELECT year_month, COUNT(song_id) AS total_listens
FROM listening_logs_cte
GROUP BY year_month
ORDER BY year_month;


-- 1.4.b
SELECT
    STRFTIME('%Y-%m', listen_time) AS year_month,
    COUNT(*) AS total_listens
FROM listening_logs
GROUP BY year_month
ORDER BY year_month;
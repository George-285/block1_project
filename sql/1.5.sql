-- 1.5
SELECT g.name AS genre, ll.region, COUNT(ll.song_id) AS total_listens
FROM listening_logs ll 
JOIN song_genres sg ON sg.song_id = ll.song_id 
JOIN genres g ON g.genre_id = sg.genre_id 
GROUP BY genre, ll.region;
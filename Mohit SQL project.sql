Objective Question 1.
SELECT 'users', COUNT(*) - COUNT(DISTINCT id) AS Duplicates, SUM(username IS NULL) AS NullValues FROM users
UNION ALL
SELECT 'photos', COUNT(*) - COUNT(DISTINCT id), SUM(image_url IS NULL) FROM photos
UNION ALL
SELECT 'comments', COUNT(*) - COUNT(DISTINCT id), SUM(comment_text IS NULL) FROM comments
UNION ALL
SELECT 'likes', COUNT(*) - COUNT(DISTINCT user_id, photo_id), 0 FROM likes
UNION ALL
SELECT 'follows', COUNT(*) - COUNT(DISTINCT follower_id, followee_id), 0 FROM follows
UNION ALL
SELECT 'photo_tags', COUNT(*) - COUNT(DISTINCT photo_id, tag_id), 0 FROM photo_tags
UNION ALL
SELECT 'tags', COUNT(*) - COUNT(DISTINCT id), SUM(id IS NULL) FROM tags;
=================================================================================================================================
Objective Question 2.
SELECT u.id, u.username,
       COUNT(DISTINCT p.id) AS TotalPosts,
       COUNT(DISTINCT l.photo_id) AS TotalLikes,
       COUNT(DISTINCT c.id) AS TotalComments
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username
ORDER BY TotalLikes DESC, TotalComments DESC, TotalPosts DESC;
====================================================================================================================================
Objective Question 3
SELECT AVG(tag_count) AS AvgTagsPerPost FROM (
    SELECT photo_id, COUNT(tag_id) AS tag_count
    FROM photo_tags
    GROUP BY photo_id
) t;
==========================================================================================================================================
Objective question 4
SELECT u.id, u.username, COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id) AS Engagement
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY u.id, u.username
ORDER BY Engagement DESC
LIMIT 10;
========================================================================================================================================
Objective question 5
SELECT 'Most Followed' AS Category, followee_id AS UserID, COUNT(follower_id) AS Count 
FROM follows 
GROUP BY followee_id ORDER BY Count DESC 
LIMIT 5;

SELECT 'Most Following', follower_id, COUNT(followee_id) 
FROM follows 
GROUP BY follower_id 
ORDER BY COUNT(followee_id) 
DESC LIMIT 5;
=======================================================================================================================================
Objective Question 6
AVG((SELECT COUNT(*) FROM likes l WHERE l.photo_id = p.id) + (SELECT COUNT(*) FROM comments c 
WHERE c.photo_id = p.id)) AS AvgEngagementPerPost
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username;
===================================================================================================================================
Objective Question 7
SELECT u.id, u.username FROM users u
LEFT JOIN likes l ON u.id = l.user_id
WHERE l.user_id IS NULL;
====================================================================================================================================
Objective Question 8 
SELECT t.tag_name, COUNT(*) AS UsageCount FROM photo_tags pt
JOIN tags t ON pt.tag_id = t.id
GROUP BY t.tag_name ORDER BY UsageCount DESC LIMIT 10;
==========================================================================================================================================
Objective Question 9
SELECT 
    p.image_url, 
    COUNT(DISTINCT l.user_id) AS TotalLikes, 
    COUNT(DISTINCT c.id) AS TotalComments,
    (COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id)) AS TotalEngagement,
    (COUNT(DISTINCT l.user_id) * 1.0 / NULLIF(COUNT(DISTINCT c.id), 0)) AS LikeToCommentRatio
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY TotalEngagement DESC;
===========================================================================================================================================
Objective question 10
SELECT u.id, u.username,
       COUNT(DISTINCT l.photo_id) AS TotalLikes,
       COUNT(DISTINCT c.id) AS TotalComments,
       COUNT(DISTINCT pt.photo_id) AS TotalTags
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
LEFT JOIN photo_tags pt ON p.id = pt.photo_id
GROUP BY u.id, u.username;
======================================================================================================================================
Objective Question 11
SELECT u.id, u.username, COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id) AS TotalEngagement,
RANK() OVER(ORDER BY COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id) DESC) AS engagement_rank
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
WHERE p.created_dat >= NOW() - INTERVAL 1 MONTH
GROUP BY u.id, u.username
ORDER BY TotalEngagement DESC;
======================================================================================================================================
Objective Question 12
WITH HashtagLikes AS (
    SELECT t.tag_name, AVG(l_count.likes) AS AvgLikes
    FROM photo_tags pt
    JOIN tags t ON pt.tag_id = t.id
    JOIN (SELECT photo_id, COUNT(*) AS likes FROM likes GROUP BY photo_id) l_count
    ON pt.photo_id = l_count.photo_id
    GROUP BY t.tag_name
)
SELECT * FROM HashtagLikes ORDER BY AvgLikes DESC LIMIT 10;
====================================================================================================================================
Objective Question 13
SELECT f1.follower_id, f1.followee_id
FROM follows f1
JOIN follows f2 ON f1.follower_id = f2.followee_id AND f1.followee_id = f2.follower_id;

==========================================================================================================================================
==========================================================================================================================================
Subjective Question 1
WITH user_activity AS (SELECT u.id AS user_id,u.username,
        IFNULL(photo_counts.total_photos, 0) AS total_photos,
        IFNULL(comment_counts.total_comments, 0) AS total_comments,
        IFNULL(like_counts.total_likes_given, 0) AS total_likes_given,
        IFNULL(follower_counts.total_followers, 0) AS total_followers,
        IFNULL(following_counts.total_following, 0) AS total_following,
        (IFNULL(photo_counts.total_photos, 0) +
            IFNULL(comment_counts.total_comments, 0) +
            IFNULL(like_counts.total_likes_given, 0)  +
            IFNULL(follower_counts.total_followers, 0)  +
            IFNULL(following_counts.total_following, 0) ) AS engagement_score
    FROM users u
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_photos FROM photos GROUP BY user_id) photo_counts ON u.id = photo_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_comments FROM comments GROUP BY user_id) comment_counts ON u.id = comment_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_likes_given FROM likes GROUP BY user_id) like_counts ON u.id = like_counts.user_id
    LEFT JOIN(SELECT followee_id AS user_id, COUNT(*) AS total_followers FROM follows GROUP BY followee_id) follower_counts ON u.id = follower_counts.user_id
    LEFT JOIN(SELECT follower_id AS user_id, COUNT(*) AS total_following FROM follows GROUP BY follower_id) following_counts ON u.id = following_counts.user_id),
ranked_users AS (SELECT user_id,username,engagement_score,RANK() OVER (ORDER BY engagement_score DESC) AS user_rank
    FROM user_activity)
SELECT user_id,username,engagement_score,user_rank
FROM ranked_users
WHERE user_rank = 1;
===================================================================================================================================================================
Subjective Question 2
WITH user_activity AS (SELECT u.id AS user_id,u.username,
        IFNULL(photo_counts.total_photos, 0) AS total_photos,
        IFNULL(comment_counts.total_comments, 0) AS total_comments,
        IFNULL(like_counts.total_likes_given, 0) AS total_likes_given,
        IFNULL(follower_counts.total_followers, 0) AS total_followers,
        IFNULL(following_counts.total_following, 0) AS total_following,
        (IFNULL(photo_counts.total_photos, 0) +
            IFNULL(comment_counts.total_comments, 0) +
            IFNULL(like_counts.total_likes_given, 0)  +
            IFNULL(follower_counts.total_followers, 0)  +
            IFNULL(following_counts.total_following, 0) ) AS engagement_score
    FROM users u
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_photos FROM photos GROUP BY user_id) photo_counts ON u.id = photo_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_comments FROM comments GROUP BY user_id) comment_counts ON u.id = comment_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_likes_given FROM likes GROUP BY user_id) like_counts ON u.id = like_counts.user_id
    LEFT JOIN(SELECT followee_id AS user_id, COUNT(*) AS total_followers FROM follows GROUP BY followee_id) follower_counts ON u.id = follower_counts.user_id
    LEFT JOIN(SELECT follower_id AS user_id, COUNT(*) AS total_following FROM follows GROUP BY follower_id) following_counts ON u.id = following_counts.user_id),
ranked_users AS (SELECT user_id,username,engagement_score,RANK() OVER (ORDER BY engagement_score ASC) AS user_rank
    FROM user_activity)
SELECT user_id,username,engagement_score,user_rank
FROM ranked_users
WHERE user_rank = '1';
===================================================================================================================================================================
Subjective Question 3
SELECT
    t.tag_name,
    COUNT(pt.photo_id) AS total_posts,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(pt.photo_id) AS average_engagement
FROM
    tags t
JOIN
    photo_tags pt ON t.id = pt.tag_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes ON pt.photo_id = likes.photo_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments ON pt.photo_id = comments.photo_id
GROUP BY
    t.tag_name
ORDER BY
    average_engagement DESC
LIMIT 10;
========================================================================================================================================================================
Subjective Question 4
SELECT
    DATE_FORMAT(p.created_dat, '%H') AS hour_of_day,
    DAYNAME(p.created_dat) AS day_of_week,
    COUNT(p.id) AS total_posts,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(p.id) AS average_engagement
FROM
    photos p
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes ON p.id = likes.photo_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments ON p.id = comments.photo_id
GROUP BY
    hour_of_day, day_of_week
ORDER BY
    average_engagement DESC
LIMIT 0, 1000;
=============================================================================================================================================================================
Subjective Question 5
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(f.follower_id) AS follower_count,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0) AS total_engagement,
    CASE WHEN COUNT(f.follower_id) > 0 THEN 
        (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(f.follower_id)
    ELSE 0 END AS engagement_rate
FROM 
    users u
LEFT JOIN 
    follows f ON u.id = f.followee_id
LEFT JOIN 
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes
    ON u.id = (SELECT user_id FROM photos WHERE id = likes.photo_id)
LEFT JOIN 
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments 
    ON u.id = (SELECT user_id FROM photos WHERE id = comments.photo_id)
GROUP BY 
    u.id, u.username
ORDER BY 
    engagement_rate DESC, follower_count DESC
    LIMIT 10;
====================================================================================================================================================
Subjective Question 6
SELECT 
    u.id AS user_id,
    u.username,
    COALESCE(SUM(likes_count), 0) AS total_likes,
    COALESCE(SUM(comments_count), 0) AS total_comments,
    COALESCE(COUNT(DISTINCT p.id), 0) AS total_photos,
    CASE 
        WHEN COALESCE(COUNT(DISTINCT p.id), 0) = 0 THEN 0 
        ELSE (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) 
    END AS engagement_rate,
    CASE 
        WHEN COALESCE(COUNT(DISTINCT p.id), 0) = 0 THEN 'Low'
        WHEN (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) > 150 THEN 'High'
        WHEN (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) BETWEEN 100 AND 150 
        THEN 'Medium'
        ELSE 'Low'
    END AS engagement_level
FROM users u
LEFT JOIN (SELECT user_id, COUNT(*) AS likes_count FROM likes GROUP BY user_id) l ON u.id = l.user_id
LEFT JOIN (SELECT user_id, COUNT(*) AS comments_count FROM comments GROUP BY user_id) c ON u.id = c.user_id
LEFT JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username
ORDER BY engagement_rate DESC;    
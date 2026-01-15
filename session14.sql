create database session141;
use session141;

-- kha 1 
create table users(
  user_id int primary key auto_increment, 
  username varchar(50) not null, 
  post_count int default 0
);
create table posts(
  post_id int primary key auto_increment, 
  user_id int NOT NULL, 
  foreign key(user_id) references users(user_id),
  content text not null, 
  created_at datetime default current_timestamp,
   like_count int default 0
);
INSERT INTO users (username, post_count)
VALUES
('alice', 2),
('bob', 1),
('charlie', 1),
('david', 1),
('emma', 1),
('frank', 1),
('grace', 0);
INSERT INTO posts (user_id, content)
VALUES
(1, 'Bài viết thứ nhất của Alice'),
(1, 'Bài viết thứ hai của Alice'),
(2, 'Bài viết của Bob'),
(3, 'Bài viết của Charlie'),
(4, 'Bài viết của David'),
(5, 'Bài viết của Emma'),
(6, 'Bài viết của Frank');

start transaction;
insert into posts(user_id, content)
value 
    (1, 'tien dep trai');
update users
set post_count = post_count + 1
where user_id = 1;
commit ;

start transaction; 
insert into posts(user_id, content)
values 
    (99, 'tien dep trai');
UPDATE users
SET post_count = post_count + 1
WHERE user_id = 999;
ROLLBACK;    

-- kha 2 
create table likes(
  like_id int primary key auto_increment, 
  post_id int not null, 
  foreign key(post_id) references posts(post_id),
  user_id int not null, 
  foreign key(user_id) references users(user_id)
 
);
INSERT INTO likes (post_id, user_id)
VALUES
(1, 2),  -- Bob like bài của Alice
(1, 3),  -- Charlie like bài của Alice
(2, 4),  -- David like bài thứ 2 của Alice
(3, 1),  -- Alice like bài của Bob
(4, 5),  -- Emma like bài của David
(5, 6),  -- Frank like bài của Emma
(6, 7);  -- Grace like bài của Frank


start transaction;
insert into likes(post_id, user_id) 
values 
  (1, 2);
update posts
set like_count = like_count + 1
where post_id = 1;
commit ; 
select * from posts ;
-- th2 loi 
start transaction ; 
insert into likes(post_id, user_id) 
values 
   (1, 2);
update posts
set like_count = like_count + 1
where post_id = 1;
rollback;

select * from posts;



-- gioi 1 
ALTER TABLE users
ADD COLUMN IF NOT EXISTS following_count INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS followers_count INT DEFAULT 0;

CREATE TABLE IF NOT EXISTS followers (
  follower_id INT NOT NULL,
  followed_id INT NOT NULL,

  PRIMARY KEY (follower_id, followed_id),

  CONSTRAINT fk_follower_user
    FOREIGN KEY (follower_id) REFERENCES users(user_id),

  CONSTRAINT fk_followed_user
    FOREIGN KEY (followed_id) REFERENCES users(user_id)
);
CREATE TABLE IF NOT EXISTS follow_log (
  log_id INT PRIMARY KEY AUTO_INCREMENT,
  follower_id INT,
  followed_id INT,
  error_message VARCHAR(255),
  log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //

CREATE PROCEDURE sp_follow_user (
  IN p_follower_id INT,
  IN p_followed_id INT
)
BEGIN
  DECLARE v_count INT DEFAULT 0;
  START TRANSACTION;
  SELECT COUNT(*) INTO v_count
  FROM users
  WHERE user_id IN (p_follower_id, p_followed_id);
  IF v_count < 2 THEN
    INSERT INTO follow_log(follower_id, followed_id, error_message)
    VALUES (p_follower_id, p_followed_id, 'User không tồn tại');
    ROLLBACK;
  ELSEIF p_follower_id = p_followed_id THEN
    INSERT INTO follow_log(follower_id, followed_id, error_message)
    VALUES (p_follower_id, p_followed_id, 'Không được tự follow chính mình');
    ROLLBACK;
  ELSEIF EXISTS (
    SELECT 1 FROM followers
    WHERE follower_id = p_follower_id
      AND followed_id = p_followed_id
  ) THEN
    INSERT INTO follow_log(follower_id, followed_id, error_message)
    VALUES (p_follower_id, p_followed_id, 'Đã follow trước đó');
    ROLLBACK;
  ELSE
    INSERT INTO followers (follower_id, followed_id)
    VALUES (p_follower_id, p_followed_id);
    UPDATE users
    SET following_count = following_count + 1
    WHERE user_id = p_follower_id;
    UPDATE users
    SET followers_count = followers_count + 1
    WHERE user_id = p_followed_id;
    COMMIT;
  END IF;

END;
//
DELIMITER ;


-- gioi 2 
DELIMITER //
CREATE PROCEDURE sp_post_comment (
  IN p_post_id INT,
  IN p_user_id INT,
  IN p_content TEXT
)
BEGIN
  START TRANSACTION;
  -- 1. Thêm bình luận
  INSERT INTO comments (post_id, user_id, content)
  VALUES (p_post_id, p_user_id, p_content);
  -- 2. Tạo savepoint sau khi insert comment
  SAVEPOINT after_insert;
  -- 3. Cập nhật số lượng comment của bài viết
  UPDATE posts
  SET comments_count = comments_count + 1
  WHERE post_id = p_post_id;
  -- 4. Nếu update không ảnh hưởng dòng nào (giả lập lỗi)
  IF ROW_COUNT() = 0 THEN
    -- rollback chỉ phần UPDATE, vẫn giữ comment
    ROLLBACK TO after_insert;
  ELSE
    -- mọi thứ OK
    COMMIT;
  END IF;
END;
//
DELIMITER ;
CALL sp_post_comment(1, 2, 'Bình luận đầu tiên cho bài viết');
CALL sp_post_comment(999, 2, 'Bình luận gây lỗi update');
-- Kiểm tra comments
SELECT * FROM comments ORDER BY comment_id DESC;
-- Kiểm tra posts
SELECT post_id, comments_count FROM posts;


-- xuat xuac 1 
DELIMITER //
CREATE PROCEDURE sp_delete_post (
  IN p_post_id INT,
  IN p_user_id INT
)
BEGIN
  DECLARE v_owner_id INT;
  START TRANSACTION;
  -- 1. Kiểm tra bài viết có tồn tại và thuộc về user hay không
  SELECT user_id INTO v_owner_id
  FROM posts
  WHERE post_id = p_post_id;
  -- Không tồn tại bài viết
  IF v_owner_id IS NULL THEN
    ROLLBACK;
  -- Không phải chủ bài viết
  ELSEIF v_owner_id <> p_user_id THEN
    ROLLBACK;
  ELSE
    -- 2. Xóa likes của bài viết
    DELETE FROM likes
    WHERE post_id = p_post_id;
    -- 3. Xóa comments của bài viết
    DELETE FROM comments
    WHERE post_id = p_post_id;
    -- 4. Xóa bài viết
    DELETE FROM posts
    WHERE post_id = p_post_id;
    -- 5. Giảm số lượng bài viết của user
    UPDATE users
    SET post_count = post_count - 1
    WHERE user_id = p_user_id
      AND post_count > 0;
    -- 6. Hoàn tất
    COMMIT;
  END IF;

END;
//
DELIMITER ;
CALL sp_delete_post(1, 1);
CALL sp_delete_post(2, 1);
CALL sp_delete_post(999, 1);
SELECT * FROM posts;
SELECT * FROM likes;
SELECT * FROM comments;
SELECT user_id, post_count FROM users;


-- xuat sac 2 
DELIMITER //
CREATE PROCEDURE sp_accept_friend_request (
  IN p_request_id INT,
  IN p_to_user_id INT
)
BEGIN
  DECLARE v_from_user_id INT;
  DECLARE v_status VARCHAR(20);
  -- Isolation level để tránh dirty read / non-repeatable read
  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  START TRANSACTION;
  -- 1. Lấy thông tin request
  SELECT from_user_id, status
  INTO v_from_user_id, v_status
  FROM friend_requests
  WHERE request_id = p_request_id
    AND to_user_id = p_to_user_id
  FOR UPDATE;
  -- Request không tồn tại hoặc không hợp lệ
  IF v_from_user_id IS NULL OR v_status <> 'pending' THEN
    ROLLBACK;
  -- Đã là bạn trước đó
  ELSEIF EXISTS (
    SELECT 1 FROM friends
    WHERE user_id = p_to_user_id
      AND friend_id = v_from_user_id
  ) THEN
    ROLLBACK;
  ELSE
    -- 2. Thêm bạn 2 chiều
    INSERT INTO friends (user_id, friend_id)
    VALUES
      (p_to_user_id, v_from_user_id),
      (v_from_user_id, p_to_user_id);
    -- 3. Cập nhật số lượng bạn bè
    UPDATE users
    SET friends_count = friends_count + 1
    WHERE user_id IN (p_to_user_id, v_from_user_id);
    -- 4. Cập nhật trạng thái request
    UPDATE friend_requests
    SET status = 'accepted'
    WHERE request_id = p_request_id;
    COMMIT;
  END IF;
END;
//
DELIMITER ;


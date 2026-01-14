create database session13;
use session13;

-- kha 1 
drop table posts;
drop table  users;
create table users (
  user_id int primary key auto_increment, 
  username varchar(50) unique not null,
  email varchar(100) unique not null,
  created_at date, 
  follower_count int default 0,
  post_count int default 0
);
create table posts (
  post_id int primary key auto_increment, 
  user_id int , 
  foreign key (user_id) references users(user_id) on delete cascade, 
  content text, 
  created_at datetime, 
  like_count int default 0
);

INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');


-- 3) Tạo 2 trigger:
-- Trigger AFTER INSERT trên posts: Khi thêm bài đăng mới, tăng post_count của người dùng tương ứng lên 1.
delimiter //
create trigger tg_increase_post_count 
after insert on posts  
for each row 
begin
	update users 
    set post_count = post_count +1
    where user_id  = new.user_id ;
end //   
-- Trigger AFTER DELETE trên posts: Khi xóa bài đăng, giảm post_count của người dùng tương ứng đi 1.
create trigger tg_decrease_post_count 
after delete on posts 
for each row 
begin  
    update users 
    set post_count = post_count -1 
    where user_id = old.user_id; 
end //
delimiter ;
-- DROP TRIGGER IF EXISTS  tg_increase_post_count ;
INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

SELECT * FROM users;
-- 5) Xóa một bài đăng bất kỳ (ví dụ post_id = 2) rồi hiển thị lại bảng users để kiểm tra.
delete from posts 
where post_id = 2 ;
SELECT * FROM users;

-- kha 2 
create table likes(
  like_id int primary key auto_increment, 
  user_id int, 
  foreign key(user_id) references users(user_id) on delete cascade, 
  post_id int, 
  foreign key(post_id) references posts(post_id) on delete cascade,
  liked_at datetime 
);
-- Thêm dữ liệu mẫu vào likes (sử dụng các post_id hiện có)
INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');
-- Tạo trigger AFTER INSERT và AFTER DELETE trên likes để tự động cập nhật like_count trong bảng posts
delimiter //
create trigger tg_increase_like_count 
after insert on likes 
for each row 
begin 
   update posts 
   set like_count = like_count + 1
   where post_id = new.post_id;
end //

create trigger tg_decrease_like_count 
after delete on likes 
for each row 
begin 
   update posts 
   set like_count = like_count - 1
   where post_id = old.post_id; 
end //
delimiter ;

-- Tạo một View tên user_statistics hiển thị: user_id, username, post_count, total_likes (tổng like_count của tất cả bài đăng của người dùng đó).
create or replace view v_user_statistics as
select u.user_id, u.username, u.post_count, p.like_count as total_likes
from users u
left join posts p on u.user_id = p.user_id;


-- 5)Thực hiện thêm/xóa một lượt thích và kiểm chứng:
INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());
SELECT * FROM posts WHERE post_id = 4;
select * from v_user_statistics;

-- Xóa một lượt thích và kiểm chứng lại View.
delete from likes 
where post_id = 1;
select * from v_user_statistics;


-- gioi 3 
-- Tạo/cập nhật trigger trên likes:
-- BEFORE INSERT: Kiểm tra không cho phép user like bài đăng của chính mình (nếu user_id = user_id của post thì RAISE ERROR).
delimiter //
create trigger tg_check_like 
before insert on likes 
for each row 
begin 
   declare post_owner_id int ;
   select user_id into post_owner_id 
   from posts 
   where post_id = new.post_id;
   if new.user_id = post_owner_id then 
   signal sqlstate '45000'
   set message_text = 'loi. Khong duoc like bai dang cua minh';
   end if ;
end //   

-- 4) Thực hiện các thao tác kiểm thử:
-- Thử like bài của chính mình (phải báo lỗi).

insert into likes(user_id,post_id,liked_at)
values 
  (1, 1, '2025-01-10 11:00:00');
select * from likes ;
-- Thêm like hợp lệ, kiểm tra like_count.
insert into likes(user_id,post_id,liked_at)
values 
  (2, 1, '2025-01-10 11:00:00');
-- UPDATE một like sang post khác, kiểm tra like_count của cả hai post.
insert into likes(user_id,post_id,liked_at)
values 
  (1, 1, '2025-01-10 11:00:00');
-- Xóa like và kiểm tra.   
delete from likes 
where post_id = 1;


-- gioi 4 
create table post_history(
  history_id int primary key auto_increment, 
  post_id int ,
  foreign key(post_id) references posts(post_id),
  old_content text, 
  new_content text, 
  changed_at datetime, 
  changed_by_user_id int
);   
-- BEFORE UPDATE trên posts: Nếu content thay đổi, INSERT bản ghi vào post_history với old_content (OLD.content), new_content (NEW.content), changed_at NOW(), và giả sử changed_by_user_id là user_id của post.
delimiter //
create trigger tg_log_post_update 
before update on posts 
for each row 
begin 
  if old.content <> new.content then 
  insert into post_history(	post_id,old_content,new_content,changed_at,changed_by_user_id)
  values ( old.post_id,old.content,new.content,now(),old.user_id);
  end if ; 
end //
-- AFTER DELETE trên posts: Có thể ghi log hoặc để CASCADE.
delete from posts where post_id = 1;
-- Thực hiện UPDATE nội dung một số bài đăng, sau đó SELECT từ post_history để xem lịch sử.
update posts
set content = 'Noi dung da duoc cap nhat lan 1'
where post_id = 1;

update posts
set content = 'Noi dung da duoc cap nhat lan 2'
where post_id = 3;

select 
    history_id,
    post_id,
    old_content,
    new_content,
    changed_at,
    changed_by_user_id
from post_history
order by changed_at desc;




-- xuat sac 5 
delimiter //
create procedure add_user(in username varchar(50), in email varchar(100), in created_at date)
begin 
insert into users(username,email,created_at)
 values (username, email, created_at);
end //

create trigger tg_check_insert_user
before insert on users
for each row
begin
    -- Kiểm tra email
    if new.email not like '%@%.%' then
        signal sqlstate '45000'
        set message_text = 'Email khong hop le';
    end if;

    -- Kiểm tra username (chỉ chữ, số, underscore)
    if new.username not regexp '^[A-Za-z0-9_]+$' then
        signal sqlstate '45000'
        set message_text = 'Username chi duoc chua chu, so va dau gach duoi';
    end if;
end//
delimiter ;
call add_user('vu viet tien', 'tienadsads', current_date());
call add_user('vuviettien', 'tienxinhzai@gmail.com', current_date());
select * from users;

-- xuat sac 6 
create table friendships (
    follower_id int,
    followee_id int,
    status enum('pending', 'accepted') default 'accepted',
    primary key (follower_id, followee_id),
    foreign key (follower_id) references users(user_id) on delete cascade,
    foreign key (followee_id) references users(user_id) on delete cascade
);
delimiter //

create trigger tg_follow_increase
after insert on friendships
for each row
begin
    if new.status = 'accepted' then
        update users
        set follower_count = follower_count + 1
        where user_id = new.followee_id;
    end if;
end//

delimiter ;
delimiter //

create trigger tg_follow_decrease
after delete on friendships
for each row
begin
    if old.status = 'accepted' then
        update users
        set follower_count = follower_count - 1
        where user_id = old.followee_id;
    end if;
end//

delimiter ;
delimiter //

create procedure follow_user(
    in p_follower_id int,
    in p_followee_id int,
    in p_status enum('pending','accepted')
)
begin
    -- Không cho tự follow
    if p_follower_id = p_followee_id then
        signal sqlstate '45000'
        set message_text = 'Khong the follow chinh minh';
    end if;
    -- Tránh follow trùng
    if exists (
        select 1
        from friendships
        where follower_id = p_follower_id
          and followee_id = p_followee_id
    ) then
        signal sqlstate '45000'
        set message_text = 'Da follow nguoi nay roi';
    end if;
    -- Thực hiện follow
    insert into friendships (follower_id, followee_id, status)
    values (p_follower_id, p_followee_id, p_status);
end//

delimiter ;
create or replace view v_user_profile as
select
    u.user_id,
    u.username,
    u.follower_count,
    u.post_count,
    coalesce(sum(p.like_count), 0) as total_likes
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id, u.username, u.follower_count, u.post_count;
create or replace view v_recent_posts as
select
    p.post_id,
    p.user_id,
    p.content,
    p.created_at,
    p.like_count
from posts p
order by p.created_at desc;
select * from v_user_profile where user_id = 1;

select * from v_recent_posts where user_id = 1 limit 5;

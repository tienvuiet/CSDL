use test;
-- Viết câu truy vấn Select tìm tất cả những User ở Hà Nội
EXPLAIN ANALYZE
select *from users
where hometown = 'Hà Nội';
--  Tạo một chỉ mục có tên idx_hometown cho cột hometown của bảng User. 
create index idx_hometown on users(hometown);

EXPLAIN ANALYZE
select *from users
where hometown = 'Hà Nội';
-- Trước khi có index: thường sẽ thấy kiểu như Table scan / full table scan (quét toàn bảng).
-- Sau khi có index: thường sẽ thấy Index lookup / dùng key idx_hometown (tra theo chỉ mục), và thời gian/rows xử lý sẽ giảm.
--  Hãy xóa chỉ mục idx_hometown khỏi bảng user.
drop index  idx_hometown on users;


-- co ban 4 
-- 2) Tạo chỉ mục phức hợp (Composite Index)
EXPLAIN ANALYZE
select post_id, content, created_at
from posts
where user_id = 1;
-- Tạo chỉ mục phức hợp với tên idx_created_at_user_id trên bảng posts sử dụng các cột created_at và user_id.
create index  idx_created_at_user_id on posts(created_at,  user_id);
drop index idx_created_at_user_id on posts;
EXPLAIN ANALYZE
select post_id, content, created_at
from posts
where user_id = 1;
--   3) Tạo chỉ mục duy nhất (Unique Index)
EXPLAIN ANALYZE
select user_id, username, email
from  users
where email = 'an@gmail.com';
-- tao chi muc unique index 
create unique index idx_email on users(email);
EXPLAIN ANALYZE
select user_id, username, email
from  users
where email = 'an@gmail.com';
-- 4) Xóa chỉ mục
-- Xóa chỉ mục idx_created_at_user_id khỏi bảng posts.
drop index idx_created_at_user_id on posts;
-- Xóa chỉ mục idx_email khỏi bảng users.
drop index idx_email on users;
EXPLAIN
SELECT user_id, username, email
FROM users
WHERE email = 'an@gmail.com';


-- kha 1 
-- Tạo chỉ mục có tên idx_hometown trên cột hometown của bảng users
create index idx_hometown on users(hometown);
drop index  idx_hometown on users;
-- Viết một câu truy vấn để tìm tất cả các người dùng (users) có hometown là "Hà Nội"
select *from users 
where hometown = 'Hà Nội';
-- Kết hợp với bảng posts để hiển thị thêm post_id và content về các lần đăng bài. 
SELECT u.user_id, u.username, u.hometown, p.post_id, p.content
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
WHERE u.hometown = 'Hà Nội';
-- Sắp xếp danh sách theo username giảm dần và giới hạn kết quả chỉ hiển thị 10 bài đăng đầu tiên.
EXPLAIN ANALYZE 
SELECT u.user_id, u.username, u.hometown, p.post_id, p.content
FROM users u
LEFT JOIN posts p ON p.user_id = u.user_id
WHERE u.hometown = 'Hà Nội'
order by u.username desc
limit 10;

-- Sử dụng EXPLAIN ANALYZE để kiểm tra lại kế hoạch thực thi trước và sau khi có chỉ mục.
-- 2) So sánh tốc độ trước / sau (từ số bạn đưa)
-- Trước khi có index: actual time=9.71..9.75 ms
-- Sau khi có index: actual time=0.0719..0.0905 ms


-- kha 6 
create or replace view view_users_summary as
select u.user_id, u.username, count(p.user_id) as total_posts
from users u
left join posts p on p.user_id = u.user_id
group by u.user_id, u.username
having total_posts >5;

select * from view_users_summary;
drop view if exists view_users_summary;

-- gioi 7 
create or replace view view_user_activity_status as 
select 
   u.user_id,
   u.username, 
   u.gender,
   u.created_at,
   case 
      when coalesce(p.post_count, 0)>0 or coalesce(c.comment_count, 0)>0
      then 'Active'
      else 'Inactive'
      end as status 
   
--    case 
--      when status = 'Active' 
--      then p.post_count or p.comment_count
--      else 0
--      end as user_count
 from users u 
 left join (
   select user_id, count(*) as post_count
   from posts 
   group by user_id
)p on p.user_id = u.user_id
 left join (
   select user_id, count(*) as comment_count
   from comments 
   group by user_id 
 )c on c.user_id = u.user_id;
-- thong ke theo so luong người dùng và xắp sếp giảm dần 

select status, count(*) as total_user
from view_user_activity_status
group by status 
order by total_user desc ;

drop view if exists  view_user_activity_status;


-- sáng nay khi em load lại trang đã bị mất 4 bài cơ bản đầu bài giỏi 7 là xuất xắc 2 còn mấy bài trước theo thứ tự giảm dần thầy tự check nhé :)))
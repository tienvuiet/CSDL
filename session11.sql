create database session11; 
use session11;

-- kha 1 
-- Tạo stored procedure có tham số IN nhận vào p_user_id:
-- Tạo stored procedure nhận vào mã người dùng p_user_id và trả về danh sách bài viết của user đó.Thông tin trả về gồm:
-- PostID (post_id)
-- Nội dung (content)
-- Thời gian tạo (created_at)
delimiter $$
create procedure layThongTinBaiPost (in maUser int)
begin 
select p.post_id, p.content, p.created_at
from posts p
where p.post_id = maUser;
end $$
delimiter ;
-- Gọi lại thủ tục vừa tạo với user cụ thể mà bạn muốn
call layThongTinBaiPost(8);
-- Xóa thủ tục vừa tạo.
drop procedure layThongTinBaiPost;

-- kha 2 
delimiter $$
create procedure CalculatePostLikes(in p_post_id int, out  total_likes int )
begin 
   declare t_user_id int ;
   -- lay chu nhan bai post
   select user_id into t_user_id
   from posts p
   where p.post_id = p_post_id;
   -- lay tong so like nhan duoc tren tat ca bai viet cua nguoi dung
   if t_user_id is null
   then set total_likes = 0 ;
   else 
   select count(*) into total_likes 
   from likes l 
   join posts p on p.post_id = l.post_id
   where p.user_id = t_user_id ; 
   end if ; 
 end $$
 delimiter ;
 -- Thực hiện gọi stored procedure CalculatePostLikes với một post cụ thể và truy vấn giá trị của tham số OUT total_likes sau khi thủ tục thực thi.
 call CalculatePostLikes(8, @kq);
 select @kq;
 --  Xóa thủ tục vừa mới tạo trên
 drop procedure CalculatePostLikes;
 
 
 -- gioi 3 
 --  Viết stored procedure tên CalculateBonusPoints nhận hai tham số:
 delimiter $$
 create procedure CalculateBonusPoints(in p_user_id int, inout p_bonus_points int) 
 begin 
     declare countPost int default 0; 
     select count(user_id) into countPost
     from posts u
     where u.user_id = p_user_id;
     if countPost >= 10 then 
     set p_bonus_points = p_bonus_points + 50 ;
     elseif countPost >= 20 then 
     set p_bonus_points = p_bonus_points + 100;
	 end if ;
end $$
delimiter ;
set @bonus_point = 10; 
call CalculateBonusPoints(8, @bonus_point);
select  @bonus_point;
-- Xóa thủ tục mới khởi tạo trên 
drop procedure CalculateBonusPoints;
     
-- gioi 4 
delimiter $$
create procedure CreatePostWithValidation(in p_user_id int, in p_content text, out result_message varchar(255))
begin 
--     select p.user_id into v_user_id 
--     from posts p
--     where p.user_id = p_user_id;
    
    
    if CHAR_LENGTH(p_content)< 5 then 
    set result_message = 'Nội dung quá ngắn';
    else 
    set result_message = 'them thanh cong bai viet';
    update posts 
    set content = p_content
    where posts.user_id = p_user_id;
    end if;
end $$
delimiter ;
call  CreatePostWithValidation(8,'tien dep trai', @result_message);
select @result_message;


-- xuat xac 1 
delimiter $$
create procedure CalculateUserActivityScore( IN p_user_id INT, OUT activity_score INT, out activity_level varchar(50))
begin 
   declare v_countPost int default  0;
   declare v_countComment int default 0;
   declare v_countLike int default 0;
   
   select count(*) into v_countPost from posts
   where user_id = p_user_id;
   
   select count(*) into v_countComment from comments 
   where user_id = p_user_id;
    
   select count(*) into v_countLike from likes 
   where user_id = p_user_id;

   set activity_score = v_countPost* 0 + v_countComment * 5 + v_countLike * 3 ;
   if activity_score > 500 then 
   set activity_level = 'Rất tích cực';
   elseif (activity_score >= 200 and activity_score <= 500) then
   set activity_level = 'Tích cực';
   elseif (activity_score <200) then
   set activity_level = 'Bình thường';
   end if;
end $$
delimiter ;   
call CalculateUserActivityScore(1, @activity_score, @activity_level);
select @activity_score, @activity_level;
drop procedure CalculateUserActivityScore;

-- xuat xac 2 
-- delimiter $$
-- create procedure NotifyFriendsOnNewPost( in p_user_id int, in p_content text );
-- khong biet lam
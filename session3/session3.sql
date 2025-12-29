create database session3;
use session3;
-- bai kha 1, 2
create table Student (	
  student_id int auto_increment primary key, 
  full_name varchar(225) not null,
  date_of_birth date , 
  email varchar(225) unique
);
insert into Student (full_name, date_of_birth, email)
value 
   ('Vu Viet Tien', '2006-12-01', 'tienxinhzai241@gmail.com'),
   ('Dao Quang Huy', '2006-12-02', 'trithang@gmail.com'),
   ('Nguyen Tri Thang', '2006-12-19','trithangne@gmail.com'),
   ('ABC', '2006-12-02', 'abcg@gmail.com'),
   ('bcd', '2006-12-19','bcd@gmail.com');

select*from Student   ;
select student_id, full_name  from  Student;
update Student
set email = 'thaydoiemail@gmail.com'
where student_id =3;
update Student
set date_of_birth = '2006-1-01'
where student_id = 2;
delete from Student
where student_id = 9;
-- gioi 1,2 
create table Subject (	
	subject_id int auto_increment primary key, 
    subject_name varchar(225) not null, 
    credit int check(credit >0)
);
insert into Subject (subject_name, credit)
value 	
    ('tieng viet lop 1', 2),
    ('biet an loi se co duoc thien ha',3);
select* from Subject;
update Subject 
set credit = 110, subject_name = 'doidulieu'
where subject_id = 1;

create table Enrollment(	
  student_id int , 
  subject_id int,
  enroll_date date, 
  foreign key(student_id) references Student(student_id),
  foreign key(subject_id) references Subject(subject_id)
);
insert into Enrollment (student_id, subject_id, enroll_date)
value 
    (1, 1, '2025-12-29'),
    (1, 2, '2025-12-29'),
    (2, 1, '2025-12-29');
select* from Enrollment;
select* from Enrollment where  student_id = 1;

-- xuat sac 1, 2 
create table Score(	
   student_id int , 
   subject_id int , 
   mid_score double not null check(mid_score > 0 and mid_score <= 10),
   final_score double not null check(final_score > 0 and final_score <= 10),
   foreign key(student_id) references Student(student_id),
   foreign key(subject_id) references Subject(subject_id)
);
insert into Score ( student_id , subject_id, mid_score ,final_score) 
value 
    (1,1,9.4,8.2),
    (2,2,5,8),
    (2,2,6,9);
update Score 
set final_score = 4
where student_id = 1;
select * from Score;
select * from Score where  final_score>= 8;

-- them mot sinh vien moi
insert into Student (full_name, date_of_birth, email)
value 
    ('Dao Xuan Khanh', '2006-01-19', 'khanhdao@gmail.com');
-- dang ki 2 mon hoc cho sinh vien
insert into Enrollment (student_id, subject_id, enroll_date)
value 
    (3, 1, '2025-12-29'),
    (3, 2, '2025-12-29');
-- them diem sinh vien 
insert into Score ( student_id , subject_id, mid_score ,final_score) 
value 
    (3,1,9.4,8.2);
-- cap nhat diem sinh vien
update Score 
set  final_score = 1
where student_id = 3;
select * from Student where student_id = 3;
select * from Score where student_id = 3;
-- xoa mot luot dang ki khong hop le 
delete from Enrollment
where student_id = 2


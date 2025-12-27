create database session2;	
use session2;

drop table dangKiMonHoc;
drop table monhoc;
drop table sinhvien;
drop table 	giaoVien;
drop table diem;
drop table lopHoc;




create table giaoVien (	
    teacherId int auto_increment primary key, 
    teacherName varchar(100) not null, 
    teacherEmail varchar(100) not null
);
create table diem(	
    scoreId int auto_increment primary key,
    studentName varchar(100) not null, 
    subjectName varchar(100) not null, 
    processPoint double not null check(processPoint> 0 and processPoint <= 10), 
    finalScore double not null check(finalScore> 0 and finalScore <= 10)
);
create table lopHoc(	
  classId int auto_increment primary key,
  className varchar(225) not null, 
  studyYear date not null
);
create table sinhVien(	
  studentId int auto_increment primary key , 
  fullName varchar(100) not null,
  scoreId int , 
  classId int, 
  foreign key(scoreId) references diem(scoreId),
  foreign key(classId) references lopHoc(classId)
);
create table monHoc(	
  subjectId int auto_increment primary key , 
  subjectName varchar(225) not null, 
  subjectNumber int not null check(subjectNumber>0),
  teacherId int not null,
  foreign key(teacherId) references giaoVien(teacherId)
);
create table dangKiMonHoc(	
	registerId int auto_increment primary key,
    nameStudent varchar(225) not null,
    registerDay date not null,
    subjectId int not null,
    studentId int not null, 
    foreign key(subjectId) references monHoc(subjectId),
    foreign key(studentId) references sinhVien(studentId)
);

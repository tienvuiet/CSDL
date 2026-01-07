create database session7;
use session7;
-- kha 1  
create table customers(
  id int primary key auto_increment, 
  name varchar(255) not null, 
  email varchar(255) not null
); 
create table orders(
  id int primary key auto_increment, 
  customer_id int not null, 
  order_date date not null,
  total_amount decimal(10,2),
  foreign key(customer_id) references customers(id)
);
INSERT INTO customers (name, email) VALUES
('Nguyễn Văn An', 'an.nguyen@example.com'),
('Trần Thị Bình', 'binh.tran@example.com'),
('Lê Minh Châu', 'chau.le@example.com'),
('Phạm Quang Dũng', 'dung.pham@example.com'),
('Hoàng Thu Hà', 'ha.hoang@example.com'),
('Vũ Đức Khang', 'khang.vu@example.com'),
('Đặng Ngọc Lan', 'lan.dang@example.com');
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2025-12-01', 120.50),
(2, '2025-12-03', 450.00),
(3, '2025-12-05', 89.99),
(1, '2025-12-01', 300.25),
(3, '2025-12-12', 1500.00),
(5, '2025-12-15', 75.10),
(7, '2025-12-18', 999.99);
select * 
from customers 
where id in (select customer_id from orders);

-- kha 2 
create table products(	
  id int primary key auto_increment, 
  name varchar(255) not null, 
  price decimal(10,2) not null
);
create table order_items(
  order_id int primary key auto_increment, 
  product_id int not null, 
  quantity int not null,
  foreign key(product_id) references products(id)
);
INSERT INTO products (name, price) VALUES
('Bàn phím cơ', 850000.00),
('Chuột không dây', 320000.00),
('Tai nghe Bluetooth', 690000.00),
('Màn hình 24 inch', 2890000.00),
('USB 64GB', 180000.00),
('Ổ cứng SSD 512GB', 1390000.00),
('Laptop stand', 250000.00);
INSERT INTO order_items (product_id, quantity) VALUES
(1, 1),
(2, 2),
(3, 1),
(5, 3),
(4, 1),
(6, 2),
(7, 0);
-- lay danh sach san pham da tung duoc ban
select id, name
from products 
where id in (select DISTINCT product_id from order_items );

-- gioi 1 
drop table ordersG;
create table ordersG(
  id int primary key, 
  customer_id int not null, 
  order_date date not null, 
  total_amount decimal(10,2),
  foreign key(customer_id) references customersG(id)
);

INSERT INTO ordersG (id, customer_id, order_date, total_amount) VALUES
(1, 1, '2025-12-01', 1250000.00),
(2, 2, '2025-12-03', 320000.00),
(3, 1, '2025-12-10', 2890000.00),
(4, 3, '2025-12-15', 1570000.00),
(5, 4, '2025-12-20', 180000.00);
-- lay gia tri don hang co gia tri lon hon gia tri trung binh cua tat ca don hang 
select id 
from ordersG
where total_amount > (select avg(total_amount) from ordersG);
-- gioi 2 
create table customersG(
  id int primary key auto_increment, 
  name varchar(255) not null, 
  email varchar(255) not null
);
INSERT INTO customersG (name, email) VALUES
('Nguyễn Văn An',  'an.nguyen@gmail.com'),
('Trần Thị Bình',  'binh.tran@gmail.com'),
('Lê Văn Cường',   'cuong.le@gmail.com'),
('Phạm Thị Dung',  'dung.pham@gmail.com'),
('Hoàng Minh Đức', 'duc.hoang@gmail.com');
-- hien thi ten khach hang va so luong don hang cua tung khach 
select 
 c.name,
 (select count(customer_id)
  from ordersg o
  where o.customer_id = c.id
 ) as soLuongDonHang
from customersG c;


-- xuat xac 1 
-- tim khach hang co tong so tien mua hang lon nhat 
select c.*, sum(total_amount) as 'total money'
from customersg c 
join ordersG od on c.id = od.customer_id
group by c.id
having sum(total_amount)  = (	
   select sum(total_amount) from ordersG
   group by customer_id
   order by sum(total_amount) desc
   limit 1
);

-- xuat sac 2
-- khách hàng có tổng tiền mua hàng lớn hơn tổng tiền trung bình của tất cả khách hàng
select c.*, sum(od.total_amount) as tongTien
from customersg c 
join ordersg od on c.id = od.customer_id
group by c.id, od.customer_id
having sum(od.total_amount) > (select avg(od.total_amount) from od);


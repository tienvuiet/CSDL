create database session6; 
use session6;
drop table orders;
drop table customers; 

-- kha 1 
create table  customers (	
   customer_id int primary key, 
   full_name varchar(255) not null, 
   city varchar(255) not null
);	
create table orders(	
   order_id int primary key, 
   customer_id int not null , 
   
   order_date date, 
   status enum('pending', 'completed','cancelled'),
   foreign key (customer_id) references customers(customer_id)
); 
INSERT INTO customers (customer_id, full_name, city) VALUES
(1, 'Nguyen Van An', 'Ha Noi'),
(2, 'Tran Thi Bich', 'Da Nang'),
(3, 'Le Quang Huy', 'Ho Chi Minh'),
(4, 'Pham Minh Tuan', 'Can Tho'),
(5, 'Vu Viet Tien', 'Hai Phong');
INSERT INTO orders (order_id, customer_id, order_date, status) 	
VALUES
(101, 1, '2025-12-20', 'pending'),
(102, 2, '2025-12-21', 'completed'),
(103, 3, '2025-12-21', 'cancelled'),
(104, 1, '2025-12-21', 'completed'),
(105, 5, '2025-12-26', 'pending');
-- Hiển thị danh sách đơn hàng kèm tên khách hàng
select customers.full_name, orders.order_id, orders.order_date
from customers
inner join orders on customers.customer_id = orders.customer_id;
-- hien thi mot khach hang da dat bao nhieu don hang 
select c.customer_id, c.full_name, count(o.customer_id) 
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.full_name, c.customer_id;
-- Cột nào xuất hiện trong SELECT mà không nằm trong hàm tổng hợp (COUNT, SUM, ...) thì phải nằm trong GROUP BY.
-- Chỉ hiển thị các khách hàng có ít nhất 1 đơn hàng
select c.customer_id, c.full_name, count(o.customer_id) as tongSoDon
from customers c
inner join orders o on c.customer_id = o.customer_id
group by c.full_name, c.customer_id;

-- kha 2 
-- Bổ sung cột tổng tiền vào bảng đơn hàng (orders)
alter table orders add column total_amount decimal(10,2) ; 
update orders 
set total_amount  = case order_id
   when 101 then 10000.20
   when 102 then 210000.00
   when 103 then 15000.2
   when 104 then 320000
   when 105 then 100000.32
   else total_amount 
   end 
where order_id in (101,102,103,104,105);
select *from orders;
-- Hiển thị tổng tiền mà mỗi khách hàng đã chi tiêu
select c.customer_id, c.full_name, sum(o.total_amount) as tongTien
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.full_name;
-- Hiển thị giá trị đơn hàng cao nhất của từng khách
select o.customer_id, c.full_name, max(o.total_amount) as tongTienCaoNhat
from customers c 
left join orders o on  c.customer_id = o.customer_id
group by o.customer_id, c.full_name;
-- Sắp xếp danh sách khách hàng theo tổng tiền giảm dần
select c.customer_id, c.full_name, sum(o.total_amount)  as tongTien
from customers c
left join orders o on c.customer_id = o.customer_id 
group by c.customer_id, c.full_name
order by tongTien desc;


-- gioi 1 
-- Tính tổng doanh thu theo từng ngày
select o.order_date, sum(o.total_amount) as tongDoanhThu
from orders o
where o.status = 'completed'
group by o.order_date
order by o.order_date;
-- Tính số lượng đơn hàng theo từng ngày
select o.order_date, count(o.order_id) as soLuongDon
from orders o 
group by o.order_date
order by o.order_date;
-- Chỉ hiển thị các ngày có doanh thu > 320000
select o.order_date, o.total_amount
from orders o
where o.total_amount > 32000;

-- gioi 2 
create table products(	
  product_id int primary key auto_increment,
  product_name varchar(255) not null, 
  price decimal(10,2) not null
);
create table order_items(
  order_id int primary key auto_increment,
  product_id int not null, 
  foreign key(product_id) references products(product_id),
  quantity int not null
); 
-- Thêm dữ liệu cho 2 bảng mỗi bảng tối thiểu 5 dữ liệu mẫu
INSERT INTO products (product_name, price) VALUES
('Laptop Dell Inspiron', 15000000.00),
('Chuột Logitech', 350000.00),
('Bàn phím cơ', 1200000.00),
('Tai nghe Bluetooth', 800000.00),
('Màn hình 24 inch', 3200000.00);
INSERT INTO order_items (product_id, quantity) VALUES
(1, 1),   -- 1 laptop
(2, 2),   -- 2 chuột
(3, 1),   -- 1 bàn phím
(4, 3),   -- 3 tai nghe
(5, 1);   -- 1 màn hình
select *from products;
select *from order_items;
-- Hiển thị mỗi sản phẩm đã bán được bao nhiêu 
select p.product_id, p.product_name, o.quantity as soLuongBan
from products p
left join order_items o on p.product_id = o.product_id;
-- tinh doanh thu cua tung san pham 
select p.product_name, sum(p.price * o.quantity) as tongDoanhThu
from products p
left join order_items o on o.product_id = p.product_id
where o.quantity >0
group by  p.product_name;
-- Chỉ hiển thị các sản phẩm có doanh thu > 5.000.000
select p.product_name, sum(p.price * o.quantity) as tongDoanhThu
from products p
left join order_items o on o.product_id = p.product_id
where o.quantity >0
group by  p.product_name
having sum(p.price * o.quantity)> 5000000;

-- xuat xac 1
-- Tổng số đơn hàng của mỗi khách
select  c.customer_id,c.full_name, count(o.customer_id  ) as soDon
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id,c.full_name;
-- Tổng số tiền đã chi
select c.full_name, sum(o.total_amount) as tongTienDaChi 
from customers c
left join orders o on c.customer_id = o.customer_id
group by  c.full_name;
-- Giá trị đơn hàng trung bình
select c.full_name, avg(o.total_amount) as gtDonTb
from customers c 
left join orders o on c.customer_id = o.customer_id
group by  c.full_name;
-- Chỉ hiển thị khách hàng
-- --  co tu 2 don tro len  Và tổng tiền > 500.000
select  c.customer_id,c.full_name, count(o.customer_id  ) as soDon, sum(o.total_amount) as tongSotien
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id,c.full_name
having  count(o.customer_id  )>= 2 and  tongSotien> 50000
order by tongSotien desc;


-- xuat xac 2 
-- hien thi: ten sp, tong so luong ban, tong doanh thu, gia ban trung binh 
SELECT
  p.product_name AS tenSanPham,
  SUM(oi.quantity) AS tongSoLuongBan,
  SUM(oi.quantity * p.price) AS tongDoanhThu,
  ROUND(SUM(oi.quantity * p.price) / SUM(oi.quantity), 2) AS giaBanTrungBinh
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.price
HAVING SUM(oi.quantity) >= 2
ORDER BY tongDoanhThu DESC
LIMIT 2;

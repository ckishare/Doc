-- 1、插入新记录
insert into dept
  (deptno, dname, loc)
values
  (50, 'PROGRAMMING', 'BALTIMORE');
  
  
-- 2、插入默认值
create table D (id integer default 0);
insert into D values (default);
insert into D (id) values (default);
select * from D;


-- 3、使用null覆盖默认值
create table D1 (id integer default 0, foo VARCHAR(10));
insert into D1(id, foo) values (null, 'Brighten');   -- ID 列插入null
insert into D1 (foo) values ('Brighten');  -- 插入默认值
select * from D1;


-- 4、复制数据到另一个表
create table DEPT_EAST
(
  deptno NUMBER,
  dname  VARCHAR2(32),
  loc    VARCHAR2(32)
)

insert into dept_east
  (deptno, dname, loc)
  select deptno, dname, loc from dept where loc in ('NEW YORK', 'BOSTON');
  
select * from dept_east;


-- 5、复制表定义
create table DEPT_MID
as
 select *
 from dept
 where 1 = 0;
select * from dept_west; 

-- 6、多表插入
-- 把 DEPT 表的数据分别插入到 DEPT_EAST 表、 DEPT_WEST 表和 DEPT_MID 表
insert all when loc in
  ('NEW YORK', 'BOSTON') then into dept_east
  (deptno, dname, loc)
values
  (deptno, dname, loc) when loc = 'CHICAGO' then into dept_mid
  (deptno, dname, loc)
values
  (deptno, dname, loc) else into dept_west
  (deptno, dname, loc)
values
  (deptno, dname, loc)
  select deptno, dname, loc from dept;
  
  
 


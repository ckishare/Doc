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
);

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
-- INSERT FIRST 和 INSERT ALL 的区别 （后者有可能把同一行数据插入到多个表）
insert all when loc in
                ('NEW YORK', 'BOSTON') then into dept_east (deptno, dname, loc)
values (deptno, dname, loc) when loc = 'CHICAGO' then into dept_mid (deptno, dname, loc)
values (deptno, dname, loc) else into dept_west (deptno, dname, loc)
values (deptno, dname, loc)
select deptno, dname, loc
from dept;


-- 7、禁止插入特定列
-- 为那些可以向上面三个列中写入数据的用户和程序赋予视图的插入权限。不要把 EMP 表的插入权限授权给用户。
-- 这样用户插入数据到 NEW_EMPS 视图后就可以创建新的 EMP 记录，但是他们不能为视图定义里不存在的列提供插入值。
create view new_emps as
  select empno, ename, job
  from emp;

-- 向一个简单视图插入数据，数据库服务器会把它转换为针对基础表的插入操作
insert into new_emps (empno, ename, job)
values (1, 'Jonathan', 'Editor');


-- 8、


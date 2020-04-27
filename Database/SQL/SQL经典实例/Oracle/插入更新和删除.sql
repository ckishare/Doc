-- 1�������¼�¼
insert into dept
  (deptno, dname, loc)
values
  (50, 'PROGRAMMING', 'BALTIMORE');
  
  
-- 2������Ĭ��ֵ
create table D (id integer default 0);
insert into D values (default);
insert into D (id) values (default);
select * from D;


-- 3��ʹ��null����Ĭ��ֵ
create table D1 (id integer default 0, foo VARCHAR(10));
insert into D1(id, foo) values (null, 'Brighten');   -- ID �в���null
insert into D1 (foo) values ('Brighten');  -- ����Ĭ��ֵ
select * from D1;


-- 4���������ݵ���һ����
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


-- 5�����Ʊ���
create table DEPT_MID
as
 select *
 from dept
 where 1 = 0;
select * from dept_west; 

-- 6��������
-- �� DEPT ������ݷֱ���뵽 DEPT_EAST �� DEPT_WEST ��� DEPT_MID ��
-- INSERT FIRST �� INSERT ALL ������ �������п��ܰ�ͬһ�����ݲ��뵽�����
insert all when loc in
                ('NEW YORK', 'BOSTON') then into dept_east (deptno, dname, loc)
values (deptno, dname, loc) when loc = 'CHICAGO' then into dept_mid (deptno, dname, loc)
values (deptno, dname, loc) else into dept_west (deptno, dname, loc)
values (deptno, dname, loc)
select deptno, dname, loc
from dept;


-- 7����ֹ�����ض���
-- Ϊ��Щ������������������д�����ݵ��û��ͳ�������ͼ�Ĳ���Ȩ�ޡ���Ҫ�� EMP ��Ĳ���Ȩ����Ȩ���û���
-- �����û��������ݵ� NEW_EMPS ��ͼ��Ϳ��Դ����µ� EMP ��¼���������ǲ���Ϊ��ͼ�����ﲻ���ڵ����ṩ����ֵ��
create view new_emps as
  select empno, ename, job
  from emp;

-- ��һ������ͼ�������ݣ����ݿ�����������ת��Ϊ��Ի�����Ĳ������
insert into new_emps (empno, ename, job)
values (1, 'Jonathan', 'Editor');


-- 8��


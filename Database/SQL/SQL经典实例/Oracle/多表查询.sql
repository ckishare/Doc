-- 1、查找两个表中相同的行
-- intersect 的用法（相当于交集）
select empno, ename, job, sal, deptno
from emp
where (ename, job, sal) in (select ename, job, sal from emp
                            intersect
                            select ename, job, sal from V);

-- 2、查询只存在一个表中的数据
-- minus 差集函数
select deptno
from dept
minus
select deptno
from emp;

select deptno
from dept
where deptno not in (select deptno from emp);

-- 使用 NOT IN 的时候应该注意 null 值
select *
from dept
where deptno not in (select deptno from new_dept);

--由于 IN 和 NOT IN 本质上是 OR 运算，而 NULL 参与OR逻辑运算的方式不同，他们会产生不同的结果
select deptno
from dept
where deptno in (10, 50, null);

select deptno
from dept
where (deptno = 10 or deptno = 50 or deptno = null);

-----------  使用 NOT IN 和 NOT OR 的例子 ----------------------
select deptno
from dept
where deptno not in (10, 50, null);

select deptno
from dept
where not (deptno = 10 or deptno = 50 or deptno = null);

-- 当 deptno = 10 >> true false null >> false
-- 当 deptno = 50 >> false false null >> null
-- not (deptno=10 or deptno=50 or deptno=null)
--      (false or false or null)
--      (false or null)
--      null

----------------------------------------------------------------


-------------------解决方案 not exists --------------------------

select d.deptno
from dept d
where not exists(select null from emp e where d.deptno = e.deptno);

-- 如果子查询有结果返回给外层查询，那么exists的返回结果是 true, 那么 not exists 则会返回 false

----------------------------------------------------------------


-- 3、从一个表中检索与另一个表不相关的行
-- 左外连接（左表全部查出来）
select d.*
from dept d
       left outer join emp e on (d.deptno = e.deptno)
where e.deptno is null;

select d.*
from dept d,
     emp e
where d.deptno = e.deptno (+)  and e.deptno is null;


-- 4、确定两个表是否有相同的数据
-- 找出两个表不同的数据
create view V2
  as
    select *
    from emp
    where deptno != 10
    union all
    select *
    from emp
    where ename = 'WARD';

-- 第一个结果集去掉第二个结果集中存在的数据
-- 使用集合运算 MINUS 和 UNION ALL 找出视图 V 和 EMP 表的不同之处
select empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm,
       deptno,
       count(*) as cnt
from V2
group by empno, ename, job, mgr, hiredate, sal, comm, deptno
minus
select empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm,
       deptno,
       count(*) as cnt
from emp
group by empno, ename, job, mgr, hiredate, sal, comm, deptno;


-- 5、组合使用连接查询与聚合函数
-- 在连接查询里进行聚合运算时，必须十分小心才行。如果连接查询产生了重复行
-- 方法一：调用聚合函数时直接使用关键字 DISTINCT，这样每个值都会先去掉重复项再参与计算
-- 方法二：在进行连接查询之前先执行聚合运算

select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal * case
                 when eb.type = 1 then .1
                 when eb.type = 2 then .2
                 else .3 end as bonus
from emp e,
     emp_bonus eb
where e.empno = eb.empno
  and e.deptno = 10;

-- 工资总额是错误的，员工工资重复累加
select deptno, sum(sal) as total_sal, sum(bonus) as total_bonus
from (select e.empno,
             e.ename,
             e.sal,
             e.deptno,
             e.sal * case
                       when eb.type = 1 then .1
                       when eb.type = 2 then .2
                       else .3 end as bonus
      from emp e,
           emp_bonus eb
      where e.empno = eb.empno
        and e.deptno = 10)x
group by deptno;

-- 解决方案  窗口函数 SUM OVER 的使用
-- sum(distinct e.sal) over (partition by e.deptno) 按照 e.deptno 进行分组
select distinct deptno, total_sal, total_bonus
from (select e.empno,
             e.ename,
             sum(distinct e.sal) over
               (partition by e.deptno)                             as total_sal,
             e.deptno,
             sum(e.sal * case
                           when eb.type = 1 then .1
                           when eb.type = 2 then .2
                           else .3 end) over (partition by deptno) as total_bonus
      from emp e,
           emp_bonus eb
      where e.empno = eb.empno
        and e.deptno = 10)x;


-- 6、在运算和比较中使用 null 
-- coalesce 的使用
select ename, comm, coalesce(to_number(comm), 0)
  from emp
 where coalesce(to_number(comm), 0) < (select comm from emp where ename = 'WARD');

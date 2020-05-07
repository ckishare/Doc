-- 1、计算同一组或分区的行之间的差
-- 首先使用标量子查询找出同一个部门里紧随当前员工之后入职的员工的 HIREDATE
-- 使用了 MIN(HIREDATE) 来确保仅返回一个值，即使同一天入职的员工 不止一个人，也只会返回一个值
select deptno, ename, hiredate, sal, coalesce(cast(sal - next_sal as char(10)), 'N/A') as diff
from (select e.deptno, e.ename, e.hiredate, e.sal, (select min(sal)
                                                    from emp d
                                                    where d.deptno = e.deptno
                                                      and d.hiredate =
                                                          (select min(hiredate) from emp d where e.deptno = d.deptno
                                                                                             and d.hiredate > e.hiredate)) as next_sal
      from emp e) x;
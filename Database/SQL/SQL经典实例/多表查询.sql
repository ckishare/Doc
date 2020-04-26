-- 查找两个表中相同的行
-- intersect 的用法（相当于交集）
select empno, ename, job, sal, deptno
  from emp
 where (ename, job, sal) in (select ename, job, sal
                               from emp
                             intersect
                             select ename, job, sal
                               from V)

-- 查询只存在一个表中的数据
-- minus 差集函数
select deptno from dept minus select deptno from emp;


                 

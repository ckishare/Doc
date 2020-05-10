-- 1、结果集分页
/*
  LIMIT 子句指定要返回的行数
  OFFSET 子句指定要跳过的行数
 */
SELECT sal
FROM emp
ORDER BY sal LIMIT 5 OFFSET 0;


-- 2、跳过n行记录
-- where b.ename <= a.ename 模拟排序，ename按照姓名来排序（字典顺序）
SELECT x.ename
FROM (SELECT a.ename,
             (SELECT COUNT(*) FROM emp b WHERE b.ename <= a.ename) AS rn
      FROM emp a)X
WHERE MOD(x.rn, 2) = 1;

-- 3、在外连接查询里使用OR逻辑
SELECT e.ename, d.deptno, d.dname, d.loc
FROM dept d
       LEFT JOIN emp e ON (d.deptno = e.deptno
                             AND (e.deptno = 10 OR e.deptno = 20))
ORDER BY 2;

-- 4、找出最大和最小的记录
select ename
from emp
where sal in ((select min(sal) from emp), (select max(sal) from emp));

-- 5、查询未来的行
-- 入职比他晚、且工资更高的员工当中最早入职的那个人的入职日期
-- 入职比他晚的员工当中最早入职的那个人的入职日期。
select ename, sal, hiredate
from (select a.ename,
             a.sal,
             a.hiredate,
             (select min(hiredate) from emp b where b.hiredate > a.hiredate
                                                and b.sal > a.sal)           as next_sal_grtr,
             (select min(hiredate) from emp b where b.hiredate > a.hiredate) as next_hire
      from emp a) x
where next_sal_grtr = next_hire;




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

-- 4、提取最靠前的N行记录




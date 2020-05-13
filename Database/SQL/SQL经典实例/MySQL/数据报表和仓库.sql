-- 1、返回非分组列
/*
   使用场景：你正在执行 GROUP BY 查询，并希望通过 SELECT 列表返回一些列，但这些列却不会出现在 GROUP BY 子句里
   
   需求：你希望找出每个部门工资最高和最低的员工，同时也希望找出每个职位对应的工资最高和最低的员工
   你想查看每个员工的名字、部门、职位以及工资
*/

SELECT deptno, ename, job, sal  -- 每个 DEPTNO 和 JOB 对应的最高和最低的工资可以和 EMP 表里其他的工资比较了
	, CASE 
		WHEN sal = max_by_dept THEN 'TOP SAL IN DEPT'
		WHEN sal = min_by_dept THEN 'LOW SAL IN DEPT'
	END AS dept_status
	, CASE 
		WHEN sal = max_by_job THEN 'TOP SAL IN JOB'
		WHEN sal = min_by_job THEN 'LOW SAL IN JOB'
	END AS job_status
FROM (
	SELECT e.deptno, e.ename, e.job, e.sal  -- 使用标量子查询找出每个 DEPTNO 和 JOB 对应的最高和最低的工资
		, (
			SELECT MAX(sal)
			FROM emp d
			WHERE d.deptno = e.deptno
		) AS max_by_dept
		, (
			SELECT MAX(sal)
			FROM emp d
			WHERE d.job = e.job
		) AS max_by_job
		, (
			SELECT MIN(sal)
			FROM emp d
			WHERE d.deptno = e.deptno
		) AS min_by_dept
		, (
			SELECT MIN(sal)
			FROM emp d
			WHERE d.job = e.job
		) AS min_by_job
	FROM emp e
) X
WHERE sal IN (max_by_dept, max_by_job, min_by_dept, min_by_job);


-- 2、计算所有可能的表达式组合的小计
SELECT deptno, job,
 'TOTAL BY DEPT AND JOB' AS category,
 SUM(sal) AS sal
 FROM emp
 GROUP BY deptno, job
 UNION ALL
 SELECT NULL, job, 'TOTAL BY JOB', SUM(sal)
 FROM emp
 GROUP BY job
 UNION ALL
 SELECT deptno, NULL, 'TOTAL BY DEPT', SUM(sal)
 FROM emp
 GROUP BY deptno
 UNION ALL
 SELECT NULL,NULL,'GRAND TOTAL FOR TABLE', SUM(sal)
 FROM emp;








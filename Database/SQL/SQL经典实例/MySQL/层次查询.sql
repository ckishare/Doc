-- 1、展现父子关系
SELECT CONCAT(a.ename, ' works for ', b.ename) AS emps_and_mgrs
FROM emp a,
     emp b
WHERE a.mgr = b.empno;

-- 2、展现祖孙关系
SELECT 
  CONCAT(a.ename , '-->' , b.ename , '-->' , c.ename) AS leaf___branch___root 
FROM
  emp a,
  emp b,
  emp c 
WHERE a.ename = 'MILLER' 
  AND a.mgr = b.empno 
  AND b.mgr = c.empno ;
  
-- 3、创建层次视图
SELECT 
  emp_tree 
FROM
  (SELECT 
    ename AS emp_tree 
  FROM
    emp 
  WHERE mgr IS NULL -- 顶层
  UNION
  SELECT 
    CONCAT(a.ename, ' - ', b.ename) 
  FROM
    emp a 
    JOIN emp b 
      ON (a.empno = b.mgr) 
  WHERE a.mgr IS NULL -- 2层
  UNION
  SELECT 
    CONCAT(
      a.ename,
      ' - ',
      b.ename,
      ' - ',
      c.ename
    ) 
  FROM
    emp a 
    JOIN emp b 
      ON (a.empno = b.mgr) 
    LEFT JOIN emp c 
      ON (b.empno = c.mgr) 
  WHERE a.ename = 'KING' -- 3层
  UNION
  SELECT 
    CONCAT(
      a.ename,
      ' - ',
      b.ename,
      ' - ',
      c.ename,
      ' - ',
      d.ename
    ) 
  FROM
    emp a 
    JOIN emp b 
      ON (a.empno = b.mgr) 
    JOIN emp c 
      ON (b.empno = c.mgr) 
    LEFT JOIN emp d 
      ON (c.empno = d.mgr) 
  WHERE a.ename = 'KING') X -- 4层
WHERE tree IS NOT NULL 
ORDER BY 1 ;

-- 4、找出给定的父节点对应的所有子节点
-- 三个标量子查询
SELECT e.ename,
 (SELECT SIGN(COUNT(*)) FROM emp d
 WHERE 0 = (SELECT COUNT(*) FROM emp f
 WHERE f.mgr = e.empno)) AS is_leaf,
 (SELECT SIGN(COUNT(*)) FROM emp d  -- 数字n的符号,大于0返回1, 小于0返回-1, 等于0返回0
 WHERE d.mgr = e.empno
 AND e.mgr IS NOT NULL) AS is_branch,
 (SELECT SIGN(COUNT(*)) FROM emp d
 WHERE d.empno = e.empno
 AND d.mgr IS NULL) AS is_root
 FROM emp e
 ORDER BY 4 DESC,3 DESC;

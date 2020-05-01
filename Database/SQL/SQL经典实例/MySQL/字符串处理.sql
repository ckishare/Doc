-- 1、判断含有字母和数字的字符串
CREATE VIEW V AS 
SELECT 
  ename AS DATA 
FROM
  emp 
WHERE deptno = 10 
UNION
ALL 
SELECT 
  CONCAT(ename, ', $', sal, '.00') AS DATA 
FROM
  emp 
WHERE deptno = 20 
UNION
ALL 
SELECT 
  CONCAT(ename, deptno) AS DATA 
FROM
  emp 
WHERE deptno = 30 ;

-- 使用正则表达式
-- 返回值等于 1 代表 TRUE ，0 代表 FALSE
-- 执行非数字和字母字符匹配操作，并返回结果等于 FALSE 的行
SELECT
  DATA
FROM
  V
WHERE DATA REGEXP '[^0-9a-zA-Z]' = 0;


-- 2、提取姓名首字母
SELECT 
  CASE
    WHEN cnt = 2 
    THEN TRIM(
      TRAILING '.' FROM CONCAT_WS(
        '.',
        SUBSTR(SUBSTRING_INDEX(NAME, ' ', 1), 1, 1),
        SUBSTR(
          NAME,
          LENGTH(SUBSTRING_INDEX(NAME, ' ', 1)) + 2,
          1
        ),
        SUBSTR(SUBSTRING_INDEX(NAME, ' ', - 1), 1, 1),
        '.'
      )
    ) 
    ELSE TRIM(
      TRAILING '.' FROM CONCAT_WS(
        '.',
        SUBSTR(SUBSTRING_INDEX(NAME, ' ', 1), 1, 1),
        SUBSTR(SUBSTRING_INDEX(NAME, ' ', - 1), 1, 1)
      )
    ) 
  END AS initials 
FROM
  (SELECT 
    NAME,
    LENGTH(NAME) - LENGTH(REPLACE(NAME, ' ', '')) AS cnt 
  FROM
    (SELECT 
      REPLACE('Stewie Griffin', '.', '') AS NAME 
    FROM
      t1) Y) X-- substring_index() 截取字符串    
  SELECT 
    SUBSTR(SUBSTRING_INDEX(NAME, ' ', 1), 1, 1) AS a,
    SUBSTR(SUBSTRING_INDEX(NAME, ' ', - 1), 1, 1) AS b 
  FROM
    (SELECT 
      'Stewie Griffin' AS NAME 
    FROM
      t1) X

      
-- 3、创建分割列表
SELECT 
  deptno,
  GROUP_CONCAT(ename 
    ORDER BY empno SEPARATOR, ',') AS emps 
FROM
  emp 
GROUP BY deptno; 

-- 4、按字母表顺序排列字符
/*
   内嵌视图 ITER 用于遍历字符串。其余的工作都交由 GROUP_CONCAT 函数完成
   通过指定排序方式， GROUP_CONCAT 函数不仅能串接每个字母，还能按照字母表顺序对它们进行排序
*/
SELECT 
  ename,
  GROUP_CONCAT(c 
    ORDER BY c SEPARATOR '') 
FROM
  (SELECT 
    ename,
    SUBSTR(a.ename, iter.pos, 1) c 
  FROM
    emp a,
    (SELECT 
      id pos 
    FROM
      t10) iter 
  WHERE iter.pos <= LENGTH(a.ename)) X
GROUP BY ename;




-- 1、年月日加减法
-- 方案一
SELECT 
  hiredate - INTERVAL 5 DAY AS hd_minus_5D,
  hiredate + INTERVAL 5 DAY AS hd_plus_5D,
  hiredate - INTERVAL 5 MONTH AS hd_minus_5M,
  hiredate + INTERVAL 5 MONTH AS hd_plus_5M,
  hiredate - INTERVAL 5 YEAR AS hd_minus_5Y,
  hiredate + INTERVAL 5 YEAR AS hd_plus_5Y 
FROM
  emp 
WHERE deptno = 10 ;

-- 方案二
SELECT 
  DATE_ADD(hiredate, INTERVAL - 5 DAY) AS hd_minus_5D,
  DATE_ADD(hiredate, INTERVAL 5 DAY) AS hd_plus_5D,
  DATE_ADD(hiredate, INTERVAL - 5 MONTH) AS hd_minus_5M,
  DATE_ADD(hiredate, INTERVAL 5 MONTH) AS hd_plus_5M,
  DATE_ADD(hiredate, INTERVAL - 5 YEAR) AS hd_minus_5Y,
  DATE_ADD(hiredate, INTERVAL 5 YEAR) AS hd_plus_5DY 
FROM
  emp 
WHERE deptno = 10 ;

-- 2、计算两个日期之间的天数
-- 方案一
SELECT 
  ward_hd - allen_hd 
FROM
  (SELECT 
    hiredate AS ward_hd 
  FROM
    emp 
  WHERE ename = 'WARD') X,
  (SELECT 
    hiredate AS allen_hd 
  FROM
    emp 
  WHERE ename = 'ALLEN') Y;

-- 方案二
SELECT 
  DATEDIFF(ward_hd, allen_hd) 
FROM
  (SELECT 
    hiredate AS ward_hd 
  FROM
    emp 
  WHERE ename = 'WARD') X,
  (SELECT 
    hiredate AS allen_hd 
  FROM
    emp 
  WHERE ename = 'ALLEN') Y;

-- 3、计算两个日期直接的工作日
-- 使用 DATE_ADD 函数为每一个日期加上若干天
-- 使用 DATE_FORMAT 函数能够知道一个日期是星期几
SELECT 
  SUM(
    CASE
      WHEN DATE_FORMAT(
        DATE_ADD(jones_hd, INTERVAL tt500.id - 1 DAY),
        '%a'
      ) IN ('Sat', 'Sun') 
      THEN 0 
      ELSE 1 
    END
  ) AS days 
FROM
  (SELECT 
    MAX(
      CASE
        WHEN ename = 'BLAKE' 
        THEN hiredate 
      END
    ) AS blake_hd,
    MAX(
      CASE
        WHEN ename = 'JONES' 
        THEN hiredate 
      END
    ) AS jones_hd 
  FROM
    emp 
  WHERE ename IN ('BLAKE', 'JONES')) X,
  tt500 
WHERE tt500.id <= DATEDIFF(blake_hd, jones_hd) + 1;

-- 4、计算出两个日期直接相差的年份和月份
-- 使用函数 YEAR 和 MONTH 计算出给定日期的含有 4 位数字的年份和含有 2 位数字的月份
SELECT 
  mnth,
  mnth / 12 
FROM
  (SELECT 
    (YEAR(max_hd) - YEAR(min_hd)) * 12 + (MONTH(max_hd) - MONTH(min_hd)) AS mnth 
  FROM
    (SELECT 
      MIN(hiredate) AS min_hd,
      MAX(hiredate) AS max_hd 
    FROM
      emp) X) Y;
      
-- 5、计算两个日期直接相差的时分秒
-- 使用 DATEDIFF 函数计算 ALLEN 和 WARD 的 HIREDATE 之间相差多少天，然后进行时间单位换算
SELECT 
  DATEDIFF(ward_hd, allen_hd) * 24 hr,
  DATEDIFF(ward_hd, allen_hd) * 24 * 60 MIN,
  DATEDIFF(ward_hd, allen_hd) * 24 * 60 * 60 sec 
FROM
  (SELECT 
    MAX(
      CASE
        WHEN ename = 'WARD' 
        THEN hiredate 
      END
    ) AS ward_hd,
    MAX(
      CASE
        WHEN ename = 'ALLEN' 
        THEN hiredate 
      END
    ) AS allen_hd 
  FROM
    emp) X;
    
-- 6、统计一年中有多少个星期一
-- DATE_FORMAT() 函数用于以不同的格式显示日期/时间数据。
/*
   结合 T500 表执行 SELECT 查询，为一年中的每一个日期生成单独的一行数据
   
*/
SELECT 
  DATE_FORMAT( -- 调用 DATE_FORMAT 函数能够返回每一个日期是星期几
    DATE_ADD( -- 调用DATEADD 函数将其与 TT500.ID 逐一相加以生成一年里的每一天
      CAST(
        CONCAT(YEAR(CURRENT_DATE), '-01-01') AS DATE -- 用于生成当前年份的第一天
      ),
      INTERVAL tt500.id - 1 DAY
    ),
    '%W'
  ) DAY,
  COUNT(*) 
FROM
  tt500 
WHERE tt500.id <= DATEDIFF( -- 要先找出当前年份第一天和下一年度第一天之间的差值，并生成与之相等数目的行
    CAST(
      CONCAT(YEAR(CURRENT_DATE) + 1, '-01-01') AS DATE
    ),
    CAST(
      CONCAT(YEAR(CURRENT_DATE), '-01-01') AS DATE
    )
  ) 
GROUP BY DATE_FORMAT(  -- 以星期几来分组
    DATE_ADD(
      CAST(
        CONCAT(YEAR(CURRENT_DATE), '-01-01') AS DATE
      ),
      INTERVAL tt500.id - 1 DAY
    ),
    '%W'
  ) ;


-- 7、计算当前记录和下一条记录之间的日期差
SELECT 
  x.*,
  DATEDIFF(x.next_hd ,x.hiredate) diff 
FROM
  (SELECT 
    e.deptno,
    e.ename,
    e.hiredate,
    (SELECT 
      MIN(d.hiredate) 
    FROM
      emp d 
    WHERE d.hiredate > e.hiredate) next_hd 
  FROM
    emp e 
  WHERE e.deptno = 10) X;


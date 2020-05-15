------------------------------------------------ 逻辑否定问题 ------------------------------------------------
-- 1、找出没有选修过 CS112 课程的学生
-- 错误方案
-- 由于是一行一行遍历，所以当有的学生选了多门课程就会出现问题
-- 选择多门课程的情况下，要分祖判断没有一门是 CS112 课程
SELECT *
FROM student
WHERE sno IN (
	SELECT sno
	FROM take
	WHERE cno != 'CS112'
);
  
-- MySQL解决方案
SELECT s.sno, s.sname, s.age
FROM student s
	LEFT JOIN take t ON s.sno = t.sno 
GROUP BY s.sno, s.sname, s.age
HAVING MAX(CASE 
	WHEN t.cno = 'CS112' THEN 1
	ELSE 0
END) = 0;

-- Oracle 中利用窗口函数来解决
SELECT DISTINCT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, MAX(CASE 
			WHEN t.cno = 'CS112' THEN 1
			ELSE 0
		END) OVER (PARTITION BY s.sno, s.sname, s.age) AS takes_CS112
	FROM student s, take t
	WHERE s.sno = t.sno(+)
) X
WHERE takes_CS112 = 0;

-- 2、找出只选修了 CS112 和 CS114 中的一门
-- 错误方案，没有对每个学生进行分组判断
SELECT *
FROM student
WHERE sno IN (
	SELECT *
	FROM take
	WHERE cno != 'CS112'
		AND cno != 'CS114'
);

-- 正确方案，需要用分组来确定每一个学生
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
GROUP BY s.sno, s.sname, s.age
HAVING SUM(CASE 
	WHEN t.cno IN ('CS112', 'CS114') THEN 1
	ELSE 0
END) = 1;

-- Oracle 解决方案(窗口函数)
SELECT DISTINCT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, SUM(CASE 
			WHEN t.cno IN (' CS112 ', ' CS114 ') THEN 1
			ELSE 0
		END) OVER (PARTITION BY s.sno, s.sname, s.age) AS takes_either_or
	FROM student s, take t
	WHERE s.sno = t.sno
) X
WHERE takes_either_or = 1;

-- 3、选修了 CS112 ，而且没有选修其他课程的学生
-- 错误方案
SELECT s.*
FROM student s, take t
WHERE s.sno = t.sno
AND t.cno = 'CS112';

-- 正确方案
-- 谁只选修了一门课程，并且这门课是 CS112
SELECT s.*
FROM student s, take t1, (
		SELECT sno
		FROM take
		GROUP BY sno
		HAVING COUNT(*) = 1
	) t2
WHERE s.sno = t1.sno
	AND t1.sno = t2.sno
	AND t1.cno = 'CS112';
	
-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, t.cno
		, COUNT(t.cno) OVER (PARTITION BY s.sno, s.sname, s.age) AS cnt
	FROM student s, take t
	WHERE s.sno = t.sno
) X
WHERE cnt = 1
	AND cno = 'CS112';
	
----------------------------------------------AT Most 条件问题------------------------------------------------
-- 4、找出最多选修两门课程的学生，没有选修任何课程的学生应该被排除在外
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
GROUP BY s.sno, s.sname, s.age
HAVING COUNT(*) <= 2;

-- Oracle 解决方案
SELECT DISTINCT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, COUNT(*) OVER (PARTITION BY s.sno, s.sname, s.age) AS cnt
	FROM student s, take t
	WHERE s.sno = t.sno
) X
WHERE cnt <= 2;

-- 5、找出年龄最多大于其他两名同学的学生
-- 找出那些比其他 0 个、1 个或者 2 个学生年龄大的学生
-- 找出所有年龄小的学生集合，然后 小于等于 2
SELECT s1.*
FROM student s1
WHERE 2 >= (
	SELECT COUNT(*)
	FROM student s2
	WHERE s2.age < s1.age
);

-- Oracle 解决方案
-- DENSE_RANK() 排序函数
SELECT sno, sname, age
FROM (
	SELECT sno, sname, age, DENSE_RANK() OVER (ORDER BY age) AS dr
	FROM student
) X
WHERE dr <= 3;

----------------------------------------------AT Least条件问题------------------------------------------------
-- 6、找出至少选修了两门课程的学生
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
GROUP BY s.sno, s.sname, s.age
HAVING COUNT(*) >= 2;

-- Oracle 解决方案
SELECT DISTINCT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, COUNT(*) OVER (PARTITION BY s.sno, s.sname, s.age) AS cnt
	FROM student s, take t
	WHERE s.sno = t.sno
) X
WHERE cnt >= 2;

-- 7、找出同时选修了 CS112 和 CS114 两门课程的学生
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
	AND t.cno IN ('CS114', 'CS112')
GROUP BY s.sno, s.sname, s.age
HAVING MIN(t.cno) != MAX(t.cno);

-- Oracle 解决方案
SELECT DISTINCT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, MIN(cno) OVER (PARTITION BY s.sno) AS min_cno
		, MAX(cno) OVER (PARTITION BY s.sno) AS max_cno
	FROM student s, take t
	WHERE s.sno = t.sno
		AND t.cno IN ('CS114', 'CS112')
) X
WHERE min_cno != max_cno;

-- 8、找出那些至少比其他两位学生年龄大的学生
SELECT s1.*
FROM student s1
WHERE 2 <= (
	SELECT COUNT(*)
	FROM student s2
	WHERE s2.age < s1.age
);

-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT sno, sname, age, DENSE_RANK() OVER (ORDER BY age) AS dr
	FROM student
) X
WHERE dr >= 3;

-------------------------------------------------------Exactly 问题-----------------------------------------------------

-- 9、找出只讲授一门课程的教授
SELECT p.lname, p.dept, p.salary, p.age
FROM professor p, teach t
WHERE p.lname = t.lname
GROUP BY p.lname, p.dept, p.salary, p.age
HAVING COUNT(*) = 1;  -- 只连接了一个

-- Oracle 解决方案
SELECT lname, dept, salary, age
FROM (
	SELECT p.lname, p.dept, p.salary, p.age
		, COUNT(*) OVER (PARTITION BY p.lname) AS cnt
	FROM professor p, teach t
	WHERE p.lname = t.lname
) X
WHERE cnt = 1;

-- 10、只选修 CS112 和 CS114 课程的学生
-- 分完组之后进行计算
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
GROUP BY s.sno, s.sname, s.age
HAVING COUNT(*) = 2
AND MAX(CASE 
	WHEN cno = 'CS112' THEN 1
	ELSE 0
END) + MAX(CASE 
	WHEN cno = 'CS114' THEN 1
	ELSE 0
END) = 2;

-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, COUNT(*) OVER (PARTITION BY s.sno) AS cnt
		, SUM(CASE 
			WHEN t.cno IN ('CS112', 'CS114') THEN 1
			ELSE 0
		END) OVER (PARTITION BY s.sno) AS BOTH, 
		
                -- 其实 RN 值等于 1 或 2 都没有关系，该列的作用在于去掉重复项，因此我们无须使用 DISTINCT
		ROW_NUMBER() OVER (PARTITION BY s.sno ORDER BY s.sno) AS rn 
	FROM student s, take t
	WHERE s.sno = t.sno
) X
WHERE cnt = 2
	AND BOTH = 2
	AND rn = 1;

-- 11、找出比其他两位学生年龄大的学生
SELECT s1.*
FROM student s1
WHERE 2 = (
	SELECT COUNT(*)
	FROM student s2
	WHERE s2.age < s1.age
);

-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT sno, sname, age, DENSE_RANK() OVER (ORDER BY age) AS dr
	FROM student
) X
WHERE dr = 3;

-------------------------------------------------------Any和All问题-----------------------------------------------------
-- 12、找出选修了全部课程的学生
-- 在 TAKE 表中一个学生选修的课程总数必须等于 COURSES 表中所有课程的总数。 COURSES 表里有 3 门课程。只有 AARON 选修了全部 3 门课程
SELECT s.sno, s.sname, s.age
FROM student s, take t
WHERE s.sno = t.sno
GROUP BY s.sno, s.sname, s.age
HAVING COUNT(t.cno) = (
	SELECT COUNT(*)
	FROM courses
);

-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT s.sno, s.sname, s.age, COUNT(t.cno) OVER (PARTITION BY s.sno) AS cnt
		, COUNT(DISTINCT c.title) OVER () AS total, 
		-- 起到去重的作用，不需要使用DISTINCT，因为是明细和聚合在一起，会有重复，任意取一个就行
		ROW_NUMBER() OVER (PARTITION BY s.sno ORDER BY c.cno) AS rn
	FROM courses c, take t, student s
	WHERE c.cno = t.cno(+)
		AND t.sno = s.sno(+)
)
WHERE cnt = total
	AND rn = 1;

-- 13、找出比任何其他学生年龄都大的学生（找出年龄最大的学生）
SELECT *
FROM student
WHERE age = (
	SELECT MAX(age)
	FROM student
);

-- Oracle 解决方案
SELECT sno, sname, age
FROM (
	SELECT s.*, MAX(s.age) OVER () AS oldest
	FROM student s
) X
WHERE age = oldest;





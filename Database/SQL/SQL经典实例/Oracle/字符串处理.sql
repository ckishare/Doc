-- 1、遍历字符串
select substr(e.ename, iter.pos) a, substr(e.ename, length(e.ename) - iter.pos + 1) b
from (select ename from emp where ename = 'KING') e,
     (select id pos from t10) iter
where iter.pos <= length(e.ename);


-- 2、嵌入引号
select 'g''day mate' qmarks
from t1
union all
select 'beavers'' teeth'
from t1
union all
select ''''
from t1;

---------------------------------------------------------------------------------------
select 'apples core', 'apple''s core', case when '' is null then 0 else 1 end from t1;

select '''' as quote from t1;

-- 3、删除不想要的字符
-- translate 的用法
select ename, replace(translate(ename, 'AEIOU', 'aaaaa'), 'a') as stripped1, sal, replace(sal, 0, '') as stripped2
from emp;

-- 4、分离数字和字符数据
select data, replace(translate(data, '0123456789', '0000000000'), '0') ename
from (select ename || sal data from emp);
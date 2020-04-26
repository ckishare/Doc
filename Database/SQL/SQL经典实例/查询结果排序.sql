-- 空值排序  nulls first
select ename, sal, comm from emp order by comm desc nulls first;
select ename, sal, comm from emp order by comm desc nulls last;

-- case 表达式
select ename,
       sal,
       job,
       comm,
       case
         when job = 'SALESMAN' then
          to_number(comm)
         else
          to_number(sal)
       end as ordered
  from emp
 order by 5
 
-- 对含有字母和数字的列排序
create view V1
as
select ename||' '||deptno as data
from emp;

-- 按照DEPTNO排序
select data
  from V1
 order by replace(data,
                  replace(translate(data, '0123456789', '##########'),
                          '#',
                          ''),
                  '');
-- 按照ENAME排序
select data
  from V1
 order by replace(translate(data, '0123456789', '##########'), '#', '');

select * from V;






 


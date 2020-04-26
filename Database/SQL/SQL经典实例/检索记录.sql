-- 把 Null 值转换为实际值  coalesce
select coalesce(comm, '0') from emp;

-- 用 case 来转换
select case
         when comm is not null then
          comm
         else
          '0'
       end
  from emp

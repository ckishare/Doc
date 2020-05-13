-- 1、展现父子关系
select concat(a.ename, ' works for ', b.ename) as emps_and_mgrs
from emp a,
     emp b
where a.mgr = b.empno;













-- 1����������������ͬ����
-- intersect ���÷����൱�ڽ�����
select empno, ename, job, sal, deptno
from emp
where (ename, job, sal) in (select ename, job, sal from emp
                            intersect
                            select ename, job, sal from V);

-- 2����ѯֻ����һ�����е�����
-- minus �����
select deptno
from dept
minus
select deptno
from emp;

select deptno
from dept
where deptno not in (select deptno from emp);

-- ʹ�� NOT IN ��ʱ��Ӧ��ע�� null ֵ
select *
from dept
where deptno not in (select deptno from new_dept);

--���� IN �� NOT IN �������� OR ���㣬�� NULL ����OR�߼�����ķ�ʽ��ͬ�����ǻ������ͬ�Ľ��
select deptno
from dept
where deptno in (10, 50, null);

select deptno
from dept
where (deptno = 10 or deptno = 50 or deptno = null);

-----------  ʹ�� NOT IN �� NOT OR ������ ----------------------
select deptno
from dept
where deptno not in (10, 50, null);

select deptno
from dept
where not (deptno = 10 or deptno = 50 or deptno = null);

-- �� deptno = 10 >> true false null >> false
-- �� deptno = 50 >> false false null >> null
-- not (deptno=10 or deptno=50 or deptno=null)
--      (false or false or null)
--      (false or null)
--      null

----------------------------------------------------------------


-------------------������� not exists --------------------------

select d.deptno
from dept d
where not exists(select null from emp e where d.deptno = e.deptno);

-- ����Ӳ�ѯ�н�����ظ�����ѯ����ôexists�ķ��ؽ���� true, ��ô not exists ��᷵�� false

----------------------------------------------------------------


-- 3����һ�����м�������һ������ص���
-- �������ӣ����ȫ���������
select d.*
from dept d
       left outer join emp e on (d.deptno = e.deptno)
where e.deptno is null;

select d.*
from dept d,
     emp e
where d.deptno = e.deptno (+)  and e.deptno is null;


-- 4��ȷ���������Ƿ�����ͬ������
-- �ҳ�������ͬ������
create view V2
  as
    select *
    from emp
    where deptno != 10
    union all
    select *
    from emp
    where ename = 'WARD';

-- ��һ�������ȥ���ڶ���������д��ڵ�����
-- ʹ�ü������� MINUS �� UNION ALL �ҳ���ͼ V �� EMP ��Ĳ�֮ͬ��
select empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm,
       deptno,
       count(*) as cnt
from V2
group by empno, ename, job, mgr, hiredate, sal, comm, deptno
minus
select empno,
       ename,
       job,
       mgr,
       hiredate,
       sal,
       comm,
       deptno,
       count(*) as cnt
from emp
group by empno, ename, job, mgr, hiredate, sal, comm, deptno;


-- 5�����ʹ�����Ӳ�ѯ��ۺϺ���
-- �����Ӳ�ѯ����оۺ�����ʱ������ʮ��С�Ĳ��С�������Ӳ�ѯ�������ظ���
-- ����һ�����þۺϺ���ʱֱ��ʹ�ùؼ��� DISTINCT������ÿ��ֵ������ȥ���ظ����ٲ������
-- ���������ڽ������Ӳ�ѯ֮ǰ��ִ�оۺ�����

select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal * case
                 when eb.type = 1 then .1
                 when eb.type = 2 then .2
                 else .3 end as bonus
from emp e,
     emp_bonus eb
where e.empno = eb.empno
  and e.deptno = 10;

-- �����ܶ��Ǵ���ģ�Ա�������ظ��ۼ�
select deptno, sum(sal) as total_sal, sum(bonus) as total_bonus
from (select e.empno,
             e.ename,
             e.sal,
             e.deptno,
             e.sal * case
                       when eb.type = 1 then .1
                       when eb.type = 2 then .2
                       else .3 end as bonus
      from emp e,
           emp_bonus eb
      where e.empno = eb.empno
        and e.deptno = 10)x
group by deptno;

-- �������  ���ں��� SUM OVER ��ʹ��
-- sum(distinct e.sal) over (partition by e.deptno) ���� e.deptno ���з���
select distinct deptno, total_sal, total_bonus
from (select e.empno,
             e.ename,
             sum(distinct e.sal) over
               (partition by e.deptno)                             as total_sal,
             e.deptno,
             sum(e.sal * case
                           when eb.type = 1 then .1
                           when eb.type = 2 then .2
                           else .3 end) over (partition by deptno) as total_bonus
      from emp e,
           emp_bonus eb
      where e.empno = eb.empno
        and e.deptno = 10)x;


-- 6��������ͱȽ���ʹ�� null 
-- coalesce ��ʹ��
select ename, comm, coalesce(to_number(comm), 0)
  from emp
 where coalesce(to_number(comm), 0) < (select comm from emp where ename = 'WARD');

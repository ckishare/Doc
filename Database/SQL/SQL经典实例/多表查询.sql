-- ��������������ͬ����
-- intersect ���÷����൱�ڽ�����
select empno, ename, job, sal, deptno
  from emp
 where (ename, job, sal) in (select ename, job, sal
                               from emp
                             intersect
                             select ename, job, sal
                               from V)

-- ��ѯֻ����һ�����е�����
-- minus �����
select deptno from dept minus select deptno from emp;


                 

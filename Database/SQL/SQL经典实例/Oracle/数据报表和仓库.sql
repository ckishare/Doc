-- 1���任�������һ��
-- ����һ
select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
       sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
       sum(case when deptno = 30 then 1 else 0 end) as deptno_30
from emp;

-- ������
-- �����������������
select max(case when deptno = 10 then empcount else null end) as deptno_10,
       max(case when deptno = 20 then empcount else null end) as deptno_20,
       max(case when deptno = 30 then empcount else null end) as deptno_30
from (select deptno, count(*) as empcount from emp group by deptno) x;

-- 2���任�����Ϊ����
/*
   ������б任���У�������ָ���е�ֵ������ÿһ��ԭ��������Ҫ�����ֵ������ݵ���һ
   �С�Ȼ������ǰһ��ʵ����ͬ���ǣ�����Ҫ����Ľ����ֹһ�С�
   
    JOB ENAME
    --------- ----------
    ANALYST SCOTT
    ANALYST FORD
    CLERK SMITH
    332 �� �� 12 ��
    CLERK ADAMS
    CLERK MILLER
    CLERK JAMES
    
    ���������ݸ�ʽ��Ϊ��
    CLERKS ANALYSTS MGRS PREZ SALES
    ------ -------- ----- ---- ------
    MILLER FORD CLARK KING TURNER
    JAMES SCOTT BLAKE MARTIN
    ADAMS JONES WARD
    SMITH ALLEN
*/

/*
    ����һ�ָ�����ְλ��Ϊ���е�ÿһ�� ENAME ����һ��Ψһ�ġ��б�š� ��������ʹ������
    ����Ա��������ͬ���ֺ�ְλ�����Ҳ���������⡣��������Ϊ�˼��ܻ����б�ţ� RN ��
    ���飬�ֲ�����Ϊʹ���� MAX ����©���κ�һ��Ա��
*/
select max(case when job='CLERK' then ename else null end) as clerks,
 max(case when job='ANALYST' then ename else null end) as analysts,
 max(case when job='MANAGER' then ename else null end) as mgrs,
 max(case when job='PRESIDENT' then ename else null end) as prez,
 max(case when job='SALESMAN' then ename else null end) as sales
 from(select job,ename,row_number()over(partition by job order by ename) rn
    from emp
 )x
 group by rn
 having rn = 1 or rn = 2;
 
-- 3������任�����
/*
   �������ݱ�Ϊ������
   DEPTNO_10 DEPTNO_20 DEPTNO_30
   ---------- ------- -----------
    3          5          6
    
    DEPTNO COUNTS_BY_DEPT
    ------ --------------
      10 3
      20 5
      30 6
�������ݱ任�������ݣ���Ҫ�õ��ѿ���������һ�����ݱ�Ϊ���У�


��������Ҫ֪���ж�������Ҫ��ת��Ϊ����ʽ
*/
select dept.deptno,
 case dept.deptno  -- �Խ�������б任
 when 10 then emp_cnts.deptno_10
 when 20 then emp_cnts.deptno_20
 when 30 then emp_cnts.deptno_30
 end as counts_by_dept
 from (
 select sum(case when deptno=10 then 1 else 0 end) as deptno_10, -- ����10��Ա������
 sum(case when deptno=20 then 1 else 0 end) as deptno_20,
 sum(case when deptno=30 then 1 else 0 end) as deptno_30
 from emp
 ) emp_cnts,
 (select deptno from dept) dept; -- ���� DEPT ������һ���ѿ�����

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
select max(case when job = 'CLERK' then ename else null end)     as clerks,
       max(case when job = 'ANALYST' then ename else null end)   as analysts,
       max(case when job = 'MANAGER' then ename else null end)   as mgrs,
       max(case when job = 'PRESIDENT' then ename else null end) as prez,
       max(case when job = 'SALESMAN' then ename else null end)  as sales
from (select job, ename, row_number()over (partition by job order by ename) rn from emp)x
group by rn
having rn = 1
    or rn = 2;
 
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
select dept.deptno, case dept.deptno  -- �Խ�������б任
                     when 10 then emp_cnts.deptno_10
                     when 20 then emp_cnts.deptno_20
                     when 30 then emp_cnts.deptno_30
    end as counts_by_dept
from (select sum(case when deptno = 10 then 1 else 0 end) as deptno_10, -- ����10��Ա������
             sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
             sum(case when deptno = 30 then 1 else 0 end) as deptno_30
      from emp) emp_cnts,
     (select deptno from dept) dept; -- ���� DEPT ������һ���ѿ�����

-- 4������任�������һ��
-- �����ѿ����� > �ڲ��Ӳ�ѯ�߼����� > �ⲿselect�����װ
select case rn
        when 1 then ename
        when 2 then job
        when 3 then cast(sal as char(4))
           end emps
from (select e.ename, e.job, e.sal, row_number() over (partition by e.empno
 order by e.empno) rn
      from emp e,
           (select * from emp where job = 'CLERK') four_rows  -- ����ѿ�����
      where e.deptno = 10)x;

-- 5��ɾ���ظ�����
-- �� EMP ������ȡ�� DEPTNO �� ENAME��ϣ������ DEPTNO �����е��н��з��飬���� ϣ��ÿ�� DEPTNO ֻ��ʾһ��
/*
  decode���ֶ�|���ʽ������1�����1������2�����2��...������n�����n��ȱʡֵ����
  ��ʾ��� �ֶ�|���ʽ ���� ����1 ʱ��DECODE�����Ľ������ ����1 ,...,����������κ�һ������ֵ���򷵻�ȱʡֵ��
 ��ע�⡿��decode ���� ��ֻ����select ����á�

  lag: ����ǰһ��
 */
select to_number(
        decode(lag(deptno)over (order by deptno),
               deptno, null, deptno)
           ) deptno, ename
from emp;

-- 6���任�������ʵ�ֿ��м���
select d20_sal - d10_sal as d20_10_diff, d20_sal - d30_sal as d20_30_diff
from (select sum(case when deptno = 10 then sal end) as d10_sal,
             sum(case when deptno = 20 then sal end) as d20_sal,
             sum(case when deptno = 30 then sal end) as d30_sal
      from emp) totals_by_dept;

-- 7�������̶���С������Ͱ
-- ��������ݷ������ɸ���С�̶���Ͱ(bucket)�ÿ��Ͱ��Ԫ�ظ��������ȶ��õ�
-- Ͱ �ĸ��������ǲ�ȷ���ģ�����ϣ��ȷ��ÿ��Ͱ�� 5 ��Ԫ��

/*
  ceil(n) ȡ���ڵ�����ֵn����С������
  floor(n)ȡС�ڵ�����ֵn���������

  select ceil(9.5) from dual;
  CEIL(9.5)
  ----------
     10
 */
select ceil(row_number()over (order by empno) / 5.0) grp, empno, ename  -- ÿ��Ͱ5������
from emp;

-- 8������Ԥ����Ŀ��Ͱ
/*
  select ename,sal,ntile(3) over(order by sal desc nulls last) tile from emp
  �Ѽ�¼�ֳ�3��,�����14����ֳ�554���ݣ�
  ���������where �����ﲻ��ֱ��ɸѡĳһ�ݵļ�¼
 */
select ntile(4) over (order by empno) grp, empno, ename
from emp;

-- 9������ˮƽֱ��ͼ
/*
  lpad���������ַ�����������ָ���ַ���
  lpad(String ,��ȡ���ȣ���ӵ��ַ���)
 */
select deptno, lpad('*', count(*), '*') as cnt
from emp
group by deptno;


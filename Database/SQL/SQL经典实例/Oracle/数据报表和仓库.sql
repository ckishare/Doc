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

-- 10��������ֱֱ��ͼ
SELECT MAX(deptno_10) AS d10, MAX(deptno_20) AS d20
  , MAX(deptno_30) AS d30
FROM (
  SELECT row_number() OVER (PARTITION BY deptno ORDER BY empno) AS rn
    , CASE 
      WHEN deptno = 10 THEN '*'
      ELSE NULL
    END AS deptno_10
    , CASE 
      WHEN deptno = 20 THEN '*'
      ELSE NULL
    END AS deptno_20
    , CASE 
      WHEN deptno = 30 THEN '*'
      ELSE NULL
    END AS deptno_30
  FROM emp
) x
GROUP BY rn
ORDER BY 1 DESC, 2 DESC, 3 DESC;

-- 11�����طǷ�����
/*
   ʹ�ó�����������ִ�� GROUP BY ��ѯ����ϣ��ͨ�� SELECT �б���һЩ�У�����Щ��ȴ��������� GROUP BY �Ӿ���
   
   ������ϣ���ҳ�ÿ�����Ź�����ߺ���͵�Ա����ͬʱҲϣ���ҳ�ÿ��ְλ��Ӧ�Ĺ�����ߺ���͵�Ա��
   ����鿴ÿ��Ա�������֡����š�ְλ�Լ�����
*/

-- �������ÿ�� ENAME ���� MAX(SAL) ���� > �ҳ��� EMP ����ÿ�� ENAME ��Ӧ����߹���
-- ������Ҫ�ܹ���ѯ�� ENAME ȴ���ذ� ENAME���� GROUP BY �Ӿ�ķ���
SELECT ename, MAX(sal)
FROM emp
GROUP BY ename;

SELECT deptno, ename, job, sal
  , CASE 
    WHEN sal = max_by_dept THEN 'TOP SAL IN DEPT'
    WHEN sal = min_by_dept THEN 'LOW SAL IN DEPT'
  END AS dept_status
  , CASE 
    WHEN sal = max_by_job THEN 'TOP SAL IN JOB'
    WHEN sal = min_by_job THEN 'LOW SAL IN JOB'
  END AS job_status
FROM (
  SELECT deptno, ename, job, sal  , -- ʹ�ô��ں��� MAX OVER �� MIN OVER �ҳ�ÿ�� DEPTNO �� JOB ��Ӧ����ߺ���͵Ĺ���
     MAX(sal) OVER (PARTITION BY deptno ) AS max_by_dept, MAX(sal) OVER (PARTITION BY job ) AS max_by_job
    , MIN(sal) OVER (PARTITION BY deptno ) AS min_by_dept, MIN(sal) OVER (PARTITION BY job ) AS min_by_job
  FROM emp
) emp_sals
WHERE sal IN (max_by_dept, max_by_job, min_by_dept, min_by_job);

-- 12������򵥵�С��
/*
   ָ����һ������Ľ�������ý������������ĳһ�еľۺ���������Ҳ�������������и��еĺϼ�ֵ
   TOTAL 29025
   
   ֻʹ��group by�Ӿ�;ۺϺ������޷�ͬʱ�ó�С�ƺͺϼƵģ���Ҫͬʱ�õ�������ʹ��grouping�����
   
   GROUPING�������Խ���һ�У�����0����1�������ֵΪ�գ���ôGROUPING()����1�������ֵ�ǿգ���ô����0��
   GROUPINGֻ����ʹ��ROLLUP��CUBE�Ĳ�ѯ��ʹ�á�
   ����Ҫ�ڷ��ؿ�ֵ�ĵط���ʾĳ��ֵʱ��GROUPING()�ͷǳ�����
*/
SELECT CASE grouping(job)
		WHEN 0 THEN job
		ELSE 'TOTAL'
	END AS job, SUM(sal) AS sal
FROM emp
GROUP BY ROLLUP (job);

-- 13���������п��ܵı��ʽ��ϵ�С��
/*
   ���밴�� DEPTNO �� JOB �Լ� JOB/DEPTNO ��Ϸֱ��������ʺϼ�ֵ��ͬʱ����Ҳϣ���õ� EMP ��Ĺ����ܼ�
   
   ʹ��group by cube(a,b)�������Ȼ��(a,b)����group by��Ȼ��������(a)��(b)��
   ����ȫ�����group by ������һ����2^2=4��grouping
*/
select deptno,
 job,
 case grouping(deptno)||grouping(job)
 when '00' then 'TOTAL BY DEPT AND JOB'
 when '10' then 'TOTAL BY JOB'
 when '01' then 'TOTAL BY DEPT'
 when '11' then 'GRAND TOTAL FOR TABLE'
 end category,
 sum(sal) sal
 from emp
 group by cube(deptno,job)
 order by grouping(job),grouping(deptno);

-- 14��ʶ���С����
/*
  ���ֽ����Ϊ��������� 00 01 10 11
 */
-- ���Ѿ�֪�����ʹ�� GROUP BY �Ӿ�� CUBE ��չ�﷨���ɱ���
-- ��������Ҫ֪��������� ��Щ��������ͨ�� GROUP BY �Ӿ�����ģ���Щ������ CUBE �� ROLLUP ������
select deptno, job, sum(sal) sal,
       grouping(deptno) deptno_subtotals, grouping(job) job_subtotals -- ʹ�� GROUPING �����ж���Щֵ�� CUBE �� ROLLUP ��С�ƽ��
from emp
group by cube (deptno, job);


-- 15��ʹ��case���ʽ���������
-- ��ĳ�е�ֵӳ���һϵ�еġ���������־λ
select ename,
       case
         when job = 'CLERK'
                 then 1
         else 0
           end      as is_clerk,
       case
         when job = 'SALESMAN'
                 then 1
         else 0 end as is_sales,
       case
         when job = 'MANAGER'
                 then 1
         else 0
           end      as is_mgr,
       case
         when job = 'ANALYST'
                 then 1
         else 0
           end      as is_analyst,
       case
         when job = 'PRESIDENT'
                 then 1
         else 0
           end      as is_prez
from EMP
order by 2, 3, 4, 5, 6;


-- 16������ʱ�䵥λ����
-- ��ID����
select ceil(trx_id / 5.0) as grp, min(trx_date) as trx_start, max(trx_date) as trx_end, sum(trx_cnt) as total
from trx_log
group by ceil(trx_id / 5.0);

-- ��ʱ����飨5��һ�飩
select hr, grp, sum(trx_cnt) total
from (select trx_date,
             trx_cnt,
             to_number(to_char(trx_date, 'hh24'))                                hr,
             ceil(to_number(to_char(trx_date - 1 / 24 / 60 / 60, 'miss')) / 5.0) grp
      from trx_log)x
group by hr, grp;

-- 17����γ�Ⱦۺ�����
/*
  ����ͬʱ���в�ͬά�ȵľۺ�����
  ��ϣ���õ�һ������������а���ÿ��Ա���� ���֡����š������ڲ��ŵ�Ա������(�������Լ�)����������ͬ������Ա������(�ú� ��ֵ��Ҳ�������Լ�)
  �Լ� EMP ���е�Ա��������
 */
select ename,
       deptno,
       count(*)over (partition by deptno) deptno_cnt,
       job,
       count(*)over (partition by job)    job_cnt,
       count(*)over ()                    total
from emp;

-- 18����̬����ۺ�����
/*
  ���� EMP ���ʵĶ�̬�ϼơ���ϣ������ְ�����Ա���� HIREDATE ��Ϊ��ʼ�㣬ÿ�� 90 �����һ�ι��ʺϼ�ֵ
  �������һ����������ְ��Ա�� �������ְ��Ա��֮��ÿ�� 90 �칤�ʵĲ���״��

  �ڴ��ڻ�֡���Ӿ� ��ָ��ʱ�䷶ΧΪ 90 �죬�����������ÿ��Ա���Լ���ְʱ������� 90 �����ڵ������� �Ĺ���ִ�кϼƼ���

  Ҫ�˽��ѯ����д����Ӿ�Ĺ���ԭ��
  ���ȣ����Ƕ���õĴ� �ڻᰴ�� HIREDATE ������Ա���Ĺ��ʽ�������,Ȼ�󣬵��þۺϺ������㹤���ܶ�,����Ĵ������������ʾ
  (1) ����������ְ��Ա���Ĺ��ʡ���һ��Ա����ְ֮ǰ�������������Ѿ���ְ�������ʱ�� �����ܶ���ǵ�һ��Ա���Ĺ���
  (2)(���� HIREDATE ���Ⱥ�˳��)������һλԱ���Ĺ��ʡ���Ա���Ĺ��ʻᱻ���붯̬���� �ϼ�ֵ��������ְʱ������硢����� 90 �����ڵ�Ա���Ĺ���Ҳ�ᱻ����ϼ�ֵ��
 */
select hiredate, sal, sum(sal) over (order by hiredate
range between 90 preceding
and current row) spending_pattern
from emp e;


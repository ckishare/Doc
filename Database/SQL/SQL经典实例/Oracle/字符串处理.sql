-- 1�������ַ���
select substr(e.ename, iter.pos) a, substr(e.ename, length(e.ename) - iter.pos + 1) b
from (select ename from emp where ename = 'KING') e,
     (select id pos from t10) iter
where iter.pos <= length(e.ename);

-- 2��Ƕ������
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

-- 3��ɾ������Ҫ���ַ�
-- translate ���÷�
select ename, replace(translate(ename, 'AEIOU', 'aaaaa'), 'a') as stripped1, sal, replace(sal, 0, '') as stripped2
from emp;

-- 4���������ֺ��ַ�����
select data, replace(translate(data, '0123456789', '0000000000'), '0') ename
from (select ename || sal data from emp);

-- 5���жϺ�����ĸ�����ֵ��ַ���
-- �Ȱ����е���ĸ�ַ��������ַ�ת����һ����һ���ַ�
-- Ȼ����ܰ����ǵ���һ���ַ�
create view V3 as
select ename as data
from emp
where deptno=10
union all
select ename||', $'|| sal ||'.00' as data
from emp
where deptno=20
union all
select ename|| deptno as data
from emp
where deptno=30;

select data
  from V3
 where translate(lower(data),
                 '0123456789abcdefghijklmnopqrstuvwxyz',
                 rpad('a', 36, 'a')) = rpad('a', length(data), 'a');

-- 6����ȡ����������ĸ
-- TRANSLATE ������ѷǴ�д��ĸ���滻Ϊ�ַ� #
-- ��������ĸ�⣬�������������ֶ������ # Ȼ��ʹ�� REPLACE ����ɾ�������е� #
-- �ٴ�ʹ�� REPLACE �����ѿո��滻ΪӢ�ľ��
select replace(replace(translate(replace('Stewie Griffin', '.', ''),
                                 'abcdefghijklmnopqrstuvwxyz',
                                 rpad('#', 26, '#')),
                       '#',
                       ''),
               ' ',
               '.') || '.' as name
  from t1;
select replace('Stewie Griffin', '.', '') from dual;

-- 7���������ַ�������
select ename from emp order by substr(ename, length(ename) - 1, 2);

-- 8�������ַ����е���������
-- ���ֱ�Ϊ # > # ��Ϊ�� > �����ֱ�Ϊ # > # ��Ϊ�� > ʣ�µ������� > to_number ת��Ϊ����
-- ˼·���������ֺͷ����ֵ������������ж�
select data
  from V3
 order by to_number(replace(translate(data,
                                      replace(translate(data,
                                                        '0123456789',
                                                        '##########'),
                                              '#'),
                                      rpad('#', 20, '#')),
                            '#'));

-- 9�������ָ��б�
/*
  connect by ����������Ŀ�ľ��Ǹ�������֮��Ĺ�ϵ��ʲô�����������ϵ���еݹ��ѯ
  start with: ���ڵ���޶���������ȻҲ���Էſ�Ȩ�ޣ��Ի�ö�����ڵ㣬Ҳ���ǻ�ȡ�����
  prior: ������д��
         connect by prior dept_id=par_dept_id  �������϶��µ�������ʽ�����Ҹ��ڵ�Ȼ�����ӽڵ㣩
         connect by dept_id=prior par_dept_id  ����Ҷ�ӽڵ�Ȼ���Ҹ��ڵ�
  level: levelα��,��ʾ�㼶��ֵԽС�㼶Խ�ߣ�level=1Ϊ�㼶��߽ڵ�
*/
---------------------------------------------------------------------------
/*
  ���������������������ڼ���������ĳ�־ۺ�ֵ�����;ۺϺ����Ĳ�֮ͬ���ǣ�
  ����ÿ���鷵�ض��У����ۺϺ�������ÿ����ֻ����һ��
  OVER(PARTITION BY)��������
  over��order by salary�� ����salary��������ۼƣ�order by�Ǹ�Ĭ�ϵĿ�������
  over��partition by deptno�����ղ��ŷ���
*/
select deptno, ltrim(sys_connect_by_path(ename, ','), ',') emps
  from (select deptno,
               ename,
               row_number() over(partition by deptno order by empno) rn,
               count(*) over(partition by deptno) cnt
          from emp)
 where level = cnt
 start with rn = 1
connect by prior deptno = deptno
       and prior rn = rn - 1;
       
-- 10���ָ�����ת��Ϊ��ֵ IN �б�
-- instr �ַ����Һ���
/*
   select instr('helloworld','l') from dual; ���ؽ����3��Ĭ�ϵ�һ�γ��֡�l����λ�ã�
   select instr('helloworld','l',2,2) from dual; ���ؽ����4 ����"helloworld"�ĵ�2(e)��λ�ÿ�ʼ�����ҵڶ��γ��ֵġ�l����λ�ã�
*/

-- substr �ַ���ȡ����
/*
    ��ʽ1��
        1��string ��Ҫ��ȡ���ַ���
        2��a ��ȡ�ַ����Ŀ�ʼλ�ã�ע����a����0��1ʱ�����Ǵӵ�һλ��ʼ��ȡ��
        3��b Ҫ��ȡ���ַ����ĳ���

    ��ʽ2��
        1��string ��Ҫ��ȡ���ַ���
        2��a �������Ϊ�ӵ�a���ַ���ʼ��ȡ�������е��ַ�����
*/ 

/*
   ltrim(x,y) �����ǰ���y�е��ַ�һ��һ���ص�x�е��ַ��������Ǵ���߿�ʼִ�еģ�
   ֻҪ����y���е��ַ�, x�е��ַ����ᱻ�ص�, ֱ����x���ַ�������y��û�е��ַ�Ϊֹ��������Ž���
*/       
select empno, ename, sal, deptno
  from emp
 where empno in
       (select to_number(rtrim(substr(emps,
                                      instr(emps, ',', 1, iter.pos) + 1,
                                      instr(emps, ',', 1, iter.pos + 1) -
                                      instr(emps, ',', 1, iter.pos)),
                               ',')) emps
          from (select ',' || '7654,7698,7782,7788' || ',' emps from t1) csv,
               (select rownum pos from emp) iter
         where iter.pos <=
               ((length(csv.emps) - length(replace(csv.emps, ','))) /
               length(',')) - 1);

-- �ҳ����˼������ŷָ�
select emps, pos
  from (select ',' || '7654,7698,7782,7788' || ',' emps from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
       ((length(csv.emps) - length(replace(csv.emps, ','))) / length(',')) - 1;

-- ���ַ����������       
select substr(emps,
              instr(emps, ',', 1, iter.pos) + 1,
              instr(emps, ',', 1, iter.pos + 1) -
              instr(emps, ',', 1, iter.pos)) emps
  from (select ',' || '7654,7698,7782,7788' || ',' emps from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
       ((length(csv.emps) - length(replace(csv.emps, ','))) / length(',')) - 1;

-- ȥ��ÿ�еĶ���֮��ת��Ϊ��ֵ

-- 11������ĸ��˳�������ַ�
/*
   sys_connect_by_path�����󸸽ڵ㵽�ӽڵ�·��
  ���԰�һ�����ڵ��µ����нڵ�ͨ��ĳ���ַ����֣�Ȼ��������һ��������ʾ
*/
select old_name, new_name
  from (select old_name, replace(sys_connect_by_path(c, ' '), ' ') new_name
          from (select e.ename old_name,
                       row_number() over(partition by e.ename order by substr(e.ename, iter.pos, 1)) rn,
                       substr(e.ename, iter.pos, 1) c
                  from emp e, (select rownum pos from emp) iter
                 where iter.pos <= length(e.ename)
                 order by 1) x
         start with rn = 1
        connect by prior rn = rn - 1
               and prior old_name = old_name)
 where length(old_name) = length(new_name); -- ���������������з��صļ�¼���й���
 
-- rn = 1 ��1��ʼ
-- ���� rn = rn - 1 > 1 = rn -1 > rn = 2 > �´��ҵľ���rn = 2 ��

-- ��������
-- ��ȡ��ÿ�����ֵ��ַ�����������ĸ��˳�����к�
select e.ename old_name,
       row_number() over(partition by e.ename order by substr(e.ename, iter.pos, 1)) rn,
       substr(e.ename, iter.pos, 1) c
  from emp e, (select rownum pos from emp) iter
 where iter.pos <= length(e.ename);

-- ��ȡ���ź�����ַ����ؽ�ÿ������
-- ʹ�� SYS_CONNECT_BY_PATH ��������ɣ��������е��ַ���˳�򴮽�����

-- 12��ʶ���ַ�����������ַ�
create view V4 as
  select replace(mixed, ' ', '') as mixed
  from (select substr(ename, 1, 2) ||
               deptno ||
               substr(ename, 3, 2) as mixed
        from emp
        where deptno = 10
        union all
        select cast(empno as char(4)) as mixed from emp where deptno = 20
        union all
        select ename as mixed from emp where deptno = 30)x;

select * from v4;


-- ���� > ������ > ����
select to_number(case
                   when replace(translate(mixed, '0123456789', '9999999999'), '9')
        is not null
                           then replace(
                                  translate(mixed,
                                            replace(
                                              translate(mixed, '0123456789', '9999999999'), '9'),
                                            rpad('#', length(mixed), '#')), '#')
                   else mixed
                     end
           ) mixed
from V4
where instr(translate(mixed, '0123456789', '9999999999'), '9') > 0;

-- ��ȡ��n���ָ����ַ���
create view V5 as
  select 'mo,larry,curly' as name
  from t1
  union all
  select 'tina,gina,jaunita,regina,leena' as name
  from t1;

select * from v5;

-- �����ٽ�ȡ
select sub
from (select iter.pos, src.name, substr(src.name,
                                        instr(src.name, ',', 1, iter.pos) + 1,
                                        instr(src.name, ',', 1, iter.pos + 1) - instr(src.name, ',', 1, iter.pos) - 1) sub
      from (select ',' || name || ',' as name from V5) src,
           (select rownum pos from emp) iter

      where iter.pos < length(src.name) - length(replace(src.name, ',')))
where pos = 2;


-- ����IP��ַ
select ip,
       substr(ip, 1, instr(ip, '.') - 1) a,
       substr(ip, instr(ip, '.') + 1,
              instr(ip, '.', 1, 2) - instr(ip, '.') - 1) b,
       substr(ip, instr(ip, '.', 1, 2) + 1,
              instr(ip, '.', 1, 3) - instr(ip, '.', 1, 2) - 1) c,
       substr(ip, instr(ip, '.', 1, 3) + 1) d
from (select '92.111.0.2' as ip from t1);
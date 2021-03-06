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

-- 5、判断含有字母和数字的字符串
-- 先把所有的字母字符和数字字符转换成一个单一的字符
-- 然后就能把它们当作一个字符
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

-- 6、提取姓名的首字母
-- TRANSLATE 函数会把非大写字母都替换为字符 #
-- 除了首字母外，姓名的其他部分都变成了 # 然后使用 REPLACE 函数删除掉所有的 #
-- 再次使用 REPLACE 函数把空格替换为英文句号
select replace(replace(translate(replace('Stewie Griffin', '.', ''),
                                 'abcdefghijklmnopqrstuvwxyz',
                                 rpad('#', 26, '#')),
                       '#',
                       ''),
               ' ',
               '.') || '.' as name
  from t1;
select replace('Stewie Griffin', '.', '') from dual;

-- 7、按照子字符串排序
select ename from emp order by substr(ename, length(ename) - 1, 2);

-- 8、根据字符串中的数据排序
-- 数字变为 # > # 变为空 > 非数字变为 # > # 变为空 > 剩下的是数字 > to_number 转换为数字
-- 思路：利用数字和非数字的理论来进行判断
select data
  from V3
 order by to_number(replace(translate(data,
                                      replace(translate(data,
                                                        '0123456789',
                                                        '##########'),
                                              '#'),
                                      rpad('#', 20, '#')),
                            '#'));

-- 9、创建分割列表
/*
  connect by 连接条件，目的就是给出父子之间的关系是什么，根据这个关系进行递归查询
  start with: 根节点的限定条件，当然也可以放宽权限，以获得多个根节点，也就是获取多个树
  prior: 有两种写法
         connect by prior dept_id=par_dept_id  采用自上而下的搜索方式（先找父节点然后找子节点）
         connect by dept_id=prior par_dept_id  先找叶子节点然后找父节点
  level: level伪列,表示层级，值越小层级越高，level=1为层级最高节点
*/
---------------------------------------------------------------------------
/*
  开窗函数，分析函数用于计算基于组的某种聚合值，它和聚合函数的不同之处是：
  对于每个组返回多行，而聚合函数对于每个组只返回一行
  OVER(PARTITION BY)函数介绍
  over（order by salary） 按照salary排序进行累计，order by是个默认的开窗函数
  over（partition by deptno）按照部门分区
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
       
-- 10、分隔数据转换为多值 IN 列表
-- instr 字符查找函数
/*
   select instr('helloworld','l') from dual; 返回结果：3（默认第一次出现“l”的位置）
   select instr('helloworld','l',2,2) from dual; 返回结果：4 （在"helloworld"的第2(e)号位置开始，查找第二次出现的“l“的位置）
*/

-- substr 字符截取函数
/*
    格式1：
        1、string 需要截取的字符串
        2、a 截取字符串的开始位置（注：当a等于0或1时，都是从第一位开始截取）
        3、b 要截取的字符串的长度

    格式2：
        1、string 需要截取的字符串
        2、a 可以理解为从第a个字符开始截取后面所有的字符串。
*/ 

/*
   ltrim(x,y) 函数是按照y中的字符一个一个截掉x中的字符，并且是从左边开始执行的，
   只要遇到y中有的字符, x中的字符都会被截掉, 直到在x的字符中遇到y中没有的字符为止函数命令才结束
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

-- 找出用了几个逗号分割
select emps, pos
  from (select ',' || '7654,7698,7782,7788' || ',' emps from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
       ((length(csv.emps) - length(replace(csv.emps, ','))) / length(',')) - 1;

-- 将字符串分离出来       
select substr(emps,
              instr(emps, ',', 1, iter.pos) + 1,
              instr(emps, ',', 1, iter.pos + 1) -
              instr(emps, ',', 1, iter.pos)) emps
  from (select ',' || '7654,7698,7782,7788' || ',' emps from t1) csv,
       (select rownum pos from emp) iter
 where iter.pos <=
       ((length(csv.emps) - length(replace(csv.emps, ','))) / length(',')) - 1;

-- 去掉每列的逗号之后转换为数值

-- 11、按字母表顺序排列字符
/*
   sys_connect_by_path函数求父节点到子节点路径
  可以把一个父节点下的所有节点通过某个字符区分，然后链接在一个列中显示
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
 where length(old_name) = length(new_name); -- 过滤条件，对所有返回的记录进行过滤
 
-- rn = 1 从1开始
-- 条件 rn = rn - 1 > 1 = rn -1 > rn = 2 > 下次找的就是rn = 2 的

-- 分析过程
-- 提取出每个名字的字符，并按照字母表顺序排列好
select e.ename old_name,
       row_number() over(partition by e.ename order by substr(e.ename, iter.pos, 1)) rn,
       substr(e.ename, iter.pos, 1) c
  from emp e, (select rownum pos from emp) iter
 where iter.pos <= length(e.ename);

-- 提取出排好序的字符并重建每个名字
-- 使用 SYS_CONNECT_BY_PATH 函数来完成，它把所有的字符按顺序串接起来

-- 12、识别字符串里的数字字符
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


-- 数字 > 非数字 > 数字
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

-- 提取第n个分割子字符串
create view V5 as
  select 'mo,larry,curly' as name
  from t1
  union all
  select 'tina,gina,jaunita,regina,leena' as name
  from t1;

select * from v5;

-- 先找再截取
select sub
from (select iter.pos, src.name, substr(src.name,
                                        instr(src.name, ',', 1, iter.pos) + 1,
                                        instr(src.name, ',', 1, iter.pos + 1) - instr(src.name, ',', 1, iter.pos) - 1) sub
      from (select ',' || name || ',' as name from V5) src,
           (select rownum pos from emp) iter

      where iter.pos < length(src.name) - length(replace(src.name, ',')))
where pos = 2;


-- 解析IP地址
select ip,
       substr(ip, 1, instr(ip, '.') - 1) a,
       substr(ip, instr(ip, '.') + 1,
              instr(ip, '.', 1, 2) - instr(ip, '.') - 1) b,
       substr(ip, instr(ip, '.', 1, 2) + 1,
              instr(ip, '.', 1, 3) - instr(ip, '.', 1, 2) - 1) c,
       substr(ip, instr(ip, '.', 1, 3) + 1) d
from (select '92.111.0.2' as ip from t1);
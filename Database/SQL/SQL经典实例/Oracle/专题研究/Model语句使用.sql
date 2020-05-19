/*
  sales_fact���¼��ÿ�ܿ��ֵĽ��������������Ϳ��
  ���ܿ�� = ���ܽ�����-�������۶�+���ܿ�棬���ǿ�������ͼ�еĹ�ʽ��������ÿ�ܵĿ��
*/

-- 1����������
create table sales_fact
(
  prod      varchar2(20),--��Ʒ
  year    number,      --��
  week    number,      --��
  sale    number,      --���۶�
  receipts   number       --������
);

insert into sales_fact values ('����',2020,1,100,200);
insert into sales_fact values ('����',2020,2,100,200);
insert into sales_fact values ('����',2020,3,150,300);
insert into sales_fact values ('����',2020,4,1000,5000);
insert into sales_fact values ('����',2020,5,2000,10000);
insert into sales_fact values ('����',2020,6,3000,0);
insert into sales_fact values ('����',2020,7,5000,0);
insert into sales_fact values ('����',2020,8,10000,10000);
insert into sales_fact values ('����',2020,9,100000,100000);
insert into sales_fact values ('����',2020,10,100000,100000);
insert into sales_fact values ('����',2020,11,100000,100000);
insert into sales_fact values ('����',2020,12,100000,100000);
insert into sales_fact values ('����',2020,13,100000,100000);
insert into sales_fact values ('����',2020,14,100000,100000);

select * from sales_fact;
/*
   cv��ʾ��ֵ������������ʾ�ӹ�������������Ĺ����Ҳ����ֵ��
   ���������year��week�е�ֵΪ(2001,3)�������Ҳ��cv(year)�Ӿ���ָ��ֵΪ�������yearֵ��ֵ��Ҳ����2001,
   ���Ƶأ�cv(week)�Ӿ�ָ���ǹ������week�е�ֵҲ����3��
   ��ˣ�inventory [ cv(year), cv(week) - 1 ]�Ӿ佫����2001����ǰ1��Ҳ���ǵڣ��ܵĿ�����ֵ��
   ����,sale [ cv(year), cv(week) ]�� receipts [ cv(year), cv(week) ]ָ����ʹ��c���������2001��ڣ��ܵ�sale�к�receipts�е�ֵ��
   �ڹ����в�δ����������product��country��������ʽ��Ϊproduct��country�����õ�ǰ�����е�ֵ
*/
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory --�����
from sales_fact
where 1 = 1
model return updated rows
partition by(prod) -- ��prod��ָ��Ϊ������(��һ�������У�ά����Ψһ��ʶÿһ��)
dimension by(year,week) -- ָ��year,weekΪά���У�ά����Ψһ��ʶÿһ�У���ƷΪ���֣�ÿ��ÿ��ֻ��һ�����ݣ�

measures(0 inventory,sale,receipts)  -- ��ʾ inventory, sale, receipts����Ϊ�������ֵ
rules automatic -- ����������һ����ʽ
-- ���㹫ʽ 0 inventory ��������Ҳ������ܵĿ�棬Ĭ��ֵΪ0
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)])
order by prod,year,week;

-- 2��λ�ñ��
/*
   ����2020���8�ܣ������������ͽ������������в�������û��¼��ϵͳ
   ��ʵ��ʵ�Ľ�����Ϊ300000��������ҲΪ200000
*/

/*
   λ�ñ���ܹ��ڽ�����в���һ���µ�Ԫ������һ�����е�Ԫ��
   ��������õĵ�Ԫ���ڽ�����д��ڣ������µ�Ԫ���ֵ����������ڣ��������һ���µĵ�Ԫ��
   ���ִ�������£������������ĸ����Ϊupsert���ԣ���update��insert���ܵ��ںϰ汾��λ�ñ���ṩ��upsert������
*/
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory --�����
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts) rules automatic
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)],
sale[2020,8] = 200000, receipts[2020,8] = 300000) -- ����δ����ϵ�
order by prod,year,week;

select * from sales_fact;

/*
   ����15�ܵ��������Ǽ�¼�ˣ���ԭ�еĻ����ϼ���15�ܵ�����
   2020���15�����۶� 100000��������100000
*/
--15�����ݲ�����
--��ֱ���ڹ�ʽ��ָ�����ɣ����Ͼ���������
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory --�����
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts) rules automatic
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)],sale[2020,8] = 200000, receipts[2020,8] = 300000,sale[2020,15] = 200000, receipts[2020,15] = 200000)
order by prod,year,week;

-- 3�����ű��
-- ��ʱ����14-16�ܵ����۶�ͽ���������¼�����ݵ�1.2��

-- ���ű�ǲ�ͬ��λ�ñ�ǣ���������ڲ�������
-- �����Լ�ָ����ÿ����ʽ��order by  û���� automatic order�������Ƽ�ʹ�� automatic order,Oracle���Ǻ����ܵ�
-- �ڹ��򲿷ֿ�������������򣬲��ҹ�����������໥֮���������ϵ��
-- ������ˣ���ʹ��һ�������Ĺ����У���������Ҳ����Ҫ����һ�����߼�˳�����

-- ע����return updated rows֮����ʾ����
select prod ,
       year ,
       week ,
       sale ,    -- ������
       receipts, -- ������
       inventory -- �����
from sales_fact
where 1 = 1
model -- return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts)  
rules (--inventory[year,week] order by year,week = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)] ,
      sale[year in (2020),week in (14,15,16)] order by year,week = sale[cv(year),cv(week)]*1.2,
      receipts[year in (2020),week in (14,15,16)] order by year,week = receipts[cv(year),cv(week)]*1.2
      )
order by prod,year,week;

--���ű�ǲ�ͬ��λ�ñ�ǣ���������ڲ�������
--�����Լ�ָ����ÿ����ʽ��order by  û���� automatic order�������Ƽ�ʹ�� automatic order,Oracle���Ǻ����ܵ�
--����return updated rows֮��ֻ��ʾ���ĵ�
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory --�����
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts)  
rules (--inventory[year,week] order by year,week = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)] ,
      sale[year in (2020),week in (14,15,16)] order by year,week = sale[cv(year),cv(week)]*1.2,
      receipts[year in (2020),week in (14,15,16)] order by year,week = receipts[cv(year),cv(week)]*1.2
      )
order by prod,year,week;

-- 4��forѭ��
-- ��������������2020���8�ܿ�ʼ��ÿ�ܽ����������۶��150000
/*
   for dimension for <value1> to <value2>
   [increment | decrement] <value3>
*/
--��ʱ�����ڵ�15��Ҳ������
--forѭ�����Լ��ٺܶ������
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory --�����
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts)  
rules automatic order(
      sale[2020,for week from 8 to 15 increment  1]  = 150000,
      receipts[2020,for week from 8 to 15 increment  1]  = 150000,
      inventory[year,week]  = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)] 
      )
order by prod,year,week;

-- 5���ۺ�
-- Model�Ӿ仹�������avg��sum��max�Ⱥ���һ��ʹ��
select prod ,
       year ,
       week ,
       sale ,    --������
       receipts, --������
       inventory, --�����
       avg_inventory , --ƽ�����
       max_sale      --����������۶�
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts,0 avg_inventory,0 max_sale) rules automatic
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)],
      avg_inventory[year,ANY] = round(avg(inventory)[cv(year),week],2),
      max_sale[year,ANY] = max(sale)[cv(year),week]   
      )
order by prod,year,week;

-- 6�������˳��
/*
   �ڹ��򲿷ֿ�������������򣬲��ҹ�����������໥֮���������ϵ��
   ������ˣ���ʹ��һ�������Ĺ����У���������Ҳ����Ҫ����һ�����߼�˳����С�
*/
select product,country,year,week,inventory,sale,receipts
from sales_fact sf
where sf.country in ('Australia') 
model return updated rows
partition by(product, country) 
dimension by(year, week)
measures(0 inventory,sale, receipts) 
rules  -- automatic order
(
 inventory[year,week]=nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)]
)
order by product, country, year, week;

/*
   ��automatic orderע�͵���ǿ��ʹ����sequential order��Ĭ����Ϊ��
   �ù���ͨ��inventory[cv(year),cv(week)-1]�Ӿ�����˿������á�����е�ֵ���밴���ܵ�������м��㡣
   ǰһ�ܵĿ���������ڵ�ǰ�ܵĿ�����֮ǰ��⡣
   ͨ��automatic order,���ݿ�����ȷ������������ϵ���ϸ���������ϵ��˳����н�����⡣
   ���û��automatic order�������˳��Ͳ���ȷ�����⽫�ᵼ��ORA-32637����
*/

-- �������
-- ��ʽ���������˳���Ա����������
select product,country,year,week,inventory,sale,receipts
from sales_fact sf
where sf.country in ('Australia') and product in ('Xtend Memory')
model return updated rows
partition by(product, country) 
dimension by(year, week)
measures(0 inventory,sale, receipts) 
rules  -- automatic order
(
 -- ͨ��order by year,week�Ӿ���ʽ�����������˳�򣬱�ʾ���밴��year��week��ֵ���������
 inventory[year,week] order by year,week =nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)]
) 
order by product, country, year, week;

-- 7���������˳��
-- ���������˳���⣬����Ҫ�����Ӧ�õĹ������˳������
--������ֵ˳��--˳����ֵ
select * from (
  select product,country,year,week,inventory,sale,receipts
  from sales_fact sf
  where sf.country in ('Australia') and product in ('Xtend memory')
  model return updated rows
  partition by (product, country) 
  dimension by (year, week)
  measures (0 inventory,sale, receipts) 
  rules sequential order  -- sequential orderָ���˹����������б��е��Ⱥ�˳��������
  (
   inventory[year,week] order by year,week =nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)],
   receipts[year in (2000,2001),week in (51,52,53)] order by year,week =receipts[cv(year),cv(week)]*10
  ) 
  order by product, country, year, week
) where week>50;

-- ������ֵ˳��--�Զ���ֵ
select * from (
  select product,country,year,week,inventory,sale,receipts
  from sales_fact sf
  where sf.country in ('Australia') and product in ('Xtend Memory')
  model return updated rows
  partition by (product, country) 
  dimension by (year, week)
  measures (0 inventory,sale, receipts) 
  rules sequential order 
  (
   inventory[year,week] order by year,week =nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)],
   receipts[year in (2000,2001),week in (51,52,53)] order by year,week =receipts[cv(year),cv(week)]*10
  ) 
  order by product, country, year, week
) where week>50;

/*
  ��������sql�Ľ���ǲ�ƥ��ġ�automatic order�������ݿ������Զ�ʶ�����֮���������ϵ��
  ��ˣ����ݿ��������ȶ�receipts������⣬Ȼ����inventory����
  ��������˳���Ƿǳ���Ҫ�ģ�������ںܸ��ӵ��໥�����ԣ���Ҫָ��automatic order�������ϸ����˳�������г�����
*/

-- 8������
/*
   ��������һ��ʹ�ü���model��sql�����ʵ�ָ���ҵ��Ĺ���
   ������ζ��һ�ι�������ܹ���ѭ����ִ��һ���Ĵ������ߵ���������Ϊ��ʱִ��
   
   [iterate (n) [until <condition>] ]
   (<cell_assignment> = <expression> ...)
   
   rules iterate(5)	�������ν���5��ѭ��
   iteration_number	��ǰѭ�������ı����ӵ�һ�Σ���ʼ��������n-1,����nΪiterate (n)�Ӿ���ָ����ѭ��������
   sale[cv(year),cv(week)-iteration_number+2]	����ǰ�����Լ������ܵ�ֵ��
   case when iteration_number=0 then '' else ',' end	Ϊ�б��г��˵�һ����Ա�����ÿ����Ա������һ�����š�
*/
--����
select year,week,sale,sale_list
from sales_fact sf
where sf.country in ('Australia') and sf.product ='Xtend Memory'
model return updated rows
partition by (product, country) 
dimension by (year, week)
measures ( cast(' ' as varchar2(50) ) sale_list, sale ) 
rules iterate(5)( -- Ŀ��Ϊ�Զ��ŷָ��б����ʽչʾ����sale�е�ֵ
 sale_list[year,week] order by year,week =sale[cv(year),cv(week)-iteration_number+2] || 
 case when iteration_number=0 then '' else ',' end ||
 sale_list [cv(year),cv(week)]
);






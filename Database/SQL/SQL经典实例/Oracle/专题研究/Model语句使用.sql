/*
  sales_fact表记录了每周口罩的进货量、销售量和库存
  本周库存 = 本周进货量-本周销售额+上周库存，我们可以用上图中的公式，来计算每周的库存
*/

-- 1、跨行引用
create table sales_fact
(
  prod      varchar2(20),--产品
  year    number,      --年
  week    number,      --月
  sale    number,      --销售额
  receipts   number       --进货量
);

insert into sales_fact values ('口罩',2020,1,100,200);
insert into sales_fact values ('口罩',2020,2,100,200);
insert into sales_fact values ('口罩',2020,3,150,300);
insert into sales_fact values ('口罩',2020,4,1000,5000);
insert into sales_fact values ('口罩',2020,5,2000,10000);
insert into sales_fact values ('口罩',2020,6,3000,0);
insert into sales_fact values ('口罩',2020,7,5000,0);
insert into sales_fact values ('口罩',2020,8,10000,10000);
insert into sales_fact values ('口罩',2020,9,100000,100000);
insert into sales_fact values ('口罩',2020,10,100000,100000);
insert into sales_fact values ('口罩',2020,11,100000,100000);
insert into sales_fact values ('口罩',2020,12,100000,100000);
insert into sales_fact values ('口罩',2020,13,100000,100000);
insert into sales_fact values ('口罩',2020,14,100000,100000);

select * from sales_fact;
/*
   cv表示现值，可以用来表示从规则左侧计算得来的规则右侧的列值。
   如规则左侧的year和week列的值为(2001,3)，规则右侧的cv(year)子句所指的值为规则左侧year值的值，也就是2001,
   类似地，cv(week)子句指的是规则左侧week列的值也就是3。
   因此，inventory [ cv(year), cv(week) - 1 ]子句将返回2001年中前1周也就是第２周的库存度量值。
   类似,sale [ cv(year), cv(week) ]和 receipts [ cv(year), cv(week) ]指的是使用c函数计算的2001年第３周的sale列和receipts列的值。
   在规则中并未声明分区列product和country，规则隐式地为product和country列引用当前分区中的值
*/
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory --库存量
from sales_fact
where 1 = 1
model return updated rows
partition by(prod) -- 将prod列指定为分区列(在一个分区中，维度列唯一辩识每一行)
dimension by(year,week) -- 指定year,week为维度列（维度列唯一辩识每一行，产品为口罩，每年每周只有一行数据）

measures(0 inventory,sale,receipts)  -- 表示 inventory, sale, receipts三列为计算的列值
rules automatic -- 规则类似于一个公式
-- 计算公式 0 inventory 代表如果找不到上周的库存，默认值为0
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)])
order by prod,year,week;

-- 2、位置标记
/*
   假设2020年第8周，口罩销售量和进货量猛增，有部分数据没有录入系统
   其实真实的进货量为300000，销售量也为200000
*/

/*
   位置标记能够在结果集中插入一个新单元格或更新一个己有单元格。
   如果所引用的单元格在结果集中存在，则会更新单元格的值；如果不存在，则会增加一个新的单元格。
   这种存在则更新，不存在则插入的概念被称为upsert特性，是update和insert功能的融合版本，位置标记提供了upsert的能力
*/
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory --库存量
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts) rules automatic
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)],
sale[2020,8] = 200000, receipts[2020,8] = 300000) -- 更新未添加上的
order by prod,year,week;

select * from sales_fact;

/*
   假设15周的数据忘记记录了，在原有的基础上加上15周的数据
   2020年第15周销售额 100000，进货量100000
*/
--15周数据不存在
--我直接在公式列指定即可，马上就有数据了
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory --库存量
from sales_fact
where 1 = 1
model return updated rows
partition by(prod)
dimension by(year,week)
measures(0 inventory,sale,receipts) rules automatic
order(inventory[year,week] = nvl(inventory[cv(year),cv(week) - 1],0) - sale[cv(year),cv(week)] + receipts[cv(year),cv(week)],sale[2020,8] = 200000, receipts[2020,8] = 300000,sale[2020,15] = 200000, receipts[2020,15] = 200000)
order by prod,year,week;

-- 3、符号标记
-- 此时需求14-16周的销售额和进货量都是录入数据的1.2倍

-- 符号标记不同于位置标记，如果不存在不会新增
-- 此列自己指定了每个公式的order by  没有用 automatic order，但是推荐使用 automatic order,Oracle还是很智能的
-- 在规则部分可以声明多个规则，并且规则可以声明相互之间的依赖关系。
-- 不仅如此，即使在一个单独的规则中，规则的求解也必须要按照一定的逻辑顺序进行

-- 注释了return updated rows之后，显示所有
select prod ,
       year ,
       week ,
       sale ,    -- 销售量
       receipts, -- 进货量
       inventory -- 库存量
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

--符号标记不同于位置标记，如果不存在不会新增
--此列自己指定了每个公式的order by  没有用 automatic order，但是推荐使用 automatic order,Oracle还是很智能的
--加上return updated rows之后，只显示更改的
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory --库存量
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

-- 4、for循环
-- 假设现在有需求，2020年第8周开始，每周进货量和销售额都是150000
/*
   for dimension for <value1> to <value2>
   [increment | decrement] <value3>
*/
--此时不存在的15周也出来了
--for循环可以减少很多代码量
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory --库存量
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

-- 5、聚合
-- Model子句还可以配合avg、sum、max等函数一起使用
select prod ,
       year ,
       week ,
       sale ,    --销售量
       receipts, --进货量
       inventory, --库存量
       avg_inventory , --平均库存
       max_sale      --单周最大销售额
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

-- 6、行求解顺序
/*
   在规则部分可以声明多个规则，并且规则可以声明相互之间的依赖关系。
   不仅如此，即使在一个单独的规则中，规则的求解也必须要按照一定的逻辑顺序进行。
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
   将automatic order注释掉，强制使用了sequential order的默认行为。
   该规则通过inventory[cv(year),cv(week)-1]子句进行了跨行引用。库存列的值必须按照周的升序进行计算。
   前一周的库存规则必须在当前周的库存规则之前求解。
   通过automatic order,数据库引擎确定了行依赖关系并严格按照依赖关系的顺序对行进行求解。
   如果没有automatic order，行求解顺序就不能确定，这将会导致ORA-32637错误
*/

-- 解决方案
-- 显式声明行求解顺序以避免这个错误
select product,country,year,week,inventory,sale,receipts
from sales_fact sf
where sf.country in ('Australia') and product in ('Xtend Memory')
model return updated rows
partition by(product, country) 
dimension by(year, week)
measures(0 inventory,sale, receipts) 
rules  -- automatic order
(
 -- 通过order by year,week子句显式声明了行求解顺序，表示必须按照year和week列值的升序求解
 inventory[year,week] order by year,week =nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)]
) 
order by product, country, year, week;

-- 7、规则求解顺序
-- 除了行求解顺序外，还需要面对所应用的规则求解顺序问题
--规则求值顺序--顺序求值
select * from (
  select product,country,year,week,inventory,sale,receipts
  from sales_fact sf
  where sf.country in ('Australia') and product in ('Xtend memory')
  model return updated rows
  partition by (product, country) 
  dimension by (year, week)
  measures (0 inventory,sale, receipts) 
  rules sequential order  -- sequential order指定了规则按照其在列表中的先后顺序进行求解
  (
   inventory[year,week] order by year,week =nvl(inventory[cv(year),cv(week)-1],0)-sale[cv(year),cv(week)]+receipts[cv(year),cv(week)],
   receipts[year in (2000,2001),week in (51,52,53)] order by year,week =receipts[cv(year),cv(week)]*10
  ) 
  order by product, country, year, week
) where week>50;

-- 规则求值顺序--自动求值
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
  上面两个sql的结果是不匹配的。automatic order允许数据库引擎自动识别规则之间的依赖关系。
  因此，数据库引擎首先对receipts规则求解，然后是inventory规则。
  规则的求解顺序是非常重要的，如果存在很复杂的相互依赖性，需要指定automatic order并按照严格求解顺序依次列出规则。
*/

-- 8、迭代
/*
   迭代是另一种使用简洁的model　sql语句来实现复杂业务的功能
   迭代意味着一段规则代码能够在循环中执行一定的次数或者当条件保持为真时执行
   
   [iterate (n) [until <condition>] ]
   (<cell_assignment> = <expression> ...)
   
   rules iterate(5)	规则程序段进行5次循环
   iteration_number	当前循环次数的变量从第一次０开始，结束于n-1,其中n为iterate (n)子句中指定的循环次数。
   sale[cv(year),cv(week)-iteration_number+2]	访问前两周以及后两周的值。
   case when iteration_number=0 then '' else ',' end	为列表中除了第一个成员以外的每个成员加上了一个逗号。
*/
--迭代
select year,week,sale,sale_list
from sales_fact sf
where sf.country in ('Australia') and sf.product ='Xtend Memory'
model return updated rows
partition by (product, country) 
dimension by (year, week)
measures ( cast(' ' as varchar2(50) ) sale_list, sale ) 
rules iterate(5)( -- 目标为以逗号分隔列表的形式展示５周sale列的值
 sale_list[year,week] order by year,week =sale[cv(year),cv(week)-iteration_number+2] || 
 case when iteration_number=0 then '' else ',' end ||
 sale_list [cv(year),cv(week)]
);






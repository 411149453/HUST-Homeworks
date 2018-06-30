show tables;
system echo '[94m-- PART I -------------------------------------------------'
system echo '[94m-----------------------------------------------------------'

-- 清理表 -------------------------------------------------
system echo '[93m==> 清理表';
drop table if exists GOODS;
drop table if exists PLAZA;
drop table if exists SALE;
drop table if exists SALE_CHEAP;
drop table if exists R;
drop view  if exists SALE_CHEAP_VIEW;

-- 创建表 -------------------------------------------------
system echo '[93m==> 创建表';
create table if not exists GOODS (
    商品名称 nvarchar(10) not null primary key,
    商品类型 nvarchar(5)  not null
);

create table if not exists PLAZA (
    商场名称 nvarchar(10) not null primary key,
    所在地区 nvarchar(5)  not null
);

create table if not exists SALE (
    商品名称 nvarchar(10) not null,
    商场名称 nvarchar(10) not null,
    价格     decimal(8,2) not null default 0.0,
    促销类型 nvarchar(10),
    primary key (商品名称, 商场名称)
);

-- 插入数据 -----------------------------------------------
system echo '[93m==> 插入数据';
insert into GOODS (商品名称, 商品类型) values
('创维*电视',       '电器'),
('格力*空调',       '电器'),
('海尔*冰箱',       '电器'),
('小天鹅*洗衣机',   '电器'),
('老人头*t恤',      '服装'),
('lEE*牛仔裤',      '服装'),
('哈森*皮靴',       '服装'),
('七匹狼*夹克',     '服装'),
('晨光*中性笔',     '文具'),
('得力*笔记本',     '文具'),
('老干妈*辣酱',     '食品'),
('奥利奥*饼干',     '食品'),
('海天*酱油',       '食品');

insert into PLAZA values
('群光广场',        '武昌'),
('新世界百货',      '汉口'),
('汉商购物中心',    '汉阳'),
('大洋百货',        '武昌'),
('校园超市',        '武昌'),
('王府井百货',      '汉口');

insert into SALE values
('创维*电视',       '群光广场',     3188,   '打折'  ),
('格力*空调',       '群光广场',     4588,   '打折'  ),
('海尔*冰箱',       '汉商购物中心', 3888,   null    ),
('lEE*牛仔裤',      '汉商购物中心', 500,    '送券'  ),
('晨光*中性笔',     '汉商购物中心', 1.5,    null    ),
('得力*笔记本',     '汉商购物中心', 5,      null    ),
('奥利奥*饼干',     '汉商购物中心', 8,      null    ),
('小天鹅*洗衣机',   '大洋百货',     2288,   null    ),
('格力*空调',       '大洋百货',     4388,   '打折'  ),
('老人头*t恤',      '大洋百货',     1200,   '送券'  ),
('lEE*牛仔裤',      '大洋百货',     380,    '打折'  ),
('哈森*皮靴',       '大洋百货',     300,    '打折'  ),
('老干妈*辣酱',     '大洋百货',     9,      null    ),
('七匹狼*夹克',     '新世界百货',   880,    '打折'  ),
('晨光*中性笔',     '校园超市',     1,      null    ),
('得力*笔记本',     '校园超市',     4.5,    null    ),
('奥利奥*饼干',     '校园超市',     8.5,    null    );

system echo '[94m-- PART II ------------------------------------------------'
system echo '[94m-----------------------------------------------------------'
-- 将SALE表中活动类型为打折的记录插入到新表SALE_CHEAP中 ---
system echo '[93m==> 将SALE表中活动类型为打折的记录插入到新表SALE_CHEAP中';
create table if not exists SALE_CHEAP as (
    select * from SALE
    where 促销类型="打折"
);
select * from SALE_CHEAP;

-- 群光广场的创维电视停止打折活动，价格恢复为3988 ---------
system echo '[93m==> 群光广场的创维电视停止打折活动，价格恢复为3988';
update SALE
set 价格=3988, 促销类型=null
where 商场名称='群光广场' and 商品名称='创维*电视';

delete from SALE_CHEAP
where 商场名称='群光广场' and 商品名称='创维*电视';

select * from SALE;
select * from SALE_CHEAP;

-- 基于SALE_CHEAP表创建一个统计每个打折商品平均价格的视图--
system echo '[93m==> 基于SALE_CHEAP表创建一个统计每个打折商品平均价格的视图';
create view if not exists SALE_VIEW as (
    select 商品名称, AVG(价格)
    from SALE_CHEAP
    group by 商品名称
);
select * from SALE_VIEW;

system echo '[94m-- PART III -----------------------------------------------'
system echo '[94m-----------------------------------------------------------'
-- 查询有没有任何促销活动的商品及其所在的商场 -------------
system echo '[93m==> 查询有没有任何促销活动的商品及其所在的商场';
select 商品名称, 商场名称
from SALE
where 促销类型 is null
order by 商品名称;

-- 查询价格在200～500元之间的商品名称等 -------------------
system echo '[93m==> 查询价格在200～500元之间的商品名称等';
select 商品名称, 商场名称, 价格
from SALE
where 价格>=200 and 价格<=500
order by 商场名称;

-- 查询每种商品的商品名称、最低售价、最高售价 -------------
system echo '[93m==> 查询每种商品的商品名称、最低售价、最高售价';
select  商品类型, min(价格), max(价格)
from GOODS join SALE
on GOODS.商品名称=SALE.商品名称
group by 商品类型;

-- 查询以“打折”方式销售的商品总数超过2种的商场信息 --------
system echo '[93m==> 查询以“打折”方式销售的商品总数超过2种的商场信息';
select PLAZA.商场名称, PLAZA.所在地区
from PLAZA join SALE
on PLAZA.商场名称=SALE.商场名称
where 促销类型='打折'
group by PLAZA.商场名称
having count(*)>2;

-- 查询以“老”字开头的所有商品的名称 -----------------------
system echo '[93m==> 查询以“老”字开头的所有商品的名称';
select 商品名称
from GOODS
where 商品名称 like '老%';

-- 查询同时销售“晨光*中性笔”和“得力*笔记本”的商场名称 -----
system echo '[93m==> 查询同时销售“晨光*中性笔”和“得力*笔记本”的商场名称';
( select 商场名称
from SALE
where 商品名称='晨光*中性笔'
) intersect ( select 商场名称
from SALE
where 商品名称='得力*笔记本'
);

-- 查询未举办任何活动的商场 -------------------------------
system echo '[93m==> 查询未举办任何活动的商场';
select 商场名称
from SALE
group by 商场名称
having COUNT(促销类型) = 0;

-- 查询出售商品种类最多的商场名称 -------------------------
system echo '[93m==> 查询出售商品种类最多的商场名称';
select 商场名称
from SALE
group by 商场名称
having count(*)>=all(
    select count(*)
    from SALE
    group by 商场名称
);

-- 查询出售商品类型最多的商场名称 -------------------------
system echo '[93m==> 查询出售商品类型最多的商场名称';
select 商场名称
from
SALE inner join GOODS
on SALE.商品名称=GOODS.商品名称
group by SALE.商场名称
having count(distinct GOODS.商品类型)>=all(
    select count(distinct GOODS.商品类型)
    from SALE inner join GOODS
    on SALE.商品名称=GOODS.商品名称
    group by SALE.商场名称
);

-- 查询销售商品包含“校园超市”所销售的所有商品的商场名称 ---
system echo '[93m==> 查询销售商品包含“校园超市”所销售的所有商品的商场名称';
select oldSALE.商场名称
from (
    select * from SALE
) as oldSALE
inner join (
    select 商品名称 from SALE
    where 商场名称='校园超市'
) as newSALE
on oldSALE.商品名称=newSALE.商品名称
group by oldSALE.商场名称
having
    count(distinct oldSALE.商品名称)=count(distinct newSALE.商品名称);

-- 查询所有商品的名称及出售该商品的商场 -------------------

system echo '[93m==> 查询所有商品的名称及出售该商品的商场，显示未在任何商场出售的商品名称';
select GOODS.商品名称, 商场名称
from GOODS left outer join SALE
on GOODS.商品名称 = SALE.商品名称;


system echo '[94m-- PART IV ------------------------------------------------'
system echo '[94m-----------------------------------------------------------'
-- 在SALE中增加活动截止时间列， 并进行各种查询 ------------
system echo '[93m==> 在SALE中增加活动截止时间列， 并进行各种查询'
system echo '[33m--> 在SALE表中增加一个活动截止时间列';
alter table SALE
add 活动截止时间 timestamp;

insert into SALE (商品名称,商场名称,活动截止时间)
values
('创维*电视',       '群光广场',     '2019-03-31 04:23:21'),
('格力*空调',       '群光广场',     '2016-09-12 01:36:41'),
('海尔*冰箱',       '汉商购物中心', '2018-05-31 23:50:01'),
('lEE*牛仔裤',      '汉商购物中心', '2018-05-31 01:43:21'),
('晨光*中性笔',     '汉商购物中心', '2019-05-26 01:00:00'),
('得力*笔记本',     '汉商购物中心', '2018-10-01 03:06:41'),
('奥利奥*饼干',     '汉商购物中心', '2018-07-19 08:00:00'),
('小天鹅*洗衣机',   '大洋百货',     '2018-10-26 17:00:00'),
('格力*空调',       '大洋百货',     '2016-10-08 12:00:00'),
('老人头*t恤',      '大洋百货',     '2018-11-19 05:00:00'),
('lEE*牛仔裤',      '大洋百货',     '2016-12-14 12:23:21'),
('哈森*皮靴',       '大洋百货',     '2018-05-22 22:30:01'),
('老干妈*辣酱',     '大洋百货',     '2016-12-26 08:50:01'),
('七匹狼*夹克',     '新世界百货',   '2018-05-16 15:23:21'),
('晨光*中性笔',     '校园超市',     '2019-12-14 06:00:00'),
('得力*笔记本',     '校园超市',     '2016-02-04 18:00:00'),
('奥利奥*饼干',     '校园超市',     '2016-08-25 03:06:41')
on duplicate key update 活动截止时间=values(活动截止时间);

system echo '[33m--> 查出所有在整点时刻截止活动的商品';
select * from SALE
where minute(活动截止时间)=0 and second(活动截止时间)=0;

system echo '[33m--> 查询活动截止时间在本月最后一天的SALE记录';
select *
from SALE
where date(活动截止时间)=last_day(curdate());

system echo '[33m--> 查询活动截止时间在2016年的SALE记录';
select *
from SALE
where year(活动截止时间)=2016;

system echo '[33m--> 查询本月的最后一天';
select last_day(curdate());

system echo '[33m--> 将所有打折商品的活动截止时间推迟一个小时';
update SALE
set `活动截止时间`=timestampadd(hour, 1, `活动截止时间`);
select * from SALE;

-- 将查询结果的某些列的某些值转换成特殊的形式 -------------
system echo '[93m==> 将查询结果的某些列的某些值转换成特殊的形式';
select 商场名称,
case 所在地区
    when '武昌' then '附近'
    else '遥远'
end as '所在地区'
from PLAZA;

-- 查询价格个位数为8元的商品名称、所在商场名称和价格 ------
system echo '[93m==> 查询价格个位数为8元的商品名称、所在商场名称和价格';
select 商品名称, 商场名称, 价格
from SALE
where 价格%10=8;

-- 假设品牌名不可能包含“*”号，查询所有商品的品 ------------
system echo '[93m==> 假设品牌名不可能包含“*”号，查询所有商品的品';
select 商品名称,substr(商品名称, 1, instr(商品名称, '*') - 1) as 品牌名
from SALE;

system echo '[94m-- PART V -------------------------------------------------'
system echo '[94m-----------------------------------------------------------'
create table if not exists R (
    A char(10) primary key,
    B int
);

insert into R values
("C1", 40),
("C2", 50),
("C3", 60);

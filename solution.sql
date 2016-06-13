use Exam;

-- выборка данных
--1. Найдите все классы кораблей, которые записаны в базе данных
select Classes.class from Classes;

--2. Выбрать все корабли, которые были спущены до Второй мировой войны
select Ships.name, Ships.launched from Ships where Ships.launched < '1939';

--3. Определите среднее число орудий для классов линейных кораблей
select avg(cast(Classes.numGuns as float)) from Classes where Classes.type = 'bb';

--4. С точностью до двух десятичных знаков определите среднее
-- число орудий всех линейных кораблей.
select round(avg(cast(Q.numGuns as float)), 2)
from (select Ships.name, Classes.numGuns
		from Ships, Classes
		where Ships.class = Classes.class and Classes.type = 'bb') as Q
;

--5. Найдите корабли, «сохранившиеся для будущих сражений»; 
--то есть выведенные из строя в одной битве (damaged),
-- они участвовали в другой.
select Outcomes.ship from Outcomes
inner join 
	(select Outcomes.ship from Outcomes 
	group by Outcomes.ship
	having COUNT(Outcomes.ship) > 1) as Mult
on Outcomes.ship = Mult.ship
group by Outcomes.ship
;

--6. Укажите названия, водоизмещение и число орудий, 
--кораблей участвовавших в сражении при Гвадалканале (Guadalcanal).
select Outcomes.ship, Classes.displacement, Classes.numGuns
from Outcomes, Ships, Classes
where Outcomes.battle = 'Guadalcanal' and Outcomes.ship = Ships.name and Ships.class = Classes.class
union
select Outcomes.ship, Classes.displacement, Classes.numGuns
from Outcomes, Classes
where Outcomes.battle = 'Guadalcanal' and Outcomes.ship = Classes.class and
	Outcomes.ship not in (select Ships.name from Ships)
;

--7. Для каждого класса определите число кораблей этого 
--класса, потопленных в сражении. Вывести: класс и число 
--потопленных кораблей
select Classes.class, isnull(SecondTemp.secondcnt, 0) from Classes
left outer join
(
	select Temp.class, sum(Temp.cnt) as secondcnt from
		(
		select Classes.class, count(classes.class) as cnt
		from Classes, Ships, Outcomes
		where Outcomes.result = 'sunk' and Outcomes.ship = Ships.name and Ships.class = Classes.class
		group by Classes.class
		union all
		select Classes.class, count(classes.class)
		from Classes, Outcomes
		where Outcomes.result = 'sunk' and Outcomes.ship = Classes.class and 
			Outcomes.ship not in (select Ships.name from Ships)
		group by Classes.class
		) as Temp
	group by Temp.class
) as SecondTemp
on Classes.class = SecondTemp.class
;

--8. Укажите сражения, в которых участвовало, по меньшей мере,
-- три корабля одной и той же страны
select Temp.battle --, Temp.country, count(Temp.country) as Cnt
from 
	(select Outcomes.ship, Outcomes.battle, Classes.country
		from Outcomes, Classes, Ships
		where Outcomes.ship = Ships.name and Ships.class = Classes.class
		union
		select Outcomes.ship, Outcomes.battle, Classes.country
		from Outcomes, Classes
		where Outcomes.ship = Classes.class and Outcomes.ship not in (select Ships.name from Ships)
	) as Temp
group by Temp.battle, Temp.country
having count(Temp.country) > 2
;

-- функции
--1. Функция, возвращающая количество битв в X году 
go
create function YearlyBattleCount (@year int)
returns int
as
begin

declare @count int
set @count = (select count(Battles.name) from Battles where year(Battles.date) = @year)
return @count

end


go
declare @result int
execute @result = YearlyBattleCount 1962
print @result

--2. Функция, возвращающая информацию о битвах, в которых 
--участвовал корабль Х
go
create function ShipBattles (@Name varchar(25))
returns table
as
return (select Outcomes.battle from Outcomes where Outcomes.ship = @Name)

go
select * from dbo.ShipBattles('California');

--3. функция, возвращающая дату последнего потопленного корабля
go
create function LastSinkDate()
returns date
as
begin

declare @SinkDate date
set @SinkDate = (
					select max(Battles.date)
					from Outcomes, Battles
					where Outcomes.battle = Battles.name and Outcomes.result = 'sunk'
				)
return @SinkDate

end

go
declare @date date
execute @date = LastSinkDate
print @date

--4. функция, возвращающая корабли, не воевавшие в войнах
go
create function DecorativeShips()
returns table
as
return (select Ships.name 
		from Ships 
		where Ships.name not in (select Outcomes.ship from Outcomes)
		)

go
select * from dbo.DecorativeShips();

--5. функция, возвращающая имя и класс корабля, в которых 
--встречаеться буква о больше 3-х раз. Нельзя чтобы класс 
--и имя корабля были одинаковыми
go
create function WeirdReqs()
returns table
as 
return (
		select Ships.name, Classes.class
		from Ships, Classes
		where Ships.class = Classes.class and Ships.name <> Classes.class and 
			Ships.name + Classes.class like '%o%o%o%o%'
	   )

go
select * from dbo.WeirdReqs();


-- процедуры
--1. Процедура принимает страну и возвращает таблицу в виде: 
--год, количество кораблей спущенных на воду (вывод на экран)
go
create procedure Launched
@Country varchar(25)
as	
	select Temp.launched, count(Temp.launched)
	from
		(select Classes.country, Ships.launched, Ships.name
		from Classes, Ships
		where Classes.class = Ships.class or Classes.class = Ships.name) as Temp
	where Temp.country = @Country
	group by Temp.launched

go
execute Launched 'USA'

--2. Сделать процедуру добавления новой записи в таблицы: 
--Battles, Classes, Outcomes, Ships
go
create procedure InsertBattle
@Name as varchar(20),
@Date as datetime
as 
	insert into Battles
	values(@Name, @Date)

go
execute InsertBattle 'OloloBattle', '2050-01-01 00:00:00.000'


go
create procedure InsertClass
@Class as varchar(50),
@Type as varchar(2),
@Country as varchar(20),
@NumGuns as tinyint,
@Bore as real,
@Displacement as int
as
	insert into Classes 
	values(@Class,@Type,@Country,@NumGuns,@Bore,@Displacement)

go
execute InsertClass 'OloloClass','bb','Germany',8,15,42000


go
create procedure InsertOutcome
@Ship as varchar(50),
@Battle as varchar(20),
@Result as varchar(10)
as
	insert into Outcomes
	values(@Ship, @Battle, @Result)

go
execute InsertOutcome 'OloloOutcome','North Atlantic','sunk'


go
create procedure InsertShip
@Name as varchar(50),
@Class as varchar(50),
@Launched as smallint
as
	insert into Ships
	values(@Name, @Class, @Launched)

go
execute InsertShip 'OloloShip','North Carolina',1941

--3. Сделать процедуру, выводящую корабли, потопленные во время 1-й мировой войны
--Заменил на 2-ю мировую, чтобы были тестовые данные
go
create procedure SunkWWII
as
	select Outcomes.ship
	from Outcomes, Battles
	where Outcomes.result = 'sunk' and Outcomes.battle = Battles.name and 
		Battles.date between '1939-09-01' and '1945-09-02'

go
execute SunkWWII

--4. Сделать процедуру, переименовывающую название 
--корабля (если название корабля являеться классом, 
--то и класс корабля переименовать)
go
create procedure RenameShip
@From varchar (25),
@To varchar (25)
as
	insert into Classes
	select @To, Classes.type, Classes.country, Classes.numGuns, Classes.bore, Classes.displacement
	from Classes
	where Classes.class = @From

	update Ships
	set Ships.class = @To
	where Ships.class = @From

	update Ships
	set Ships.name = @To 
	where Ships.name = @From
	
	update Outcomes
	set Outcomes.ship = @To
	where Outcomes.ship = @From

	delete from Classes
	where Classes.class = @From

go
execute RenameShip 'Test', 'Ttt'

go
execute RenameShip 'Ttt', 'Test'

-- таблицы
-- Сделать точную копию существующих таблиц, убарв из них все ограничения, названия таблиц сделать с 
--цифрой 2 в конце
CREATE TABLE [Battles2] (
	[name] [varchar] (20) NULL ,
	[date] [datetime] NULL 
);

CREATE TABLE [Classes2] (
	[class] [varchar] (50) NULL ,
	[type] [varchar] (2) NULL ,
	[country] [varchar] (20) NULL ,
	[numGuns] [tinyint] NULL ,
	[bore] [real] NULL ,
	[displacement] [int] NULL 
);

CREATE TABLE [Ships2] (
	[name] [varchar] (50) NULL ,
	[class] [varchar] (50) NULL ,
	[launched] [smallint] NULL 
);

CREATE TABLE [Outcomes2] (
	[ship] [varchar] (50) NULL ,
	[battle] [varchar] (20) NULL ,
	[result] [varchar] (10) NULL 
);

-- тригеры
--1. Сделать тригер, который будет копировать все удаляемые записи из таблиц в свои копии ()
go
create trigger Battles_CopyDeleted
on Battles
after delete
as
	insert into Battles2
	select * from deleted
	
go
delete from Battles where Battles.name = 'OloloBattle';	
select * from Battles2;

go
create trigger Classes_CopyDeleted
on Classes
after delete
as
	insert into Classes2
	select * from deleted

go	
delete from Classes where Classes.class = 'OloloClass';	
select * from Classes2;

go
create trigger Outcomes_CopyDeleted
on Outcomes
after delete
as
	insert into Outcomes2
	select * from deleted

go	
delete from Outcomes where Outcomes.ship = 'OloloOutcome';	
select * from Outcomes2;

go
create trigger Ships_CopyDeleted
on Ships
after delete
as
	insert into Ships2
	select * from deleted

go	
delete from Ships where Ships.name = 'OloloShip';	
select * from Ships2;

--2. Запретить удаление или изменение таблиц в БД
go
create trigger NoDrop
on database
for drop_table 
as
	print 'Drop forbidden'
	rollback
	begin transaction
	
go
drop table Battles2;

go
create trigger NoAlter
on database
for alter_table 
as
	print 'Alter forbidden'
	rollback
	begin transaction
	
go
alter table Battles2
add testcol varchar(25);

select * from Battles2;

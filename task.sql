
go
use Exam;
GO
PRINT N'Recreating the objects for the database'
declare @table_name sysname, @constraint_name sysname
declare i cursor static for 
select c.table_name, a.constraint_name
from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS a join INFORMATION_SCHEMA.KEY_COLUMN_USAGE b
on a.unique_constraint_name=b.constraint_name join INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
on a.constraint_name=c.constraint_name
WHERE upper(c.table_name) in (upper('Battles'),upper('Classes'),upper('Ships'),upper('Outcomes'))
open i
fetch next from i into @table_name,@constraint_name
while @@fetch_status=0
begin
	exec('ALTER TABLE '+@table_name+' DROP CONSTRAINT '+@constraint_name)
	fetch next from i into @table_name,@constraint_name
end
close i
deallocate i
GO
declare @object_name sysname, @sql varchar(8000)
declare i cursor static for 
SELECT table_name from INFORMATION_SCHEMA.TABLES
where upper(table_name) in (upper('Battles'),upper('Classes'),upper('Ships'),upper('Outcomes'))
open i
fetch next from i into @object_name
while @@fetch_status=0
begin
	set @sql='DROP TABLE [dbo].['+@object_name+']'
	exec(@sql)
	fetch next from i into @object_name
end
close i
deallocate i
GO
CREATE TABLE [Battles] (
	[name] [varchar] (20) NOT NULL ,
	[date] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [Classes] (
	[class] [varchar] (50) NOT NULL ,
	[type] [varchar] (2) NOT NULL ,
	[country] [varchar] (20) NOT NULL ,
	[numGuns] [tinyint] NULL ,
	[bore] [real] NULL ,
	[displacement] [int] NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[Ships] (
	[name] [varchar] (50) NOT NULL ,
	[class] [varchar] (50) NOT NULL ,
	[launched] [smallint] NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[Outcomes] (
	[ship] [varchar] (50) NOT NULL ,
	[battle] [varchar] (20) NOT NULL ,
	[result] [varchar] (10) NOT NULL 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Battles] ADD 
	CONSTRAINT [PK_Battles] PRIMARY KEY  CLUSTERED 
	(
		[name]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[Classes] ADD 
	CONSTRAINT [PK_Classes] PRIMARY KEY  CLUSTERED 
	(
		[class]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[Ships] ADD 
	CONSTRAINT [PK_Ships] PRIMARY KEY  CLUSTERED 
	(
		[name]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[Outcomes] ADD 
	CONSTRAINT [PK_Outcomes] PRIMARY KEY  CLUSTERED 
	(
		[ship],
		[battle]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[Ships] ADD 
	CONSTRAINT [FK_Ships_Classes] FOREIGN KEY 
	(
		[class]
	) REFERENCES [dbo].[Classes] (
		[class]
	) NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Outcomes] ADD 
	CONSTRAINT [FK_Outcomes_Battles] FOREIGN KEY 
	(
		[battle]
	) REFERENCES [dbo].[Battles] (
		[name]
	)
GO                                                                                                                                                                                                                                                           
----Classes------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
insert into Classes values('Bismarck','bb','Germany',8,15,42000)
insert into Classes values('Iowa','bb','USA',9,16,46000)
insert into Classes values('Kongo','bc','Japan',8,14,32000)
insert into Classes values('North Carolina','bb','USA',12,16,37000)
insert into Classes values('Renown','bc','Gt.Britain',6,15,32000)
insert into Classes values('Revenge','bb','Gt.Britain',8,15,29000)
insert into Classes values('Tennessee','bb','USA',12,14,32000)
insert into Classes values('Yamato','bb','Japan',9,18,65000)
GO                                                                                                                                                                                                                                                                 
----Battles------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
insert into Battles values('Guadalcanal','19421115 00:00:00.000')
insert into Battles values('North Atlantic','19410525 00:00:00.000')
insert into Battles values('North Cape','19431226 00:00:00.000')
insert into Battles values('Surigao Strait','19441025 00:00:00.000')
insert into battles values ('#Cuba62a'   , '19621020')
insert into battles values ('#Cuba62b'   , '19621025')
GO                                                                                                                                                                                                                                                               
----Ships------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
insert into Ships values('California','Tennessee',1921)
insert into Ships values('Haruna','Kongo',1916)
insert into Ships values('Hiei','Kongo',1914)
insert into Ships values('Iowa','Iowa',1943)
insert into Ships values('Kirishima','Kongo',1915)
insert into Ships values('Kongo','Kongo',1913)
insert into Ships values('Missouri','Iowa',1944)
insert into Ships values('Musashi','Yamato',1942)
insert into Ships values('New Jersey','Iowa',1943)
insert into Ships values('North Carolina','North Carolina',1941)
insert into Ships values('Ramillies','Revenge',1917)
insert into Ships values('Renown','Renown',1916)
insert into Ships values('Repulse','Renown',1916)
insert into Ships values('Resolution','Renown',1916)
insert into Ships values('Revenge','Revenge',1916)
insert into Ships values('Royal Oak','Revenge',1916)
insert into Ships values('Royal Sovereign','Revenge',1916)
insert into Ships values('Tennessee','Tennessee',1920)
insert into Ships values('Washington','North Carolina',1941)
insert into Ships values('Wisconsin','Iowa',1944)
insert into Ships values('Yamato','Yamato',1941)
insert into Ships values('South Dakota','North Carolina',1941) 
GO                                                                                                                                                                                                                                                               
----Outcomes------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
insert into Outcomes values('Bismarck','North Atlantic','sunk')
insert into Outcomes values('California','Surigao Strait','OK')
insert into Outcomes values('Duke of York','North Cape','OK')
insert into Outcomes values('Fuso','Surigao Strait','sunk')
insert into Outcomes values('Hood','North Atlantic','sunk')
insert into Outcomes values('King George V','North Atlantic','OK')
insert into Outcomes values('Kirishima','Guadalcanal','sunk')
insert into Outcomes values('Prince of Wales','North Atlantic','damaged')
insert into Outcomes values('Rodney','North Atlantic','OK')
insert into Outcomes values('Schamhorst','North Cape','sunk')
insert into Outcomes values('South Dakota','Guadalcanal','damaged')
insert into Outcomes values('Tennessee','Surigao Strait','OK')
insert into Outcomes values('Washington','Guadalcanal','OK')
insert into Outcomes values('West Virginia','Surigao Strait','OK')
insert into Outcomes values('Yamashiro','Surigao Strait','sunk')
insert into Outcomes values('California','Guadalcanal','damaged')
GO



/*
Корабли в «классах» построены по одному и тому же проекту. 
Классу присваивается либо имя первого корабля, построенного по данному проекту, 
либо названию класса дается имя проекта, которое в этом случае не совпадает с именем ни одного из кораблей. 
Корабль, давший название классу, называется головным.

Атрибутами отношения Classes являются имя класса (class), тип (значение bb используется для обозначения боевого 
или линейного корабля, а bc для боевого крейсера), страну (country), которой принадлежат корабли данного класса, 
число главных орудий (numGuns), калибр орудий (bore — диаметр ствола орудия в дюймах) 
и водоизмещение в тоннах (displacement).

В отношение Ships записывается информация о кораблях: 
название корабля (name), имя его класса (class) и год спуска на воду (launched).

В отношение Battles включены название (name) и дата битвы (date), в которой участвовал корабль.

Отношение Outcomes используется для хранения информации о результатах участия кораблей в битвах, 
а именно, имя корабля (ship), название сражения (battle) и чем завершилось сражение для данного 
корабля (потоплен — sunk, поврежден — damaged или невредим — ok).

Отметим несколько моментов, на которые следует обратить внимание при анализе схемы http://v8.kiev.ua/ships.gif.
Таблица Outcomes имеет составной первичный ключ {ship, battle}. 
Это ограничение не позволит ввести в базу данных дважды один и тот же корабль, принимавший участие в одном и том же сражении. 
Однако допустимо неоднократное присутствие одного и того же корабля в данной таблице, 
что означает участие корабля в нескольких битвах. Класс корабля определяется из таблицы Ships, 
которая имеет внешний ключ (class) к таблице Classes.

Особенностью данной схемы, которая усложняет логику запросов и служит причиной ошибок при решении задач, является то, 
что таблицы Outcomes и Ships никак не связаны, то есть в таблице результатов сражений могут находиться корабли, 
отсутствующие в таблице Ships. На основании этого, казалось бы, можно сделать вывод о том, что для таких кораблей их класс 
неизвестен, а, следовательно, неизвестны и все технические характеристики. Это не совсем так. 
Как следует из описания предметной области, имя головного корабля совпадает с именем класса, родоначальником которого он является. 
Поэтому если имя корабля из таблицы Outcomes совпадает с именем класса в таблице Classes, то однозначно можно сказать, 
что это головной корабль, и, следовательно, все его характеристики нам известны.

Столбец launched в таблице Ships допускает NULL-значения, то есть нам может быть неизвестен год спуска на воду 
того или иного корабля. То же самое мы можем сказать о кораблях из Outcomes, отсутствующих в Ships.

коротко: -- http://v8.kiev.ua/ships.gif
Classes -- Таблица "Классы кораблей"
class             -- Имя класса (текстовое поле)(ключевое поле);
type             -- Тип (bb для боевого (линейного) корабля или bc для боевого крейсера);
country         -- Страна, в которой построен корабль;
numGuns      -- Число главных орудий;
bore             -- Калибр орудий (диаметр ствола орудия в дюймах);
displacement  -- Вводоизмещение ( вес в тоннах).

Ships -- Таблица " Названия кораблей"
name          -- Название;
class           -- Имя Класа(ссылка на таблицу Classes );
launched      -- Год спуска на воду.

Battles -- Таблица "Битвы"
name         -- Название битвы;
date           -- Дата битвы.

Outcomes -- Таблица "Результат участия данного корабля в битве"
ship            -- Корабль(ссылка на таблицу Ships ) ;
battle          -- Битва(ссылка на таблицу Battles ) ;
result          -- Результат участия в битве: потоплен-sunk, поврежден - damaged или невредим - OK .
*/

-- выборка данных
-- функция ROUND делает что-то полезное :)

--1. Найдите все классы кораблей, которые записаны в базе данных
--2. Выбрать все корабли, которые были спущены до Второй мировой войны
--3. Определите среднее число орудий для классов линейных кораблей

--4. С точностью до двух десятичных знаков определите среднее
-- число орудий всех линейных кораблей.
--5. Найдите корабли, «сохранившиеся для будущих сражений»; 
--то есть выведенные из строя в одной битве (damaged),
-- они участвовали в другой.

--6. Укажите названия, водоизмещение и число орудий, 
--кораблей участвовавших в сражении при Гвадалканале (Guadalcanal).
--7. Для каждого класса определите число кораблей этого 
--класса, потопленных в сражении. Вывести: класс и число 
--потопленных кораблей
--8. Укажите сражения, в которых участвовало, по меньшей мере,
-- три корабля одной и той же страны
-- функции
--1. Функция, возвращающая количество битв в X году 
--2. Функция, возвращающая информацию о битвах, в которых 
--участвовал корабль Х
--3. функция, возвращающая дату последнего потопленного корабля
--4. функция, возвращающая корабли, не воевавшие в войнах
--5. функция, возвращающая имя и класс корабля, в которых 
--встречаеться буква о больше 3-х раз. Нельзя чтобы класс 
--и имя корабля были одинаковыми
-- процедуры
--1. Процедура принимает страну и возвращает таблицу в виде: 
--год, количество кораблей спущенных на воду (вывод на экран)
--2. Сделать процедуру добавления новой записи в таблицы: 
--Battles, Classes, Outcomes, Ships
--3. Сделать процедуру, выводящую корабли, потопленные во время 1-й мировой войны
--4. Сделать процедуру, переименовывающую название 
--корабля (если название корабля являеться классом, 
--то и класс корабля переименовать)

-- таблицы
-- Сделать точную копию существующих таблиц, убарв из них все ограничения, названия таблиц сделать с цифрой 2 в конце
-- тригеры
--1. Сделать тригер, который будет копировать все удаляемые записи из таблиц в свои копии ()
--2. Запретить удаление или изменение таблиц в БД



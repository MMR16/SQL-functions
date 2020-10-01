--Variables
--golbal Variables starts with @@
select @@error , @@servername ,@@version, @@rowcount , @@identity

--Local must declare and used with @
-- declare with key word 'declare'
--initialize with key word 'set' or 'se;ect'
declare @x int --declare
set @x=10 -- initialize
select @x
select @x=age from student where id=10  --initialize
--------------
-- Create Database if exsists or not exsists 
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'del') 
select 'exsist'
else
 CREATE DATABASE del
 
 ----------
 IF not EXISTS (SELECT * FROM sys.databases WHERE name = 'del') 
 CREATE DATABASE del
else
select 'exsist'

-----------------------
--synonym is ashortcut for atable usually used with 
--schema or function or if tables name are too long
Use del
 create schema people --creating schema

 create table people.student(Fname nchar(30),id int identity primary key)

 create synonym ST for people.student -- creating synonym
 insert into st(fname) values ('MMR'),('ali'),('ahmed') -- synonym to insert data
 select * from people.student
 select * from ST -- using synonym as atable name

 drop table people.student
 drop table st -- can't use drop with synonym only table name
 truncate table st -- can't use truncate with synonym only table name
 drop schema people -- can't use drop with schema before dropping all tables using it
 drop synonym st


 ----------------------------------Funtions
 -- User Defined Functions
 --Scalar Function 
 --Return one Result only
 Use Northwind


 -- we don't need second parameter so when call we add keyword default to make it optional
 Create function GetCateName(@id int,@sid int) 
 returns nvarchar(50)
 begin
		declare @CateName nvarchar(50) --must be same ase return
		select @CateName=[CategoryName] from Categories where CategoryID = @id 
		return @CateName
 end

 drop function GetCateName
 select dbo.getcatename(3,default)

 ---------------------------Functions That return Table
 ------inline Function
 -- use select statement only & return table
 create function GetCatePrice(@id int)
 returns table
 as return(
 --if using ant operation must use Alias Name for column [as SummerDiscount]
 select [ProductID],[Quantity],[UnitPrice],[Discount]*2 as SummerDiscount 
 from [Order Details] 
 where [ProductID]=@id
 )

 --we use select * from because the function return table [just query]
 select * from GetCatePrice(3)

 -- select into to create physical table into DB Named FPrices
 -- we can use insert based on select also (insert into table select * from function)
 select *into FPrices from GetCatePrice(7)

 -- Using  inner Join with inline function
 select p.ProductID,[Quantity],p.UnitPrice,SummerDiscount,[ProductName]
 from GetCatePrice(7) P inner join Products PS
 on p.productid = ps.productid
 --we can use insert,select,update,union,delete,joins,....
------
 drop function GetCatePrice

 ----------------------
  ------MultiStatement Function
  -- insert statement based on select statement Function
Create function GetProduct(@format varchar(50))
returns @t table(id int,PName varchar(50), PQuantity  nvarchar (50)) as 
begin
if @format ='name'
insert into @t 
select [ProductID],[ProductName],null from [Products]
else if @format='Quantity'
insert into @t select [ProductID],null,[QuantityPerUnit] from [Products]
else if @format='Full'
insert into @t select [ProductID],[ProductName],[QuantityPerUnit] from [Products]

return
end

select * from GetProduct('name')
select * from GetProduct('Quantity')
select * from GetProduct('full')


drop function GetProduct

---------------------------Identity
--Setting identity manual
--then automatic again to Closing the Gap between identity nubmers
Use del
 create table student(Fname nchar(30),id int identity primary key)
 insert into student values ('MMR'),('ali'),('ahmed'),('mostafa'),('nour'),('asmaa')
 -- run insert statement 5 times , so we get 30 row with 30 id
 select * from student
 --deletting some rows
 delete from student where id between 1 and 10
 --we get 6 row affeted the id is now starts from 11
 -----
 -- turn IDENTITY_INSERT on  to add values manually
 set IDENTITY_INSERT student on;
insert into student(Fname,id) values ('MMR',1),('ali',2),('ahmed',3),('mostafa',4),('nour',5)
insert into student(Fname,id) values ('MMR',6),('ali',7),('ahmed',8),('mostafa',9),('nour',10)
select * from student --now we add the 10 deleted rows
-- turn IDENTITY_INSERT off to add values automatically
 set IDENTITY_INSERT student off;
 -- now the identity works automatically again and add more 6 rows till id=36
 insert into student values ('MMR'),('ali'),('ahmed'),('mostafa'),('nour'),('asmaa')

 ---------
  
DBCC CHECKIDENT ('student'); -- to know current identity number

------------------Tables
--table types
--1- Physical table we can close or restart sevices and the table will exist 
--delete when use drop
use del
go
create table Exam(id int identity primary key, ExName varchar(50),Exdate date )
----------------------
--2- variable table [livetime = querylifetime]
--must run as a patch
--can't run it without selecting all patch codes
declare @x table(x int) -- memory table
select * from @x
----------------------
--Local tables [session based tables]
-- not physical table on database
-- found in database - system databases - tempdb - temporary tables
--temporary table automaticaly deleted after closing session [query page that created in]
--can't access it from any other session [query page]
create table #Exam(id int identity primary key, ExName varchar(50),Exdate date )
select * from #Exam
drop table #Exam
----------------------
--global tables [shared tables]
-- not physical table on database
-- found in database - system databases - tempdb - temporary tables
--temporary table automaticaly deleted after closing all sessions [all query pages closed ]
--can access it from any other session [query page]
create table ##Exam(id int identity primary key, ExName varchar(50),Exdate date )
select * from ##Exam
drop table ##Exam


use db

drop table if exists tbIdentity
go

create table tbIdentity(pk int identity primary key,
c2 datetime2(3) default(sysdatetime()))
go

insert tbIdentity default values
go 5

select * from tbIdentity

shutdown with nowait
go

use db

--會跳過一千筆
insert tbIdentity default values
go 5

select * from tbIdentity

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF

SELECT * FROM sys.database_scoped_configurations;

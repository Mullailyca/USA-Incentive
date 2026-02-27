    
alter   PROCEDURE MIS_1001_PORTIN_WS_HS_INCENTIVE    
AS    
BEGIN    
    
DECLARE @sql varchar(max)    
Declare @YYYYMM1_112 varchar(10)    
Declare @YYYYMM2_112 varchar(10)    
Declare @YYYYMM3_112 varchar(10)    
Declare @YYYYMM4_112 varchar(10)    
Declare @YYYYMM5_112 varchar(10)    
    
Set @YYYYMM1_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)),112)    
Set @YYYYMM2_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)),112)    
Set @YYYYMM3_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0)),112)    
Set @YYYYMM4_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 4, 0)),112)    
Set @YYYYMM5_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 5, 0)),112)    
    
Select @YYYYMM1_112,@YYYYMM2_112,@YYYYMM3_112,@YYYYMM4_112,@YYYYMM5_112    
    
    
Set @sql='    
    
    
    
if object_id(''Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS'')is not null    
DROP TABLE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS    
    
if object_id(''Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS'')is not null    
DROP TABLE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS    
    
'    
PRINT(@SQL)    
EXEC(@SQL)    
    
SET @SQL='    
    
    
Select * into Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS from Mis_1717_USA_DETAIL_'+@YYYYMM5_112+'    
where ws_final=''Paid after 4months''    
    
Select * into Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS from Mis_1717_USA_DETAIL_'+@YYYYMM5_112+'    
where HS_final=''Paid after 4months''    
    
'    
PRINT(@SQL)    
EXEC(@SQL)    
    
SET @SQL='    
    
IF OBJECT_ID(''tempdb.dbo.##PORTIN'') is not null    
Drop table ##PORTIN     
    
Select * into ##PORTIN from MVNOREPORT_USA_LM.dbo.vw_mnpportoutrequest    
where convert(varchar(06),COMPLETEDDATE,120) between '''+@YYYYMM5_112+''' and '''+@YYYYMM1_112+'''    
'    
PRINT(@SQL)    
EXEC(@SQL)    
    
SET @SQL='    
    
Alter table Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS add Portout_New datetime    
    
Alter table Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS add Portout_New datetime    
'    
PRINT(@SQL)    
EXEC(@SQL)    
    
SET @SQL='    
update Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS set Portout_New=b.COMPLETEDDATE    
from Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS a,##PORTIN b    
where a.iccid=right(b.iccid,12)    
    
update Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS set Portout_New=b.COMPLETEDDATE    
from Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS a,##PORTIN b    
where a.iccid=right(b.iccid,12)    
    
--ALTER TABLE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS ADD STATUS VARCHAR(50);    
    
--ALTER TABLE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS ADD STATUS VARCHAR(50) ;   
    
--UPDATE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS    
--SET STATUS= Case when Portout_New is not null then ''NotEligible'' else ''Eligible'' END    
    
--UPDATE Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS    
--SET STATUS= Case when Portout_New is not null then ''NotEligible'' else ''Eligible'' END 

'
PRINT(@SQL)    
EXEC(@SQL)   

Set @sql='    

if object_id(''Mis_1717_USA_Detail_portin_WS'')is not null    
DROP TABLE Mis_1717_USA_Detail_portin_WS    
    
if object_id(''Mis_1717_USA_Detail_portin_HS'')is not null    
DROP TABLE Mis_1717_USA_Detail_portin_HS    
    
'    
PRINT(@SQL)    
EXEC(@SQL) 


set @sql='
    
Select ''RESELLER''    
Select *, Case when Portout_New is not null then ''NotEligible'' else ''Eligible''  End status into Mis_1717_USA_Detail_portin_WS from Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_WS    
 
  select * from Mis_1717_USA_Detail_portin_WS

Select ''RETAILER''    
Select *,Case when Portout_New is not null then ''NotEligible'' else ''Eligible'' End  status into  Mis_1717_USA_Detail_portin_HS from Mis_1717_USA_Detail_portin_'+@YYYYMM5_112+'_'+@YYYYMM1_112+'_HS    
 
   select * from Mis_1717_USA_Detail_portin_HS



 '

PRINT(@SQL)    
EXEC(@SQL)   

    
END    
    

 
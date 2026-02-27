        
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20240301>                         
-- Modify date: <>                        
-- Description: <USA_KB_Retailer_output>                          
-- =============================================                          
alter  procedure MIS_1717_USA_06_Retailer_output_Date2  
as   
begin  
  
--Sp_rename 'Mis_1717_USA_retailer_Detail_comm','Mis_1717_USA_retailer_Detail_comm_202507'  
--Sp_rename 'Mis_1717_USA_Retailer_output','Mis_1717_USA_Retailer_output_202507'  
  
Declare @Sql varchar(max)  
Declare @month Varchar(10)  
Declare @month1 Varchar(10)  
Declare @month3 Varchar(10)  
Declare @Year Varchar(4)  
Declare @MM Varchar(2)  
  
Set @month=convert(varchar(07),Dateadd(mm,-1,Getdate()),120)   
Set @month1=convert(varchar(06),Dateadd(mm,-1,Getdate()),112)   
Set @month3=convert(varchar(07),Dateadd(mm,-3,Getdate()),120)   
Set @Year=convert(varchar(04),Dateadd(mm,-1,Getdate()),112)   
Set @MM=right((convert(varchar(06),Dateadd(mm,-1,Getdate()),112)),2)  
  
Select @month,@month1,@Year,@MM,@month3  
  
  
  
Set @Sql='IF OBJECT_ID(''tempdb..##Deva'') IS NOT NULL        
drop table ##Deva        
select Retailerid into ##Deva from Mvnoreport_usa_lm.dbo.vw_dsmretailer  
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
Set @Sql='IF OBJECT_ID(''Mis_1717_USA_retailer_Detail_comm'') IS NOT NULL   
drop table Mis_1717_USA_retailer_Detail_comm  
select * into Mis_1717_USA_retailer_Detail_comm from Mis_1717_USA_Detail_comm   
where  Retailerid in (Select Retailerid From ##Deva)  
and  offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')  
and Convert(varchar(10),Activitydate,120)>''2024-12-08'''  
EXEC (@Sql)  
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where Portout_Status=''Portout'''  
EXEC (@Sql)  
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'',''SIM_BLOCK'')'  
EXEC (@Sql)  
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'',''Lessthan_60_Portin'',''Lessthan_90_Portin'',  
''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'')  
and activityname like ''%Portin%'''  
EXEC (@Sql)  
  
--Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
--where Portin_status=''Lessthan_45_Portin'''  
--EXEC (@Sql)  
  
--Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
--where Activityname in (''Residual_12_AR'',''Residual_12_R'') and RETAILER_COMM=0'  
--EXEC (@Sql)  
  
--Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
--where isnull(noofmonths,0)>=''4'' and Activityname like ''Plan_%'''   
--EXEC (@Sql)  
  
Set @Sql='  
IF OBJECT_ID(''tempdb..##Iccid_12month'') IS NOT NULL        
drop table ##Iccid_12month         
 Select Iccid,bundlecode,Count(*) cnt ,min(Topupseq) Min_topupseq into ##Iccid_12month from MIS_1717_BS_wrkard_master_dontdrop  
where convert(varchar(07),Topupdate,120)='''+@month+'''  
and bundlecode in (''1012'')  
group by Iccid,bundlecode having Count(*)=12'  
Exec (@sql)    
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where iccid in (select iccid from ##Iccid_12month ) and  Activityname in (''Residual_12_AR'',''Residual_12_R'') '  
Exec (@sql)  
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where Convert(varchar(10),activitydate,120)<=''2023-09-07''  and activityname not in (''Bundle_1'',''Bundle_2'')'  
EXEC (@Sql)  
  
  
Set @Sql='Delete from Mis_1717_USA_retailer_Detail_comm  
where RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'')  and activityname not in (''Bundle_1'',''Bundle_2'')'  
EXEC (@Sql)  
  
  
--select distinct activityname  from Mis_1717_USA_retailer_Detail_comm where ACTIVITYNAME like ''PLAN%''  
--update Mis_1717_USA_retailer_Detail_comm set RET_TIER=''LI_''+ACTIVITYNAME where RESELLERID like ''%-LI-%'' and ACTIVITYNAME like ''Plan%''--260  
--update Mis_1717_USA_retailer_Detail_comm set RET_TIER=''NON_LI_''+ACTIVITYNAME where RESELLERID not like ''%-LI-%'' and ACTIVITYNAME like ''Plan%''--5475  
--update Mis_1717_USA_retailer_Detail_comm set ACTIVITYNAME=RET_TIER where RET_TIER is not null  
  
  
Set @Sql='IF OBJECT_ID(''tempdb..##TopupCategory_Ret'') IS NOT NULL        
drop table ##TopupCategory_Ret        
select ISNULL(Resellerid,'''')Resellerid,ISNULL(offmgrid,'''')offmgrid,ISNULL(accmgrid,'''')accmgrid,ISNULL(hotspotid,'''')hotspotid,        
ISNULL(retailerid,'''')retailerid,activityname,ISNULL(RET_DC_TIER,'''') RET_DC_TIER,ISNULL(RES_TYPE,'''') RES_TYPE,   
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE ,Comm_Type,      
case when activityname in (''Residual_12_AR'',''Residual_12_R'') then SUM(BUNDLE_VALUE)    
else count(*)    
end cnt  ,SUM(RETAILER_COMM)RETAILER_COMM        
into ##TopupCategory_Ret  from Mis_1717_USA_retailer_Detail_comm        
where Convert(varchar(07),activitydate,120)  =  '''+@month+'''      
and ISNULL(accmgrid,'''') not like ''%EUROPEAN%''   
group by ISNULL(Resellerid,''''),ISNULL(offmgrid,''''),ISNULL(accmgrid,''''),ISNULL(hotspotid,''''),  
ISNULL(retailerid,''''),activityname,ISNULL(RET_DC_TIER,''''),ISNULL(RES_TYPE,''''),  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE,Comm_Type '  
EXEC (@Sql)   
  
  
Set @Sql='insert into ##TopupCategory_Ret  
select ISNULL(Resellerid,'''')Resellerid,ISNULL(offmgrid,'''')offmgrid,ISNULL(accmgrid,'''')accmgrid,ISNULL(hotspotid,'''')hotspotid,   
ISNULL(retailerid,'''')retailerid,activityname,   ISNULL(RET_DC_TIER,'''') , ISNULL(RES_TYPE,'''') RES_TYPE,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE,Comm_Type ,      
case when activityname in (''Residual_12_AR'',''Residual_12_R'') then SUM(BUNDLE_VALUE)    
else count(*)    
end cnt  ,SUM(RETAILER_COMM)RETAILER_COMM        
from Mis_1717_USA_retailer_Detail_comm        
where Convert(varchar(07),activitydate,120)  =   '''+@month+'''        
and ISNULL(accmgrid,'''') like ''%EUROPEAN%''  
and activityname in (''Residual_12_AR'',''Residual_12_R'')  
group by ISNULL(Resellerid,''''),ISNULL(offmgrid,''''),ISNULL(accmgrid,''''),ISNULL(hotspotid,''''),  
ISNULL(retailerid,''''),activityname,ISNULL(RET_DC_TIER,''''),ISNULL(RES_TYPE,''''),  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE,Comm_Type '  
EXEC (@Sql)   
  
  
DECLARE @columns1 TABLE (COL varchar(50))         
declare @Col varchar(max)    
declare @id varchar(100)    
declare @columnscsv2 varchar(MAX)                
  
        
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MIS_1717_Pivot_category_RET]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)                                                             
drop table MIS_1717_Pivot_category_RET               
  
DECLARE @columns4 TABLE (COL varchar(50))                                                  
declare @columnscsv4 varchar(MAX)                              
        
insert into @columns4                                  
select distinct activityname  from ##TopupCategory_RET    order by activityname                              
        
select @columnscsv4 = COALESCE(@columnscsv4 + '],[','') + COL from @columns4                                  
set @columnscsv4 = '[' + @columnscsv4 + ']'                                  
select @columnscsv4        
        
SET @sql = 'SELECT Resellerid,offmgrid,accmgrid,hotspotid,retailerid,RET_DC_TIER,RES_TYPE,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE ,Comm_Type, ' + @columnscsv4 + ' into  MIS_1717_Pivot_category_RET FROM           
##TopupCategory_RET                                  
PIVOT (SUM(cnt) for activityname in (' + @columnscsv4+ ')) as PVT order by Resellerid,offmgrid,accmgrid,hotspotid,retailerid,RET_DC_TIER,RES_TYPE,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE ,Comm_Type '                                  
            
print(@sql)         
exec(@sql)     
  
--select * from Mis_1717_KB_COLUMN_MASTER order by id  
--="insert into Mis_1717_KB_COLUMN_MASTER values('"&A1&"','"&B1&"')"  
    
set @id=1    
while(@id<200)     
begin    
    
select @Col=Column_name from Mis_1717_KB_COLUMN_MASTER    
where ID=@id    
    
    
set @sql='    
if  (select COUNT(*) from dbo.syscolumns where id = object_id(''[MIS_1717_Pivot_category_RET]'')    
AND NAME IN('''+@Col+''') )=0    
ALTER TABLE   MIS_1717_Pivot_category_RET  Add '+@Col+' float'    
exec (@sql)    
set @id=@id+1    
end   
  
    
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Mis_1717_Pivot_category_comm_RET]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)                                                                             
drop table Mis_1717_Pivot_category_comm_RET                               
                        
DECLARE @columns5 TABLE (COL varchar(50))                                                  
declare @columnscsv5 varchar(MAX)                              
                         
insert into @columns5                                                  
select distinct activityname  from ##TopupCategory_RET    order by activityname              
                        
select @columnscsv5 = COALESCE(@columnscsv5 + '],[','') + COL from @columns5                                                  
set @columnscsv5 = '[' + @columnscsv5 + ']'                                                  
select @columnscsv5                         
                        
SET @sql = 'SELECT Resellerid,offmgrid,accmgrid,hotspotid,retailerid,RET_DC_TIER,RES_TYPE,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE ,Comm_Type,  ' + @columnscsv5 + ' into  Mis_1717_Pivot_category_comm_RET FROM                                                  
##TopupCategory_RET                                                 
PIVOT (SUM(retailer_comm) for activityname in (' + @columnscsv5+ ')) as PVT   
order by Resellerid,offmgrid,accmgrid,hotspotid,retailerid,RET_DC_TIER,RES_TYPE ,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE,Comm_Type '                                                  
                            
print(@sql)                         
exec(@sql)         
         
set @id=1    
while(@id<200)     
begin    
    
select @Col=Column_name from Mis_1717_KB_COLUMN_MASTER    
where ID=@id    
    
set @sql='    
if  (select COUNT(*) from dbo.syscolumns where id = object_id(''[Mis_1717_Pivot_category_comm_RET]'')    
AND NAME IN('''+@Col+''') )=0    
ALTER TABLE   Mis_1717_Pivot_category_comm_RET  Add '+@Col+' float'    
exec (@sql)    
set @id=@id+1    
end    
  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Arjun1'') is not null  
Drop table ##Arjun1  
  
Select A.Resellerid,A.offmgrid,A.accmgrid,A.Hotspotid,A.retailerid,A.RET_DC_TIER,A.RES_TYPE,  
A.Ret_Bundle_1,A.Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE ,Comm_Type,   
sum(isnull(Plan_15_1,0)) Plan_15_1,sum(isnull(Plan_19_1,0)) Plan_19_1,sum(isnull(Plan_23_1,0)) Plan_23_1,sum(isnull(Plan_29_1,0)) Plan_29_1,  
sum(isnull(Plan_33_1,0)) Plan_33_1,sum(isnull(Plan_39_1,0)) Plan_39_1,sum(isnull(Plan_49_1,0)) Plan_49_1,sum(isnull(Plan_59_1,0)) Plan_59_1,  
sum(isnull(Plan_15_2,0)) Plan_15_2,sum(isnull(Plan_19_2,0)) Plan_19_2,sum(isnull(Plan_23_2,0)) Plan_23_2,sum(isnull(Plan_29_2,0)) Plan_29_2,  
sum(isnull(Plan_33_2,0)) Plan_33_2,sum(isnull(Plan_39_2,0)) Plan_39_2,sum(isnull(Plan_49_2,0)) Plan_49_2,sum(isnull(Plan_59_2,0)) Plan_59_2,  
sum(isnull(Plan_15_3,0)) Plan_15_3,sum(isnull(Plan_19_3,0)) Plan_19_3,sum(isnull(Plan_23_3,0)) Plan_23_3,sum(isnull(Plan_29_3,0)) Plan_29_3,  
sum(isnull(Plan_33_3,0)) Plan_33_3,sum(isnull(Plan_39_3,0)) Plan_39_3,sum(isnull(Plan_49_3,0)) Plan_49_3,sum(isnull(Plan_59_3,0)) Plan_59_3,  
sum(isnull(Plan_15_4,0)) Plan_15_4,sum(isnull(Plan_19_4,0)) Plan_19_4,sum(isnull(Plan_23_4,0)) Plan_23_4,sum(isnull(Plan_29_4,0)) Plan_29_4,  
sum(isnull(Plan_33_4,0)) Plan_33_4,sum(isnull(Plan_39_4,0)) Plan_39_4,sum(isnull(Plan_49_4,0)) Plan_49_4,sum(isnull(Plan_59_4,0)) Plan_59_4,  
sum(isnull(Plan_30_1,0)) Plan_30_1,sum(isnull(Plan_30_2,0)) Plan_30_2,sum(isnull(Plan_30_3,0)) Plan_30_3,sum(isnull(Plan_30_4,0)) Plan_30_4,  
sum(isnull(a.residual_12_AR,0)) residual_12_AR,sum(isnull(a.residual_12_R,0)) residual_12_R,  
sum(isnull(Plan_Ch29_1,0)) Plan_Ch29_1,sum(isnull(Plan_Ch29_2,0)) Plan_Ch29_2,sum(isnull(Plan_Ch29_3,0)) Plan_Ch29_3,sum(isnull(Plan_Ch29_4,0)) Plan_Ch29_4,  
sum(isnull(Plan_Ch49_1,0)) Plan_Ch49_1,sum(isnull(Plan_Ch49_2,0)) Plan_Ch49_2,sum(isnull(Plan_Ch49_3,0)) Plan_Ch49_3,sum(isnull(Plan_Ch49_4,0)) Plan_Ch49_4,  
sum(isnull(Plan_Ch59_1,0)) Plan_Ch59_1,sum(isnull(Plan_Ch59_2,0)) Plan_Ch59_2,sum(isnull(Plan_Ch59_3,0)) Plan_Ch59_3,sum(isnull(Plan_Ch59_4,0)) Plan_Ch59_4,  
sum(isnull(Plan_12M_1012_10,0)) Plan_12M_1012_10,0 Plan_12M_1912_1,   
SUM(isnull(a.portin_plan_15_4,0)) portin_plan_15_4,SUM(isnull(a.portin_plan_19_4,0)) portin_plan_19_4,SUM(isnull(a.portin_plan_23_4,0)) portin_plan_23_4,  
SUM(isnull(a.portin_plan_29_4,0)) portin_plan_29_4,SUM(isnull(a.portin_plan_33_4,0)) portin_plan_33_4,  
SUM(isnull(a.portin_plan_39_4,0)) portin_plan_39_4,SUM(isnull(a.portin_plan_49_4,0)) portin_plan_49_4,SUM(isnull(a.Portin_Plan_59_4,0)) portin_plan_59_4,  
sum(isnull(a.portin_Plan_Ch29_4,0)) portin_Plan_Ch29_4,sum(isnull(portin_Plan_Ch49_4,0)) portin_Plan_Ch49_4,sum(isnull(portin_Plan_Ch59_4,0)) portin_Plan_Ch59_4,  
sum(isnull(a.portin_plan_1012_4,0)) portin_plan_1012_4,0 portin_plan_1912_4,sum(isnull(a.portin_plan_30_4,0)) portin_plan_30_4,  
sum(isnull(A.Bundle_1,0)) Bundle_1,sum(isnull(A.Bundle_2,0)) Bundle_2  
into ##Arjun1  
from Mis_1717_Pivot_category_RET A  
Group by A.Resellerid,A.offmgrid,A.accmgrid,A.Hotspotid,A.retailerid,A.RET_DC_TIER,A.RES_TYPE,  
A.Ret_Bundle_1,A.Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE,Comm_Type '    
exec (@sql)    
  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Arjundev1'') is not null  
Drop table ##Arjundev1  
  
Select A.Resellerid,A.offmgrid,A.accmgrid,A.Hotspotid,A.retailerid,A.RET_DC_TIER,A.RES_TYPE,  
A.Ret_Bundle_1,A.Ret_Activebase,A.RET_RESIDUAL_TIER,A.RET_T1M_FCA,A.RET_T1M_TP,A.RET_T1M_PER,A.RET_T1M_TYPE ,A.Comm_Type,   
sum(isnull(plan_15_1,0)+isnull(plan_15_2,0)+isnull(plan_15_3,0)+isnull(plan_15_4,0)) as plan_15_comm,  
sum(isnull(plan_19_1,0)+isnull(plan_19_2,0)+isnull(plan_19_3,0)+isnull(plan_19_4,0)) as plan_19_comm,  
sum(isnull(plan_23_1,0)+isnull(plan_23_2,0)+isnull(plan_23_3,0)+isnull(plan_23_4,0)) as Plan_23_comm,  
SUM(isnull(plan_29_1,0)+isnull(plan_29_2,0)+isnull(plan_29_3,0)+isnull(plan_29_4,0)) as plan_29_comm,  
sum(isnull(plan_33_1,0)+isnull(plan_33_2,0)+isnull(plan_33_3,0)+isnull(plan_33_4,0)) as plan_33_comm,  
sum(isnull(plan_39_1,0)+isnull(plan_39_2,0)+isnull(plan_39_3,0)+isnull(plan_39_4,0)) as plan_39_comm,  
sum(isnull(plan_49_1,0)+isnull(plan_49_2,0)+isnull(plan_49_3,0)+isnull(plan_49_4,0)) as plan_49_comm,  
SUM(isnull(plan_59_1,0)+isnull(plan_59_2,0)+isnull(plan_59_3,0)+isnull(plan_59_4,0)) as plan_59_comm,  
SUM(isnull(plan_30_1,0)+isnull(plan_30_2,0)+isnull(plan_30_3,0)+isnull(plan_30_4,0)) as plan_30_comm,  
sum(isnull(plan_CH29_1,0)+isnull(plan_CH29_2,0)+isnull(plan_CH29_3,0)+isnull(plan_CH29_4,0)+  
isnull(plan_CH49_1,0)+isnull(plan_CH49_2,0)+isnull(plan_CH49_3,0)+isnull(plan_CH49_4,0)+  
isnull(plan_CH59_1,0)+isnull(plan_CH59_2,0)+isnull(plan_CH59_3,0)+isnull(plan_CH59_4,0)) as family_Childplan_comm,  
SUM(isnull(a.portin_plan_15_4,0)+isnull(a.portin_plan_19_4,0)+isnull(a.portin_plan_23_4,0)+isnull(a.portin_plan_29_4,0)+isnull(a.portin_plan_33_4,0)+  
isnull(a.portin_plan_39_4,0)+isnull(a.portin_plan_49_4,0)+isnull(a.Portin_Plan_59_4,0)  
+isnull(a.portin_plan_1012_4,0)+isnull(a.portin_plan_1912_4,0)  
+isnull(a.portin_plan_Ch29_4,0)+isnull(a.portin_plan_Ch49_4,0)+isnull(a.portin_plan_Ch59_4,0)+isnull(a.portin_plan_30_4,0)) Portin_comm,  
sum(isnull(Plan_12M_1012_10,0)) Plan_12M_comm,  
sum(isnull(a.residual_12_AR,0)+isnull(a.residual_12_R,0)) residual_comm,  
sum(isnull(a.Bundle_1,0) +isnull(A.Bundle_2,0)) Act_slab_comm,0 Dealer_comm,  
sum(  
isnull(plan_15_1,0)+isnull(plan_15_2,0)+isnull(plan_15_3,0)+isnull(plan_15_4,0)+  
isnull(plan_19_1,0)+isnull(plan_19_2,0)+isnull(plan_19_3,0)+isnull(plan_19_4,0)+  
isnull(plan_23_1,0)+isnull(plan_23_2,0)+isnull(plan_23_3,0)+isnull(plan_23_4,0)+  
isnull(plan_29_1,0)+isnull(plan_29_2,0)+isnull(plan_29_3,0)+isnull(plan_29_4,0)+  
isnull(plan_33_1,0)+isnull(plan_33_2,0)+isnull(plan_33_3,0)+isnull(plan_33_4,0)+  
isnull(plan_39_1,0)+isnull(plan_39_2,0)+isnull(plan_39_3,0)+isnull(plan_39_4,0)+  
isnull(plan_49_1,0)+isnull(plan_49_2,0)+isnull(plan_49_3,0)+isnull(plan_49_4,0)+  
isnull(plan_59_1,0)+isnull(plan_59_2,0)+isnull(plan_59_3,0)+isnull(plan_59_4,0)+  
isnull(plan_30_1,0)+isnull(plan_30_2,0)+isnull(plan_30_3,0)+isnull(plan_30_4,0)+  
isnull(plan_CH29_1,0)+isnull(plan_CH29_2,0)+isnull(plan_CH29_3,0)+isnull(plan_CH29_4,0)+  
isnull(plan_CH49_1,0)+isnull(plan_CH49_2,0)+isnull(plan_CH49_3,0)+isnull(plan_CH49_4,0)+  
isnull(plan_CH59_1,0)+isnull(plan_CH59_2,0)+isnull(plan_CH59_3,0)+isnull(plan_CH59_4,0)+  
--isnull(a.portin_plan_15_4,0)+isnull(a.portin_plan_19_4,0)+isnull(a.portin_plan_23_4,0)+isnull(a.portin_plan_29_4,0)+isnull(a.portin_plan_33_4,0)+  
--isnull(a.portin_plan_39_4,0)+isnull(a.portin_plan_49_4,0)+isnull(a.Portin_Plan_59_4,0)+  
--isnull(a.portin_plan_1012_4,0)+isnull(a.portin_plan_1912_4,0)+  
--isnull(a.portin_plan_Ch29_4,0)+isnull(a.portin_plan_Ch49_4,0)+isnull(a.portin_plan_Ch59_4,0)+isnull(a.portin_plan_30_4,0)+  
isnull(a.residual_12_AR,0)+isnull(a.residual_12_R,0)) Total_comm   
into ##ArjunDev1  
from Mis_1717_Pivot_category_comm_RET A  
Group by A.Resellerid,A.offmgrid,A.accmgrid,A.Hotspotid,A.retailerid,A.RET_DC_TIER,A.RES_TYPE,  
A.Ret_Bundle_1,A.Ret_Activebase,A.RET_RESIDUAL_TIER,A.RET_T1M_FCA,A.RET_T1M_TP,A.RET_T1M_PER,A.RET_T1M_TYPE,A.Comm_Type '    
exec (@sql)    
  
Set @sql='alter table ##ArjunDev1 add ic float '    
exec (@sql)    
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##ins'') is not null  
Drop table ##ins  
select retailerid,Resellerid,sum(retailer_comm) comm into ##ins from Mis_1717_ins_comm  
where (CONVERT(Varchar(07),Reportdate,120) = '''+@month+''' and CONVERT(Varchar(07),TopupDate,120) = '''+@month+''' )  
or (CONVERT(Varchar(07),Reportdate,120) = '''+@month+'''  and Retailer_comm>0  
and CONVERT(Varchar(07),TopupDate,120) <> '''+@month+''' )  
--and RES_TYPE like ''%HP%''   
group by retailerid,Resellerid'    
exec (@sql)    
  
Set @Sql='update a set a.ic=b.comm from ##ArjunDev1 a,##ins b  
where a.retailerid=b.retailerid  
and a.Resellerid=b.Resellerid  
and a.retailerid in (Select retailerid from Mis_1717_USA_Detail_comm_double)  
and A.Comm_Type=''Double'''    
exec (@sql)   
  
Set @Sql='update a set a.ic=b.comm from ##ArjunDev1 a,##ins b  
where a.retailerid=b.retailerid  
and a.Resellerid=b.Resellerid  
and a.retailerid in (Select retailerid from Mis_1717_USA_Detail_comm_UNIQUE)  
and A.Comm_Type=''unique'''    
exec (@sql)   
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##ArjunDevA1'') is not null  
Drop table ##ArjunDevA1  
SELECT retailerid,sum(IC) ic INTO ##ArjunDevA1 FROM ##ArjunDev1   
GROUP BY retailerid'    
exec (@sql)   
  
Set @Sql='update a set a.ic=b.comm from ##ArjunDev1 a,##ins b  
where a.retailerid=b.retailerid  
and a.Resellerid=b.Resellerid  
and A.Comm_Type=''Normal''  
AND A.retailerid NOT IN (SELECT retailerid FROM ##ArjunDevA1 WHERE IC>=0)  
'    
exec (@sql)   
  
  
-----Deva missing   
  
Set @sql='alter table ##ArjunDev1 add Missing_ic_202308 float '    
exec (@sql)    
  
--Set @Sql='  
--IF OBJECT_ID(''tempdb.dbo.##ins1'') is not null  
--Drop table ##ins1  
--select Left(Cdr_time_stamp,6) month, retailerid,Resellerid,sum(Retailer_Commission) comm into ##ins1 from Mis_1717_USA_Balancecdr_recon_202308_final  
--group by Left(Cdr_time_stamp,6),retailerid,Resellerid'    
--exec (@sql)   
  
--Set @Sql='update a set a.Missing_ic_202308=b.comm from ##ArjunDev1 a,##ins1 b  
--where a.retailerid=b.retailerid  
--and a.Resellerid=b.Resellerid  
--and b.month=''202308''  
--'    
--exec (@sql)   
  
--Set @Sql='update a set a.Missing_ic_202307=b.comm from ##ArjunDev1 a,##ins1 b  
--where a.retailerid=b.retailerid  
--and a.Resellerid=b.Resellerid  
--and b.month=''202307'''    
--exec (@sql)   
   
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Mis_1717_USA_Retailer_output'') is not null  
Drop table ##Mis_1717_USA_Retailer_output  
  
Select A.Resellerid,A.offmgrid,A.accmgrid,A.Hotspotid,A.retailerid,A.RET_DC_TIER,A.RES_TYPE,  
A.Ret_Bundle_1,A.Ret_Activebase,A.RET_RESIDUAL_TIER,A.RET_T1M_FCA,A.RET_T1M_TP,A.RET_T1M_PER,A.RET_T1M_TYPE,A.Comm_Type ,   
A.Plan_15_1,A.Plan_19_1,A.Plan_23_1,A.Plan_29_1,A.Plan_33_1,A.Plan_39_1,A.Plan_49_1,A.Plan_59_1,  
A.Plan_15_2,A.Plan_19_2,A.Plan_23_2,A.Plan_29_2,A.Plan_33_2,A.Plan_39_2,A.Plan_49_2,A.Plan_59_2,  
A.Plan_15_3,A.Plan_19_3,A.Plan_23_3,A.Plan_29_3,A.Plan_33_3,A.Plan_39_3,A.Plan_49_3,A.Plan_59_3,  
A.Plan_15_4,A.Plan_19_4,A.Plan_23_4,A.Plan_29_4,A.Plan_33_4,A.Plan_39_4,A.Plan_49_4,A.Plan_59_4,  
A.Plan_30_1,A.Plan_30_2,A.Plan_30_3,A.Plan_30_4,  
A.Plan_CH29_1,A.Plan_CH29_2,A.Plan_CH29_3,A.Plan_CH29_4,  
A.Plan_CH49_1,A.Plan_CH49_2,A.Plan_CH49_3,A.Plan_CH49_4,  
A.Plan_CH59_1,A.Plan_CH59_2,A.Plan_CH59_3,A.Plan_CH59_4,  
A.portin_plan_15_4,A.portin_plan_19_4,A.portin_plan_23_4,A.portin_plan_29_4,A.portin_plan_33_4,A.portin_plan_39_4,A.portin_plan_49_4,  
A.portin_plan_59_4,A.portin_plan_30_4,  
A.Portin_Plan_ch29_4,A.Portin_Plan_ch49_4,A.Portin_Plan_ch59_4,  
A.portin_plan_1012_4,A.portin_plan_1912_4,  
A.Residual_12_AR,A.Residual_12_R,  
A.Bundle_1,A.Bundle_2,A.Plan_12M_1012_10,A.Plan_12M_1912_1,  
B.plan_15_comm,B.plan_19_comm,B.Plan_23_comm,B.plan_29_comm,B.plan_30_comm,B.plan_33_comm,B.plan_39_comm,B.plan_49_comm,B.plan_59_comm,  
B.family_Childplan_comm,B.Portin_comm,B.Plan_12M_comm,B.residual_comm,B.Act_slab_comm,  
--Case when  A.RET_DC_TIER=''Tier1'' then 1*33.  
--  when  A.RET_DC_TIER=''Tier2'' then 2*33.  
--  when  A.RET_DC_TIER=''Tier3'' then 3*33.  
--  when  A.RET_DC_TIER=''Tier4'' then 4*33.  
--  when  A.RET_DC_TIER=''Tier5'' then 5*33.  
--  when  A.RET_DC_TIER=''Tier6'' then 6*33.  
--end    
0 Dealer_comm,  
B.Ic,B.Total_comm MC  
,B.Missing_ic_202308,  
--B.Missing_ic_202307,   
isnull(B.Ic,0)+isnull(B.Missing_ic_202308,0) Total_ic,b.Total_comm- (isnull(B.Ic,0)+isnull(B.Missing_ic_202308,0)) Final_Comm  
into ##Mis_1717_USA_Retailer_output  
from ##Arjun1 a,##ArjunDev1 b  
where a.retailerid=b.retailerid   
and a.resellerid=b.resellerid  
and A.Comm_Type=b.Comm_Type'    
exec (@sql)    
  
Select 'Retailer output'  
  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_Retailer_output'') is not null  
Drop table Mis_1717_USA_Retailer_output  
  
Select CONVERT(VARCHAR(10),DATEADD(month, DATEDIFF(month, 0, GETDATE()) - 1, 0),120) as FROMDATE,EOMONTH(GETDATE(), -1)
AS TODATE,
''LMPLUS'' Brand,B.createdby,B.createddate,B.contactperson ,B.mobileno ,B.landlineno,B.fname,B.lname,B.postcode,B.houseno,B.street,B.cityname,B.email,B.shoptype,  
A.resellerid,A.offmgrid,A.accmgrid,A.hotspotid,A.retailerid,  
case when b.RetailerMode=''2'' then ''Virtual''  
when b.retailermode=''1'' then ''Whitelisted''  
else ''Regular'' end retailermode,  
case when b.RetailerMode=''2'' then b.Virtual_msisdn  
when b.retailermode=''1'' then b.Whitelistmsisdn  
else isnull(b.Whitelistmsisdn,b.Virtual_msisdn) end msisdn,  
A.Plan_15_1,A.Plan_19_1,A.Plan_23_1,A.Plan_29_1,A.Plan_30_1,A.Plan_33_1,A.Plan_39_1,A.Plan_49_1,A.Plan_59_1,  
A.Plan_15_2,A.Plan_19_2,A.Plan_23_2,A.Plan_29_2,A.Plan_30_2,A.Plan_33_2,A.Plan_39_2,A.Plan_49_2,A.Plan_59_2,  
A.Plan_15_3,A.Plan_19_3,A.Plan_23_3,A.Plan_29_3,A.Plan_30_3,A.Plan_33_3,A.Plan_39_3,A.Plan_49_3,A.Plan_59_3,  
A.Plan_15_4,A.Plan_19_4,A.Plan_23_4,A.Plan_29_4,A.Plan_30_4,A.Plan_33_4,A.Plan_39_4,A.Plan_49_4,A.Plan_59_4,  
--A.Plan_19_5,A.Plan_23_5,A.Plan_29_5,A.Plan_33_5,A.Plan_39_5,A.Plan_49_5,A.Plan_59_5,  
--A.Plan_50_1,A.Plan_50_2,A.Plan_50_3,A.Plan_50_4,  
A.Plan_CH29_1,A.Plan_CH29_2,A.Plan_CH29_3,A.Plan_CH29_4,  
A.Plan_CH49_1,A.Plan_CH49_2,A.Plan_CH49_3,A.Plan_CH49_4,  
A.Plan_CH59_1,A.Plan_CH59_2,A.Plan_CH59_3,A.Plan_CH59_4,  
A.portin_plan_15_4,A.portin_plan_19_4,A.portin_plan_23_4,A.portin_plan_29_4,A.portin_plan_30_4,  
A.portin_plan_33_4,A.portin_plan_39_4,A.portin_plan_49_4,A.portin_plan_59_4,  
--A.portin_family_plan,  
A.Portin_plan_ch29_4,A.Portin_plan_ch49_4,A.Portin_plan_ch59_4,  
A.portin_plan_1012_4,A.portin_plan_1912_4,  
A.Residual_12_AR,A.Residual_12_R,  
A.Bundle_1,A.Bundle_2,  
A.Plan_12M_1012_10,A.Plan_12M_1912_1,  
A.plan_15_comm,A.plan_19_comm,A.Plan_23_comm,A.plan_29_comm,A.plan_30_comm,A.plan_33_comm,A.plan_39_comm,A.plan_49_comm,A.plan_59_comm,  
A.family_Childplan_comm,A.Portin_comm,A.Plan_12M_comm,A.residual_comm,A.Act_slab_comm,isnull(A.Dealer_comm,0) Dealer_comm,  
isnull(A.Ic,0) IC,isnull(A.Dealer_comm,0)+isnull(A.MC,0)+isnull(A.Plan_12M_comm,0) MC,a.RET_DC_TIER,  
A.Ret_Bundle_1,A.Ret_Activebase,A.RET_RESIDUAL_TIER,A.RET_T1M_FCA,A.RET_T1M_TP,A.RET_T1M_PER,A.RET_T1M_TYPE ,A.Comm_Type,   
--A.Missing_ic_202306,  
isnull(A.Missing_ic_202308,0) Missing_ic_202308,isnull(A.Ic,0) Total_ic,isnull(A.Dealer_comm,0)+isnull(A.MC,0)+isnull(A.Plan_12M_comm,0)-A.Total_ic Final_Comm  
into Mis_1717_USA_Retailer_output  
from ##Mis_1717_USA_Retailer_output a  
left join MVNOREPORT_USA_LM.dbo.vw_dsmretailer b  
on a.retailerid=b.retailerid'    
exec (@sql)     
  
update Mis_1717_USA_Retailer_output set plan_15_comm=0,  
plan_19_comm=0, Plan_23_comm=0, plan_29_comm=0, plan_30_comm=0,plan_33_comm=0, plan_39_comm=0, plan_49_comm=0, plan_59_comm=0,  
family_Childplan_comm=0,  
Portin_comm=0, Plan_12M_comm=0, residual_comm=0, Act_slab_comm=0, Dealer_comm=0, MC=0  
where Resellerid in ('LMPUS-SIM-ST-LI-TX-ELPASO','LMPUS-SIM-SM-HEADOFFICE','LMPUS-SIM-OF-TESTING','LMPUS-SIM-ON-HEADOFFICE')  
  
Alter Table  Mis_1717_USA_Retailer_output add New_Type varchar(100)  
  
--Update Mis_1717_USA_Retailer_output set New_Type='No Sim Activation 3month Retailer 202308'  
--where retailerid in (Select retailerid from Mis_1717_USA_Retailer_group_master_202309  
--where groupname='No Sim Activation 3month Retailer 202308'  
--)  
  
  
  
Select Distinct Retailerid,Case when  RET_DC_TIER='Tier1' then 1*29.  
  when  RET_DC_TIER='Tier2' then 2*29.  
  when  RET_DC_TIER='Tier3' then 3*29.  
  when  RET_DC_TIER='Tier4' then 4*29.  
  when  RET_DC_TIER='Tier5' then 5*29.  
  when  RET_DC_TIER='Tier6' then 6*29.  
end Dealer_comm  
From Mis_1717_USA_retailer_Detail_comm  
where RET_DC_TIER<>'NA'  
  
  
Select  Distinct Offmgrid,Accmgrid,Hotspotid,Retailerid,  
Case when  RET_DC_TIER='Tier1' then 1.  
  when  RET_DC_TIER='Tier2' then 2.  
  when  RET_DC_TIER='Tier3' then 3.  
  when  RET_DC_TIER='Tier4' then 4.  
  when  RET_DC_TIER='Tier5' then 5.  
  when  RET_DC_TIER='Tier6' then 6.  
end Dealer_VOU,  
Case when  RET_DC_TIER='Tier1' then 1*29.  
  when  RET_DC_TIER='Tier2' then 2*29.  
  when  RET_DC_TIER='Tier3' then 3*29.  
  when  RET_DC_TIER='Tier4' then 4*29.  
  when  RET_DC_TIER='Tier5' then 5*29.  
  when  RET_DC_TIER='Tier6' then 6*29.  
end Dealer_comm  
From Mis_1717_USA_retailer_Detail_comm  
where RET_DC_TIER <>'NA'  
  
  
--Select Resellerid,Retailerid,RES_TYPE,Sum(Retailer_comm) IC from Mis_1717_ins_comm  
--group by Resellerid,Retailerid,RES_TYPE  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##ins'') is not null  
Drop table ##ins  
Select Resellerid,Retailerid,RES_TYPE,Sum(Retailer_comm) IC from Mis_1717_ins_comm  
where (CONVERT(Varchar(07),Reportdate,120) = '''+@month+''' and CONVERT(Varchar(07),TopupDate,120) = '''+@month+''' )  
or (CONVERT(Varchar(07),Reportdate,120) = '''+@month+'''  and Retailer_comm>0  
and CONVERT(Varchar(07),TopupDate,120) <> '''+@month+''' )  
group by Resellerid,Retailerid,RES_TYPE'    
exec (@sql)    
  
--Select Left(Cdr_time_stamp,6) Month,Resellerid, Retailerid,RES_TYPE,Sum(Retailer_Commission) IC from Mis_1717_USA_Balancecdr_recon_202308_final  
--group by Left(Cdr_time_stamp,6),Resellerid,Retailerid,RES_TYPE  
  
--if object_id ('Mis_1717_USA_Detail_comm_DOUBLE_OUTPUT') is not null    
--DROP TABLE Mis_1717_USA_Detail_comm_DOUBLE_OUTPUT    
    
--if object_id ('Mis_1717_USA_Detail_comm_UNIQUE_OUTPUT') is not null    
--DROP TABLE Mis_1717_USA_Detail_comm_UNIQUE_OUTPUT    
  
--sELECT 'UNIQUE'  
--SELECT ICCID, ACTIVITYNAME, ACTIVITYDATE, RESELLERID, OFFMGRID, ACCMGRID, HOTSPOTID, RETAILERID,  
--BUNDLE_VALUE, BUNDLE_CODE, BUNDLE_NAME,RETAILER_COMM,RES_TYPE,Portout_Status, Portin_status,newrno into Mis_1717_USA_Detail_comm_UNIQUE_OUTPUT  
--FROM Mis_1717_USA_Detail_comm_UNIQUE where retailerid in (select retailerid from Mis_1717_USA_Detail_comm_UNIQUE where newrno>100)  
  
--select * from Mis_1717_USA_Detail_comm_UNIQUE_OUTPUT  
  
--sELECT 'DOUBLE'  
--SELECT ICCID, ACTIVITYNAME, ACTIVITYDATE, RESELLERID, OFFMGRID, ACCMGRID, HOTSPOTID, RETAILERID,  
--BUNDLE_VALUE, BUNDLE_CODE, BUNDLE_NAME,RETAILER_COMM,RES_TYPE,Portout_Status, Portin_status,newrno into Mis_1717_USA_Detail_comm_DOUBLE_OUTPUT  
--FROM Mis_1717_USA_Detail_comm_double where retailerid in (select retailerid from Mis_1717_USA_Detail_comm_double where newrno>100)  
  
--select * from Mis_1717_USA_Detail_comm_DOUBLE_OUTPUT  
  
--Update Mis_1717_USA_Retailer_output set New_Type='double'  
--where retailerid in (Select retailerid from Mis_1717_USA_Detail_comm_double)  
  
--Update Mis_1717_USA_Retailer_output set New_Type='unique'  
--where retailerid in (Select retailerid from Mis_1717_USA_Detail_comm_UNIQUE)  
  
select * from Mis_1717_USA_Retailer_output  

select 'retailer_block'

select * from Mis_1717_USA_Detail_comm_blocK
  
  
End  
  

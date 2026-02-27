        
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20230302>                         
-- Modify date: <20231009>                        
-- Description: <USA_KB_Reseller_output>                          
-- =============================================                          
ALTER  procedure MIS_1717_USA_05_Reseller_output  
as   
begin  
  
--Sp_rename 'Mis_1717_USA_Reseller_output','Mis_1717_USA_Reseller_output_202507'  
  
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
  
Set @Sql='IF OBJECT_ID(''tempdb..##Mis_1717_USA_Detail_comm'') IS NOT NULL        
drop table ##Mis_1717_USA_Detail_comm        
  
Select * into ##Mis_1717_USA_Detail_comm from Mis_1717_USA_Detail_comm'  
Exec (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where Wholesalerid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where offmgrid<>Wholesalerid'  
EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)>=''4''  
--and Activityname like ''Plan%4'''  
--EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where isnull(Gateway_Offmgr,Wholesalerid)<>Wholesalerid'  
EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)=''4''  and Bundle_seq<=4 and Bundle_seq<>''Addon''  
--and Activityname like ''Residual%'''  
--EXEC (@Sql)  
  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)=''5''  and Bundle_seq<=5 and Bundle_seq<>''Addon''  
--and Activityname like ''Residual%'''  
--EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)=''6''  and Bundle_seq<=6 and Bundle_seq<>''Addon''  
--and Activityname like ''Residual%'''  
--EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)=''12''  and Bundle_seq<=12 and Bundle_seq<>''Addon''  
--and Activityname like ''Residual%'''  
--EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where Bundle_seq<=12 and bundle_code in (''3512'',''1912'',''1012'') and Bundle_seq<>''Addon''  
--and activityname like ''Residual%''  
--and iccid in (Select iccid from ##Mis_1717_USA_Detail_comm where Activityname like ''Plan_12M%'')'  
--EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where Portout_Status=''Portout'''  
EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'',''SIM_BLOCK'')'  
EXEC (@Sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where Portin_status in (''Lessthan_60_Portin'',''Lessthan_90_Portin'',  
''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'')  
and Convert(varchar(10),activitydate,120)>=''2023-06-12'''  
EXEC (@Sql)  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb..##Iccid_12month'') IS NOT NULL        
drop table ##Iccid_12month         
 Select Iccid,bundlecode,Count(*) cnt ,min(Topupseq) Min_topupseq into ##Iccid_12month from MIS_1717_BS_wrkard_master_dontdrop  
where convert(varchar(07),Topupdate,120)='''+@month+'''  
and bundlecode in (''1012'')  
group by Iccid,bundlecode having Count(*)=12'  
Exec (@sql)    
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where iccid in (select iccid from ##Iccid_12month ) and  activityname like ''Residual%'' '  
Exec (@sql)  
  
  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where (Wholesalerid in (''GLOBAL LINK'',''EAHASOLUTIONSINC'') or Offmgrid in (''GLOBAL LINK'',''EAHASOLUTIONSINC''))  
and Convert(varchar(10),activitydate,120)>=''2023-06-21'''  
Exec (@sql)  
  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where (Wholesalerid in (''BNK US'',''EK WIRELESS'') or Offmgrid in (''BNK US'',''EK WIRELESS''))  
and Convert(varchar(10),activitydate,120)>=''2023-08-11'''  
Exec (@sql)  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where (Wholesalerid in (''WIRELESSSHOP'') or Offmgrid in (''WIRELESSSHOP''))  
and Convert(varchar(10),activitydate,120)>=''2024-07-22'''  
Exec (@sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where Portin_status=''Lessthan_45_Portin'''  
--EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where Portindate is not null and activityname not in (''Bundle_1'',''Bundle_2'')'  
--EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'') and activityname not in (''Bundle_1'',''Bundle_2'')  
--and offmgrid not in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')'  
--EXEC (@Sql)  
  
--Thanusan oral communication for mobilecon and universal Preloaded has been removed from Sep'24 onwards  
  
Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
where RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'') and activityname not in (''Bundle_1'',''Bundle_2'')  
and isnull(offmgrid,'''') not in (''LMUS-PF-SIMLOCAL'',''LMPUS-SIM-PF-EPAYPAYSPOT'')'  
EXEC (@Sql)  
  
Set @Sql='Update ##Mis_1717_USA_Detail_comm set reseller_comm=0  
where activityname in (''Bundle_1'',''Bundle_2'')  
and isnull(resellerid,'''') not in (''LMPUS-SIM-PF-LI-TARGET'',''LMPUS-SIM-PF-TARGET'',''LMPUS-SIM-PF-LI-7ELEVEN'')'  
EXEC (@Sql)  
  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'') and activityname not in (''Bundle_1'',''Bundle_2'')  
--and offmgrid in (''LMPUS-SIM-PF-EPAYPAYSPOT'') and convert(varchar(10),activitydate,120)<''2024-10-14'''  
--EXEC (@Sql)  
  
        
Set @Sql='IF OBJECT_ID(''tempdb..##TopupCategory'') IS NOT NULL        
drop table ##TopupCategory        
select ISNULL(resellerid,'''')resellerid,ISNULL(Wholesalerid,'''')offmgrid,activityname, RES_T2M_FCA,RES_T2M_TP,RES_T2M_PER,RES_T2M_Type, RES_AS_TIER,RES_DC_TIER, RES_TIER,  
Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE ,   
case when activityname in (''Residual_12_AR'',''Residual_12_R'',''Residual_24_R'',''Residual_24_AR'') then SUM(BUNDLE_VALUE)    
else count(*)    
end cnt  ,SUM(reseller_comm)reseller_comm        
into ##TopupCategory  from ##Mis_1717_USA_Detail_comm        
where Convert(varchar(07),activitydate,120)  ='''+@month+'''    
group by ISNULL(resellerid,''''),ISNULL(Wholesalerid,''''),activityname, RES_T2M_FCA,RES_T2M_TP,RES_T2M_PER,RES_T2M_Type, RES_AS_TIER,RES_DC_TIER,RES_TIER,  
Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE'  
Exec (@sql)  
  
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MIS_1717_Pivot_category]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)                                                             
drop table MIS_1717_Pivot_category               
  
DECLARE @columns1 TABLE (COL varchar(50))         
declare @Col varchar(max)    
declare @id varchar(100)    
declare @columnscsv2 varchar(MAX)                
        
insert into @columns1                                  
select distinct activityname  from ##TopupCategory    order by activityname                              
        
select @columnscsv2 = COALESCE(@columnscsv2 + '],[','') + COL from @columns1                                  
set @columnscsv2 = '[' + @columnscsv2 + ']'                                  
select @columnscsv2  
        
SET @sql = 'SELECT resellerid,offmgrid, RES_T2M_FCA,RES_T2M_TP,RES_T2M_PER,RES_T2M_Type, RES_AS_TIER,RES_DC_TIER,RES_TIER,  
Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE , ' + @columnscsv2 + ' into  MIS_1717_Pivot_category FROM                                  
##TopupCategory                                  
PIVOT (SUM(cnt) for activityname in (' + @columnscsv2+ ')) as PVT   
order by resellerid,offmgrid, RES_T2M_FCA,RES_T2M_TP,RES_T2M_PER,RES_T2M_Type, RES_AS_TIER,RES_DC_TIER,RES_TIER,  
Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE  '                                  
            
print(@sql)         
exec(@sql)     
  
   
set @id=1    
while(@id<175)     
begin    
    
select @Col=Column_name from Mis_1717_KB_COLUMN_MASTER    
where ID=@id    

    
set @sql='    
if  (select COUNT(*) from dbo.syscolumns where id = object_id(''[MIS_1717_Pivot_category]'')    
AND NAME IN('''+@Col+''') )=0    
ALTER TABLE   MIS_1717_Pivot_category  Add '+@Col+' float'    
exec (@sql)    
set @id=@id+1    
end   
  
    
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Mis_1717_Pivot_category_comm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)                                                                             
drop table Mis_1717_Pivot_category_comm                               
                        
DECLARE @columns3 TABLE (COL varchar(50))                                                  
declare @columnscsv3 varchar(MAX)                              
                         
insert into @columns3                                                  
select distinct activityname  from ##TopupCategory    order by activityname              
                        
select @columnscsv3 = COALESCE(@columnscsv3 + '],[','') + COL from @columns3                                                  
set @columnscsv3 = '[' + @columnscsv3 + ']'                                                  
select @columnscsv3                  
                        
SET @sql = 'SELECT resellerid,offmgrid, ' + @columnscsv3 + ' into  Mis_1717_Pivot_category_comm FROM                                                  
##TopupCategory                                                  
PIVOT (SUM(reseller_comm) for activityname in (' + @columnscsv3+ ')) as PVT   
order by resellerid,offmgrid '                                                  
                            
print(@sql)                         
exec(@sql)         
         
set @id=1    
while(@id<175)     
begin    
    
select @Col=Column_name from Mis_1717_KB_COLUMN_MASTER    
where ID=@id    
    
set @sql='    
if  (select COUNT(*) from dbo.syscolumns where id = object_id(''[Mis_1717_Pivot_category_comm]'')    
AND NAME IN('''+@Col+''') )=0    
ALTER TABLE   Mis_1717_Pivot_category_comm  Add '+@Col+' float'    
exec (@sql)    
set @id=@id+1    
end    
  
  
--drop table ##arjun,##ArjunDev  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Arjun'') is not null  
Drop table ##Arjun  
  
Select A.Resellerid,A.offmgrid,a.RES_T2M_FCA,a.RES_T2M_TP,a.RES_T2M_PER,a.RES_T2M_Type,A.RES_AS_TIER,A.RES_DC_TIER,A.RES_TIER,  
A.Res_Bundle_1,A.Res_Activebase,A.RES_RESIDUAL_TIER,A.RES_T1M_FCA,A.RES_T1M_TP,A.RES_T1M_PER,A.RES_T1M_TYPE ,  
sum(isnull(a.plan_15_1,0)) as plan_15_1,sum(isnull(a.plan_15_2,0)) Plan_15_2,sum(isnull(a.plan_15_3,0)) Plan_15_3,sum(isnull(a.plan_15_4,0)) Plan_15_4,  
sum(isnull(a.plan_19_1,0)) as plan_19_1,sum(isnull(a.plan_19_2,0)) Plan_19_2,sum(isnull(a.plan_19_3,0)) Plan_19_3,sum(isnull(a.plan_19_4,0)) Plan_19_4,  
sum(isnull(a.plan_23_1,0)) as plan_23_1,sum(isnull(a.plan_23_2,0)) Plan_23_2,sum(isnull(a.plan_23_3,0)) Plan_23_3,sum(isnull(a.plan_23_4,0)) Plan_23_4,  
sum(isnull(a.plan_29_1,0)) as plan_29_1,sum(isnull(a.plan_29_2,0)) Plan_29_2,sum(isnull(a.plan_29_3,0)) Plan_29_3,sum(isnull(a.plan_29_4,0)) Plan_29_4,  
sum(isnull(a.plan_33_1,0)) as plan_33_1,sum(isnull(a.plan_33_2,0)) Plan_33_2,sum(isnull(a.plan_33_3,0)) Plan_33_3,sum(isnull(a.plan_33_4,0)) Plan_33_4,  
sum(isnull(a.plan_39_1,0)) as plan_39_1,sum(isnull(a.plan_39_2,0)) Plan_39_2,sum(isnull(a.plan_39_3,0)) Plan_39_3,sum(isnull(a.plan_39_4,0)) Plan_39_4,  
sum(isnull(a.plan_49_1,0)) as plan_49_1,sum(isnull(a.plan_49_2,0)) Plan_49_2,sum(isnull(a.plan_49_3,0)) Plan_49_3,sum(isnull(a.plan_49_4,0)) Plan_49_4,  
sum(isnull(a.plan_59_1,0)) as plan_59_1,sum(isnull(a.plan_59_2,0)) plan_59_2,sum(isnull(a.plan_59_3,0)) plan_59_3,sum(isnull(a.plan_59_4,0)) plan_59_4,  
sum(isnull(Plan_Ch29_1,0)) Plan_Ch29_1,sum(isnull(Plan_Ch29_2,0)) Plan_Ch29_2,sum(isnull(Plan_Ch29_3,0)) Plan_Ch29_3,sum(isnull(Plan_Ch29_4,0)) Plan_Ch29_4,  
sum(isnull(Plan_Ch49_1,0)) Plan_Ch49_1,sum(isnull(Plan_Ch49_2,0)) Plan_Ch49_2,sum(isnull(Plan_Ch49_3,0)) Plan_Ch49_3,sum(isnull(Plan_Ch49_4,0)) Plan_Ch49_4,  
sum(isnull(Plan_Ch59_1,0)) Plan_Ch59_1,sum(isnull(Plan_Ch59_2,0)) Plan_Ch59_2,sum(isnull(Plan_Ch59_3,0)) Plan_Ch59_3,sum(isnull(Plan_Ch59_4,0)) Plan_Ch59_4,  
SUM(isnull(a.portin_plan_15_4,0)) portin_plan_15_4,SUM(isnull(a.portin_plan_19_4,0)) portin_plan_19_4,SUM(isnull(a.portin_plan_23_4,0)) portin_plan_23_4,SUM(isnull(a.portin_plan_29_4,0)) portin_plan_29_4,SUM(isnull(a.portin_plan_33_4,0)) portin_plan_33_4,
  
SUM(isnull(a.portin_plan_39_4,0)) portin_plan_39_4,SUM(isnull(a.portin_plan_49_4,0)) portin_plan_49_4,SUM(isnull(a.Portin_Plan_59_4,0)) portin_plan_59_4,  
sum(isnull(a.portin_Plan_Ch29_4,0)) portin_Plan_Ch29_4,sum(isnull(portin_Plan_Ch49_4,0)) portin_Plan_Ch49_4,sum(isnull(portin_Plan_Ch59_4,0)) portin_Plan_Ch59_4,  
0 portin_plan_1012_4,0 portin_plan_1912_4,  
sum(isnull(a.residual_12_AR,0)) residual_12_AR,sum(isnull(a.residual_12_R,0)) residual_12_R,sum(isnull(a.residual_24_AR,0)) residual_24_AR,sum(isnull(a.residual_24_R,0))residual_24_R,  
sum(isnull(A.Bundle_1,0)) Bundle_1,sum(isnull(A.Bundle_2,0)) Bundle_2,sum(isnull(A.Plan_12M_1012_10,0))+0 Plan_12M_1  
into ##Arjun  
from Mis_1717_Pivot_category A  
Group by A.Resellerid,A.offmgrid,a.RES_T2M_FCA,a.RES_T2M_TP,a.RES_T2M_PER,a.RES_T2M_Type,A.RES_AS_TIER,A.RES_DC_TIER,A.RES_TIER,  
A.Res_Bundle_1,A.Res_Activebase,A.RES_RESIDUAL_TIER,A.RES_T1M_FCA,A.RES_T1M_TP,A.RES_T1M_PER,A.RES_T1M_TYPE '  
Exec (@sql)  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Arjundev'') is not null  
Drop table ##Arjundev  
Select A.Resellerid,A.offmgrid,  
sum(isnull(a.plan_15_1,0)) as plan_15_1,sum(isnull(a.plan_15_2,0)) Plan_15_2,sum(isnull(a.plan_15_3,0)) Plan_15_3,sum(isnull(a.plan_15_4,0)) Plan_15_4,  
sum(isnull(a.plan_19_1,0)) as plan_19_1,sum(isnull(a.plan_19_2,0)) Plan_19_2,sum(isnull(a.plan_19_3,0)) Plan_19_3,sum(isnull(a.plan_19_4,0)) Plan_19_4,  
sum(isnull(a.plan_23_1,0)) as plan_23_1,sum(isnull(a.plan_23_2,0)) Plan_23_2,sum(isnull(a.plan_23_3,0)) Plan_23_3,sum(isnull(a.plan_23_4,0)) Plan_23_4,  
sum(isnull(a.plan_29_1,0)) as plan_29_1,sum(isnull(a.plan_29_2,0)) Plan_29_2,sum(isnull(a.plan_29_3,0)) Plan_29_3,sum(isnull(a.plan_29_4,0)) Plan_29_4,  
sum(isnull(a.plan_33_1,0)) as plan_33_1,sum(isnull(a.plan_33_2,0)) Plan_33_2,sum(isnull(a.plan_33_3,0)) Plan_33_3,sum(isnull(a.plan_33_4,0)) Plan_33_4,  
sum(isnull(a.plan_39_1,0)) as plan_39_1,sum(isnull(a.plan_39_2,0)) Plan_39_2,sum(isnull(a.plan_39_3,0)) Plan_39_3,sum(isnull(a.plan_39_4,0)) Plan_39_4,  
sum(isnull(a.plan_49_1,0)) as plan_49_1,sum(isnull(a.plan_49_2,0)) Plan_49_2,sum(isnull(a.plan_49_3,0)) Plan_49_3,sum(isnull(a.plan_49_4,0)) Plan_49_4,  
sum(isnull(a.plan_59_1,0)) as plan_59_1,sum(isnull(a.plan_59_2,0)) plan_59_2,sum(isnull(a.plan_59_3,0)) plan_59_3,sum(isnull(a.plan_59_4,0)) plan_59_4,  
sum(isnull(Plan_Ch29_1,0)) Plan_Ch29_1,sum(isnull(Plan_Ch29_2,0)) Plan_Ch29_2,sum(isnull(Plan_Ch29_3,0)) Plan_Ch29_3,sum(isnull(Plan_Ch29_4,0)) Plan_Ch29_4,  
sum(isnull(Plan_Ch49_1,0)) Plan_Ch49_1,sum(isnull(Plan_Ch49_2,0)) Plan_Ch49_2,sum(isnull(Plan_Ch49_3,0)) Plan_Ch49_3,sum(isnull(Plan_Ch49_4,0)) Plan_Ch49_4,  
sum(isnull(Plan_Ch59_1,0)) Plan_Ch59_1,sum(isnull(Plan_Ch59_2,0)) Plan_Ch59_2,sum(isnull(Plan_Ch59_3,0)) Plan_Ch59_3,sum(isnull(Plan_Ch59_4,0)) Plan_Ch59_4,  
SUM(isnull(a.portin_plan_15_4,0)) portin_plan_15_4,SUM(isnull(a.portin_plan_19_4,0)) portin_plan_19_4,SUM(isnull(a.portin_plan_23_4,0)) portin_plan_23_4,SUM(isnull(a.portin_plan_29_4,0)) portin_plan_29_4,SUM(isnull(a.portin_plan_33_4,0)) portin_plan_33_4,
  
SUM(isnull(a.portin_plan_39_4,0)) portin_plan_39_4,SUM(isnull(a.portin_plan_49_4,0)) portin_plan_49_4,SUM(isnull(a.Portin_Plan_59_4,0)) portin_plan_59_4,  
sum(isnull(a.portin_Plan_Ch29_4,0)) portin_Plan_Ch29_4,sum(isnull(portin_Plan_Ch49_4,0)) portin_Plan_Ch49_4,sum(isnull(portin_Plan_Ch59_4,0)) portin_Plan_Ch59_4,  
0 portin_plan_1012_4,0 portin_plan_1912_4,  
sum(isnull(a.residual_12_AR,0)) residual_12_AR,sum(isnull(a.residual_12_R,0)) residual_12_R,sum(isnull(a.residual_24_AR,0)) residual_24_AR,sum(isnull(a.residual_24_R,0))residual_24_R,  
sum(isnull(A.Bundle_1,0)) Bundle_1,sum(isnull(A.Bundle_2,0)) Bundle_2,0+0 Plan_12M_1  
into ##ArjunDev  
from Mis_1717_Pivot_category_comm A  
Group by A.Resellerid,A.offmgrid'  
Exec (@sql)  
  
--Select * into Mis_1717_USA_Reseller_output_202210 from Mis_1717_USA_Reseller_output  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##Mis_1717_USA_Reseller_output'') is not null  
Drop table ##Mis_1717_USA_Reseller_output  
  
Select A.Resellerid,A.offmgrid,  
isnull(a.plan_15_1,0) plan_15_1,isnull(a.plan_15_2,0) Plan_15_2,isnull(a.plan_15_3,0) Plan_15_3,isnull(a.plan_15_4,0) Plan_15_4,  
isnull(A.Plan_19_1,0) Plan_19_1,isnull(A.Plan_19_2,0) Plan_19_2,isnull(A.Plan_19_3,0) Plan_19_3,isnull(A.Plan_19_4,0) Plan_19_4,  
isnull(A.Plan_23_1,0) Plan_23_1,isnull(A.Plan_23_2,0) Plan_23_2,isnull(A.Plan_23_3,0) Plan_23_3,isnull(A.Plan_23_4,0) Plan_23_4,  
isnull(A.Plan_29_1,0) Plan_29_1,isnull(A.Plan_29_2,0) Plan_29_2,isnull(A.Plan_29_3,0) Plan_29_3,isnull(A.Plan_29_4,0) Plan_29_4,  
isnull(A.Plan_33_1,0) Plan_33_1,isnull(A.Plan_33_2,0) Plan_33_2,isnull(A.Plan_33_3,0) Plan_33_3,isnull(A.Plan_33_4,0) Plan_33_4,  
isnull(A.Plan_39_1,0) Plan_39_1,isnull(A.Plan_39_2,0) Plan_39_2,isnull(A.Plan_39_3,0) Plan_39_3,isnull(A.Plan_39_4,0) Plan_39_4,  
isnull(A.Plan_49_1,0) Plan_49_1,isnull(A.Plan_49_2,0) Plan_49_2,isnull(A.Plan_49_3,0) Plan_49_3,isnull(A.Plan_49_4,0) Plan_49_4,  
isnull(A.Plan_59_1,0) Plan_59_1,isnull(A.Plan_59_2,0) Plan_59_2,isnull(A.Plan_59_3,0) Plan_59_3,isnull(A.Plan_59_4,0) Plan_59_4,  
isnull(A.Plan_Ch29_1,0) Plan_Ch29_1,isnull(A.Plan_Ch29_2,0) Plan_Ch29_2,isnull(A.Plan_Ch29_3,0) Plan_Ch29_3,isnull(A.Plan_Ch29_4,0) Plan_Ch29_4,  
isnull(A.Plan_Ch49_1,0) Plan_Ch49_1,isnull(A.Plan_Ch49_2,0) Plan_Ch49_2,isnull(A.Plan_Ch49_3,0) Plan_Ch49_3,isnull(A.Plan_Ch49_4,0) Plan_Ch49_4,  
isnull(A.Plan_Ch59_1,0) Plan_Ch59_1,isnull(A.Plan_Ch59_2,0) Plan_Ch59_2,isnull(A.Plan_Ch59_3,0) Plan_Ch59_3,isnull(A.Plan_Ch59_4,0) Plan_Ch59_4,  
isnull(a.portin_plan_15_4,0) portin_plan_15_4,  
isnull(A.Portin_Plan_19_4,0) Portin_Plan_19_4,  
isnull(A.Portin_Plan_23_4,0) Portin_Plan_23_4,  
isnull(A.Portin_Plan_29_4,0) Portin_Plan_29_4,  
isnull(A.Portin_Plan_33_4,0) Portin_Plan_33_4,  
isnull(A.Portin_Plan_39_4,0) Portin_Plan_39_4,  
isnull(A.Portin_Plan_49_4,0) Portin_Plan_49_4,  
isnull(A.Portin_Plan_59_4,0) Portin_Plan_59_4,  
isnull(a.portin_Plan_Ch29_4,0) portin_Plan_Ch29_4,isnull(A.portin_Plan_Ch49_4,0) portin_Plan_Ch49_4,isnull(A.portin_Plan_Ch59_4,0) portin_Plan_Ch59_4,  
isnull(A.Portin_Plan_1012_4,0) Portin_Plan_1012_4,  
isnull(A.Portin_Plan_1912_4,0) Portin_Plan_1912_4,  
isnull(A.Residual_12_R,0) Residual_12_R,isnull(A.Residual_12_AR,0) Residual_12_AR,isnull(A.Residual_24_R,0) Residual_24_R,isnull(A.Residual_24_AR,0) Residual_24_AR,  
isnull(A.Bundle_1,0) Bundle_1,isnull(A.Bundle_2,0) Bundle_2,isnull(A.Plan_12M_1,0) Plan_12M_1,  
isnull(B.Plan_15_1,0) +isnull(B.Plan_15_2,0) +isnull(B.Plan_15_3,0) +isnull(B.Plan_15_4,0)  Plan_15_comm,  
isnull(B.Plan_19_1,0) +isnull(B.Plan_19_2,0) +isnull(B.Plan_19_3,0) +isnull(B.Plan_19_4,0)  Plan_19_comm,  
isnull(B.Plan_23_1,0) +isnull(B.Plan_23_2,0) +isnull(B.Plan_23_3,0) +isnull(B.Plan_23_4,0)  Plan_23_comm,  
isnull(B.Plan_29_1,0) +isnull(B.Plan_29_2,0) +isnull(B.Plan_29_3,0) +isnull(B.Plan_29_4,0)  Plan_29_comm,  
isnull(B.Plan_33_1,0) +isnull(B.Plan_33_2,0) +isnull(B.Plan_33_3,0) +isnull(B.Plan_33_4,0)  Plan_33_comm,  
isnull(B.Plan_39_1,0) +isnull(B.Plan_39_2,0) +isnull(B.Plan_39_3,0) +isnull(B.Plan_39_4,0)  Plan_39_comm,  
isnull(B.Plan_49_1,0) +isnull(B.Plan_49_2,0) +isnull(B.Plan_49_3,0) +isnull(B.Plan_49_4,0)  Plan_49_comm,  
isnull(B.Plan_59_1,0) +isnull(B.Plan_59_2,0) +isnull(B.Plan_59_3,0) +isnull(B.Plan_59_4,0)  Plan_59_comm,  
isnull(B.plan_CH29_1,0)+isnull(B.plan_CH29_2,0)+isnull(B.plan_CH29_3,0)+isnull(B.plan_CH29_4,0)+  
isnull(B.plan_CH49_1,0)+isnull(B.plan_CH49_2,0)+isnull(B.plan_CH49_3,0)+isnull(B.plan_CH49_4,0)+  
isnull(B.plan_CH59_1,0)+isnull(B.plan_CH59_2,0)+isnull(B.plan_CH59_3,0)+isnull(B.plan_CH59_4,0) as family_Childplan_comm,  
isnull(B.Portin_Plan_15_4,0) +isnull(B.Portin_Plan_19_4,0) +isnull(B.Portin_Plan_23_4,0) +isnull(B.Portin_Plan_29_4,0) +isnull(B.Portin_Plan_33_4,0) +  
isnull(B.Portin_Plan_39_4,0) +isnull(B.Portin_Plan_49_4,0) +isnull(B.Portin_Plan_59_4,0) +  
isnull(B.Portin_Plan_1012_4,0)  +isnull(B.Portin_Plan_1912_4,0)+  
isnull(b.portin_plan_Ch29_4,0)+isnull(b.portin_plan_Ch49_4,0)+isnull(b.portin_plan_Ch59_4,0) Portin_Plan_comm,  
isnull(B.Residual_12_R,0) +isnull(B.Residual_12_AR,0) +isnull(B.Residual_24_R,0) +isnull(B.Residual_24_AR,0) Residual_comm,  
isnull(B.Bundle_1,0) +isnull(B.Bundle_2,0) Act_slab_comm,isnull(B.Plan_12M_1,0) Plan_12M_comm,0 Dealer_comm,  
isnull(B.Plan_15_1,0) +isnull(B.Plan_15_2,0) +isnull(B.Plan_15_3,0) +isnull(B.Plan_15_4,0)+  
isnull(B.Plan_19_1,0) +isnull(B.Plan_19_2,0) +isnull(B.Plan_19_3,0) +isnull(B.Plan_19_4,0)+  
isnull(B.Plan_23_1,0) +isnull(B.Plan_23_2,0) +isnull(B.Plan_23_3,0) +isnull(B.Plan_23_4,0)+  
isnull(B.Plan_29_1,0) +isnull(B.Plan_29_2,0) +isnull(B.Plan_29_3,0) +isnull(B.Plan_29_4,0)+  
isnull(B.Plan_33_1,0) +isnull(B.Plan_33_2,0) +isnull(B.Plan_33_3,0) +isnull(B.Plan_33_4,0)+  
isnull(B.Plan_39_1,0) +isnull(B.Plan_39_2,0) +isnull(B.Plan_39_3,0) +isnull(B.Plan_39_4,0)+  
isnull(B.Plan_49_1,0) +isnull(B.Plan_49_2,0) +isnull(B.Plan_49_3,0) +isnull(B.Plan_49_4,0)+  
isnull(B.Plan_59_1,0) +isnull(B.Plan_59_2,0) +isnull(B.Plan_59_3,0) +isnull(B.Plan_59_4,0)+  
isnull(B.plan_CH29_1,0)+isnull(B.plan_CH29_2,0)+isnull(B.plan_CH29_3,0)+isnull(B.plan_CH29_4,0)+  
isnull(B.plan_CH49_1,0)+isnull(B.plan_CH49_2,0)+isnull(B.plan_CH49_3,0)+isnull(B.plan_CH49_4,0)+  
isnull(B.plan_CH59_1,0)+isnull(B.plan_CH59_2,0)+isnull(B.plan_CH59_3,0)+isnull(B.plan_CH59_4,0)+  
--isnull(B.Portin_Plan_15_4,0) +isnull(B.Portin_Plan_19_4,0) +isnull(B.Portin_Plan_23_4,0) +isnull(B.Portin_Plan_29_4,0) +isnull(B.Portin_Plan_33_4,0) +  
--isnull(B.Portin_Plan_39_4,0) +isnull(B.Portin_Plan_49_4,0) +isnull(B.Portin_Plan_59_4,0) +  
--isnull(B.Portin_Plan_1012_4,0)+isnull(B.Portin_Plan_1912_4,0) +  
--+isnull(B.portin_plan_Ch29_4,0)+isnull(B.portin_plan_Ch49_4,0)+isnull(B.portin_plan_Ch59_4,0)  
isnull(B.Residual_12_R,0) +isnull(B.Residual_12_AR,0) +isnull(B.Residual_24_R,0) +isnull(B.Residual_24_AR,0) +  
isnull(B.Bundle_1,0) +isnull(B.Bundle_2,0) +isnull(B.Plan_12M_1,0) Total_comm,a.RES_T2M_FCA,a.RES_T2M_TP,a.RES_T2M_PER,a.RES_T2M_Type,A.RES_AS_TIER,A.RES_DC_TIER,A.RES_TIER RES_Type,  
A.Res_Bundle_1,A.Res_Activebase,A.RES_RESIDUAL_TIER,A.RES_T1M_FCA,A.RES_T1M_TP,A.RES_T1M_PER,A.RES_T1M_TYPE   
into ##Mis_1717_USA_Reseller_output  
from ##Arjun a, ##ArjunDev b  
where A.Resellerid=b.Resellerid  
and a.Offmgrid=b.Offmgrid'  
Exec (@sql)  
  
  
Set @Sql='Alter table ##Mis_1717_USA_Reseller_output Add IC float'  
Exec (@sql)  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##ins'') is not null  
Drop table ##ins  
select Resellerid,sum(retailer_comm) comm into ##ins from mis_1717_ins_comm  
where CONVERT(Varchar(07),Reportdate,120) = '''+@month+''' and Retailer_comm>0  
group by Resellerid'  Exec (@sql)  
  
  
Set @Sql='update a set a.ic=b.comm from ##Mis_1717_USA_Reseller_output a,##ins b  
where a.Resellerid=b.Resellerid'  
Exec (@sql)  
  
Set @Sql='update ##Mis_1717_USA_Reseller_output set ic=0 where ic is null'  
Exec (@sql)  
  
Set @Sql='IF OBJECT_ID(''Mis_1717_USA_Reseller_output'') IS NOT NULL        
Drop table Mis_1717_USA_Reseller_output  
  
Select * into Mis_1717_USA_Reseller_output from ##Mis_1717_USA_Reseller_output  
  
Select ''Reseller output''  
Select * from Mis_1717_USA_Reseller_output'  
Exec (@sql)  
  
Set @Sql='IF OBJECT_ID(''tempdb..##Arjundevan'') IS NOT NULL        
drop table ##Arjundevan        
  
select Offmgrid,Sum(Bundle_1) cnt,Res_DC_Tier,Res_t2m_type,  
 case when Res_DC_Tier=''Tier1'' then 3.  
   when Res_DC_Tier=''Tier2'' then 4.  
   when Res_DC_Tier=''Tier3'' then 5.  
   when Res_DC_Tier=''Tier4'' then 6.  
   when Res_DC_Tier=''Tier5'' then 7.  
   when Res_DC_Tier=''Tier6'' then 8.  
  
   --when Res_DC_Tier=''Tier1'' and Res_t2m_type=''Silver'' then 4.  
   --when Res_DC_Tier=''Tier2'' and Res_t2m_type=''Silver'' then 4.  
   --when Res_DC_Tier=''Tier3'' and Res_t2m_type=''Silver'' then 4.  
   --when Res_DC_Tier=''Tier4'' and Res_t2m_type=''Silver'' then 8.  
   --when Res_DC_Tier=''Tier5'' and Res_t2m_type=''Silver'' then 12.  
   --when Res_DC_Tier=''Tier6'' and Res_t2m_type=''Silver'' then 16.  
   end DealerLine_Value  
 into ##Arjundevan  
 from Mis_1717_USA_Reseller_output  
 group by Offmgrid,Res_DC_Tier,Res_t2m_type'  
Exec (@sql)  
  
  
Set @Sql='  

IF OBJECT_ID(''Mis_1717_USA_DEALERLINE_output'') IS NOT NULL        
Drop table Mis_1717_USA_DEALERLINE_output

Select ''Dealerline bonus''  
Select distinct a.Offmgrid, a.cnt bundle1,a.Res_DC_Tier,a.DealerLine_Value,(Round((a.cnt/1000.),0,-1))*a.DealerLine_Value*29 DealerlineBonus,b.Type INTO Mis_1717_USA_DEALERLINE_output  from ##Arjundevan a  
left join Mis_1717_USA_T2M_Res_mly b  
on a.offmgrid=b.Wholesalerid  
order by cnt desc'  
Exec (@sql)  
  
End

SELECT * INTO Mis_1717_USA_Reseller_output_REWORK_202511 FROM Mis_1717_USA_Reseller_output
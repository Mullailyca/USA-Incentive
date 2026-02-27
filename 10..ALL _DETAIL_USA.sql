        
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20230302>                         
-- Modify date: <20231009>                        
-- Description: <USA_KB_Retailer_output>                          
-- =============================================                          
ALTER  procedure MIS_1717_USA_07_Detail_report  
as   
begin  
  
  
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
  
Alter table ##Mis_1717_USA_Detail_comm add Ws_Exposure Varchar(100),HS_incentive varchar(100), HS_Exposure varchar(100)  
  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set WS_Exposure=''Hotspot Activation'',HS_incentive=''Yes''  
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_incentive=''No''  
where HS_incentive is null'  
EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
--''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
--EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Hotspot Sims''  
where Wholesalerid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'') and Ws_Exposure is null'  
EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where Wholesalerid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
--''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
--EXEC (@Sql)  
  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where isnull(noofmonths,0)>=''4''  
--and Activityname like ''Plan%4'''  
--EXEC (@Sql)  
  
  
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
--where Bundle_seq<=12 and bundle_code in (''1012'') and Bundle_seq<>''Addon''  
--and activityname like ''Residual%''  
--and iccid in (Select iccid from ##Mis_1717_USA_Detail_comm where Activityname like ''Plan_12M%'')'  
--EXEC (@Sql)  
  
Set @Sql='  
IF OBJECT_ID(''tempdb..##Iccid_12month'') IS NOT NULL        
drop table ##Iccid_12month         
 Select Iccid,bundlecode,Count(*) cnt ,min(Topupseq) Min_topupseq into ##Iccid_12month from MIS_1717_BS_wrkard_master_dontdrop  
where convert(varchar(07),Topupdate,120)='''+@month+'''  
and bundlecode in (''1012'')  
group by Iccid,bundlecode having Count(*)=12'  
Exec (@sql)    
  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''12monthplan''  
where  iccid in (select iccid from ##Iccid_12month ) and  activityname like ''Residual%'' and HS_Exposure is null and HS_incentive=''Yes'''  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''12monthplan''  
where  iccid in (select iccid from ##Iccid_12month ) and  activityname like ''Residual%'' and Ws_Exposure is null '  
EXEC (@Sql)  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where iccid in (select iccid from ##Iccid_12month ) and  activityname like ''Residual%'' '  
--Exec (@sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Portout''  
where Portout_Status=''Portout'' and HS_Exposure is null and HS_incentive=''Yes'''  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Portout''  
where Portout_Status=''Portout'' and Ws_Exposure is null '  
EXEC (@Sql)  
  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where Portout_Status=''Portout'''  
--EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''WS Mismatch activation''  
where Offmgrid<>wholesalerid and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Gateway Mismatch activation''  
where isnull(Gateway_Offmgr,Wholesalerid)<>Wholesalerid and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''WS Closed activation''  
where (Wholesalerid in (''GLOBAL LINK'',''EAHASOLUTIONSINC'') or Offmgrid in (''GLOBAL LINK'',''EAHASOLUTIONSINC''))  
and Convert(varchar(10),activitydate,120)>=''2023-06-21'' and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''WS Closed activation''  
where (Wholesalerid in (''BNK US'',''EK WIRELESS'') or Offmgrid in (''BNK US'',''EK WIRELESS''))  
and Convert(varchar(10),activitydate,120)>=''2023-08-11'' and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''WS Closed activation''  
where (Wholesalerid in (''WIRELESSSHOP'') or Offmgrid in (''WIRELESSSHOP''))  
--and Convert(varchar(10),activitydate,120)>=''2024-07-22'''  
EXEC (@Sql)  
  
  
--Set @Sql='Delete from ##Mis_1717_USA_Detail_comm  
--where (Wholesalerid in (''WIRELESSSHOP'') or Offmgrid in (''WIRELESSSHOP''))  
--and Convert(varchar(10),activitydate,120)>=''2024-07-22'''  
--Exec (@sql)  
  
  
--Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Lessthan_180_Portin''  
--where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'',''Lessthan_60_Portin'',''Lessthan_90_Portin'',  
--''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'') and Ws_Exposure is null'  
--EXEC (@Sql)  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Lessthan_45_Portin''  
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'') and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Lessthan_45_Portin''  
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'') and HS_Exposure is null and HS_incentive=''Yes'''  
EXEC (@Sql)  
  
--Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Spl for residual''  
--where activityname in (''Residual_12_AR'',''Residual_12_R'')  
--and bundle_code in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype in (''Plan_29'',''Plan_33'',''Plan_49''))  
--and bundle_seq in (''5'',''6'')'  
--EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Lessthan_180_Portin After 20230611''  
where Portin_status in (''Lessthan_60_Portin'',''Lessthan_90_Portin'',  
''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'')   
and Convert(varchar(10),activitydate,120)>=''2023-06-12''and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Lessthan_180_Portin After 20230611''  
where Portin_status in (''Lessthan_60_Portin'',''Lessthan_90_Portin'',  
''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'')   
and Convert(varchar(10),activitydate,120)>=''2023-06-12''and HS_Exposure is null and HS_incentive=''Yes''  
and activityname like ''%Portin%'''  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Portin will be paid after 4months''  
where activityname like ''Portin%'' and Ws_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Portin will be paid after 4months''  
where activityname like ''Portin%'' and HS_Exposure is null'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''lessthan 3 activation''  
where RET_T1M_TYPE =''<3'' and activityname like ''Residual%'''  
EXEC (@Sql)  
  
  
--Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Preloaded_sims''  
--where  Ws_Exposure is null and RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'')  and activityname not in (''Bundle_1'',''Bundle_2'')  
--and offmgrid not in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')'  
--EXEC (@Sql)  
  
---Thanusan Sep'24 onwards  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''Preloaded_sims''  
where  Ws_Exposure is null and RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'')  and activityname not in (''Bundle_1'',''Bundle_2'')  
and isnull(offmgrid,'''') not in (''LMUS-PF-SIMLOCAL'',''LMPUS-SIM-PF-EPAYPAYSPOT'')'  
EXEC (@Sql)  
  
Set @Sql='Update ##Mis_1717_USA_Detail_comm set reseller_comm=0  
where activityname in (''Bundle_1'',''Bundle_2'')  
and isnull(resellerid,'''') not in (''LMPUS-SIM-PF-LI-TARGET'',''LMPUS-SIM-PF-TARGET'',''LMPUS-SIM-PF-LI-7ELEVEN'')'  
EXEC (@Sql)  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Preloaded_sims''  
where HS_Exposure is null and HS_incentive=''Yes'' and RES_TIER in (''NI'',''LI'',''DP'',''TP'',''NI_WS'')  and activityname not in (''Bundle_1'',''Bundle_2'')'  
EXEC (@Sql)  
  
  
Set @Sql='update ##Mis_1717_USA_Detail_comm set HS_Exposure=''Not Eligible_HS''  
where HS_Exposure is null  and HS_incentive=''Yes''  
and Resellerid in (''LMPUS-SIM-ST-LI-TX-ELPASO'',''LMPUS-SIM-SM-HEADOFFICE'',''LMPUS-SIM-OF-TESTING'',''LMPUS-SIM-ON-HEADOFFICE'')'  
Exec (@sql)  
  
------------------------------------------------------------------------------------------------------------------------------------
Set @Sql='update ##Mis_1717_USA_Detail_comm set Ws_Exposure=''SIM_BLOCK''  
where Portin_status =''SIM_BLOCK'' and Ws_Exposure is null'  
EXEC (@Sql) 

Set @Sql='update ##Mis_1717_USA_Detail_comm set Hs_Exposure=''SIM_BLOCK''  
where Portin_status =''SIM_BLOCK'' and Hs_Exposure is null'  
EXEC (@Sql) 

-------------------------------------------------------------------------------------------------------------------------------------
  
Set @Sql='IF OBJECT_ID(''Mis_1717_USA_DETAIL_'+@month1+''') IS NOT NULL        
Drop table Mis_1717_USA_DETAIL_'+@month1+'  
  
select iccid,activityname,activitydate,resellerid,offmgrid,accmgrid,hotspotid,retailerid,INI_facevalue as simfacevalue,FREEMIN,discount as simdiscount,  
bundle_seq,BUNDLE_CODE,BUNDLE_NAME,BUNDLE_VALUE,RESELLER_COMM,RETAILER_COMM,res_tier reseller_tag,RET_TIER,res_t2m_type comm_category,wholesalerid,  
Portin_status,Portout_status,Noofmonths,Portindate,Portoutdate,Gateway_offmgr,Ws_Exposure,HS_incentive,HS_Exposure,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE , Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE ,Comm_type  
into Mis_1717_USA_DETAIL_'+@month1+' from ##Mis_1717_USA_Detail_comm '  
Exec (@sql)  
  
--select distinct bundle_seq from Mis_1717_USA_Detail_comm where activityname like '%RESIDUAL%'  
  
Set @Sql='alter table Mis_1717_USA_DETAIL_'+@month1+' add msisdn varchar(100)'  
Exec (@sql)  
  
Set @Sql='IF OBJECT_ID(''tempdb.dbo.##base1'') IS NOT NULL        
Drop table ##base1  
select distinct iccid into ##base1 from Mis_1717_USA_DETAIL_'+@month1+' '  
Exec (@sql)  
  
Set @Sql='alter table ##base1 add msisdn varchar(100)'  
Exec (@sql)  
  
Set @Sql='update a set a.msisdn=b.msisdn from ##base1 a,MIS_1717_BS_wrkard_master_dontdrop b  
where a.iccid=b.iccid'  
Exec (@sql)  
  
Set @Sql='update a set a.msisdn=b.msisdn from Mis_1717_USA_DETAIL_'+@month1+' a,##base1 b  
where a.iccid=b.iccid'  
Exec (@sql)  
  
Set @Sql='Alter table Mis_1717_USA_DETAIL_'+@month1+' add WS_Final varchar(100),HS_Final varchar(100)'  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set WS_Final=''Eligible''  
where Ws_Exposure is null'  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set HS_Final=''Eligible''  
where HS_Exposure is null  and HS_incentive=''Yes'''  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set Ws_Final=''Paid after 4months''  
where Ws_Exposure=''Portin will be paid after 4months'' '  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set HS_Final=''Paid after 4months''  
where Hs_Exposure=''Portin will be paid after 4months''  and HS_incentive=''Yes'''  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set Ws_Final=''Not Eligible''  
where Ws_Final is null'  
Exec (@sql)  
  
Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set Hs_Final=''Not Eligible''  
where Hs_Final is null  and HS_incentive=''Yes'''  
--Exec (@sql)  
--Set @Sql='update Mis_1717_USA_DETAIL_'+@month1+' set Hs_Final=''Not Eligible_HS''  
--where Hs_Final is null  and HS_incentive=''Yes''  
--and Resellerid in (''LMPUS-SIM-ST-LI-TX-ELPASO'',''LMPUS-SIM-SM-HEADOFFICE'',''LMPUS-SIM-OF-TESTING'',''LMPUS-SIM-ON-HEADOFFICE'')'  
--Exec (@sql)  
  

  
Set @Sql='

IF OBJECT_ID(''MIS_1001_RET_DETAIL_OUTPUT'') IS NOT NULL        
Drop table MIS_1001_RET_DETAIL_OUTPUT  
SELECT ''RETAILER OUTPUT''

select msisdn,iccid,activityname,activitydate,resellerid,offmgrid,accmgrid,hotspotid,retailerid,simfacevalue as simfacevalue,FREEMIN,simdiscount as simdiscount,  
bundle_seq,BUNDLE_CODE,BUNDLE_NAME,BUNDLE_VALUE,RESELLER_COMM,RETAILER_COMM,reseller_tag reseller_tag,RET_TIER,comm_category comm_category,wholesalerid,  
Portin_status,Portout_status,Noofmonths,Portindate,Portoutdate,Gateway_offmgr,Ws_Exposure,Ws_Final,Hs_incentive,Hs_Exposure,Hs_Final,  
Ret_Bundle_1,Ret_Activebase,RET_RESIDUAL_TIER,RET_T1M_FCA,RET_T1M_TP,RET_T1M_PER,RET_T1M_TYPE , Res_Bundle_1,Res_Activebase,RES_RESIDUAL_TIER,RES_T1M_FCA,RES_T1M_TP,RES_T1M_PER,RES_T1M_TYPE 
INTO MIS_1001_RET_DETAIL_OUTPUT
From Mis_1717_USA_DETAIL_'+@month1+'   
where ACTIVITYNAME<>''Activation''  
order by ACTIVITYDATE,ACTIVITYNAME'  
Exec (@sql)  
  
Set @Sql='Alter table Mis_1717_USA_DETAIL_'+@month1+' add authdate datetime'  
Exec (@sql)  
  
Set @Sql='IF OBJECT_ID(''tempdb..##Arjundev'') IS NOT NULL        
drop table ##Arjundev        
Select * into ##Arjundev from MVNOREPORT_USA_LM.dbo.vw_trnactivation   
where convert(varchar(10),authdate,120)>=''2022-10-12''  
and (resellerid like ''%-TP-%'' or resellerid like ''%-DP-%'' or resellerid like ''%-LI-%'')  
  
Create index id1 on ##Arjundev(iccid_fr,iccid_to)'  
Exec (@sql)  
  
Set @Sql='Update Mis_1717_USA_DETAIL_'+@month1+' set authdate=b.authdate  
From Mis_1717_USA_DETAIL_'+@month1+' a, ##Arjundev b  
where left(a.iccid,11) between b.iccid_fr and b.iccid_to'  
Exec (@sql)  
  
Set @Sql='

IF OBJECT_ID(''MIS_1001_RES_DETAIL_OUTPUT'') IS NOT NULL        
Drop table MIS_1001_RES_DETAIL_OUTPUT 

SELECT '' RESELLER OUTPUT''

Select Wholesalerid,Resellerid,Activityname,Activitydate,authdate,Bundle_code,Bundle_name,Comm_category,Msisdn,iccid,Ws_Exposure,Ws_Final 
INTO MIS_1001_RES_DETAIL_OUTPUT
from Mis_1717_USA_DETAIL_'+@month1+'  
where authdate is  not null and Ws_Exposure is  null  
and Activityname like ''Plan%'''  
Exec (@sql)  
  
End  







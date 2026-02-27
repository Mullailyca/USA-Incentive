        
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20231002>                         
-- Modify date: <>                        
-- Description: <USA_KB_T1M>                          
-- =============================================                          
alter  procedure MIS_1717_USA_03_T1M_BASE_Res  
as   
begin  
  
--Sp_rename 'Mis_1717_USA_T1M_Res_mly','Mis_1717_USA_T1M_Res_mly_202507'  
  
Declare @Sql varchar(max)  
Declare @month Varchar(10)  
Declare @month1 Varchar(10)  
Declare @month2 Varchar(10)  
Declare @month3 Varchar(10)  
Declare @Year Varchar(4)  
Declare @MM Varchar(2)  
  
Set @month=convert(varchar(07),Dateadd(mm,-1,Getdate()),120)   
Set @month1=convert(varchar(06),Dateadd(mm,-1,Getdate()),112)   
Set @month2=convert(varchar(07),Dateadd(mm,-2,Getdate()),120)   
Set @month3=convert(varchar(07),Dateadd(mm,-3,Getdate()),120)   
Set @Year=convert(varchar(04),Dateadd(mm,-1,Getdate()),112)   
Set @MM=right((convert(varchar(06),Dateadd(mm,-1,Getdate()),112)),2)  
  
Select @month,@month1,@Year,@MM,@month2,@month3  
  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_T1M_'+@month1+''') is not null  
Drop table Mis_1717_USA_T1M_'+@month1+'  
select Topupseq,Msisdn,iccid,Topupdate,face_value,Bundlecode,payment_mode,bundle_name,Bundlevalue,RRBS_iccid,RRBS_Transaction_Id  
into Mis_1717_USA_T1M_'+@month1+'  
from [MIS_1717_BS_wrkard_master_dontdrop]  
where topupseq=''1''  
and convert(varchar(07),topupdate,120)='''+@month2+''''  
Exec (@sql)  
  
Set @Sql='Delete from Mis_1717_USA_T1M_'+@month1+'  
where bundlecode in (''1005'',''681005'')'  
Exec (@sql)  
  
--Set @Sql='  
--IF OBJECT_ID(''tempdb.dbo.##POS'') is not null  
--Drop table ##POS   
  
--select iccid,max(activationdate) activationdate into ##POS from IS_USA.mvno_usa.dbo.TopupBundle_Commission_detailed  
--where  cons_bundletype=''ACT''  
--and convert(varchar(7),activationdate,120)>=''2020-08''  
--and Retailerid is not null  
--group by iccid'  
--Exec (@sql)  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##POS'') is not null  
Drop table ##POS   
  
select iccid,max(activationdate) activationdate into ##POS from mvno_usa.dbo.TopupBundle_Commission_detailed  
where  TopupSeq=''1''  
and convert(varchar(7),activationdate,120)>=''2020-08''  
and Retailerid is not null  
group by iccid'  
Exec (@sql)  
  
--Set @Sql='  
--insert into ##POS  
--select iccid,max(activationdate) activationdate  from IS_USA.mvno_usa.dbo.TopupBundle_Commission_detailed  
--where  TopupSeq=''1''  
--and convert(varchar(7),activationdate,120)>=''2020-08''  
--and iccid not in (select iccid from ##POS)  
--and Retailerid is not null  
--group by iccid'  
--Exec (@sql)  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##POS1'') is not null  
Drop table ##POS1   
Select A.iccid,A.Retailerid,A.activationdate,A.OffMgrID,  
a.hotspotid,a.accmgrid into ##POS1 from mvno_usa.dbo.TopupBundle_Commission_detailed a,##POS b  
where a.iccid=b.iccid  
and a.activationdate=b.activationdate'  
Exec (@sql)  

set @sql='
update a
set a.retailerid=b.retailerid,a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from ##POS1 a,mis_1717_ins_comm_staff_mapping b
where a.retailerid=b.USERID
'
Exec (@sql)
  
Set @Sql='Alter Table Mis_1717_USA_T1M_'+@month1+'  
Add  
Resellerid varchar(70),  
Offmgrid varchar(70),  
accmgrid varchar(70),  
hotspotid varchar(70),  
retailerid varchar(70),  
Wholesalerid varchar(70),  
Topup_status varchar(10),  
Gateway varchar(70),  
Gateway_Offmgr varchar(70)'  
Exec (@sql)  
  
Set @Sql='update a              
set a.OffMgrID=b.OffMgrID,  
a.hotspotid=b.hotspotid,  
a.accmgrid=b.accmgrid,  
a.retailerid=b.retailerid             
from Mis_1717_USA_T1M_'+@month1+' a join ##POS1 b              
on a.iccid=b.iccid'  
Exec (@sql)  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##res'') is not null  
Drop table ##res  
select * into ##res from mvno_usa.dbo.trnactivation'  
Exec (@sql)  
  
Set @Sql='Create index id1 on ##res(iccid_fr,iccid_to)'  
Exec (@sql)  
  
--Set @Sql='  
--IF OBJECT_ID(''tempdb.dbo.##off'') is not null  
--Drop table ##off   
--select * into ##off from USA_ACC.mvno_usa.dbo.dsm_offmgr_trnactivation'  
--Exec (@sql)   
  
--Set @Sql='Create index id1 on ##off(iccid_fr,iccid_to)'  
--Exec (@sql)   
  
Set @Sql='update a        
set a.Resellerid=b.Resellerid   
from Mis_1717_USA_T1M_'+@month1+' a join ##res b        
on LEFT(a.iccid,11) between b.iccid_fr and b.iccid_to'  
Exec (@sql)    
  
Set @Sql='update a              
set a.Wholesalerid=b.OffMgrID              
from Mis_1717_USA_T1M_'+@month1+' a join MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b              
on a.resellerid=b.resellerid'  
Exec (@sql)   
  
Set @Sql='update a              
set a.OffMgrID=b.OffMgrID              
from Mis_1717_USA_T1M_'+@month1+' a join MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b              
on a.resellerid=b.resellerid  
and a.offmgrid is not null'  
Exec (@sql)   
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##ITG'') is not null  
Drop table ##ITG  
Select Substring(Iccid,8,12) Iccid,Realmsisdn,Paymentchannel,Processeddate,Wholesalerid,Retailerid  
into ##ITG  
from USA_ACC.mvno_usa.dbo.TrnSimActivationWithBundlePurchaseandPortIn  
where Convert(varchar(07),processeddate,120)>=''2023-03''  
and status=''5'' and voucherpin=''0''  
order by Channel'  
Exec (@sql)  
  
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+' set Gateway=b.Paymentchannel  
from Mis_1717_USA_T1M_'+@month1+' a,##ITG b  
where a.iccid=b.iccid'  
Exec (@sql)  
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+' set Gateway_Offmgr=   
Case when Gateway=''ENKWIR'' then ''EK WIRELESS''  
when Gateway=''EMIDA'' then ''LMUS-PF-EMIDA''  
when Gateway=''BNK'' then ''BNK US''  
when Gateway=''WIRELESSSHOP'' then ''WIRELESSSHOP''  
when Gateway=''PREPAY'' then ''Prepay Nation LLC''  
when Gateway=''GLOBAL'' then ''GLOBAL LINK''  
when Gateway=''EAHA'' then ''EAHASOLUTIONSINC''  
when Gateway=''A1WS1'' then ''AFZALTRADING''  
when Gateway=''EPAY'' then ''LMUS-PF-EPAY''  
when Gateway=''SIMMD'' then ''LMUS-WS-UNIVERSAL LLC''  
when Gateway=''SIMMD_NEW'' then ''LMUS-WS-UNIVERSAL LLC''  
End'  
Exec (@sql)  
  
  
  
Set @Sql='update Mis_1717_USA_T1M_'+@month1+' set OffMgrID=Gateway_Offmgr,Wholesalerid=Gateway_Offmgr  
where Gateway_Offmgr is not null'  
Exec (@sql)  
  
Set @Sql='Delete from Mis_1717_USA_T1M_'+@month1+'  
where Wholesalerid<>OffMgrID'  
Exec (@sql)  
  
Set @Sql='Delete from Mis_1717_USA_T1M_'+@month1+'  
where Wholesalerid<>Gateway_Offmgr  
and Gateway_Offmgr is not null'  
Exec (@sql)  
  
Set @Sql='Delete from Mis_1717_USA_T1M_'+@month1+'  
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
  
Set @Sql='  
IF OBJECT_ID(''tempdb.dbo.##deva'') is not null  
Drop table ##deva   
select iccid,bundlecode  
into ##deva  
from [MIS_1717_BS_wrkard_master_dontdrop]  
where topupseq>=''2''  
and iccid in (select iccid from Mis_1717_USA_T1M_'+@month1+')  
and convert(varchar(07),topupdate,120) between '''+@month2+''' and '''+@month+''''  
Exec (@sql)   
  
Set @Sql='Delete from ##deva  
where bundlecode in (''1005'',''681005'')'  
Exec (@sql)  
  
  
Set @Sql='Alter Table ##deva  
Add  
Resellerid varchar(70),  
Offmgrid varchar(70),  
accmgrid varchar(70),  
hotspotid varchar(70),  
retailerid varchar(70),  
Wholesalerid varchar(70),  
Topup_status varchar(10),  
Gateway varchar(70),  
Gateway_Offmgr varchar(70)'  
Exec (@sql)  
  
Set @Sql='update a              
set a.OffMgrID=b.OffMgrID,  
a.hotspotid=b.hotspotid,  
a.accmgrid=b.accmgrid,  
a.retailerid=b.retailerid             
from ##deva a join ##POS1 b              
on a.iccid=b.iccid'  
Exec (@sql)  
  
  
Set @Sql='update a        
set a.Resellerid=b.Resellerid   
from ##deva a join ##res b        
on LEFT(a.iccid,11) between b.iccid_fr and b.iccid_to'  
Exec (@sql)    
  
Set @Sql='update a              
set a.Wholesalerid=b.OffMgrID                    
from ##deva a join MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b              
on a.resellerid=b.resellerid'  
Exec (@sql)   
  
Set @Sql='update a              
set a.OffMgrID=b.OffMgrID                       
from ##deva a join MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b              
on a.resellerid=b.resellerid  
and a.OffMgrID is null'  
Exec (@sql)   
  
  
Set @Sql='Update ##deva set Gateway=b.Paymentchannel  
from ##deva a,##ITG b  
where a.iccid=b.iccid'  
Exec (@sql)  
  
Set @Sql='Update ##deva set Gateway_Offmgr=   
Case when Gateway=''ENKWIR'' then ''EK WIRELESS''  
when Gateway=''EMIDA'' then ''LMUS-PF-EMIDA''  
when Gateway=''BNK'' then ''BNK US''  
when Gateway=''WIRELESSSHOP'' then ''WIRELESSSHOP''  
when Gateway=''PREPAY'' then ''Prepay Nation LLC''  
when Gateway=''GLOBAL'' then ''GLOBAL LINK''  
when Gateway=''EAHA'' then ''EAHASOLUTIONSINC''  
when Gateway=''A1WS1'' then ''AFZALTRADING''  
when Gateway=''EPAY'' then ''LMUS-PF-EPAY''  
when Gateway=''SIMMD'' then ''LMUS-WS-UNIVERSAL LLC''  
when Gateway=''SIMMD_NEW'' then ''LMUS-WS-UNIVERSAL LLC''  
End'  
Exec (@sql)  
  
Set @Sql='update ##deva set OffMgrID=Gateway_Offmgr,Wholesalerid=Gateway_Offmgr  
where Gateway_Offmgr is not null'  
Exec (@sql)  
  
Set @Sql='Delete from ##deva  
where Wholesalerid<>OffMgrID'  
Exec (@sql)  
  
Set @Sql='Delete from ##deva  
where Wholesalerid<>Gateway_Offmgr  
and Gateway_Offmgr is not null'  
Exec (@sql)  
  
  
Set @Sql='Delete from ##deva  
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',  
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'  
EXEC (@Sql)  
  
Set @Sql='update Mis_1717_USA_T1M_'+@month1+' set Topup_status=''Yes''  
from Mis_1717_USA_T1M_'+@month1+' a,##deva b  
where a.iccid=b.iccid'  
Exec (@sql)   
  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_T1M_'+@month1+'_Res'') is not null  
Drop table Mis_1717_USA_T1M_'+@month1+'_Res  
Select Wholesalerid ,Count(iccid) FCA,Count(Topup_status) TS  
into Mis_1717_USA_T1M_'+@month1+'_Res  
from Mis_1717_USA_T1M_'+@month1+'  
--where resellerid not like ''%-NI-%''  
group by Wholesalerid'  
Exec (@sql)   
  
Set @Sql='Alter table Mis_1717_USA_T1M_'+@month1+'_Res Add T1M float,Type Varchar(20)'  
Exec (@sql)   
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set T1M=round(cast(TS as float)/Cast(FCA as float),4)*100'  
Exec (@sql)    
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set Type=''Platinum''  
where T1M>=70'  
Exec (@sql)   
  
--Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set Type=''Gold''  
--where T1M between 40 and 49.99'  
--Exec (@sql)   
  
--Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set Type=''Silver''  
--where T1M between 30 and 39.99'  
--Exec (@sql)   
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set Type=''Silver''  
where T1M<70'  
Exec (@sql)   
  
Set @Sql='Update Mis_1717_USA_T1M_'+@month1+'_Res set Type=''<2000''  
where FCA<2000'  
Exec (@sql)   
  
  
Set @Sql='Alter table Mis_1717_USA_T1M_'+@month1+' Add T1M_FCA float,T1M_TP float,T1M_PER float,T1M_Type Varchar(20)'  
Exec (@sql)   
  
Set @Sql='update Mis_1717_USA_T1M_'+@month1+' set T1M_FCA=b.FCA,T1M_TP=b.Ts,T1M_PER=b.T1M,T1M_Type=b.Type  
from Mis_1717_USA_T1M_'+@month1+' a,Mis_1717_USA_T1M_'+@month1+'_Res b  
where a.Wholesalerid=b.Wholesalerid'  
Exec (@sql)   
  
--select Distinct Offmgrid,T1M_FCA,T1M_TP,T1M_PER,T1M_Type from Mis_1717_USA_T1M_'+@month1+'  
--order by T1M_PER desc  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_T1M_Res_mly'') is not null  
Drop table Mis_1717_USA_T1M_Res_mly  
Select * into Mis_1717_USA_T1M_Res_mly from Mis_1717_USA_T1M_'+@month1+'_Res  
  
Select * from Mis_1717_USA_T1M_'+@month1+'_Res'  
Exec (@sql)   
  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_T1M_'+@month1+'_Final'') is not null  
Drop table Mis_1717_USA_T1M_'+@month1+'_Final  
Select distinct Resellerid,T1M_FCA,T1M_TP,T1M_PER,T1M_type  into Mis_1717_USA_T1M_'+@month1+'_Final from Mis_1717_USA_T1M_'+@month1+''  
Exec (@sql)   
  
Set @Sql='  
IF OBJECT_ID(''Mis_1717_USA_T1M_Res_mly_'+@month1+''') is not null  
Drop table Mis_1717_USA_T1M_Res_mly_'+@month1+'  
  
Select * into Mis_1717_USA_T1M_Res_mly_'+@month1+' from Mis_1717_USA_T1M_Res_mly'  
Exec (@sql)  
  
END  
  
  
Select * from Mis_1717_USA_T1M_Res_mly  
  
  
  
  
  
  
  
  
  
  
  
  
  
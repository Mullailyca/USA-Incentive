                
-- =============================================                                    
-- Author:  <Arjundev>                                    
-- Create date: <20230302>                                   
-- Modify date: <>                                  
-- Description: <USA_KB_Detail>                                    
-- =============================================                                    
ALTER   procedure MIS_1717_USA_04_Detail_nolive            
as             
begin            
            
--Sp_rename 'Mis_1717_USA_FCA','Mis_1717_USA_FCA_202507'            
Declare @Sql varchar(max)            
Declare @month Varchar(10)            
Declare @month1 Varchar(10)            
Declare @month3 Varchar(10)            
Declare @month4 Varchar(10)            
Declare @month7 Varchar(10)            
Declare @month30 Varchar(10)            
Declare @Year Varchar(4)            
Declare @MM Varchar(2)            
Declare @Lastday Datetime            
            
Set @month=convert(varchar(07),Dateadd(mm,-1,Getdate()),120)             
Set @month1=convert(varchar(06),Dateadd(mm,-1,Getdate()),112)             
Set @month3=convert(varchar(07),Dateadd(mm,-3,Getdate()),120)            
Set @month4=convert(varchar(07),Dateadd(mm,-4,Getdate()),120)             
Set @month7=convert(varchar(07),Dateadd(mm,-7,Getdate()),120)             
Set @month30=convert(varchar(07),Dateadd(mm,-30,Getdate()),120)             
Set @Year=convert(varchar(04),Dateadd(mm,-1,Getdate()),112)             
Set @MM=right((convert(varchar(06),Dateadd(mm,-1,Getdate()),112)),2)            
set @Lastday=convert(varchar(10),(DATEADD(MM,DATEDIFF(MM, 1, Getdate()),-1)),120)            
            
Select @month month,@month1 month1,@Year Year,@MM MM,@month3 month3,@month4 month4,@month7 month7,@month30 month30,@Lastday Lastday            
            
Set @Sql='            
IF OBJECT_ID(''Mis_1717_USA_FCA'') is not null            
Drop table Mis_1717_USA_FCA            
            
select Topupseq,Msisdn,iccid,Topupdate,face_value,Bundlecode,payment_mode,bundle_name,Bundlevalue,RRBS_iccid,RRBS_Transaction_Id            
Into Mis_1717_USA_FCA            
from [MIS_1717_BS_wrkard_master_dontdrop]            
where topupseq=''1''            
and convert(varchar(07),topupdate,120) between '''+@month30+''' and  '''+@month+''''            
Exec (@sql)            
            
Set @Sql='            
Alter Table Mis_1717_USA_FCA            
Add            
Resellerid varchar(70),            
Offmgrid varchar(70),            
Accmgrid varchar(70),            
Hotspotid varchar(70),            
Retailerid varchar(70),            
Authdate_ret datetime,            
Initial_bundlecode varchar(10),            
Ini_facevalue float,            
Freemin float,            
Discount float,            
Noofmonths varchar(10)
'            
Exec (@sql)            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##res'') is not null            
Drop table ##res            
select * into ##res from mvno_usa.dbo.trnactivation'            
Exec (@sql)            
            
Set @Sql='Create index id1 on ##res(iccid_fr,iccid_to)'            
Exec (@sql)            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##Trnbundlecost'') is not null            
Drop table ##Trnbundlecost            
select * into ##Trnbundlecost from mvno_usa.dbo.TRNACTIVATIONBUNDLECOST'            
Exec (@sql)            
            
Set @Sql='Create index id7 on ##Trnbundlecost(Activateid)'            
Exec (@sql)            
            
Set @Sql='Alter table ##res add noofmonths varchar(10)'            
Exec (@sql)            
            
Set @Sql='Update ##res set noofmonths=b.noofmonths            
from ##res a, ##Trnbundlecost b            
where a.Activateid=b.Activateid'            
Exec (@sql)            
            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##off'') is not null    
Drop table ##off             
select * into ##off from mvno_usa.dbo.dsm_offmgr_trnactivation'            
Exec (@sql)             
            
Set @Sql='Create index id1 on ##off(iccid_fr,iccid_to)'            
Exec (@sql)             
            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##Acc'') is not null            
Drop table ##Acc             
select * into ##Acc from mvno_usa.dbo.dsm_accmgr_trnactivation'            
Exec (@sql)             
            
Set @Sql='Create index id1 on ##Acc(iccid_fr,iccid_to)'            
Exec (@sql)             
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##HP'') is not null            
Drop table ##HP             
select * into ##HP from mvno_usa.dbo.dsm_hotspot_trnactivation'            
Exec (@sql)             
            
Set @Sql='Create index id1 on ##HP(iccid_fr,iccid_to)'            
Exec (@sql)             
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##DSM'') is not null            
Drop table ##DSM             
select retailerid,offmgrid,accmgrid,hotspotid into ##DSM from mvno_usa.dbo.dsm_retailer'            
Exec (@sql)             
            
Set @Sql='Create index id1 on ##DSM(retailerid)'            
Exec (@sql)             
            
            
Set @Sql='update a                  
set a.Resellerid=b.Resellerid ,a.Initial_bundlecode=b.bundlecode, a.Ini_facevalue=b.facevalue,            
a.freemin=b.freemin,a.discount=b.discount,a.noofmonths=b.noofmonths            
from Mis_1717_USA_FCA a join ##res b                  
on LEFT(a.iccid,11) between b.iccid_fr and b.iccid_to'            
Exec (@sql)             
            
Set @Sql='update a                  
set  a.Ini_facevalue=b.bundlecost,a.discount=b.discount            
from Mis_1717_USA_FCA a join ##res b                  
on LEFT(a.iccid,11) between b.iccid_fr and b.iccid_to and b.bundlecost is not null and facevalue=0'            
Exec (@sql)             
            
Set @Sql='update a                        
set a.OffMgrID=b.OffMgrID                        
from Mis_1717_USA_FCA a join MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b                        
on a.resellerid=b.resellerid'            
Exec (@sql)             
            
--Set @Sql='update a                        
--set a.OffMgrID=b.OffMgrID                        
--from Mis_1717_USA_FCA a join ##off b                        
--on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'            
--Exec (@sql)             
            
--Set @Sql='update a                        
--set a.accmgrid=b.accmgrid            
--from Mis_1717_USA_FCA a join ##acc b                        
--on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'            
--Exec (@sql)             
               
--Set @Sql='update a                        
--set a.hotspotid=b.hotspotid            
--from Mis_1717_USA_FCA a join ##hp b                        
--on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'            
--Exec (@sql)             
            
Set @Sql='            
IF OBJECT_ID(''mis_1717_retailer_trnactivation'+@month1+''') is not null            
Drop table mis_1717_retailer_trnactivation'+@month1+'            
            
select retailerid,Offmgrid,Accmgrid,Hotspotid,iccid_fr,iccid_to,authdate into mis_1717_retailer_trnactivation'+@month1+'            
from mvno_usa.dbo.dsm_retailer_trnactivation with (nolock)            
where CONVERT(varchar(7),authdate,120)<='''+@month+'''            
            
create index IDX on   mis_1717_retailer_trnactivation'+@month1+' (iccid_fr,iccid_to) '            
Exec (@sql)            
            
            
--Set @Sql='            
--IF OBJECT_ID(''tempdb.dbo.##Comm'') is not null            
--Drop table ##comm             
            
--select * into ##Comm from IS_USA.mvno_usa.dbo.TopupBundle_Commission_detailed            
--where  cons_bundletype=''ACT''            
--and convert(varchar(7),activationdate,120)>=''2020-08''            
--and retailerid is not null'            
--Exec (@sql)            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##Comm'') is not null            
Drop table ##comm             
            
select * into ##Comm from mvno_usa.dbo.TopupBundle_Commission_detailed            
where  TopupSeq=''1''            
and convert(varchar(7),activationdate,120)>=''2020-08''            
and retailerid is not null'            
Exec (@sql)            
            
            
--Set @Sql='            
--insert into ##Comm            
--select * from IS_USA.mvno_usa.dbo.TopupBundle_Commission_detailed            
--where  TopupSeq=''1''            
--and retailerid is not null            
--and convert(varchar(7),activationdate,120)>=''2020-08''            
--and iccid not in (select iccid from ##Comm)'            
--Exec (@sql)            
            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##POS'') is not null            
Drop table ##POS             
            
select iccid,max(activationdate) activationdate into ##POS from ##comm             
where   convert(varchar(7),activationdate,120)>=''2020-08''            
group by iccid'            
Exec (@sql)            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##POS1'') is not null            
Drop table ##POS1             
Select A.iccid,A.Retailerid,A.activationdate,A.OffMgrID,            
a.hotspotid,a.accmgrid into ##POS1 from ##comm  a,##POS b            
where a.iccid=b.iccid            
and a.activationdate=b.activationdate'            
Exec (@sql)            
            
            
Set @Sql='            
Delete from  ##POS1            
where retailerid is null'            
Exec (@sql)     


set @sql='
update a
set a.retailerid=b.retailerid,a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from ##POS1 a,mis_1717_ins_comm_staff_mapping b
where a.retailerid=b.USERID
'
Exec (@sql)
            
--Set @Sql='update a                        
--set a.retailerid=b.retailerid,a.OffMgrID=b.OffMgrID,            
--a.hotspotid=b.hotspotid,            
--a.accmgrid=b.accmgrid,            
--a.authdate_ret=b.authdate                        
--from Mis_1717_USA_FCA a join mis_1717_retailer_trnactivation'+@month1+' b                        
--on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'            
--Exec (@sql)            
            
Set @Sql='update a                        
set a.OffMgrID=b.OffMgrID,            
a.hotspotid=b.hotspotid,            
a.accmgrid=b.accmgrid,            
a.retailerid=b.retailerid                       
from Mis_1717_USA_FCA a join ##POS1 b                        
on a.iccid=b.iccid'            
Exec (@sql)    


            
Set @Sql='update a                        
set a.OffMgrID=b.OffMgrID,            
a.hotspotid=b.hotspotid,            
a.accmgrid=b.accmgrid            
from Mis_1717_USA_FCA a join ##DSM b                        
on a.retailerid=b.retailerid '            
Exec (@sql)            
            
---Deva missing commission             
            
--Set @Sql='update a                        
--set a.OffMgrID=b.OffMgrID,            
--a.hotspotid=b.hotspotid,            
--a.accmgrid=b.accmgrid,            
--a.retailerid=b.retailerid                      
--from Mis_1717_USA_FCA a join Mis_1717_ins_comm b                        
--on a.iccid=b.iccid'            
--Exec (@sql)            
            
--Set @Sql='update a                        
--set a.OffMgrID=b.OffMgrID,            
--a.hotspotid=b.hotspotid,            
--a.accmgrid=b.accmgrid,            
--a.retailerid=b.retailer_ic                       
--from Mis_1717_USA_FCA a join Mis_1717_USA_Missing_INSTANT_Master_202307 b                        
--on a.iccid=b.iccid'            
--Exec (@sql)           
            
            
            
Set @Sql='            
IF OBJECT_ID(''tempdb..##Iccid_12month'') IS NOT NULL                  
drop table ##Iccid_12month                   
 Select Iccid,bundlecode,Count(*) cnt ,min(Topupseq) Min_topupseq into ##Iccid_12month from MIS_1717_BS_wrkard_master_dontdrop            
where convert(varchar(07),Topupdate,120)='''+@month+'''            
and bundlecode in (''1012'')            
group by Iccid,bundlecode having Count(*)=12'            
Exec (@sql)              
            
--Set @Sql='Delete from ##Iccid_12month            
--where Min_topupseq<>1'            
--Exec (@sql)              
            
            
Set @Sql='            
IF OBJECT_ID(''tempdb..##detail_Topup_report'') IS NOT NULL         
drop table ##detail_Topup_report                   
               
select A.iccid,''Plan_19_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
into ##detail_Topup_report                
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)         
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_19'')'            
Exec (@sql)             
            
Set @Sql='Alter Table ##detail_Topup_report alter column Activityname varchar(50)            
Alter Table ##detail_Topup_report alter column Bundle_seq varchar(20)'            
Exec (@sql)            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_23_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_23'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_29_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <7            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_29'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_30_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_30'')'            
Exec (@sql)             
            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_33_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <7            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_33'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_39_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <7            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_39'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_49_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <7            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_49'')'            
Exec (@sql)            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_59_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <7            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_59'')'            
Exec (@sql)             
            
            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_CH29_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Child_61029'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_CH49_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Child_61049'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_CH59_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''           
and a.Topupseq <5            
and a.Topupseq<>0            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Child_61059'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_15_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <5            
and a.Topupseq<>0            
and a.iccid not in (select iccid from ##Iccid_12month )            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundlecode=''1012'')'            
Exec (@sql)            
            
             
            
---12month plan            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Plan_12M_''+a.bundlecode+''_10'' Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and a.iccid  in (select iccid from ##Iccid_12month where bundlecode =''1012'' and Min_topupseq=''1'')            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =''1''              
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundlecode=''1012'')'            
Exec (@sql)             
            
--Set @Sql='insert into ##detail_Topup_report            
--select A.iccid,''Plan_12M_''+a.bundlecode+''_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
--ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
--a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
--from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
--where a.iccid =b.iccid              
--and a.iccid  in (select iccid from ##Iccid_12month where  bundlecode =''1912'' and Min_topupseq=''1'')                 
--and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
--and a.Topupseq =1            
--and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundlecode in (''1912''))'            
--Exec (@sql)             
            
----Activation            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##mis_1717_bundle_cdr_stg'') is not null            
drop table ##mis_1717_bundle_cdr_stg            
             
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number ,transaction_id  ,RECHARGE_DATE  ,                                                      
Special_topup_amount   , bundle_code,Operation_code,Recharge_type,Payment_Mode,planid                    
,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments ,Reservation                 
,SUBSTRING(RECHARGE_DATE,0,5)+''-''+ SUBSTRING(RECHARGE_DATE,5,2)+''-''+                                               
SUBSTRING(RECHARGE_DATE,7,2)+ '' ''+ SUBSTRING(RECHARGE_DATE,9,2)+ '':''+                                               
SUBSTRING(RECHARGE_DATE,11,2)+ '':''+ SUBSTRING(RECHARGE_DATE,13,2)+''.000'' as topupdate,                
right(sim_number,12)iccid,right(sim_number,12)RRBS_iccid                
into ##mis_1717_bundle_cdr_stg from (             
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,                
account_pin_number ,transaction_id  ,RECHARGE_DATE  ,                                                      
Special_topup_amount   , bundle_code,Operation_code,Recharge_type,Payment_Mode,planid                    
,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id ,Number_Of_Installments ,Reservation                
from  usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup--change month            
where operation_code in (''5'',''12'',''14'',''11'')             
and left(recharge_date,6)='+@month1+') x               
'            
Exec (@Sql)            
            
Set @Sql='Delete from ##mis_1717_bundle_cdr_stg            
where transaction_id in (Select order_id from usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup            
where operation_code in (''6'') and Forcible_Cancellation<>''1'')'            
Exec (@Sql)            
            
Set @Sql='Delete from ##mis_1717_bundle_cdr_stg            
where  bundle_code in (''668851'',''668855'',''668852'',''668853'',''668854'',''885566'',''885577'',''3010'',''3020'',''3005'',''1110'',            
''121035'',''131023'',''131039'',''445566'',''445567'',''445570'',''668899'',''777331'',''778853'',''888813'',''668844'',''1005'',''681005'')'            
Exec (@Sql)            
            
Set @Sql='delete from ##mis_1717_bundle_cdr_stg where bundle_name like ''add%'''            
Exec (@Sql)            
            
Set @Sql='delete from ##mis_1717_bundle_cdr_stg where bundle_name like ''%addon%'''            
Exec (@Sql)            
            
Set @Sql='delete from ##mis_1717_bundle_cdr_stg  where bundle_name like ''%Free%'''            
Exec (@Sql)            
            
            
            
Set @Sql='insert into ##detail_Topup_report            
select iccid,''Activation'' Activityname,convert(varchar(10),(DATEADD(MM,DATEDIFF(MM, 1, Getdate()),-1)),120) Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,face_value Topup_value,bundlevalue,Topupdate Firstbundle_date,bundlecode,bundle_name,topupseq Bundle_seq,Payment_Mode,null Operation_code,null Recharge_type
,noofmonths            
from  Mis_1717_USA_FCA (nolock)                  
where (iccid  in (select iccid from ##mis_1717_bundle_cdr_stg)            
or RRBS_iccid in (select iccid from ##mis_1717_bundle_cdr_stg))'            
Exec (@sql)             
            
--Activation & 1st renewal for slab bonus            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Bundle_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                  
where a.iccid =b.iccid                   
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq <3            
and a.Topupseq<>0'            
Exec (@sql)            
            
---Portin            
            
            
Set @Sql='IF OBJECT_ID(''tempdb..##deva'') IS NOT NULL                  
drop table ##deva                  
 select * into  ##deva from (           
select RIGHT(ICCID,12)  iccid,Pmsisdn,CompletedDate   from mvnoreport_USA_LM.dbo.vw_mnpportinrequest             
where convert(varchar(07),CompletedDate,120) >='''+@month7+'''             
and status=''10''        
union all        
Select RIGHT(ICCID,12)  iccid,Pmsisdn, Completeddate  from MNP_USA_ATT.DBO.mnpportinrequest        
where Status=''10''and isnull(SIMCHANGETYPE,'''')<>''SIMCHANGE'' and convert(varchar(07),CompletedDate,120) >='''+@month7+'''        
)a'        
Exec (@sql)            
            
            
--Set @Sql='Delete from ##Deva where pmsisdn in (select pmsisdn from ##Deva_portin)'            
--Exec (@Sql)            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Portout'') IS NOT NULL                  
drop table ##Portout            
            
select Msisdn,CompletedDate,RIGHT(ICCID,12)Iccid into ##Portout  from mvnoreport_USA_LM.dbo.vw_mnpportoutrequest             
where convert(varchar(07),CompletedDate,120) <='''+@month+'''            
and status=''10'''            
Exec (@sql)            
            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Portouticcid'') IS NOT NULL                  
drop table ##Portouticcid            
Select iccid into ##Portouticcid from ##Portout'            
Exec (@Sql)            
   
Set @Sql='IF OBJECT_ID(''tempdb..##Portiniccid'') IS NOT NULL                  
drop table ##Portiniccid            
Select iccid into ##Portiniccid from ##Deva'            
Exec (@Sql)            
            
            
Set @Sql='Delete from ##Deva where iccid in (select Iccid from ##Portouticcid)'            
Exec (@Sql)            
            
Set @Sql='Delete from ##Portout where iccid in (select Iccid from ##Portiniccid)'            
Exec (@Sql)            
            
            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Portout1'') IS NOT NULL                  
drop table ##Portout1            
            
Select Msisdn,Max(CompletedDate) CompletedDate             
into ##Portout1 from ##Portout            
group by Msisdn'            
Exec (@Sql)            
            
Set @Sql='Alter table ##deva add Portoutdate datetime ,Aging float,Final varchar(10)'            
Exec (@Sql)            
            
Set @Sql='update ##deva set Portoutdate=b.CompletedDate,Aging=datediff(dd,b.CompletedDate,a.CompletedDate)            
from ##deva a,##Portout1 b            
where a.Pmsisdn=b.MSISDN            
and a.CompletedDate>=b.CompletedDate'            
Exec (@Sql)            
            
Set @Sql='Update ##deva set Final=''NO''            
where Aging<=180'            
Exec (@sql)            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_15_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.iccid not in (select iccid from ##Iccid_12month )             
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundlecode=''1012'')'            
Exec (@sql)             
            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_19_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,           
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_19'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_23_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva  )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_23'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_29_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_29'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_30_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_30'')'            
Exec (@sql)             
            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_33_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva  )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_33'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_39_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_39'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report       
select A.iccid,''Portin_Plan_49_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva  )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_49'')'            
Exec (@sql)             
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_59_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva  )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''     
and a.Topupseq =4            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_59'')'            
Exec (@sql)            
            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Portin_Plan_''+Cast(a.BUNDLECODE as varchar(10))+''_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and a.iccid in (select iccid from ##deva )            
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq =4            
and a.iccid in (select iccid from ##Iccid_12month where bundlecode in (''1012'') and Min_topupseq=''1'')            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_12month'')'            
Exec (@sql)             
            
----Residual            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Residual_12_AR'' Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq between ''5'' and ''24''            
and Convert(varchar(10),a.Topupdate,120)<=Convert(varchar(10),b.Topupdate+730,120)            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211)            
and isnull(b.accmgrid,'''') not like ''%EUROPEAN AGENCY%'''            
Exec (@sql)            
            
Set @Sql='insert into ##detail_Topup_report            
select A.iccid,''Residual_12_AR'' Activityname,a.Topupdate Activitydate,                  
ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,            
a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths            
from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)                 
where a.iccid =b.iccid              
and Convert(varchar(07),a.Topupdate,120) ='''+@month+'''              
and a.Topupseq between ''1'' and ''6''            
and Convert(varchar(10),a.Topupdate,120)<=Convert(varchar(10),b.Topupdate+180,120)            
and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211)            
and isnull(b.accmgrid,'''') like ''%EUROPEAN AGENCY%'''            
Exec (@sql)            
            
Set @Sql='Delete from ##detail_Topup_report            
where bundlecode in (''1005'',''681005'')'            
Exec (@sql)            
            
            
Set @Sql='            
TRUNCATE TABLE Mis_1717_USA_Detail_comm            
            
insert into Mis_1717_USA_Detail_comm            
(ICCID ,ACTIVITYNAME ,ACTIVITYDATE ,RESELLERID ,OFFMGRID ,ACCMGRID ,HOTSPOTID ,RETAILERID ,INI_FACEVALUE ,FREEMIN ,DISCOUNT ,TOPUP_VALUE ,BUNDLE_VALUE ,            
FIRSTBUNDLE_DATE ,BUNDLE_CODE ,BUNDLE_NAME ,BUNDLE_SEQ ,PAYMENT_MODE ,OPERATION_CODE ,RECHARGE_TYPE,noofmonths )            
select iccid, Activityname, Activitydate,ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount, Topup_value,            
Bundlevalue, Firstbundle_date,bundlecode,bundle_name, Bundle_seq,Payment_Mode,Operation_code,Recharge_type,noofmonths            
from ##detail_Topup_report'            
Exec (@sql)             
            
--Alter table Mis_1717_USA_Detail_comm add Gateway varchar(70),Gateway_Offmgr varchar(70)            
            
Set @Sql='            
IF OBJECT_ID(''tempdb.dbo.##ITG'') is not null            
Drop table ##ITG            
Select RIGHT(ICCID,12)Iccid,Realmsisdn,Paymentchannel,Processeddate,Wholesalerid,Retailerid            
into ##ITG            
from mvno_usa.dbo.TrnSimActivationWithBundlePurchaseandPortIn            
where Convert(varchar(07),processeddate,120)>=''2023-03''            
and status=''5'' and voucherpin=''0''            
order by Channel'            
Exec (@sql)            
            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Gateway=b.Paymentchannel            
from Mis_1717_USA_Detail_comm a,##ITG b            
where a.iccid=b.iccid'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Gateway_Offmgr=             
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
            
--Set @Sql='Delete from Mis_1717_USA_Detail_comm            
--where Wholesalerid<>Gateway_Offmgr            
--and Gateway_Offmgr is not null'            
--Exec (@sql)            
            
            
Set @Sql='update Mis_1717_USA_Detail_comm set Offmgrid=b.offmgrid,Accmgrid=b.Accmgrid,Hotspotid=b.Hotspotid            
from Mis_1717_USA_Detail_comm a, Mvnoreport_USA_LM.dbo.vw_dsmRetailer b            
where a.retailerid=b.retailerid'     
Exec (@sql)            
            
            
            
            
--Alter Table  Mis_1717_USA_Detail_comm add Wholesalerid varchar(100)            
            
--Alter table Mis_1717_USA_Detail_comm add Portoutdate datetime,portindays float,Portineligible varchar(100), Portindate datetime,Portout_Status Varchar(100),Portin_status varchar(100)            
         
          
        
        
Set @Sql='Update Mis_1717_USA_Detail_comm set Portout_Status=''Portout''            
where iccid in (select Iccid from ##Portouticcid)'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_30_Portin''            
where iccid in (select Iccid from ##deva where Aging<31)'            
Exec (@sql)            
           
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_45_Portin''            
where iccid in (select Iccid from ##deva where Aging<46) and Portin_status is null'            
Exec (@sql)          
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_60_Portin''            
where iccid in (select Iccid from ##deva where Aging<61) and Portin_status is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_90_Portin''            
where iccid in (select Iccid from ##deva where Aging<91) and Portin_status is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_120_Portin''            
where iccid in (select Iccid from ##deva where Aging<121) and Portin_status is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_150_Portin''            
where iccid in (select Iccid from ##deva where Aging<151) and Portin_status is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Lessthan_180_Portin''            
where iccid in (select Iccid from ##deva where Aging<181) and Portin_status is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Greaterthan_180_Portin''            
where iccid in (select Iccid from ##deva where Aging>=181) and Portin_status is null'            
Exec (@sql)           
        
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''Greaterthan_180_Portin''            
where iccid in (select Iccid from ##deva ) and Portin_status is null'            
Exec (@sql)         
            
Set @Sql='Update Mis_1717_USA_Detail_comm set PortinDate=b.completeddate,Portoutdate=b.Portoutdate            
from Mis_1717_USA_Detail_comm a,##deva b            
where a.iccid=b.Iccid'            
Exec (@sql)         
    
Set @Sql='Update Mis_1717_USA_Detail_comm set Portin_status=''SIM_BLOCK''            
where iccid in (select Iccid from ADHOC.Incentive_master.DBO.MIS_1001_ALL_KB_SIMBLOCK_MASTER  where country=''USA'' and month='+@month1+')and Portin_status is null    
    
'            
Exec (@sql)      
        
        
        
        
        
            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set portindays= Datediff(dd,PortinDate,convert(varchar(10),(DATEADD(MM,DATEDIFF(MM, 1, Getdate()),-1)),120))            
where PortinDate is not null'            
Exec (@sql)            
            
            
--Set @Sql='            
--IF OBJECT_ID(''tempdb..##off'') IS NOT NULL                  
--drop table ##off            
                    
--select OffMgrID,Iccid_fr,Iccid_to into ##off from  MVNOREPORT_USA_LM.dbo.vw_dsmoffmgrtrnactivation'            
--Exec (@sql)             
     
--Set @Sql='Create index id1 on ##off(iccid_fr,iccid_to)'            
--Exec (@sql)            
            
--Set @Sql='            
--update a                        
--set a.Wholesalerid=b.OffMgrID                        
--from Mis_1717_USA_Detail_comm a join ##off b                        
--on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to              
--and a.Wholesalerid is null'            
--Exec (@sql)            
            
Set @Sql='update  Mis_1717_USA_Detail_comm set Wholesalerid=b.OffMgrID            
from  MVNOREPORT_USA_LM.dbo.vw_DSMOffMgrResellerMapping b, Mis_1717_USA_Detail_comm a            
where a.resellerid=b.resellerid'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set OffMgrID=Gateway_Offmgr,Wholesalerid=Gateway_Offmgr            
where Gateway_Offmgr is not null'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_FCA set OffMgrID=b.Gateway_Offmgr            
from Mis_1717_USA_Detail_comm b,Mis_1717_USA_FCA a            
where a.iccid=b.iccid            
and b.Gateway_Offmgr is not null'            
Exec (@sql)            
            
                  
Set @Sql='Update Mis_1717_USA_Detail_comm set RES_T2M_FCA=b.T2M_FCA,RES_T2M_TP=b.T2M_TP,RES_T2M_PER=b.T2M_PER,RES_T2M_TYPE=b.T2M_Type            
from Mis_1717_USA_Detail_comm a,Mis_1717_USA_T2M_'+@month1+'_Final b---Change month            
where a.RESELLERID=b.resellerid'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set RES_T2M_FCA=b.FCA,RES_T2M_TP=b.TS,RES_T2M_PER=b.T2M,RES_T2M_TYPE=b.Type            
from Mis_1717_USA_Detail_comm a,Mis_1717_USA_T2M_Res_mly b            
where  a.Wholesalerid=b.Wholesalerid            
and RES_T2M_TYPE is null'            
Exec(@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_T2M_TYPE=''Silver''  where RES_T2M_TYPE is null'            
Exec (@sql)            
            
            
--Alter table Mis_1717_USA_Detail_comm add RES_T1M_FCA float,RES_T1M_TP float,RES_T1M_PER float,RES_T1M_TYPE varchar(100)            
--Alter table Mis_1717_USA_Detail_comm add RET_T1M_FCA float,RET_T1M_TP float,RET_T1M_PER float,RET_T1M_TYPE varchar(100)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set RES_T1M_FCA=b.T1M_FCA,RES_T1M_TP=b.T1M_TP,RES_T1M_PER=b.T1M_PER,RES_T1M_TYPE=b.T1M_Type            
from Mis_1717_USA_Detail_comm a,Mis_1717_USA_T1M_'+@month1+'_Final b---Change month            
where a.RESELLERID=b.resellerid'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set RES_T1M_FCA=b.FCA,RES_T1M_TP=b.TS,RES_T1M_PER=b.T1M,RES_T1M_TYPE=b.Type            
from Mis_1717_USA_Detail_comm a,Mis_1717_USA_T1M_Res_mly b            
where  a.Wholesalerid=b.Wholesalerid            
and RES_T1M_TYPE is null'            
Exec(@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_T1M_FCA=0,RES_T1M_TP=0,RES_T1M_PER=0,RES_T1M_TYPE=''<5000''  where RES_T1M_FCA is null'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm set RET_T1M_FCA=b.T1M_FCA,RET_T1M_TP=b.T1M_TP,RET_T1M_PER=b.T1M_PER,RET_T1M_TYPE=b.T1M_Type            
from Mis_1717_USA_Detail_comm a,Mis_1717_USA_T1M_RET_'+@month1+'_Final b---Change month            
where a.Retailerid=b.Retailerid            
and offmgrid  in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_T1M_FCA=0,RET_T1M_TP=0,RET_T1M_PER=0,RET_T1M_TYPE=''<3''  where RET_T1M_FCA is null            
and offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'            
Exec (@sql)            
            
--Arjundev            
--Set @Sql='Update Mis_1717_USA_Detail_comm set RES_T2M_FCA=100,RES_T2M_TP=100,RES_T2M_PER=100,RES_T2M_TYPE=''Gold''            
--where wholesalerid=''LMUS-WS-UNIVERSAL LLC'' and RES_T2M_TYPE<>''Platinum'''            
--Exec(@sql)            
            
--update Mis_1717_USA_Detail_comm set RES_TYPE=NULL,RES_TIER=NULL,Retailer_comm=Null,REseller_comm=Null            
            
Set @Sql='            
            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_DP'' where RESELLERID like ''%-WS-DP-%''            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_DP'' where RESELLERID like ''%-WS-%-DP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_TP'' where RESELLERID like ''%-WS-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_TP'' where RESELLERID like ''%-WS-%-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_LI'' where RESELLERID like ''%-WS-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_LI'' where RESELLERID like ''%-WS-%-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_NI'' where RESELLERID like ''%-WS-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS_NI'' where RESELLERID like ''%-WS-%-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_DP'' where RESELLERID like ''%-HP-DP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_DP'' where RESELLERID like ''%-HP-%-DP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_TP'' where RESELLERID like ''%-HP-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_TP'' where RESELLERID like ''%-HP-%-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_LI'' where RESELLERID like ''%-HP-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_LI'' where RESELLERID like ''%-HP-%-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_NI'' where RESELLERID like ''%-HP-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP_NI'' where RESELLERID like ''%-HP-%-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''HP'' where RESELLERID like ''%-HP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''WS'' where RESELLERID like ''%-WS-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_DP'' where RESELLERID like ''%-PF-DP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_DP'' where RESELLERID like ''%-PF-%-DP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_TP'' where RESELLERID like ''%-PF-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_TP'' where RESELLERID like ''%-PF-%-TP-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_LI'' where RESELLERID like ''%-PF-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_LI'' where RESELLERID like ''%-PF-%-LI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_NI'' where RESELLERID like ''%-PF-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF_NI'' where RESELLERID like ''%-PF-%-NI-%'' and RES_TYPE IS NULL            
update Mis_1717_USA_Detail_comm set RES_TYPE=''PF'' where RESELLERID like ''%-PF-%'' and RES_TYPE IS NULL'            
Exec (@sql)            
--Select Distinct RESELLERID from Mis_1717_USA_Detail_comm where RES_TYPE is null            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_TYPE=''Others'' where RES_TYPE IS NULL      
            
update Mis_1717_USA_Detail_comm set RES_TIER=''DP'' where RES_TYPE like ''%DP%''            
update Mis_1717_USA_Detail_comm set RES_TIER=''TP'' where RES_TYPE like ''%TP%''            
update Mis_1717_USA_Detail_comm set RES_TIER=''LI'' where RES_TYPE like ''%LI%''            
update Mis_1717_USA_Detail_comm set RES_TIER=''NI'' where RES_TYPE like ''%NI%''            
            
--update Mis_1717_USA_Detail_comm set RES_TIER=''DP_WS'' where RES_TYPE like ''%DP%''            
--and offmgrid in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')            
--update Mis_1717_USA_Detail_comm set RES_TIER=''TP_WS'' where RES_TYPE like ''%TP%''            
--and offmgrid in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')            
--update Mis_1717_USA_Detail_comm set RES_TIER=''LI_WS'' where RES_TYPE like ''%LI%''            
--and offmgrid in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')            
--update Mis_1717_USA_Detail_comm set RES_TIER=''NI_WS'' where RES_TYPE like ''%NI%''            
--and Wholesalerid in (''LMUS-WS-MOBILECON'',''LMUS-PF-SIMLOCAL'',''LMUS-WS-UNIVERSAL LLC'')            
            
update Mis_1717_USA_Detail_comm set RES_TIER=''NI_WS'' where RES_TYPE like ''%NI%''            
and Wholesalerid in (''LMUS-PF-SIMLOCAL'')---20240909 thanusan confirmation            
'            
Exec (@sql)            
            
--Select Distinct RES_TYPE from Mis_1717_USA_Detail_comm where RES_TIER is null            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_TIER=''Others'' where RES_TIER IS NULL'            
Exec (@sql)            
            
            
            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan4'') IS NOT NULL                  
drop table ##Devan4            
Select * into ##Devan4 from Mis_1717_USA_Detail_comm'            
Exec (@sql)            
            
            
Set @Sql='Delete from ##Devan4            
where (Wholesalerid in (''GLOBAL LINK'',''EAHASOLUTIONSINC'') or Offmgrid in (''GLOBAL LINK'',''EAHASOLUTIONSINC''))            
--and Activityname=''Bundle_1''            
and Convert(varchar(10),activitydate,120)>=''2023-06-21'''            
Exec (@sql)            
            
Set @Sql='Delete from ##Devan4            
where (Wholesalerid in (''EK WIRELESS'',''BNK US'') or Offmgrid in (''EK WIRELESS'',''BNK US''))            
--and Activityname=''Bundle_1''            
and Convert(varchar(10),activitydate,120)>=''2023-08-11'''            
Exec (@sql)            
            
Set @Sql='Delete from ##Devan4            
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'',''SIM_BLOCK'')'            
EXEC (@Sql)            
            
Set @Sql='Delete from ##Devan4            
where Portin_status in (''Lessthan_60_Portin'',''Lessthan_90_Portin'',            
''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin'')            
and Convert(varchar(10),activitydate,120)>=''2023-06-12'''            
EXEC (@Sql)            
            
--Alter Table Mis_1717_USA_Detail_comm add RES_AS_TIER varchar(20),RES_DC_TIER varchar(20),RET_AS_TIER varchar(20),RET_DC_TIER varchar(20)            
            
--Alter Table Mis_1717_USA_Detail_comm add RES_RESIDUAL_TIER varchar(20),RET_RESIDUAL_TIER varchar(20)            
            
--Alter Table Mis_1717_USA_Detail_comm add RES_Bundle_1 Float,RET_Bundle_1 Float            
            
--Alter Table Mis_1717_USA_Detail_comm add Res_Activebase Float,Ret_Activebase Float            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan'') IS NOT NULL                  
drop table ##Devan            
            
Select Wholesalerid,Count(*) Cnt into ##Devan from ##Devan4            
where Activityname=''Bundle_1''            
and isnull(offmgrid,'''') not in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')            
and Portout_Status is null             
and offmgrid=Wholesalerid            
and isnull(Gateway_Offmgr,Wholesalerid)=Wholesalerid            
group by Wholesalerid'            
Exec (@sql)            
            
--Select * from ##Devan            
            
Set @Sql='Alter table ##Devan add AS_Tier varchar(20),DS_Tier varchar(20)'            
Exec (@sql)            
            
Set @Sql='Update ##Devan set AS_Tier= case when cnt between 10000 and 19999 then ''Tier1''          
       when cnt between 20000 and 29999 then ''Tier2''          
       when cnt between 30000 and 39999 then ''Tier3''          
       when cnt >=40000 then ''Tier4''          
       else ''NA'' end'          
Exec (@sql)          
Set @Sql='Update ##Devan set DS_Tier= case when cnt =''1000''  then ''Tier1''          
       when cnt between 1001 and 4999 then ''Tier2''          
       when cnt between 5000 and 9999 then ''Tier3''          
       when cnt between 10000 and 14999 then ''Tier4''          
       when cnt between 15000 and 19999 then ''Tier5''          
       when cnt >=20000 then ''Tier6''          
       else ''NA'' end'          
Exec (@sql)            
            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_AS_TIER =b.AS_Tier,RES_DC_TIER=b.DS_Tier,RES_Bundle_1=b.Cnt            
from Mis_1717_USA_Detail_comm a,##Devan b            
where a.wholesalerid=b.Wholesalerid'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_Bundle_1=0,RES_AS_TIER=''NA'',RES_DC_TIER=''NA''            
where RES_Bundle_1 is null'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_T1M_TYPE=''<2000''            
where RES_Bundle_1<2000'            
Exec (@sql)            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan_1'') IS NOT NULL                  
drop table ##Devan_1            
            
Select Wholesalerid,Count(*) Cnt into ##Devan_1 from ##Devan4            
where Activityname=''Activation''            
and isnull(offmgrid,'''') not in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')            
and Portout_Status is null             
and offmgrid=Wholesalerid            
and isnull(Gateway_Offmgr,Wholesalerid)=Wholesalerid            
group by Wholesalerid'            
Exec (@sql)            
            
Set @Sql='Alter table ##Devan_1 add Residual_Tier varchar(20)'            
Exec (@sql)            
            
Set @Sql='Update ##Devan_1 set Residual_Tier= case when cnt <= 10000 then ''Tier1''            
       when cnt between 10001 and 49999 then ''Tier2''            
       when cnt between 50000 and 99999 then ''Tier3''            
       when cnt >=100000 then ''Tier4''            
       else ''NA'' end'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_RESIDUAL_TIER =b.Residual_Tier,Res_activebase=b.cnt            
from Mis_1717_USA_Detail_comm a,##Devan_1 b            
where a.wholesalerid=b.Wholesalerid'            
Exec (@sql)            
            
            
            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RES_RESIDUAL_TIER =''NA'',Res_activebase=0            
where Res_activebase is  null'            
Exec (@sql)            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan41'') IS NOT NULL                  
drop table ##Devan41            
Select * into ##Devan41 from Mis_1717_USA_Detail_comm            
Where isnull(offmgrid,'''')  in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')            
and Portout_Status is null '            
Exec (@sql)            
            
Set @Sql='Delete from ##Devan41            
where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin'')'            
EXEC (@Sql)            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan1'') IS NOT NULL                  
drop table ##Devan1            
            
Select Retailerid,Count(*) Cnt into ##Devan1 from ##Devan41            
where Activityname=''Bundle_1''            
group by Retailerid'            
Exec (@sql)            
            
Set @Sql='Alter table ##Devan1 add DS_Tier varchar(20)'            
Exec (@sql)            
            
Set @Sql='Update ##Devan1 set DS_Tier= case when cnt between 1 and 10 then ''Tier1''            
       when cnt between 11 and 20 then ''Tier2''            
       when cnt between 21 and 49 then ''Tier3''          
       when cnt between 50 and 100 then ''Tier4''            
       when cnt between 101 and 200 then ''Tier5''            
       when cnt >=201 then ''Tier6''            
       else ''NA'' end'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_DC_TIER=b.DS_Tier,RET_Bundle_1=b.Cnt            
from Mis_1717_USA_Detail_comm a,##Devan1 b            
where a.Retailerid=b.Retailerid'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_Bundle_1=0,RET_DC_TIER=''NA''            
where RET_Bundle_1 is null'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_T1M_TYPE=''<3''            
where RET_Bundle_1<3'            
Exec (@sql)            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Devan_2'') IS NOT NULL                  
drop table ##Devan_2            
            
Select Retailerid,Count(*) Cnt into ##Devan_2 from ##Devan41            
where Activityname=''Activation''            
and isnull(offmgrid,'''')  in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')            
and Portout_Status is null             
group by Retailerid'            
Exec (@sql)            
            
Set @Sql='Alter table ##Devan_2 add Residual_Tier varchar(20)'            
Exec (@sql)            
            
Set @Sql='Update ##Devan_2 set Residual_Tier= case when cnt <= 50 then ''Tier1''            
       when cnt between 51 and 250 then ''Tier2''            
       when cnt between 251 and 500 then ''Tier3''            
       when cnt >500 then ''Tier4''            
       else ''NA'' end'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_RESIDUAL_TIER =b.Residual_Tier,Ret_Activebase=b.cnt            
from Mis_1717_USA_Detail_comm a,##Devan_2 b            
where a.Retailerid=b.Retailerid'            
Exec (@sql)            
            
Set @Sql='update Mis_1717_USA_Detail_comm set RET_RESIDUAL_TIER =''NA'',Ret_Activebase=0            
where Ret_Activebase is  null'            
Exec (@sql)            
            
update Mis_1717_USA_Detail_comm set RES_T2M_TYPE='Platinum'            
where Resellerid='LMPUS-SIM-PF-EPAYPAYSPOT' and convert(varchar(10),activitydate,120)>='2024-10-14'            
            
---Commission update            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.5            
where Activityname in (''Plan_15_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
where Activityname in (''Plan_15_2'') and RES_TIER not in (''DP'',''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5           
where Activityname in (''Plan_15_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
where Activityname in (''Plan_15_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
--where Activityname in (''Plan_15_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Plan_15_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Plan_15_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
--where Activityname in (''Plan_15_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec(@sql)            
            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.5            
where Activityname in (''Plan_19_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.5            
where Activityname in (''Plan_19_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.5            
where Activityname in (''Plan_19_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.5            
where Activityname in (''Plan_19_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.5            
--where Activityname in (''Plan_19_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
--where Activityname in (''Plan_19_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.5            
--where Activityname in (''Plan_19_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.5            
--where Activityname in (''Plan_19_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec(@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.5          
where Activityname in (''Plan_23_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.5           
where Activityname in (''Plan_23_2'') and RES_TIER not in (''DP'',''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.5           
where Activityname in (''Plan_23_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.5            
where Activityname in (''Plan_23_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.25            
--where Activityname in (''Plan_23_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.5            
--where Activityname in (''Plan_23_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.5            
--where Activityname in (''Plan_23_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.            
--where Activityname in (''Plan_23_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''             
            
'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.5            
where Activityname in (''Plan_29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.5            
where Activityname in (''Plan_29_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.5            
where Activityname in (''Plan_29_3'') and RES_TIER not in (''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.5            
where Activityname in (''Plan_29_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_29_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=13.5            
--where Activityname in (''Plan_29_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.            
--where Activityname in (''Plan_29_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec (@sql)             
            
            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.            
--where Activityname in (''Plan_30_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'') and RES_T2M_TYPE=''Platinum''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.            
--where Activityname in (''Plan_30_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Platinum''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_30_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Platinum''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_30_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Platinum'' and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.            
--where Activityname in (''Plan_30_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.            
--where Activityname in (''Plan_30_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_30_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_30_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
--'            
--Exec (@sql)             
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=16.5            
where Activityname in (''Plan_33_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=19.5            
where Activityname in (''Plan_33_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=19.5            
where Activityname in (''Plan_33_3'') and RES_TIER not in (''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=19.5             
where Activityname in (''Plan_33_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.            
--where Activityname in (''Plan_33_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.            
--where Activityname in (''Plan_33_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.            
--where Activityname in (''Plan_33_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.            
--where Activityname in (''Plan_33_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
EXec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.5            
where Activityname in (''Plan_39_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.5            
where Activityname in (''Plan_39_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.5            
where Activityname in (''Plan_39_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.5            
where Activityname in (''Plan_39_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=17.            
--where Activityname in (''Plan_39_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.8            
--where Activityname in (''Plan_39_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.8            
--where Activityname in (''Plan_39_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=17.            
--where Activityname in (''Plan_39_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec (@sql)             
            
    Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=30.5            
where Activityname in (''Plan_49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=30.5             
where Activityname in (''Plan_49_2'') and RES_TIER not in (''DP'',''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=30.5             
where Activityname in (''Plan_49_3'') and RES_TIER not in (''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=30.5             
where Activityname in (''Plan_49_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=25.            
--where Activityname in (''Plan_49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=22.            
--where Activityname in (''Plan_49_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=22.            
--where Activityname in (''Plan_49_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=22.            
--where Activityname in (''Plan_49_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
            
'            
Exec (@sql)             
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=36.5            
where Activityname in (''Plan_59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=36.5            
where Activityname in (''Plan_59_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=36.5            
where Activityname in (''Plan_59_3'') and RES_TIER not in (''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=36.5            
where Activityname in (''Plan_59_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=28.            
--where Activityname in (''Plan_59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.            
--where Activityname in (''Plan_59_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.            
--where Activityname in (''Plan_59_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=24.            
--where Activityname in (''Plan_59_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
            
'            
Exec (@sql)             
            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.75            
where Activityname in (''Plan_ch29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=9.25            
where Activityname in (''Plan_ch29_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=9.25             
where Activityname in (''Plan_ch29_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=9.25             
where Activityname in (''Plan_ch29_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.            
--where Activityname in (''Plan_ch29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.            
--where Activityname in (''Plan_ch29_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=6.75            
--where Activityname in (''Plan_ch29_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.5            
--where Activityname in (''Plan_ch29_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec (@sql)             
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.25            
where Activityname in (''Plan_ch49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.25             
where Activityname in (''Plan_ch49_2'') and RES_TIER not in (''DP'',''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.25             
where Activityname in (''Plan_ch49_3'') and RES_TIER not in (''TP'',''NI'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=15.25             
where Activityname in (''Plan_ch49_4'') and RES_TIER not in (''NI'') and isnull(noofmonths,0)<''4''            
            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.5            
--where Activityname in (''Plan_ch49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.            
--where Activityname in (''Plan_ch49_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.            
--where Activityname in (''Plan_ch49_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=11.            
--where Activityname in (''Plan_ch49_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec (@sql)             
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.25            
where Activityname in (''Plan_ch59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.25            
where Activityname in (''Plan_ch59_2'') and RES_TIER not in (''DP'',''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.25            
where Activityname in (''Plan_ch59_3'') and RES_TIER not in (''TP'',''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=18.25            
where Activityname in (''Plan_ch59_4'') and RES_TIER not in (''NI'')  and isnull(noofmonths,0)<''4''            
            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=14.            
--where Activityname in (''Plan_ch59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_ch59_2'') and RES_TIER not in (''DP'',''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_ch59_3'') and RES_TIER not in (''TP'',''NI'') and RES_T2M_TYPE=''Silver''             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
--where Activityname in (''Plan_ch59_4'') and RES_TIER not in (''NI'') and RES_T2M_TYPE=''Silver'' and isnull(noofmonths,0)<''4''            
            
'            
Exec (@sql)             
            
Set @Sql='            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=2.            
where Activityname in (''Portin_Plan_15_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
where Activityname in (''Portin_Plan_19_4'',''Portin_Plan_23_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.            
where Activityname in (''Portin_Plan_29_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.            
where Activityname in (''Portin_Plan_33_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=9.            
where Activityname in (''Portin_Plan_39_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=10.            
where Activityname in (''Portin_Plan_49_4'') and RES_TIER not in (''NI'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=12.            
where Activityname in (''Portin_Plan_59_4'') and RES_TIER not in (''NI'')             
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
--where Activityname in (''Portin_Plan_15_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''      
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=3.            
--where Activityname in (''Portin_Plan_19_4'',''Portin_Plan_23_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Portin_Plan_29_4'',''Portin_Plan_33_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Portin_Plan_39_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.            
--where Activityname in (''Portin_Plan_49_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=7.            
--where Activityname in (''Portin_Plan_59_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=2.            
--where Activityname in (''Portin_Plan_1012_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Platinum''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
--where Activityname in (''Portin_Plan_1012_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=3.5            
--where Activityname in (''Portin_Plan_CH29_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Platinum''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Portin_Plan_CH49_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Platinum''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=5.            
--where Activityname in (''Portin_Plan_CH59_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Platinum''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=2.5            
--where Activityname in (''Portin_Plan_CH29_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=3.5            
--where Activityname in (''Portin_Plan_CH49_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=3.5            
--where Activityname in (''Portin_Plan_CH59_4'') and RES_TIER not in (''NI'') AND RES_T2M_TYPE=''Silver''            
            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.03            
where Activityname in (''Residual_12_AR'')             
and RES_Residual_TIER Like ''TIER%''             
and RES_BUNDLE_1>=''2000''            
and RES_T1M_TYPE=''Silver''            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.03            
where Activityname in (''Residual_12_AR'')             
and RES_Residual_TIER=''TIER1''             
and RES_BUNDLE_1>=''2000''            
and RES_T1M_TYPE=''Platinum''            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.05            
where Activityname in (''Residual_12_AR'')             
and RES_Residual_TIER=''TIER2''             
and RES_BUNDLE_1>=''2000''            
and RES_T1M_TYPE=''Platinum''            
             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.075            
where Activityname in (''Residual_12_AR'')             
and RES_Residual_TIER=''TIER3''             
and RES_BUNDLE_1>=''2000''            
and RES_T1M_TYPE=''Platinum''            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.1            
where Activityname in (''Residual_12_AR'')             
and RES_Residual_TIER=''TIER4''             
and RES_BUNDLE_1>=''2000''            
and RES_T1M_TYPE=''Platinum''            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=BUNDLE_VALUE*0.075            
where Activityname in (''Residual_12_AR'')             
and Resellerid=''LMPUS-SIM-PF-EPAYPAYSPOT''            
and convert(varchar(10),activitydate,120)>=''2024-10-14''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_24_R'',''Residual_12_R'',''Residual_24_AR'') and isnull(noofmonths,0)=''5'' and Bundle_seq<=5 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_24_R'',''Residual_12_R'',''Residual_24_AR'') and isnull(noofmonths,0)=''6'' and Bundle_seq<=6 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_24_R'',''Residual_12_R'',''Residual_24_AR'') and isnull(noofmonths,0)=''12'' and Bundle_seq<=12 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_24_R'',''Residual_12_R'',''Residual_24_AR'') and iccid in (select iccid from ##Iccid_12month )            
'            
Exec (@sql)             
            
--Set @Sql='            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0.5            
--where Activityname in (''Bundle_1'')  and RES_AS_TIER like ''Tier%'' and RES_T2M_TYPE in (''Silver'')             
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
--where Activityname in (''Bundle_2'')  and RES_AS_TIER like ''Tier%'' and RES_T2M_TYPE in (''Silver'')'            
--Exec (@sql)             
            
Set @Sql='            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0.5            
where Activityname in (''Bundle_1'')  and RES_AS_TIER=''Tier1'' --and RES_T2M_TYPE in (''Platinum'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0.75            
where Activityname in (''Bundle_2'')  and RES_AS_TIER=''Tier1'' --and RES_T2M_TYPE in (''Platinum'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0.75            
where Activityname in (''Bundle_1'')  and RES_AS_TIER=''Tier2'' --and RES_T2M_TYPE in (''Platinum'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
where Activityname in (''Bundle_2'')  and RES_AS_TIER=''Tier2'' --and RES_T2M_TYPE in (''Platinum'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
where Activityname in (''Bundle_1'')  and RES_AS_TIER=''Tier3'' --and RES_T2M_TYPE in (''Platinum'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.25            
where Activityname in (''Bundle_2'')  and RES_AS_TIER=''Tier3'' --and RES_T2M_TYPE in (''Platinum'')             
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.            
where Activityname in (''Bundle_1'')  and RES_AS_TIER=''Tier4'' --and RES_T2M_TYPE in (''Platinum'')              
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=1.5            
where Activityname in (''Bundle_2'')  and RES_AS_TIER=''Tier4'' --and RES_T2M_TYPE in (''Platinum'')             
'            
Exec (@sql)             
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0.            
where  resellerid in ('LMPUS-SIM-PF-LI-7ELEVEN','LMPUS-SIM-PF-LI-TARGET','LMPUS-SIM-PF-TARGET')            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=40.            
where Activityname in ('Bundle_1')              
and resellerid in ('LMPUS-SIM-PF-LI-TARGET','LMPUS-SIM-PF-TARGET')            
            
Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=8.            
where Activityname in ('Bundle_1')              
and resellerid in ('LMPUS-SIM-PF-LI-7ELEVEN')            
            
            
--Set @Sql='            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0           
--where Activityname in (''Bundle_1'',''Bundle_2'')             
--and offmgrid  in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',            
--''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')            
            
--Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where Activityname in (''Bundle_1'',''Bundle_2'')             
--and isnull(Gateway_Offmgr,Wholesalerid)<>Wholesalerid            
--and RESELLER_COMM<>0            
--'            
--Exec (@sql)            
            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where (Wholesalerid in (''GLOBAL LINK'',''EAHASOLUTIONSINC'') or Offmgrid in (''GLOBAL LINK'',''EAHASOLUTIONSINC''))            
--and Convert(varchar(10),activitydate,120)>=''2023-06-21'''            
--Exec (@sql)            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RESELLER_COMM=0            
--where (Wholesalerid in (''BNK US'',''EK WIRELESS'') or Offmgrid in (''BNK US'',''EK WIRELESS''))            
--and Convert(varchar(10),activitydate,120)>=''2023-08-11'''            
--Exec (@sql)            
            
--Retailer comm            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=0            
            
Set @Sql='IF OBJECT_ID(''tempdb..##Retailer'') IS NOT NULL                  
drop table ##Retailer            
            
select Retailerid into ##Retailer from Mvnoreport_usa_lm.dbo.vw_dsmretailer            
where offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')'            
Exec (@sql)            
            
            
--New            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=7           
where Activityname in (''Plan_15_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6            
where Activityname in (''Plan_15_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6             
where Activityname in (''Plan_15_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6            
where Activityname in (''Plan_15_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)            
            
--new            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=10            
where Activityname in (''Plan_19_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=11            
where Activityname in (''Plan_19_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=11            
where Activityname in (''Plan_19_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=11             
where Activityname in (''Plan_19_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)            
--New            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=11.            
where Activityname in (''Plan_23_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12           
where Activityname in (''Plan_23_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12            
where Activityname in (''Plan_23_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12            
where Activityname in (''Plan_23_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)            
--New            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=15.            
where Activityname in (''Plan_29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18            
where Activityname in (''Plan_29_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18            
where Activityname in (''Plan_29_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18            
where Activityname in (''Plan_29_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=15.            
where Activityname in (''Plan_29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>=''2024-12-09''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18             
where Activityname in (''Plan_29_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>=''2024-12-09''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18.            
where Activityname in (''Plan_29_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>=''2024-12-09''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=18             
where Activityname in (''Plan_29_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>=''2024-12-09''            
'            
Exec (@sql)            
            
            
--new            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=16            
where Activityname in (''Plan_33_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19            
where Activityname in (''Plan_33_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19            
where Activityname in (''Plan_33_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19            
where Activityname in (''Plan_33_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=16             
where Activityname in (''Plan_33_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19             
where Activityname in (''Plan_33_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19            
where Activityname in (''Plan_33_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=19            
where Activityname in (''Plan_33_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
'            
Exec (@sql)            
--new            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''  
and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
'            
Exec (@sql)            
            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24             
where Activityname in (''Plan_39_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24            
where Activityname in (''Plan_39_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2024-12-08''            
'            
Exec (@sql)            
--new            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=30.            
where Activityname in (''Plan_49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=30.            
where Activityname in (''Plan_49_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=30.            
where Activityname in (''Plan_49_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=30.            
where Activityname in (''Plan_49_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)            
            
  --New            
Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=36            
where Activityname in (''Plan_59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=36            
where Activityname in (''Plan_59_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=36            
where Activityname in (''Plan_59_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=36            
where Activityname in (''Plan_59_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)         
      
	  -----------------------------------------CH-PLAN
            
----New            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.5            
--where Activityname in (''Plan_CH29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.75            
--where Activityname in (''Plan_CH29_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.            
--where Activityname in (''Plan_CH29_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=7.5            
--where Activityname in (''Plan_CH29_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
--and convert(varchar(10),Activitydate,120)<=''2024-12-08''            
--'            
--Exec (@sql)            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.5            
--where Activityname in (''Plan_CH29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.75            
--where Activityname in (''Plan_CH29_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.            
--where Activityname in (''Plan_CH29_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2024-12-08''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=7.5            
--where Activityname in (''Plan_CH29_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
--and convert(varchar(10),Activitydate,120)>''2024-12-08''            
--'            
--Exec (@sql)            
----New            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=15.            
--where Activityname in (''Plan_CH49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=10.            
--where Activityname in (''Plan_CH49_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=10.            
--where Activityname in (''Plan_CH49_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=10.            
--where Activityname in (''Plan_CH49_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--'            
--Exec (@sql)            
            
----New            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=17.5            
--where Activityname in (''Plan_CH59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12.            
--where Activityname in (''Plan_CH59_2'') and RES_TIER not in (''DP'',''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12.            
--where Activityname in (''Plan_CH59_3'') and RES_TIER not in (''TP'',''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=12.            
--where Activityname in (''Plan_CH59_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer ) and isnull(noofmonths,0)<''4''            
--and convert(varchar(10),Activitydate,120)>''2023-09-07''            
--'            
--Exec (@sql)            
            
--New            
Set @Sql='            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=1.            
where Activityname in (''Portin_Plan_15_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=3.            
where Activityname in (''Portin_Plan_19_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=4.            
where Activityname in (''Portin_Plan_23_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=6.            
where Activityname in (''Portin_Plan_29_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=7.            
where Activityname in (''Portin_Plan_33_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=8.            
where Activityname in (''Portin_Plan_39_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=9.            
where Activityname in (''Portin_Plan_49_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=10.            
where Activityname in (''Portin_Plan_59_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=1.            
where Activityname in (''Portin_Plan_1012_4'') and RES_TIER not in (''NI'',''NI_WS'') and Retailerid in (select Retailerid From ##Retailer )            
and convert(varchar(10),Activitydate,120)>''2023-09-07''            
'            
Exec (@sql)            
          
---Special retailer commission effective from 20230108 and updated script on 20230905            
            
--Set @Sql='Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=14.            
--where Activityname in (''Plan_19_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=20.            
--where Activityname in (''Plan_23_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=24.            
--where Activityname in (''Plan_29_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=28.            
--where Activityname in (''Plan_33_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=34.            
--where Activityname in (''Plan_39_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=36.            
--where Activityname in (''Plan_49_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=38.            
--where Activityname in (''Plan_59_1'') and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')             
--and Retailerid in (select Retailerid From Mis_1717_USA_Retailer_group_master_202309             
--where groupname=''No Sim Activation 3month Retailer 202308'')'            
--Exec (@sql)            
            
            
Set @Sql='            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.03            
where Activityname in (''Residual_12_AR'')  and Retailerid in (select Retailerid From ##Retailer )            
and RET_T1M_TYPE=''Silver''            
and RET_Bundle_1>2 and RET_RESIDUAL_TIER like ''TIER%''            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.03            
where Activityname in (''Residual_12_AR'')  and Retailerid in (select Retailerid From ##Retailer )            
and RET_T1M_TYPE=''Platinum''            
and RET_Bundle_1>2 and RET_RESIDUAL_TIER=''TIER1''            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.06            
where Activityname in (''Residual_12_AR'')  and Retailerid in (select Retailerid From ##Retailer )            
and RET_T1M_TYPE=''Platinum''            
and RET_Bundle_1>2 and RET_RESIDUAL_TIER=''TIER2''            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.08            
where Activityname in (''Residual_12_AR'')  and Retailerid in (select Retailerid From ##Retailer )            
and RET_T1M_TYPE=''Platinum''            
and RET_Bundle_1>2 and RET_RESIDUAL_TIER=''TIER3''            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.12            
where Activityname in (''Residual_12_AR'')  and Retailerid in (select Retailerid From ##Retailer )            
and RET_T1M_TYPE=''Platinum''            
and RET_Bundle_1>2 and RET_RESIDUAL_TIER=''TIER4''            
            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=BUNDLE_VALUE*0.19            
where Activityname in (''Residual_12_AR'',''Residual_12_R'') and RES_TYPE LIKE ''%HP%'' and Retailerid in (select Retailerid From ##Retailer )            
and ACCMGRID like ''%EUROPEAN AGENCY%''            
            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_12_R'') and isnull(noofmonths,0)=''5'' and Bundle_seq<=5 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_12_R'') and isnull(noofmonths,0)=''6'' and Bundle_seq<=6 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_12_R'') and isnull(noofmonths,0)=''12'' and Bundle_seq<=12 and Bundle_seq<>''Addon''            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=0            
--where Activityname in (''Residual_12_AR'',''Residual_12_R'') and iccid in (select iccid from ##Iccid_12month )            
            
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=40.            
where Activityname in (''Plan_12M_1012_10'') and Retailerid in (select Retailerid From ##Retailer ) and RES_TIER not in (''DP'',''TP'',''LI'',''NI'',''NI_WS'')'            
Exec (@sql)            
            
            
--Alter table Mis_1717_USA_Detail_comm add Comm_Type varchar(100)            
            
--if object_id ('Mis_1717_USA_Detail_comm_double') is not null            
--DROP TABLE Mis_1717_USA_Detail_comm_double            
            
--if object_id ('Mis_1717_USA_Detail_comm_UNIQUE') is not null            
--DROP TABLE Mis_1717_USA_Detail_comm_UNIQUE            
            
            
            
--select *,row_number() over(partition by Retailerid order by activitydate) newrno            
--into Mis_1717_USA_Detail_comm_double            
--from Mis_1717_USA_Detail_comm where activityname in ('Plan_15_1','Plan_19_1','Plan_23_1','Plan_29_1','Plan_33_1','Plan_39_1','Plan_49_1','Plan_59_1')            
--AND Retailerid in (select Retailerid From Mis_1717_USA_Double_incentive_202509 )            
            
            
--Update Mis_1717_USA_Detail_comm_double Set RETAILER_COMM=RETAILER_COMM*2            
--where  Activityname in  ('Plan_15_1','Plan_19_1','Plan_23_1','Plan_29_1','Plan_33_1','Plan_39_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_double Set RETAILER_COMM=49.0            
--where  Activityname in  ('Plan_49_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_double Set RETAILER_COMM=59.0            
--where  Activityname in  ('Plan_59_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=B.RETAILER_COMM,Comm_Type='Double'            
--FROM Mis_1717_USA_Detail_comm A,Mis_1717_USA_Detail_comm_double B            
--WHERE A.ICCID=B.ICCID            
--AND A.Activityname=B.Activityname            
--AND A.RETAILERID=B.RETAILERID            
--AND b.newrno<=100            
            
--select *,row_number() over(partition by Retailerid order by activitydate) newrno         
--into Mis_1717_USA_Detail_comm_UNIQUE            
--from Mis_1717_USA_Detail_comm where activityname in ('Plan_15_1','Plan_19_1','Plan_23_1','Plan_29_1','Plan_33_1','Plan_39_1','Plan_49_1','Plan_59_1')            
--AND Retailerid in (select Retailerid From Mis_1717_USA_UNIQUE_UAO_incentive_202509 )            
            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=10.0            
--where  Activityname in  ('Plan_15_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=14.0            
--where  Activityname in  ('Plan_19_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=17.0            
--where  Activityname in  ('Plan_23_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=20.0            
--where  Activityname in  ('Plan_29_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=23.0            
--where  Activityname in  ('Plan_33_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=27.0            
--where  Activityname in  ('Plan_39_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=45.0            
--where  Activityname in  ('Plan_49_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm_UNIQUE Set RETAILER_COMM=53.0            
--where  Activityname in  ('Plan_59_1')            
--AND newrno<=100            
--and convert(varchar(10),Activitydate,120) between '2025-09-01' and '2025-09-30'            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=B.RETAILER_COMM,Comm_Type='Unique'            
--FROM Mis_1717_USA_Detail_comm A,Mis_1717_USA_Detail_comm_UNIQUE B            
--WHERE A.ICCID=B.ICCID            
--AND A.Activityname=B.Activityname            
--AND A.RETAILERID=B.RETAILERID            
--AND b.newrno<=100            
            
Update Mis_1717_USA_Detail_comm Set Comm_Type='Normal' where Comm_Type is null            
            
--Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=RETAILER_COMM*1.5            
--where  Retailerid in (select Retailerid from MVNOREPORT_USA_LM.dbo.vw_dsmretailer where convert(varchar(07),createddate,120)=convert(varchar(07),getdate()-10,120) )            
--and (Activityname like 'Plan_15%'             
--or Activityname like 'Plan_19%'             
--or Activityname like 'Plan_23%'             
--or Activityname like 'Plan_29%'             
--or Activityname like 'Plan_33%'             
--or Activityname like 'Plan_39%'             
--or Activityname like 'Plan_49%'             
--or Activityname like 'Plan_59%')            
        
        
--CREATE TABLE Mis_1717_USA_Detail_comm_block(        
--RETAILERID VARCHAR(50)        
--)        
        
        
-----------------------block retalilers------        
        
--if object_id ('Mis_1717_USA_Detail_comm_block') is not null            
--DROP TABLE Mis_1717_USA_Detail_comm_block         
        
Update Mis_1717_USA_Detail_comm Set RETAILER_COMM=RETAILER_COMM*0.5,Comm_Type='RETAILER_BLOCK'            
FROM Mis_1717_USA_Detail_comm A,Mis_1717_USA_Detail_comm_block B            
WHERE A.RETAILERID=B.RETAILERID            
        
            
            
  SELECT CONVERT(VARCHAR(07),ACTIVITYDATE,120) MONTHS ,ICCID,ACTIVITYNAME,ACTIVITYDATE,RESELLERID,BUNDLE_CODE,BUNDLE_NAME,BUNDLE_SEQ ,CASE WHEN BUNDLE_SEQ=1 THEN '1'          
 WHEN BUNDLE_SEQ=2 THEN '5'          
  WHEN BUNDLE_SEQ=3 THEN '5'          
   WHEN BUNDLE_SEQ=4 THEN '4' END COMMISSION          
 FROM Mis_1717_USA_Detail_comm WHERE RESELLERID ='LMPUS-SIM-PF-LI-UNICONNEC'          
 AND ACTIVITYNAME LIKE 'PLAN%' AND Portout_Status IS NULL AND Portineligible IS NULL           
            
            
Set @Sql='            
IF OBJECT_ID(''Mis_1717_USA_Detail_comm_'+@month1+''') is not null            
Drop table Mis_1717_USA_Detail_comm_'+@month1+'            
            
select * into Mis_1717_USA_Detail_comm_'+@month1+' from  Mis_1717_USA_Detail_comm'            
Exec (@sql)            
            
Set @Sql='Select Count(*) from Mis_1717_USA_Detail_comm'            
Exec (@sql)            
            
END 











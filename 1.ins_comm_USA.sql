       
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20230718>                         
-- Modify date: <>                        
-- Description: <USA_KB_Instant commission table>                          
-- =============================================                          
create  procedure MIS_1717_USA_01_Retailer_INS_COMM_DETAIL_New_no_live  
as   
begin  
  
  
Declare @Month_112 varchar(6)  
declare @sql nvarchar(max)  
Set @Month_112=convert(varchar(06),getdate()-10,112)  
Select @Month_112  
  
set @sql='IF OBJECT_ID(''tempdb.dbo.##bt'') is not null  
drop table ##bt  
select transaction_id,cdr_time_stamp into ##bt from USA_CDR.dbo.balance_transfer with(nolock)'  
Exec (@sql)  
  
set @sql='  
IF OBJECT_ID(''tempdb.dbo.##ins'') is not null  
drop table ##ins  
select *,Row_number() over(partition by commision_tranid,Topupseq  order by Cons_RRBS_TransactionId) Rownum   
into ##ins from mvno_usa.dbo.TopupBundle_Commission_detailed A with (nolock)   
where convert(varchar(06),reportdate,112)='''+@Month_112+''''  
Exec (@sql)  
   
set @sql='IF OBJECT_ID(''tempdb.dbo.##ins1'') is not null  
drop table ##ins1  
Select * into ##ins1 from ##ins  
where ROwnum=''1'''  
Exec (@sql)  
   
set @sql='IF OBJECT_ID(''mvnoreport_usa_gt.dbo.mis_1717_ins_comm'') is not null  
drop table mis_1717_ins_comm  
select Brand,TopupSeq,MSISDN,Pinnumber,reportdate,TopupDate,face_value,Iccidprefix,Iccid,bundlecode,  
Operation_code,Payment_Mode,ProductName,Resellerid,OffMgrID,accMgrID,hotspotID,retailerid,  
retailer_comm,commision_tranid,RRBS_TransactionId,b.transaction_id into mis_1717_ins_comm   
from  ##ins1 a  
left join  
##bt b  
on a.commision_tranid=b.transaction_id  
where isnull(a.retailer_comm,0)<>0'  
Exec (@sql)  
  
set @sql='IF OBJECT_ID(''tempdb.dbo.##TRN'') is not null  
drop table ##TRN  
select resellerid,iccid_fr,iccid_to into ##TRN from MVNOREPORT_USA_LM..Vw_TrnActivation'  
Exec (@sql)  
  
set @sql='create index id on ##TRN(iccid_fr,iccid_to)'  
Exec (@sql)  
  
set @sql='update a  
set a.resellerid=b.resellerid  
from mis_1717_ins_comm  a join ##TRN b  
on LEFT(iccid,11) between b.iccid_fr and b.iccid_to'  
Exec (@sql)  
  
set @sql='update mis_1717_ins_comm   
set brand=''LMPLUS''  
where Resellerid like ''LMPUS%'''  
Exec (@sql)  
  
set @sql='update mis_1717_ins_comm   
set brand=''LM''  
where Resellerid like ''LMUS%'''  
Exec (@sql)  
  
set @sql='alter table mis_1717_ins_comm   add LI_Status varchar(20)'  
Exec (@sql)  
  
  
set @sql='update mis_1717_ins_comm   
set LI_Status=''non_li_sims''  
where resellerid not like ''%-LI-%'''  
Exec (@sql)   
  
set @sql='update mis_1717_ins_comm   
set LI_Status=''li_sims''  
where resellerid like ''%-LI-%'''  
Exec (@sql)   
  
set @sql='Alter table Mis_1717_ins_comm add RES_TYPE Varchar(20)'  
Exec (@sql)   
  
update Mis_1717_ins_comm set RES_TYPE='WS_DP' where RESELLERID like '%-WS-DP-%'  
update Mis_1717_ins_comm set RES_TYPE='WS_DP' where RESELLERID like '%-WS-%-DP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_TP' where RESELLERID like '%-WS-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_TP' where RESELLERID like '%-WS-%-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_LI' where RESELLERID like '%-WS-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_LI' where RESELLERID like '%-WS-%-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_NI' where RESELLERID like '%-WS-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS_NI' where RESELLERID like '%-WS-%-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_DP' where RESELLERID like '%-HP-DP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_DP' where RESELLERID like '%-HP-%-DP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_TP' where RESELLERID like '%-HP-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_TP' where RESELLERID like '%-HP-%-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_LI' where RESELLERID like '%-HP-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_LI' where RESELLERID like '%-HP-%-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_NI' where RESELLERID like '%-HP-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP_NI' where RESELLERID like '%-HP-%-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='HP' where RESELLERID like '%-HP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='WS' where RESELLERID like '%-WS-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_DP' where RESELLERID like '%-PF-DP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_DP' where RESELLERID like '%-PF-%-DP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_TP' where RESELLERID like '%-PF-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_TP' where RESELLERID like '%-PF-%-TP-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_LI' where RESELLERID like '%-PF-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_LI' where RESELLERID like '%-PF-%-LI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_NI' where RESELLERID like '%-PF-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF_NI' where RESELLERID like '%-PF-%-NI-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='PF' where RESELLERID like '%-PF-%' and RES_TYPE IS NULL  
update Mis_1717_ins_comm set RES_TYPE='Others' where RES_TYPE IS NULL  
  

Set @sql='  
IF OBJECT_ID(''mis_1717_ins_comm_staff_mapping'') is not null  
Drop table mis_1717_ins_comm_staff_mapping  

select UserID,CreatedBy retailerid,virtual_msisdn into  mis_1717_ins_comm_staff_mapping from [Vw_wlmstaffretailer]

alter table  mis_1717_ins_comm_staff_mapping add offmgrid varchar(50),accmgrid varchar (50),hotspotid varchar(50)

update a 
set a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from mis_1717_ins_comm_staff_mapping a ,mvnoreport_usa_lm..vw_dsmretailer b
where a.retailerid=b.retailerid
'
Exec (@sql)  

set @sql='

update a
set a.retailerid=b.retailerid,a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from Mis_1717_ins_comm a,mis_1717_ins_comm_staff_mapping b
where a.retailerid=b.userid
'
Exec (@sql) 


Set @sql='  
IF OBJECT_ID(''mis_1717_ins_comm_'+@Month_112+''') is not null  
Drop table mis_1717_ins_comm_'+@Month_112+'  
select * into  mis_1717_ins_comm_'+@Month_112+' from mis_1717_ins_comm'  
Exec (@sql)  
  
Set @sql='Delete from mis_1717_ins_comm  
where Convert(varchar(6),Topupdate,112)<'''+@Month_112+''' and Retailer_comm<0 '  
Exec (@sql)  
  
Select 'OUTPUT'  
Set @sql='Select * from Mis_1717_ins_comm'  
Exec (@sql)  
  
  
end  


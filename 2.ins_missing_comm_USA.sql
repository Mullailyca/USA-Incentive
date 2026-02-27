        
-- =============================================                          
-- Author:  <Arjundev>                          
-- Create date: <20240104>                         
-- Modify date: <>                        
-- Description: <USA_KB_Instant commission missing & mismatch>                          
-- =============================================                          
alter  procedure MIS_1717_USA_01_Retailer_INS_COMM_DETAIL_Missing  
as   
begin  
  
  
  
Declare @Month_112 varchar(6)  
declare @sql nvarchar(max)  
Set @Month_112=convert(varchar(06),getdate()-10,112)  
  
Select @Month_112  
  
Set @sql='  
IF OBJECT_ID(''tempdb.dbo.##Deva'') is not null  
drop table ##Deva  
Select Pinnumber,Retailer_comm,commision_tranid into ##Deva from Mis_1717_ins_comm_'+@Month_112+''  
Exec (@sql)  
  
Set @sql='  
IF OBJECT_ID(''Mis_1717_USA_Missing_IC_'+@Month_112+''') is not null  
Drop table Mis_1717_USA_Missing_IC_'+@Month_112+'  
  
Select CDR_Type, Network_ID, Service_ID, MSISDN_NO, IMSI, Receiver_MSISDN, Account_balance, Amount_Transferred, Final_Account_balance, Operation_code, Transaction_ID,  
CDR_Time_Stamp,Dedicated_Account_Balance, Amount_Detected_from_Dedicated_Balance, Final_Balance_in_Dedicated_Account,Retailer_Commission, Retailer_Discount  
Into Mis_1717_USA_Missing_IC_'+@Month_112+'  
 from usa_cdr.dbo.balance_transfer  
where left(cdr_time_stamp,6) in ('''+@Month_112+''')  
and transaction_id  not in   
(Select Pinnumber from ##Deva)  
and retailer_commission>0  
order by cdr_time_stamp'  
Exec (@sql)  
  
  
Set @sql='  
Alter table Mis_1717_USA_Missing_IC_'+@Month_112+'   
add OffMgrID varchar(100),accMgrID varchar(100),hotspotID varchar(100),retailerid varchar(100)'  
Exec (@sql)  

set @sql='
update a
set a.retailerid=b.retailerid,a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from Mis_1717_USA_Missing_IC_'+@Month_112+' a,mis_1717_ins_comm_staff_mapping b
where a.msisdn_no=b.virtual_msisdn
'
Exec (@sql)
  
Set @sql='update Mis_1717_USA_Missing_IC_'+@Month_112+' set OffMgrID=b.OffMgrID,accMgrID=b.accMgrID,hotspotID=b.hotspotID,retailerid=b.retailerid  
from Mis_1717_USA_Missing_IC_'+@Month_112+' a, MVNOREPORT_USA_LM.dbo.vw_dsmretailer b  
where a.msisdn_no=b.virtual_msisdn'  
Exec (@sql)  
  
Select 'Missing_IC'  
Set @sql='Select * from Mis_1717_USA_Missing_IC_'+@Month_112+''  
Exec (@sql)  
  
Set @sql='  
IF OBJECT_ID(''tempdb.dbo.##Deva1'') is not null  
drop table ##Deva1  
Select Pinnumber,Sum(Retailer_comm) Retailer_comm into ##Deva1 from ##Deva  
group by Pinnumber'  
Exec (@sql)  
  
Set @sql='  
IF OBJECT_ID(''Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch'') is not null  
Drop table Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch  
  
Select CDR_Type, Network_ID, Service_ID, MSISDN_NO, IMSI, Receiver_MSISDN, Account_balance, Amount_Transferred, Final_Account_balance, Operation_code, Transaction_ID,  
CDR_Time_Stamp,Dedicated_Account_Balance, Amount_Detected_from_Dedicated_Balance, Final_Balance_in_Dedicated_Account,Retailer_Commission, Retailer_Discount,b.Retailer_comm Retailer_comm_instant_table  
Into Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch  
 from usa_cdr.dbo.balance_transfer a,##Deva1 b  
where left(cdr_time_stamp,6) in ('''+@Month_112+''')  
and A.transaction_id  =b.Pinnumber  
and a.retailer_commission>0  
and A.Retailer_Commission<>b.Retailer_comm  
and b.Retailer_comm>0'  
Exec (@sql)  
  
  
Set @sql='Alter table Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch   
add OffMgrID varchar(100),accMgrID varchar(100),hotspotID varchar(100),retailerid varchar(100),OVERPAY INT'  
Exec (@sql)  

set @sql='
update a
set a.retailerid=b.retailerid,a.offmgrid=b.offmgrid,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch a,mis_1717_ins_comm_staff_mapping b
where a.msisdn_no=b.virtual_msisdn
'
Exec (@sql)
 
  
Set @sql='update Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch set OffMgrID=b.OffMgrID,accMgrID=b.accMgrID,hotspotID=b.hotspotID,retailerid=b.retailerid  
from Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch a, MVNOREPORT_USA_LM.dbo.vw_dsmretailer b  
where a.msisdn_no=b.virtual_msisdn'  
Exec (@sql)  
  
Set @sql='  
  
UPDATE Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch SET OVERPAY=Retailer_Commission-Retailer_comm_instant_table  
'  
Exec (@sql)  
  
Select 'Mismatch_IC'  
Set @sql='Select * from Mis_1717_USA_Missing_IC_'+@Month_112+'_mismatch'  
Exec (@sql)  
  
End  
  
  
  
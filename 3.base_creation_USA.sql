USE [MVNOREPORT_USA_GT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- =============================================                        
-- Author:  <Arjundev>                        
-- Create date: <20230302>                       
-- Modify date: <>                      
-- Description: <USA_KB_Base creation>                        
-- =============================================                        
Alter procedure MIS_1717_USA_02_Base_creation
as 
begin

----select * into MIS_1717_BS_wrkard_master_dontdrop_month from MIS_1717_BS_wrkard_master_dontdrop_month_202507

--Sp_rename 'MIS_1717_BS_wrkard_master_dontdrop_month','MIS_1717_BS_wrkard_master_dontdrop_month_202507'


Declare @Sql varchar(max)
Declare @month Varchar(10)
Declare @month1 Varchar(10)
Declare @Year Varchar(4)
Declare @MM Varchar(2)

Set @month=convert(varchar(07),Dateadd(mm,-1,Getdate()),120) 
Set @month1=convert(varchar(06),Dateadd(mm,-1,Getdate()),112) 
Set @Year=convert(varchar(04),Dateadd(mm,-1,Getdate()),112) 
Set @MM=right((convert(varchar(06),Dateadd(mm,-1,Getdate()),112)),2)

Select @month,@month1,@Year,@MM

Set @Sql='delete from [MIS_1717_BS_wrkard_master_dontdrop]
where   convert(varchar(07),topupdate,120)='''+@month+''''
Exec (@Sql)


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
where operation_code in (''5'',''12'',''14'',''25'',''26'',''27'') 
--and bundle_code not in (''668851'',''668855'',''668852'',''668853'',''668854'',''885566'',''885577'',''3010'',''3020'',''3005'',''1110'',
--''121035'',''131023'',''131039'',''445566'',''445567'',''445570'',''668899'',''777331'',''778853'',''888813'')
and left(recharge_date,6)='+@month1+') x   
'
Exec (@Sql)
--Select Distinct Special_topup_amount,bundle_code,bundle_name,payment_mode from ##mis_1717_bundle_cdr_stg where bundle_name like 'add%'


Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
where transaction_id in (Select order_id from usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup
where operation_code in (''6'') and Forcible_Cancellation<>''1'')'
Exec (@Sql)


Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
where transaction_id in (
Select Reservation_Reference_Transaction_Id from  usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup
where operation_code=''30'')'
Exec (@Sql)

Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
where RRBS_Transaction_Id in (
Select RRBS_Transaction_Id from  usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup
where operation_code=''30'')'
Exec (@Sql)


Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
where Transaction_Id in (
Select pinnumber from  mis_1717_ins_comm
where retailer_comm<0)'
Exec (@Sql)



--Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
--where RRBS_Transaction_Id in (
--Select RRBS_Transaction_Id from  usa_hrrbs.usa_month08_2023.dbo.Vw_topup
--where operation_code=''30'')'
--Exec (@Sql)


Set @Sql='Delete from ##mis_1717_bundle_cdr_stg
where  bundle_code in (''668851'',''668855'',''668852'',''668853'',''668854'',''885566'',''885577'',''3010'',''3020'',''3005'',''1110'',
''121035'',''131023'',''131039'',''445566'',''445567'',''445570'',''668899'',''777331'',''778853'',''888813'')'
Exec (@Sql)


Set @Sql='delete from ##mis_1717_bundle_cdr_stg where bundle_name like ''add%'''
Exec (@Sql)


--Select Distinct Special_topup_amount,bundle_code,bundle_name,payment_mode from ##mis_1717_bundle_cdr_stg where bundle_name like '%addon%'

Set @Sql='delete from ##mis_1717_bundle_cdr_stg where bundle_name like ''%addon%'''
Exec (@Sql)


--Select Distinct Special_topup_amount,bundle_code,bundle_name,payment_mode from ##mis_1717_bundle_cdr_stg where bundle_name like '%Free%'

Set @Sql='delete from ##mis_1717_bundle_cdr_stg  where bundle_name like ''%Free%'''
Exec (@Sql)



Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##Test'') is not null
drop table ##Test

select * into ##Test from ##mis_1717_bundle_cdr_stg    
where operation_code in (''25'',''26'',''27'')'
Exec (@sql)

Set @Sql='
delete a     
from ##mis_1717_bundle_cdr_stg a join ##Test b    
on a.Reservation_Reference_Transaction_Id=b.RRBS_Transaction_Id    
and a.operation_code in (''5'',''12'',''14'')'
Exec (@sql)   


Set @Sql='
delete  from ##mis_1717_bundle_cdr_stg where Reservation_Reference_Transaction_Id in     
(select RRBS_Transaction_Id from   MVNOREPORT_USA_GT..MIS_1717_BS_wrkard_master_dontdrop     
where CONVERT(varchar(10),topupdate,120)>=''2015-09-02'')'
Exec (@sql) 

Set @Sql='  
delete  from ##mis_1717_bundle_cdr_stg where Reservation_Reference_Transaction_Id in     
(select Reservation from MVNOREPORT_USA_GT..MIS_1717_BS_wrkard_master_dontdrop     
where CONVERT(varchar(10),topupdate,120)>=''2015-09-02'')'
Exec (@sql)    


Set @Sql='alter table ##mis_1717_bundle_cdr_stg add sequence_no int'
Exec (@sql) 

Set @Sql='
update ##mis_1717_bundle_cdr_stg    
set sequence_no=1    
where Number_Of_Installments>1 and operation_code in (''25'',''26'',''27'')'
Exec (@sql) 

Set @Sql='
insert into ##mis_1717_bundle_cdr_stg  (  
msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,
RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,
planid,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,
Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,sequence_no)
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,
RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,
planid,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,
Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,sequence_no

 from (    
------------------------Sequence2------------    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,    
sequence_no=''2'' from ##mis_1717_bundle_cdr_stg where     
Number_Of_Installments=2 and operation_code in (''25'',''26'',''27'')    
union all---------------Sequence3------------    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,    
sequence_no=''2'' from ##mis_1717_bundle_cdr_stg where     
Number_Of_Installments=3 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,    
sequence_no=''3'' from ##mis_1717_bundle_cdr_stg where     
Number_Of_Installments=3 and operation_code in (''25'',''26'',''27'')    
union all---------------Sequence4------------    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,RRBS_iccid,    
sequence_no=''2'' from ##mis_1717_bundle_cdr_stg where     
Number_Of_Installments=4 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''3'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=4 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''4'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=4 and operation_code in (''25'',''26'',''27'')    
union all---------------Sequence5------------    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''2'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=5 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''3'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=5 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''4'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=5 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''5'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=5 and operation_code in (''25'',''26'',''27'')    
union all---------------Sequence6------------    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''2'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=6 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''3'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=6 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''4'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=6 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''5'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=6 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''6'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=6 and operation_code in (''25'',''26'',''27'') 
union all
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''2'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''3'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''4'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''5'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''6'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''7'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''8'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''9'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''10'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''11'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=11 and operation_code in (''25'',''26'',''27'') 
union all
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''2'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''3'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''4'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''5'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'')    
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''6'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''7'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''8'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''9'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''10'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''11'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
union all    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number,transaction_id,RECHARGE_DATE,Special_topup_amount,bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,bundle_name,    
promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,topupdate,iccid,    
RRBS_iccid,sequence_no=''12'' from ##mis_1717_bundle_cdr_stg    
where Number_Of_Installments=12 and operation_code in (''25'',''26'',''27'') 
)x    '
Exec (@sql)


Set @sql='alter table ##mis_1717_bundle_cdr_stg add pinnumber varchar(50),iccidprefix varchar(20)'
Exec (@Sql) 

Set @sql='
update ##mis_1717_bundle_cdr_stg    
set iccidprefix=Left(sim_number,7) '
Exec (@sql)
 
Set @sql='
update ##mis_1717_bundle_cdr_stg    
set pinnumber=RRBS_Transaction_Id+''_''+CONVERT(varchar(10),Operation_code)    
where sequence_no is NULL'
Exec (@sql)    

Set @sql='    
update ##mis_1717_bundle_cdr_stg    
set pinnumber=RRBS_Transaction_Id+''_''+CONVERT(varchar(10),Operation_code)+''_''+CONVERT(varchar(10),sequence_no)    
where sequence_no is not NULL'
Exec (@sql)
    
Set @sql='if exists (select pinnumber from ##mis_1717_bundle_cdr_stg(nolock) group by  pinnumber having COUNT(*) >1 )                  
begin                           
                            
  update a                          
  set  iccid=''D''                           
  from  ##mis_1717_bundle_cdr_stg  a   ,(select  pinnumber,MIN(topupdate) min_topupdate                          
             from ##mis_1717_bundle_cdr_stg(nolock)                           
             group by  pinnumber having COUNT(*) >1) b                          
  where a.Pinnumber=b.Pinnumber                          
  and   a.TopupDate >b.min_topupdate                          
                          
  delete from ##mis_1717_bundle_cdr_stg where iccid=''D''                          
                          
end'
Exec (@sql)                   
    
------------------------Swap imsi-------------------------  
Set @sql='
IF OBJECT_ID(''mis_1717_swapmaster'') is not null
drop table mis_1717_swapmaster

select OldMSISDN,OldICCID,NewMSISDN,NewICCID,RequestDate,Status,AuthorisedDate  
into mis_1717_swapmaster from
(select OldMSISDN,OldICCID,NewMSISDN,NewICCID,RequestDate,Status,AuthorisedDate   from MVNO_USA.DBO.MSTSWAPIMSI with (nolock)
union all
select OldMSISDN,OldICCID,NewMSISDN,NewICCID,RequestDate,Status,AuthorisedDate   from [ARC_MVNO_USA].DBO.MSTSWAPIMSI_arch with (nolock)
union all
select OldMSISDN,OldICCID,NewMSISDN,NewICCID,RequestDate,Status,AuthorisedDate   from MVNO_USA.DBO.MSTSWAPIMSI_arch with (nolock))x'
Exec (@sql)

Set @sql='
IF OBJECT_ID(''Tempdb.dbo.##swapmaster'') is not null
drop table ##swapmaster
select OldMSISDN,OldICCID,NewMSISDN,NewICCID,RequestDate,Status,AuthorisedDate  
into ##swapmaster from mis_1717_swapmaster  
where convert(varchar(07),AuthorisedDate,120)<='''+@month+'''
and Status=''2'''
Exec (@sql)


Set @sql='
IF OBJECT_ID(''Tempdb.dbo.##swap'') is not null
drop table ##swap
select oldmsisdn ,MIN(AuthorisedDate)AuthorisedDate     
into ##swap from  ##swapmaster   
where convert(varchar(07),AuthorisedDate,120)<='''+@month+'''
group by oldmsisdn'
Exec (@sql)    
    
Set @sql='alter table ##swap add oldiccid varchar(20)'
Exec (@sql)      
    
Set @sql='update a    
set a.oldiccid=right(b.OldICCID,12)    
from ##swap a join ##swapmaster b    
on a.oldmsisdn =b.oldmsisdn    
and a.AuthorisedDate=b.AuthorisedDate'
Exec (@sql)      

Set @sql='
IF OBJECT_ID(''Tempdb.dbo.##mstswap'') is not null
drop table ##mstswap
select * into ##mstswap from ##swapmaster    
where convert(varchar(07),AuthorisedDate,120)<='''+@month+'''
and Status=''2'''
Exec (@sql)      
    
Set @sql='alter table ##mstswap add firsticcid varchar(20)'  
Exec (@sql)      
    
Set @sql='update a    
set a.firsticcid=b.oldiccid    
from ##mstswap a join ##swap b    
on a.oldmsisdn=b.oldmsisdn'  
Exec (@sql) 

Set @sql='update a    
set a.iccid=b.firsticcid    
from ##mis_1717_bundle_cdr_stg a join ##mstswap b    
on a.RRBS_iccid=RIGHT(b.newiccid,12)'  
Exec (@sql)     
   
Set @sql='update a    
set a.iccid=b.firsticcid    
from ##mis_1717_bundle_cdr_stg a join ##mstswap b    
on a.iccid=RIGHT(b.newiccid,12)'  
Exec (@sql)     

Set @sql='IF OBJECT_ID(''Tempdb.dbo.##Deva'') is not null
Drop table ##Deva
Select Msisdn,max(Completeddate) Completeddate 
into ##Deva from (
Select ''1''+Pmsisdn Msisdn, Completeddate  from MNP_USA.DBO.mnpportinrequest
where Status=''10''
union all
Select ''1''+Pmsisdn,Completeddate from mnp_usa.DBO.MNPPORTINREQUESTCOMPLETE
where Status=''10''
union all
Select ''1''+Pmsisdn Msisdn, Completeddate  from MNP_USA_ATT.DBO.mnpportinrequest
where Status=''10''and isnull(SIMCHANGETYPE,'''')<>''SIMCHANGE''
)A
Group by msisdn '  
Exec (@sql)      

Set @sql='IF OBJECT_ID(''Tempdb.dbo.##swap1'') is not null
Drop table ##swap1
select A.oldmsisdn ,MIN(A.AuthorisedDate)AuthorisedDate     
into ##swap1 from  ##swapmaster a,##Deva b  
where a.oldmsisdn=b.msisdn
and convert(varchar(6),a.AuthorisedDate,112)>=convert(varchar(6),b.Completeddate,112)
and convert(varchar(7),a.AuthorisedDate,120)<='''+@month+'''   
group by oldmsisdn '  
Exec (@sql)    
    
Set @sql='alter table ##swap1 add oldiccid varchar(20)'  
Exec (@sql)     
    
Set @sql='update a    
set a.oldiccid=right(b.OldICCID,12)    
from ##swap1 a join ##swapmaster b    
on a.oldmsisdn =b.oldmsisdn    
and a.AuthorisedDate=b.AuthorisedDate'  
Exec (@sql)     

Set @sql='IF OBJECT_ID(''Tempdb.dbo.##mstswap1'') is not null
Drop table ##mstswap1
select a.* into ##mstswap1 from ##swapmaster a, ##Deva b   
where a.oldmsisdn=b.msisdn
and convert(varchar(6),a.AuthorisedDate,112)>=convert(varchar(6),b.Completeddate,112)
and convert(varchar(7),AuthorisedDate,120)<='''+@month+'''      
and Status in (''2'') '  
Exec (@sql)  
  
Set @sql='alter table ##mstswap1 add firsticcid varchar(20)'  
Exec (@sql)     
    
Set @sql='update a    
set a.firsticcid=b.oldiccid    
from ##mstswap1 a join ##swap1 b    
on a.oldmsisdn=b.oldmsisdn'  
Exec (@sql)     

Set @sql='update a    
set a.iccid=b.firsticcid    
from ##mis_1717_bundle_cdr_stg a join ##mstswap1 b    
on a.RRBS_iccid=RIGHT(b.newiccid,12)'  
Exec (@sql) 
Set @sql='update a    
set a.iccid=b.firsticcid    
from ##mis_1717_bundle_cdr_stg a join ##mstswap1 b    
on a.iccid=RIGHT(b.newiccid,12)'  
Exec (@sql)     


Set @sql='IF OBJECT_ID(''Mis_1717_USA_ADDON_'+@month1+''') is not null
Drop table Mis_1717_USA_ADDON_'+@month1+'
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,account_pin_number ,transaction_id  ,RECHARGE_DATE  ,                                          
Special_topup_amount   , bundle_code,Operation_code,Recharge_type,Payment_Mode,planid        
,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id,Number_Of_Installments ,Reservation     
,SUBSTRING(RECHARGE_DATE,0,5)+''-''+ SUBSTRING(RECHARGE_DATE,5,2)+''-''+                                   
SUBSTRING(RECHARGE_DATE,7,2)+ '' ''+ SUBSTRING(RECHARGE_DATE,9,2)+ '':''+                                   
SUBSTRING(RECHARGE_DATE,11,2)+ '':''+ SUBSTRING(RECHARGE_DATE,13,2)+''.000'' as topupdate,    
right(sim_number,12)iccid,right(sim_number,12)RRBS_iccid    
into Mis_1717_USA_ADDON_'+@month1+'
from (    
select msisdn,sim_number,Account_Id,RRBS_Transaction_Id,    
account_pin_number ,transaction_id  ,RECHARGE_DATE  ,                                          
Special_topup_amount   , bundle_code,Operation_code,Recharge_type,Payment_Mode,planid        
,bundle_name,promo_validity_date,topup_counter,Reservation_Reference_Transaction_Id ,Number_Of_Installments ,Reservation    
from  usa_month'+@MM+'_'+@Year+'.dbo.Vw_topup
where operation_code in (''5'',''12'',''14'') 
and bundle_code in (''3010'',''3020'',''3005'',''1110'')
and left(recharge_date,6)='+@month1+')x   '
Exec (@sql)

Set @sql='update a    
set a.iccid=b.firsticcid    
from Mis_1717_USA_ADDON_'+@month1+' a join ##mstswap b    
on a.RRBS_iccid=RIGHT(b.newiccid,12)'
Exec (@sql)    

Set @sql='update a    
set a.iccid=b.firsticcid    
from Mis_1717_USA_ADDON_'+@month1+' a join ##mstswap1 b    
on a.RRBS_iccid=RIGHT(b.newiccid,12)'
Exec (@sql)    

--Select * into Mis_1717_pt_us_iccidseq_lyca_test from Mis_pt_us_iccidseq_lyca_test where 1=2

Set @sql='truncate table   Mis_1717_pt_us_iccidseq_lyca_test'
Exec (@sql)

Set @sql='insert into Mis_1717_pt_us_iccidseq_lyca_test                             
select iccid,MAX(topupseq)                           
from   MVNOREPORT_USA_GT..MIS_1717_BS_wrkard_master_dontdrop     
where  iccid in ( select distinct iccid from  ##mis_1717_bundle_cdr_stg(nolock) )                       
and operation_code<>''6''                                    
group by iccid'
Exec  (@sql)              

Set @sql='insert into Mis_1717_pt_us_iccidseq_lyca_test                                
select distinct iccid,0                             
from   ##mis_1717_bundle_cdr_stg (nolock)                        
where  iccid not in ( select distinct iccid from  MVNOREPORT_USA_GT..MIS_1717_BS_wrkard_master_dontdrop(nolock) where operation_code<>''6'')               
and    iccid is not null'
Exec  (@sql)    

Set @sql='IF OBJECT_ID(''tempdb..##temp_topupsummary'') IS NOT NULL                    
drop table     ##temp_topupsummary                              
select row_number() OVER(partition by a.iccid order by topupdate)+seq topupseq,MSISDN,a.iccid,Pinnumber,TopupDate,special_topup_amount,        
bundle_code,Operation_code,Recharge_type,Payment_Mode,planid,iccidprefix ,bundle_name,promo_validity_date,                       
special_topup_amount bundlevalue,Reservation_Reference_Transaction_Id,    
Number_Of_Installments,Reservation,RRBS_Transaction_Id,Transaction_Id,RRBS_iccid,sequence_no    
into   ##temp_topupsummary                           
from   ##mis_1717_bundle_cdr_stg a(nolock) ,Mis_1717_pt_us_iccidseq_lyca_test b(nolock)                              
where  a.iccid=b.iccid  and operation_code <> ''6''                  
order by a.iccid,TopupDate'
Exec  (@sql)   

Set @sql='select max(topupdate) from MVNOREPORT_USA_gt..MIS_1717_BS_wrkard_master_dontdrop
select min(topupdate),max(topupdate) from ##temp_topupsummary'
Exec  (@sql)   



Set @sql='IF OBJECT_ID(''MIS_1717_BS_wrkard_master_dontdrop_month'') IS NOT NULL                    
drop table MIS_1717_BS_wrkard_master_dontdrop_month
                         
select  topupseq,MSISDN,iccid,Pinnumber,TopupDate,special_topup_amount face_value,bundle_code,    
Operation_code,Recharge_type,Payment_Mode,planid,iccidprefix,bundle_name,promo_validity_date bundle_validity,    
Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,RRBS_Transaction_Id,Transaction_Id,RRBS_iccid    
,bundlevalue=right(bundle_code,2),sequence_no into MIS_1717_BS_wrkard_master_dontdrop_month from  ##temp_topupsummary(nolock)'
Exec (@sql)

--update MIS_1717_BS_wrkard_master_dontdrop_month
--set bundlevalue=right(bundle_code,2)

--Create table Mis_1717_USA_Bundle_Value_master(Bundle_code varchar(10),Bundle_Value float)
--="insert into Mis_1717_USA_Bundle_Value_master values('"&&"','"&&"')"

Set @sql='update MIS_1717_BS_wrkard_master_dontdrop_month set bundlevalue=b.Bundle_value
from MIS_1717_BS_wrkard_master_dontdrop_month a,Mis_1717_USA_Bundle_Value_master b
where a.bundle_code=b.bundle_code'
Exec (@sql)



Set @sql='IF OBJECT_ID(''MIS_1717_BS_wrkard_master_dontdrop_new'') IS NOT NULL                    
drop table MIS_1717_BS_wrkard_master_dontdrop_new
select * into MIS_1717_BS_wrkard_master_dontdrop_new from (
select  topupseq,MSISDN,iccid,Pinnumber,TopupDate,face_value,bundlecode,Operation_code,Recharge_type,Payment_Mode,planid,iccidprefix,bundle_name,Bundle_validity,bundlevalue,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,RRBS_Transaction_Id,Transaction_Id,RRBS_iccid,sequence_no
from MVNOREPORT_USA_GT..MIS_1717_BS_wrkard_master_dontdrop
union all
select  topupseq,MSISDN,iccid,Pinnumber ,TopupDate,face_value,bundle_code bundlecode,Operation_code,Recharge_type,Payment_Mode,planid,iccidprefix,bundle_name,Bundle_validity,bundlevalue,Reservation_Reference_Transaction_Id,Number_Of_Installments,Reservation,RRBS_Transaction_Id,Transaction_Id,RRBS_iccid,sequence_no
from MIS_1717_BS_wrkard_master_dontdrop_month)x'
Exec (@sql)
 
 Set @sql='IF OBJECT_ID(''MIS_1717_BS_wrkard_master_dontdrop_old_'+@Month1+''') IS NOT NULL                    
drop table MIS_1717_BS_wrkard_master_dontdrop_old_'+@Month1+''
Exec (@sql)

 Set @sql='sp_rename ''MIS_1717_BS_wrkard_master_dontdrop'',''MIS_1717_BS_wrkard_master_dontdrop_old_'+@Month1+''''
Exec (@sql)
 Set @sql='sp_rename ''MIS_1717_BS_wrkard_master_dontdrop_new'',''MIS_1717_BS_wrkard_master_dontdrop'''
Exec (@sql)
 
 Set @sql='
 Select ''Final check''
 select min(topupdate) mindate,max(topupdate) Maxdate from MIS_1717_BS_wrkard_master_dontdrop'
Exec (@sql)
 


 Set @sql='select count(*) from [MIS_1717_BS_wrkard_master_dontdrop] 
 where convert(varchar(07),topupdate,120) = '''+@month+''' and topupseq=1'
Exec (@sql)

 Set @sql='select count(*) from MVNOREPORT_USA_LM.dbo.bundlesummarydetail_comm with (nolock)
 where convert(varchar(07),topupdate,120) =  '''+@month+''' and topupseq=1
 and bundlecode not in (''668851'',''668855'',''668852'',''668853'',''668854'',''885566'',''885577'',''3010'',''3020'',''3005'',''1110'',
''121035'',''131023'',''131039'',''445566'',''445567'',''445570'',''668899'',''777331'',''778853'',''888813'')'
Exec (@sql)

 Set @sql='select convert(varchar(10),topupdate,120),count(*) from [MIS_1717_BS_wrkard_master_dontdrop]
 where convert(varchar(07),topupdate,120) = '''+@month+'''
 --and bundlecode not in (''3010'',''3020'',''3005'',''1110'')
 group by convert(varchar(10),topupdate,120)
 order by convert(varchar(10),topupdate,120)'
Exec (@sql)
 
 Set @sql='select convert(varchar(10),topupdate,120),count(*) from MVNOREPORT_USA_LM.dbo.bundlesummarydetail_comm with(nolock)
 where convert(varchar(07),topupdate,120) = '''+@month+'''   
 and bundlecode not in (''668851'',''668855'',''668852'',''668853'',''668854'',''885566'',''885577'',''3010'',''3020'',''3005'',''1110'',
''121035'',''131023'',''131039'',''445566'',''445567'',''445570'',''668899'',''777331'',''778853'',''888813'')
 group by convert(varchar(10),topupdate,120)
 order by convert(varchar(10),topupdate,120)'
Exec (@sql)
 
 Set @sql='
 IF OBJECT_ID(''MIS_1717_BS_wrkard_master_dontdrop_month_'+@month1+''') is not null
Drop table MIS_1717_BS_wrkard_master_dontdrop_month_'+@month1+'

 Select * into MIS_1717_BS_wrkard_master_dontdrop_month_'+@month1+' from MIS_1717_BS_wrkard_master_dontdrop_month'
 Exec (@sql)

 END


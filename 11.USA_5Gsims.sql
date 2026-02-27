


alter  PROCEDURE MIS_1001_FCA_5G_SIM_UPLIFT_INCENTIVE
AS
BEGIN

DECLARE @sql varchar(max)
Declare @YYYYMM1_112 varchar(10)
Declare @YYYYMM2_112 varchar(10)
Declare @YYYYMM3_112 varchar(10)
Declare @YYYYMM4_112 varchar(10)

Set @YYYYMM1_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)),112)
Set @YYYYMM2_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)),112)
Set @YYYYMM3_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0)),112)
Set @YYYYMM4_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 4, 0)),112)

Select @YYYYMM1_112 YYYYMM1_112,@YYYYMM2_112 YYYYMM2_112,@YYYYMM3_112 YYYYMM3_112,@YYYYMM4_112 YYYYMM4_112
--5G Sims


if (object_id('MIS_1001_5G_SIM_OUTPUT')is not null)
drop table MIS_1001_5G_SIM_OUTPUT


Select * into MIS_1001_5G_SIM_OUTPUT from mis_1717_USA_FCA
where convert(varchar(06),Topupdate,112)=@YYYYMM1_112
--and iccid like '25%'
and offmgrid  in ('NEWJERSEY-ST','Stall-Florida','stall-texas','stall-chicago','NEWJERSEY','FLORIDA','TEXAS',
'CHICAGO','CALIFORNIA','LMUS-HP-EUROPEANAGENCY','CLOSED_OFFICE')

---FCA Uplift

set @sql='
if object_id(''Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+''')is not null
Drop table Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'

Select offmgrid,	accmgrid,	hotspotid,	retailerid,ShopType,Status,
cast (null as float) month3, cast (null as float) month2,cast (null as float) month1,
 cast (null as float) Pre_FCA , cast (null as float) Cur_FCA , cast (null as varchar(100)) Shop_Desc ,cast (null as varchar(100))Type, 
 cast (null as varchar(100)) Pre_FCA_Slab , cast (null as varchar(100)) Cur_FCA_Slab, cast (null as float) FCA_UPlift, cast (null as float) Target_Bonus 
into Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' from Mvnoreport_USA_LM.dbo.vw_dsmretailer_live

'
print(@sql)
exec(@sql)

set @sql='
IF OBJECT_ID(''tempdb.dbo.##Arjun'') is not null
Drop table ##Arjun 
   
Select 	retailerid,Count(*) Prev_FCA
into ##Arjun
 from Mis_1717_USA_DETAIL_'+@YYYYMM2_112+'
 where Activityname=''Bundle_1'' and HS_Final=''Eligible''
 group by retailerid

 IF OBJECT_ID(''tempdb.dbo.##Arjun1'') is not null
Drop table ##Arjun1 

 Select 	retailerid,Count(*) Prev_FCA
into ##Arjun1
 from Mis_1717_USA_DETAIL_'+@YYYYMM3_112+'
 where Activityname=''Bundle_1'' and HS_Final=''Eligible''
 group by retailerid

IF OBJECT_ID(''tempdb.dbo.##Arjun2'') is not null
Drop table ##Arjun2 

 Select 	retailerid,Count(*) Prev_FCA
into ##Arjun2
 from Mis_1717_USA_DETAIL_'+@YYYYMM4_112+'
 where Activityname=''Bundle_1'' and HS_Final=''Eligible''
 group by retailerid
'
 print(@sql)
 exec(@sql)

 set @sql='
 
  update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month1=b.Prev_FCA
 from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' a,##Arjun b
 Where a.retailerid=b.retailerid

   update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month2=b.Prev_FCA
 from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' a,##Arjun1 b
 Where a.retailerid=b.retailerid

   update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month3=b.Prev_FCA
 from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' a,##Arjun2 b
 Where a.retailerid=b.retailerid

 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month1=0 where month1 is null
 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month2=0 where month2 is null
 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set month3=0 where month3 is null

 --Select *,case when (case when  month1>=month2 then month1 else month2 end)>=(case when  month2>=month3 then month2 else month3 end) 
 --then (case when  month1>=month2 then month1 else month2 end) else (case when  month2>=month3 then month2 else month3 end) end Final
 --from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'
 --where month1>0

 '
 PRINT(@SQL)
 exec(@sql)

SET @SQL='
IF OBJECT_ID(''tempdb.dbo.##Temp_kb'') is not null
Drop table ##Temp_kb 

Select 	retailerid,Count(*) Curr_FCA
into ##Temp_kb
from Mis_1717_USA_DETAIL_'+@YYYYMM1_112+'
where Activityname=''Bundle_1'' and HS_Final=''Eligible''
and offmgrid in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')
group by retailerid

 -- update Mis_1717_USA_Retailer_output_Wirelessshops_202507 set Pre_FCA=b.Prev_FCA
 --from Mis_1717_USA_Retailer_output_Wirelessshops_202507 a,#Arjun b
 --Where a.retailerid=b.retailerid

 -- update Mis_1717_USA_Retailer_output_Wirelessshops_202507 
 -- set Pre_FCA=case when (case when  month1>=month2 then month1 else month2 end)>=(case when  month2>=month3 then month2 else month3 end) 
 --then (case when  month1>=month2 then month1 else month2 end) else (case when  month2>=month3 then month2 else month3 end) end

 --update Mis_1717_USA_Retailer_output_Wirelessshops_202507 set Pre_FCA=NULL

 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' 
  set Pre_FCA=month1


 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Cur_FCA=b.Curr_FCA
 from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' a,##Temp_kb b
 Where a.retailerid=b.retailerid

  update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Pre_FCA=0
  where Pre_FCA is null

    update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Cur_FCA=0
  where Cur_FCA is null

 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Shop_Desc=b.ShopTypeDesc
 from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' a,Mvnoreport_USA_LM.dbo.VW_DSMSHOPTYPE b
 Where a.ShopType=b.Shopid

 
update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Type=''Others''

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Type=''Wirelessshops''
where Shop_Desc in (''MOBILE SHOP-ACCESSORIES'',''Phone Repair and Accessories'',''Wireless Outlet'')

'
PRINT(@SQL)
exec(@sql)

SET @SQL='
 --Alter table Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' add Pre_FCA_Slab varchar(100),Cur_FCA_Slab varchar(100)


 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Pre_FCA_Slab= case	when Pre_FCA<10 then ''<10''
																				when Pre_FCA between 10 and 19 then ''10''	
																				when Pre_FCA between 20 and 39 then ''20''	
																				when Pre_FCA between 40 and 59 then ''40''	
																				when Pre_FCA between 60 and 79 then ''60''	
																				when Pre_FCA between 80 and 99 then ''80''
																				else ''100'' end

where Type=''Wirelessshops''

																				
 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Cur_FCA_Slab= case	when Cur_FCA<10 then ''<10''
																				when Cur_FCA between 10 and 19 then ''10''	
																				when Cur_FCA between 20 and 39 then ''20''	
																				when Cur_FCA between 40 and 59 then ''40''	
																				when Cur_FCA between 60 and 79 then ''60''	
																				when Cur_FCA between 80 and 99 then ''80''
																				else ''100'' end

where Type=''Wirelessshops''


--Alter table Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' add FCA_UPlift Float

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set FCA_UPlift=Round((Cur_FCA/Pre_FCA),2)
where Pre_FCA>0

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set FCA_UPlift=Cur_FCA
where Pre_FCA=0


--Alter table Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' add Target_Bonus Float

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=100
where Cur_FCA_Slab=''10'' and Type=''Wirelessshops''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=100
where Cur_FCA_Slab=''10'' and Type=''Wirelessshops''
and pre_FCA_slab=''<10'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=200
where Cur_FCA_Slab=''20'' and Type=''Wirelessshops''
and FCA_UPlift>=1.18
'
PRINT(@SQL)
exec(@sql)

SET @SQL='

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=200
where Cur_FCA_Slab=''20'' and Type=''Wirelessshops''
and pre_FCA_slab=''10'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=400
where Cur_FCA_Slab=''40'' and Type=''Wirelessshops''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=400
where Cur_FCA_Slab=''40''and Type=''Wirelessshops''
and pre_FCA_slab=''20'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=600
where Cur_FCA_Slab=''60''and Type=''Wirelessshops''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=600
where Cur_FCA_Slab=''60''and Type=''Wirelessshops''
and pre_FCA_slab=''40'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=800
where Cur_FCA_Slab=''80''and Type=''Wirelessshops''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=800
where Cur_FCA_Slab=''80''and Type=''Wirelessshops''
and pre_FCA_slab=''60'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=1000
where Cur_FCA_Slab=''100''and Type=''Wirelessshops''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=1000
where Cur_FCA_Slab=''100''and Type=''Wirelessshops''
and pre_FCA_slab=''80'' and target_bonus is null
'
PRINT(@SQL)
exec(@sql)



------------NON-WIRELESS-OUTPUT  

SET @SQL='

 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Pre_FCA_Slab= case	when Pre_FCA<5 then ''<5''
																				when Pre_FCA between 5 and 14 then ''5''	
																				when Pre_FCA between 15 and 39 then ''15''	
																				when Pre_FCA between 40 and 59 then ''40''	
																				when Pre_FCA between 60 and 79 then ''60''
																				when Pre_FCA between 80 and 99 then ''80''	
																				else ''100'' end

where Type=''OTHERS ''

																				
 update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Cur_FCA_Slab= case	when Cur_FCA<5 then ''<5''
																				when Cur_FCA between 5 and 14 then ''5''	
																				when Cur_FCA between 15 and 39 then ''15''	
																				when Cur_FCA between 40 and 59 then ''40''	
																				when Cur_FCA between 60 and 79 then ''60''
																				when Cur_FCA between 80 and 99 then ''80''	
																				else ''100'' end

where Type=''OTHERS ''	
'
EXEC(@SQL)

---TARGET CHANGE ----NON WIRELESS

SET @SQL='

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=40
where Cur_FCA_Slab=''5'' and Type=''OTHERS''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=40
where Cur_FCA_Slab=''5'' and Type=''OTHERS''
and pre_FCA_slab=''<5'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=100
where Cur_FCA_Slab=''15'' and Type=''OTHERS''
and FCA_UPlift>=1.18



update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=100
where Cur_FCA_Slab=''15'' and Type=''OTHERS''
and pre_FCA_slab=''5'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=200
where Cur_FCA_Slab=''40'' and Type=''OTHERS''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=200
where Cur_FCA_Slab=''40''and Type=''OTHERS''
and pre_FCA_slab=''15'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=300
where Cur_FCA_Slab=''60''and Type=''OTHERS''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=300
where Cur_FCA_Slab=''60''and Type=''OTHERS''
and pre_FCA_slab=''40'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=400
where Cur_FCA_Slab=''80''and Type=''OTHERS''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=400
where Cur_FCA_Slab=''80''and Type=''OTHERS''
and pre_FCA_slab=''60'' and target_bonus is null

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=500
where Cur_FCA_Slab=''100''and Type=''OTHERS''
and FCA_UPlift>=1.18

update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=500
where Cur_FCA_Slab=''100''and Type=''OTHERS''
and pre_FCA_slab=''80'' and target_bonus is null
'
PRINT(@SQL)
exec(@sql)



--UPLIFT OUTPUT
SET @SQL='

--update Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+' set Target_Bonus=0
--where Cur_FCA_Slab=PRE_FCA_Slab and Cur_FCA_Slab<>100
--and Target_Bonus>0

if object_id(''Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'_OUTPUT'')is not null
Drop table Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'_OUTPUT


Select * INTO Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'_OUTPUT from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'
where 
--and cur_fca>0
 offmgrid  in (''NEWJERSEY-ST'',''Stall-Florida'',''stall-texas'',''stall-chicago'',''NEWJERSEY'',''FLORIDA'',''TEXAS'',
''CHICAGO'',''CALIFORNIA'',''LMUS-HP-EUROPEANAGENCY'',''CLOSED_OFFICE'')
--and (Pre_FCA>0 or Cur_Fca>0)
and HotSpotid not like ''%closed%''
order by target_bonus desc

-----
--Select * from Mis_1717_USA_Retailer_output_Wirelessshops_'+@YYYYMM1_112+'
--where Status=''Wirelessshops''
--order by target_bonus desc


--Select * from Mis_1717_USA_FCA
--where retailerid like ''%29465417%''
--group by Bundlecode

--select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_49''

--select A.iccid,''Plan_49_''+Cast(a.TopupSeq as varchar(5)) Activityname,a.Topupdate Activitydate,      
--ResellerId,OffMgrid,AccMgrid,HotspotId,Retailerid,ini_facevalue,freemin,discount,a.face_value Topup_value,
--a.bundlevalue,b.Topupdate Firstbundle_date,a.bundlecode,a.bundle_name,a.topupseq Bundle_seq,a.Payment_Mode,a.Operation_code,a.Recharge_type,b.noofmonths
--from [MIS_1717_BS_wrkard_master_dontdrop] a(nolock) , Mis_1717_USA_FCA b(nolock)      
--where a.iccid =b.iccid       
--and Convert(varchar(07),a.Topupdate,120) =''2024-11'' 
--and retailerid=''DD-CELLULAR1~29465417''
--and a.Topupseq <5
--and a.Topupseq<>0
--and a.bundlecode in (select bundlecode from Mis_1717_USA_BUNDLE_MASTER_202211 where bundletype=''Plan_49'')

--'

PRINT(@SQL)
exec(@sql)

END 



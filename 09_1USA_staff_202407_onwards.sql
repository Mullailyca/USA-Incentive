



create  PROCEDURE MIS_1001_USA_STAFF_DETAIL_COMM_nolive
AS
BEGIN

DECLARE @sql varchar(max)
Declare @YYYYMM1_112 varchar(10)
Declare @YYYYMM2_112 varchar(10)
Declare @YYYYMM3_112 varchar(10)

Set @YYYYMM1_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)),112)
Set @YYYYMM2_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0)),112)
Set @YYYYMM3_112=Convert(varchar(6),(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0)),112)

Select @YYYYMM1_112,@YYYYMM2_112,@YYYYMM3_112


Set @sql='
if object_id(''Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+''')is not null
Drop table Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+'

Select * into Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' from Mis_1717_USA_FCA(nolock)
where convert(varchar(06),Topupdate,112)='''+@YYYYMM1_112+''''
Print (@sql)
Exec (@sql)

Set @sql='
Delete from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+'
where Bundlecode in (''681005'',''1005'')'
Print (@sql)
Exec (@sql)

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##offmgr'') is not null
Drop table ##offmgr 
select * into ##offmgr from mvno_usa.dbo.dsm_offmgr_trnactivation'
Print (@sql)
Exec (@sql)

Set @Sql='Create index id1 on ##offmgr(iccid_fr,iccid_to)'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##Accmgr'') is not null
Drop table ##Accmgr 
select * into ##Accmgr from mvno_usa.dbo.dsm_accmgr_trnactivation'
Print (@sql)
Exec (@sql) 
Set @Sql='Create index id1 on ##Accmgr(iccid_fr,iccid_to)'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##Hotspot'') is not null
Drop table ##Hotspot 
select * into ##Hotspot from mvno_usa.dbo.dsm_hotspot_trnactivation'
Print (@sql)
Exec (@sql) 
Set @Sql='Create index id1 on ##Hotspot(iccid_fr,iccid_to)'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##DSMRET'') is not null
Drop table ##DSMRET 
select retailerid,offmgrid,accmgrid,hotspotid into ##DSMRET from mvno_usa.dbo.dsm_retailer'
Print (@sql)
Exec (@sql) 
Set @Sql='Create index id1 on ##DSMRET(retailerid)'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb..##TRNRET1'') is not null
Drop table ##TRNRET1
select retailerid,Offmgrid,Accmgrid,Hotspotid,iccid_fr,iccid_to,authdate into ##TRNRET1
from mvno_usa.dbo.dsm_retailer_trnactivation with (nolock)
create index IDX on   ##TRNRET1 (iccid_fr,iccid_to) '
Print (@sql)
Exec (@sql) 

Set @Sql='update a            
set a.OffMgrID=b.OffMgrID            
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join ##offmgr b            
on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'
Print (@sql)
Exec (@sql) 

Set @Sql='update a            
set a.accmgrid=b.accmgrid
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join ##accmgr b            
on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'
Print (@sql)
Exec (@sql) 
   
Set @Sql='update a            
set a.hotspotid=b.hotspotid
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join ##hotspot b            
on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'
Print (@sql)
Exec (@sql) 

Set @Sql='update a            
set a.retailerid=b.retailerid,a.OffMgrID=b.OffMgrID,
a.hotspotid=b.hotspotid,
a.accmgrid=b.accmgrid,
a.authdate_ret=b.authdate            
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join ##TRNRET1 b            
on  LEFT(a.ICCID,11)  between b.iccid_fr and b.iccid_to'
Print (@sql)
Exec (@sql) 

Set @Sql='update a            
set a.OffMgrID=b.OffMgrID,
a.hotspotid=b.hotspotid,
a.accmgrid=b.accmgrid
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join ##DSMRET b            
on a.retailerid=b.retailerid '
Print (@sql)
Exec (@sql) 


-----may month only
--Set @Sql='update a            
--set a.OffMgrID=b.OffMgrID,
--a.hotspotid=b.hotspotid,
--a.accmgrid=b.accmgrid
--from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join Mis_1717_adhoc b            
--on a.retailerid=b.retailerid '
--Print (@sql)
--Exec (@sql) 
-----


Set @Sql='update a            
set a.OffMgrID=b.OffMgrID            
from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+' a join mvno_usa.dbo.DSM_OffMgr_ResellerMapping b            
on a.resellerid=b.resellerid'
Print (@sql)
Exec (@sql) 


Set @Sql='if object_id(''Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+''')is not null
Drop table Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+'
Select * into Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' from Mis_1717_USA_Staff_Working_'+@YYYYMM1_112+'
where offmgrid in (''NEWJERSEY'',''FLORIDA'',''TEXAS'',''CHICAGO'',''CALIFORNIA'')
and retailerid  like ''DD%'''
Print (@sql)
Exec (@sql)

Set @Sql='
Sp_rename ''Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+'.topupdate'',''Activitydate'''
Print (@sql)
Exec (@sql)


Set @Sql='if object_id(''Tempdb.dbo.##TRNRET'')is not null
Drop table  ##TRNRET

Select *,Row_number() over (partition by Retailerid order by Submitdate Desc) Rownum  into ##TRNRET from (
Select ExistingRetailerID Retailerid,Existinghotspotid Hotspotid,ExistingAccmgrid Accmgrid,Existingoffmgrid Offmgrid,Newhotspotid, Max(Submitdate) Submitdate
from mvno_usa.dbo.DSM_HierarchyChangeRequest
group by ExistingRetailerID,Existinghotspotid,ExistingAccmgrid,Existingoffmgrid,Newhotspotid
) a'
Print (@sql)
Exec (@sql)

Set @Sql='Create index id1 on  ##TRNRET(Retailerid)'
Print (@sql)
Exec (@sql)

declare @id varchar(100)
declare @maxid varchar(100)
select @maxid=max(Rownum) from ##TRNRET
Set @id=1

while(@id<@maxid) 
begin

set @sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set Hotspotid =b.Hotspotid,Accmgrid=b.Accmgrid,Offmgrid =b.Offmgrid
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a, ##TRNRET b
where a.Retailerid=b.Retailerid
and b.Rownum='+@id+'
and a.Activitydate<b.submitdate'
exec (@sql)
set @id=@id+1
end


set @sql='Alter table Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+'
add SR varchar(100),
SR_Joindate varchar(20),
SR_Startdate varchar(20),
SR_Enddate varchar(20),
TL varchar(100),
TL_Joindate varchar(20),
TL_startDate	varchar(20),
TL_EndDate	varchar(20),
AM varchar(100),
AM_Joindate varchar(20),
AM_startDate	varchar(20),
AM_EndDate	varchar(20),
RM varchar(100),
RM_Joindate varchar(20),
RM_startDate	varchar(20),
RM_EndDate	varchar(20),
SR_GA_TGT	Float,
SR_UAO_TGT	Float,
TL_GA_TGT	Float,
TL_UAO_TGT	Float,
AM_GA_TGT	Float,
AM_UAO_TGT	Float,
RM_GA_TGT	Float,
RM_UAO_TGT Float,
Exposure varchar(100) ,Activity_date varchar(10)'
Print (@sql)
Exec (@sql)


set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set Exposure=''Portout''
where iccid in (Select iccid from Mis_1717_USA_Detail_comm_'+@YYYYMM1_112+' where portout_status is not null)'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set Exposure=''Lessthan_45_Portin''
where iccid in (Select iccid from Mis_1717_USA_Detail_comm_'+@YYYYMM1_112+' where Portin_status in (''Lessthan_30_Portin'',''Lessthan_45_Portin''))
and Exposure is  null'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set Exposure=''Lessthan_180_Portin''
where iccid in (Select iccid from Mis_1717_USA_Detail_comm_'+@YYYYMM1_112+' 
where Portin_status in (''Lessthan_60_Portin'',''Lessthan_90_Portin'',''Lessthan_120_Portin'',''Lessthan_150_Portin'',''Lessthan_180_Portin''))
and Exposure is  null'
Print (@sql)
Exec (@sql)

set @sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set Activity_date=convert(varchar(08),Activitydate,112)'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR=b.SalesRep,SR_Startdate=b.SalesRep_Startdate,SR_Enddate=b.SalesRep_Enddate,SR_GA_TGT=b.GA_TGT,SR_UAO_TGT=b.UAO_TGT,
SR_Joindate=b.SalesRep_Joindate
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,Mis_1717_Staff_Master_'+@YYYYMM1_112+' b
where a.hotspotid=b.hotspotid
and convert(varchar(08),a.activitydate,112) between b.SalesRep_Joindate and b.SalesRep_Enddate'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set 
TL=b.TeamLead,TL_startDate=b.TeamLead_startDate,TL_EndDate=b.TeamLead_EndDate,TL_Joindate=b.Teamlead_Joindate,TL_GA_TGT=b.GA_TGT,TL_UAO_TGT=b.UAO_TGT
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,Mis_1717_Staff_Master_'+@YYYYMM1_112+' b
where a.hotspotid=b.hotspotid
and convert(varchar(08),a.activitydate,112) between b.Teamlead_Joindate and b.TeamLead_EndDate'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set 
AM=b.AreaManager,AM_startDate=b.AreaManager_startDate,AM_EndDate=b.AreaManager_EndDate,AM_Joindate=b.AreaManager_Joindate,AM_GA_TGT=b.GA_TGT,AM_UAO_TGT=b.UAO_TGT
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,Mis_1717_Staff_Master_'+@YYYYMM1_112+' b
where a.hotspotid=b.hotspotid
and convert(varchar(08),a.activitydate,112) between b.AreaManager_Joindate and b.AreaManager_EndDate'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set 
RM=b.RegManager,RM_startDate=b.RegManager_startDate,RM_EndDate=b.RegManager_EndDate,RM_Joindate=b.RegManager_Joindate,RM_GA_TGT=b.GA_TGT,RM_UAO_TGT=b.UAO_TGT
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,Mis_1717_Staff_Master_'+@YYYYMM1_112+' b
where a.hotspotid=b.hotspotid
and convert(varchar(08),a.activitydate,112) between b.RegManager_Joindate and b.RegManager_EndDate'
Print (@sql)
Exec (@sql)

set @sql='Alter table Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+'
add 
SR_UAO_Curr float,
TL_UAO_Curr float,
AM_UAO_Curr float,
RM_UAO_Curr float,
SR_FCA_Curr Float,
TL_FCA_Curr Float,
AM_FCA_Curr Float,
RM_FCA_Curr Float'
Print (@sql)
Exec (@sql)

---UAO



--FCA

set @sql='if object_id(''Tempdb.dbo.##Salesrep_FCA'')is not null
Drop table ##Salesrep_FCA
Select hotspotid,SR,Count(iccid) Cnt,Count(Distinct retailerid) Cnt1  into ##Salesrep_FCA from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
where Activity_date between SR_Startdate and SR_Enddate
and Exposure is null
group by hotspotid,SR'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_FCA_Curr=b.cnt,SR_UAO_Curr=b.Cnt1
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,##Salesrep_FCA b
where a.hotspotid=b.hotspotid
and a.SR=b.SR'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_FCA_Curr=0,SR_UAO_Curr=0 where SR_FCA_Curr is null'
Print (@sql)
Exec (@sql)

set @sql='if object_id(''Tempdb.dbo.##Teamlead_FCA'')is not null
Drop table ##Teamlead_FCA
Select hotspotid,TL,Count(iccid) Cnt,Count(Distinct retailerid) Cnt1 into ##Teamlead_FCA from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
where Activity_date between TL_Startdate and TL_Enddate
and Exposure is null
group by hotspotid,TL'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set TL_FCA_Curr=b.cnt,TL_UAO_Curr=b.Cnt1
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,##Teamlead_FCA b
where a.hotspotid=b.hotspotid
and a.TL=b.TL'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set TL_FCA_Curr=0,TL_UAO_Curr=0 where TL_FCA_Curr is null'
Print (@sql)
Exec (@sql)

set @sql='if object_id(''Tempdb.dbo.##Areamanager_FCA'')is not null
Drop table ##Areamanager_FCA
Select hotspotid,AM,Count(iccid) Cnt,Count(Distinct retailerid) Cnt1 into ##Areamanager_FCA from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
where Activity_date between AM_Startdate and AM_Enddate
and Exposure is null
group by hotspotid,AM'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set AM_FCA_Curr=b.cnt,AM_UAO_Curr=b.Cnt1
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,##Areamanager_FCA b
where a.hotspotid=b.hotspotid
and a.AM=b.AM'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set AM_FCA_Curr=0,AM_UAO_Curr=0 where AM_FCA_Curr is null'
Print (@sql)
Exec (@sql)

set @sql='if object_id(''Tempdb.dbo.##Regmanager_FCA'')is not null
Drop table ##Regmanager_FCA
Select hotspotid,RM,Count(iccid) Cnt,Count(Distinct retailerid) Cnt1 into ##Regmanager_FCA from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
where Activity_date between RM_Startdate and RM_Enddate
and Exposure is null
group by hotspotid,RM'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set RM_FCA_Curr=b.cnt,RM_UAO_Curr=b.Cnt1
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a,##Regmanager_FCA b
where a.hotspotid=b.hotspotid
and a.RM=b.RM'
Print (@sql)
Exec (@sql)

set @sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set RM_FCA_Curr=0,RM_UAO_Curr=0 where RM_FCA_Curr is null'
Print (@sql)
Exec (@sql)

--old month
set @sql='
Alter table Mis_1717_USA_Staff_Final_'+@YYYYMM3_112+' Add Renewal Float'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##deva'') is not null
Drop table ##deva 
select iccid,bundlecode
into ##deva
from [MIS_1717_BS_wrkard_master_dontdrop]
where topupseq=''3''
and convert(varchar(6),topupdate,112) between '''+@YYYYMM3_112+''' and '''+@YYYYMM1_112+''''
Print (@sql)
Exec (@sql) 

Set @Sql='Delete from ##deva 
where bundlecode in (''1005'',''681005'')'
Print (@sql)
Exec (@sql) 

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM3_112+' set Renewal=1
where iccid in (Select iccid from ##deva )'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+''') is not null
Drop table Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+'

Select Hotspotid,Count(*) FCA,Count(Renewal) Renewal 
Into Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+'
from Mis_1717_USA_Staff_Final_'+@YYYYMM3_112+'
where exposure is null
group by Hotspotid'
Print (@sql)
Exec (@sql) 

Set @Sql='Alter table Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+' add T2M float'
Print (@sql)
Exec (@sql) 

Set @Sql='Alter table Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' add T2M_FCA float,T2M_Renewal float,T2M_PER Float'
Print (@sql)
Exec (@sql) 


Set @Sql='update Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+' set T2M=Round((cast(Renewal as float)/cast(FCA as float)),2) *100'
Print (@sql)
Exec (@sql) 

Set @Sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set T2M_FCA=cast(b.FCA as float),T2M_Renewal=cast(b.Renewal as float),T2M_PER=b.T2M
from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a, Mis_1717_USA_Staff_T2M_'+@YYYYMM1_112+' b
where a.Hotspotid=b.Hotspotid'
Print (@sql)
Exec (@sql) 


Set @Sql='Alter table Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' Add UAO_last float,UAO_Final float,SR_GA_PER float,SR_UAO_PER float,SR_Incentive float'
Print (@sql)
Exec (@sql) 

Set @Sql='
IF OBJECT_ID(''tempdb.dbo.##Ret'') is not null
Drop table ##Ret 
Select Hotspotid,Count(Distinct retailerid) Cnt Into ##Ret from Mis_1717_USA_Staff_Final_'+@YYYYMM2_112+'
where exposure is null
group by Hotspotid'
Print (@sql)
Exec (@sql) 

Set @Sql='Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set UAO_last=b.cnt
From  Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' a, ##Ret b
where a.Hotspotid=b.Hotspotid

Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set UAO_last=0 where UAO_last is null

Update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set UAO_Final=Case when SR_UAO_TGT>UAO_last then SR_UAO_TGT else UAO_last end'
Print (@sql)
Exec (@sql) 


Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_GA_PER=(Round((cast(SR_FCA_Curr as float)/cast(SR_GA_TGT as float)),2) *100)/2,SR_UAO_PER=(Round((cast(SR_UAO_Curr as float)/cast(UAO_Final as float)),2)*100)/2
where SR is not null'
Print (@sql)
Exec (@sql)

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_Incentive=1500*((SR_GA_PER+SR_UAO_PER)/100)
where SR_GA_PER+SR_UAO_PER<126 
and isnull(T2M_PER,0)<65
And SR is not null'
Print (@sql)
Exec (@sql)

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_Incentive=1500*((SR_GA_PER+SR_UAO_PER+20)/100)
where SR_GA_PER+SR_UAO_PER<126 
and T2M_PER>=65
And SR is not null'
Print (@sql)
Exec (@sql)

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_Incentive=1500*(1.25)
where SR_GA_PER+SR_UAO_PER>=126
and T2M_PER<65
And SR is not null'
Print (@sql)
Exec (@sql)

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_Incentive=1500*(1.25)
where SR_GA_PER+SR_UAO_PER+20>=126
and T2M_PER>=65
And SR is not null'
Print (@sql)
Exec (@sql)

Set @Sql='update Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' set SR_Incentive=0
where SR_GA_PER<30 or SR_UAO_PER<30'
Print (@sql)
Exec (@sql)

--Select 'Salesrep Output'
--Set @Sql='Select Hotspotid,SR,SR_GA_TGT,SR_UAO_TGT,UAO_Last,UAO_Final,SR_FCA_Curr,SR_UAO_Curr,T2M_FCA,T2M_Renewal,T2M_Per,SR_GA_PER,SR_UAO_PER,SR_incentive from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
--where SR is not null
--and exposure is null
--group by Hotspotid,SR,SR_GA_TGT,SR_UAO_TGT,UAO_Last,UAO_Final,SR_FCA_Curr,SR_UAO_Curr,T2M_FCA,T2M_Renewal,T2M_Per,SR_GA_PER,SR_UAO_PER,SR_incentive'
--Print (@sql)
--Exec (@sql)


--Select 'Teamlead Output'
--Set @Sql='Select Hotspotid,TL,TL_GA_TGT,TL_UAO_TGT,UAO_Last,UAO_Final,TL_FCA_Curr,TL_UAO_Curr,T2M_FCA,T2M_Renewal from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
--where TL is not null
--and exposure is null
--group by Hotspotid,TL,TL_GA_TGT,TL_UAO_TGT,UAO_Last,UAO_Final,TL_FCA_Curr,TL_UAO_Curr,T2M_FCA,T2M_Renewal'
--Print (@sql)
--Exec (@sql)


--Select 'AM outpout'
--Set @Sql='Select Hotspotid,AM,AM_GA_TGT,AM_UAO_TGT,UAO_Last,UAO_Final,AM_FCA_Curr,AM_UAO_Curr,T2M_FCA,T2M_Renewal from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
--where AM is not null
--and exposure is null
--group by Hotspotid,AM,AM_GA_TGT,AM_UAO_TGT,UAO_Last,UAO_Final,AM_FCA_Curr,AM_UAO_Curr,T2M_FCA,T2M_Renewal'
--Print (@sql)
--Exec (@sql)

--Select 'RM Output'
--Set @Sql='Select Hotspotid,RM,RM_GA_TGT,RM_UAO_TGT,UAO_Last,UAO_Final,RM_FCA_Curr,RM_UAO_Curr,T2M_FCA,T2M_Renewal from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+' 
--where RM is not null
--and exposure is null
--group by Hotspotid,RM,RM_GA_TGT,RM_UAO_TGT,UAO_Last,UAO_Final,RM_FCA_Curr,RM_UAO_Curr,T2M_FCA,T2M_Renewal'
--Print (@sql)
--Exec (@sql)

--Select 'Detail sheet'

--Set @Sql='Select Iccid,Activitydate,Bundlecode,	payment_mode,Bundlevalue,Resellerid,	Offmgrid,	Accmgrid,	Hotspotid,	Retailerid,	
--SR,TL,AM,RM,SR_GA_TGT,	SR_UAO_TGT,	TL_GA_TGT,	TL_UAO_TGT,	AM_GA_TGT,	AM_UAO_TGT,	RM_GA_TGT,	RM_UAO_TGT,UAO_Last,UAO_Final,
--SR_UAO_Curr,	TL_UAO_Curr,	AM_UAO_Curr,	RM_UAO_Curr,	SR_FCA_Curr,	TL_FCA_Curr,	AM_FCA_Curr,	RM_FCA_Curr,	
--T2M_FCA,	T2M_Renewal,	T2M_PER,	SR_GA_PER,	SR_UAO_PER,	SR_Incentive,	Exposure
--from Mis_1717_USA_Staff_Final_'+@YYYYMM1_112+''
--Print (@sql)
--Exec (@sql)

END


 
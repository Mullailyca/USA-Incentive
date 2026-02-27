
drop table #mis_6427
CreatedBy


Select RIGHT(ICCID,12)  iccid,Pmsisdn, Completeddate,CreatedBy retailerid into #mis_6427 from MNP_USA_ATT.DBO.mnpportinrequest   
where convert(varchar(07),CompletedDate,120) ='2025-12' and isnull(SIMCHANGETYPE,'')='SIMCHANGE' and status=10

--alter table #mis_6427 add retailerid varchar(100) 

alter table #mis_6427 add resellerid  varchar(100) 


alter table #mis_6427 add offmgrid  varchar(100) ,accmgrid varchar(100),hotspotid varchar(100)


--select * from mvnoreport_usa_lm..vw_mstsimactivation_cpos where len(simnumber)=23 
update a 
set a.retailerid=b.submittedby 
from #mis_6427 a,
mvnoreport_usa_lm..vw_mstsimactivation_cpos   b
where a.iccid =right(b.simnumber,12)  AND a.retailerid IS NULL 

update a 
set a.resellerid=b.resellerid 
from #mis_6427 a,
mvnoreport_usa_lm..vw_trnactivation  b
where a.iccid between b.iccid_fr and b.iccid_to 

update a 
set a.offmgrid=b.offmgrid ,a.accmgrid=b.accmgrid,a.hotspotid=b.hotspotid
from #mis_6427 a,
 mvnoreport_usa_lm..vw_dsmretailer b
where a.retailerid =b.retailerid



--reselleird
select resellerid,count(iccid)counts ,count(iccid)*10 comm from mis_6427_usa_sim_swap where retailerid is null
group by resellerid 

--retailerid

select resellerid,offmgrid,accmgrid,hotspotid,retailerid,count(iccid)counts ,count(iccid)*10 comm from #mis_6427 where retailerid  not like '%accounts%' and retailerid not like '%phl%' and retailerid not like '%mor%' 
and offmgrid  in ('NEWJERSEY-ST','Stall-Florida','stall-texas','stall-chicago','NEWJERSEY','FLORIDA','TEXAS',
'CHICAGO','CALIFORNIA','LMUS-HP-EUROPEANAGENCY','CLOSED_OFFICE')
group by resellerid,offmgrid,accmgrid,hotspotid,retailerid 

select * into  mis_6427_usa_sim_swap from #mis_6427

select * from  mis_6427_usa_sim_swap where retailerid='DD-YUKI WIRELESS'


select * from #mis_6427 where retailerid  not like '%accounts%' and retailerid not like '%phl%' and retailerid not like '%mor%' 



 ------------------------------------------------


 select resellerid,retailerid,count(iccid) from mis_6427_usa_sim_swap
 where retailerid not like '%dd%'
 group by resellerid,retailerid 
 order by count(iccid) desc



 -------------------------------------------------------------------------------new logic
 drop table #mis_6427

 Select LEFT(ICCID,8) ICCIDPREFIX, RIGHT(ICCID,12)  iccid,Pmsisdn, Completeddate,CreatedBy  into #mis_6427 from MNP_USA_ATT.DBO.mnpportinrequest   
where convert(varchar(07),CompletedDate,120) ='2025-12' and isnull(SIMCHANGETYPE,'')='SIMCHANGE' and status=10


ALTER TABLE #MIS_6427 ADD RESELLERID  VARCHAR(50) , OFFMGRID  VARCHAR(50) ,ACCMGRID VARCHAR(50),HOTSPOTID VARCHAR(50)
,RETAILERid VARCHAR(50)

UPDATE A
SET A.RESELLERID = B.RESELLERID
FROM #mis_6427 A,MVNOREPORT_USA_LM..VW_TRNACTIVATION B 
WHERE iccid BETWEEN B.ICCID_FR AND B.ICCID_TO

UPDATE A
SET A.HOTSPOTID = B.HOTSPOTID ,A.ACCMGRID = B.ACCMGRID ,A.OFFMGRID = B.OFFMGRID,a.RETAILERID=b.RETAILERID
FROM #mis_6427 A,MVNOREPORT_USA_LM..VW_DSMRETAILER B
WHERE A.createdby=B.RETAILERID

update a set a.retailerid=b.Createdby from 
#mis_6427 a   inner join
(select ICCID,Createdby,ChannelName,Updatedby from  [MVNO_USA].dbo.CBOS_ESIMRequest (nolock)
where ChannelName='CPOS') b
on a.iccidprefix+a.ICCID=b.ICCID
where a.RETAILERID is null

update a set a.retailerid=b.Updatedby from 
#mis_6427 a inner join
(select ICCID,Createdby,ChannelName,Updatedby from  [MVNO_USA].dbo.CBOS_ESIMRequest (nolock)
where ChannelName='CPOS') b
on a.iccidprefix+a.ICCID=b.ICCID
where a.retailerid is null

UPDATE A 
SET A.RETAILERID=B.SUBMITTEDBY 
FROM #MIS_6427 A JOIN 
mvnoreport_usa_lm..VW_MSTSIMACTIVATION_CPOS   B
ON  A.ICCID =RIGHT(B.SIMNUMBER,12) 
where a.retailerid is null

UPDATE A 
SET A.OFFMGRID=B.OFFMGRID ,A.ACCMGRID=B.ACCMGRID,A.HOTSPOTID=B.HOTSPOTID
FROM #MIS_6427 A JOIN 
mvnoreport_usa_lm..VW_DSMRETAILER B
ON  A.RETAILERID =B.RETAILERID



select * into mis_6427_simswp_new from 
 #MIS_6427 #MIS_6427 where createdby not like 'dd%' and retailerid is not null


select resellerid,offmgrid,accmgrid,hotspotid,retailerid,count(iccid)counts ,count(iccid)*10 comm from mis_6427_simswp_new where offmgrid in ('NEWJERSEY','FLORIDA','TEXAS',
'CHICAGO','CALIFORNIA') 
group by resellerid,offmgrid,accmgrid,hotspotid,retailerid


select resellerid,offmgrid,count(iccid)counts ,count(iccid)*10 comm from mis_6427_simswp_new where isnull(offmgrid,'') not in ('NEWJERSEY','FLORIDA','TEXAS',
'CHICAGO','CALIFORNIA') AND RETAILERID IS NULL
group by resellerid,offmgrid

-----------------cross check 2026-01-21

select * from mis_6427_simswp_new where retailerid='DD-AKADIGITAL10861'

select CreatedBy,* from MNP_USA_ATT.DBO.mnpportinrequest   where piccid in ('8919601000337406355','8901280232236375412','89012804331831775255','8919601000334101058')
and isnull(SIMCHANGETYPE,'')='SIMCHANGE' and status=10


select len ('89012804331831775255')

mvnoreport_usa_lm..vw_mstswapimsi where oldiccid in ('8919601000337406355','8901280232236375412','89012804331831775255','8919601000334101058')

--mvnoreport_usa_lm..vw_mstswapmsisdn where oldiccid in ('8919601000337406355','8901280232236375412','89012804331831775255','8919601000334101058')


 select * from mvnoreport_USA_LM.dbo.vw_mnpportoutrequest             
where 
--convert(varchar(07),CompletedDate,120) <='''+@month+'''            
  status='10' and iccid in ('8919601000337406355','8901280232236375412','89012804331831775255','8919601000334101058')


 select CreatedBy,* from MNP_USA_ATT.DBO.mnpportinrequest   where piccid in ('8919601000337406355','8901280232236375412','89012804331831775255','8919601000334101058')
and isnull(SIMCHANGETYPE,'')='SIMCHANGE' and status=10



select * from mis_6427_simswp_new where iccid='89012804331831775263'

#mis_6427

select * from #mis_6427 where iccid='89012804331831775263'

 select CreatedBy,* from MNP_USA_ATT.DBO.mnpportinrequest  where iccid='89012804331831775263' and convert(varchar(07),CompletedDate,120) ='2025-12'
 and isnull(SIMCHANGETYPE,'')='SIMCHANGE' 
 and status=10

 select * from mis_6427_simswp_new where iccidprefix+iccid='89012804331831775263'



 select * from mvnoreport_usa_lm..retailertransactions where retailerid='DD-AKADIGITAL10861' 
 order by trndate desc


 select * from Mis_1717_USA_Detail_comm_202512 where retailerid='DD-AKADIGITAL10861'

 ----------------------------------------------------------------------------------------------
 select * from  mis_6427_simswp_new where  iccidprefix+iccid in ('89012804331831775271',
'89012804331831775263',
'89012802332236375412')
--------------------------------------------------------------------------------------

select * from mvnoreport_USA_LM.dbo.vw_mnpportoutrequest  where iccid in ('8919601000337406355','8901280232236375412','8919601000334101058')

select distinct len (iccid) from mvnoreport_USA_LM.dbo.vw_mnpportoutrequest

select * from mis_6427_simswp_new where 
 offmgrid is null

 select * from MNP_USA_ATT.DBO.mnpportinrequest  where createdby is null and status=10

 [Vw_wlmstaffretailer]

 CREATE    VIEW [dbo].[Vw_wlmstaffretailer] AS   
select * from   
(  
SELECT StaffName ,MSISDN ,BTMode,UserID ,Password, Status ,Amount ,CreatedBy, CreatedDate ,staffMode, otherContact,EmailID,virtual_msisdn  
 FROM MVNO_USA.DBO.WLM_STAFFRETAILER    with (nolock)     
union  
SELECT StaffName ,MSISDN ,BTMode,UserID ,Password, Status ,Amount ,CreatedBy, CreatedDate ,staffMode, otherContact,EmailID,virtual_msisdn FROM MVNO_USA.DBO.WLM_StaffRetailerDeleted  with (nolock)     
  
)a

[Vw_wlmstaffretailer] where userid in ('Accounts',
'PHLGeraldBS30248',
'PHLGraceVS30184')
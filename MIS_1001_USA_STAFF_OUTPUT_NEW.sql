

ALTER procedure MIS_1001_USA_STAFF_OUTPUT
as
begin 



DECLARE @MonthSuffix VARCHAR(6) = FORMAT(DATEADD(MONTH, -1, GETDATE()), 'yyyyMM');
DECLARE @SQL NVARCHAR(MAX);

SELECT @MonthSuffix


SET @SQL='

IF OBJECT_ID(''dbo.Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ';


Select Hotspotid,SR,SR_GA_TGT,SR_UAO_TGT,UAO_Last, CASE WHEN SR_UAO_TGT >= UAO_Last THEN SR_UAO_TGT ELSE UAO_Last END AS uao_final,SR_FCA_Curr,SR_UAO_Curr,T2M_FCA,T2M_Renewal,T2M_Per,SR_GA_PER,SR_UAO_PER,SR_incentive 
INTO Mis_1001_USA_SR_Staff_BASE_'+@MonthSuffix +' from Mis_1717_USA_Staff_Final_'+ @MonthSuffix+' 
where SR is not null
and exposure is null
group by Hotspotid,SR,SR_GA_TGT,SR_UAO_TGT,UAO_Last,UAO_Final,SR_FCA_Curr,SR_UAO_Curr,T2M_FCA,T2M_Renewal,T2M_Per,SR_GA_PER,SR_UAO_PER,SR_incentive
'
EXEC(@SQL)

-------------------------------SR FINAL ATTENDANCE UPDATION 

SET @SQL='

ALTER TABLE Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ' ADD SR_DAYS INT,ATTENDANCE INT,FINAL FLOAT
'
exec(@sql)
SET @SQL='

--ALTER TABLE Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ' ADD SR_DAYS INT,ATTENDANCE INT,FINAL FLOAT

UPDATE A
SET A.SR_DAYS=B.SR_DAYS
FROM Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.SR=B.SALESREP

UPDATE A
SET A.ATTENDANCE=B.SR_PER
FROM Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.SR=B.SALESREP

UPDATE A
SET A.FINAL=CASE WHEN A.ATTENDANCE>90 THEN  SR_incentive ELSE 0 END
FROM Mis_1001_USA_SR_Staff_BASE_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.SR=B.SALESREP

'
EXEC(@SQL)
-------------------------------------------------------------

SET @SQL = N'
IF OBJECT_ID(''dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ';

IF OBJECT_ID(''dbo.Mis_1001_USA_TL_Staff_BASE_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_TL_Staff_BASE_' + @MonthSuffix + ';

SELECT distinct Hotspotid, TL, TL_GA_TGT, TL_UAO_TGT, UAO_Last,
       CASE WHEN TL_UAO_TGT >= UAO_Last THEN TL_UAO_TGT ELSE UAO_Last END AS uao_final,
       TL_FCA_Curr, TL_UAO_Curr, T2M_FCA, T2M_Renewal
INTO Mis_1001_USA_TL_Staff_BASE_' + @MonthSuffix + '
FROM Mis_1717_USA_Staff_Final_' + @MonthSuffix + '
WHERE TL IS NOT NULL
  AND exposure IS NULL
GROUP BY Hotspotid, TL, TL_GA_TGT, TL_UAO_TGT, UAO_Last, UAO_Final, TL_FCA_Curr, TL_UAO_Curr, T2M_FCA, T2M_Renewal;

;WITH CTE AS (
    SELECT TL, TL_GA_TGT, TL_UAO_TGT, UAO_Last, UAO_Final,
           TL_FCA_Curr, TL_UAO_Curr, T2M_FCA, T2M_Renewal
    FROM Mis_1001_USA_TL_Staff_BASE_' + @MonthSuffix + '
    WHERE TL IS NOT NULL
    GROUP BY TL, TL_GA_TGT, TL_UAO_TGT, UAO_Last, UAO_Final, TL_FCA_Curr, TL_UAO_Curr, T2M_FCA, T2M_Renewal
)
SELECT TL,
       SUM(TL_GA_TGT) AS TL_GA_TGT,
       SUM(UAO_Final) AS UAO_Final,
       SUM(TL_FCA_Curr) AS TL_FCA_Curr,
       SUM(TL_UAO_Curr) AS TL_UAO_Curr,
       SUM(T2M_FCA) AS T2M_FCA,
       SUM(T2M_Renewal) AS T2M_Renewal
INTO dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
FROM CTE
GROUP BY TL;

ALTER TABLE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
ADD T2M_Per FLOAT,
    TL_GA_PER FLOAT,
    TL_UAO_PER FLOAT,
    Overall_Per FLOAT,
    TL_incentive FLOAT;

UPDATE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
SET T2M_Per = ROUND(CAST(T2M_Renewal AS FLOAT) / NULLIF(CAST(T2M_FCA AS FLOAT), 0), 2);

UPDATE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
SET TL_GA_PER = ROUND((CAST(TL_FCA_Curr AS FLOAT) / NULLIF(CAST(TL_GA_TGT AS FLOAT), 0)) * 0.5, 2);

UPDATE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
SET TL_UAO_PER = ROUND((CAST(TL_UAO_Curr AS FLOAT) / NULLIF(CAST(UAO_Final AS FLOAT), 0)) * 0.5, 2);

UPDATE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
SET Overall_Per = CASE
    WHEN T2M_Per >= 0.65 THEN TL_GA_PER + TL_UAO_PER + 0.2
    ELSE TL_GA_PER + TL_UAO_PER
END;

UPDATE dbo.Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
SET TL_incentive = CASE
    WHEN TL_GA_TGT >= 600 THEN
        CASE
            WHEN TL_UAO_PER >= 0.3 THEN
                CASE
                    WHEN TL_GA_PER >= 0.3 THEN
                        CASE
                            WHEN Overall_Per >= 1.25 THEN 1.25 * 2000
                            ELSE Overall_Per * 2000
                        END
                    ELSE 0
                END
            ELSE 0
        END
    ELSE 0
END;
';

EXEC sp_executesql @SQL;


-------------------------------TL FINAL ATTENDANCE UPDATION 

set @sql='
ALTER TABLE Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ' ADD TL_DAYS INT,ATTENDANCE INT,FINAL FLOAT
'
exec(@sql)
SET @SQL='

--ALTER TABLE Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ' ADD TL_DAYS INT,ATTENDANCE INT,FINAL FLOAT

UPDATE A
SET A.TL_DAYS=B.TL_DAYS
FROM Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.TL=B.TEAMLEAD

UPDATE A
SET A.ATTENDANCE=B.TL_PER
FROM Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.TL=B.TEAMLEAD

UPDATE A
SET A.FINAL=CASE WHEN A.ATTENDANCE>90 THEN  TL_incentive ELSE 0 END
FROM Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.TL=B.TEAMLEAD

'
EXEC(@SQL)
-----------------------------------------------------


SET @SQL = N'

IF OBJECT_ID(''dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ';

IF OBJECT_ID(''dbo.Mis_1001_USA_AM_Staff_BASE_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_AM_Staff_BASE_' + @MonthSuffix + ';

SELECT DISTINCT Hotspotid, AM, AM_GA_TGT, AM_UAO_TGT, UAO_Last,
       CASE WHEN AM_UAO_TGT >= UAO_Last THEN AM_UAO_TGT ELSE UAO_Last END AS UAO_Final,
       AM_FCA_Curr, AM_UAO_Curr, T2M_FCA, T2M_Renewal
INTO Mis_1001_USA_AM_Staff_BASE_' + @MonthSuffix + '
FROM Mis_1717_USA_Staff_Final_' + @MonthSuffix + '
WHERE AM IS NOT NULL
  AND exposure IS NULL
GROUP BY Hotspotid, AM, AM_GA_TGT, AM_UAO_TGT, UAO_Last, UAO_Final, AM_FCA_Curr, AM_UAO_Curr, T2M_FCA, T2M_Renewal;

;WITH CTE AS (
    SELECT AM, AM_GA_TGT, AM_UAO_TGT, UAO_Last, UAO_Final, AM_FCA_Curr, AM_UAO_Curr, T2M_FCA, T2M_Renewal
    FROM Mis_1001_USA_AM_Staff_BASE_' + @MonthSuffix + '
    WHERE AM IS NOT NULL
    GROUP BY AM, AM_GA_TGT, AM_UAO_TGT, UAO_Last, UAO_Final, AM_FCA_Curr, AM_UAO_Curr, T2M_FCA, T2M_Renewal
)
SELECT AM,
       SUM(AM_GA_TGT) AS AM_GA_TGT,
       SUM(UAO_Final) AS UAO_Final,
       SUM(AM_FCA_Curr) AS AM_FCA_Curr,
       SUM(AM_UAO_Curr) AS AM_UAO_Curr,
       SUM(T2M_FCA) AS T2M_FCA,
       SUM(T2M_Renewal) AS T2M_Renewal
INTO dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
FROM CTE
GROUP BY AM;

ALTER TABLE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
ADD T2M_Per FLOAT,
    AM_GA_PER FLOAT,
    AM_UAO_PER FLOAT,
    Overall_Per FLOAT,
    AM_incentive FLOAT;

UPDATE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
SET T2M_Per = ROUND(CAST(T2M_Renewal AS FLOAT) / NULLIF(CAST(T2M_FCA AS FLOAT), 0), 2);

UPDATE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
SET AM_GA_PER = ROUND((CAST(AM_FCA_Curr AS FLOAT) / NULLIF(CAST(AM_GA_TGT AS FLOAT), 0)) * 0.5, 2);

UPDATE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
SET AM_UAO_PER = ROUND((CAST(AM_UAO_Curr AS FLOAT) / NULLIF(CAST(UAO_Final AS FLOAT), 0)) * 0.5, 2);

UPDATE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
SET Overall_Per = CASE
    WHEN T2M_Per >= 0.65 THEN AM_GA_PER + AM_UAO_PER + 0.2
    ELSE AM_GA_PER + AM_UAO_PER
END;

UPDATE dbo.Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
SET AM_incentive = CASE
    WHEN AM_GA_TGT >= 1000 AND AM_UAO_PER >= 0.3 AND AM_GA_PER >= 0.3 THEN
        CASE
            WHEN Overall_Per >= 1.25 THEN 1.25 * 2500
            ELSE Overall_Per * 2500
        END
    ELSE 0
END;
';

EXEC sp_executesql @SQL;

--Mis_1717_Staff_Master_202510
-----------------------------------------------------------ATTENDANCE AM

SET @SQL='

ALTER TABLE Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ' ADD AM_DAYS INT,ATTENDANCE INT,FINAL FLOAT

'
exec(@sql)
SET @SQL='

--ALTER TABLE Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ' ADD AM_DAYS INT,ATTENDANCE INT,FINAL FLOAT

UPDATE A
SET A.AM_DAYS=B.AM_DAYS
FROM Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.AM=B.AREAMANAGER

UPDATE A
SET A.ATTENDANCE=B.AM_PER
FROM Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.AM=B.AREAMANAGER

UPDATE A
SET A.FINAL=CASE WHEN A.ATTENDANCE>90 THEN  AM_incentive ELSE 0 END
FROM Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.AM=B.AREAMANAGER

'
EXEC(@SQL)

----------------------------------------------------------------------

SET @SQL = N'
IF OBJECT_ID(''dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ''') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ';

IF OBJECT_ID(''dbo.Mis_1001_USA_RM_Staff_BASE_' + @MonthSuffix + ''', ''U'') IS NOT NULL
    DROP TABLE dbo.Mis_1001_USA_RM_Staff_BASE_' + @MonthSuffix + ';

SELECT DISTINCT Hotspotid, RM, RM_GA_TGT, RM_UAO_TGT, UAO_Last,
    CASE WHEN RM_UAO_TGT >= UAO_Last THEN RM_UAO_TGT ELSE UAO_Last END AS UAO_Final,
    RM_FCA_Curr, RM_UAO_Curr, T2M_FCA, T2M_Renewal
INTO Mis_1001_USA_RM_Staff_BASE_' + @MonthSuffix + '
FROM Mis_1717_USA_Staff_Final_' + @MonthSuffix + '
WHERE RM IS NOT NULL
  AND exposure IS NULL
GROUP BY Hotspotid, RM, RM_GA_TGT, RM_UAO_TGT, UAO_Last, UAO_Final, RM_FCA_Curr, RM_UAO_Curr, T2M_FCA, T2M_Renewal;

;WITH CTE AS (
    SELECT RM, RM_GA_TGT, RM_UAO_TGT, UAO_Last, UAO_Final, RM_FCA_Curr, RM_UAO_Curr, T2M_FCA, T2M_Renewal
    FROM Mis_1001_USA_RM_Staff_BASE_' + @MonthSuffix + '
    WHERE RM IS NOT NULL
      AND Hotspotid NOT LIKE ''%TELE%''
    GROUP BY RM, RM_GA_TGT, RM_UAO_TGT, UAO_Last, UAO_Final, RM_FCA_Curr, RM_UAO_Curr, T2M_FCA, T2M_Renewal
)
SELECT RM,
       SUM(RM_GA_TGT) AS RM_GA_TGT,
       SUM(UAO_Final) AS UAO_Final,
       SUM(RM_FCA_Curr) AS RM_FCA_Curr,
       SUM(RM_UAO_Curr) AS RM_UAO_Curr,
       SUM(T2M_FCA) AS T2M_FCA,
       SUM(T2M_Renewal) AS T2M_Renewal
INTO dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
FROM CTE
GROUP BY RM;

ALTER TABLE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
ADD T2M_Per FLOAT,
    RM_GA_PER FLOAT,
    RM_UAO_PER FLOAT,
    Overall_Per FLOAT,
    Tele_Incentive FLOAT,
    Normal_Incentive FLOAT,
    Total_incentive FLOAT;

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET T2M_Per = ROUND(CAST(T2M_Renewal AS FLOAT) / NULLIF(CAST(T2M_FCA AS FLOAT), 0), 2);

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET RM_GA_PER = ROUND((CAST(RM_FCA_Curr AS FLOAT) / NULLIF(CAST(RM_GA_TGT AS FLOAT), 0)) * 0.4, 2);

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET RM_UAO_PER = ROUND((CAST(RM_UAO_Curr AS FLOAT) / NULLIF(CAST(UAO_Final AS FLOAT), 0)) * 0.6, 2);

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET Overall_Per = CASE
    WHEN T2M_Per >= 0.65 THEN RM_GA_PER + RM_UAO_PER + 0.2
    ELSE RM_GA_PER + RM_UAO_PER
END;

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET Normal_Incentive = CASE
    WHEN RM_UAO_PER >= 0.36 AND RM_GA_PER >= 0.24 THEN
        CASE
            WHEN Overall_Per >= 1.25 THEN 1.25 * 3500
            ELSE Overall_Per * 3500
        END
    ELSE 0
END;

;WITH TeleCTE AS (
    SELECT Hotspotid, RM, SUM(RM_FCA_Curr) AS RM_FCA_Curr
    FROM Mis_1001_USA_RM_Staff_BASE_' + @MonthSuffix + '
    WHERE Hotspotid LIKE ''%TELE%''
    GROUP BY Hotspotid, RM
)
UPDATE a
SET a.Tele_Incentive = b.RM_FCA_Curr * 0.05
FROM dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' a
INNER JOIN TeleCTE b ON a.RM = b.RM;

UPDATE dbo.Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
SET Total_incentive = ISNULL(Normal_Incentive, 0) + ISNULL(Tele_Incentive, 0);
';

EXEC sp_executesql @SQL;

SET @SQL='

ALTER TABLE Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' ADD RM_DAYS INT,ATTENDANCE INT,FINAL FLOAT
'
exec(@sql)
SET @SQL='

--ALTER TABLE Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' ADD RM_DAYS INT,ATTENDANCE INT,FINAL FLOAT

UPDATE A
SET A.RM_DAYS=B.RM_DAYS
FROM Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.RM=B.REGMANAGER

UPDATE A
SET A.ATTENDANCE=B.RM_PER
FROM Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.RM=B.REGMANAGER

UPDATE A
SET A.FINAL=CASE WHEN A.ATTENDANCE>90 THEN  Total_incentive ELSE 0 END
FROM Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + ' A JOIN Mis_1717_Staff_Master_'+@MonthSuffix+' B
ON A.RM=B.REGMANAGER

'
EXEC(@SQL)


Select 'Salesrep Output'
Set @Sql='
SELECT * FROM Mis_1001_USA_SR_Staff_BASE_'+@MonthSuffix +'
'
Exec (@sql)



Set @Sql='
Select ''TL DATA''
SELECT * FROM Mis_1001_USA_TL_Staff_BASE_'+@MonthSuffix +'
select ''TL final''
SELECT * FROM Mis_1001_USA_TL_Staff_Final_' + @MonthSuffix + '
'
Print (@sql)
Exec (@sql)

Set @Sql='
Select ''AM DATA''
SELECT * FROM Mis_1001_USA_AM_Staff_BASE_'+@MonthSuffix +'
select ''AM final''
SELECT * FROM Mis_1001_USA_AM_Staff_Final_' + @MonthSuffix + '
'
Print (@sql)
Exec (@sql)

Set @Sql='
Select ''RM DATA''
SELECT * FROM Mis_1001_USA_RM_Staff_BASE_'+@MonthSuffix +'
select ''RM final''
SELECT * FROM Mis_1001_USA_RM_Staff_Final_' + @MonthSuffix + '
'
Print (@sql)
Exec (@sql)

Select 'Detail sheet'

Set @Sql='Select Iccid,Activitydate,Bundlecode,	payment_mode,Bundlevalue,Resellerid,	Offmgrid,	Accmgrid,	Hotspotid,	Retailerid,	
SR,TL,AM,RM,SR_GA_TGT,	SR_UAO_TGT,	TL_GA_TGT,	TL_UAO_TGT,	AM_GA_TGT,	AM_UAO_TGT,	RM_GA_TGT,	RM_UAO_TGT,UAO_Last,UAO_Final,
SR_UAO_Curr,	TL_UAO_Curr,	AM_UAO_Curr,	RM_UAO_Curr,	SR_FCA_Curr,	TL_FCA_Curr,	AM_FCA_Curr,	RM_FCA_Curr,	
T2M_FCA,	T2M_Renewal,	T2M_PER,	SR_GA_PER,	SR_UAO_PER,	SR_Incentive,	Exposure
from Mis_1717_USA_Staff_Final_'+ @MonthSuffix+''
Print (@sql)
Exec (@sql)


END














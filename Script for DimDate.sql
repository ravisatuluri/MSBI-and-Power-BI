CREATE TABLE  dbo.DimDate(
DateKey                            INT NOT NULL
,DateFullName               VARCHAR(50) NULL
,DateFull                           DATE NULL
,Year                                   INT NULL
,Quarter                            INT NULL
,QuarterName               VARCHAR(50) NULL
,QuarterFullName        VARCHAR(50) NULL
,QuarterKey                    INT NULL
,Month                              INT NULL
,MonthKey                      INT NULL
,MonthName                 VARCHAR(50) NULL
,DayOfMonth                 INT NULL
,NumberOfDaysInTheMonth         INT NULL
,DayOfYear                       INT NULL
,WeekOfYear                   INT NULL
,WeekOfYearKey           INT NULL
,ISOWeek                          INT NULL
,ISOWeekKey                  INT NULL
,WeekDay                         INT NULL
,WeekDayName             VARCHAR(50) NULL
,FiscalYear                         INT NULL
,FiscalQuarter                  INT NULL
,FiscalQuarterKey          INT NULL
,FiscalMonth                    INT NULL
,FiscalMonthKey            INT NULL
,IsWorkDayKey                    INT NULL
,IsWorkDayDescription   VARCHAR(50) NULL
,CalendarQuarter        VARCHAR(50) NULL
,CalendarYear               VARCHAR(50) NULL
,CalendarSemester       VARCHAR(50) NULL
,IsLeapYear                       INT NULL
,Has53Weeks                   VARCHAR(50) NULL
,Has53ISOWeeks                    VARCHAR(50) NULL
,MMYYYY                                   VARCHAR(50) NULL
,Style101                                    VARCHAR(50) NULL
,Style103                                    VARCHAR(50) NULL
,Style112                                    VARCHAR(50) NULL
,Style120                                    VARCHAR(50) NULL
,FirstDayOfWeekStartFromSunday                                        VARCHAR(50) NULL
,LastDayOfWeekStartFromSunday                           VARCHAR(50) NULL
,FirstDayOfWeekStartFromMonday                        VARCHAR(50) NULL
,LastDayOfWeekStartFromMonday                         VARCHAR(50) NULL
,FirstDayOfWeekStartFromTuesday                        VARCHAR(50) NULL
,LastDayOfWeekStartFromTuesday                         VARCHAR(50) NULL
,FirstDayOfWeekStartFromWednesday               VARCHAR(50) NULL
,LastDayOfWeekStartFromWednesday               VARCHAR(50) NULL
,FirstDayOfWeekStartFromThursday                    VARCHAR(50) NULL
,LastDayOfWeekStartFromThursday                       VARCHAR(50) NULL
,FirstDayOfWeekStartFromFriday                             VARCHAR(50) NULL
,LastDayOfWeekStartFromFriday                             VARCHAR(50) NULL
,FirstDayOfWeekStartFromSaturday                     VARCHAR(50) NULL
,LastDayOfWeekStartFromSaturday                        VARCHAR(50) NULL
CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED
(
DateKey ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

) ON [PRIMARY]


--------------- Insert statement for DimDate  ------
GO

declare @CurrentDate date
declare @FiscalYearStartMonth int
declare @WeeklyHolidays table (WeekDay int) -- weekday, sunday is 1 and saturday is 7
declare @FirstDate date
declare @NumberOfYearsToGenerate int
declare @LastDate date
 
set @FirstDate='1990-01-01'
set @NumberOfYearsToGenerate=40
 
-- do not change line below

set @LastDate=DATEADD(YEAR,@NumberOfYearsToGenerate,@FirstDate)
set @CurrentDate=@FirstDate
set @FiscalYearStartMonth=7
 
-- insert weekly holidays
insert into @WeeklyHolidays(WeekDay) values(1) -- sunday
insert into @WeeklyHolidays(WeekDay) values(7) -- saturday

while(@CurrentDate<@LastDate)
begin
 
INSERT INTO DimDate
           (
                                   DateKey                                                                                                                           
                                   ,DateFullName                                                                                              
                                   ,DateFull                                                                                                          
                                   ,Year                                                                                                                  
                                   ,Quarter                                                                                                           
                                   ,QuarterName                                                                                              
                                   ,QuarterFullName                                                                       
                                   ,QuarterKey                                                                                                   
                                   ,Month                                                                                                                             
                                   ,MonthKey                                                                                                     
                                   ,MonthName                                                                                                
                                   ,DayOfMonth                                                                                                
                                   ,NumberOfDaysInTheMonth                                                 
                                   ,DayOfYear                                                                                                     
                                   ,WeekOfYear                                                                                                 
                                   ,WeekOfYearKey                                                                                         
                                   ,ISOWeek                                                                                                        
                                   ,ISOWeekKey                                                                                                
                                   ,WeekDay                                                                                                       
                                   ,WeekDayName                                                                                           
                                   ,FiscalYear                                                                                                       
                                   ,FiscalQuarter                                                                                
                                   ,FiscalQuarterKey                                                                        
                                   ,FiscalMonth                                                                                  
                                   ,FiscalMonthKey                                                                                          
                                   ,IsWorkDayKey                                                                                             
                                   ,IsWorkDayDescription                                                              
                                   ,CalendarQuarter                                                                         
                                   ,CalendarYear                                                                                
                                   ,CalendarSemester                                                                     
                                   ,IsLeapYear                                                                                                     
                                   ,Has53Weeks                                                                                                 
                                   ,Has53ISOWeeks                                                                                          
                                   ,MMYYYY                                                                                                                         
                                   ,Style101                                                                                                          
                                   ,Style103                                                                                                          
                                   ,Style112                                                                                                          
                                   ,Style120                                                                                                          
                                   ,FirstDayOfWeekStartFromSunday                      
                                   ,LastDayOfWeekStartFromSunday                       
                                   ,FirstDayOfWeekStartFromMonday                    
                                   ,LastDayOfWeekStartFromMonday                     
                                   ,FirstDayOfWeekStartFromTuesday                    
                                   ,LastDayOfWeekStartFromTuesday                     
                                   ,FirstDayOfWeekStartFromWednesday             
                                   ,LastDayOfWeekStartFromWednesday             
                                   ,FirstDayOfWeekStartFromThursday  
                                   ,LastDayOfWeekStartFromThursday                   
                                   ,FirstDayOfWeekStartFromFriday                         
                                   ,LastDayOfWeekStartFromFriday                         
                                   ,FirstDayOfWeekStartFromSaturday   
                                   ,LastDayOfWeekStartFromSaturday                                       
)
 
 
select 
convert(int,convert(varchar(8),@CurrentDate,112))                                                       as DateKey,
convert(varchar(max),@CurrentDate,106)                                                                                                           as DateFullName,
@CurrentDate                                                                                                                                                                                                  as DateFull,
datepart(year,@CurrentDate)                                                                                                                                   as Year,
datepart(QUARTER,@CurrentDate)                                                                                                                                        as Quarter,
'QTR '+datename(QUARTER,@CurrentDate)                                                                                                       as QuarterName,
CASE DATEPART(QQ, @CurrentDate)
                                                WHEN 1 THEN 'First'
                                                WHEN 2 THEN 'Second'
                                                WHEN 3 THEN 'Third'
                                                WHEN 4 THEN 'Fourth'
                                                END  + ' Quarter'                                                                                                                                               as QuarterFullName,
convert(int,datename(year,@CurrentDate)
+datename(QUARTER,@CurrentDate))                                                                                                                                 as QuarterKey,
datepart(month,@CurrentDate)                                                                                                                                              as Month,
convert(int,datename(year,@CurrentDate)
+right('0'+convert(varchar(2),datepart(month,@CurrentDate)),2)) as MonthKey,
datename(month,@CurrentDate)                                                                                                                                           as MonthName,
datepart(day,@CurrentDate)                                                                                                                                     as DayOfMonth,
datepart(day,EOMONTH(@CurrentDate))                                                                                                           as NumberOfDaysInTheMonth,
datepart(DAYOFYEAR,@CurrentDate)                                                                                                                    as DayOfYear,
datepart(WEEK,@CurrentDate)                                                                                                                                                as WeekOfYear,
datename(year,@CurrentDate)
+right('0'+datename(week,@CurrentDate),2)                                                                                   as WeekOfYearKey,
datepart(ISO_WEEK,@CurrentDate)                                                                                                                       as ISOWeek,
datename(year,@CurrentDate)+
right('0'+convert(varchar(2),datepart(ISO_WEEK,@CurrentDate)),2) as ISOWeekKey,
datepart(WEEKDAY,@CurrentDate)                                                                                                                                        as WeekDay,
datename(WEEKDAY,@CurrentDate)                                                                                                                                     as WeekDayName,
case when month(@CurrentDate)<@FiscalYearStartMonth
                then year(@CurrentDate)
                else year(@CurrentDate)+1 end                                                                                                                               as FiscalYear,
ceiling(convert(float,(
                                case when month(@CurrentDate)=13-@FiscalYearStartMonth
                                then 12
                                else ((@FiscalYearStartMonth-1)
                                +month(@CurrentDate))%12 end))/3)                                                                                  as FiscalQuarter,
convert(varchar(4),
                                case when month(@CurrentDate)<@FiscalYearStartMonth
                                then year(@CurrentDate) else year(@CurrentDate)+1 end)
                                +convert(varchar(1),ceiling(convert(float,
                                (case when month(@CurrentDate)=13-@FiscalYearStartMonth
                                then 12 else ((@FiscalYearStartMonth-1)
                                +month(@CurrentDate))%12 end))/3))                                                                                 as FiscalQuarterKey,
case when month(@CurrentDate)=13-@FiscalYearStartMonth
 then 12 else ((@FiscalYearStartMonth-1)
 +month(@CurrentDate))%12 end                                                                                                                                           as FiscalMonth,
convert(varchar(4),
case when month(@CurrentDate)<@FiscalYearStartMonth
then year(@CurrentDate) else year(@CurrentDate)+1 end)
+right('0'+convert(varchar(2),
case when month(@CurrentDate)=13-@FiscalYearStartMonth
then 12 else ((@FiscalYearStartMonth-1)
+month(@CurrentDate))%12 end),2)                                                                                                                     as FiscalMonthKey,
case when datepart(WEEKDAY,@CurrentDate)
in (select weekday from @WeeklyHolidays) then 1 else 0 end                    as IsWorkDayKey,
case when datepart(WEEKDAY,@CurrentDate)
in (select weekday from @WeeklyHolidays)
then 'Weekend' else 'Workday' end                                                                                                                        as IsWorkDayDescription,
datepart(qq, @CurrentDate)                                                                                                                                                      as CalendarQuarter,
    year(@CurrentDate)                                                                                                                                                                  as CalendarYear,
    case datepart(qq,@CurrentDate)
        when 1 then 1
        when 2 then 1
        when 3 then 2
        when 4 then 2
    end                                                                                                                                                                                                                    as CalendarSemester,
CONVERT(bit, CASE WHEN
(datepart(year,@CurrentDate) % 400 = 0)
OR (datepart(year,@CurrentDate) % 4 = 0
AND datepart(year,@CurrentDate) % 100 <> 0)
THEN 1 ELSE 0 END)                                                                                                                                                                         as IsLeapYear,
CASE WHEN
DATEPART(ISO_WEEK,DATEFROMPARTS(YEAR(@CurrentDate), 12, 31)) = 53
THEN 1 ELSE 0 END                                                                                                                                                                                           as   Has53Weeks,
CASE WHEN
DATEPART(WEEK,DATEFROMPARTS(YEAR(@CurrentDate), 12, 31)) = 53
THEN 1 ELSE 0 END                                                                                                                                                                                           as  Has53ISOWeeks,
CONVERT(char(2), CONVERT(char(8), @CurrentDate, 101))
+ CONVERT(char(4), datepart(year,@CurrentDate))                                                        as  MMYYYY,
CONVERT(char(10), @CurrentDate, 101)                                                                                                               as Style101,
CONVERT(char(10), @CurrentDate, 103)                                                                                                               as Style103,
CONVERT(char(8),  @CurrentDate, 112)                                                                                                                as Style112,
CONVERT(char(10), @CurrentDate, 120)                                                                                                               as Style120,
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromSunday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 0-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromSunday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 2-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromMonday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 1-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromMonday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 3-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromTuesday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 2-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromTuesday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 4-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromWednesday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 3-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromWednesday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 5-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromThursday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 4-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromThursday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 6-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromFriday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 5-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromFriday',
CONVERT(char(10),DATEADD(wk, 0, DATEADD(DAY, 7-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'FirstDayOfWeekStartFromSaturday',
CONVERT(char(10),DATEADD(wk, 1, DATEADD(DAY, 6-DATEPART(WEEKDAY, @CurrentDate), DATEDIFF(dd, 0, @CurrentDate))), 120)  as 'LastDayOfWeekStartFromSaturday'
 
set @CurrentDate=dateadd(day,1,@CurrentDate)

end


GO
select * from dbo.DimDate
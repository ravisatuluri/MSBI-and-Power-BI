--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateCalendardaysandCalendar](
	 @IntCalendarId			TINYINT			=NULL
	,@VcCalendarName		VARCHAR(50)
	,@VcCalendarDesc		VARCHAR(250) 	=NULL
	,@BitSun_Off			BIT				=NULL
	,@BitMon_Off			BIT				=NULL
	,@BitTue_Off			BIT				=NULL
	,@BitWed_Off			BIT				=NULL
	,@BitThu_Off			BIT				=NULL
	,@BitFri_Off			BIT				=NULL
	,@BitSat_Off			BIT				=NULL
	,@XmCalendarDays 		XML				=NULL
	,@TinOperFlag			TINYINT			=NULL
---------------------------------Common Columns---------------------------------
	,@IntSuccess			INT				OUTPUT
	,@VcError_Message		VARCHAR(1000)	OUTPUT
---------------------------------Common Columns-----------------------------------
)AS    
DECLARE @IDENTITY INT=0,@IntMsgID INT,@CalendarNewId  TINYINT,@internal_success INT,@internal_error_message VARCHAR(1000),@DateExistsFlag BIT=0,@IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRANSACTION T1
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF  @TinOperFlag=0 
		BEGIN
			IF LEN(@VcCalendarName)>0
			BEGIN
				INSERT INTO [cmrf].[TBL_Calendar]([VcCalendarname],[VcCalendarDesc],[BitSun_Off],[BitMon_Off],[BitTue_Off],[BitWed_Off],[BitThu_Off],[BitFri_Off],[BitSat_Off],[IntCreatedBy_IntBusinessEntityID],[DtCreatedDate])
				VALUES (@VcCalendarName,@VcCalendarDesc,@BitSun_Off,@BitMon_Off,@BitTue_Off,@BitWed_Off,@BitThu_Off,@BitFri_Off,@BitSat_Off,@IntUserID,@DtActionDate)
				SET @CalendarNewId=SCOPE_IDENTITY();
				SET @IntCalendarId=@CalendarNewId
				SET @IntSuccess=1
				SET @IntMsgID =200038
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END	

		IF @TinOperFlag =1
		BEGIN
			IF (@IntCalendarId)>0 
			BEGIN
				UPDATE [cmrf].[TBL_Calendar]
				SET [VcCalendarname]					=@VcCalendarName,
					[VcCalendarDesc]					=@VcCalendarDesc,
					[BitSun_Off]						=@BitSun_Off,
					[BitMon_Off]						=@BitMon_Off,
					[BitTue_Off]						=@BitTue_Off,
					[BitWed_Off]						=@BitWed_Off,
					[BitThu_Off]						=@BitThu_Off,
					[BitFri_Off]						=@BitFri_Off,
					[BitSat_Off]						=@BitSat_Off,
					[IntModifiedBy_IntBusinessEntityID]	=@IntUserID,
					[DtModifiedDate]					=@DtActionDate
				WHERE [TinCalendarId]					=@IntCalendarId
				IF @@ROWCOUNT=1
				BEGIN
					SET @IntSuccess=1
					SET @IntMsgID =200039
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
				END
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END

		DECLARE @CalendarDays TABLE
		(
			[RecId]			SMALLINT,
			[CalendarId]	TINYINT,
			[dt]			DATE,
			[description]	VARCHAR(100)
		) 
		INSERT INTO @CalendarDays([RecId],[CalendarId],[dt],[description])
		SELECT 
			ISNULL(LTRIM(RTRIM(tab.col.value('@RecId','SMALLINT'))),0) [RecId],
			ISNULL(LTRIM(RTRIM(tab.col.value('@CalendarId','TINYINT'))),0) [CalendarId],  
			ISNULL(LTRIM(RTRIM(tab.col.value('@dt','DATE'))),'') [dt],
			ISNULL(LTRIM(RTRIM(tab.col.value('@description','VARCHAR(100)'))),'') [description] 
		FROM @XmCalendarDays.nodes('//Key') tab(col)
		
		MERGE INTO [cmrf].[TBL_CalendarDays] T
		USING @CalendarDays S
		ON T.[IntRecId]=S.[RecId]
		
		WHEN NOT MATCHED THEN
		INSERT ([TinCalendarId],[DtDate],[VcDescription])
		VALUES(@IntCalendarId,s.dt,s.description)

		WHEN MATCHED THEN
		UPDATE SET 
			T.[TinCalendarId]	=S.CalendarId,
			T.[DtDate]			=S.dt,
			T.[VcDescription]	=S.description;
	
		IF  @TinOperFlag=1
		BEGIN
			SET @IntSuccess=1
			SET @IntMsgID =200039
			SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
		END
		ELSE
		BEGIN
			SET @IntSuccess=1
			SET @IntMsgID =200038
			SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
		END

		IF  @TinOperFlag=2
		BEGIN
			DECLARE @Del_CalendarDays table ([RecId] SMALLINT) 
			INSERT INTO @Del_CalendarDays ([RecId])
			SELECT ISNULL(LTRIM(RTRIM(tab.col.value('@RecId','INT'))),0) [RecId] 
			FROM @XmCalendarDays.nodes('//Key') tab(col)

			IF EXISTS(SELECT 1 FROM @Del_CalendarDays WHERE ISNULL([RecId],0)>0)
			BEGIN
				DELETE [cmrf].[TBL_CalendarDays] 
				FROM @Del_CalendarDays d, [cmrf].[TBL_CalendarDays] c
				WHERE c.IntRecId=d.RecId
			SET @IntSuccess=1
			SET @IntMsgID =200072
			SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END 
	COMMIT TRANSACTION T1
END TRY
BEGIN CATCH
	IF ERROR_NUMBER()=2601
	BEGIN
		SET @VcError_Message='Holiday Date Already Exists. Please Try With a Different Date.'
	END
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRANSACTION T1
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * ERROR_NUMBER()      
END CATCH

/*

----------------------------To Insert

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000), @XmCalendarDays XML

EXEC [cmrf].[STP_InsertUpdateCalendardaysandCalendar]

 @IntCalendarId		=''
,@VcCalendarName	='DemoTestingsss'
,@VcCalendarDesc	='DemoTestingsss'
,@BitSun_Off		=1
,@BitMon_Off		=0
,@BitTue_Off		=0
,@BitWed_Off		=0
,@BitThu_Off		=0
,@BitFri_Off		=0
,@BitSat_Off		=0
,@XmCalendarDays	='<root>
  <Key RecId="4741" CalendarId="85" dt="11/27/2015" description="Hi Holiday"></Key>
</root>' 	
,@TinOperFlag		=0
----------------
,@IntSuccess		=@IntSuccess		OUTPUT
,@VcError_Message	=@VcError_Message	OUTPUT

SELECT @IntSuccess, @VcError_Message

SELECT * FROM [cmrf].[TBL_Calendar] order by 1


----------------------------To Update

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000), @XmCalendarDays XML

EXEC [cmrf].[STP_InsertUpdateCalendardaysandCalendar]

 @IntCalendarId		=79
,@VcCalendarName	='Testz'
,@VcCalendarDesc	='Testingz'
,@BitSun_Off		=0
,@BitMon_Off		=0
,@BitTue_Off		=0
,@BitWed_Off		=0
,@BitThu_Off		=0
,@BitFri_Off		=0
,@BitSat_Off		=1
,@XmCalendarDays	='' 	
,@TinOperFlag		=1
----------------
,@IntSuccess		=@IntSuccess		OUTPUT
,@VcError_Message	=@VcError_Message	OUTPUT

SELECT @IntSuccess, @VcError_Message

SELECT * FROM [cmrf].[TBL_Calendar] order by 1


----------------------------To Delete

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000), @XmCalendarDays XML

EXEC [cmrf].[STP_InsertUpdateCalendardaysandCalendar]

 @IntCalendarId		=''
,@VcCalendarName	=''
,@VcCalendarDesc	=''
,@BitSun_Off		=0
,@BitMon_Off		=0
,@BitTue_Off		=0
,@BitWed_Off		=0
,@BitThu_Off		=0
,@BitFri_Off		=0
,@BitSat_Off		=1
,@XmCalendarDays	='<root><Key RecId="36" /></root>'
,@TinOperFlag		=2
----------------
,@IntSuccess		=@IntSuccess		OUTPUT
,@VcError_Message	=@VcError_Message	OUTPUT

SELECT @IntSuccess, @VcError_Message

SELECT * FROM [cmrf].[TBL_Calendardays] order by 1


*/

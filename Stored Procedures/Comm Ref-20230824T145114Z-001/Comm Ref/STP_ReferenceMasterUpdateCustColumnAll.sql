--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_referenceMasterUpdateCustColumnALL] (
	@VcReferenceMasterName		VARCHAR(200),
	@XmCustomColValues			XML,
	@BintLineReference 			BIGINT,
-----------------------common columns------------------
	@IntSuccess					INT				OUTPUT,
	@VcError_Message			VARCHAR(1000)	OUTPUT
-----------------------common columns------------------
) AS
DECLARE @IntMsgID INT ,@id SMALLINT,@Intsrno INT,@IntSeq INT,@i INT,@IntUserID int,@DtActionDate datetime,
@columnCode VARCHAR(100),
@value NVARCHAR(4000)
BEGIN 
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRY
		BEGIN TRAN T1
			SET NOCOUNT ON
			SET @IntSuccess=0
			SELECT @id =SinID FROM cmrf.TBL_referenceMasters WITH(NOLOCK) WHERE VcReferenceMasterName=@VcReferenceMasterName

			DECLARE @customColumns TABLE (Intsrno SMALLINT IDENTITY(1,1),columnCode VARCHAR(100), value VARCHAR(8000))

			INSERT INTO @customColumns  (columnCode,value)
			SELECT 
			tab.col.value('@columnCode','VARCHAR(100)'),
			tab.col.value('@value','NVARCHAR(4000)')
			FROM @XmCustomColValues.nodes('customColumns/data') tab(col)
			OPTION (OPTIMIZE FOR ( @XmCustomColValues = NULL )) 

			SET @i=1
			WHILE @i<=(SELECT 1 FROM @customColumns) AND 1=2
			BEGIN
				SELECT @columnCode=columnCode,@value =value FROM @customColumns WHERE Intsrno=@i
				--____________________________________________________________________________________________________
			
				SELECT @Intsrno=Intsrno FROM [cmrf].[TBL_ReferenceMastersCustColName] WITH(NOLOCK) WHERE [VcColumnCode] =@columnCode
				IF @id>0 and @Intsrno >0
				BEGIN
					SELECT @IntSeq=IntSeq FROM [cmrf].[TBL_ReferenceMastersCustColLink] WITH(NOLOCK) WHERE IntCustCol_srno=@Intsrno and SinID =@id
				END
			
				IF @IntSeq>0
				BEGIN
					SET @IntSuccess=1
					UPDATE cmrf.TBL_referenceMastersCustColVal SET 
						Nvcvalue							=@value,
						[IntModifiedBy_IntBusinessEntityID]	=@IntUserID,[DtModifiedDate]=@DtActionDate	 
					WHERE BintLink_Seq = @IntSeq AND BintLineReference=@BintLineReference
					IF @@ROWCOUNT=0
					BEGIN 
						INSERT INTO cmrf.TBL_referenceMastersCustColVal(BintLink_Seq,BintLineReference,Nvcvalue,IntCreatedBy_IntBusinessEntityID,DtCreatedDate) VALUES (@IntSeq,@BintLineReference,@value,@IntUserID,@DtActionDate)
					END
				END			
				--____________________________________________________________________________________________________
				SET @i=@i+1
			END
		COMMIT TRAN T1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		BEGIN
			ROLLBACK TRAN T1
		END
		EXEC err.STP_LogError
		SET @IntSuccess = -1 * Error_Number()  
		SET @VcError_Message = ERROR_MESSAGE()             
	END CATCH
END

/*

DECLARE @IntSuccess INT,@VcError_Message VARCHAR(1000)
EXEC cmrf.STP_referenceMasterUpdateCustColumnALL 
@VcReferenceMasterName			='broker',

@XmCustomColValues='

<customColumns>
	<data columnCode="yeild1" value="100.00" />
	<data columnCode="yeild32" value="400.00" />
	<data columnCode="yeild44" value="500.00" />
</customColumns>',

@BintLineReference			=2,
@IntSuccess			=@IntSuccess	OUTPUT,
@VcError_Message		=@VcError_Message	OUTPUT
SELECT @IntSuccess,@VcError_Message


*/

/*

SELECT * FROM cmrf.TBL_referenceMasters 
SELECT * FROM [cmrf].[TBL_ReferenceMastersCustColLink]
SELECT * FROM [cmrf].[TBL_ReferenceMastersCustColName]
SELECT * FROM cmrf.TBL_referenceMastersCustColVal

*/
GO



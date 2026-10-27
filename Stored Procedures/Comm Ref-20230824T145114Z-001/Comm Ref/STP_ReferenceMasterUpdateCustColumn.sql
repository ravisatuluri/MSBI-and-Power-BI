--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_referenceMasterUpdateCustColumn] (
	@VcReferenceMasterName	VARCHAR(200),
	@VcColumnCode			VARCHAR(1000),
	@VcValue				VARCHAR(1000),
	@BintLineReference 		BIGINT,
---------------------------common columns_____________________________________
	@IntSuccess				INT				OUTPUT,
	@VcError_Message		VARCHAR(1000)	OUTPUT
---------------------------common columns_____________________________________
) AS
DECLARE @IntMsgID INT ,@id [SMALLINT] ,@Intsrno INT,@IntSeq INT,@IntUserID INT,@DtActionDate datetime
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
		BEGIN
			SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
		END
		BEGIN TRAN T1
			SET @IntSuccess=0
			SELECT @id =SinID FROM cmrf.TBL_referenceMasters WITH(NOLOCK) 
			WHERE VcReferenceMasterName=@VcReferenceMasterName
			
			SELECT @Intsrno=Intsrno FROM [cmrf].[TBL_ReferenceMastersCustColName] WITH(NOLOCK) 
			WHERE [VcColumnCode] =@VcColumnCode
			IF @id>0 AND @Intsrno >0
			BEGIN
				SELECT @IntSeq=IntSeq FROM [cmrf].[TBL_ReferenceMastersCustColLink] WITH(NOLOCK)
				WHERE IntCustCol_srno=@Intsrno AND SinID =@id
			END
			IF @IntSeq>0
			BEGIN
				SET @IntSuccess=1
				UPDATE cmrf.TBL_referenceMastersCustColVal SET Nvcvalue=@VcValue,[IntModifiedBy_IntBusinessEntityID]=@IntUserID ,[DtModifiedDate]=@DtActionDate 
				WHERE BintLink_Seq = @IntSeq AND BintLineReference=@BintLineReference
				IF @@ROWCOUNT=0
				BEGIN 
					INSERT INTO  cmrf.TBL_referenceMastersCustColVal(BintLink_Seq,BintLineReference,Nvcvalue,IntCreatedBy_IntBusinessEntityID,DtCreatedDate) 
					VALUES (@IntSeq,@BintLineReference,@VcValue,@IntUserID,@DtActionDate)
				END
			END
		COMMIT TRAN T1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		BEGIN
			ROLLBACK TRAN T1
		END
		EXEC err.STP_LogError
		SET @IntSuccess = -1 * ERROR_NUMBER()  
		SET @VcError_Message = ERROR_MESSAGE()             
	END CATCH
END

/*

DECLARE @IntSuccess INT,@VcError_Message VARCHAR(1000)
EXEC cmrf.STP_referenceMasterUpdateCustColumn 
@VcReferenceMasterName	='Currency',
@VcColumnCode			='c1',
@VcValue				='v13',
@BintLineReference		=2,
@IntSuccess				=@IntSuccess	OUTPUT,
@VcError_Message		=@VcError_Message	OUTPUT

SELECT @IntSuccess,@VcError_Message

*/
GO



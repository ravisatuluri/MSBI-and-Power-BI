--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateFundFamily](
	@IntFundFamilyID			INT			=NULL,
	@BintClientDefinitionID		BIGINT		=NULL,
	@VcFundFamilyCode			VARCHAR(20) =NULL,
	@VcFundFamilyName			VARCHAR(100)=NULL,
	@VcInvestmentRegion			VARCHAR(50)	=NULL,
	@BitIsActive				BIT			=NULL,
	@DtInceptionDate			DATE		=NULL,
	@XmCustomColValues			XML			=NULL,
	@BitOperFlag				BIT			=NULL,
---------------------------------Common Columns---------------------------------
	@IntSuccess					INT				OUTPUT,
	@VcError_Message			VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)AS
DECLARE @IDENTITY INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRAN T1
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF @BitOperFlag =0
		BEGIN
			IF LEN(@VcFundFamilyCode)>0 AND LEN(@VcFundFamilyName)>0
			BEGIN
				SET @IntSuccess=1
				INSERT INTO [cmrf].[TBL_FundFamily](VcFundFamilyCode,VcFundFamilyName,VcInvestmentRegion,BitIsActive,IntClientDefinitionID,DtInceptionDate,IntCreatedBy_IntBusinessEntityID,DtCreatedDate) 
				VALUES (@VcFundFamilyCode,@VcFundFamilyName,@VcInvestmentRegion,@BitIsActive,@BintClientDefinitionID,@DtInceptionDate,@IntUserID,@DtActionDate)
				--------------- Region FOR Custom Columns @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				IF @IntSuccess=1
				BEGIN
					SET @IntSuccess=1
					SET @IntMsgID =200038
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
					IF @XmCustomColValues IS NOT NULL
					BEGIN
						BEGIN TRY
							EXEC cmrf.STP_referenceMasterUpdateCustColumnALL 
							@VcReferenceMasterName		='FundFamily',
							@XmCustomColValues			=@XmCustomColValues,
							@BintLineReference			=@IntFundFamilyID,
							@IntSuccess					=@internal_success	OUTPUT,
							@VcError_Message			=@internal_error_message	OUTPUT
						END TRY
						BEGIN CATCH
							EXEC err.STP_LogError
							SET @IntSuccess = -1 * ERROR_NUMBER()
							SET @VcError_Message = ERROR_MESSAGE()     
						END CATCH
					END
				END
				-----------------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END
		IF @BitOperFlag =1
		BEGIN
			IF LEN(@VcFundFamilyCode)>0 AND LEN(@VcFundFamilyName)>0 AND @IntFundFamilyID>0
			BEGIN
				SET @IntSuccess=1
				UPDATE [cmrf].[TBL_FundFamily]
				SET 
				 VcFundFamilyCode						=@VcFundFamilyCode
				 ,VcFundFamilyName						=@VcFundFamilyName
				 ,VcInvestmentRegion					=@VcInvestmentRegion
				 ,BitIsActive							=@BitIsActive
				 ,IntClientDefinitionID					=@BintClientDefinitionID
				 ,DtInceptionDate						=@DtInceptionDate
				 ,[IntModifiedBy_IntBusinessEntityID]	=@IntUserID
				 ,[DtModifiedDate]						=@DtActionDate
				WHERE [IntFundFamilyID]					=@IntFundFamilyID
				--------------- Region FOR Custom Columns @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				IF @IntSuccess=1
				BEGIN
					SET @IntSuccess=1
					SET @IntMsgID =200039
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
					IF @XmCustomColValues IS NOT NULL
					BEGIN
						BEGIN TRY
								EXEC cmrf.STP_referenceMasterUpdateCustColumnALL 
								@VcReferenceMasterName		='FundFamily',
								@XmCustomColValues			=@XmCustomColValues,
								@BintLineReference			=@IntFundFamilyID,
								@IntSuccess					=@internal_success			OUTPUT,
								@VcError_Message			=@internal_error_message	OUTPUT
						END TRY
						BEGIN CATCH
							EXEC err.STP_LogError
							SET @IntSuccess = -1 * ERROR_NUMBER()
							SET @VcError_Message = ERROR_MESSAGE()     
						END CATCH
					END
				END
				-----------------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END
	COMMIT TRAN T1
END TRY
BEGIN CATCH
	IF ERROR_NUMBER()=2601
	BEGIN
		SET @VcError_Message='Fund Family Already Exists. Please Try With a Different Name.'
	END
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRAN T1
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * ERROR_NUMBER()     
	SET @VcError_Message = ERROR_MESSAGE() 
END CATCH
/*

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateFundFamily]

@IntFundFamilyID		=NULL,
@BintClientDefinitionID	=1
,@VcFundFamilyCode		='testfund'
,@VcFundFamilyName		='testfund'
,@VcInvestmentRegion		='dfd'
,@BitIsActive			=1
,@DtInceptionDate		='10-10-2014'

,@BitOperFlag			=1,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message



*/
GO



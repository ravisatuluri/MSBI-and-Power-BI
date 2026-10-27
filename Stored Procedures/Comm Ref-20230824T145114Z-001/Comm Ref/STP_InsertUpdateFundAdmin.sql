--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateFundAdmin](
	@IntFundAdminID		INT				=NULL,
	@VcFundAdminCode	VARCHAR(50)		=NULL,
	@VcFundAdminName	VARCHAR(250)	=NULL,
	@VcTitle			VARCHAR(250)	=NULL,
	@VcSalutation		VARCHAR(250)	=NULL,
	@BitIsActive		BIT				=NULL,
	@VcAddress			VARCHAR(250)	=NULL,
	@VcCity				VARCHAR(50)		=NULL,
	@VcState			VARCHAR(100)	=NULL,
	@VcPostalCode		VARCHAR(20)		=NULL,
	@SinCountryID		SMALLINT		=NULL,
	@VcTelephoneNumber	VARCHAR(100)	=NULL,
	@VcFax				VARCHAR(100)	=NULL,
	@VcContactEmail		VARCHAR(100)	=NULL,
	@BitOperFlag		BIT				=NULL,
	@XmCustomColValues	XML				=NULL,
---------------------------------Common Columns---------------------------------
	@IntSuccess			INT				OUTPUT,
	@VcError_Message	VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)AS
DECLARE @IDENTITY INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRANSACTION T1
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF @BitOperFlag =0
		BEGIN
			IF LEN(@VcFundAdminCode)>0 AND LEN(@VcFundAdminName)>0
			BEGIN
				SET @IntSuccess=1
				INSERT INTO [cmrf].[TBL_FundAdmin](VcFundAdminCode,VcFundAdminName,VcTitle,VcSalutation,BitIsActive,[VcAddress],VcCity,[VcState],[VcPostalCode],SinCountryID,[VcTelephoneNumber],VcFax,[VcContactEmail],IntCreatedBy_IntBusinessEntityID,DtCreatedDate) 
				VALUES (@VcFundAdminCode,@VcFundAdminName,@VcTitle,@VcSalutation,@BitIsActive,@VcAddress,@VcCity,@VcState,@VcPostalCode,@SinCountryID,@VcTelephoneNumber,@VcFax,@VcContactEmail,@IntUserID,@DtActionDate)

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
								@VcReferenceMasterName			='Broker',
								@XmCustomColValues				=@XmCustomColValues,
								@BintLineReference				=@IntFundAdminID,
								@IntSuccess						=@internal_success			OUTPUT,
								@VcError_Message				=@internal_error_message	OUTPUT
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
			IF LEN(@VcFundAdminCode)>0 AND LEN(@VcFundAdminName)>0 AND @IntFundAdminID>0
			BEGIN
				SET @IntSuccess=1
				UPDATE [cmrf].[TBL_FundAdmin] SET 
					 VcFundAdminCode						=	@VcFundAdminCode		
					,VcFundAdminName						=	@VcFundAdminName		
					,[VcTitle]								=	@VcTitle				
					,[VcSalutation]							=	@VcSalutation			
					,[BitIsActive]							=	@BitIsActive			
					,[VcAddress]							=	@VcAddress			
					,[VcCity]								=	@VcCity				
					,[VcState]								=	@VcState				
					,[VcPostalCode]							=	@VcPostalCode			
					,SinCountryID							=	@SinCountryID			
					,[VcTelephoneNumber]					=	@VcTelephoneNumber	
					,[VcFax]								=	@VcFax				
					,[VcContactEmail]						=	@VcContactEmail		
					,[IntModifiedBy_IntBusinessEntityID]	=	@IntUserID
					,[DtModifiedDate]						=	@DtActionDate
				WHERE IntFundAdminID						=	@IntFundAdminID
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
								@VcReferenceMasterName			='Broker',
								@XmCustomColValues				=@XmCustomColValues,
								@BintLineReference				=@IntFundAdminID,
								@IntSuccess						=@internal_success			OUTPUT,
								@VcError_Message				=@internal_error_message	OUTPUT
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
	COMMIT TRANSACTION T1
END TRY
BEGIN CATCH
	IF ERROR_NUMBER()=2601
	BEGIN
		SET @VcError_Message='FundAdmin Code Already Exists. Please Try With a Different Code.'
	END
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRANSACTION T1
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * ERROR_NUMBER()  
	SET @VcError_Message = ERROR_MESSAGE()     
END CATCH
/*
---------------------Insert

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateFundAdmin]

@IntFundAdminID			='',
@VcFundAdminCode		='CITCO ',
@VcFundAdminName		='CITCO Corp',
@VcTitle				=NULL,
@VcSalutation			=NULL,
@BitIsActive			=1,
@VcAddress				=NULL,
@VcCity					=NULL,
@VcState				=NULL,
@VcPostalCode			=NULL,
@SinCountryID			=NULL,
@VcTelephoneNumber		=NULL,
@VcFax					=NULL,
@VcContactEmail			=NULL,
@BitOperFlag			=0,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message

select * from [cmrf].[TBL_FundAdmin]

---------------------Update

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateFundAdmin]

@IntFundAdminID			='2',
@VcFundAdminCode		='Globe Ops ',
@VcFundAdminName		='SS&C GlobeOp',
@VcTitle				=NULL,
@VcSalutation			=NULL,
@BitIsActive			=1,
@VcAddress				=NULL,
@VcCity					=NULL,
@VcState				=NULL,
@VcPostalCode			=NULL,
@SinCountryID			=NULL,
@VcTelephoneNumber		=NULL,
@VcFax					=NULL,
@VcContactEmail			=NULL,
@BitOperFlag			=1,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message

select * from [cmrf].[TBL_FundAdmin]

*/
--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateCustodian](
	@BintCustodianID		BIGINT			=NULL,
	@VcCustodianCode		VARCHAR(50)		=NULL,
	@VcCustodianName		VARCHAR(250)	=NULL,
	@VcTitle				VARCHAR(250)	=NULL,
	@VcSalutation			VARCHAR(250)	=NULL,
	@BitIsActive			BIT				=NULL,
	@VcCity					VARCHAR(50)		=NULL,
	@VcState				VARCHAR(100)	=NULL,
	@VcPostalCode			VARCHAR(20)		=NULL,
	@VcIntCountry			VARCHAR(100)	=NULL,
	@VcTelephoneNumber1		VARCHAR(100)	=NULL,
	@VcTelephoneNumber2		VARCHAR(100)	=NULL,
	@VcAddressLine1			VARCHAR(250)	=NULL,
	@VcAddressLine2			VARCHAR(250)	=NULL,
	@VcFax					VARCHAR(100)	=NULL,
	@VcContactEmail			VARCHAR(100)	=NULL,
	@BitOperFlag			BIT				=NULL,
	@XmCustomColValues		XML				=NULL,
---------------------------------Common Columns---------------------------------
	@IntSuccess				INT				OUTPUT,
	@VcError_Message		VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)AS
DECLARE @IDENTITY INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@PreviousTimeStamp  DATETIME,@IntUserID INT,@DtActionDate DATETIME
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
			IF LEN(@VcCustodianCode)>0 AND LEN(@VcCustodianName)>0
			BEGIN
				SET @IntSuccess=1
				--SELECT 
				INSERT INTO [cmrf].[TBL_Custodian]([VcCustodianCode],[VcCustodianName],VcTitle,VcSalutation,BitIsActive,VcCity,[VcState],[VcPostalCode],[VcCountry],VcFax,[VcContactEmail],
					[VcTelephoneNumber1],[VcTelephoneNumber2],VcAddressLine1,VcAddressLine2,IntCreatedBy_IntBusinessEntityID,DtCreatedDate) 
				VALUES (@VcCustodianCode,@VcCustodianName,@VcTitle,@VcSalutation,@BitIsActive,@VcCity,@VcState,@VcPostalCode,@VcIntCountry,@VcFax,@VcContactEmail,
					@VcTelephoneNumber1,@VcTelephoneNumber2,@VcAddressLine1,@VcAddressLine2,@IntUserID,@DtActionDate)
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
								@VcReferenceMasterName			='Custodian',
								@XmCustomColValues				=@XmCustomColValues,
								@BintLineReference				=@BintCustodianID,
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
			IF LEN(@VcCustodianCode)>0 AND LEN(@VcCustodianName)>0
			BEGIN
				UPDATE [cmrf].[TBL_Custodian]
				SET 
					 [VcCustodianCode]						=	@VcCustodianCode		
					,[VcCustodianName]						=	@VcCustodianName		
					,[VcTitle]								=	@VcTitle				
					,[VcSalutation]							=	@VcSalutation			
					,[BitIsActive]							=	@BitIsActive			
					,[VcCity]								=	@VcCity				
					,[VcState]								=	@VcState				
					,[VcPostalCode]							=	@VcPostalCode			
					,[VcCountry]							=	@VcIntCountry			
					,[VcTelephoneNumber1]					=	@VcTelephoneNumber1	
					,[VcTelephoneNumber2]					=	@VcTelephoneNumber2
					,[VcAddressLine1]						=   @VcAddressLine1
					,[VcAddressLine2]						=   @VcAddressLine2
					,[VcFax]								=	@VcFax				
					,[VcContactEmail]						=	@VcContactEmail	
					,[IntModifiedBy_IntBusinessEntityID]	=	@IntUserID
					,[DtModifiedDate]						=	@DtActionDate
				WHERE [IntCustodianID]						=	@BintCustodianID
				SET @IntSuccess=1
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
								@VcReferenceMasterName			='Custodian',
								@XmCustomColValues				=@XmCustomColValues,
								@BintLineReference				=@BintCustodianID,
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
		SET @VcError_Message='Custodian Already Exists. Please Try With a Different Name.'
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

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000),@success_message  VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateCustodian]

@BintCustodianID		='',
@VcCustodianCode		='RDL',
@VcCustodianName		='REFORM',
@VcTitle				='',
@VcSalutation			=NULL,
@BitIsActive			=1,
@VcAddressLine1			='NEW YORK',
@VcCity					='NEW YORK',
@VcState				='NEW YORK',
@VcPostalCode			='123456',
@VcIntCountry			='USA',
@VcTelephoneNumber1		='0123456789',
@VcTelephoneNumber2		='01343535',
@VcFax					=NULL,
@VcContactEmail			='ABC@DEF.COM',
@BitOperFlag			=0,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT


SELECT @IntSuccess,@VcError_Message



*/
GO



--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateCustodianAccount](
	@BintClientDefinitionID		BIGINT			=NULL,
	@BintCustodianID			BIGINT			=NULL,
	@CustodianAccountID			BIGINT			=NULL,
	@VcCustodianAccountCode		VARCHAR(50)		=NULL,
	@VcCustodianAccountName		VARCHAR(250)	=NULL,
	@VcTitle					VARCHAR(250)	=NULL,
	@VcSalutation				VARCHAR(250)	=NULL,
	@BitIsActive				BIT				=NULL,
	@VcAddress					VARCHAR(250)	=NULL,
	@VcCity						VARCHAR(50)		=NULL,
	@VcState					VARCHAR(100)	=NULL,
	@VcPostalCode				VARCHAR(20)		=NULL,
	@IntCountry					VARCHAR(100)	=NULL,
	@TelephoneNumber			VARCHAR(100)	=NULL,
	@VcFax						VARCHAR(100)	=NULL,
	@VcContactEmail				VARCHAR(100)	=NULL,
	@TinOperFlag				TINYINT			=NULL,
	@VcAccountType				VARCHAR(50)		=NULL,
	@XmCustomColValues			XML				=NULL,
	@LinkedFund					XML				=NULL,
---------------------------------Common Columns---------------------------------
	@IntSuccess					INT				OUTPUT,
	@VcError_Message			VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)AS
DECLARE @IDENTITY INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@IntUserID INT,@DtActionDate DATETIME,@NEW_INSERTED_CustodianAccountID INT
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRANSACTION T1
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF @TinOperFlag =0
		BEGIN
			IF LEN(@VcCustodianAccountCode)>0 AND LEN(@VcCustodianAccountName)>0
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM [cmrf].[TBL_Custodian_Account] WITH(NOLOCK) WHERE [VcCustodianAccountCode]=@VcCustodianAccountCode AND [VcCustodianAccountName]=@VcCustodianAccountName  )
				BEGIN
					SET @IntSuccess=1
					INSERT INTO [cmrf].[TBL_Custodian_Account] ([VcCustodianAccountCode],[VcCustodianAccountName],[IntCustodianID],VcTitle,VcSalutation,BitIsActive,[VcAddress],VcCity,[VcState],[VcPostalCode],[VcCountry],[VcTelephoneNumber],VcFax,[VcContactEmail],IntClientDefinitionID,VcAccountType,IntCreatedBy_IntBusinessEntityID,DtCreatedDate) 
					VALUES (@VcCustodianAccountCode,@VcCustodianAccountName,@BintCustodianID,@VcTitle,@VcSalutation,@BitIsActive,@VcAddress,@VcCity,@VcState,@VcPostalCode,@IntCountry,@TelephoneNumber,@VcFax,@VcContactEmail,@BintClientDefinitionID,@VcAccountType,@IntUserID,@DtActionDate)
					SET @NEW_INSERTED_CustodianAccountID=SCOPE_IDENTITY();
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
									@VcReferenceMasterName		='CustodianAccount',
									@XmCustomColValues			=@XmCustomColValues,
									@BintLineReference			=@CustodianAccountID,
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
					SET @IntMsgID =100020
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'Already Record EXISTS')
				END
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
			IF LEN(@VcCustodianAccountCode)>0 AND LEN(@VcCustodianAccountName)>0
			BEGIN
				SET @IntSuccess=1
				UPDATE [cmrf].[TBL_Custodian_Account]
				SET 
					[VcCustodianAccountCode]				=@VcCustodianAccountCode		
				,[VcCustodianAccountName]				=@VcCustodianAccountName
				,IntClientDefinitionID					=@BintClientDefinitionID
				,[IntCustodianID]						=@BintCustodianID	
				,VcTitle								=@VcTitle				
				,VcSalutation							=@VcSalutation			
				,BitIsActive							=@BitIsActive			
				,[VcAddress]							=@VcAddress			
				,VcCity									=@VcCity				
				,[VcState]								=@VcState				
				,[VcPostalCode]							=@VcPostalCode			
				,[VcCountry]							=@IntCountry			
				,[VcTelephoneNumber]					=@TelephoneNumber	
				,VcFax									=@VcFax				
				,[VcContactEmail]						=@VcContactEmail
				,[VcAccountType]						=@VcAccountType
				,[IntModifiedBy_IntBusinessEntityID]	=@IntUserID
				,[DtModifiedDate]						=@DtActionDate
				WHERE [IntCustodianAccountID]			=@CustodianAccountID
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
								@VcReferenceMasterName			='CustodianAccount',
								@XmCustomColValues				=@XmCustomColValues,
								@BintLineReference				=@CustodianAccountID,
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

		DECLARE @TB_LinkedFund TABLE (SRNO SMALLINT IDENTITY(1,1) ,flag VARCHAR(1),fundID INT,IntCustodianAccountPortfolioLinkID INT)
		INSERT INTO @TB_LinkedFund (flag,fundID,IntCustodianAccountPortfolioLinkID)

		SELECT
			ISNULL(LTRIM(RTRIM(tab.col.value('@flag','VARCHAR(50)'))),'') flag,
			ISNULL(LTRIM(RTRIM(tab.col.value('@fundID','INT'))),0) fundID,
			ISNULL(LTRIM(RTRIM(tab.col.value('@IntCustodianAccountPortfolioLinkID','INT'))),0) IntCustodianAccountPortfolioLinkID
		FROM @LinkedFund.nodes('LinkedFund/row') tab(col)

		--SELECT * FROM [cmrf].[TBL_CustodianAccountPortfolioLink]

		INSERT INTO [cmrf].[TBL_CustodianAccountPortfolioLink] (IntPortfolioID,IntCustodianAccountID,IntCreatedBy_IntBusinessEntityID,DtCreatedDate)
		SELECT fundID,(CASE WHEN @TinOperFlag=0  THEN @NEW_INSERTED_CustodianAccountID ELSE @CustodianAccountID END) CustodianAccountID,@IntUserID,@DtActionDate
		FROM @TB_LinkedFund WHERE flag='A'

		UPDATE [cmrf].[TBL_CustodianAccountPortfolioLink]
		SET  [IntPortfolioID]						=L.fundID
			,[IntModifiedBy_IntBusinessEntityID]	=@IntUserID
			,[DtModifiedDate]						=@DtActionDate
		FROM @TB_LinkedFund L, [cmrf].[TBL_CustodianAccountPortfolioLink] CL 
		WHERE L.flag='E'
		AND L.IntCustodianAccountPortfolioLinkID=CL.IntCustodianAccountPortfolioLinkID
	
		DELETE [cmrf].[TBL_CustodianAccountPortfolioLink] 
		FROM @TB_LinkedFund L, [cmrf].[TBL_CustodianAccountPortfolioLink] CL WITH(NOLOCK)
		WHERE L.flag='D'
		AND L.IntCustodianAccountPortfolioLinkID=CL.IntCustodianAccountPortfolioLinkID
	
		IF @TinOperFlag=2
		BEGIN
			DECLARE @Del_LinkedFund TABLE (flag VARCHAR(1),IntCustodianAccountPortfolioLinkID INT)
			INSERT INTO @Del_LinkedFund (flag,IntCustodianAccountPortfolioLinkID)

			SELECT
				ISNULL(LTRIM(RTRIM(tab.col.value('@flag','VARCHAR(50)'))),'') flag,
				ISNULL(LTRIM(RTRIM(tab.col.value('@IntCustodianAccountPortfolioLinkID','INT'))),0) IntCustodianAccountPortfolioLinkID
			FROM @LinkedFund.nodes('LinkedFund/row') tab(col)

			IF EXISTS(SELECT 1 FROM @Del_LinkedFund WHERE flag='D')
			BEGIN
				DELETE [cmrf].[TBL_CustodianAccountPortfolioLink] 
				FROM @TB_LinkedFund L, [cmrf].[TBL_CustodianAccountPortfolioLink] CL WITH(NOLOCK)
				WHERE L.flag='D'
				AND L.IntCustodianAccountPortfolioLinkID=CL.IntCustodianAccountPortfolioLinkID
				SET @IntSuccess=1
				SET @VcError_Message = 'Successfully Deleted'
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
		SET @VcError_Message='Custodian Account Already Exists. Please Try With a Different Portfolio.'
	END
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRANSACTION T1
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * ERROR_NUMBER()      
END CATCH
/*


DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateCustodianAccount]
@BintClientDefinitionID	=39,
@BintCustodianID		=1,
@VcCustodianAccountCode	='ICICI',
@VcCustodianAccountName	='ICICI',
@VcTitle				='',
@VcSalutation			=NULL,
@BitIsActive			=1,
@VcAddress				='NEW YORK',
@VcCity					='NEW YORK',
@VcState				='NEW YORK',
@VcPostalCode			='123456',
@IntCountry				='USA',
@TelephoneNumber		='0123456789',
@VcFax					=NULL,
@VcContactEmail			='ABC@DEF.COM',
@VcAccountType			='Trading',
@BitOperFlag			=1,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message



------Delete PortfolioLink

declare @LinkedFund	xml=
'<LinkedFund>
<row flag="D" fundID="" IntCustodianAccountPortfolioLinkID="442" />
</LinkedFund>
'

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdateCustodianAccount]
@BintClientDefinitionID	='',
@BintCustodianID		='',
@CustodianAccountID		='',
@VcCustodianAccountCode	='',
@VcCustodianAccountName	='',
@VcTitle				='',
@VcSalutation			='',
@BitIsActive			='',
@VcAddress				='',
@VcCity					='',
@VcState				='',
@VcPostalCode			='',
@IntCountry				='',
@TelephoneNumber		='',
@VcFax					='',
@VcContactEmail			='',
@VcAccountType			='',
@TinOperFlag			=2,
@LinkedFund				=@LinkedFund,
--------------------
@IntSuccess				=@IntSuccess OUTPUT,
@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message



select * from [cmrf].[TBL_CustodianAccountPortfolioLink]
*/

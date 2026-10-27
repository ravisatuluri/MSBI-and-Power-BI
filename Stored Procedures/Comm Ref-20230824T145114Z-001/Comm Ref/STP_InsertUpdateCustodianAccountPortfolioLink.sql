--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdateCustodianAccountPortfolioLink](
		 @IntCustodianAccountPortfolioLinkID	INT		=NULL
		,@IntPortfolioID						INT		=NULL
		,@IntCustodianAccountID					INT		=NULL
    	,@TinOperFlag							TINYINT	=NULL	-- @TinOperFlag value 0 for INSERT, 1 for update
---------------------------------Common Columns---------------------------------
		,@IntSuccess							INT				OUTPUT
		,@VcError_Message						VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)
AS
DECLARE @identity INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRAN T
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF @TinOperFlag=0
		BEGIN 
			IF @IntPortfolioID>0 AND @IntCustodianAccountID>0
			BEGIN    
				INSERT INTO [cmrf].[TBL_CustodianAccountPortfolioLink] ([IntPortfolioID],[IntCustodianAccountID],IntCreatedBy_IntBusinessEntityID,DtCreatedDate)
				VALUES (@IntPortfolioID,@IntCustodianAccountID,@IntUserID,@DtActionDate)
				SET @IntSuccess=1
				SET @VcError_Message='Successfully Added'
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END	
		END

		IF @TinOperFlag=1
		BEGIN
			IF @IntCustodianAccountPortfolioLinkID>0 AND @IntPortfolioID>0 AND @IntCustodianAccountID>0
			BEGIN
				UPDATE [cmrf].[TBL_CustodianAccountPortfolioLink] SET
					 [IntPortfolioID]						= @IntPortfolioID
					,[IntCustodianAccountID]				= @IntCustodianAccountID
					,[IntModifiedBy_IntBusinessEntityID]	=@IntUserID
					,[DtModifiedDate]						=@DtActionDate
				WHERE [IntCustodianAccountPortfolioLinkID]	= @IntCustodianAccountPortfolioLinkID
				IF @@ROWCOUNT=1
				BEGIN
					SET @IntSuccess=1
					SET @VcError_Message='Successfully Updated'
				END
				ELSE
				BEGIN
					SET @IntSuccess=-1
					SET @IntMsgID=100002
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
				END
			END
		END

		IF @TinOperFlag=2
		BEGIN
			IF @IntCustodianAccountPortfolioLinkID>0
			BEGIN
				DELETE [cmrf].[TBL_CustodianAccountPortfolioLink]
				WHERE [IntCustodianAccountPortfolioLinkID]	= @IntCustodianAccountPortfolioLinkID
				IF @@ROWCOUNT=1
				BEGIN
					SET @IntSuccess=1
					SET @VcError_Message='Successfully Deleted'
				END
				ELSE
				BEGIN
					SET @IntSuccess=-1
					SET @IntMsgID=100002
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
				END
			END
		END
	COMMIT TRAN T
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRAN T
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * Error_Number()
	SET @VcError_Message = ERROR_MESSAGE()   
	IF Error_Number()=2601
	BEGIN
		SET @IntMsgID =200016
		SET @IntSuccess=-1
		SET @VcError_Message = ISNULL(err.FnGetErrorMessage(200016),'')
	END   
END CATCH

/*
------------------------TEST CASE 1: TO INSERT(OperFlag=0)-------------------------

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000)

EXEC [cmrf].[STP_InsertUpdateCustodianAccountPortfolioLink]

 @IntCustodianAccountPortfolioLinkID	=''					--identity column
,@IntPortfolioID						=1
,@IntCustodianAccountID					=1
,@TinOperFlag							=0					-- @TinOperFlag value 0 for INSERT, 1 for update, 2 FOR DELETE
---------
,@IntSuccess							=@IntSuccess OUTPUT
,@VcError_Message						=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

-------------TO VIEW THE DATA IN TABLE------------

SELECT * from [cmrf].[TBL_CustodianAccountPortfolioLink] ORDER BY 1
SELECT * from [cmrf].[TBL_Portfolio] ORDER BY 1
SELECT * from [cmrf].[TBL_Custodian_Account] ORDER BY 1


------------------------TEST CASE 2: TO UPDATE(OperFlag=1)-------------------------

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000)

EXEC [cmrf].[STP_InsertUpdateCustodianAccountPortfolioLink]

 @IntCustodianAccountPortfolioLinkID	=1					--identity column
,@IntPortfolioID						=2
,@IntCustodianAccountID					=1
,@TinOperFlag							=1					-- @TinOperFlag value 0 for INSERT, 1 for update, 2 FOR DELETE
---------
,@IntSuccess							=@IntSuccess OUTPUT
,@VcError_Message						=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

-------------TO VIEW THE DATA IN TABLE------------

SELECT * from [cmrf].[TBL_CustodianAccountPortfolioLink] ORDER BY 1
SELECT * from [cmrf].[TBL_Portfolio] ORDER BY 1
SELECT * from [cmrf].[TBL_Custodian_Account] ORDER BY 1

------------------------TEST CASE 3: TO DELETE(OperFlag=2)-------------------------

DECLARE @IntSuccess INT, @VcError_Message VARCHAR(1000)

EXEC [cmrf].[STP_InsertUpdateCustodianAccountPortfolioLink]

 @IntCustodianAccountPortfolioLinkID	=1					--identity column
,@IntPortfolioID						=''
,@IntCustodianAccountID					=''
,@TinOperFlag							=2					-- @TinOperFlag value 0 for INSERT, 1 for update, 2 FOR DELETE
---------
,@IntSuccess							=@IntSuccess OUTPUT
,@VcError_Message						=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

-------------TO VIEW THE DATA IN TABLE------------

SELECT * from [cmrf].[TBL_CustodianAccountPortfolioLink] ORDER BY 1
SELECT * from [cmrf].[TBL_Portfolio] ORDER BY 1
SELECT * from [cmrf].[TBL_Custodian_Account] ORDER BY 1
*/
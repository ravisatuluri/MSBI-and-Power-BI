USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_Update_PushtoGeneva_Details]    Script Date: 30-05-2016 14:10:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [VUWireTransfer]
--GO

ALTER PROCEDURE [wr].[STP_Update_PushtoGeneva_Details](
      @xmPushDetails         XML,
      --@VcGenevaPushStatus VARCHAR(100) = NULL,
      --@VcGenevaMessage    VARCHAR(1000) = NULL,
      --@DtGenevaUpdateDate DATETIME,
      @IntModifiedBy      INT = NULL,
      ---------------------------------Common Columns--------------------------------
      @IntSuccess         INT OUTPUT,
      @VcError_Message    VARCHAR(1000) OUTPUT
---------------------------------Common Columns---------------------------------
)
AS
     DECLARE @IntUserID    INT,
             @DtActionDate DATETIME;
    BEGIN TRY
        IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
            BEGIN
                SELECT @IntUserID = IntUserID,
                       @DtActionDate = DtActionDate
                FROM #Sessiondata;
            END;
        BEGIN TRANSACTION T1;
        SET NOCOUNT ON;
		DECLARE @loopcounter INT;
		DECLARE @GenevaDetails TABLE(IntSrNo INT IDENTITY(1,1),WireId BIGINT,GenevaPushStatus VARCHAR(100), GenevaMessage VARCHAR(1000) )
	INSERT INTO @GenevaDetails (WireId,GenevaPushStatus,GenevaMessage)
	SELECT 
		LTRIM(RTRIM(tab.col.value('@WireId', 'VARCHAR(50)'))) WireId
	   ,LTRIM(RTRIM(tab.col.value('@GenevaPushStatus', 'VARCHAR(100)'))) GenevaPushStatus
	   ,LTRIM(RTRIM(tab.col.value('@GenevaMessage', 'VARCHAR(1000)'))) GenevaMessage
		FROM @xmPushDetails.nodes('PushWiresResponse//row') tab(col) ;


		SET @loopcounter=1
		Declare @BintWireID BIGINT
		WHILE EXISTS(SELECT WireId from @GenevaDetails where IntSrNo=@loopcounter)
		BEGIN
			SET @BintWireID=(SELECT WireId FROM @GenevaDetails WHERE IntSrNo=@loopcounter)
			 UPDATE wr.TBL_WireTransfer WITH(ROWLOCK)
          SET [VcGenevaPushStatus] = (SELECT GenevaPushStatus FROM @GenevaDetails WHERE IntSrNo=@loopcounter) ,
              [VcGenevaMessage] =(SELECT GenevaMessage FROM @GenevaDetails WHERE IntSrNo=@loopcounter) ,
              [DtGenevaUpdateDate] =GETDATE() ,
              [BtIsPushSuccess] = CASE
                                      WHEN (SELECT GenevaPushStatus FROM @GenevaDetails WHERE IntSrNo=@loopcounter) = 'Success'
                                      THEN 1
                                      ELSE 0
                                  END,
              [IntModifiedBy_IntBusinessEntityID] = @IntModifiedBy,
              [DtModifiedDate] = GETDATE(),
              [DtLastUpdatedTime] = GETDATE()
        WHERE BintWireID = @BintWireID
        IF @@ROWCOUNT = 1
            BEGIN
                --UPDATE the reason
                DECLARE @actiondate DATETIME;
                SET @actiondate = GETDATE();
                EXEC [wr].[STP_InsertUpdate_Reasons]
                     @IntReasonID = 0,
                     @VcModuleCode = 'WIRE',
                     @VcScreenCode = 'WIRETRANSFER',
                     @IntReferenceID = @BintWireID,
                     @VcActionCode = 'PUSHTOGENEVA',
                     @IntCreatedBy = @IntModifiedBy,
                     @IntModifiedBy = @IntModifiedBy,
                     @DtLastUpdatedTime = NULL,
                     @VcReason = NULL,
                     @DtActionDate = @actiondate,
                     @VcOperFlag = 0,
                     @IntSuccess = @IntSuccess OUTPUT,
                     @VcMessage = @VcError_Message OUTPUT;
                SET @IntSuccess = 1;
                SET @VcError_Message = 'Successfully Updated';
            END;

			 SET @loopcounter=@loopcounter+1;
		END
       
        COMMIT TRANSACTION T1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION T1;
            END;
        EXEC [err].[STP_LogError];
        SET @IntSuccess = -1 * ERROR_NUMBER();
        SET @VcError_Message = ERROR_MESSAGE();
    END CATCH;        
 

/*
DECLARE @RC int
DECLARE @xmPushDetails xml
DECLARE @IntModifiedBy int
DECLARE @IntSuccess int
DECLARE @VcError_Message varchar(1000)

SET @xmPushDetails=
'<PushWiresResponse>
		<row WireId="163" GenevaPushStatus="Success" GenevaMessage="test1" /> 
		<row WireId="164" GenevaPushStatus="Failure" GenevaMessage="test2" /> 
		<row WireId="165" GenevaPushStatus="Success" GenevaMessage="test3" /> 
	</PushWiresResponse>'
SET @IntModifiedBy=728

EXECUTE @RC = [wr].[STP_Update_PushtoGeneva_Details] 
   @xmPushDetails
  ,@IntModifiedBy
  ,@IntSuccess OUTPUT
  ,@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message



----------------------TO VIEW DATA IN TABLES---------------------------

SELECT * FROM [WR].[TBL_ProcessWire]
SELECT * FROM [wr].[TBL_WireTransfer]

*/
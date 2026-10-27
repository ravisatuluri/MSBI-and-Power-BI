USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_InsertUpdate_WireAttachment]    Script Date: 30-05-2016 14:06:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [VUWireTransfer]
--GO

ALTER PROC [wr].[STP_InsertUpdate_WireAttachment](
      @IntWireAttachmentID INT,
      @BintWrID            BIGINT = NULL,
      @VcFileName          VARCHAR(100) = NULL,
      @VcPath              VARCHAR(100) = NULL,
      @IsActive            BIT = NULL,
      @IntCreatedBy        INT = NULL,
      @IntModifiedBy       INT = NULL,
      @DtLastUpdatedTime   DATETIME = NULL,
      @VcOperFlag          VARCHAR(5) = NULL, -- @VcOperFlag value 0 for INSERT, 1 for UPDATE
      ---------------------------------Common Columns--------------------------------					
      @IntSuccess          INT OUTPUT,
      @VcMessage           VARCHAR(1000) OUTPUT
---------------------------------Common Columns---------------------------------
)
AS
     DECLARE @IntIdentity              INT = 0,
             @IntMsgID                 INT,
             @IntInternal_Success      INT,
             @VcInternal_Error_Message VARCHAR(1000);
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
        SET @IntSuccess = 0;
        IF @VcOperFlag = 0
            BEGIN
                IF( LEN(@BintWrID) <> 0 )
                    BEGIN
                        INSERT INTO [wr].[TBL_WireAttachment]
                               ( [BintWrID],
                                 [VcFileName],
                                 [VcPath],
                                 [BitIsActive],
                                 [IntCreatedBy_IntBusinessEntityID],
                                 [DtCreatedDate],
                                 [DtLastUpdatedTime]
                               )
                        VALUES( @BintWrID, @VcFileName, @VcPath, @IsActive, @IntCreatedBy, GETDATE(), GETDATE());
                        SET @IntSuccess = 1;
                        SET @VcMessage = 'Successfully Added';
                    END;
                ELSE
                    BEGIN
                        SET @IntSuccess = -1;
                        SET @IntMsgID = 100002;
                        SET @VcMessage = ISNULL(err.FnGetErrorMessage( @IntMsgID ), '');
                    END;
            END;
        ELSE
        IF @VcOperFlag = 1
            BEGIN
                IF( LEN(@IntWireAttachmentID) <> 0
                AND LEN(@BintWrID) <> 0
                  )
                    BEGIN
                        UPDATE [wr].[TBL_WireAttachment] WITH(ROWLOCK)
                          SET [BintWrID] = @BintWrID,
                              [VcFileName] = @VcFileName,
                              [VcPath] = @VcPath,
                              [BitIsActive] = @IsActive,
                              [IntModifiedBy_IntBusinessEntityID] = @IntModifiedBy,
                              [DtModifiedDate] = GETDATE(),
                              [DtLastUpdatedTime] = GETDATE()
                        WHERE [BintWireAttachmentID] = @IntWireAttachmentID;
                        IF @@ROWCOUNT = 1
                            BEGIN
                                SET @IntSuccess = 1;
                                SET @VcMessage = 'Successfully Updated';
                            END;
                    END;
                ELSE
                    BEGIN
                        SET @IntSuccess = -1;
                        SET @IntMsgID = 100002;
                        SET @VcMessage = ISNULL(err.FnGetErrorMessage( @IntMsgID ), '');
                    END;
            END;
        IF @VcOperFlag = 2
            BEGIN
                UPDATE [wr].[TBL_WireAttachment] WITH(ROWLOCK)
                  SET BitIsActive = 0,
                      [IntModifiedBy_IntBusinessEntityID] = @IntModifiedBy,
                      DtModifiedDate = GETDATE()
                WHERE [BintWireAttachmentID] = @IntWireAttachmentID;
                IF @@ROWCOUNT = 1
                    BEGIN
                        SET @IntSuccess = 1;
                        SET @VcMessage = 'Successfully Deleted';
                    END;
                ELSE
                    BEGIN
                        SET @IntSuccess = -1;
                        SET @IntMsgID = 100002;
                        SET @VcMessage = ISNULL(err.FnGetErrorMessage( @IntMsgID ), '');
                    END;
            END;
        COMMIT TRANSACTION T1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION T1;
            END;
        EXEC [err].[STP_LogError];
        SET @IntSuccess = -1 * ERROR_NUMBER();
        SET @VcMessage = ERROR_MESSAGE();
    END CATCH;

/*
------------------CASE 1: TO INSERT---------------------

DECLARE @IntSuccess INT, @VcMessage VARCHAR(1000)

EXEC [wr].[STP_InsertUpdate_WireAttachment]
 @IntWireAttachmentID	=''
,@BintWrID				=1
,@VcFileName			='testing'
,@VcPath				='vbriubvgribvr'
,@IsActive				=1
,@IntCreatedBy			=1
,@IntModifiedBy			=''
,@DtLastUpdatedTime		=''
,@VcOperFlag			=0
,@IntSuccess			=@IntSuccess output
,@VcMessage				=@VcMessage  output

SELECT @IntSuccess, @VcMessage 

------------------CASE 2: TO UPDATE---------------------

DECLARE @IntSuccess INT, @VcMessage VARCHAR(1000)

EXEC [wr].[STP_InsertUpdate_WireAttachment]
 @IntWireAttachmentID	=11
,@BintWrID				=''
,@VcFileName			=''
,@VcPath				=''
,@IsActive			=1
,@IntCreatedBy			=''
,@IntModifiedBy		=2
,@DtLastUpdatedTime		='2015-03-10 17:42:12.377'
,@VcOperFlag			=1
,@IntSuccess			=@IntSuccess output
,@VcMessage				=@VcMessage  output

SELECT @IntSuccess, @VcMessage

------------------CASE 3: TO DELETE---------------------

DECLARE @IntSuccess INT, @VcMessage VARCHAR(1000)

EXEC [wr].[STP_InsertUpdate_WireAttachment]
 @IntWireAttachmentID	=11
,@BintWrID				=''
,@VcFileName			=''
,@VcPath				=''
,@IsActive			=''
,@IntCreatedBy			=''
,@IntModifiedBy		=''
,@DtLastUpdatedTime		=''
,@VcOperFlag			=2
,@IntSuccess			=@IntSuccess output
,@VcMessage				=@VcMessage  output

SELECT @IntSuccess, @VcMessage 

------------TO VIEW THE DATA IN TABLE----------

SELECT *  FROM [wr].[TBL_WireAttachment]

*/
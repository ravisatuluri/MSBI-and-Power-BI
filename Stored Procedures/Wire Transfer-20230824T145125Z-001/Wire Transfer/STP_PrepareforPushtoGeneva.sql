USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_PrepareforPushtoGeneva]    Script Date: 30-05-2016 14:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [VUWireTransfer]
--GO

ALTER PROCEDURE [wr].[STP_PrepareforPushtoGeneva](
      @VcWrIDs         VARCHAR(300),
      ---------------------------------Common Columns--------------------------------
      @IntSuccess      INT OUTPUT,
      @VcError_Message VARCHAR(1000) OUTPUT
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
        SELECT wt.BintWireID AS [IntWrID],
               wt.VcWireStatus AS [VcWireStatus],
               p.IntPortfolioID,
			   p.[SinGenevaID],
               'Transfer' AS [RecordClass],
                             CASE wt.VcWireStatus
                                 WHEN 'Deleted'
                                 THEN 'Delete'
                                 ELSE 'InsertUpdate'
                             END AS [RecordAction],
               '1' AS [RecordRows],
               p.VcPortfolioShortCode AS [Portfolio],
               --dc.VcCustodianAccountCode AS [LocationAccount],
			   CASE WHEN WT.VcActionType = 'Deposit'  THEN cc.VcCustodianAccountCode 
					WHEN WT.VcActionType = 'Withdrawal'  THEN dc.VcCustodianAccountCode 
			   END [LocationAccount],
               'CURRENCY' AS [Strategy],
               c.VcCurrencyCode AS [Investment],
               CONVERT( DATE, wt.DtValueDate) AS [EventDate],
               CONVERT( DATE, wt.DtValueDate) AS [SettleDate],
               CONVERT( DATE, wt.DtValueDate) AS [ActualSettleDate],
               wt.VcComment AS [Comments],
               '' AS [UserDefDate1],
               '' AS [UserDefDate2],
               RTRIM(LTRIM(CONVERT(   VARCHAR(5), wt.BintWireID))) + '_' + p.VcPortfolioShortCode + '_' + c.VcCurrencyCode + '_5678' AS [UserTranId1],
               '' AS [UserTranId2],
               '' AS [InvestmentClosingRule],
               '' AS [SecondaryInvestmentClosingRule],
               wt.DecAmount AS [Quantity],
               '' AS [N/A19],
               '1' AS [Price],
               '' AS [N/A21],
               '' AS [N/A22],
               '' AS [N/A23],
               '' AS [N/A24],
               '' AS [N/A25],
               '' AS [N/A26],
               '' AS [N/A27],
               '' AS [PendingIncomeFlag],
               '' AS [N/A29],
               '' AS [PriceFXDenomination],
               '' AS [N/A31],
               '' AS [CounterTDateFx],
               '' AS [N/A33],
               '' AS [AccruedInterest],
               '' AS [N/A35],
               '' AS [N/A36],
               '' AS [N/A37],
               '' AS [LotId],
               '' AS [ReliefQuantity],
               '' AS [ContractExpirationDate],
               '' AS [N/A41],
               '' AS [Original Face],
               '' AS [N/A43],
               '' AS [N/A44],
               '' AS [N/A45],
               '' AS [N/A46],
               '' AS [N/A47],
               '' AS [OldFundStructure],
               '' AS [TransferLeg],
               '' AS [N/A50],
               '' AS [N/A51],
               'At Price' AS [TransferType],
               '' AS [N/A53],
               '' AS [N/A54],
               '' AS [N/A55],
               '' AS [N/A56],
               '' AS [N/A57],
               '' AS [N/A58],
               '' AS [N/A59],
               '' AS [N/A60],
               '' AS [N/A61],
               '' AS [N/A62],
               '' AS [N/A63],
               '' AS [N/A64],
               '' AS [N/A65],
               '' AS [N/A66],
               '' AS [N/A67],
               '' AS [N/A68],
               '' AS [N/A69],
               '' AS [N/A70],
               '' AS [N/A71],
               '' AS [N/A72],
               '' AS [N/A73],
               '' AS [N/A74],
               '' AS [N/A75],
               --cc.VcCustodianAccountCode AS [NewLocationAccount],
			   CASE WHEN WT.VcActionType = 'Deposit'  THEN dc.VcCustodianAccountCode 
					WHEN WT.VcActionType = 'Withdrawal'  THEN cc.VcCustodianAccountCode 
			   END [NewLocationAccount],
               'CURRENCY' AS [NewStrategy],
               '' AS [N/A78],
               '' AS [N/A79],
               '' AS [N/A80],
               '' AS [N/A81],
               '' AS [N/A82],
               '' AS [N/A83],
               '' AS [N/A84],
               '' AS [NewPriority],
               '' AS [EventDesc],
               '' AS [N/A87],
               '' AS [N/A88],
               '&lt;CALC&gt;' AS [FundStructure],
               '' AS [UserDefField1],
               '' AS [N/A91],
               '' AS [N/A92],
               '' AS [N/A93],
               '' AS [N/A94],
               '' AS [N/A95],
               '' AS [N/A96],
               '' AS [N/A97],
               '' AS [N/A98],
               '' AS [N/A99],
               '' AS [N/A100],
               '' AS [N/A101],
               '' AS [N/A102],
               '' AS [N/A103],
               '' AS [AccountingView],
               '' AS [N/A105],
               '' AS [N/A106],
               '' AS [N/A107],
               '' AS [N/A108],
               '' AS [N/A109],
               '' AS [N/A110],
               '' AS [N/A111],
               '' AS [N/A112],
               '' AS [N/A113],
               '' AS [N/A114],
               '' AS [N/A115],
               '' AS [N/A116],
               '' AS [N/A117],
               '' AS [N/A118],
               '' AS [N/A119],
               '' AS [N/A120],
               '' AS [N/A121],
               '' AS [N/A122],
               '' AS [N/A123],
               '' AS [TradeSource],
               '' AS [N/A125],
               '' AS [UnsupervisedFlag],
               '' AS [N/A127],
               '' AS [N/A128],
               '' AS [N/A129],
               '' AS [N/A130],
               '' AS [N/A131],
               '' AS [N/A132],
               '' AS [N/A133],
               '' AS [UDFLabel],
               '' AS [UDFData],
               '' AS [N/A136],
               '' AS [N/A137],
               '' AS [N/A138],
               RTRIM(LTRIM(CONVERT(   VARCHAR(5), wt.BintWireID))) + '_' + p.VcPortfolioShortCode + '_' + c.VcCurrencyCode + '_5678' AS [UserTranId1_2],
               wt.BintWireID AS [ExternalSystemReferenceID],
               wt.DtLastUpdatedTime as DtLastUpdatedOn
        FROM wr.TBL_WireTransfer wt WITH ( NOLOCK )
             INNER JOIN cmrf.TBL_Portfolio p WITH ( NOLOCK ) ON wt.IntPortfolioid = p.IntPortfolioID
             INNER JOIN cmrf.TBL_Currency c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
             INNER JOIN cmrf.TBL_Custodian_Account dc WITH ( NOLOCK ) ON wt.IntDebitCustodianAccount = dc.IntCustodianAccountID
             INNER JOIN cmrf.TBL_Custodian_Account cc WITH ( NOLOCK ) ON wt.IntCreditCustodianAccount = cc.IntCustodianAccountID
        WHERE wt.BintWireID IN( 
                                SELECT *
                                FROM wr.FN_Csv_to_Table( @VcWrIDs ))
          AND ISNULL(BtIsPushSuccess, 0) = 0;
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

DECLARE @RC INT, @IntSuccess INT, @VcError_Message VARCHAR(1000)


EXECUTE [wr].[STP_PrepareforPushtoGeneva]
 @VcWrIDs					='5'
 ,@IntSuccess				=@IntSuccess OUTPUT
 ,@VcError_Message				=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------TO VIEW DATA IN TABLES---------------------------

SELECT * FROM [WR].[TBL_ProcessWire]
SELECT * FROM [wr].[TBL_WireTransfer]

*/
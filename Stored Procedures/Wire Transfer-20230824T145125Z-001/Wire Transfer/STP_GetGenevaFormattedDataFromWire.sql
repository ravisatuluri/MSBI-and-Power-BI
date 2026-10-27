USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_GetGenevaFormattedDataFromWire]    Script Date: 30-05-2016 14:05:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [VUWireTransfer]
--GO

ALTER PROCEDURE [wr].[STP_GetGenevaFormattedDataFromWire](
      @VcWireTrasferIDS VARCHAR(MAX) = NULL,
      @IntSuccess       INT OUTPUT,
      @VcMessage        VARCHAR(1000) OUTPUT )
AS
    BEGIN TRY
        BEGIN TRANSACTION T1;
        DECLARE @WireOutput1 VARCHAR(MAX);
		DECLARE @WIREID TABLE (WIREID INT)
		INSERT INTO @WIREID 
		SELECT DATA FROM wr.Split( @VcWireTrasferIDS, ',' )

        CREATE TABLE #Wire( [WireID]							  INT,	
							[RecordClass]                         VARCHAR(500),
                            [RecordAction]                        VARCHAR(500),
                            [RecordRows]                          VARCHAR(500),
                            [Portfolio]                           VARCHAR(500),
                            [LocationAccount]                     VARCHAR(500),
                            [Strategy]                            VARCHAR(500),
                            [Investment]                          VARCHAR(500),
                            [EventDate]                           VARCHAR(500),
                            [SettleDate]                          VARCHAR(500),
                            [ActualSettleDate]                    VARCHAR(500),
                            [Comments]                            VARCHAR(500),
                            [UserDefDate1]                        VARCHAR(500),
                            [UserDefDate2]                        VARCHAR(500),
                            [UserTranID1]                         VARCHAR(500),
                            [UserTranID2]                         VARCHAR(500),
                            [InvestmentClosingRule]               VARCHAR(500),
                            [SecondaryInvestmentClosingRule]      VARCHAR(500),
                            [Quantity]                            VARCHAR(500),
                            [N/A]                                 VARCHAR(500),
                            [Price]                               VARCHAR(500),
                            [N/A1]                                VARCHAR(500),
                            [N/A2]                                VARCHAR(500),
                            [N/A3]                                VARCHAR(500),
                            [N/A4]                                VARCHAR(500),
                            [N/A5]                                VARCHAR(500),
                            [N/A6]                                VARCHAR(500),
                            [N/A7]                                VARCHAR(500),
                            [PendingIncomeFlag]                   VARCHAR(500),
                            [N/A8]                                VARCHAR(500),
                            [PriceFXDenomination]                 VARCHAR(500),
                            [N/A9]                                VARCHAR(500),
                            [CounterTDateFX]                      VARCHAR(500),
                            [N/A10]                               VARCHAR(500),
                            [AccruedInterest]                     VARCHAR(500),
                            [N/A11]                               VARCHAR(500),
                            [N/A12]                               VARCHAR(500),
                            [N/A13]                               VARCHAR(500),
                            [InvestmentClosingListLotID]          VARCHAR(500),
                            [InvestmentClosingListReliefQuantity] VARCHAR(500),
                            [ContractExpirationDate]              VARCHAR(500),
                            [N/A14]                               VARCHAR(500),
                            [Original Face]                       VARCHAR(500),
                            [N/A15]                               VARCHAR(500),
                            [N/A16]                               VARCHAR(500),
                            [N/A17]                               VARCHAR(500),
                            [N/A18]                               VARCHAR(500),
                            [N/A19]                               VARCHAR(500),
                            [N/A20]                               VARCHAR(500),
                            [TransferLeg]                         VARCHAR(500),
                            [N/A21]                               VARCHAR(500),
                            [N/A22]                               VARCHAR(500),
                            [TransferType]                        VARCHAR(500),
                            [N/A23]                               VARCHAR(500),
                            [N/A24]                               VARCHAR(500),
                            [N/A25]                               VARCHAR(500),
                            [N/A26]                               VARCHAR(500),
                            [N/A27]                               VARCHAR(500),
                            [N/A28]                               VARCHAR(500),
                            [N/A29]                               VARCHAR(500),
                            [N/A30]                               VARCHAR(500),
                            [N/A31]                               VARCHAR(500),
                            [N/A32]                               VARCHAR(500),
                            [N/A33]                               VARCHAR(500),
                            [N/A34]                               VARCHAR(500),
                            [N/A35]                               VARCHAR(500),
                            [N/A36]                               VARCHAR(500),
                            [N/A37]                               VARCHAR(500),
                            [N/A38]                               VARCHAR(500),
                            [N/A39]                               VARCHAR(500),
                            [N/A40]                               VARCHAR(500),
                            [N/A41]                               VARCHAR(500),
                            [N/A42]                               VARCHAR(500),
                            [N/A43]                               VARCHAR(500),
                            [N/A44]                               VARCHAR(500),
                            [N/A45]                               VARCHAR(500),
                            [NewLocationAccount]                  VARCHAR(500),
                            [NewStrategy]                         VARCHAR(500),
                            [N/A46]                               VARCHAR(500),
                            [N/A47]                               VARCHAR(500),
                            [N/A48]                               VARCHAR(500),
                            [N/A49]                               VARCHAR(500),
                            [N/A50]                               VARCHAR(500),
                            [N/A51]                               VARCHAR(500),
                            [N/A52]                               VARCHAR(500),
                            [NewPriority]                         VARCHAR(500),
                            [EventDesc]                           VARCHAR(500),
                            [N/A67]                               VARCHAR(500),
                            [N/A68]                               VARCHAR(500),
                            [FundStructure]                       VARCHAR(500),
                            [UserDefField1]                       VARCHAR(500),
                            [N/A53]                               VARCHAR(500),
                            [N/A54]                               VARCHAR(500),
                            [N/A55]                               VARCHAR(500),
                            [N/A56]                               VARCHAR(500),
                            [N/A57]                               VARCHAR(500),
                            [N/A58]                               VARCHAR(500),
                            [N/A59]                               VARCHAR(500),
                            [N/A60]                               VARCHAR(500),
                            [N/A61]                               VARCHAR(500),
                            [N/A62]                               VARCHAR(500),
                            [N/A63]                               VARCHAR(500),
                            [N/A64]                               VARCHAR(500),
                            [N/A65]                               VARCHAR(500),
                            [AccountingView]                      VARCHAR(500),
                            [N/A66]                               VARCHAR(500),
                            [N/A69]                               VARCHAR(500),
                            [N/A70]                               VARCHAR(500),
                            [N/A71]                               VARCHAR(500),
                            [N/A72]                               VARCHAR(500),
                            [N/A73]                               VARCHAR(500),
                            [N/A74]                               VARCHAR(500),
                            [N/A75]                               VARCHAR(500),
                            [N/A76]                               VARCHAR(500),
                            [N/A77]                               VARCHAR(500),
                            [N/A78]                               VARCHAR(500),
                            [N/A79]                               VARCHAR(500),
                            [N/A80]                               VARCHAR(500),
                            [N/A81]                               VARCHAR(500),
                            [N/A82]                               VARCHAR(500),
                            [N/A83]                               VARCHAR(500),
                            [N/A84]                               VARCHAR(500),
                            [N/A85]                               VARCHAR(500),
                            [N/A86]                               VARCHAR(500),
                            [N/A87]                               VARCHAR(500),
                            [N/A88]                               VARCHAR(500),
                            [N/A89]                               VARCHAR(500),
                            [N/A90]                               VARCHAR(500),
                            [N/A91]                               VARCHAR(500),
                            [N/A92]                               VARCHAR(500),
                            [N/A93]                               VARCHAR(500),
                            [N/A94]                               VARCHAR(500),
                            [N/A95]                               VARCHAR(500),
                            [N/A96]                               VARCHAR(500),
                            [N/A97]                               VARCHAR(500),
                            [N/A98]                               VARCHAR(500),
                            [N/A99]                               VARCHAR(500),
                            [N/A100]                              VARCHAR(500),
                            [N/A101]                              VARCHAR(500),
                            [UserTranId1_2]                       VARCHAR(500),
                            [ExternalSystemReferenceID]           VARCHAR(500));
        INSERT INTO #Wire
               ( [WireID],
			     [RecordClass],
                 [RecordAction],
                 [RecordRows],
                 [Portfolio],
                 [LocationAccount],
                 [NewLocationAccount],
                 [Strategy],
                 [Investment],
                 [NewStrategy],
                 [EventDate],
                 [SettleDate],
                 [ActualSettleDate],
                 [Quantity],
                 [TransferType],
                 [UserTranID1],
                 [UserTranId1_2],
                 FundStructure,
                 EventDesc,
                 InvestmentClosingRule,
                 [ExternalSystemReferenceID],
                 [Comments],
                 [Price]
               )
               SELECT [WireID],
					  'Transfer' [RecordClass],
                                 CASE VcWireStatus
                                     WHEN 'Deleted'
                                     THEN 'Delete'
                                     ELSE 'InsertUpdate'
                                 END [RecordAction],
                      '1' [RecordRows],
                      Pf.VcPortfolioShortCode [Portfolio],
                      CASE WHEN WT.VcActionType = 'Deposit'  THEN cc.VcCustodianAccountCode 
						   WHEN WT.VcActionType = 'Withdrawal'  THEN dc.VcCustodianAccountCode 
					  END [LocationAccount],
					  CASE WHEN WT.VcActionType = 'Deposit'  THEN dc.VcCustodianAccountCode 
						   WHEN WT.VcActionType = 'Withdrawal'  THEN cc.VcCustodianAccountCode 
					  END [NewLocationAccount],
                      'CURRENCY' [Strategy],
                      c.VcCurrencyCode [Investment],
                      'CURRENCY' [NewStrategy],
                      CONVERT( DATE, wt.DtValueDate) [EventDate],
                      CONVERT( DATE, wt.DtValueDate) [SettleDate],
                      CONVERT( DATE, wt.DtValueDate) [ActualSettleDate],
                      wt.DecAmount [Quantity],
                      'At Price' [TransferType],
                      RTRIM(LTRIM(CONVERT(   VARCHAR(5), wt.BintWireID))) + '_' + pf.VcPortfolioShortCode + '_' + c.VcCurrencyCode + '_5678' [UserTranID1],
                      RTRIM(LTRIM(CONVERT(   VARCHAR(5), wt.BintWireID))) + '_' + pf.VcPortfolioShortCode + '_' + c.VcCurrencyCode + '_5678' [UserTranId1_2],
                      '<CALC>' [FundStructure],
                      '' [EventDesc],
                      '' [InvestmentClosingRule],
                      BintWireID [ExternalSystemReferenceID],
                      Wt.VcComment [Comments],
                      '1' [Price]
               FROM wr.TBL_WireTransfer Wt
					INNER JOIN @WIREID w ON Wt.BintWireID = W.WIREID
                    LEFT JOIN CMRF.tbl_Portfolio Pf ON Wt.IntPortfolioid = Pf.IntPortfolioID
                    LEFT JOIN cmrf.TBL_Currency c ON wt.SinCurrencyID = c.SinCurrencyID
                    LEFT JOIN cmrf.TBL_Custodian_Account dc ON Wt.IntDebitCustodianAccount = dc.IntCustodianAccountID
                    LEFT JOIN cmrf.TBL_Custodian_Account cc ON Wt.IntCreditCustodianAccount = cc.IntCustodianAccountID
               --WHERE BintWireID IN( SELECT DATA
                 --                   FROM wr.Split( @VcWireTrasferIDS, ',' ));
        SELECT ISNULL(CONVERT(VARCHAR(10),[WireID]),'') AS [WireID],ISNULL([RecordClass], '') + '|' + ISNULL([RecordAction], '') + '|' + ISNULL([RecordRows], '') + '|' + ISNULL([Portfolio], '') + '|' + ISNULL([LocationAccount], '') + '|' + ISNULL([Strategy], '') + '|' + ISNULL([Investment], '') + '|' + ISNULL([EventDate], '') + '|' + ISNULL([SettleDate], '') + '|' + ISNULL([ActualSettleDate], '') + '|' + ISNULL([Comments], '') + '|' + ISNULL([UserDefDate1], '') + '|' + ISNULL([UserDefDate2], '') + '|' + ISNULL([UserTranID1], '') + '|' + ISNULL([UserTranID2], '') + '|' + ISNULL([InvestmentClosingRule], '') + '|' + ISNULL([SecondaryInvestmentClosingRule], '') + '|' + ISNULL([Quantity], '') + '|' + ISNULL([N/A], '') + '|' + ISNULL([Price], '') + '|' + ISNULL([N/A1], '') + '|' + ISNULL([N/A2], '') + '|' + ISNULL([N/A3], '') + '|' + ISNULL([N/A4], '') + '|' + ISNULL([N/A5], '') + '|' + ISNULL([N/A6], '') + '|' + ISNULL([N/A7], '') + '|' + ISNULL([PendingIncomeFlag], '') + '|' + ISNULL([N/A8], '') + '|' + ISNULL([PriceFXDenomination], '') + '|' + ISNULL([N/A9], '') + '|' + ISNULL([CounterTDateFX], '') + '|' + ISNULL([N/A10], '') + '|' + ISNULL([AccruedInterest], '') + '|' + ISNULL([N/A11], '') + '|' + ISNULL([N/A12], '') + '|' + ISNULL([N/A13], '') + '|' + ISNULL([InvestmentClosingListLotID], '') + '|' + ISNULL([InvestmentClosingListReliefQuantity], '') + '|' + ISNULL([ContractExpirationDate], '') + '|' + ISNULL([N/A14], '') + '|' + ISNULL([Original Face], '') + '|' + ISNULL([N/A15], '') + '|' + ISNULL([N/A16], '') + '|' + ISNULL([N/A17], '') + '|' + ISNULL([N/A18], '') + '|' + ISNULL([N/A19], '') + '|' + ISNULL([N/A20], '') + '|' + ISNULL([TransferLeg], '') + '|' + ISNULL([N/A21], '') + '|' + ISNULL([N/A22], '') + '|' + ISNULL([TransferType], '') + '|' + ISNULL([N/A23], '') + '|' + ISNULL([N/A24], '') + '|' + ISNULL([N/A25], '') + '|' + ISNULL([N/A26], '') + '|' + ISNULL([N/A27], '') + '|' + ISNULL([N/A28], '') + '|' + ISNULL([N/A29], '') + '|' + ISNULL([N/A30], '') + '|' + ISNULL([N/A31], '') + '|' + ISNULL([N/A32], '') + '|' + ISNULL([N/A33], '') + '|' + ISNULL([N/A34], '') + '|' + ISNULL([N/A35], '') + '|' + ISNULL([N/A36], '') + '|' + ISNULL([N/A37], '') + '|' + ISNULL([N/A38], '') + '|' + ISNULL([N/A39], '') + '|' + ISNULL([N/A40], '') + '|' + ISNULL([N/A41], '') + '|' + ISNULL([N/A42], '') + '|' + ISNULL([N/A43], '') + '|' + ISNULL([N/A44], '') + '|' + ISNULL([N/A45], '') + '|' + ISNULL([NewLocationAccount], '') + '|' + ISNULL([NewStrategy], '') + '|' + ISNULL([N/A46], '') + '|' + ISNULL([N/A47], '') + '|' + ISNULL([N/A48], '') + '|' + ISNULL([N/A49], '') + '|' + ISNULL([N/A50], '') + '|' + ISNULL([N/A51], '') + '|' + ISNULL([N/A52], '') + '|' + ISNULL([NewPriority], '') + '|' + ISNULL([EventDesc], '') + '|' + ISNULL([N/A67], '') + '|' + ISNULL([N/A68], '') + '|' + ISNULL([FundStructure], '') + '|' + ISNULL([UserDefField1], '') + '|' + ISNULL([N/A53], '') + '|' + ISNULL([N/A54], '') + '|' + ISNULL([N/A55], '') + '|' + ISNULL([N/A56], '') + '|' + ISNULL([N/A57], '') + '|' + ISNULL([N/A58], '') + '|' + ISNULL([N/A59], '') + '|' + ISNULL([N/A60], '') + '|' + ISNULL([N/A61], '') + '|' + ISNULL([N/A62], '') + '|' + ISNULL([N/A63], '') + '|' + ISNULL([N/A64], '') + '|' + ISNULL([N/A65], '') + '|' + ISNULL([AccountingView], '') + '|' + ISNULL([N/A66], '') + '|' + ISNULL([N/A69], '') + '|' + ISNULL([N/A70], '') + '|' + ISNULL([N/A71], '') + '|' + ISNULL([N/A72], '') + '|' + ISNULL([N/A73], '') + '|' + ISNULL([N/A74], '') + '|' + ISNULL([N/A75], '') + '|' + ISNULL([N/A76], '') + '|' + ISNULL([N/A77], '') + '|' + ISNULL([N/A78], '') + '|' + ISNULL([N/A79], '') + '|' + ISNULL([N/A80], '') + '|' + ISNULL([N/A81], '') + '|' + ISNULL([N/A82], '') + '|' + ISNULL([N/A83], '') + '|' + ISNULL([N/A84], '') + '|' + ISNULL([N/A85], '') + '|' + ISNULL([N/A86], '') + '|' + ISNULL([N/A87], '') + '|' + ISNULL([N/A88], '') + '|' + ISNULL([N/A89], '') + '|' + ISNULL([N/A90], '') + '|' + ISNULL([N/A91], '') + '|' + ISNULL([N/A92], '') + '|' + ISNULL([N/A93], '') + '|' + ISNULL([N/A94], '') + '|' + ISNULL([N/A95], '') + '|' + ISNULL([N/A96], '') + '|' + ISNULL([N/A97], '') + '|' + ISNULL([N/A98], '') + '|' + ISNULL([N/A99], '') + '|' + ISNULL([N/A100], '') + '|' + ISNULL([N/A101], '') + '|' + ISNULL([UserTranId1_2], '') + '|' + ISNULL(ExternalSystemReferenceID, '') + CHAR(10) AS WireLoaderData
        FROM #Wire WITH ( NOLOCK )  
        ORDER BY ExternalSystemReferenceID;

			SET @IntSuccess = 1 
			SET @VcMessage = 'success'
        COMMIT TRANSACTION T1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION T1;
            END;
        EXEC [err].[stp_LogError];
        SET @IntSuccess = -1 * ERROR_NUMBER();
        SET @VcMessage = ERROR_MESSAGE();
    END CATCH

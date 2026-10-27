USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_WireReports]    Script Date: 25-02-2016 19:05:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [wr].[STP_WireReports](
      @VcReportType VARCHAR(20),
      @VcApprovedDate VARCHAR(20),
	  @VcValueDate VARCHAR(20),
	  @IntClientId INT
	  )
AS
     DECLARE @IntUserID    INT,
             @DtActionDate DATETIME,
             @DtApprovedDate       DATE = CONVERT(DATE, @VcApprovedDate),
			 @DtValueDate  DATE =  CONVERT(DATE, @VcValueDate);

    BEGIN TRY
	 --IF @VcReportType = 'PB Report'
	 --BEGIN
	 --   SELECT                 [ssi].[VcUnique_id] AS [Trade number],
  --                             '' AS [Allocation / sequence number],
  --                             [wt].[VcType] AS [Security type],
  --                                              CASE [wt].[VcActionType]
  --                                                  WHEN 'Deposit'
  --                                                  THEN 'DP'
  --                                                  WHEN 'Withdrawal'
  --                                                  THEN 'WD'
  --                                              END AS [Trade action],
  --                             [ssi].VcBenInfo_CounterPartyName AS [Counterparty],
  --                             [ssi].IntBenInfo_CustodianAccountID AS [Account number],
  --                             [ssi].[VcAccountType] AS [Account Type],
  --                             '' AS [ISIN],
  --                             '' AS [SEDOL],
  --                             '' AS [QUIK],
  --                             '' AS [CUSIP],
  --                             '' AS [TICKER],
  --                             [c].[VcCurrencyCode] AS [Local Currency Code],
  --                             '' AS [Settlement Currency Code],
  --                             '' AS [Fx rate],
  --                             '' AS [Pricing Factor],
  --                             '' AS [Trading Factor],
  --                             '' AS [Quantity],
  --                             '' AS [Price Local],
  --                             '' AS [Accrued Interest Local],
  --                             '' AS [Principal Local],
  --                             '' AS [Commission local],
  --                             '' AS [Fees Local],
  --                             '' AS [CHARges Local],
  --                             '' AS [Levies Local],
  --                             '' AS [SEC Fees Local],
  --                             '' AS [Net Proceeds Local],
  --                             '' AS [Price Settlement],
  --                             '' AS [Accrued Interest Settlement],
  --                             '' AS [Principal Settlement],
  --                             '' AS [Commission Settlement],
  --                             '' AS [Fees Settlement],
  --                             '' AS [CHARges Settlement],
  --                             '' AS [Levies Settlement],
  --                             '' AS [SEC Fees settlement],
  --                             wt.DecAmount AS [Net Proceeds Settlement],
  --                             '' AS [Trade DATE],
  --                             wt.DtValueDate AS [Settle DATE/Transfer DATE/Payment DATE],
  --                             '' AS [Reserved],
  --                              ssi.VcFurtherCredit_Reference AS  [Comments],
  --                             '' AS [Yield],
  --                             '' AS [Clearing Broker],
  --                             '' AS [Strategy],
  --                             '' AS [Clearing Location],
  --                             '' AS [Product description],
  --                             [ssi].[VcTemplateID] AS [Delivery instruction/Template name],
  --                             '' AS [Settlement instruction],
  --                             '' AS [Off DATE/Delivery DATE],
  --                             '' AS [Rate],
  --                             '' AS [Rerate/Fix DATE],
  --                             '' AS [Repo basis],
  --                             '' AS [PutCall type],
  --                             '' AS [Option contract type],
  --                             '' AS [Expiry time],
  --                             '' AS [Expiry location],
  --                             '' AS [FX option CCY1],
  --                             '' AS [FX option CCY2],
  --                             '' AS [Notional amount1],
  --                             '' AS [Notional amount2],
  --                             '' AS [Payout Amount],
  --                             '' AS [Payout CCY],
  --                             '' AS [Rebate Quote Mode],
  --                             '' AS [Rebate1],
  --                             '' AS [Barrier1],
  --                             '' AS [Barrier1 start DATE],
  --                             '' AS [Barrier1 END DATE],
  --                             '' AS [Rebate2],
  --                             '' AS [Barrier2],
  --                             '' AS [Barrier2 start DATE],
  --                             '' AS [Barrier2 END DATE],
  --                             '' AS [Far amount],
  --                             '' AS [Barrier direction],
  --                             '' AS [Link indicator]
  --                      FROM [wr].[TBL_WireTransfer] wt WITH ( NOLOCK )                      
  --                      INNER JOIN [wr].[TBL_SSI] ssi WITH ( NOLOCK ) ON wt.VcSSIUniqueID = ssi.VcUnique_id
  --                      INNER JOIN [cmrf].[TBL_Currency] c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
		--			    WHERE (CONVERT(DATE,wt.DtApprovedDate) = @DtApprovedDate OR  CONVERT(DATE,wt.DtValueDate) = @DtValueDate) AND (wt.VcWireStatus = 'Sent To PB' OR wt.VcWireStatus='Approved' OR wt.VcWireStatus='Sent To Client') 
	 --END
	 --ELSE 
	 IF @VcReportType = 'Geneva Report'
	 BEGIN
	 SELECT wt.BintWireID AS [IntWrID],
               wt.VcWireStatus AS [VcWireStatus],
               p.IntPortfolioID,
               'Transfer' AS [RecordClass],
                             CASE wt.VcWireStatus
                                 WHEN 'Deleted'
                                 THEN 'Delete'
                                 ELSE 'InsertUpdate'
                             END AS [RecordAction],
               '1' AS [RecordRows],
               p.VcPortfolioShortCode AS [Portfolio],
               dc.VcCustodianAccountCode AS [LocationAccount],
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
               cc.VcCustodianAccountCode AS [NewLocationAccount],
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
               wt.DtLastUpdatedTime as DtLastUpdatedOn,
			   CASE WHEN wt.BtIsPushSuccess = 0 THEN 'Failure'
					WHEN wt.BtIsPushSuccess = 1 THEN 'Success'
					WHEN wt.BtIsPushSuccess = NULL THEN NULL
					END GenevaStatus
        FROM wr.TBL_WireTransfer wt WITH ( NOLOCK )
             INNER JOIN cmrf.TBL_Portfolio p WITH ( NOLOCK ) ON wt.IntPortfolioid = p.IntPortfolioID
             INNER JOIN cmrf.TBL_Currency c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
             INNER JOIN cmrf.TBL_Custodian_Account dc WITH ( NOLOCK ) ON wt.IntDebitCustodianAccount = dc.IntCustodianAccountID
             INNER JOIN cmrf.TBL_Custodian_Account cc WITH ( NOLOCK ) ON wt.IntCreditCustodianAccount = cc.IntCustodianAccountID
	     WHERE (CONVERT(DATE, Wt.DtApprovedDate) = @DtApprovedDate OR DtValueDate = @DtValueDate) AND (wt.VcWireStatus = 'Sent To PB' OR wt.VcWireStatus='Approved' OR wt.VcWireStatus='Sent To Client')  
          --AND ISNULL(BtIsPushSuccess, 0) = 0 
		  AND wt.IntClientDefinitionID = @IntClientId;
	 END
	 ELSE 
	 IF (@VcReportType = 'Package Report')
	 BEGIN
		  DECLARE @ClientCode VARCHAR(25)
		  SELECT  @ClientCode = VcClientShortCode FROM [cmrf].[TBL_Client] where IntClientDefinitionID = @IntClientId
		  DECLARE @AstClientId int
		  SELECT @AstClientId = intCLient FROM  [setup].[tbl_clients] WHERE vcClientShortCode = @ClientCode  
		  CREATE TABLE #conf (status_log_RecID bigint, Confim_DB_RecID BIGINT, status_log_Updatedtime DATETIME, [Status] VARCHAR(20))      
		  INSERT INTO #conf (status_log_RecID,Confim_DB_RecID)      
		  SELECT MAX(RecID)status_log_RecID,Confim_DB_RecID      
		 FROM setup.tbl_cnfm_data_status_log WITH(NOLOCK)      
		 GROUP BY Confim_DB_RecID 
		 UPDATE #conf set status_log_Updatedtime=l.Updatedtime, [Status]=l.[status]      
		 FROM #conf  cm WITH(NOLOCK),  setup.tbl_cnfm_data_status_log  l WITH(NOLOCK)      
		 WHERE cm.Confim_DB_RecID =l.Confim_DB_RecID      
		 and  cm.status_log_RecID =l.recID  

	     DECLARE @WirePackage TABLE([Sno]				Int,  
									[VcGroupName]        VARCHAR(300),
                                    [ClientAccount]    VARCHAR(300),
                                    [TradeType]        VARCHAR(300),
                                    [AccountName]      VARCHAR(300),
                                    [SecurityName]     VARCHAR(300),
                                    [Paymentcurrency]      VARCHAR(300),
                                    [TradeDate]        DATE,
                                    [PaymentDate]      DATE,
                                    [Amount]        DECIMAL(19, 4),
                                    [Movement]           VARCHAR(300),
                                    [Status]           VARCHAR(300));

        IF EXISTS( SELECT 1
                   FROM Wr.TBL_WireTransfer WT
                   WHERE Wt.BitIsApproved = 1
                     AND Wt.VcType='WIRE'
					 AND Wt.BitActive = 1
					 AND WT.IntClientDefinitionID = @IntClientId
                     AND (CONVERT(DATE, Wt.DtApprovedDate) = @DtApprovedDate OR WT.DtValueDate = @DtValueDate))
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],
					     [VcGroupName],
                         [ClientAccount],
                         [TradeType],
                         [AccountName],
                         [SecurityName],
                         [Paymentcurrency],
                         [TradeDate],
                         [PaymentDate],
                         [Amount],
                         [Movement],
                         [Status]
                       )
                       SELECT 1 [Sno],
							  'Confirmed and Wire Uploaded' AS [Group Name],
                              Ca.VcCustodianAccountCode [Client Account],
                              TC.VcTypeName [Trade Type],
                              pf.VcPortfolioName [Account Name],
                              '' [Security Name],
                              Cu.VcCurrencyCode [Payment currency],
                              CONVERT(DATE,wt.DtCreatedDate) [Trade Date],
                              Wt.DtValueDate [Payment Date],
                                 CASE
                                     WHEN Wt.VcActionType = 'Deposit'
                                     THEN( CONVERT( VARCHAR, Wt.DecAmount))
                                     ELSE '-' + ( CONVERT(VARCHAR, Wt.DecAmount))
                                 END AS [Amount],
                                        CASE
                                            WHEN Wt.VcActionType = 'Deposit'
                                            THEN  'Fore Recieves'
                                            ELSE  'Fore Pays'
                                        END [Movement],
                              Wt.VcWireStatus [Status]
                       FROM Wr.TBL_WireTransfer Wt WITH ( NOLOCK )
					   INNER JOIN WR.TBL_Configuration TC WITH ( NOLOCK ) ON WT.VcTransactionType = TC.VcTypeCode AND TC.BitActive = 1
					   INNER JOIN cmrf.tbl_Portfolio pf WITH (NOLOCK) ON Wt.IntPortfolioid = pf.IntPortfolioID AND pf.BitIsActive = 1
					   INNER JOIN cmrf.tbl_Currency cu WITH(NOLOCK) ON Wt.SinCurrencyID = cu.SinCurrencyID AND cu.BitIsActive = 1
					   INNER JOIN [cmrf].[TBL_Client] C WITH ( NOLOCK ) ON Wt.IntClientDefinitionID = C.IntClientDefinitionID AND C.BitIsActive = 1
					   INNER JOIN CMRF.tbl_Custodian_Account Ca WITH ( NOLOCK ) ON CASE
                                                                                            WHEN Wt.VcActionType = 'Deposit'
                                                                                            THEN Wt.IntCreditCustodianAccount
                                                                                            ELSE Wt.IntDebitCustodianAccount
                                                                                        END = Ca.IntCustodianAccountID
                        INNER JOIN [wr].[TBL_SSI] Ss WITH ( NOLOCK ) ON ss.IntID = CASE
                                                                                           WHEN Wt.VcActionType = 'Deposit'
                                                                                           THEN Wt.IntCreditSSID
                                                                                           ELSE Wt.IntDebitSSID
                                                                                       END
					   WHERE Wt.BitIsApproved = 1 AND Wt.VcType='WIRE'AND Wt.BitActive = 1  AND Wt.IntClientDefinitionID = @IntClientId
					   AND (CONVERT(DATE, Wt.DtApprovedDate) = @DtApprovedDate OR DtValueDate = @DtValueDate );
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 1 [Sno],'Confirmed and Wire Uploaded' [VcGroupName];
            END;
        IF EXISTS( SELECT 1
                   FROM Wr.TBL_WireTransfer WT
                   WHERE Wt.BitIsApproved = 0 AND Wt.VcWireStatus IN ('Created','Modified')
                     AND Wt.VcType = 'WIRE'
					 AND Wt.BitActive = 1
					 AND wt.IntClientDefinitionID = @IntClientId
                     )
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],
						 [VcGroupName],
                         [ClientAccount],
                         [TradeType],
                         [AccountName],
                         [SecurityName],
                         [Paymentcurrency],
                         [TradeDate],
                         [PaymentDate],
                         [Amount],
                         [Movement],
                         [Status]
                       )
                       SELECT 2 [Sno],
							  'Pending for Approval' AS [Group Name],
                              Ca.VcCustodianAccountCode [Client Account],
                              TC.VcTypeName [Trade Type],
                             pf.VcPortfolioName [Account Name],
                              '' [Security Name],
                              Cu.VcCurrencyCode [Payment currency],
                              CONVERT(DATE,wt.DtCreatedDate) [Trade Date],
                              Wt.DtValueDate [Payment Date],
                                 CASE
                                     WHEN Wt.VcActionType = 'Deposit'
                                     THEN( CONVERT( VARCHAR, Wt.DecAmount))
                                     ELSE '-' + ( CONVERT(VARCHAR, Wt.DecAmount))
                                 END AS [Amount],
                                        CASE
                                            WHEN Wt.VcActionType = 'Deposit'
                                            THEN 'Fore Recieves'
                                            ELSE 'Fore Pays'
                                        END [Movement],
                             Wt.VcWireStatus  [Status]
                       FROM Wr.TBL_WireTransfer Wt WITH ( NOLOCK )
							INNER JOIN WR.TBL_Configuration TC WITH ( NOLOCK ) ON WT.VcTransactionType = TC.VcTypeCode AND TC.BitActive = 1
					        INNER JOIN cmrf.tbl_Portfolio pf WITH (NOLOCK) ON Wt.IntPortfolioid = pf.IntPortfolioID AND pf.BitIsActive = 1
							INNER JOIN cmrf.tbl_Currency cu WITH(NOLOCK) ON Wt.SinCurrencyID = cu.SinCurrencyID AND cu.BitIsActive = 1
							INNER JOIN [cmrf].[TBL_Client] C WITH ( NOLOCK ) ON Wt.IntClientDefinitionID = C.IntClientDefinitionID AND C.BitIsActive = 1
                            INNER JOIN CMRF.tbl_Custodian_Account Ca WITH ( NOLOCK ) ON CASE
                                                                                            WHEN Wt.VcActionType = 'Deposit'
                                                                                            THEN Wt.IntCreditCustodianAccount
                                                                                            ELSE Wt.IntDebitCustodianAccount
                                                                                        END = Ca.IntCustodianAccountID
                            INNER JOIN [wr].[TBL_SSI] Ss WITH ( NOLOCK ) ON ss.IntID = CASE
                                                                                           WHEN Wt.VcActionType = 'Deposit'
                                                                                           THEN Wt.IntCreditSSID
                                                                                           ELSE Wt.IntDebitSSID
                                                                                       END 
            
						WHERE Wt.BitIsApproved = 0 AND Wt.VcWireStatus IN ('Created','Modified')
								AND Wt.VcType = 'WIRE'
								AND Wt.BitActive = 1
								AND wt.IntClientDefinitionID = @IntClientId
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 2 [Sno],'Pending for Approval' [VcGroupName];
            END;
        IF EXISTS( (SELECT 1
                   FROM setup.tbl_cnfm_data cd
                   WHERE cd.Approved = 1
				       AND cd.confirmed = 1
					   AND cd.PreAdviseProcessed = 0
					   AND cd.intClient = @AstClientId
                   UNION ALL
				   SELECT 1 FROM wr.TBL_WireBasicInfo
					WHERE BitValidStatus = 1
					AND IntClientDefinitionID = @IntClientId)
                    )                  
					  
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],
						 [VcGroupName],
                         [ClientAccount],
                         [TradeType],
                         [AccountName],
                         [SecurityName],
                         [Paymentcurrency],
                         [TradeDate],
                         [PaymentDate],
                         [Amount],
                         [Movement],
                         [Status]
                       )
                       (SELECT 3 [Sno],
							'Confirmed but Wire not Uploaded' AS [VcGroupName],
                             cd.CustID [Client Account],
                             '' [Trade Type],
                             cd.PortName [Account Name],
                             '' [Security Name],
                              cd.CounterInvest AS [Payment currency],
                              CONVERT(DATE,cd.TDate) AS [Trade Date],
                              cd.ADate AS [Payment Date],
                              cd.LocAmt AS [Amount],
                              CASE WHEN cd.LocAmt < 0 THEN 'Fore Pays' ELSE 'Fore Receives' END [Movement],
                              'Confirm' [Status]
                        FROM setup.tbl_cnfm_data cd
						WHERE cd.Approved = 1
							AND cd.confirmed = 1
							AND cd.PreAdviseProcessed = 0
							AND cd.intClient = @AstClientId
					   UNION ALL
					   SELECT 3 [Sno],
							   'Confirmed but Wire not Uploaded' AS [VcGroupName],
                               Ca.VcCustodianAccountName [Client Account],
                               '' [Trade Type],
                               pf.VcPortfolioName [Account Name],
                               '' [Security Name],
                               Cu.VcCurrencyCode [Payment currency],
                               CONVERT(DATE,wb.DtCreatedDate) [Trade Date],
                               wb.DtValueDate [Payment Date],
                               wb.DecAmount AS [Amount],
                                CASE WHEN wb.DecAmount< 0 THEN 'Fore Pays' ELSE 'Fore Receives' END  [Movement],
                              'Confirm' [Status]
					    FROM wr.TBL_WireBasicInfo wb WITH(NOLOCK)
						INNER JOIN cmrf.tbl_Portfolio pf WITH (NOLOCK) ON wb.IntPortfolioid = pf.IntPortfolioID AND pf.BitIsActive = 1
						INNER JOIN cmrf.tbl_Currency cu WITH(NOLOCK) ON wb.SinCurrencyID = cu.SinCurrencyID AND cu.BitIsActive = 1
						INNER JOIN [cmrf].[TBL_Client] C WITH ( NOLOCK ) ON C.IntClientDefinitionID = @IntClientId AND C.BitIsActive = 1
						INNER JOIN CMRF.tbl_Custodian_Account Ca WITH ( NOLOCK ) ON wb.IntCustodianAccountID = Ca.IntCustodianAccountID AND Ca.BitIsActive=1
						WHERE wb.BitValidStatus = 1)
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 3 [Sno],'Confirmed but Wire not Uploaded' [VcGroupName];
            END;
        IF EXISTS( SELECT 1
                   FROM setup.tbl_cnfm_data cd
                   WHERE cd.Approved = 1
				       AND cd.confirmed = 0
					   AND cd.PreAdviseProcessed = 0
					   AND cd.wireInstruction_prepared = 0
					   AND cd.intClient = @AstClientId
				  )
            BEGIN

						WITH CTE AS(
									SELECT 'Unconfirmed' AS [VcGroupName],
											cd.CustID [Client Account],
											'' [Trade Type],
											cd.PortName [Account Name],
											'' [Security Name],
											cd.CounterInvest AS [Payment currency],
											CONVERT(DATE,cd.TDate) AS [Trade Date],
											cd.ADate AS [Payment Date],
											cd.LocAmt AS [Amount],
											CASE WHEN cd.LocAmt < 0 THEN 'Fore Pays' ELSE 'Fore receives' END [Movement],
											'Unconfirmed' [Status],
											ROW_NUMBER() OVER(PARTITION BY cd.CustID,cd.CounterInvest,cd.ADate ORDER BY CONVERT(DATE,cd.TDate) DESC) AS row_num
														FROM setup.tbl_cnfm_data cd
														WHERE cd.Approved = 1
															AND cd.confirmed = 0
															AND cd.PreAdviseProcessed = 0
															AND cd.wireInstruction_prepared = 0   
															AND cd.intClient = @AstClientId
									),
							CTE1 AS (
							SELECT cd.CustID AS [Client Account],cd.CounterInvest AS [Payment currency],cd.PortName [Account Name],cd.ADate AS [Payment Date],sum(cd.LocAmt) AS [Amount] 
							FROM setup.tbl_cnfm_data cd
							WHERE cd.Approved = 1
								AND cd.confirmed = 0
								AND cd.PreAdviseProcessed = 0
								AND cd.wireInstruction_prepared = 0   
								AND cd.intClient = @AstClientId
							GROUP BY cd.CustID,cd.CounterInvest,cd.ADate,cd.PortName
							)
							--select distinct c1.*,c.[Trade Date] from cte1 c1
						INSERT INTO @WirePackage
						   ( [Sno],
							 [VcGroupName],
							 [ClientAccount],
							 [TradeType],
							 [AccountName],
							 [SecurityName],
							 [Paymentcurrency],
							 [TradeDate],
							 [PaymentDate],
							 [Amount],
							 [Movement],
							 [Status]
						   )
							SELECT DISTINCT 4 [Sno],c.VcGroupName,c1.[Client Account],c.[Trade Type],c1.[Account Name],c.[Security Name],c1.[Payment currency]
							,c.[Trade Date],c1.[Payment Date],c1.Amount,CASE WHEN c1.Amount < 0 THEN 'Fore Pays' ELSE 'Fore receives' END [Movement],c.[Status] 
							FROM CTE1 c1
							INNER JOIN cte c ON c1.[Client Account] = c.[Client Account]
								AND c1.[Payment currency] = c.[Payment currency]
								AND c1.[Payment Date] = c.[Payment Date]
								WHERE c.row_num = 1
							
						 
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 4 [Sno],'Unconfirmed' [VcGroupName];
            END;
        IF EXISTS( SELECT 1
                   FROM setup.tbl_cnfm_data cd WITH (NOLOCK),#conf conf
                   WHERE cd.Approved = 1
                     AND cd.confirmed = 1
					 AND cd.PreAdviseProcessed = 1
					 AND cd.wireInstruction_prepared =0
					 AND cd.intClient = @AstClientId
					 AND CD.Recid = Conf.Confim_DB_RecID
					 AND (cd.ADate = @DtValueDate OR CONVERT(DATE,conf.status_log_Updatedtime) = @DtApprovedDate)
                    )
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],
						 [VcGroupName],
                         [ClientAccount],
                         [TradeType],
                         [AccountName],
                         [SecurityName],
                         [Paymentcurrency],
                         [TradeDate],
                         [PaymentDate],
                         [Amount],
                         [Movement],
                         [Status]
                       )
                       SELECT  5 [Sno], 
							 'Confirmed but Wires not required' AS [VcGroupName],
                             cd.CustID  [Client Account],
                             '' [Trade Type],
                             cd.PortName [Account Name],
                             '' [Security Name],
                             cd.CounterInvest AS [Payment currency],
                             CONVERT(DATE,cd.TDate) AS [Trade Date],
                             cd.ADate AS [Payment Date],
                             cd.LocAmt AS [Amount],
                             CASE WHEN cd.LocAmt < 0 THEN 'Fore Pays' ELSE 'Fore receives' END [Movement],
                             'Pre Advise' [Status]
					    FROM setup.tbl_cnfm_data cd WITH (NOLOCK),#conf conf
						WHERE cd.Approved = 1
							AND cd.confirmed = 1
							AND cd.PreAdviseProcessed = 1
						    AND cd.wireInstruction_prepared =0
							AND cd.intClient = @AstClientId	
							AND CD.Recid = Conf.Confim_DB_RecID
							AND (cd.ADate = @DtValueDate OR CONVERT(DATE,conf.status_log_Updatedtime) = @DtApprovedDate)
														
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 5 [Sno],'Confirmed but Wires not required' [VcGroupName];
            END;
        IF EXISTS( SELECT 1
                   FROM Wr.TBL_WireTransfer WT
                   WHERE Wt.VcType = 'LOA'
                     AND Wt.BitActive = 1
					 AND Wt.IntClientDefinitionID = @IntClientId
                     )
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],
					     [VcGroupName],
                         [ClientAccount],
                         [TradeType],
                         [AccountName],
                         [SecurityName],
                         [Paymentcurrency],
                         [TradeDate],
                         [PaymentDate],
                         [Amount],
                         [Movement],
                         [Status]
                       )
                       SELECT  6 [Sno],
							  'Instructed through LOA' AS [GroupName],
                              Ca.VcCustodianAccountCode [Client Account],
                              TC.VcTypeName [Trade Type],
                              pf.VcPortfolioName [Account Name],
                              '' [Security Name],
                              Cu.VcCurrencyCode [Payment currency],
                              CONVERT(DATE,wt.DtCreatedDate) [Trade Date],
                              Wt.DtValueDate [Payment Date],
                                    CASE
                                        WHEN Wt.VcActionType = 'Deposit'
                                        THEN( CONVERT( VARCHAR, Wt.DecAmount))
                                        ELSE '-' + ( CONVERT(VARCHAR, Wt.DecAmount))
                                    END AS [Amount],
                                           CASE
                                               WHEN Wt.VcActionType = 'Deposit'
                                               THEN 'Fore Recieves'
                                               ELSE 'Fore Pays'
                                           END [Movement],
                              wt.VcWireStatus [Status]
                       FROM Wr.TBL_WireTransfer Wt WITH ( NOLOCK )
							INNER JOIN WR.TBL_Configuration TC WITH ( NOLOCK ) ON WT.VcTransactionType = TC.VcTypeCode AND TC.BitActive = 1
							INNER JOIN cmrf.tbl_Portfolio pf WITH (NOLOCK) ON Wt.IntPortfolioid = pf.IntPortfolioID AND pf.BitIsActive = 1
							INNER JOIN cmrf.tbl_Currency cu WITH(NOLOCK) ON Wt.SinCurrencyID = cu.SinCurrencyID AND cu.BitIsActive = 1
							INNER JOIN [cmrf].[TBL_Client] C WITH ( NOLOCK ) ON C.IntClientDefinitionID = @IntClientId AND C.BitIsActive = 1
                            INNER JOIN CMRF.tbl_Custodian_Account Ca WITH ( NOLOCK ) ON CASE
                                                                                            WHEN Wt.VcActionType = 'Deposit'
                                                                                            THEN Wt.IntCreditCustodianAccount
                                                                                            ELSE Wt.IntDebitCustodianAccount
                                                                                        END = Ca.IntCustodianAccountID
                            INNER JOIN [wr].[TBL_SSI] Ss WITH ( NOLOCK ) ON ss.IntID = CASE
                                                                                           WHEN Wt.VcActionType = 'Deposit'
                                                                                           THEN Wt.IntCreditSSID
                                                                                           ELSE Wt.IntDebitSSID
                                                                                       END
                          
                        WHERE Wt.VcType = 'LOA'
                          AND Wt.BitActive = 1
						  
            END;
        ELSE
            BEGIN
                INSERT INTO @WirePackage
                       ( [Sno],[VcGroupName]
                       )
                       SELECT 6 [Sno],'Instructed through LOA' [VcGroupName];
            END;
        SELECT [Sno],
			   [VcGroupName],
               [ClientAccount],
               [TradeType],
               [AccountName],
               [SecurityName],
               [Paymentcurrency],
               [TradeDate],
               [PaymentDate],
               [Amount],
               [Movement],
               [Status]
        FROM @WirePackage
		ORDER BY 1;

	 END
	 
    END TRY
    BEGIN CATCH
        EXEC [err].[STP_LogError];
    END CATCH;        

/*

USE [VUWireTransfer]
GO
EXECUTE  [wr].[STP_WireReports]
@VcReportType = 'PB Report', 
 @VcTradeDate = '11/25/2015',
	  @VcValueDate =null
-------------------------------------------------
EXECUTE  [wr].[STP_WireReports]
@VcReportType = 'Geneva Report', 
 @VcApprovedDate = '11/25/2015',
	  @VcValueDate =null
-------------------------------------------------
EXECUTE  [wr].[STP_WireReports]
@VcReportType = 'Package Report', 
 @VcApprovedDate = '2016-01-18',
	  @VcValueDate ='2016-01-20',
	   @IntClientId = 39
SELECT * FROM WR.TBL_WIRETRANSFER
------------------------------------------------
EXECUTE  [wr].[STP_WireReports]
@VcReportType = 'Geneva Report', 
@VcApprovedDate = '',
@VcValueDate ='2016-01-17',
@IntClientId = 146
*/




USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_PBReports]    Script Date: 10-02-2016 21:48:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [wr].[STP_PBReports](
									  @VcCustodianCode VARCHAR(20),
									  @VcApprovedDate VARCHAR(25),
									  @VcValueDate VARCHAR(25),
									  @IntClientId	Int,
									  @VcPortfolioIds Varchar(MAX)
									  )
AS
     DECLARE @DtApprovedDate       VARCHAR(20) =  @VcApprovedDate,
			 @DtValueDate  VARCHAR(20) =  @VcValueDate,
			 @ROWNUM INT = 0,
             @LOOPNUM INT = 0,
			 @CrVcActionType VARCHAR(50), 
			 @VcAccountType VARCHAR(50) ;
	IF (OBJECT_ID('tempdb..#VcCustodianCode_CS') IS NOT NULL)
	BEGIN
		DROP TABLE #VcCustodianCode_CS
	END
	IF (OBJECT_ID('tempdb..#VcCustodianCode_BOA') IS NOT NULL)
	BEGIN
		DROP TABLE #VcCustodianCode_BOA
	END
	IF (OBJECT_ID('tempdb..#CustodianCode_CS') IS NOT NULL)
	BEGIN
		DROP TABLE #CustodianCode_CS
	END
	CREATE TABLE #CustodianCode_CS(
		[WireID] Int NULL,
		[LastUpdatedOn] DATETIME NULL,
		[Client trade reference number] [varchar](50) NULL,
		[Transaction Type] [varchar](10) NULL,
		--[CrVcActionType] [varchar](50) NULL,
		--[VcAccountType] [varchar](50) NULL,
		[Account Number] [varchar](50) NULL,
		[Account Type] [varchar](10) NULL,
		[Currency] [varchar](10) NULL,
		[Payment Amount] [decimal](19, 4) NULL,
		[Payment Date] [varchar](50) NULL,
		[Template Name] [varchar](10) NULL,
		[Beneficiary Name] [varchar](100) NULL,
		[Beneficiary Account Number] [varchar](100) NULL,
		[Beneficiary ID (ABA / Sort Code)] [varchar](100) NULL,
		[Beneficiary BIC] [varchar](100) NULL,
		[Account with Institution Beneficiary ID (ABA / Sort Code)] [varchar](100) NULL,
		[Account with Institution Beneficiary Bank BIC] [varchar](100) NULL,
		[Account with Institution Beneficiary Bank Account Number] [varchar](100) NULL,
		[Intermediary Bank ABA] [varchar](50) NULL,
		[Intermediary Bank BIC] [varchar](50) NULL,
		[For Further Credit] [varchar](100) NULL,
		[Payment Reason] [varchar](250) NULL,
		[Create Template] [varchar](10)  NULL,
		[Transfer To Account] [varchar](10)  NULL,
		[Third Party] [varchar](10)  NULL
	) 

	IF (OBJECT_ID('tempdb..#CustodianCode_BOA') IS NOT NULL)
	BEGIN
		DROP TABLE #CustodianCode_BOA
	END
	CREATE TABLE #CustodianCode_BOA(
		[WireID] Int NULL,
		[LastUpdatedOn] DATETIME NULL,
		[PB Acct. No] [varchar](50) NULL,
		[PB Type] [varchar](10)  NULL,
		[Trading Unit] [varchar](10)  NULL,
		[Trading Sub-Unit] [varchar](10)  NULL,
		[Record Typ] [varchar](10) NULL,
		--[CrVcActionType] [varchar](50) NULL,
		--[VcAccountType] [varchar](50) NULL,
		[Transaction Typ] [varchar](10) NULL,
		[Client Trans. Id] [varchar](50) NULL,
		[Client Asset Type] [varchar](20) NULL,
		[Trade Date] [DATE] NULL,
		[Value Date] [DATE] NULL,
		[Currency] [varchar](10) NULL,
		[Net Amount] [decimal](19, 4) NULL,
		[SSI-First Party Id] [varchar](100) NULL,
		[SSI-First Party Id Code] [varchar](100) NULL,
		[SSI-First Party Misc] [varchar](100) NULL,
		[SSI-Intermediary Party Id] [varchar](10) NOT NULL,
		[SSI-Intermediary Party Id Code] [varchar](100) NULL,
		[SSI-Intermediary Party Misc] [varchar](100) NULL,
		[SSI-Beneficiary Party Id] [varchar](100) NULL,
		[SSI-Beneficiary Party Id Code] [varchar](100) NULL,
		[SSI-Beneficiary Party Misc] [varchar](100) NULL,
		[Further Credit For Account] [varchar](100) NULL,
		[Further Credit For Name] [varchar](100) NULL,
		[Expense Type] [varchar](10)  NULL,
		[SWIFT Narrative] [varchar](10)  NULL,
		[Payment Narrative] [varchar](100) NULL
	)


    BEGIN TRY
	 IF @VcCustodianCode = 'CS'
	 BEGIN
		 SELECT
		 wt.BintWireID AS WireID
		,wt.[DtLastUpdatedTime] AS LastUpdatedOn 
		,wt.VcReferenceNumber AS [Client trade reference number]
		,CASE WHEN wt.VcActionType = 'Withdrawal' THEN 'WD'
				WHEN wt.VcActionType = 'Deposit' THEN 'DP'
			END  AS CrVcActionType --[Transaction Type]
		,crssi.VcAccountType AS CrVcAccountType
		,dbssi.VcAccountType AS DbVcAccountType
		,dbssi.VcFurtherCredit_AccountNo AS DbVcFurtherCredit_AccountNo --[Account Number]
		,crssi.VcFurtherCredit_AccountNo AS CrVcFurtherCredit_AccountNo --[Account Number]
		,'01' AS [Account Type]
		,C.VcCurrencyCode AS [Currency]
		,wt.SinCurrencyID AS [CurrencyID]
		,wt.DecAmount AS [Payment Amount]
		,FORMAT(wt.DtValueDate,'yyyyMMdd') AS [Payment Date]
		,crssi.VcTemplateID AS [Template Name]
		,crssi.VcBenInfo_CounterPartyName AS CrVcBenInfo_CounterPartyName --[Beneficiary Name]
		,dbssi.VcBenInfo_CounterPartyName AS DbVcBenInfo_CounterPartyName --[Beneficiary Name]
		,crssi.VcBenInfo_AccountCode AS CrVcBenInfo_AccountCode --[Beneficiary Account Number]
		,dbssi.VcBenInfo_AccountCode AS DbVcBenInfo_AccountCode --[Beneficiary Account Number]
		,crssi.VcBenInfo_ABA AS CrVcBenInfo_ABA  --[Beneficiary ID (ABA / Sort Code)]
		,dbssi.VcBenInfo_ABA AS DbVcBenInfo_ABA  --[Beneficiary ID (ABA / Sort Code)]
		,crssi.VcBenInfo_SwiftCode AS CrVcBenInfo_SwiftCode  --[Beneficiary BIC]
		,dbssi.VcBenInfo_SwiftCode AS DbVcBenInfo_SwiftCode  --[Beneficiary BIC]
		,crssi.VcAccInst_ABA AS CrVcAccInst_ABA  --[Account with Institution Beneficiary ID (ABA / Sort Code)]
		,dbssi.VcAccInst_ABA AS DbVcAccInst_ABA  --[Account with Institution Beneficiary ID (ABA / Sort Code)]
		,crssi.VcAccInst_BIC AS CrVcAccInst_BIC  --[Account with Institution Beneficiary Bank BIC]
		,dbssi.VcAccInst_BIC AS DbVcAccInst_BIC  --[Account with Institution Beneficiary Bank BIC]
		,crssi.VcAccInsti_AccountCode AS CrVcAccInsti_AccountCode --[Account with Institution Beneficiary Bank Account Number]
		,dbssi.VcAccInsti_AccountCode AS DbVcAccInsti_AccountCode --[Account with Institution Beneficiary Bank Account Number]
		,crssi.VcIntermediaryAccountNo AS CrVcIntermediaryAccountNo --[Intermediary Bank ABA]
		,dbssi.VcIntermediaryAccountNo AS DbVcIntermediaryAccountNo --[Intermediary Bank ABA]
		,crssi.VcIntermediaryClearingCode AS CrVcIntermediaryClearingCode --[Intermediary Bank BIC]
		,dbssi.VcIntermediaryClearingCode AS DbVcIntermediaryClearingCode --[Intermediary Bank BIC]
		,crssi.VcBenInfo_FurhterCredit AS CrVcBenInfo_FurhterCredit --[For Further Credit]
		,dbssi.VcBenInfo_FurhterCredit AS DbVcBenInfo_FurhterCredit --[For Further Credit]
		,crssi.VcFurtherCredit_Reference AS CrVcFurtherCredit_Reference --[Payment Reason]
		,dbssi.VcFurtherCredit_Reference AS DbVcFurtherCredit_Reference --[Payment Reason]
		,'N' AS [Create Template]
		,'N' AS [Transfer To Account]
		,'Y' AS [Third Party]
		,TC.VcCustodianCode
		,TC.IntCustodianID
		,dbssi.IntCustodianAccountID AS DBCustodianAccountID
		,crssi.IntCustodianAccountID AS CRCustodianAccountID
		,TCA.IntCustodianAccountID
		,CASE WHEN TCA.IntCustodianAccountID = dbssi.IntCustodianAccountID THEN 'PAY'
			WHEN TCA.IntCustodianAccountID = crssi.IntCustodianAccountID THEN 'RECEIVE'
			END AS VcWireType
		,ROW_NUMBER() OVER (ORDER BY TC.IntCustodianID) AS ROWNUM
		INTO #VcCustodianCode_CS 
		FROM [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) 
		INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
		INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
		INNER JOIN [cmrf].[TBL_Currency] c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
		INNER JOIN VUCommRef.cmrf.TBL_Custodian_Account TCA WITH ( NOLOCK ) 
		ON (WT.IntDebitCustodianAccount = TCA.IntCustodianAccountID OR WT.IntCreditCustodianAccount = TCA.IntCustodianAccountID)
		INNER JOIN VUCommRef.cmrf.TBL_Custodian TC WITH ( NOLOCK ) ON TCA.IntCustodianID = TC.IntCustodianID
		WHERE TC.VcCustodianCode = @VcCustodianCode
		AND (CONVERT(DATE,wt.DtApprovedDate) = @DtApprovedDate OR  CONVERT(DATE,wt.DtValueDate) = @DtValueDate)
		AND wt.VcWireStatus='Approved' AND wt.VcType = 'WIRE'
		--2016-02-05 -- Added below code for client and portfolio check----------
		AND wt.IntClientDefinitionID = @IntClientId
		AND wt.IntPortfolioid IN (SELECT DATA FROM wr.Split (@VcPortfolioIds,',')) --@VcPortfolioIds

			
		SELECT @ROWNUM=MAX(ROWNUM) FROM #VcCustodianCode_CS
		SET @LOOPNUM = 1

		WHILE (@LOOPNUM<=@ROWNUM)
		BEGIN
			IF EXISTS (SELECT 1 FROM #VcCustodianCode_CS CS
				INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
				INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
				AND CS.IntCustodianAccountID = dbssi.IntCustodianAccountID
				AND CS.DbVcAccountType = 'Prime Broker'
				WHERE ROWNUM = @LOOPNUM
				)
				BEGIN
					--print 'here1.1'
					INSERT INTO #CustodianCode_CS
						SELECT
							 WireID
							,LastUpdatedOn 
							,[Client trade reference number]
							,CrVcActionType AS [Transaction Type]
							--,DbVcAccountType
							,DbVcFurtherCredit_AccountNo AS [Account Number]
							,[Account Type]
							,[Currency]
							,[Payment Amount]
							,[Payment Date]
							,[Template Name]
							,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
							,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
							,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
							,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
							,CrVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
							,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
							,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
							,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
							,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
							,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
							,CrVcFurtherCredit_Reference AS [Payment Reason]
							,[Create Template]
							,[Transfer To Account]
							,[Third Party]
 							FROM #VcCustodianCode_CS
							WHERE ROWNUM = @LOOPNUM

							SET @LOOPNUM = @LOOPNUM+1
					END
				ELSE
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_CS CS
								INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
								INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
								AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
								AND CS.CrVcActionType <> 'WD' AND CS.CrVcAccountType = 'Prime Broker'
								AND CS.DbVcAccountType <> 'Prime Broker'
								INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
								ON CS.IntCustodianID = TWC.IntCustodianId
								INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
								ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
								AND WCAC.IntClientAccountId = TWC.IntClientAccountId
								WHERE ROWNUM = @LOOPNUM
							)
					BEGIN
					--print 'here1.2'
																																				INSERT INTO #CustodianCode_CS
					SELECT
					 WireID
					,LastUpdatedOn 
					,[Client trade reference number]
					,CrVcActionType AS [Transaction Type]
					--,DbVcAccountType
					,DbVcFurtherCredit_AccountNo AS [Account Number]
					,[Account Type]
					,[Currency]
					,[Payment Amount]
					,[Payment Date]
					,[Template Name]
					,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
					,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
					,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
					,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
					,crVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
					,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
					,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
					,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
					,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
					,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
					,CrVcFurtherCredit_Reference AS [Payment Reason]
					,[Create Template]
					,[Transfer To Account]
					,[Third Party]
 					FROM #VcCustodianCode_CS
					WHERE ROWNUM = @LOOPNUM

						SET @LOOPNUM = @LOOPNUM+1
					END
					ELSE
					IF EXISTS (SELECT 1 FROM #VcCustodianCode_CS CS
									INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
									INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
									AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
									--AND CS.CrVcBenInfo_CounterPartyName = crssi.VcBenInfo_CounterPartyName
									AND CS.CrVcActionType = 'WD' AND CS.CrVcAccountType = 'Prime Broker'
									INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
									ON CS.IntCustodianID = TWC.IntCustodianId
									INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
									ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
									AND WCAC.IntClientAccountId = TWC.IntClientAccountId 
									WHERE ROWNUM = @LOOPNUM
					)
					BEGIN
					--print 'here1.1'
					INSERT INTO #CustodianCode_CS
						SELECT
							 WireID
							,LastUpdatedOn 
							,[Client trade reference number]
							,CASE WHEN CrVcActionType = 'WD' THEN 'DP'
									WHEN CrVcActionType = 'DP' THEN 'WD'
								 END AS [Transaction Type]
							--,CrVcAccountType
							,CrVcFurtherCredit_AccountNo AS [Account Number]
							,[Account Type]
							,[Currency]
							,[Payment Amount]
							,[Payment Date]
							,[Template Name]
							,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
							,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
							,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
							,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
							,CrVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
							,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
							,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
							,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
							,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
							,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
							,CrVcFurtherCredit_Reference AS [Payment Reason]
							,[Create Template]
							,[Transfer To Account]
							,[Third Party]
 							FROM #VcCustodianCode_CS
							WHERE ROWNUM = @LOOPNUM

							SET @LOOPNUM = @LOOPNUM+1
					END
					ELSE
					SET @LOOPNUM = @LOOPNUM+1
						IF @LOOPNUM> @ROWNUM 
					BREAK
					END
--print 'here2'
		 SELECT * FROM #CustodianCode_CS
--print 'here2.1'
		
	 END
	 ELSE
	 IF @VcCustodianCode = 'BOA'
	 BEGIN
		SELECT 
			 wt.BintWireID AS WireID
			,wt.[DtLastUpdatedTime] AS LastUpdatedOn
			,dbssi.VcFurtherCredit_AccountNo AS [DbVcFurtherCredit_AccountNo] --[PB Acct. No]
			,crssi.VcFurtherCredit_AccountNo AS [CrVcFurtherCredit_AccountNo] --[PB Acct. No]
			,'' AS [PB Type]
			,'' AS [Trading Unit]
			,'' AS [Trading Sub-Unit]
			,'N' AS [Record Typ]
			,CASE WHEN wt.VcActionType = 'Withdrawal' THEN 'WD'--'MWWD'
					WHEN wt.VcActionType = 'Deposit' THEN 'DP'--'MWDP'
			 END  AS CrVcActionType --[Transaction Type]
			,crssi.VcAccountType AS CrVcAccountType
			,dbssi.VcAccountType AS DbVcAccountType
			,wt.VcReferenceNumber
			,'CA' AS [Client Asset Type]
			,wt.DtCreatedDate AS [Trade Date]
			,wt.DtValueDate AS [Value Date]
			,C.VcCurrencyCode AS [Currency]
			,wt.SinCurrencyID AS [CurrencyID]
			,wt.DecAmount AS [Net Amount]
			,crssi.VcAccInsti_AccountCode AS CrVcAccInsti_AccountCode -- [SSI-First Party Id]
			,dbssi.VcAccInsti_AccountCode AS DbVcAccInsti_AccountCode -- [SSI-First Party Id]
			,ISNULL(crssi.VcAccInst_ABA,crssi.VcAccInst_BIC) AS [CrVcAccInst_ABA_BIC] --[SSI-First Party Id Code]
			,ISNULL(dbssi.VcAccInst_ABA,dbssi.VcAccInst_BIC) AS [DbVcAccInst_ABA_BIC] --[SSI-First Party Id Code]
			,crssi.VcAccInsti_BenfBank AS CrVcAccInsti_BenfBank --[SSI-First Party Misc]
			,crssi.VcAccInsti_BenfBank AS DbVcAccInsti_BenfBank --[SSI-First Party Misc]
			,'' AS [SSI-Intermediary Party Id]
			,ISNULL(crssi.VcIntermediaryClearingCode,crssi.VcIntermediaryAccountNo) AS [CrVcIntermediaryClearingCode_AccountNo]--[SSI-Intermediary Party Id Code]
			,ISNULL(dbssi.VcIntermediaryClearingCode,dbssi.VcIntermediaryAccountNo) AS [DbVcIntermediaryClearingCode_AccountNo]--[SSI-Intermediary Party Id Code]
			,crssi.VcIntermediaryBank AS CrVcIntermediaryBank  --[SSI-Intermediary Party Misc]
			,dbssi.VcIntermediaryBank AS DbVcIntermediaryBank  --[SSI-Intermediary Party Misc]
			,crssi.VcBenInfo_AccountCode AS CrVcBenInfo_AccountCode  --[SSI-Beneficiary Party Id]
			,dbssi.VcBenInfo_AccountCode AS DbVcBenInfo_AccountCode  --[SSI-Beneficiary Party Id]
			,ISNULL(crssi.VcBenInfo_ABA,crssi.VcBenInfo_SwiftCode) AS CrVcBenInfo_ABA_SwiftCode --[SSI-Beneficiary Party Id Code]
			,ISNULL(dbssi.VcBenInfo_ABA,dbssi.VcBenInfo_SwiftCode) AS DbVcBenInfo_ABA_SwiftCode --[SSI-Beneficiary Party Id Code]
			,crssi.VcBenInfo_CounterPartyName AS CrVcBenInfo_CounterPartyName  --[SSI-Beneficiary Party Misc]
			,dbssi.VcBenInfo_CounterPartyName AS DbVcBenInfo_CounterPartyName  --[SSI-Beneficiary Party Misc]
			,crssi.VcFurtherCredit_AccountNo AS [CrFurther Credit For Account]  --[Further Credit For Account]
			,dbssi.VcFurtherCredit_AccountNo AS [DbFurther Credit For Account]  --[Further Credit For Account]
			,crssi.VcBenInfo_FurhterCredit AS CrVcBenInfo_FurhterCredit --[Further Credit For Name]
			,dbssi.VcBenInfo_FurhterCredit AS DbVcBenInfo_FurhterCredit --[Further Credit For Name]
			,'MS' AS [Expense Type]	
			,'' AS [SWIFT Narrative]
			,crssi.VcFurtherCredit_Reference AS [Payment Narrative]
			,TC.VcCustodianCode
			,TC.IntCustodianID
			,dbssi.IntCustodianAccountID AS DBCustodianAccountID
			,crssi.IntCustodianAccountID AS CRCustodianAccountID
			,TCA.IntCustodianAccountID
			,CASE WHEN TCA.IntCustodianAccountID = dbssi.IntCustodianAccountID THEN 'PAY'
				WHEN TCA.IntCustodianAccountID = crssi.IntCustodianAccountID THEN 'RECEIVE'
			 END AS VcWireType
			,ROW_NUMBER() OVER (ORDER BY TC.IntCustodianID) AS ROWNUM
			INTO #VcCustodianCode_BOA 
		FROM [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) 
			INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
			INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
			INNER JOIN [cmrf].[TBL_Currency] c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
			INNER JOIN VUCommRef.cmrf.TBL_Custodian_Account TCA WITH ( NOLOCK ) 
			ON (WT.IntDebitCustodianAccount = TCA.IntCustodianAccountID OR WT.IntCreditCustodianAccount = TCA.IntCustodianAccountID)
			INNER JOIN VUCommRef.cmrf.TBL_Custodian TC WITH ( NOLOCK ) ON TCA.IntCustodianID = TC.IntCustodianID
			WHERE TC.VcCustodianCode = @VcCustodianCode
			AND (CONVERT(DATE,wt.DtApprovedDate) = @DtApprovedDate OR  CONVERT(DATE,wt.DtValueDate) = @DtValueDate)
			AND wt.VcWireStatus='Approved'AND wt.VcType = 'WIRE'
			--2016-02-05 -- Added below code for client and portfolio check----------
			AND wt.IntClientDefinitionID = @IntClientId
			AND wt.IntPortfolioid IN (SELECT DATA FROM wr.Split (@VcPortfolioIds,',')) --@VcPortfolioIds
		
		SELECT @ROWNUM=MAX(ROWNUM) FROM #VcCustodianCode_BOA
		SET @LOOPNUM = 1
		
		WHILE (@LOOPNUM<=@ROWNUM)
			BEGIN
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_BOA CS
								INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
								INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
								AND CS.IntCustodianAccountID = dbssi.IntCustodianAccountID
								AND CS.DbVcAccountType = 'Prime Broker'
								WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_BOA
						SELECT
						 WireID
						,LastUpdatedOn 
						,[DbVcFurtherCredit_AccountNo] AS [PB Acct. No]
						,[PB Type]
						,[Trading Unit]
						,[Trading Sub-Unit]
						,[Record Typ]
						--,DbVcAccountType
						,CrVcActionType AS [Transaction Type]
						,VcReferenceNumber AS [Client Trans. Id]
						,[Client Asset Type]
						,[Trade Date]
						,[Value Date]
						,[Currency]
						,[Net Amount]
						,CrVcAccInsti_AccountCode AS [SSI-First Party Id]
						,[CrVcAccInst_ABA_BIC] AS [SSI-First Party Id Code]
						,CrVcAccInsti_AccountCode AS [SSI-First Party Misc]
						,[SSI-Intermediary Party Id]
						,[CrVcIntermediaryClearingCode_AccountNo] AS [SSI-Intermediary Party Id Code]
						,CrVcIntermediaryBank AS [SSI-Intermediary Party Misc]
						,CrVcBenInfo_AccountCode AS [SSI-Beneficiary Party Id]
						,CrVcBenInfo_ABA_SwiftCode AS [SSI-Beneficiary Party Id Code]
						,CrVcBenInfo_CounterPartyName AS [SSI-Beneficiary Party Misc]
						,CrVcFurtherCredit_AccountNo AS [Further Credit For Account]
						,CrVcBenInfo_FurhterCredit AS [Further Credit For Name]
						,[Expense Type]
						,[SWIFT Narrative]
						,[Payment Narrative]
 						FROM #VcCustodianCode_BOA
						WHERE ROWNUM = @LOOPNUM

						SET @LOOPNUM = @LOOPNUM+1
					END

				ELSE
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_BOA CS
									INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
									INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
									AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
									AND CS.CrVcActionType <> 'WD' AND CS.CrVcAccountType = 'Prime Broker'
									AND CS.DbVcAccountType <> 'Prime Broker'
									INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
									ON CS.IntCustodianID = TWC.IntCustodianId
									INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
									ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
									AND WCAC.IntClientAccountId = TWC.IntClientAccountId 
									WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_BOA
						SELECT
								WireID
							,LastUpdatedOn 
							,[DbVcFurtherCredit_AccountNo] AS [PB Acct. No]
							,[PB Type]
							,[Trading Unit]
							,[Trading Sub-Unit]
							,[Record Typ]
							--,DbVcAccountType
							,CrVcActionType AS [Transaction Type]
							,VcReferenceNumber AS [Client Trans. Id]
							,[Client Asset Type]
							,[Trade Date]
							,[Value Date]
							,[Currency]
							,[Net Amount]
							,CrVcAccInsti_AccountCode AS [SSI-First Party Id]
							,[CrVcAccInst_ABA_BIC] AS [SSI-First Party Id Code]
							,crVcAccInsti_AccountCode AS [SSI-First Party Misc]
							,[SSI-Intermediary Party Id]
							,[CrVcIntermediaryClearingCode_AccountNo] AS [SSI-Intermediary Party Id Code]
							,CrVcIntermediaryBank AS [SSI-Intermediary Party Misc]
							,CrVcBenInfo_AccountCode AS [SSI-Beneficiary Party Id]
							,CrVcBenInfo_ABA_SwiftCode AS [SSI-Beneficiary Party Id Code]
							,CrVcBenInfo_CounterPartyName AS [SSI-Beneficiary Party Misc]
							,CrVcFurtherCredit_AccountNo AS [Further Credit For Account]
							,CrVcBenInfo_FurhterCredit AS [Further Credit For Name]
							,[Expense Type]
							,[SWIFT Narrative]
							,[Payment Narrative]
 						FROM #VcCustodianCode_BOA
						WHERE ROWNUM = @LOOPNUM

						SET @LOOPNUM = @LOOPNUM+1
					END
					ELSE
					IF EXISTS (SELECT 1 FROM #VcCustodianCode_BOA CS
								INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
								INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
								AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
								AND CS.CrVcActionType = 'WD' AND CS.CrVcAccountType = 'Prime Broker'
								INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
								ON CS.IntCustodianID = TWC.IntCustodianId
								INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
								ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
								AND WCAC.IntClientAccountId = TWC.IntClientAccountId 
								WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_BOA
						SELECT
						 WireID
						,LastUpdatedOn 
						,[CrVcFurtherCredit_AccountNo] AS [PB Acct. No]
						,[PB Type]
						,[Trading Unit]
						,[Trading Sub-Unit]
						,[Record Typ]
						--,CrVcAccountType
						,CASE WHEN CrVcActionType = 'WD' THEN 'DP'
							WHEN CrVcActionType = 'DP' THEN 'WD'
						 END AS [Transaction Type]
						,VcReferenceNumber AS [Client Trans. Id]
						,[Client Asset Type]
						,[Trade Date]
						,[Value Date]
						,[Currency]
						,[Net Amount]
						,CrVcAccInsti_AccountCode AS [SSI-First Party Id]
						,[CrVcAccInst_ABA_BIC] AS [SSI-First Party Id Code]
						,CrVcAccInsti_AccountCode AS [SSI-First Party Misc]
						,[SSI-Intermediary Party Id]
						,[CrVcIntermediaryClearingCode_AccountNo] AS [SSI-Intermediary Party Id Code]
						,CrVcIntermediaryBank AS [SSI-Intermediary Party Misc]
						,CrVcBenInfo_AccountCode AS [SSI-Beneficiary Party Id]
						,CrVcBenInfo_ABA_SwiftCode AS [SSI-Beneficiary Party Id Code]
						,CrVcBenInfo_CounterPartyName AS [SSI-Beneficiary Party Misc]
						,CrVcFurtherCredit_AccountNo AS [Further Credit For Account]
						,CrVcBenInfo_FurhterCredit AS [Further Credit For Name]
						,[Expense Type]
						,[SWIFT Narrative]
						,[Payment Narrative]
 						FROM #VcCustodianCode_BOA
						WHERE ROWNUM = @LOOPNUM

						SET @LOOPNUM = @LOOPNUM+1
					END
					ELSE
						SET @LOOPNUM = @LOOPNUM+1
						IF @LOOPNUM> @ROWNUM 
						BREAK
				END
				SELECT * FROM #CustodianCode_BOA

	END
	 ELSE 
	 BEGIN
	 --PRINT (@VcCustodianCode+ 'STARTED')
		SELECT
			 wt.BintWireID AS WireID
			,wt.[DtLastUpdatedTime] AS LastUpdatedOn  
			,wt.VcReferenceNumber AS [Client trade reference number]
			,CASE WHEN wt.VcActionType = 'Withdrawal' THEN 'WD'
					WHEN wt.VcActionType = 'Deposit' THEN 'DP'
			 END  AS CrVcActionType --[Transaction Type]
			,crssi.VcAccountType AS CrVcAccountType
			,dbssi.VcAccountType AS DbVcAccountType
			,dbssi.VcFurtherCredit_AccountNo AS DbVcFurtherCredit_AccountNo --[Account Number]
			,crssi.VcFurtherCredit_AccountNo AS CrVcFurtherCredit_AccountNo --[Account Number]
			,'01' AS [Account Type]
			,C.VcCurrencyCode AS [Currency]
			,wt.SinCurrencyID AS [CurrencyID]
			,wt.DecAmount AS [Payment Amount]
			,FORMAT(wt.DtValueDate,'yyyyMMdd') AS [Payment Date]
			,crssi.VcTemplateID AS [Template Name]
			,crssi.VcBenInfo_CounterPartyName AS CrVcBenInfo_CounterPartyName --[Beneficiary Name]
			,dbssi.VcBenInfo_CounterPartyName AS DbVcBenInfo_CounterPartyName --[Beneficiary Name]
			,crssi.VcBenInfo_AccountCode AS CrVcBenInfo_AccountCode --[Beneficiary Account Number]
			,dbssi.VcBenInfo_AccountCode AS DbVcBenInfo_AccountCode --[Beneficiary Account Number]
			,crssi.VcBenInfo_ABA AS CrVcBenInfo_ABA  --[Beneficiary ID (ABA / Sort Code)]
			,dbssi.VcBenInfo_ABA AS DbVcBenInfo_ABA  --[Beneficiary ID (ABA / Sort Code)]
			,crssi.VcBenInfo_SwiftCode AS CrVcBenInfo_SwiftCode  --[Beneficiary BIC]
			,dbssi.VcBenInfo_SwiftCode AS DbVcBenInfo_SwiftCode  --[Beneficiary BIC]
			,crssi.VcAccInst_ABA AS CrVcAccInst_ABA  --[Account with Institution Beneficiary ID (ABA / Sort Code)]
			,dbssi.VcAccInst_ABA AS DbVcAccInst_ABA  --[Account with Institution Beneficiary ID (ABA / Sort Code)]
			,crssi.VcAccInst_BIC AS CrVcAccInst_BIC  --[Account with Institution Beneficiary Bank BIC]
			,dbssi.VcAccInst_BIC AS DbVcAccInst_BIC  --[Account with Institution Beneficiary Bank BIC]
			,crssi.VcAccInsti_AccountCode AS CrVcAccInsti_AccountCode --[Account with Institution Beneficiary Bank Account Number]
			,dbssi.VcAccInsti_AccountCode AS DbVcAccInsti_AccountCode --[Account with Institution Beneficiary Bank Account Number]
			,crssi.VcIntermediaryAccountNo AS CrVcIntermediaryAccountNo --[Intermediary Bank ABA]
			,dbssi.VcIntermediaryAccountNo AS DbVcIntermediaryAccountNo --[Intermediary Bank ABA]
			,crssi.VcIntermediaryClearingCode AS CrVcIntermediaryClearingCode --[Intermediary Bank BIC]
			,dbssi.VcIntermediaryClearingCode AS DbVcIntermediaryClearingCode --[Intermediary Bank BIC]
			,crssi.VcBenInfo_FurhterCredit AS CrVcBenInfo_FurhterCredit --[For Further Credit]
			,dbssi.VcBenInfo_FurhterCredit AS DbVcBenInfo_FurhterCredit --[For Further Credit]
			,crssi.VcFurtherCredit_Reference AS CrVcFurtherCredit_Reference --[Payment Reason]
			,dbssi.VcFurtherCredit_Reference AS DbVcFurtherCredit_Reference --[Payment Reason]
			,'N' AS [Create Template]
			,'N' AS [Transfer To Account]
			,'Y' AS [Third Party]
			,TC.VcCustodianCode
			,TC.IntCustodianID
			,dbssi.IntCustodianAccountID AS DBCustodianAccountID
			,crssi.IntCustodianAccountID AS CRCustodianAccountID
			,TCA.IntCustodianAccountID
			,CASE WHEN TCA.IntCustodianAccountID = dbssi.IntCustodianAccountID THEN 'PAY'
				WHEN TCA.IntCustodianAccountID = crssi.IntCustodianAccountID THEN 'RECEIVE'
			 END AS VcWireType
			,ROW_NUMBER() OVER (ORDER BY TC.IntCustodianID) AS ROWNUM
			INTO #VcCustodianCode_Others 
			FROM [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) 
			INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
			INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
			INNER JOIN [cmrf].[TBL_Currency] c WITH ( NOLOCK ) ON wt.SinCurrencyID = c.SinCurrencyID
			INNER JOIN VUCommRef.cmrf.TBL_Custodian_Account TCA WITH ( NOLOCK ) 
			ON (WT.IntDebitCustodianAccount = TCA.IntCustodianAccountID OR WT.IntCreditCustodianAccount = TCA.IntCustodianAccountID)
			INNER JOIN VUCommRef.cmrf.TBL_Custodian TC WITH ( NOLOCK ) ON TCA.IntCustodianID = TC.IntCustodianID
			WHERE TC.VcCustodianCode = @VcCustodianCode
			AND (CONVERT(DATE,wt.DtApprovedDate) = @DtApprovedDate OR  CONVERT(DATE,wt.DtValueDate) = @DtValueDate)
			AND wt.VcWireStatus='Approved'AND wt.VcType = 'WIRE'
			--2016-02-05 -- Added below code for client and portfolio check----------
			AND wt.IntClientDefinitionID = @IntClientId
			AND wt.IntPortfolioid IN (SELECT DATA FROM wr.Split (@VcPortfolioIds,',')) --@VcPortfolioIds
			
			--SELECT * from #VcCustodianCode_Others
			SELECT @ROWNUM=MAX(ROWNUM) FROM #VcCustodianCode_Others
			SET @LOOPNUM = 1

			WHILE (@LOOPNUM<=@ROWNUM)
				BEGIN
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_Others CS
								INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
								INNER JOIN [wr].[TBL_SSI] dbssi WITH ( NOLOCK ) ON wt.IntDebitSSID = dbssi.IntID
								AND CS.IntCustodianAccountID = dbssi.IntCustodianAccountID
								AND CS.DbVcAccountType = 'Prime Broker'
								WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_CS
						SELECT
						 WireID
						,LastUpdatedOn
						,[Client trade reference number]
						,CrVcActionType AS [Transaction Type]
						--,DbVcAccountType
						,DbVcFurtherCredit_AccountNo AS [Account Number]
						,[Account Type]
						,[Currency]
						,[Payment Amount]
						,[Payment Date]
						,[Template Name]
						,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
						,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
						,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
						,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
						,CrVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
						,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
						,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
						,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
						,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
						,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
						,CrVcFurtherCredit_Reference AS [Payment Reason]
						,[Create Template]
						,[Transfer To Account]
						,[Third Party]
 						FROM #VcCustodianCode_Others
						WHERE ROWNUM = @LOOPNUM
						
						SET @LOOPNUM = @LOOPNUM+1
						
					END
				ELSE
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_Others CS
									INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
									INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
									AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
									AND CS.CrVcActionType <> 'WD' AND CS.CrVcAccountType = 'Prime Broker'
									AND CS.DbVcAccountType <> 'Prime Broker'
									INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
									ON CS.IntCustodianID = TWC.IntCustodianId
									INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
									ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
									AND WCAC.IntClientAccountId = TWC.IntClientAccountId 
									WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_CS
						SELECT
						 WireID
						,LastUpdatedOn
						,[Client trade reference number]
						,CrVcActionType AS [Transaction Type]
						--,DbVcAccountType
						,DbVcFurtherCredit_AccountNo AS [Account Number]
						,[Account Type]
						,[Currency]
						,[Payment Amount]
						,[Payment Date]
						,[Template Name]
						,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
						,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
						,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
						,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
						,CrVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
						,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
						,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
						,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
						,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
						,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
						,CrVcFurtherCredit_Reference AS [Payment Reason]
						,[Create Template]
						,[Transfer To Account]
						,[Third Party]
 						FROM #VcCustodianCode_Others
						WHERE ROWNUM = @LOOPNUM

						SET @LOOPNUM = @LOOPNUM+1
						
					END
				ELSE
				IF EXISTS (SELECT 1 FROM #VcCustodianCode_Others CS
									INNER JOIN [wr].[TBL_WireTransfer] wt WITH ( NOLOCK ) ON CS.WireID = wt.BintWireID 
									INNER JOIN [wr].[TBL_SSI] crssi WITH ( NOLOCK ) ON wt.IntCreditSSID = crssi.IntID
									AND CS.IntCustodianAccountID = crssi.IntCustodianAccountID
									AND CS.CrVcActionType = 'WD' AND CS.CrVcAccountType = 'Prime Broker'
									INNER JOIN [VUWireTransfer].[wr].[TBL_WireClientAccount] TWC WITH (NOLOCK)
									ON CS.IntCustodianID = TWC.IntCustodianId
									INNER JOIN  [wr].[TBL_WireClientAccountCurrencyList] WCAC WITH (NOLOCK)
									ON CS.CurrencyID = WCAC.SinCurrencyID AND CS.CurrencyID = wt.SinCurrencyID
									AND WCAC.IntClientAccountId = TWC.IntClientAccountId 
									WHERE ROWNUM = @LOOPNUM
								)
					BEGIN
						INSERT INTO #CustodianCode_CS
						SELECT 
						 WireID
						,LastUpdatedOn
						,[Client trade reference number]
						,CASE WHEN CrVcActionType = 'WD' THEN 'DP'
							WHEN CrVcActionType = 'DP' THEN 'WD'
						 END AS [Transaction Type]
						--,CrVcAccountType
						,CrVcFurtherCredit_AccountNo AS [Account Number]
						,[Account Type]
						,[Currency]
						,[Payment Amount]
						,[Payment Date]
						,[Template Name]
						,CrVcBenInfo_CounterPartyName AS [Beneficiary Name]
						,CrVcBenInfo_AccountCode AS [Beneficiary Account Number]
						,CrVcBenInfo_ABA AS [Beneficiary ID (ABA / Sort Code)]
						,CrVcBenInfo_SwiftCode AS [Beneficiary BIC]
						,CrVcAccInst_ABA AS [Account with Institution Beneficiary ID (ABA / Sort Code)]
						,CrVcAccInst_BIC AS [Account with Institution Beneficiary Bank BIC]
						,CrVcAccInsti_AccountCode AS [Account with Institution Beneficiary Bank Account Number]
						,CrVcIntermediaryAccountNo AS [Intermediary Bank ABA]
						,CrVcIntermediaryClearingCode AS [Intermediary Bank BIC]
						,CrVcBenInfo_FurhterCredit + ' ' + Convert(varchar(100),CrVcFurtherCredit_AccountNo) AS [For Further Credit]
						,CrVcFurtherCredit_Reference AS [Payment Reason]
						,[Create Template]
						,[Transfer To Account]
						,[Third Party]
 						FROM #VcCustodianCode_Others
						WHERE ROWNUM = @LOOPNUM
					
						SET @LOOPNUM = @LOOPNUM+1
						
					END
				ELSE
				SET @LOOPNUM = @LOOPNUM+1
					IF @LOOPNUM> @ROWNUM 
				BREAK
			  END
		 SELECT * FROM #CustodianCode_CS
		 --print 'here3'
	END
END TRY
BEGIN CATCH
    EXEC [err].[STP_LogError];
END CATCH;        

/*

USE [VUWireTransfer]
GO
EXECUTE  [wr].[STP_PBReports]
@VcCustodianCode = 'CS', 
 @VcApprovedDate = '2016-02-02',
	  @VcValueDate =NULL
-------------------------------------------------
EXECUTE  [wr].[STP_PBReports]
@VcCustodianCode = 'Geneva Report', 
 @VcApprovedDate = NULL,
	  @VcValueDate ='11/25/2015'
-------------------------------------------------
EXECUTE  [wr].[STP_PBReports]
@VcCustodianCode = 'Package Report', 
 @VcApprovedDate = '11/25/2015',
	  @VcValueDate =null
SELECT * FROM WR.TBL_WIRETRANSFER

EXECUTE  [wr].[STP_PBReports_1]
@VcCustodianCode = 'cs', 
 @VcApprovedDate = NULL,
	  @VcValueDate ='2016-01-17'
	  EXECUTE  [wr].[STP_PBReports]
@VcCustodianCode = 'DRUY', 
 @VcApprovedDate = NULL,
	  @VcValueDate ='2016-01-28'

----SELECT IntCustodianId,* FROM [VUWireTransfer].[wr].[TBL_WireClientAccount] WITH (NOLOCK)
--select * from wr.TBL_WireTransfer where DtValueDate = '2016-01-05'
--select * from wr.TBL_SSI where IntID in (22,23)
--select * from VUCommRef.cmrf.TBL_Custodian_Account where IntCustodianAccountID in (313,318)
--select * from VUCommRef.cmrf.TBL_Custodian where IntCustodianID in (146,12)

EXECUTE  [wr].[STP_PBReports]
@VcCustodianCode = 'CS', 
@VcApprovedDate = '2016-02-08',
@VcValueDate =NULL,
@IntClientId = 40,
@VcPortfolioIds = '37'
*/

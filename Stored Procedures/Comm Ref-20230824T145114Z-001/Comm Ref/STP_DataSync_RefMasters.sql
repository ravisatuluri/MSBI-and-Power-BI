--USE [VUCommRef]
--GO

ALTER procedure [cmrf].[STP_DataSync_RefMasters]
(
	@master_name		VARCHAR(20),
------------------Common Columns----------------
	@success			INT				OUTPUT,
	@error_message		VARCHAR(1000)	OUTPUT
------------------Common Columns----------------
)
AS
DECLARE @IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
		SET NOCOUNT ON
		IF @master_name='CLIENT'
		BEGIN
			MERGE INTO [cmrf].[tbl_Client] AS T 
			USING [cmrf].[TBL_UAT_VW_Clients] AS S
			ON T.[VcClientShortCode]=S.[vcClientShortCode] 
			WHEN MATCHED THEN
			UPDATE 
			SET	T.[VcClientName]	=S.[vcClientName],
				T.[BitIsActive]		=S.[chrIS_Active],
				T.[DtActiveFrom]	=S.[dtActiveFrom],
				T.[DtActiveTo]		=S.[dtActiveTo]
			WHEN NOT MATCHED THEN
			INSERT ([VcClientShortCode],[VcClientName],[BitIsActive],[DtActiveFrom],[DtActiveTo])
			VALUES (S.[vcClientShortCode],S.[vcClientName],S.[chrIS_Active],S.[dtActiveFrom],S.[dtActiveTo]);
		END	
		IF @master_name='FUNDFAMILY'
		BEGIN
			IF OBJECT_ID('tempdb..#FUNDFAMILY') IS NOT NULL DROP TABLE #FUNDFAMILY;
			WITH CTE AS
			(
				SELECT [vcClientCode] = (SELECT vcClientShortCode FROM [cmrf].[TBL_UAT_VW_Clients] WITH(NOLOCK) WHERE intClient = f.intClient),*
				FROM setup.tbl_fundfamily f WITH(NOLOCK)
			)
			SELECT B.IntClientDefinitionID,a.*
			INTO #FUNDFAMILY
			FROM CTE A 
			INNER JOIN CMRF.TBL_Client B WITH(NOLOCK) ON A.vcClientCode=B.VcClientShortCode
			MERGE INTO [cmrf].TBL_FundFamily AS T 
			USING #FUNDFAMILY AS S
			ON T.[VcFundFamilyCode]=LEFT(S.[vcfundFamily],20)
			WHEN MATCHED THEN
			UPDATE 
			SET	T.IntClientDefinitionID		=S.[IntClientDefinitionID],
				T.[VcFundFamilyName]		= S.[vcfundFamily]
			WHEN NOT MATCHED THEN
			INSERT ([IntClientDefinitionID],[VcFundFamilyCode],[VcFundFamilyName],[BitIsActive])
			VALUES (S.[IntClientDefinitionID],LEFT(S.[vcfundFamily],20),S.[vcfundFamily],1);
		END
		IF @master_name='PORTFOLIO'
		BEGIN
			IF OBJECT_ID('tempdb..#PORTFOLIO') IS NOT NULL DROP TABLE #PORTFOLIO;
			WITH CTE AS
			(
				SELECT [vcClientCode]= (SELECT vcClientShortCode FROM [cmrf].[TBL_UAT_VW_Clients] WITH(NOLOCK) WHERE intClient = p.intClient),
				[vcFundFamilyCode]= (SELECT LEFT(vcfundFamily,20) FROM setup.tbl_fundfamily WITH(NOLOCK) WHERE intFundFamilyID = p.intFundFamilyID),*
				FROM setup.tbl_PortfolioNames p WITH(NOLOCK)
			)
			SELECT B.IntClientDefinitionID,F.IntFundFamilyID IntFundFamilyID_VU,a.*
			INTO #PORTFOLIO
			FROM CTE A 
			INNER JOIN CMRF.TBL_Client B WITH(NOLOCK) ON A.vcClientCode=B.VcClientShortCode
			INNER JOIN CMRF.TBL_FundFamily F WITH(NOLOCK) ON F.VcFundFamilyCode=A.[vcFundFamilyCode]
			MERGE INTO [cmrf].[tbl_Portfolio] AS T 
			USING #PORTFOLIO AS S
			ON T.[VcPortfolioName]=S.[vcPortfolioName] AND T.[IntFundFamilyID] = S.[IntFundFamilyID_VU]
			WHEN MATCHED THEN
			UPDATE 
			SET	T.IntClientDefinitionID		=S.IntClientDefinitionID,
				T.[VcPortfolioName]			= S.vcPortfolioName,
				T.[BitIsActive]				= S.isActive,
				T.[VcCollateralOwnership]	= S.vcCollateralOwnership
			WHEN NOT MATCHED THEN
			INSERT (IntClientDefinitionID,IntFundFamilyID, VcPortfolioShortCode,VcPortfolioName,BitIsActive,VcCollateralOwnership,VcFundDomicile,VcUnitizedOrNonUnitized,
					VcFundType,DtIncorporationOrFormationDate,DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate,VcOpenOrClosedEnded,VShareDecimalsForCalculations,
					VcShareDecimalsDisplay,VcNAVDecimalsForCalculation,VcNAVDecimalsDisplay,VcInvestmentStrategy,VcCity,VcSharePartnerClassID,VcSharePartnerClassDescription)
			VALUES	(S.IntClientDefinitionID,S.IntFundFamilyID_VU, S.[vcPortFolioShortCode],S.vcPortfolioName,S.isActive,S.vcCollateralOwnership,'','',
					'Fund',GETDATE(),GETDATE(),'','','','','','','','','');
		END
		IF @master_name='CUSTODIAN'
		BEGIN
			MERGE INTO [cmrf].[TBL_Custodian] AS T 
			USING setup.tbl_Custodian AS S
			ON T.[VcCustodianCode]=S.[vcCustodianCode] 
			WHEN MATCHED THEN
			UPDATE 
			SET	T.[VcCustodianName]		= S.[vcCustodianName1],
				T.[VcSalutation]		= S.[vcSalutation],
				T.[BitIsActive]			= S.[bitIsActive],
				T.[VcCity]				= S.[vcCity],
				T.[VcState]				= S.[vcState],
				T.[VcPostalCode]		= S.[vcPostalCode],
				T.[VcCountry]			= S.[vcCountry],
				T.[VcContactEmail]		= S.[vcEmail],
				T.[VcTelephoneNumber1]	= S.[vcTelephone1],
				T.[VcTelephoneNumber2]	= S.[vcTelephone2],
				T.[VcAddressLine1]		= S.[vcAddress1],
				T.[VcAddressLine2]		= S.[vcAddress2]
			WHEN NOT MATCHED THEN
			INSERT ([VcCustodianCode],[VcCustodianName],[VcSalutation],[BitIsActive],[VcCity],[VcState],[VcPostalCode],[VcCountry],[VcContactEmail],[VcTelephoneNumber1],[VcTelephoneNumber2],[VcAddressLine1],[VcAddressLine2])
			VALUES (S.[vcCustodianCode],S.[vcCustodianName1],S.[vcSalutation],S.[bitIsActive],S.[vcCity],S.[vcState],S.[vcPostalCode],S.[vcCountry],S.[vcEmail],S.[vcTelephone1],S.[vcTelephone2],S.[vcAddress1],S.[vcAddress2]);
		END
		IF @master_name='CUSTODIANACCOUNT'
		BEGIN
			IF OBJECT_ID('tempdb..#CUSTODIANACCOUNT') IS NOT NULL DROP TABLE #CUSTODIANACCOUNT;
			WITH CTE AS
			(
				SELECT DISTINCT c.vcClientShortCode, cus.vcCustodianCode , CA.*
				FROM setup.tbl_CustodianAccount CA WITH(NOLOCK)
				INNER JOIN setup.tbl_Portfolio_CustodianAccount_Link CAL WITH(NOLOCK) ON CAL.intCustodianAccountID=CA.IntCustodianAccountID
				INNER JOIN setup.tbl_PortfolioNames p WITH(NOLOCK) ON p.intPortfolioID = CAL.intPortfolioID
				INNER JOIN setup.tbl_Custodian cus WITH(NOLOCK) ON cus.intCustodianID = CA.intCustodianID
				INNER JOIN [cmrf].[TBL_UAT_VW_Clients] c WITH(NOLOCK) ON c.intClient = p.intClient
			)
			SELECT B.IntClientDefinitionID AS IntClientDefinitionID_VU,C.intCustodianID AS intCustodianID_VU, a.*
			INTO #CUSTODIANACCOUNT
			FROM CTE A 
			INNER JOIN CMRF.TBL_Client B ON A.vcClientShortCode=B.VcClientShortCode
			INNER JOIN cmrf.TBL_Custodian C ON C.VcCustodianCode = A.vcCustodianCode
			MERGE INTO CMRF.TBL_Custodian_Account AS T 
			USING #CUSTODIANACCOUNT AS S
			ON T.[VcCustodianAccountCode]=S.[vcCustodianAccountCode] 
			WHEN MATCHED THEN
			UPDATE 
			SET	T.[IntCustodianID]			= S.[intCustodianID_VU],
				T.[IntClientDefinitionID]	= S.[IntClientDefinitionID_VU],
				T.[VcCustodianAccountName]	= S.[vcCustodianAccountName1],
				T.[VcSalutation]			= S.[vcSalutation],
				T.[BitIsActive]				= S.[bitIsActive],
				T.[VcAddress]				= S.[vcAddress1],
				T.[VcCity]					= S.[vcCity],
				T.[VcState]					= S.[vcState],
				T.[VcPostalCode]			= S.[vcPostalCode],
				T.[VcCountry]				= S.[vcCountry],
				T.[VcTelephoneNumber]		= S.[vcTelephone1],
				T.[VcContactEmail]			= S.[vcEmail],
				T.[VcAccountType]			= S.[TypeofAccount]
			WHEN NOT MATCHED THEN
			INSERT ([VcCustodianAccountCode],[IntCustodianID],[IntClientDefinitionID],[VcCustodianAccountName],[VcSalutation],[BitIsActive],[VcAddress],[VcCity],[VcState],[VcPostalCode],[VcCountry],[VcTelephoneNumber],[VcContactEmail],[VcAccountType])
			VALUES (S.[vcCustodianAccountCode],S.[intCustodianID_VU],S.[IntClientDefinitionID_VU],S.[vcCustodianAccountName1],S.[vcSalutation],S.[bitIsActive],S.[vcAddress1],S.[vcCity],S.[vcState],S.[vcPostalCode],S.[vcCountry],S.[vcTelephone1],S.[vcEmail],S.[TypeofAccount]);
			MERGE INTO [cmrf].[TBL_CustodianAccountPortfolioLink] T
			USING (SELECT DISTINCT VB.INTPORTFOLIOID ,VC.INTCUSTODIANACCOUNTID FROM [setup].[tbl_Portfolio_CustodianAccount_Link] A WITH(NOLOCK)
			INNER JOIN [setup].[tbl_portfolionames] B  WITH(NOLOCK) ON A.INTPORTFOLIOID=B.INTPORTFOLIOID
			INNER JOIN [setup].[tbl_CustodianAccount] C WITH(NOLOCK) ON A.INTCUSTODIANACCOUNTID=C.INTCUSTODIANACCOUNTID
			INNER JOIN CMRF.TBL_PORTFOLIO VB WITH(NOLOCK) ON B.vcPortFolioShortCode=VB.vcPortFolioShortCode
			INNER JOIN [cmrf].[TBL_Custodian_Account] VC WITH(NOLOCK) ON C.vcCustodianAccountCode=VC.vcCustodianAccountCode) S
			ON T.INTPORTFOLIOID=S.INTPORTFOLIOID AND T.INTCUSTODIANACCOUNTID=S.INTCUSTODIANACCOUNTID
			WHEN NOT MATCHED THEN 
			INSERT(INTPORTFOLIOID,INTCUSTODIANACCOUNTID,INTCREATEDBY_INTBUSINESSENTITYID,DTCREATEDDATE,INTMODIFIEDBY_INTBUSINESSENTITYID,DTMODIFIEDDATE)
			VALUES	(S.INTPORTFOLIOID,S.INTCUSTODIANACCOUNTID,1,GETDATE(),1,GETDATE());
		END
		--IF @master_name='CALANDER'
		--BEGIN
		--	MERGE INTO [cmrf].[tbl_Calendar] AS T 
		--	USING [setup].[tbl_Calendar] AS S
		--	ON T.VcCalendarName=S.vcCalendarName 
		--	WHEN MATCHED THEN
		--	UPDATE SET	T.VcCalendarDesc =	S.GenevaCalendarName,
		--		T.BitSun_Off	 =	S.Sun_Off,
		--		T.BitMon_Off	 =	S.Mon_Off,
		--		T.BitTue_Off	 =	S.Tue_Off,
		--		T.BitWed_Off	 =	S.Wed_Off,
		--		T.BitThu_Off	 =	S.Thu_Off,
		--		T.BitFri_Off	 =	S.Fri_Off,
		--		T.BitSat_Off	 =	S.Sat_Off								  
		--	WHEN NOT MATCHED THEN
		--	INSERT (VcCalendarName,VcCalendarDesc,BitSun_Off,BitMon_Off,BitTue_Off,BitWed_Off,BitThu_Off,BitFri_Off,BitSat_Off)
		--	VALUES(S.vcCalendarName,S.GenevaCalendarName,S.Sun_Off,S.Mon_Off,S.Tue_Off,S.Wed_Off,S.Thu_Off,S.Fri_Off,S.Sat_Off);
		--END
		--IF @master_name='CALANDERDAYS'
		--BEGIN
		--	IF OBJECT_ID('tempdb..#CALANDERDAYS') IS NOT NULL DROP TABLE #CALANDERDAYS;
		--	WITH CTE AS
		--	(
		--		SELECT [vcCalendarname] = (SELECT vcCalendarname FROM [setup].[tbl_Calendar] WHERE intCalendarId = c.intCalendarId),*
		--		FROM setup.tbl_CalendarDays c WITH(NOLOCK)
		--	)
		--	SELECT B.TinCalendarId TinCalendarId_VU,a.*
		--	INTO #CALANDERDAYS
		--	FROM CTE A 
		--	INNER JOIN CMRF.tbl_Calendar B ON A.vcCalendarname=B.vcCalendarname
		--	MERGE INTO [cmrf].[TBL_CalendarDays] AS T 
		--	USING #CALANDERDAYS AS S
		--	ON T.[TinCalendarId]=S.[TinCalendarId_VU] AND T.[DtDate] = S.[dt]
		--	WHEN MATCHED THEN
		--	UPDATE SET	T.[VcDescription]	 =S.[description]
		--	WHEN NOT MATCHED THEN
		--	INSERT (TinCalendarId, DtDate, VcDescription)
		--	VALUES (S.TinCalendarId_VU,S.[dt],S.[description]);
		--END
		IF @master_name='CURRENCY'
		BEGIN
			MERGE INTO [cmrf].[TBL_Currency] AS T 
			USING (SELECT DISTINCT S.[vcCurrencyshortcode],S.vcDescription,S.bitISActive FROM [setup].[tbl_Currency] S WITH(NOLOCK)) AS S
			ON T.[VcCurrencyCode] COLLATE SQL_Latin1_General_CP1_CS_AS =S.[vcCurrencyshortcode] COLLATE SQL_Latin1_General_CP1_CS_AS
			WHEN MATCHED THEN
			UPDATE SET	T.[VcCurrencyName] =S.vcDescription,
				T.[BitIsActive]  = S.bitISActive
			WHEN NOT MATCHED THEN
			INSERT ([VcCurrencyCode],[VcCurrencyName],[BitIsActive])
			VALUES (S.[vcCurrencyshortcode],S.[vcDescription],S.[bitISActive]);
		END
		IF @master_name = 'BROKER'
		BEGIN
			PRINT '1.1'
		END
		IF @master_name = 'COUNTRY'
		BEGIN
			MERGE INTO [cmrf].[tbl_Country] AS T 
			USING  [setup].[tbl_Country] AS S
			ON T.VcCountryName=S.vcCountryName  
			WHEN MATCHED THEN
			UPDATE SET	T.VcISO31662Code	=	S.vcCountryShortCode,
				T.VcBloombergCountryCode	=	S.vcGenevaCountryCode,
				T.VcBloombergCountryName	=	S.vcGenevaCountryName
			WHEN NOT MATCHED THEN
			INSERT ([VcISO31662Code],[VcBloombergCountryCode],[VcBloombergCountryName])
			VALUES (S.vcCountryShortCode,S.vcGenevaCountryCode,S.vcGenevaCountryName);
		END
		IF @master_name = 'EXCHANGE'
		BEGIN
			MERGE INTO [cmrf].[tbl_Exchange] AS T 
			USING [setup].[tbl_Exchange]  AS S
			ON  T.VcExchangeShortcode=S.vcExchangeShortcode  
			WHEN MATCHED THEN
			UPDATE SET	T.VcExchangeName=	S.vcName,
				T.TinCalendarId			=	S.intCalendarId,
				T.BitIsactive			=	S.Isactive
			WHEN NOT MATCHED THEN
			INSERT (VcExchangeName,	TinCalendarId,BitIsactive)
			VALUES (S.vcName,S.intCalendarId,S.Isactive);
		END
		IF @master_name = 'INDUSTRY'
		BEGIN
			MERGE INTO [cmrf].[tbl_Industry] AS T 
			USING  [setup].[tbl_Industry] AS S
			ON  T.VcIndustryCode=S.vcIndustryCode  
			WHEN MATCHED THEN
			UPDATE SET	T.VcIndustryDescription	=	S.vcIndustryDescription,
				T.BitIsActive					=	S.bitIsActive,
				T.SinIndustryGroupId			=	S.intIndustryGroupId
			WHEN NOT MATCHED THEN
			INSERT (VcIndustryDescription,BitIsActive,SinIndustryGroupId)
			VALUES (S.vcIndustryDescription,S.bitIsActive,S.intIndustryGroupId);
			--DELETE FROM  [cmrf].[tbl_ReferenceMasterers_DataSync] WHERE  ReferenceMasterID=15
		END
		IF @master_name = 'INDUSTRY_GROUP'
		BEGIN
			MERGE INTO [cmrf].[tbl_IndustryGroup] AS T 
			USING [setup].[tbl_IndustryGroup] AS S
			ON  T.VcIndustryGroupCode=S.vcIndustryGroupCode  
			WHEN MATCHED THEN
			UPDATE SET	
				T.VcIndustryGroupDescription	=	S.vcIndustryGroupDescription,
				T.BitIsActive					=	S.bitIsActive,
				T.SinSectorID					=	S.intSectorID
			WHEN NOT MATCHED THEN
			INSERT (VcIndustryGroupDescription,BitIsActive,SinSectorID)
			VALUES (S.vcIndustryGroupDescription,S.bitIsActive,S.intSectorID);
			--DELETE FROM  [cmrf].[tbl_ReferenceMasterers_DataSync] WHERE  ReferenceMasterID=17
		END
		IF @master_name = 'STRATEGY'
		BEGIN
			MERGE INTO [cmrf].[tbl_Strategy] AS T 
			USING [setup].[tbl_Strategy] AS S
			ON  T.VcStrategyCode=S.vcStrategyCode
			WHEN MATCHED THEN
			UPDATE SET	
				T.VcStrategyDescription	=	S.vcStrategyDescription,
				T.BitIsActive			=	S.bitIsActive,
				T.IntSubBusinessUnitId	=	S.intSubBusinessUnitId
			WHEN NOT MATCHED THEN
			INSERT (VcStrategyDescription,BitIsActive,IntSubBusinessUnitId)
			VALUES (S.vcStrategyDescription,S.bitIsActive,S.intSubBusinessUnitId);
		END
		IF @master_name = 'SECTOR'
		BEGIN
			MERGE INTO [cmrf].[tbl_Sector] AS T 
			USING [setup].[tbl_Sector] AS S
			ON  T.VcSectorCode=S.vcSectorCode 
			WHEN MATCHED THEN
			UPDATE SET	
				T.SinSectorId			=	S.SectorId,
				T.VcSectorDescription	=	S.vcSectorDescription,
				T.BitIsActive			=	S.bitIsActive
			WHEN NOT MATCHED THEN
			INSERT (SinSectorId,VcSectorDescription,BitIsActive)
			VALUES (S.SectorId,S.vcSectorDescription,S.bitIsActive);
		END
		IF @master_name = 'SUBINDUSTRY'
		BEGIN
			MERGE INTO [cmrf].[tbl_SubIndustry] AS T 
			USING [setup].[tbl_SubIndustry] AS S
			ON  T.VcSubIndustryCode=S.vcSubIndustryCode
			WHEN MATCHED THEN
			UPDATE SET	
				T.VcSubIndustryDescription	=	S.vcSubIndustryDescription	,
				T.BitIsActive				=	S.bitIsActive,
				T.SinIndustryId				=	S.intIndustryId
			WHEN NOT MATCHED THEN
			INSERT (VcSubIndustryDescription,BitIsActive,SinIndustryId)
			VALUES (S.vcSubIndustryDescription,S.bitIsActive,S.intIndustryId);
		END
END TRY
BEGIN CATCH
	EXEC err.stp_LogError
	SET @success = -1 * Error_Number()
	SET @error_message = ERROR_MESSAGE()
END CATCH
--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_GetUserGroupInfo]
(
	@VcActionCode		VARCHAR(100),
	@XmSearchString		XML				=NULL,
---------------------------------Common Columns-------------------------------- 
	@IntSuccess			INT				OUTPUT,
	@VcError_Message	VARCHAR(1000)	OUTPUT
---------------------------------Common Columns-------------------------------- 
)
AS
DECLARE @internal_success INT,@internal_error_message VARCHAR(1000),@vc_searchstring VARCHAR(8000)
BEGIN
	SET NOCOUNT ON	
/*
	
	IF @VcActionCode ='distributionInfo.get.all.lines'
	BEGIN
		SELECT DISTINCT di.IntUDMId
			,di.IntClientId
			,STUFF((SELECT ',' + CAST(UDP.[IntPortfolioId] AS VARCHAR(250))
					FROM CMRF.TBL_UDMPortfolioMapping UDP WITH(NOLOCK)
					WHERE UDP.IntUDMId=DI.IntUDMId
					FOR XML PATH('')), 1, 1, '') [VcPortfolioIds]
			,ISNULL(STUFF((SELECT ',' + pf.VcPortfolioName
					FROM CMRF.TBL_UDMPortfolioMapping UDP WITH(NOLOCK)
					INNER JOIN [cmrf].[TBL_Portfolio] pf WITH(NOLOCK) ON UDP.IntPortfolioId=pf.IntPortfolioID
					WHERE UDP.IntUDMId=DI.IntUDMId
					ORDER BY pf.VcPortfolioName
					FOR XML PATH('')), 1, 1, ''),'ALL') [VcPortfolioNames]
			,di.[IntModuleID]
			,STUFF((SELECT ',' + CAST(UDS.IntScreenId AS VARCHAR(250))
					FROM CMRF.TBL_UDMScreenMapping UDS WITH(NOLOCK)
					WHERE UDS.IntUDMId=DI.IntUDMId
					FOR XML PATH('')), 1, 1, '') [VcScreenIds]
			,STUFF((SELECT ',' + CAST(UDA.[IntActionID] AS VARCHAR(250))
					FROM CMRF.TBL_UDMActionMapping UDA WITH(NOLOCK)
					WHERE UDA.IntUDMId=DI.IntUDMId
					FOR XML PATH('')), 1, 1, '') [VcActionIds]
			,ISNULL(STUFF((SELECT ',' + wsa.VcActionName
					FROM CMRF.TBL_UDMActionMapping UDA WITH(NOLOCK)
					INNER JOIN WR.TBL_WireSourceActions wsa WITH(NOLOCK) ON UDA.IntActionId=wsa.TinActionID
					WHERE UDA.IntUDMId=DI.IntUDMId
					ORDER BY wsa.VcActionName
					FOR XML PATH('')), 1, 1, ''),'ALL') [VcActionNames]
			--,di.[IntDistributionGroupID]
			--,di.[VcDistributionType]
			,di.[BitIsActive]
			,di.[DtLastUpdatedOn]
			,cl.VcClientName
			,pf.VcPortfolioName
			,STUFF((SELECT ',' + CAST(UDA.IntCustodianId AS VARCHAR(250))
					FROM CMRF.TBL_UDMCustodianMapping UDA WITH(NOLOCK)
					WHERE UDA.IntUDMId=DI.IntUDMId
					FOR XML PATH('')), 1, 1, '') [VcCustodianIds]
			,ISNULL(STUFF((SELECT ',' + cu.VcCustodianName
					FROM CMRF.TBL_UDMCustodianMapping UDC WITH(NOLOCK)
					INNER JOIN cmrf.TBL_Custodian cu WITH(NOLOCK) ON UDC.IntCustodianId=cu.IntCustodianID
					WHERE UDC.IntUDMId=DI.IntUDMId
					ORDER BY cu.VcCustodianName
					FOR XML PATH('')), 1, 1, ''),'ALL') [VcCustodianNames]
			,STUFF((SELECT ',' + CAST(UDCA.IntCustodianAccountId AS VARCHAR(250))
					FROM CMRF.TBL_UDMCustodianAccountMapping UDCA WITH(NOLOCK)
					WHERE UDCA.IntUDMId=DI.IntUDMId
					FOR XML PATH('')), 1, 1, '') [VcCustodianAccountIds]
			,ISNULL(STUFF((SELECT ',' + cu.VcCustodianAccountName
					FROM CMRF.TBL_UDMCustodianAccountMapping UDCA WITH(NOLOCK)
					INNER JOIN cmrf.TBL_Custodian_Account cu WITH(NOLOCK) ON UDCA.IntCustodianAccountId=cu.IntCustodianAccountId
					WHERE UDCA.IntUDMId=DI.IntUDMId
					ORDER BY cu.VcCustodianAccountName
					FOR XML PATH('')), 1, 1, ''),'ALL') VcCustodianAccountNames
		FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
		INNER JOIN CMRF.TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
		INNER JOIN CMRF.TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
		INNER JOIN CMRF.TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
		INNER JOIN CMRF.TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
		INNER JOIN CMRF.TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
		LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
		LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON UDP.[IntPortfolioID]=pf.IntPortfolioID
		LEFT JOIN cmrf.TBL_Custodian cu WITH(NOLOCK) ON UDC.IntCustodianId=cu.IntCustodianID
		LEFT JOIN cmrf.TBL_Custodian_Account cua WITH(NOLOCK) ON UDCA.IntCustodianAccountId=cua.IntCustodianAccountID
		ORDER BY di.IntUDMId
	END

*/
	IF @VcActionCode ='distributionInfo.get.selected.columns01'
	BEGIN
		
		DECLARE @searchstringDistributionInfo  TABLE
		(
			[queryType]				VARCHAR(50),
			[DistributionInfo]		INT,
			[ModuleID]				INT,
			[ScreenID]				INT,
			[ClientName]			VARCHAR(500),
			[PortfolioName]			VARCHAR(250),
			[CustodianName]			VARCHAR(250),
			[CustodianAccountName]	VARCHAR(250),
			[Status]				VARCHAR(1)
		)
		INSERT INTO @searchstringDistributionInfo(queryType,DistributionInfo,ModuleID,ScreenID,ClientName,PortfolioName,CustodianName,CustodianAccountName,[Status])
		SELECT 
			ISNULL(LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))),'') queryType,
			ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionInfo','INT'))),0)DistributionInfo,
			ISNULL(LTRIM(RTRIM(tab.col.value('@ModuleID','INT'))),0)ModuleID,
			ISNULL(LTRIM(RTRIM(tab.col.value('@ScreenID','INT'))),0)ScreenID,
			ISNULL(LTRIM(RTRIM(tab.col.value('@ClientName','VARCHAR(500)'))),'')ClientName,
			ISNULL(LTRIM(RTRIM(tab.col.value('@PortfolioName','VARCHAR(250)'))),'')PortfolioName,
			ISNULL(LTRIM(RTRIM(tab.col.value('@CustodianName','VARCHAR(250)'))),'')CustodianName,
			ISNULL(LTRIM(RTRIM(tab.col.value('@CustodianAccountName','VARCHAR(250)'))),'')CustodianAccountName,
			LTRIM(RTRIM(tab.col.value( '@Status', 'VARCHAR(1)' ))) [Status]
		FROM @XmSearchString.nodes('//row') tab(col) 

		IF EXISTS(SELECT 1 FROM @searchstringDistributionInfo WHERE queryType='GET.SINGLE')
		BEGIN
			DECLARE @DistributionInfo INT
			SELECT @DistributionInfo= DistributionInfo FROM @searchstringDistributionInfo
			--step 1:
			SELECT DISTINCT di.IntUDMId
							,di.IntClientId
							,cl.VcClientName
							,di.IntModuleId
							,di.BitIsActive
							,di.DtCreatedDate
							,di.DtLastUpdatedOn
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			WHERE di.IntUDMId = @DistributionInfo AND cl.BitIsActive = 1

			--step 2:
			SELECT DISTINCT di.IntUDMId
							,UDP.IntPortfolioId
							,P.VcPortfolioName
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
						INNER JOIN [cmrf].TBL_Portfolio P WITH(NOLOCK) ON UDP.IntPortfolioId = P.IntPortfolioID
						WHERE di.IntUDMId = @DistributionInfo AND P.BitIsActive = 1

			--STEP 3:
			SELECT DISTINCT di.IntUDMId
							,UDC.IntCustodianId
							,CU.VcCustodianName
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
						INNER JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON UDC.IntCustodianId=cu.IntCustodianID
						WHERE di.IntUDMId = @DistributionInfo AND cu.BitIsActive = 1 

			--STEP 4:
			SELECT DISTINCT di.IntUDMId
							,UDCA.IntCustodianAccountId
							,CUA.VcCustodianAccountName
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
						INNER JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON UDCA.IntCustodianAccountId=cua.IntCustodianAccountID
						WHERE di.IntUDMId = @DistributionInfo AND cua.BitIsActive = 1 

			--STEP 5:
			SELECT DISTINCT di.IntUDMId
							,UDS.IntScreenId
							,WSA.VcScreenName
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
						INNER JOIN [wr].tbl_WireSourceScreens wsa WITH(NOLOCK) ON UDS.IntScreenId=wsa.TinScreenID
						WHERE di.IntUDMId = @DistributionInfo 

			--STEP 6:
			SELECT DISTINCT di.IntUDMId
							,UDA.IntActionId
							,WSA.VcActionName
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
						INNER JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON UDA.IntActionId=wsa.TinActionID
						WHERE di.IntUDMId = @DistributionInfo  

			--STEP 7:
			SELECT DISTINCT di.IntUDMId
							,UAM.IntApprovalId
							,UAM.VcLevelName
							,UAM.IntDistributionGroupId
							,D.VcDistributionGroupName
							,UAM.VcDistributionType
							,UAM.IntPriority
			FROM [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
						INNER JOIN [cmrf].[TBL_UDMApprovalMapping] UAM WITH(NOLOCK) ON di.IntUDMId = UAM.IntUDMId
						INNER JOIN [cmrf].TBL_DistributionLists D WITH(NOLOCK) ON UAM.IntDistributionGroupId = D.IntDistributionGroupID
						WHERE di.IntUDMId = @DistributionInfo AND D.BitIsActive = 1 

		END

		IF EXISTS(SELECT 1 FROM @searchstringDistributionInfo WHERE queryType='GET.MULTIPLE')
		BEGIN
		IF EXISTS (SELECT 1 FROM @searchstringDistributionInfo WHERE DistributionInfo = '' AND ModuleID = '' AND ScreenID='' AND ClientName='' 
			AND PortfolioName='' AND CustodianName='' AND CustodianAccountName='' AND ISNULL([Status],'') = '')
			BEGIN
			 --step 1:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,di.IntClientId
				,cl.VcClientName
				,di.IntModuleId
				,di.BitIsActive
				,di.DtCreatedDate
				,di.DtLastUpdatedOn
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0))
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1

			--step 2:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UDP.IntPortfolioId
				,CASE WHEN UDP.IntPortfolioId = 0 THEN 'ALL' ELSE pf.VcPortfolioName END VcPortfolioName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1

			--step 3:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UDC.IntCustodianId
				,CASE WHEN UDC.IntCustodianId = 0 THEN 'ALL' ELSE CU.VcCustodianName END VcCustodianName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1
			--step 4:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UDCA.IntCustodianAccountId
				,CASE WHEN UDCA.IntCustodianAccountId = 0 THEN 'ALL' ELSE CUA.VcCustodianAccountName END VcCustodianAccountName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1

			--step 5:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UDS.IntScreenId
				,CASE WHEN UDS.IntScreenId = 0 THEN 'ALL' ELSE wss.VcScreenName END VcScreenName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1

			--step 6:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UDA.IntActionId
				,CASE WHEN UDA.IntActionId = 0 THEN 'ALL' ELSE WSA.VcActionName END VcActionName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1

			--step 7:
			SELECT  DISTINCT TOP 50 di.IntUDMId
				,UAM.IntApprovalId
				,UAM.VcLevelName
				,UAM.IntDistributionGroupId
				,D.VcDistributionGroupName
				,UAM.VcDistributionType
				,UAM.IntPriority
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN [cmrf].[TBL_UDMApprovalMapping] UAM WITH(NOLOCK) ON di.IntUDMId = UAM.IntUDMId
			INNER JOIN [cmrf].TBL_DistributionLists D WITH(NOLOCK) ON UAM.IntDistributionGroupId = D.IntDistributionGroupID AND D.BitIsActive = 1
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID AND cl.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0))
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE di.BitIsActive = 1 

			END
			ELSE
			BEGIN
			--step 1:
			SELECT  DISTINCT di.IntUDMId
				,di.IntClientId
				,cl.VcClientName
				,di.IntModuleId
				,di.BitIsActive
				,di.DtCreatedDate
				,di.DtLastUpdatedOn
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0))
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1
			

			--step 2:
			SELECT  DISTINCT di.IntUDMId
				,UDP.IntPortfolioId
				,CASE WHEN UDP.IntPortfolioId = 0 THEN 'ALL' ELSE pf.VcPortfolioName END VcPortfolioName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1

			--step 3:
			SELECT  DISTINCT di.IntUDMId
				,UDC.IntCustodianId
				,CASE WHEN UDC.IntCustodianId = 0 THEN 'ALL' ELSE CU.VcCustodianName END VcCustodianName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1
			--step 4:
			SELECT  DISTINCT di.IntUDMId
				,UDCA.IntCustodianAccountId
				,CASE WHEN UDCA.IntCustodianAccountId = 0 THEN 'ALL' ELSE CUA.VcCustodianAccountName END VcCustodianAccountName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1 

			--step 5:
			SELECT  DISTINCT di.IntUDMId
				,UDS.IntScreenId 
				,CASE WHEN UDS.IntScreenId = 0 THEN 'ALL' ELSE wss.VcScreenName END VcScreenName 
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1

			--step 6:
			SELECT  DISTINCT di.IntUDMId
				,UDA.IntActionId
				,CASE WHEN UDA.IntActionId = 0 THEN 'ALL' ELSE WSA.VcActionName END VcActionName
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0)) AND cua.BitIsActive = 1
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1

			--step 7:
			SELECT  DISTINCT di.IntUDMId
				,UAM.IntApprovalId
				,UAM.VcLevelName
				,UAM.IntDistributionGroupId
				,D.VcDistributionGroupName
				,UAM.VcDistributionType
				,UAM.IntPriority
			FROM  [cmrf].[TBL_UserDistributionMapping] di WITH(NOLOCK)
			INNER JOIN [cmrf].TBL_UDMPortfolioMapping UDP WITH(NOLOCK) ON di.IntUDMId = UDP.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianMapping UDC WITH(NOLOCK) ON di.IntUDMId = UDC.IntUDMId
			INNER JOIN [cmrf].TBL_UDMCustodianAccountMapping UDCA  WITH(NOLOCK) ON di.IntUDMId = UDCA.IntUDMId 
			INNER JOIN [cmrf].TBL_UDMScreenMapping UDS WITH(NOLOCK) ON di.IntUDMId = UDS.IntUDMId
			INNER JOIN [wr].TBL_WireSourceScreens wss WITH(NOLOCK) ON UDS.IntScreenId=wss.TinScreenID
			INNER JOIN [cmrf].TBL_UDMActionMapping UDA WITH(NOLOCK) ON di.IntUDMId = UDA.IntUDMId 
			INNER JOIN [cmrf].[TBL_UDMApprovalMapping] UAM WITH(NOLOCK) ON di.IntUDMId = UAM.IntUDMId
			INNER JOIN [cmrf].TBL_DistributionLists D WITH(NOLOCK) ON UAM.IntDistributionGroupId = D.IntDistributionGroupID AND D.BitIsActive = 1
			INNER JOIN @searchstringDistributionInfo sd ON (di.[IntModuleID] =sd.[ModuleID] OR ISNULL(sd.[ModuleID],'')='')
			AND (UDS.[IntScreenID]=sd.[ScreenID] OR ISNULL(sd.[ScreenID],'') ='')
			LEFT JOIN [cmrf].TBL_Client cl WITH(NOLOCK) ON di.IntClientId=cl.IntClientDefinitionID
			LEFT JOIN [cmrf].TBL_Portfolio pf WITH(NOLOCK) ON ((UDP.[IntPortfolioID]=pf.IntPortfolioID 
			AND UDP.[IntPortfolioID] <> 0 ) OR (1=1 AND UDP.[IntPortfolioID]= 0)) AND pf.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian cu WITH(NOLOCK) ON ((UDC.IntCustodianId=cu.IntCustodianID 
			AND UDC.IntCustodianId <> 0) OR (1=1 AND UDC.IntCustodianId = 0)) AND cu.BitIsActive = 1
			LEFT JOIN [cmrf].TBL_Custodian_Account cua WITH(NOLOCK) ON ((UDCA.IntCustodianAccountId=cua.IntCustodianAccountID AND UDCA.IntCustodianAccountId <> 0) OR (1=1 AND UDCA.IntCustodianAccountId = 0))
			LEFT JOIN [wr].TBL_WireSourceActions wsa WITH(NOLOCK) ON ((UDA.IntActionId=wsa.TinActionID AND UDA.IntActionId<>0) OR (1=1 AND UDA.IntActionId = 0))
			WHERE cl.VcClientName LIKE '%'+ISNULL(sd.ClientName,cl.VcClientName)+'%' 
			AND pf.VcPortfolioName LIKE '%'+ISNULL(sd.PortfolioName,pf.VcPortfolioName)+'%'
			AND cu.VcCustodianName LIKE '%'+ISNULL(sd.CustodianName,cu.VcCustodianName)+'%'
			AND cua.VcCustodianAccountName LIKE '%'+ISNULL(sd.CustodianAccountName,cua.VcCustodianAccountName)+'%'
			AND di.BitIsActive = CASE sd.[Status] WHEN '' THEN 1 ELSE sd.[Status] END
			AND cl.BitIsActive = 1 

			END
			
		END
	END
	

	IF @VcActionCode ='distribution.get.all.lines'
	BEGIN
		SELECT [IntDistributionGroupID]
			,[VcDistributionGroupName]
			,[BitIsActive]
		FROM [cmrf].[TBL_DistributionLists] WITH(NOLOCK) 
		WHERE [BitIsActive]=1 
		ORDER BY [IntDistributionGroupID]
		
		SELECT [IntDistributionMemberID]
			,[IntDistributionGroupID]
			,[IntBusinessEntityID]
		FROM [cmrf].[TBL_DistributionListADMembers] WITH(NOLOCK) 
		ORDER BY [IntDistributionMemberID]
		
		SELECT [IntDistributionCustomMemberID]
			,[IntDistributionGroupID]
			,[VcDisplayName]
			,[VcEmailAddress]
		FROM [cmrf].[TBL_DistributionListCustomMembers] WITH(NOLOCK) 
		ORDER BY [IntDistributionCustomMemberID]
	END
	
	IF @VcActionCode ='distributionlist.get.all.lines'
	BEGIN
		SELECT [IntDistributionGroupID]
			,[VcDistributionGroupName]
			,[BitIsActive]
		FROM [cmrf].[TBL_DistributionLists] WITH(NOLOCK) 
		ORDER BY [IntDistributionGroupID]
	END
	
	--IF @VcActionCode ='distributionlist.get.selected.columns02' --Get list members 
	--BEGIN
	--DECLARE @searchstringDistributionList02  TABLE 
	--	(
	--		queryType				VARCHAR(50),
	--		[ModuleCode]			VARCHAR(100),
	--		[ScreenCode]			VARCHAR(100),
	--		[ActionCode]			VARCHAR(100),
	--		[DistributionType]		VARCHAR(100),
	--		[ClientDefinitionID]	INT,
	--		[PortfolioId]			INT		
	--	)	
	--	INSERT  INTO @searchstringDistributionList02(queryType,[ModuleCode],[ScreenCode],[ActionCode],[DistributionType],[ClientDefinitionID],[PortfolioId])
	--	SELECT 
	--		LTRIM(RTRIM(tab.col.value('@VcqueryType','VARCHAR(50)'))) [queryType],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@VcModuleCode','VARCHAR(100)'))),'') [ModuleCode],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@VcScreenCode','VARCHAR(100)'))),'') ScreenCode,
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@VcActionCode','VARCHAR(100)'))),'') ActionCode,
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@VcDistributionType','VARCHAR(100)'))),'') [DistributionType],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@IntClientDefinitionID','INT'))),0) [ClientDefinitionID],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@IntPortfolioID','INT'))),0) [PortfolioId],
	--		LTRIM(RTRIM(tab.col.value( '@Status', 'VARCHAR(10)' ))) [Status]
	--	FROM @XmSearchString.nodes('//row') tab(col)

	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionList02 WHERE queryType='GET.MULTIPLE' AND DistributionType='Internal' )
	--	BEGIN
	--		SELECT di.IntDistributionInfoID
	--			,di.IntClientDefinitionID
	--			,di.IntPortfolioID
	--			,di.IntModuleID
	--			,di.IntScreenID
	--			,di.IntActionID
	--			,di.IntDistributionGroupID
	--			,di.VcDistributionType
	--			,di.BitIsActive
	--			,di.DtLastUpdatedOn
	--			,ta.[VcLogin] AS [DisplayName]
	--			,em.VcPrimaryEmailAddressID AS [EmailAddress]
	--		FROM [cmrf].[TBL_DistributionInfo] di WITH(NOLOCK) 
	--		INNER JOIN cmrf.TBL_DistributionLists dl WITH(NOLOCK) ON di.IntDistributionGroupID=dl.IntDistributionGroupID
	--		INNER JOIN cmrf.TBL_DistributionListADMembers ad WITH(NOLOCK) ON dl.IntDistributionGroupID= ad.IntDistributionGroupID 
	--		LEFT JOIN ACS.TBL_Accounts ta WITH(NOLOCK) ON ad.IntBusinessEntityID=ta.IntBusinessEntityID
	--		LEFT JOIN ACS.TBL_EmailAddress em WITH(NOLOCK) ON ad.IntBusinessEntityID=em.IntBusinessEntityID
	--		INNER JOIN @searchstringDistributionList02 sd ON di.VcDistributionType IN ('Internal','Both')
	--		INNER JOIN wr.TBL_WireModules wm WITH(NOLOCK) ON di.[IntModuleID]=wm.[TinModuleID]
	--		AND (wm.VcModuleCode LIKE '%'+sd.ModuleCode+'%' OR ISNULL(sd.ModuleCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceScreens ws WITH(NOLOCK) ON di.[IntScreenID]=ws.[TinScreenID] 
	--		AND (ws.VcScreenCode LIKE '%'+sd.ScreenCode+'%' OR ISNULL(sd.ScreenCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceActions wa WITH(NOLOCK) ON di.[IntActionID]=wa.[TinActionID] 
	--		AND (wa.VcActionCode LIKE '%'+sd.ActionCode+'%' OR ISNULL(sd.ActionCode,'')='')
	--		AND (di.[IntClientDefinitionID] =sd.[ClientDefinitionID] OR ISNULL(sd.[ClientDefinitionID],'')='' )
	--		AND (di.IntPortfolioID =sd.PortfolioID  OR ISNULL(sd.PortfolioID,'')='' ) 
	--		AND di.BitIsActive=1 ORDER BY di.IntDistributionInfoID
	--	END
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionList02 WHERE queryType='GET.MULTIPLE' AND DistributionType='External' )
	--	BEGIN
	--		SELECT di.IntDistributionInfoID
	--			,di.IntClientDefinitionID
	--			,di.IntPortfolioID
	--			,di.IntModuleID
	--			,di.IntScreenID
	--			,di.IntActionID
	--			,di.IntDistributionGroupID
	--			,di.VcDistributionType
	--			,di.BitIsActive
	--			,di.DtLastUpdatedOn
	--			,lst.VcDisplayName
	--			,lst.VcEmailAddress  
	--		FROM [cmrf].[TBL_DistributionInfo] di WITH(NOLOCK) 
	--		INNER JOIN cmrf.TBL_DistributionLists dl WITH(NOLOCK) ON di.IntDistributionGroupID=dl.IntDistributionGroupID
	--		INNER JOIN cmrf.TBL_DistributionListCustomMembers lst WITH(NOLOCK) ON dl.IntDistributionGroupID= lst.IntDistributionGroupID
	--		INNER JOIN @searchstringDistributionList02 sd ON di.VcDistributionType IN ('External','Both')
	--		INNER JOIN wr.TBL_WireModules wm WITH(NOLOCK) ON di.[IntModuleID]=wm.[TinModuleID] 
	--		AND (wm.VcModuleCode LIKE '%'+sd.ModuleCode+'%' OR ISNULL(sd.ModuleCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceScreens ws WITH(NOLOCK) ON di.[IntScreenID]=ws.[TinScreenID] 
	--		AND (ws.VcScreenCode LIKE '%'+sd.ScreenCode+'%' OR ISNULL(sd.ScreenCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceActions wa WITH(NOLOCK) ON di.[IntActionID]=wa.[TinActionID] 
	--		AND (wa.VcActionCode LIKE '%'+sd.ActionCode+'%' OR ISNULL(sd.ActionCode,'')='')
	--		AND (di.[IntClientDefinitionID] =sd.[ClientDefinitionID] OR ISNULL(sd.[ClientDefinitionID],'')='' )
	--		AND (di.IntPortfolioID =sd.PortfolioID OR ISNULL(sd.PortfolioID,'')='' )
	--		AND di.BitIsActive=1 ORDER BY di.IntDistributionInfoID
	--	END
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionList02 WHERE queryType='GET.MULTIPLE' AND DistributionType='Both')
	--	BEGIN
	--		SELECT di.IntDistributionInfoID
	--			,di.IntClientDefinitionID
	--			,di.IntPortfolioID
	--			,di.IntModuleID
	--			,di.IntScreenID
	--			,di.IntActionID
	--			,di.IntDistributionGroupID
	--			,di.VcDistributionType
	--			,di.BitIsActive
	--			,di.DtLastUpdatedOn
	--			,lst.VcDisplayName   AS  [DisplayName],
	--			 lst.VcEmailAddress  AS  [EmailAddress]
	--			 INTO #searchresult
	--		FROM [cmrf].[TBL_DistributionInfo] di WITH(NOLOCK) 
	--		INNER JOIN cmrf.TBL_DistributionLists dl WITH(NOLOCK) ON di.IntDistributionGroupID=dl.IntDistributionGroupID
	--		INNER JOIN cmrf.TBL_DistributionListCustomMembers lst WITH(NOLOCK) ON dl.IntDistributionGroupID= lst.IntDistributionGroupID
	--		INNER JOIN @searchstringDistributionList02 sd ON di.VcDistributionType ='Both'
	--		INNER JOIN wr.TBL_WireModules wm WITH(NOLOCK) ON di.[IntModuleID]=wm.[TinModuleID]
	--		AND (wm.VcModuleCode LIKE '%'+sd.ModuleCode+'%' OR ISNULL(sd.ModuleCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceScreens ws WITH(NOLOCK) ON di.[IntScreenID]=ws.[TinScreenID]
	--		AND (ws.VcScreenCode LIKE '%'+sd.ScreenCode+'%' OR ISNULL(sd.ScreenCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceActions wa WITH(NOLOCK) ON di.[IntActionID]=wa.[TinActionID]
	--		AND (wa.VcActionCode LIKE  '%'+sd.ActionCode+'%' OR ISNULL(sd.ActionCode,'')='')
	--		AND (di.[IntClientDefinitionID] =sd.[ClientDefinitionID]  OR ISNULL(sd.[ClientDefinitionID],'')='' )
	--		AND (di.IntPortfolioID =sd.PortfolioID  OR ISNULL(sd.PortfolioID,'')='' ) 
	--		AND di.BitIsActive=1 ORDER BY di.IntDistributionInfoID
			
	--		INSERT INTO #searchresult
	--		SELECT di.IntDistributionInfoID
	--			,di.IntClientDefinitionID
	--			,di.IntPortfolioID
	--			,di.IntModuleID
	--			,di.IntScreenID
	--			,di.IntActionID
	--			,di.IntDistributionGroupID
	--			,di.VcDistributionType
	--			,di.BitIsActive
	--			,di.DtLastUpdatedOn
	--			,ta.[VcLogin] AS [DisplayName]
	--			,em.VcPrimaryEmailAddressID AS [EmailAddress] 
	--		FROM [cmrf].[TBL_DistributionInfo] di WITH(NOLOCK) 
	--		INNER JOIN cmrf.TBL_DistributionLists dl WITH(NOLOCK) ON di.IntDistributionGroupID=dl.IntDistributionGroupID
	--		INNER JOIN cmrf.TBL_DistributionListADMembers ad WITH(NOLOCK) ON dl.IntDistributionGroupID= ad.IntDistributionGroupID 
	--		INNER JOIN cmrf.TBL_DistributionListCustomMembers lst WITH(NOLOCK) ON dl.IntDistributionGroupID= lst.IntDistributionGroupID
	--		LEFT JOIN ACS.TBL_Accounts ta WITH(NOLOCK) ON ad.IntBusinessEntityID=ta.IntBusinessEntityID
	--		LEFT JOIN ACS.TBL_EmailAddress em WITH(NOLOCK) ON ad.IntBusinessEntityID=em.IntBusinessEntityID
	--		INNER JOIN @searchstringDistributionList02 sd ON di.VcDistributionType ='Both'
	--		INNER JOIN wr.TBL_WireModules wm WITH(NOLOCK) ON di.[IntModuleID]=wm.[TinModuleID]
	--		AND (wm.VcModuleCode LIKE '%'+sd.ModuleCode+'%' OR ISNULL(sd.ModuleCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceScreens ws WITH(NOLOCK) ON di.[IntScreenID]=ws.[TinScreenID]
	--		AND (ws.VcScreenCode LIKE '%'+sd.ScreenCode+'%' OR ISNULL(sd.ScreenCode,'')='')
	--		INNER JOIN wr.TBL_WireSourceActions wa WITH(NOLOCK) ON di.[IntActionID]=wa.[TinActionID]
	--		AND (wa.VcActionCode LIKE  '%'+sd.ActionCode+'%' OR ISNULL(sd.ActionCode,'')='')
	--		AND (di.[IntClientDefinitionID] =sd.[ClientDefinitionID] OR ISNULL(sd.[ClientDefinitionID],'')='' )
	--		AND (di.IntPortfolioID =sd.PortfolioID OR ISNULL(sd.PortfolioID,'')='' )
	--		AND di.BitIsActive=1 ORDER BY di.IntDistributionInfoID
	--		SELECT DISTINCT * FROM #searchresult
	--	END
	--END

	IF @VcActionCode ='distributionlistNew.get.selected.columns02' --Get list members 
	BEGIN
		DECLARE @searchstringDistributionListNew  TABLE 
		(
			[queryType]				VARCHAR(50),
			[ModuleName]			VARCHAR(100),
			[ScreenName]			VARCHAR(100),
			[Action]				VARCHAR(100),
			[DistributionType]      VARCHAR(100),
			[ClientDefinitionID]	INT,
			[PortfolioId]			INT		
		)
		INSERT  INTO @searchstringDistributionListNew([queryType],[ModuleName],[ScreenName],[Action],[DistributionType],[ClientDefinitionID],[PortfolioId])
		SELECT 
			ISNULL(LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))),'')	[queryType],
			ISNULL(LTRIM(RTRIM(tab.col.value('@ModuleName','VARCHAR(100)'))),'') [ModuleName],
			ISNULL(LTRIM(RTRIM(tab.col.value('@ScreenName','VARCHAR(100)'))),'') [ScreenName],
			ISNULL(LTRIM(RTRIM(tab.col.value('@Action','VARCHAR(100)'))),'') [Action],
			ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionType','VARCHAR(50)'))),'') [DistributionType],
			ISNULL(LTRIM(RTRIM(ISNULL(tab.col.value('@ClientDefinitionID','INT'),''))),0)	[ClientDefinitionID],
			ISNULL(LTRIM(RTRIM(ISNULL(tab.col.value('@PortfolioID','INT'),''))),0) [PortfolioId]
		FROM @XmSearchString.nodes('//row') tab(col) 

		IF EXISTS(SELECT 1 FROM @searchstringDistributionListNew WHERE queryType='GET.MULTIPLE')
		BEGIN
			SELECT di.[IntDistributionInfoID],
				di.[IntClientDefinitionID],
				di.[IntPortfolioID],
				di.[IntModuleID],
				di.[IntScreenID],
				di.[IntActionID],
				di.[IntDistributionGroupID],
				di.[VcDistributionType],
				di.[BitIsActive],
				di.[DtLastUpdatedOn],
				di.[IntCreatedBy],
				di.[IntModifiedBy],
				di.[DtCreatedDate],
				di.[DtModifiedDate]
			FROM [cmrf].[TBL_DistributionInfo] di WITH(NOLOCK) 
			INNER JOIN wr.TBL_WireModules wm ON di.[IntModuleID]=wm.[TinModuleID]
			INNER JOIN @searchstringDistributionListNew sd ON (di.[VcDistributionType] LIKE '%'+sd.[DistributionType]+'%' 
			OR ISNULL(sd.[DistributionType],'')='')
			AND (wm.VcModuleName LIKE '%'+sd.ModuleName+'%' OR ISNULL(sd.ModuleName,'')='')
			INNER JOIN wr.TBL_WireSourceScreens ws WITH(NOLOCK) ON di.[IntScreenID]=ws.[TinScreenID]
			AND (ws.[VcScreenName] LIKE '%'+sd.[ScreenName]+'%' OR ISNULL(sd.[ScreenName],'')='')
			INNER JOIN wr.TBL_WireSourceActions wa WITH(NOLOCK) ON di.[IntActionID]=wa.[TinActionID]
			AND (wa.[VcActionName] LIKE '%'+sd.[Action]+'%' OR ISNULL(sd.[Action],'')='')
			INNER JOIN [cmrf].[TBL_Client] cl WITH(NOLOCK) ON di.IntClientDefinitionID=cl.IntClientDefinitionID
			AND (di.IntClientDefinitionID=sd.ClientDefinitionID OR ISNULL(sd.ClientDefinitionID,'')='' )  
			INNER JOIN cmrf.TBL_Portfolio po WITH(NOLOCK) ON di.IntPortfolioID=po.IntPortfolioID
			AND (po.IntPortfolioID=sd.PortfolioID OR ISNULL(sd.[PortfolioID],'')='' ) 
			ORDER BY di.[IntDistributionInfoID]
		END
	END

	IF @VcActionCode ='distributionlist.get.selected.columns01'
	BEGIN
		DECLARE @searchstringDistributionList  TABLE 
		(
			[queryType]					VARCHAR(50),
			[DistributionGroupID]		INT,
			[DistributionGroupName]		VARCHAR(100)
		)
		INSERT  INTO @searchstringDistributionList(queryType,DistributionGroupID,DistributionGroupName)
		SELECT 
			LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) [queryType],
			ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionGroupID','VARCHAR(50)'))),'') [DistributionGroupID],
			ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionGroupName','VARCHAR(50)'))),'') [DistributionGroupName]
		FROM @XmSearchString.nodes('//row') tab(col) 
		
		IF EXISTS(SELECT 1 FROM @searchstringDistributionList WHERE queryType='GET.SINGLE')
		BEGIN
			SELECT dl.[IntDistributionGroupID],
				dl.[VcDistributionGroupName],
				dl.[BitIsActive]
			FROM [cmrf].[TBL_DistributionLists] dl WITH(NOLOCK)
			INNER JOIN @searchstringDistributionList ss ON (dl.IntDistributionGroupID=ss.DistributionGroupID)
		END
		
		IF EXISTS(SELECT 1 FROM @searchstringDistributionList WHERE queryType='GET.MULTIPLE')
		BEGIN
			SELECT dc.[IntDistributionGroupID]
				,dc.[VcDistributionGroupName]
				,[BitIsActive]
			FROM [cmrf].[TBL_DistributionLists] dc WITH(NOLOCK)
			INNER JOIN @searchstringDistributionList sd ON (dc.VcDistributionGroupName LIKE '%'+sd.DistributionGroupName+'%' OR ISNULL(sd.DistributionGroupName,'')='')
			ORDER BY dc.[IntDistributionGroupID]
		END
	END
	
	IF @VcActionCode ='distributionListADMembers.get.all.lines'
	BEGIN
		SELECT pe.[IntBusinessEntityID]
			,[VcFirstName]+' '+[VcLastName] AS DisplayName
			,em.[VcPrimaryEmailAddressID] AS EmailAddress 
		FROM ACS.TBL_Person pe WITH(NOLOCK)
		INNER JOIN ACS.TBL_EmailAddress em WITH(NOLOCK) ON pe.IntBusinessEntityID=em.IntBusinessEntityID ORDER BY pe.VcFirstName
	END
	
	IF @VcActionCode ='distribution.get.selected.columns01'
	BEGIN
	DECLARE @searchstringDistributions TABLE 
		(
			[queryType]						VARCHAR(50),
			[DistributionCustomMemberID]	INT,
			[GroupName]						VARCHAR(100),
			[MemberName]					VARCHAR(100),
			[EmailAddress]					VARCHAR(100),
			[Status]						VARCHAR(1)
		)
		INSERT  INTO @searchstringDistributions(queryType,DistributionCustomMemberID,GroupName,MemberName,EmailAddress,[Status])
		SELECT 
			LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) [queryType],
			ISNULL(LTRIM(RTRIM(tab.col.value('@IntDistributionCustomMemberID','INT'))),0) [DistributionCustomMemberID],
			ISNULL(LTRIM(RTRIM(tab.col.value('@GroupName','VARCHAR(50)'))),'') [GroupName],
			ISNULL(LTRIM(RTRIM(tab.col.value('@MemberName','VARCHAR(50)'))),'') [MemberName],
			LTRIM(RTRIM(ISNULL(tab.col.value('@EmailAddress','VARCHAR(100)'),''))) [EmailAddress],
			LTRIM(RTRIM(tab.col.value( '@Status', 'VARCHAR(10)' ))) [Status]
		FROM @XmSearchString.nodes('//row') tab(col) 
		IF EXISTS(SELECT 1 FROM @searchstringDistributions WHERE queryType='GET.SINGLE')
		BEGIN
			SELECT dc.[IntDistributionCustomMemberID]
				,dc.[IntDistributionGroupID]
				,dc.[VcDisplayName]
				,dc.[VcEmailAddress]
			FROM [cmrf].[TBL_DistributionListCustomMembers] dc WITH(NOLOCK)
			INNER JOIN @searchstringDistributions ss ON( dc.[IntDistributionCustomMemberID]=ss.DistributionCustomMemberID)
		END
		
		IF EXISTS(SELECT 1 FROM @searchstringDistributions WHERE queryType='GET.MULTIPLE')
		BEGIN
			 SELECT	dl.[IntDistributionGroupID]
                ,dl.[VcDistributionGroupName]
                ,dl.[BitIsActive] 
				,dl.DtCreatedDate
             INTO #searchlist
			 FROM cmrf.TBL_DistributionLists dl WITH(NOLOCK)
			 LEFT JOIN  [cmrf].[TBL_DistributionListCustomMembers] dc WITH(NOLOCK) ON (dc.IntDistributionGroupID=dl.IntDistributionGroupID)
			 INNER JOIN @searchstringDistributions sd ON (dc.[VcDisplayName] LIKE '%'+sd.MemberName+'%')
			 AND (dc.[VcEmailAddress] LIKE '%'+sd.EmailAddress+'%')
			 AND (dl.VcDistributionGroupName LIKE '%'+sd.GroupName+'%')
			 ORDER BY dc.[IntDistributionGroupID]
			
			INSERT INTO #searchlist
			SELECT 
				 dl.[IntDistributionGroupID]
				,dl.VcDistributionGroupName
				,dl.[BitIsActive]
				,dl.DtCreatedDate
			FROM cmrf.TBL_DistributionListADMembers dc WITH(NOLOCK) 
			INNER JOIN cmrf.TBL_DistributionLists dl ON dc.IntDistributionGroupID=dl.IntDistributionGroupID
			INNER JOIN ACS.TBL_Accounts ta ON dc.IntBusinessEntityID=ta.IntBusinessEntityID
			INNER JOIN ACS.TBL_EmailAddress em ON dc.IntBusinessEntityID=ta.IntBusinessEntityID 
			AND dc.IntBusinessEntityID=em.IntBusinessEntityID 
			AND dc.IntBusinessEntityID IN (SELECT IntBusinessEntityID FROM ACS.TBL_Accounts ta WITH(NOLOCK)
			INNER JOIN @searchstringDistributions ss ON (ta.[VcLogin] LIKE '%'+ss.MemberName+'%') )
			AND dc.IntBusinessEntityID IN (SELECT IntBusinessEntityID  FROM ACS.TBL_EmailAddress em WITH(NOLOCK),@searchstringDistributions ss 
			WHERE em.[VcPrimaryEmailAddressID] LIKE '%'+ss.EmailAddress+'%')    
			INNER JOIN @searchstringDistributions ss ON (dl.[VcDistributionGroupName] LIKE '%'+ss.GroupName+'%')
			   
			IF EXISTS(SELECT 1  FROM @searchstringDistributions  WHERE  GroupName<>'' AND  DistributionCustomMemberID>0  AND MemberName=''  AND EmailAddress='' )
			BEGIN	
				INSERT INTO #searchlist	
				SELECT [IntDistributionGroupID]
				  ,[VcDistributionGroupName]
				  ,[BitIsActive]
				  ,DtCreatedDate	  
				FROM [cmrf].[TBL_DistributionLists] dl  WITH(NOLOCK)
				INNER JOIN @searchstringDistributions ss ON (dl.[VcDistributionGroupName] LIKE '%'+ss.GroupName+'%')
				ORDER BY dl.[IntDistributionGroupID]
			END
			IF EXISTS(SELECT 1 FROM @searchstringDistributions WHERE [DistributionCustomMemberID]='' 
			AND [GroupName]='' AND [MemberName]='' AND EmailAddress='' AND ISNULL([Status],'') = '')
			BEGIN
			SELECT DISTINCT TOP 50 [IntDistributionGroupID],[VcDistributionGroupName],[BitIsActive],DtCreatedDate FROM #searchlist WHERE BitIsActive=1 ORDER BY DtCreatedDate DESC
			END
			ELSE
			BEGIN
			SELECT DISTINCT [IntDistributionGroupID],[VcDistributionGroupName],[BitIsActive],DtCreatedDate FROM #searchlist SL
			INNER JOIN @searchstringDistributions SS ON SL.BitIsActive = SS.[Status] ORDER BY DtCreatedDate DESC
			END
		END
	END

	--IF @VcActionCode ='distributionCustom.get.selected.columns01'
	--BEGIN
	--	DECLARE @searchstringDistributionCustom  TABLE 
	--	(
	--		[queryType]						VARCHAR(50),
	--		[DistributionCustomMemberID]	INT,
	--		[DisplayName]					VARCHAR(100)
	--	)
	--	INSERT  INTO @searchstringDistributionCustom(queryType,DistributionCustomMemberID,DisplayName)
	--	SELECT 
	--		LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) [queryType],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionCustomMemberID','VARCHAR(50)'))),'') [DistributionCustomMemberID],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@DisplayName','VARCHAR(50)'))),'') [DisplayName]
	--	FROM @XmSearchString.nodes('//row') tab(col) 
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionCustom WHERE queryType='GET.SINGLE')
	--	BEGIN
	--		SELECT [IntDistributionCustomMemberID]
	--			,[IntDistributionGroupID]
	--			,[VcDisplayName]
	--			,[VcEmailAddress]
	--		FROM [cmrf].[TBL_DistributionListCustomMembers] cm WITH(NOLOCK)
	--		INNER JOIN @searchstringDistributionCustom ss ON ( cm.[IntDistributionCustomMemberID]=ss.DistributionCustomMemberID)
	--	END
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionCustom WHERE queryType='GET.MULTIPLE')
	--	BEGIN
	--		SELECT dc.[IntDistributionCustomMemberID]
	--			,dc.[IntDistributionGroupID]
	--			,dc.[VcDisplayName]
	--			,dc.[VcEmailAddress]
	--		FROM [cmrf].[TBL_DistributionListCustomMembers] dc WITH(NOLOCK)
	--		INNER JOIN @searchstringDistributionCustom sd ON (dc.[VcDisplayName] LIKE '%'+sd.DisplayName+'%'OR ISNULL(sd.DisplayName,'')='')
	--		ORDER BY dc.[IntDistributionCustomMemberID]
	--	END
	--END

	--IF @VcActionCode ='distributionAD.get.selected.columns01'
	--BEGIN
	--	DECLARE @searchstringDistributionAD  TABLE 
	--	(
	--		[queryType]					VARCHAR(50),
	--		[DistributionMemberID]		INT,
	--		[BusinessEntityID]			INT
	--	)
	--	INSERT  INTO @searchstringDistributionAD(queryType,DistributionMemberID,BusinessEntityID)
	--	SELECT 
	--		LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) [queryType],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionMemberID','VARCHAR(50)'))),'') [DistributionMemberID],
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@BusinessEntityID','INT'))),0) [BusinessEntityID]
	--	FROM @XmSearchString.nodes('//row') tab(col) 
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionAD WHERE queryType='GET.SINGLE')
	--	BEGIN
	--		SELECT [IntDistributionMemberID]
	--			,[IntDistributionGroupID]
	--			,[IntBusinessEntityID]
	--		FROM  [cmrf].[TBL_DistributionListADMembers] am WITH(NOLOCK)
	--		INNER JOIN @searchstringDistributionAD ss ON (am.[IntDistributionMemberID]=ss.DistributionMemberID)
	--	END
		
	--	IF EXISTS(SELECT 1 FROM @searchstringDistributionAD WHERE queryType='GET.MULTIPLE')
	--	BEGIN
	--		SELECT da.[IntDistributionMemberID]
	--			,da.[IntDistributionGroupID]
	--			,da.[IntBusinessEntityID]
	--		FROM  [cmrf].[TBL_DistributionListADMembers] da WITH(NOLOCK)
	--		INNER JOIN @searchstringDistributionAD sd ON (da.[IntBusinessEntityID]=sd.BusinessEntityID OR ISNULL(sd.BusinessEntityID,'')='')
	--		ORDER BY da.[IntDistributionMemberID]
	--	END			
	--END
	
	IF @VcActionCode ='distributionAll.get.selected.columns01'
	BEGIN
		DECLARE @searchstringDistributionAll  TABLE 
		(
			[queryType]					VARCHAR(50),
			[DistributionGroupID]		INT,
			[DistributionGroupName]		VARCHAR(50)
		)
		INSERT  INTO @searchstringDistributionAll(queryType,DistributionGroupID)
		SELECT 
			LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) [queryType],
			ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionGroupID','VARCHAR(50)'))),0) [DistributionGroupID]
		FROM @XmSearchString.nodes('//row') tab(col) 
		
		IF EXISTS(SELECT 1 FROM @searchstringDistributionAll WHERE queryType='GET.SINGLE')
		BEGIN
			SELECT [IntDistributionGroupID]
				,[VcDistributionGroupName]
				,[BitIsActive]
				,[DtLastUpdatedOn]
			FROM [cmrf].[TBL_DistributionLists] dl WITH(NOLOCK) 
			INNER JOIN @searchstringDistributionAll ss ON (dl.[IntDistributionGroupID]=ss.DistributionGroupID)
			
			SELECT [IntDistributionCustomMemberID]
				,[IntDistributionGroupID]
				,[VcDisplayName]
				,[VcEmailAddress]
			FROM [cmrf].[TBL_DistributionListCustomMembers] cm WITH(NOLOCK)
			INNER JOIN @searchstringDistributionAll ss ON (cm.[IntDistributionGroupID]=ss.DistributionGroupID)		
			
			SELECT [IntDistributionMemberID]
				,[IntDistributionGroupID]
				,AD.[IntBusinessEntityID]
				,CONCAT(ISNULL(TP.VcFirstName,''),' ',ISNULL(TP.VcLastName,'')) AS VcDisplayName
				,TEA.VcPrimaryEmailAddressID AS VcEmailAddress
			FROM [cmrf].[TBL_DistributionListADMembers] ad WITH(NOLOCK)
			INNER JOIN [ACS].[tbl_Person] TP WITH(NOLOCK) ON AD.IntBusinessEntityID = TP.IntBusinessEntityID
			INNER JOIN [acs].[TBL_EmailAddress] TEA on TP.IntBusinessEntityID=TEA.IntBusinessEntityID
			INNER JOIN @searchstringDistributionAll ss ON (ad.[IntDistributionGroupID]=ss.DistributionGroupID)
		END
	END
	
	--IF @VcActionCode ='distributionMember.get.selected.columns01'
	--BEGIN
	--	DECLARE @searchstringDist  TABLE 
	--	(
	--		[queryType]					VARCHAR(50),
	--		[DistributionGroupID]		INT
	--	)
	--	INSERT  INTO @searchstringDist(queryType,DistributionGroupID)
	--	SELECT 
	--		LTRIM(RTRIM(tab.col.value('@queryType','VARCHAR(50)'))) queryType,
	--		ISNULL(LTRIM(RTRIM(tab.col.value('@DistributionGroupID','VARCHAR(50)'))),'') DistributionGroupID
	--	FROM @XmSearchString.nodes('//row') tab(col) 
		
	--	IF EXISTS(SELECT 1 FROM [cmrf].[TBL_DistributionListCustomMembers] cu WITH(NOLOCK)
	--	INNER JOIN @searchstringDist ss ON cu.[IntDistributionGroupID]=ss.[DistributionGroupID])
	--	BEGIN
	--		SELECT [IntDistributionCustomMemberID]
	--			,[IntDistributionGroupID]
	--			,[VcDisplayName]
	--			,[VcEmailAddress]
	--		FROM [cmrf].[TBL_DistributionListCustomMembers] cm WITH(NOLOCK)
	--		INNER JOIN @searchstringDist ss ON (cm.[IntDistributionGroupID]=ss.DistributionGroupID)
	--	END
		
	--	IF EXISTS(SELECT 1 FROM [cmrf].[TBL_DistributionListADMembers] cu WITH(NOLOCK)
	--	INNER JOIN @searchstringDist ss ON cu.[IntDistributionGroupID]=ss.[DistributionGroupID])
	--	BEGIN				
	--		SELECT [IntDistributionMemberID]
	--			  ,[IntDistributionGroupID]
	--			  ,[IntBusinessEntityID]
	--		FROM  [cmrf].[TBL_DistributionListADMembers] am WITH(NOLOCK)
	--		INNER JOIN @searchstringDist ss ON (am.[IntDistributionGroupID]=ss.DistributionGroupID)
	--	END		
	--END

	
	
	
END

/*
--------------------address.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
  @VcActionCode			='address.get.all.lines'
 ,@IntSuccess			=@IntSuccess OUTPUT
 ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

--------------------funds.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='funds.get.all.lines'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

---------------------entity.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]  
   @VcActionCode		='entity.get.all.lines'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------clients.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='clients.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------CustodianAccount.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
  @VcActionCode			='CustodianAccount.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------CustodianAccount.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='CustodianAccount.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" listMode="Exact" CustodianAccountID="1" ClientDefinitionID="1" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT


----------------------CustodianAccount.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='CustodianAccount.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" CustodianAccountCode="EMS" CustodianAccountName="BARCLA" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------clients.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='clients.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------GET.SINGLE: clients.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='clients.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" ClientDefinitionID="149"/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------GET.MULTIPLE: clients.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='clients.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" ClientName="CTS"  ClientShortCode="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------businessunit.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='businessunit.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------subbusinessunit.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='subbusinessunit.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------strategy.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='strategy.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------GET.ALL: country.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='country.get.all.lines'
  ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT
  
----------------------exchange.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='exchange.get.all.lines'
   ,@XmSearchString=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------calendar.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='calendar.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------businessunit.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode='businessunit.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" BusinessUnitcode="a"  BusinessUnitDescription=""   />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------subbusinessunit.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='subbusinessunit.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" [IntBusinessUnitID]="5"    />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------strategy.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='strategy.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" StrategyCode=""  StrategyDescription="HU"   />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------businessunit.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='businessunit.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" BusinessUnitID="10"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------subbusinessunit.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='subbusinessunit.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" [IntBusinessUnitID]="5"    />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------strategy.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='strategy.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" StrategyID="1"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------exchange.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='exchange.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" ExchangeID="5"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------exchange.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='exchange.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" Exchangeshortcode="UK" ExchangeName="RBFF_6766" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------Portfolio.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='Portfolio.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" Calendarname="" CalendarDesc="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------calendar.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='calendar.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" CalendarId="1"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT



----------------------calendar.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='calendar.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" Calendarname=""  CalendarDesc="" Date="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------custom.Columns.Ref.master.all

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='custom.Columns.Ref.master.all'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------custodian.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='custodian.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType "GET.MULTIPLE" CustodianCode=""  CustodianName=""  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------industry.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='industry.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" SinIndustryID="1"/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------industry.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='industry.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" IndustryCode="BONY" IndustryDescription="CITIDDDD1" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message
  
----------------------industrygroup.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='industrygroup.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" IndustryGroupID="3"    />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------industrygroup.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='industrygroup.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" IndustryGroupCode="BONY" IndustryGroupDescription="CITIDDDD1" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message
	
----------------------alert.messsages.application

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='alert.messsages.application'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------fundfamily.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='fundfamily.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" FundFamilycode="bb"  FundFamilyName=""/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------distributionListADMembers.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionListADMembers.get.all.lines'
   ,@XmSearchString		=''
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------distribution.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='distribution.get.all.lines'
   ,@XmSearchString		=''
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

SELECT @IntSuccess, @VcError_Message

----------------------distributionCustom.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionCustom.get.selected.columns01'
      ,@XmSearchString	='<searchstring>
						<row queryType=	"GET.SINGLE" DistributionCustomMemberID="57"  />
						</searchstring>'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT
  ----------------------distribution.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distribution.get.selected.columns01'
      ,@XmSearchString	='<searchstring><row queryType = "GET.MULTIPLE" IntDistributionCustomMemberID="" GroupName="" MemberName=""  EmailAddress="" Status="" /></searchstring>'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT
------

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
    @VcActionCode		='CustodianDetails.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" ClientDefinitionID="153" />
						</searchstring>'
   ,@IntSuccess			=@IntSuccess OUTPUT
   ,@VcError_Message	=@VcError_Message OUTPUT


---------------ActiveCustodian.get.all.lines


DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='ActiveCustodians.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" CustodianID="13"  />
						</searchstring>'
   ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

------
  --SELECT * FROM [cmrf].[TBL_Custodian]


----------------------GenevaInstance.get.all.lines---------

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='GenevaInstance.get.all.lines'
  ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

---------

SELECT * FROM [config].[TBL_GenevaInstance]


----------------------sunindustry.get.selected.columns01---------

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='subindustry.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" SinSubIndustryID="9"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT



--------------------GET.SINGLE: distributionInfo.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionInfo.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" DistributionInfoID=""  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

--------------------GET.MULTIPLE: distributionInfo.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionInfo.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" ModuleID="" ScreenID=""  ClientName=""  CustodianName="" CustodianAccountName="" Status="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------GET.ALL: country.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='country.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" CountryID="1"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------GET.ALL: country.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='country.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" CountryName="AF"  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------GET.ALL: currency.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='currency.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT


----------------------GET.SINGLE: currency.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='currency.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.SINGLE" CurrencyID="1"   />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------GET.MULTIPLE: currency.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='currency.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" CurrencyName="" CurrencyCode="" BloombergCurrencyName=""  />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------------------

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActiveCustodiansAccounts.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						  <row queryType="GET.SINGLE" ClientDefinitionID="146" AccountType="Trading" PortfolioID="8"/>
						  </searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT
 
  ---=================================
  DECLARE @RC int, @actionCode varchar(100), @success int, @error_message varchar(1000)

EXECUTE @RC= [cmrf].[stp_GetRefInfo]
   @VcActionCode='distributionlist.get.selected.columns02'
   
   ,@XmSearchString='<searchstring><row queryType = "GET.MULTIPLE" ModuleCode="WIRE" ScreenCode="WIRETRANSFER" VcActionCode="CREATE" 

VcDistributionType="Internal" ClientDefinitionID="146" PortfolioID="8"/></searchstring>'
   
  ,@IntSuccess=@success OUTPUT
  ,@VcError_Message=@error_message OUTPUT


-------------------GET ALL: CustodianAccountPortfolioLink.Columns.Ref.master.all

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='CustodianAccountPortfolioLink.Columns.Ref.master.all'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET SINGLE: CustodianAccountPortfolioLink.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='CustodianAccountPortfolioLink.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						  <row queryType="GET.SINGLE" CustodianAccountPortfolioLinkID="1"/>
						  </searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET MULTIPLE: CustodianAccountPortfolioLink.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='CustodianAccountPortfolioLink.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						  <row queryType="GET.MULTIPLE" PortfolioID="" CustodianAccountID=""/>
						  </searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT


---------------------------ClientAndPortfolio.get.all.lines
DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ClientAndPortfolio.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET SINGLE: LookUpValues.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='LookUpValues.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						  <row queryType="GET.SINGLE" VcColumnValues=""/>
						  </searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET MULTIPLE: LookUpValues.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='LookUpValues.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						  <row queryType="GET.SINGLE" VcColumnTypes="LegalEntityTypeDetails"/>
						  </searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET ALL: ActiveClients.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActiveClients.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET ALL: ActiveFundFamily.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActiveFundFamily.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT
 
-------------------GET ALL: ActivePortfolio.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActivePortfolio.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET ALL: ActiveCurrency.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActiveCurrency.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

-------------------GET ALL: ActiveCountry.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='ActiveCountry.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT


---------------------

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo]
   @VcActionCode		='broker.get.selected.columns01'
   ,@XmSearchString		='<searchstring><row queryType = "GET.MULTIPLE" BrokerType="Broker-Clearing" BitIsActive="True" /></searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT  


--------------------GET.SINGLE: distributionInfo.get.selected.columns01
DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionInfo.get.selected.columns01'
  ,@XmSearchString		='<searchstring><row queryType = "GET.SINGLE" DistributionInfo="33" /></searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT


--------------------GET.MULTIPLE: distributionInfo.get.selected.columns01
DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [VUCommRef].[cmrf].[STP_GetRefInfo] 
   @VcActionCode		='distributionInfo.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" ModuleID="" ScreenID=""  ClientName=""  CustodianName="CITIBANK" CustodianAccountName="" Status="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------CounterParty.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='CounterParty.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------CounterParty.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='CounterParty.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" IntCounterPartyID="2" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------CounterParty.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='CounterParty.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" VcCounterPartyCode="" VcCounterPartyName="CITI Group" BitIsActive="1"/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FundAdmin.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='FundAdmin.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FundAdmin.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='FundAdmin.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" IntFundAdminID="1" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FundAdmin.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='FundAdmin.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" VcFundAdminCode="" VcFundAdminName="" BitIsActive="1"/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FCM.get.all.lines

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='FCM.get.all.lines'
   ,@XmSearchString		=''
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FCM.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo] 
   @VcActionCode		='FCM.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.SINGLE" IntFCMID="1" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------FCM.get.selected.columns01

DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetRefInfo]
   @VcActionCode		='FCM.get.selected.columns01'
   ,@XmSearchString		='<searchstring>
						<row queryType=	"GET.MULTIPLE" VcFCMCode="" VcFCMName="" BitIsActive="1"/>
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

----------------------distributionInfo.get.selected.columns01----------------------------
DECLARE @RC INT,@VcActionCode VARCHAR(100),@IntSuccess INT,@VcError_Message VARCHAR(1000)

EXECUTE @RC				= [cmrf].[STP_GetUserGroupInfo] 
   @VcActionCode		='distributionInfo.get.selected.columns01'
  ,@XmSearchString		='<searchstring>
						<row queryType="GET.MULTIPLE" ModuleID="" ScreenID=""  ClientName=""  CustodianName="" CustodianAccountName="" Status="" />
						</searchstring>'
  ,@IntSuccess			=@IntSuccess OUTPUT
  ,@VcError_Message		=@VcError_Message OUTPUT

*/
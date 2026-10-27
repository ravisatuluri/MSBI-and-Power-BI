USE [VUWireTransfer]
GO
/****** Object:  StoredProcedure [wr].[STP_InsertUpdate_WireBasicInfo]    Script Date: 30-05-2016 14:07:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [wr].[STP_InsertUpdate_WireBasicInfo]   
AS
    BEGIN TRY
        SET NOCOUNT ON;
		MERGE INTO  [wr].[TBL_WireBasicInfo] AS T
		USING  
		(	
			SELECT A.[SourceModuleID]
				,A.[UniqueID]
				,VB.[IntClientDefinitionID]
				,VC.[IntPortfolioID]
				,VD.[IntCustodianAccountID]
				,VE.[SinCurrencyID]
				,A.[ActionType]
				,A.[ValueDate]
				,A.[Amount]
				,A.[ValidStatus]
				,A.[Guid]
			FROM [localdb].[tbl_WireBasicInfo] A
			INNER JOIN  [cmrf].[TBL_UAT_VW_Clients] B ON B.intClient = A.ClientDefinitionID
			INNER JOIN  [setup].[tbl_portfolionames] C ON C.intPortFolioID = A.PortfolioID
			INNER JOIN  [setup].[tbl_CustodianAccount] D ON D.intCustodianAccountID = A.CustodianAccountID
			INNER JOIN  [setup].[tbl_Currency] E ON E.intRecID = A.CurrencyID
			INNER JOIN  [cmrf].[TBL_Client] VB ON VB.VcClientShortCode = B.vcClientShortCode
			INNER JOIN  [cmrf].[TBL_Portfolio] VC ON VC.VcPortfolioShortCode = C.vcPortFolioShortCode -- AND VC.IntClientDefinitionID = VB.IntClientDefinitionID
			INNER JOIN  [cmrf].[TBL_Custodian_Account] VD ON VD.VcCustodianAccountCode = D.vcCustodianAccountCode
			INNER JOIN  [cmrf].[TBL_Currency] VE ON VE.VcCurrencyCode COLLATE SQL_Latin1_General_CP1_CS_AS = E.vcCurrencyshortcode COLLATE SQL_Latin1_General_CP1_CS_AS
		) AS S   
		ON T.[GUID]=S.[GUID]
		WHEN NOT MATCHED THEN
		INSERT([GUID],[TinSourceModuleID],[VcUniqueID],[IntUniqueID],[IntClientDefinitionID],[IntPortfolioID],[IntCustodianAccountID],[SinCurrencyID],[VcActionType],[DtValueDate],[DecAmount],[BitValidStatus],DtLastUpdatedTime,[DtCreatedDate])
		VALUES(S.[GUID],S.[SourceModuleID],S.[UniqueID],0,S.[IntClientDefinitionID],S.[IntPortfolioID],S.[IntCustodianAccountID],S.[SinCurrencyID],S.[ActionType],S.[ValueDate],S.[Amount],S.[ValidStatus],GETDATE(),GETDATE())	
		WHEN MATCHED THEN
		UPDATE SET			
		 [TinSourceModuleID]		=S.[SourceModuleID]
		,[VcUniqueID]				=S.[UniqueID]
		,[IntUniqueID]				=0
		,[InTClientDefinitionID]	=S.[InTClientDefinitionID]
		,[InTPortfolioID]			=S.[InTPortfolioID]
		,[IntCustodianAccountID]	=S.[IntCustodianAccountID]
		,[SinCurrencyID]			=S.[SinCurrencyID]
		,[VcActionType]				=S.[ActionType]
		,[DtValueDate]				=S.[ValueDate]
		,[DeCAmount]				=S.[Amount]
		,[BitValidStatus]			=S.[ValidStatus]
		,DtLastUpdatedTime			=GETDATE();

    END TRY
    BEGIN CATCH
        EXEC [err].[STP_LogError];
    END CATCH;        





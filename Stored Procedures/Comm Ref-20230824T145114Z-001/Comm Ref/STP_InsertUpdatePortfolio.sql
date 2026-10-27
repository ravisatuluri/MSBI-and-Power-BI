--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_InsertUpdatePortfolio](
	@BintPortfolioID											BIGINT			=NULL,
	@BintClientDefinitionID										BIGINT			=NULL,		
	@IntFundFamilyID											INT				=NULL,
	@VcLegalEntityID											VARCHAR(20)		=NULL,
	@VcLegalEntityType											VARCHAR(250)	=NULL,
	@VcFundDomicile												VARCHAR(250)	=NULL,
	@VcPortfolioShortCode										VARCHAR(50)		=NULL,
	@VcPortfolioName											VARCHAR(250)	=NULL,
	@VcUnitizedOrNonUnitized									VARCHAR(250)	=NULL,
	@VcFundType													VARCHAR(250)	=NULL,
	@IntBaseCurrency											INT				=NULL,
	@TinCalendarId												TINYINT			=NULL,
	@DtIncorporationOrFormationDate								DATE			=NULL,
	@DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate	DATE			=NULL,
	@BitIsActive												BIT				=NULL,
	@VcCollateralOwnership										VARCHAR(250)	=NULL,
	@VcOpenOrClosedEnded										VARCHAR(250)	=NULL,
	@VcShareDecimalsForCalculations								VARCHAR(250)	=NULL,
	@VcShareDecimalsDisplay										VARCHAR(250)	=NULL,
	@VcNAVDecimalsForCalculation								VARCHAR(250)	=NULL,
	@VcNAVDecimalsDisplay										VARCHAR(250)	=NULL,
	@VcInvestmentStrategy										VARCHAR(250)	=NULL,
	@VcCity														VARCHAR(50)		=NULL,
	@IntCountry													INT				=NULL,
	@VcSharePartnerClassID										VARCHAR(50)		=NULL,
	@VcSharePartnerClassDescription								VARCHAR(250)	=NULL,
	@VcSeriesID													VARCHAR(50)		=NULL,
	@VcSeriesDescription										VARCHAR(250)	=NULL,
	@TinGenevaID												TINYINT			=NULL,
	@VcAccountingCalendar										VARCHAR(100)	=NULL,
	@BitOperFlag												BIT				=NULL,
	@XmCustomColValues											XML				=NULL,
---------------------------------Common Columns---------------------------------
	@IntSuccess													INT				OUTPUT,
	@VcError_Message											VARCHAR(1000)	OUTPUT
---------------------------------Common Columns---------------------------------
)AS

DECLARE @IDENTITY INT=0,@IntMsgID INT,@internal_success INT,@internal_error_message VARCHAR(1000),@IntUserID INT,@DtActionDate DATETIME
BEGIN TRY
	IF OBJECT_ID('tempdb..#Sessiondata') IS NOT NULL
	BEGIN
		SELECT @IntUserID=IntUserID,@DtActionDate=DtActionDate FROM #Sessiondata
	END
	BEGIN TRAN T1
		SET NOCOUNT ON
		SET @IntSuccess=0
		IF @BitOperFlag =0
		BEGIN
			IF LEN(@VcPortfolioShortCode)>0 AND LEN(@VcPortfolioName)>0
			BEGIN
				SET @IntSuccess=1
				INSERT INTO [cmrf].[TBL_Portfolio]
						([IntClientDefinitionID],[IntFundFamilyID],[VcLegalEntityID],[VcLegalEntityType],[VcFundDomicile],[VcPortfolioShortCode],[VcPortfolioName],[VcUnitizedOrNonUnitized],[VcFundType],[IntBaseCurrency],[TinCalendarId],[DtIncorporationOrFormationDate],
						 [DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate],[BitIsActive],[VcCollateralOwnership],[VcOpenOrClosedEnded],[VcShareDecimalsForCalculations],[VcShareDecimalsDisplay],[VcNAVDecimalsForCalculation],[VcNAVDecimalsDisplay],
						 [VcInvestmentStrategy],[VcCity],[IntCountry],[VcSharePartnerClassID],[VcSharePartnerClassDescription],[VcSeriesID],[VcSeriesDescription],[SinGenevaID],IntCreatedBy_IntBusinessEntityID,DtCreatedDate,VcAccountingCalendar)
				VALUES  (@BintClientDefinitionID,@IntFundFamilyID,@VcLegalEntityID,@VcLegalEntityType,@VcFundDomicile,@VcPortfolioShortCode,											
						@VcPortfolioName,@VcUnitizedOrNonUnitized,@VcFundType,@IntBaseCurrency,@TinCalendarId,@DtIncorporationOrFormationDate,@DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate,		
						@BitIsActive,@VcCollateralOwnership,@VcOpenOrClosedEnded,@VcShareDecimalsForCalculations,@VcShareDecimalsDisplay,@VcNAVDecimalsForCalculation,									
						@VcNAVDecimalsDisplay,@VcInvestmentStrategy,@VcCity,@IntCountry,@VcSharePartnerClassID,@VcSharePartnerClassDescription,@VcSeriesID,@VcSeriesDescription,@TinGenevaID,@IntUserID,@DtActionDate,@VcAccountingCalendar)
					
				-------------- Region FOR Custom Columns @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				IF @IntSuccess=1
				BEGIN	
					SET @IntSuccess=1
					SET @IntMsgID =200038
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
					IF @XmCustomColValues IS NOT NULL
					BEGIN
						BEGIN TRY
								EXEC cmrf.STP_referenceMasterUpdateCustColumnALL 
								@VcReferenceMasterName	='Portfolio',
								@XmCustomColValues		=@XmCustomColValues,
								@BintLineReference		=@BintPortfolioID,
								@IntSuccess				=@internal_success	OUTPUT,
								@VcError_Message		=@internal_error_message	OUTPUT
						END TRY
						BEGIN CATCH
							EXEC err.STP_LogError
							SET @IntSuccess = -1 * ERROR_NUMBER()
							SET @VcError_Message = ERROR_MESSAGE()     
						END CATCH
					END
				END
				-----------------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END
		IF @BitOperFlag =1
		BEGIN
			IF LEN(@VcPortfolioShortCode)>0 AND LEN(@VcPortfolioName)>0 AND @BintPortfolioID>0
			BEGIN
				SET @IntSuccess=1
				UPDATE [cmrf].[TBL_Portfolio]
				SET 
				 IntClientDefinitionID										= @BintClientDefinitionID											
				,IntFundFamilyID											= @IntFundFamilyID												
				,VcLegalEntityID											= @VcLegalEntityID												
				,VcLegalEntityType											= @VcLegalEntityType											
				,VcFundDomicile												= @VcFundDomicile												
				,VcPortfolioShortCode										= @VcPortfolioShortCode											
				,VcPortfolioName											= @VcPortfolioName												
				,VcUnitizedOrNonUnitized									= @VcUnitizedOrNonUnitized										
				,VcFundType													= @VcFundType													
				,IntBaseCurrency											= @IntBaseCurrency		
				,TinCalendarId										        = @TinCalendarId
				,DtIncorporationOrFormationDate								= @DtIncorporationOrFormationDate								
				,DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate	= @DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate		
				,BitIsActive												= @BitIsActive													
				,VcCollateralOwnership										= @VcCollateralOwnership										
				,VcOpenOrClosedEnded										= @VcOpenOrClosedEnded											
				,VcShareDecimalsForCalculations								= @VcShareDecimalsForCalculations								
				,VcShareDecimalsDisplay										= @VcShareDecimalsDisplay										
				,VcNAVDecimalsForCalculation								= @VcNAVDecimalsForCalculation									
				,VcNAVDecimalsDisplay										= @VcNAVDecimalsDisplay											
				,VcInvestmentStrategy										= @VcInvestmentStrategy											
				,VcCity														= @VcCity														
				,IntCountry													= @IntCountry													
				,VcSharePartnerClassID										= @VcSharePartnerClassID										
				,VcSharePartnerClassDescription								= @VcSharePartnerClassDescription								
				,VcSeriesID													= @VcSeriesID													
				,VcSeriesDescription										= @VcSeriesDescription
				,SinGenevaID												= @TinGenevaID
				,VcAccountingCalendar										= @VcAccountingCalendar
				,[IntModifiedBy_IntBusinessEntityID]						= @IntUserID
				,[DtModifiedDate]											= @DtActionDate
				WHERE [IntPortfolioID]	=	@BintPortfolioID
				-------------- Region FOR Custom Columns @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				IF @IntSuccess=1
				BEGIN
					SET @IntSuccess=1
					SET @IntMsgID =200039
					SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
					IF @XmCustomColValues IS NOT NULL
					BEGIN
						BEGIN TRY
								EXEC cmrf.STP_referenceMasterUpdateCustColumnALL 
								@VcReferenceMasterName	='Portfolio',
								@XmCustomColValues		=@XmCustomColValues,
								@BintLineReference		=@BintPortfolioID,
								@IntSuccess				=@internal_success			OUTPUT,
								@VcError_Message		=@internal_error_message	OUTPUT
						END TRY
						BEGIN CATCH
							EXEC err.STP_LogError
							SET @IntSuccess = -1 * ERROR_NUMBER()
							SET @VcError_Message = ERROR_MESSAGE()     
						END CATCH
					END
				END
				-----------------------------------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			END
			ELSE
			BEGIN
				SET @IntSuccess=-1
				SET @IntMsgID =100002
				SET @VcError_Message = ISNULL(err.FnGetErrorMessage(@IntMsgID),'')
			END
		END
	COMMIT TRAN T1
END TRY
BEGIN CATCH
	IF ERROR_NUMBER()=2601
	BEGIN
		SET @VcError_Message='Portfolio Name Already Exists. Please Try With a Different Name.'
	END
	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRAN T1
	END
	EXEC err.STP_LogError
	SET @IntSuccess = -1 * ERROR_NUMBER()    
	SET @VcError_Message = ERROR_MESSAGE() 
END CATCH

/*
-------------------------TO INSERT-----------------------------

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdatePortfolio]
 @BintPortfolioID								=32											
,@BintClientDefinitionID						=1										
,@IntFundFamilyID								=1											
,@VcLegalEntityID								=1											
,@VcLegalEntityType								=''										
,@VcFundDomicile								=''											
,@VcPortfolioShortCode							='CGMF'							
,@VcPortfolioName								='CGMF'											
,@VcUnitizedOrNonUnitized						=''									
,@VcFundType									=''												
,@IntBaseCurrency								=''	
,@TinCalendarId									=1
,@DtIncorporationOrFormationDate				=''							
,@DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate=''	
,@BitIsActive									=1												
,@VcCollateralOwnership							=''									
,@VcOpenOrClosedEnded							=''										
,@VcShareDecimalsForCalculations				=''							
,@VcShareDecimalsDisplay						=''									
,@VcNAVDecimalsForCalculation					=''								
,@VcNAVDecimalsDisplay							=''										
,@VcInvestmentStrategy							=''										
,@VcCity										=''													
,@IntCountry									=''												
,@VcSharePartnerClassID							=''									
,@VcSharePartnerClassDescription				=''							
,@VcSeriesID									=''												
,@VcSeriesDescription							=''
,@TinGenevaID									=1
,@VcAccountingCalendar							=''								
,@BitOperFlag									=0
--------------------
,@IntSuccess									=@IntSuccess OUTPUT
,@VcError_Message								=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message


-------------------------TO UPDATE-----------------------------

DECLARE @IntSuccess  INT,@VcError_Message   VARCHAR(1000)
EXEC [cmrf].[STP_InsertUpdatePortfolio]
 @BintPortfolioID								=32											
,@BintClientDefinitionID						=1										
,@IntFundFamilyID								=1											
,@VcLegalEntityID								=1											
,@VcLegalEntityType								=''										
,@VcFundDomicile								=''											
,@VcPortfolioShortCode							='CGMF'							
,@VcPortfolioName								='CGMF'											
,@VcUnitizedOrNonUnitized						=''									
,@VcFundType									=''												
,@IntBaseCurrency								=''	
,@TinCalendarId									=1
,@DtIncorporationOrFormationDate				=''							
,@DtInitialOfferingDateOrEffectiveStartDateOrInceptionDate=''	
,@BitIsActive									=1												
,@VcCollateralOwnership							=''									
,@VcOpenOrClosedEnded							=''										
,@VcShareDecimalsForCalculations				=''							
,@VcShareDecimalsDisplay						=''									
,@VcNAVDecimalsForCalculation					=''								
,@VcNAVDecimalsDisplay							=''										
,@VcInvestmentStrategy							=''										
,@VcCity										=''													
,@IntCountry									=''												
,@VcSharePartnerClassID							=''									
,@VcSharePartnerClassDescription				=''							
,@VcSeriesID									=''												
,@VcSeriesDescription							=''	
,@TinGenevaID									=1
,@VcAccountingCalendar							=''							
,@BitOperFlag									=1
--------------------
,@IntSuccess									=@IntSuccess OUTPUT
,@VcError_Message								=@VcError_Message OUTPUT

SELECT @IntSuccess,@VcError_Message

*/



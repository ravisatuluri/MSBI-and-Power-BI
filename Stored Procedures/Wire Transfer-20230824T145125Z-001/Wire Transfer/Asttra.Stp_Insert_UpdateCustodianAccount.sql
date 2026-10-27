-- =============================================

-- Author:		VMSSanthosh

----Modified by Sujith M to update the push to geneva status

-- Create date: 2009-04-06

-- Description:	Insert/Update CounterParty Details

-- =============================================

ALTER PROCEDURE [setup].[stp_Insert_UpdateCustodianAccount]

(

    @intCustodianAccountID int=NULL,

    @vcCustodianAccountCode varchar(200)=NULL,

    @vcCustodianAccountName1 varchar(200)=NULL,

    @vcCustodianAccountName2 varchar(200)=NULL,

    @vcSalutation varchar(20)=NULL,

    @intCustodianID int=NULL,

    @vcAddress1 varchar(200)=NULL,

    @vcAddress2 varchar(200)=NULL,

    @vcCity varchar(100)=NULL,

    @vcState varchar(100)=NULL,

    @vcPostalCode varchar(30)=NULL,

    @vcCountry varchar(100)=NULL,

    @vcCountryCode1 varchar(10)=NULL,

    @vcAreaCode1 varchar(10)=NULL,

    @vcTelephone1 varchar(20)=NULL,

    @vcCountryCode2 varchar(10)=NULL,

    @vcAreaCode2 varchar(10)=NULL,

    @vcTelephone2 varchar(20)=NULL,

    @vcCountryCode3 varchar(10)=NULL,

    @vcAreaCode3 varchar(10)=NULL,

    @vcTelephone3 varchar(20)=NULL,

    @vcCountryCode4 varchar(10)=NULL,

    @vcAreaCode4 varchar(10)=NULL,

    @vcTelephone4 varchar(20)=NULL,

    @vcEmail varchar(200)=NULL,

    @bitIsActive bit=NULL,

    @TypeofAccount varchar(50)=NULL,

    @LinkedCustodianAccount varchar(50)=NULL,

    @PID bigint OUTPUT,

    @intSuccess int OUTPUT,

    @msg varchar(2000) OUTPUT,

    @UserID int=NULL,

    @vcHostName varchar(200)=NULL,

    @xmlPushStatus xml =NULL

)

AS

BEGIN

	DECLARE @success int,@error_message varchar(1000),@master_name varchar(20)



    SET @intSuccess=0

    SET @msg=''

    BEGIN TRY

    IF @xmlPushStatus IS NULL

    BEGIN

        IF @intCustodianAccountID IS NULL OR @intCustodianAccountID=0

            BEGIN

                INSERT INTO setup.tbl_CustodianAccount

                    (vcCustodianAccountCode,vcCustodianAccountName1,vcCustodianAccountName2,vcSalutation,intCustodianID,vcAddress1,vcAddress2,vcCity,vcState,

                     vcPostalCode,vcCountry,vcCountryCode1,vcAreaCode1,vcTelephone1,vcCountryCode2,vcAreaCode2,vcTelephone2,vcCountryCode3,

                     vcAreaCode3,vcTelephone3,vcCountryCode4,vcAreaCode4,vcTelephone4,vcEmail,

                     TypeofAccount,

                     LinkedCustodianAccount,

                     bitIsActive,UserID,vcHostName)

                    VALUES

                    (@vcCustodianAccountCode,@vcCustodianAccountName1,@vcCustodianAccountName2,@vcSalutation,@intCustodianID,@vcAddress1,@vcAddress2,@vcCity,@vcState,@vcPostalCode,

                     @vcCountry,@vcCountryCode1,@vcAreaCode1,@vcTelephone1,@vcCountryCode2,@vcAreaCode2,@vcTelephone2,@vcCountryCode3,

                     @vcAreaCode3,@vcTelephone3,@vcCountryCode4,@vcAreaCode4,@vcTelephone4,@vcEmail,

                     @TypeofAccount,

                     @LinkedCustodianAccount,

                     @bitIsActive,@UserID,@vcHostName)

                SET @PID=@@IDENTITY;

					EXECUTE  [setup].[stp_DataSync_RefMasters] 

					 @master_name='CUSTODIANACCOUNT'

					,@success=@success OUTPUT

					,@error_message=@error_message OUTPUT

            END

        ELSE

            BEGIN

                UPDATE setup.tbl_CustodianAccount

                    SET vcCustodianAccountCode=@vcCustodianAccountCode,       vcCustodianAccountName1=@vcCustodianAccountName1,

                        vcCustodianAccountName2=@vcCustodianAccountName2,   vcSalutation=@vcSalutation,

                        intCustodianID=@intCustodianID,

                        vcAddress1=@vcAddress1,                     vcAddress2=@vcAddress2,

                        vcCity=@vcCity,                             vcState=@vcState,

                        vcCountry=@vcCountry,

                        vcPostalCode=@vcPostalCode,                 vcCountryCode1=@vcCountryCode1,

                        vcAreaCode1=@vcAreaCode1,                vcTelephone1=@vcTelephone1,

                        vcCountryCode2=@vcCountryCode2,             vcAreaCode2=@vcAreaCode2,

                        vcTelephone2=@vcTelephone2,                 vcCountryCode3=@vcCountryCode3,

          vcAreaCode3=@vcAreaCode3,                   vcTelephone3=@vcTelephone3,

                        vcCountryCode4=@vcCountryCode4,             vcAreaCode4=@vcAreaCode4,

                        vcTelephone4=@vcTelephone4,                 vcEmail=@vcEmail,

                        bitIsActive=@bitIsActive,

                        TypeofAccount=@TypeofAccount,               LinkedCustodianAccount=@LinkedCustodianAccount,

                        UserID=@UserID,

                        vcHostName=@vcHostName

                    WHERE intCustodianAccountID=@intCustodianAccountID

					

					EXECUTE  [setup].[stp_DataSync_RefMasters] 

					 @master_name='CUSTODIANACCOUNT'

					,@success=@success OUTPUT

					,@error_message=@error_message OUTPUT

            END

     END

     ELSE

     BEGIN

      UPDATE setup.tbl_CustodianAccount 

                SET vcPushStatus=xmlStatus.Status,

                    bitAvailableInGeneva= case when RecordAction='InsertUpdate' then  

                                                    case when [Message] like '%WARNING: Screen has no modifications - no commit performed%' then 1  

                                                         when [Status]='Success' then 1   

                                                         else bitAvailableInGeneva end  

                                                when RecordAction='Delete' then  

                                                    case when [Status]='Success' then 0   

                                                         else bitAvailableInGeneva end  

                                                else bitAvailableInGeneva  

                                          end,  

                    dtPushedOn=GETDATE(),

                    intPushedBy=xmlStatus.UserID

                FROM setup.tbl_CustodianAccount C

                     JOIN (select 

                                tab.col.value('Status[1]','varchar(100)') [Status],

                                tab.col.value('Message[1]','varchar(1000)') [Message],

                                tab.col.value('RecordAction[1]','varchar(100)') RecordAction,

                                tab.col.value('ExternalSystemReferenceID[1]','varchar(100)') ExternalSystemReferenceID,

                                tab.col.value('UserID[1]','varchar(100)') UserID

                                from @xmlPushStatus.nodes('NewDataSet/Table1') tab(col)) xmlStatus

                                ON C.intCustodianAccountID=xmlStatus.ExternalSystemReferenceID

     END

    END TRY

    BEGIN CATCH

        SET @intSuccess=-1*ERROR_NUMBER()

        SET @msg=ERROR_MESSAGE()

        PRINT @msg

        exec STP_LogError

    END CATCH

END

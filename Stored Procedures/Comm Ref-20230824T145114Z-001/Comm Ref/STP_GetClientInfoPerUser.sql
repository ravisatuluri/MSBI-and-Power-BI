--USE [VUCommRef]
--GO

ALTER PROCEDURE [cmrf].[STP_GetClientInfoPerUser]
(
	@VcLogin				VARCHAR(50),
---------------------------------Common Columns-------------------------------- 
	@IntSuccess				INT	OUTPUT,
	@VcError_Message		VARCHAR(1000)	OUTPUT
---------------------------------Common Columns-------------------------------- 
)
AS
BEGIN
	SET NOCOUNT ON
	SELECT F.IntClientDefinitionID,
		F.VcClientShortCode,
		F.VcClientName
	FROM [acs].[TBL_Person] A WITH(NOLOCK)
	INNER JOIN [acs].[TBL_EmailAddress] B WITH(NOLOCK) ON A.IntBusinessEntityID=B.IntBusinessEntityID
	INNER JOIN [cmrf].[TBL_User_Master] C WITH(NOLOCK) ON B.VcPrimaryEmailAddressID=C.VCEMAIL_ADDRESS
	INNER JOIN [cmrf].[TBL_client_classification_link] D WITH(NOLOCK) ON c.INTUSERID=d.INTUSERID
	INNER JOIN [cmrf].[TBL_UAT_Vw_Clients] E WITH(NOLOCK) ON D.intClientID=E.intclient
	INNER JOIN [cmrf].[TBL_Client] F WITH(NOLOCK) ON E.vcClientShortCode=F.VcClientShortCode 
	AND F.BitIsActive=1
	WHERE C.VcLogin=@VcLogin
END


/*

--------------TEST CASE------------

DECLARE @RC INT, @VcActionCode VARCHAR(100), @IntSuccess INT,
@VcError_Message VARCHAR(1000)

EXECUTE @RC= [cmrf].[STP_GetClientInfoPerUser]
   @VcLogin			='asttra.superuser'
  ,@IntSuccess		=@IntSuccess OUTPUT
  ,@VcError_Message	=@VcError_Message OUTPUT

SELECT * FROM [10.1.0.208].[STPLIVE03].[setup].[tbl_client_classification_link]
SELECT @IntSuccess,@VcError_Message

*/


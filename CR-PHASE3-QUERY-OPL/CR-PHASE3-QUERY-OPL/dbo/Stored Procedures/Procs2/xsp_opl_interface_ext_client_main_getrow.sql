create PROCEDURE dbo.xsp_opl_interface_ext_client_main_getrow
(
	@p_id bigint
)
as
begin
	select	CustId
           ,CustNo
           ,CustName
           ,MrCustTypeCode
           ,MrCustModelCode
           ,MrIdTypeCode
           ,IdNoIdNo
           ,IdExpiredDt
           ,TaxIdNo
           ,IsVip
           ,OriginalOfficeCode
           ,IsAffiliateWithMf
           ,VipNotes
           ,ThirdPartyTrxNo
           ,ThirdPartyGroupTrxNo
	from	opl_interface_ext_client_main
	where	CustId = @p_id ;
end ;


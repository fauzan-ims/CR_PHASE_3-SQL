CREATE PROCEDURE [dbo].[xsp_checking_asset_fms_for_sp_delivery]
(
	@p_agreement_no nvarchar(50)
)
as
begin
	declare @is_on_customer nvarchar(1) ;

	if exists
	(
		select	1
		from	dbo.agreement_main am
				inner join dbo.agreement_asset aa on aa.agreement_no = am.agreement_no
		--left join ifinams.dbo.asset			   a on a.rental_reff_no = aa.asset_no
		where	am.agreement_no		= @p_agreement_no
				and aa.asset_status <> 'RETURN'
	)
	begin
		set @is_on_customer = N'1' ;
	end ;
	else
	begin
		set @is_on_customer = N'0' ;
	end ;

	select	@is_on_customer 'is_on_customer' ;

end ;

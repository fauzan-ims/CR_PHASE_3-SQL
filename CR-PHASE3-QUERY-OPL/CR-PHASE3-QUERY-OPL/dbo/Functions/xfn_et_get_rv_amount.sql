CREATE FUNCTION dbo.xfn_et_get_rv_amount
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- mengambil nilai pokok hutang yang belum dibayar
	declare @rv_amount decimal(18, 2) ;

	select	@rv_amount = asset_rv_amount
	from	dbo.agreement_asset with (nolock)
	where	agreement_no = @p_agreement_no
			and asset_no in
				(
					select	asset_no
					from	dbo.et_detail with (nolock)
					where	et_code			 = @p_reff_no
							and is_terminate = '1'
				) ;

	return @rv_amount ;
end ;

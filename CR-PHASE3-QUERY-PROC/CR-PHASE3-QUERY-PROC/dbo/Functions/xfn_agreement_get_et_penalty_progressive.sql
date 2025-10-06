CREATE FUNCTION [dbo].[xfn_agreement_get_et_penalty_progressive]
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	-- untuk mendapatkan nilai bunga yang belum jatuh tempo
	declare @penalty_progressive_amount decimal(18, 2) = 0
			,@asset_no					nvarchar(50)
			,@amount_term_to_matur		decimal(18, 2)

	declare agreementasset cursor fast_forward read_only for
	select	asset_no
	from	dbo.et_detail
	where	et_code			 = @p_reff_no
			and is_terminate = '1' ;

	open agreementasset ;

	fetch next from agreementasset
	into @asset_no ;

	while @@fetch_status = 0
	begin
		select	@penalty_progressive_amount = @penalty_progressive_amount + dbo.xfn_get_et_penalty_progressive_by_asset(@asset_no, @p_date) ;

		fetch next from agreementasset
		into @asset_no ;
	end ;

	close agreementasset ;
	deallocate agreementasset ;

	return isnull(round(@penalty_progressive_amount, 0), 0) ;
end ;

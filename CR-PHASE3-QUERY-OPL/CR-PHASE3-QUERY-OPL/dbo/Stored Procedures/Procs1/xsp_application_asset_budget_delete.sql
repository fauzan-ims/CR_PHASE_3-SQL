CREATE procedure [dbo].[xsp_application_asset_budget_delete]
(
	--@p_asset_no	  nvarchar(50)
	--,@p_cost_code nvarchar(50)
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_asset_budget
			where	id = @p_id
					and cost_code in
		(
			'MBDC.2208.000001', 'MBDC.2211.000001', 'MBDC.2211.000003', 'MBDC.2301.000001'
		)
		)
		begin
			set @msg = N'Budget REPLACEMENT CAR / INSURANCE / MAINTENANCE / STNK & KEUR cannot be Deleted' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			delete	application_asset_budget
			where	id = @p_id ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

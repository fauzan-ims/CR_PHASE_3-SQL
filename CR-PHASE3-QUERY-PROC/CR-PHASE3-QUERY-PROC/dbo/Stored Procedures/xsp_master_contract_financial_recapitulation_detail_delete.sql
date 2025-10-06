create procedure [dbo].[xsp_master_contract_financial_recapitulation_detail_delete]
(
	@p_financial_recapitulation_code nvarchar(50)
	,@p_report_type					 nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete	dbo.master_contract_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_financial_recapitulation_code
				and report_type				  = @p_report_type ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

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

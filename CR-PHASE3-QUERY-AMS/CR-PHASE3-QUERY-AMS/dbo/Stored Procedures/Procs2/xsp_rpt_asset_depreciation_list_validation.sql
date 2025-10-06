CREATE PROCEDURE dbo.xsp_rpt_asset_depreciation_list_validation
(
	@p_date_type										 nvarchar(50)		= ''
	,@p_from_date										 datetime			= null
	,@p_to_date											 datetime			= null
)
as
begin
	declare @msg			nvarchar(max)
			

	begin try -- 
		if (@p_from_date > @p_to_date) and @p_date_type <> 'ALL'
		begin
			set @msg = 'From Date must be less than To Date';
			raiserror(@msg ,16,-1);	  
		end
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;

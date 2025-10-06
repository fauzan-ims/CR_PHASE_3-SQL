create procedure dbo.xsp_repossession_pricing_detail_appraisal_status
(
	@p_id				bigint
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max);

	begin try
		if exists (select 1 from dbo.repossession_pricing_detail where id = @p_id and appraisal_request_status = 'NONE')
		begin
			update	dbo.repossession_pricing_detail
			set		appraisal_request_status	= 'NEW'
					,pricelist_amount			= 0
					--
					,mod_date					= @p_mod_date		
					,mod_by						= @p_mod_by			
					,mod_ip_address				= @p_mod_ip_address
			where	id							= @p_id
		end
		else
		begin
			set @msg = 'Data already process';
			raiserror(@msg,16,1) ;
		end
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;


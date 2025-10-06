CREATE PROCEDURE dbo.xsp_master_depreciation_detail_update
(
	@p_id				  bigint = 0
	,@p_depreciation_code nvarchar(50)
	,@p_tenor			  int
	,@p_rate			  decimal(9, 6)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		IF exists (select 1 from master_depreciation_detail WHERE id <> @p_id AND depreciation_code = @p_depreciation_code and tenor = @p_tenor)
		begin
			SET @msg = 'Tenor already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		update	master_depreciation_detail
		set		depreciation_code = @p_depreciation_code
				,tenor = @p_tenor
				,rate = @p_rate
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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



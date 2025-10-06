CREATE PROCEDURE dbo.xsp_adjustment_detail_update
(
	@p_id							bigint
	,@p_adjustment_code				nvarchar(50)
	,@p_amount					    decimal(18,2)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@net_book_value_comm	decimal(18,2)
			,@net_book_value_fiscal	decimal(18,2)
			,@total_fiscal			decimal(18,2)
			,@total_comm			decimal(18,2);

			select @net_book_value_fiscal	= isnull(ass.net_book_value_fiscal,0)
					,@net_book_value_comm	= isnull(ass.net_book_value_comm,0) 
			from dbo.adjustment adj
			inner join dbo.asset ass on (ass.code = adj.asset_code)
			where adj.code = @p_adjustment_code

	begin try
		update	dbo.adjustment_detail
		set		adjustment_code				= @p_adjustment_code
				,amount						= @p_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;

		exec dbo.xsp_adjustment_detail_update_sum @p_adjustment_code	 = @p_adjustment_code
												  ,@p_mod_date			 = @p_mod_date		
												  ,@p_mod_by			 = @p_mod_by			
												  ,@p_mod_ip_address	 = @p_mod_ip_address
		
		
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

CREATE PROCEDURE dbo.xsp_reverse_sale_detail_update
(
	@p_id						  bigint
	,@p_reverse_sale_code		  nvarchar(50)
	,@p_description_detail		  nvarchar(4000)	= ''
	,@p_sale_value				  decimal(18, 2)	= ''
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@total decimal(18,2)

	begin try
		update	reverse_sale_detail
		set		reverse_sale_code	= @p_reverse_sale_code
				,description		= @p_description_detail
				,sale_value			= @p_sale_value
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @p_id ;

		select @total = sum(sale_value)
		from dbo.reverse_sale_detail with( nolock) -- -- hari - 23 august 2022 02:34 pm  case ini boleh with nolock
		where reverse_sale_code = @p_reverse_sale_code

		update	dbo.reverse_sale
		set		sale_amount = @total
		where	code		= @p_reverse_sale_code;
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

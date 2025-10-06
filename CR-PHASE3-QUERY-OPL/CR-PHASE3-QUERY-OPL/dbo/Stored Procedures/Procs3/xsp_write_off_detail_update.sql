CREATE PROCEDURE dbo.xsp_write_off_detail_update
(
	@p_id			   bigint
	,@p_write_off_code nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@agreement_no		nvarchar(50)
			,@is_take_assets	nvarchar(1) ;

	begin try
		select	@is_take_assets = is_take_assets
		from	dbo.write_off_detail
		where	id = @p_id ;

		if @is_take_assets = '1'
			set @is_take_assets = '0' ;
		else
			set @is_take_assets = '1' ;

		update	write_off_detail
		set		is_take_assets	= @is_take_assets
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

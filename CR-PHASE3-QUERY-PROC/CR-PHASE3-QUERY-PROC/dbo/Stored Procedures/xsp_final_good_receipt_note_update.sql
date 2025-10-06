CREATE PROCEDURE dbo.xsp_final_good_receipt_note_update
(
	@p_code			   nvarchar(50)
	,@p_date		   datetime
	,@p_complate_date  datetime
	,@p_status		   nvarchar(50)
	,@p_name		   nvarchar(250)
	,@p_total_amount   decimal(18, 2)
	,@p_total_item	   int
	,@p_receive_item   int
	,@p_remark		   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	final_good_receipt_note
		set		date			= @p_date
				,complate_date	= @p_complate_date
				,status			= @p_status
				,name			= @p_name
				,total_amount	= @p_total_amount
				,total_item		= @p_total_item
				,receive_item	= @p_receive_item
				,remark			= @p_remark
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

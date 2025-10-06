CREATE PROCEDURE [dbo].[xsp_purchase_order_object_info_delete_for_grn]
(
	@p_id						bigint
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
			update	dbo.purchase_order_detail_object_info
			set		good_receipt_note_detail_id = 0
					,stnk						= null
					,stnk_date					= null
					,stnk_exp_date				= null
					,stck						= null
					,stck_date					= null
					,stck_exp_date				= null
					,keur						= null
					,keur_date					= null
					,keur_exp_date				= null
					,stnk_file_no				= null
					,stnk_file_path				= null
					,stck_file_no				= null
					,stck_file_path				= null
					,keur_file_no				= null
					,keur_file_path				= null
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
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

--created by, Rian at 17/02/2023 

CREATE PROCEDURE dbo.xsp_master_item_group_update
(
	@p_code						nvarchar(50)
	,@p_company_code			nvarchar(50)
	,@p_description				nvarchar(4000)
	,@p_group_level				int
	,@p_parent_code				nvarchar(50)
	,@p_gl_asset_code			nvarchar(50)
	,@p_gl_asset_name			nvarchar(250)
	,@p_gl_asset_rent_code		nvarchar(50)
	,@p_gl_asset_rent_name		nvarchar(250)
	--,@p_transaction_type nvarchar(20) = ''
	--,@p_is_active		 nvarchar(1)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ; 

	begin try

		--validasi deskripsi tidak boleh sama
		if exists 
		(
			select	1
			from 	master_item_group
			where	code <> @p_code
			and		company_code = @p_company_code
			and		description = @p_description
		)
		begin
			set @msg = 'Description Already Exist'
			raiserror(@msg, 16, -1) ; 
		end 

		update	master_item_group
		set		description			= upper(@p_description)
				,group_level		= @p_group_level
				,parent_code		= @p_parent_code 
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code
				and company_code	= @p_company_code ;

		--Auto Delete pada master item group GL
		delete dbo.master_item_group_gl
		where item_group_code = @p_code

		--Insert lagi pada master item group GL
		exec dbo.xsp_master_item_group_gl_insert @p_id						= 0
												 ,@p_company_code			= 'DSF'
												 ,@p_item_group_code		= @p_code
												 ,@p_currency_code			= 'IDR'
												 ,@p_gl_asset_code			= @p_gl_asset_code
												 ,@p_gl_asset_name			= @p_gl_asset_name
												 ,@p_gl_asset_rent_code		= @p_gl_asset_rent_code
												 ,@p_gl_asset_rent_name		= @p_gl_asset_rent_name
												 ,@p_gl_expend_code			= ''
												 ,@p_gl_inprogress_code		= ''
												 ,@p_category				= 'FXDAST'
												 ,@p_cre_date				= @p_mod_date
												 ,@p_cre_by					= @p_mod_by
												 ,@p_cre_ip_address			= @p_mod_ip_address
												 ,@p_mod_date				= @p_mod_date
												 ,@p_mod_by					= @p_mod_by
												 ,@p_mod_ip_address			= @p_mod_ip_address
		
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

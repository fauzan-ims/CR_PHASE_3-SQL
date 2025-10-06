CREATE PROCEDURE dbo.xsp_replacement_detail_update
(
	@p_id					bigint
	--,@p_replacement_code	nvarchar(50)
	,@p_type				nvarchar(10)
	,@p_bpkb_no				nvarchar(50)	= null
	,@p_bpkb_date			datetime		= null
	,@p_bpkb_name			nvarchar(250)	= null
	,@p_bpkb_address		nvarchar(4000)	= null
	--,@p_stnk_name			nvarchar(250)	= null
	--,@p_stnk_exp_date		datetime		= null
	--,@p_stnk_tax_date		datetime		= null
	--,@p_cover_note_no		nvarchar(50)	= null
	--,@p_cover_note_date		datetime		= null
	--,@p_cover_note_exp_date datetime		= null
	--,@p_file_name			nvarchar(250)
	--,@p_file_paths			nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if(@p_type = '')
		begin
			set @msg = 'Please select replacement type' ;

			raiserror(@msg, 16, 1) ;
		end

		update	replacement_detail
		set		type							= @p_type
				,bpkb_no						= @p_bpkb_no
				,bpkb_date						= @p_bpkb_date
				,bpkb_name						= @p_bpkb_name
				,bpkb_address					= @p_bpkb_address
				--,stnk_name						= @p_stnk_name
				--,stnk_exp_date					= @p_stnk_exp_date
				--,stnk_tax_date					= @p_stnk_tax_date 
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;
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

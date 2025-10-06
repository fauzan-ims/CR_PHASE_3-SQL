CREATE PROCEDURE dbo.xsp_purchase_order_object_info_update_for_cover_note
(
	@p_id						bigint
	,@p_bpkb_no					nvarchar(50)	= null
	,@p_cover_note				nvarchar(50)	= null
	,@p_cover_note_date			datetime		= null
	,@p_exp_date				datetime		= null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

	if ((isnull(@p_bpkb_no,'') = '' and isnull(@p_cover_note,'') = '') or ((isnull(@p_bpkb_no, '') <> '' and isnull(@p_cover_note,'') <> '')))
	begin
		set @msg = 'Please input BPKB No or Cover Note.' 
		raiserror(@msg, 16, 1) ;
	end

	if(isnull(@p_cover_note,'') = '')
	begin
		set @p_exp_date = null;
	end

	--if(@p_cover_note_date < dbo.xfn_get_system_date())
	--begin
	--	set @msg = 'Cover note date must be greater or equal than system date.' 
	--	raiserror(@msg, 16, 1) ;
	--end

	if(@p_exp_date < @p_cover_note_date)
	begin
		set @msg = 'Cover note expired date must be greater than cover note date.' 
		raiserror(@msg, 16, 1) ;
	end

	update dbo.purchase_order_detail_object_info
	set	bpkb_no					= @p_bpkb_no
		,cover_note				= @p_cover_note
		,cover_note_date		= @p_cover_note_date
		,exp_date				= @p_exp_date
		--
		,mod_date				= @p_mod_date
		,mod_by					= @p_mod_by
		,mod_ip_address			= @p_mod_ip_address
	where	id	= @p_id

		

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
end

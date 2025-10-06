CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_delete]
(
	@p_id						bigint
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@reff_no				nvarchar(50)
			,@quotation_review_code	nvarchar(50);

	begin try

	select	@reff_no				= reff_no
			,@quotation_review_code	= quotation_review_code
	from dbo.quotation_review_detail
	where id = @p_id

	delete dbo.quotation_review_detail
	where reff_no = @reff_no

	delete	quotation_review_detail
	where	id	= @p_id

	if not exists(select 1 from dbo.quotation_review_detail where reff_no = @reff_no)
	begin
		update	dbo.procurement
		set		status = 'HOLD' -- -- Hari - 30.Aug.2023 04:21 PM status ganti jadi HOLD, sebelumnya NEW
				,purchase_type_code		= ''
				,purchase_type_name		= ''
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @reff_no
	end
	
	if not exists(select 1 from dbo.quotation_review_detail where quotation_review_code = @quotation_review_code)
	begin
		update	dbo.quotation_review
		set		status = 'CANCEL'
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @quotation_review_code
	end

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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

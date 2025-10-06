CREATE PROCEDURE [dbo].[xsp_et_detail_approve_to_sell_update]
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							   nvarchar(max)
			,@is_approve_to_sell			   nvarchar(1)
			,@agreement_no					   nvarchar(50)
			,@purchase_requirement_afrer_lease nvarchar(1) ;

	begin try
		select	@is_approve_to_sell				   = isnull(a.is_approve_to_sell,0)
				,@agreement_no					   = b.agreement_no
				,@purchase_requirement_afrer_lease = c.is_purchase_requirement_after_lease
		from	dbo.et_detail				  a
				inner join dbo.et_main		  b on a.et_code	  = b.code
				inner join dbo.agreement_main c on c.agreement_no = b.agreement_no
		where	a.id = @p_id ;

		if (@purchase_requirement_afrer_lease = '0')
		begin
			set @msg = N'Asset is not in purchase request after lease.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if @is_approve_to_sell = '1'
			set @is_approve_to_sell = N'0' ;
		else
			set @is_approve_to_sell = N'1' ;

		update	dbo.et_detail
		set		is_approve_to_sell	= @is_approve_to_sell
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

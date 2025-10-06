CREATE PROCEDURE dbo.xsp_billing_generate_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg			nvarchar(max)
			,@agreement_no	nvarchar(50)
			,@asset_no		nvarchar(50)
			,@generate_code nvarchar(50)
			,@billing_no	int ;

	begin try
		select	@billing_no = billing_no
				,@agreement_no = agreement_no
				,@asset_no = asset_no
				,@generate_code = generate_code
		from	billing_generate_detail
		where	id				  = @p_id ;

		if exists
		(
			select	1
			from	billing_generate_detail
			where	id				  <> @p_id
					and generate_code = @generate_code
					and agreement_no  = @agreement_no
					and asset_no	  = @asset_no
					and billing_no	  > @billing_no
		)
		begin
			delete	billing_generate_detail
			where	billing_no	  >= @billing_no
					and generate_code = @generate_code
					and agreement_no  = @agreement_no
					and asset_no	  = @asset_no
		end ;
		else
		begin
			delete	billing_generate_detail
			where	id				  = @p_id
					and generate_code = @generate_code ;
		end ;
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

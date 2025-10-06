CREATE procedure [dbo].[xsp_waived_obligation_update]
(
	@p_code				  nvarchar(50)
	,@p_branch_code		  nvarchar(50)
	,@p_branch_name		  nvarchar(250)
	,@p_agreement_no	  nvarchar(50)
	,@p_waived_status	  nvarchar(10)
	,@p_waived_date		  datetime
	,@p_waived_amount	  decimal(18, 2)
	,@p_waived_remarks	  nvarchar(4000)
	,@p_obligation_amount decimal(18, 2)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin

	declare @msg						nvarchar(max) 
			,@obligation_amount			decimal(18,2)
			,@waived_amount				decimal(18,2);


	begin TRY
		
		if (@p_waived_date <> dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be same with System Date';
			raiserror(@msg, 16, -1) ;
		end

		update	waived_obligation
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,agreement_no		= @p_agreement_no
				,waived_status		= @p_waived_status
				,waived_date		= @p_waived_date
				,waived_amount		= @p_waived_amount
				,waived_remarks		= @p_waived_remarks
				,obligation_amount	= @p_obligation_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

		select	@obligation_amount = sum(isnull(obligation_amount,0)) 
				,@waived_amount		= sum(isnull(waived_amount,0))
		from	waived_obligation_detail
		where	waived_obligation_code = @p_code


		update	waived_obligation
		set		obligation_amount	= isnull(@obligation_amount,0)
				,waived_amount		= isnull(@waived_amount,0)  
		where	code = @p_code

	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;


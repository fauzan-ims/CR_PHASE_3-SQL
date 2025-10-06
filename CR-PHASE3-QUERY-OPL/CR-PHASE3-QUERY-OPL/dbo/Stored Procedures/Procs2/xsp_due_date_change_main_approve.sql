CREATE PROCEDURE dbo.xsp_due_date_change_main_approve
(
	@p_code						nvarchar(50)
	,@p_approval_reff			nvarchar(250)
	,@p_approval_remark			nvarchar(4000)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg				nvarchar(max)
			,@change_amount		decimal(18,2)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@currency			nvarchar(10)
			,@remark			nvarchar(4000)
			,@asset_no	   nvarchar(50)
			,@agreement_no   nvarchar(50)
			,@billing_no	   int
			,@change_date		datetime
				
	
	begin try
		
		if exists
		(
			select	1
			from	dbo.due_date_change_main
			where	code			  = @p_code
					and change_status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
        else
		begin
			--if exists
			--(
			--	select	1
			--	from	dbo.due_date_change_main
			--	where	code							  = @p_code
			--			and cast(change_exp_date as date) < cast(dbo.xfn_get_system_date() as date)
			--)
			--begin
			--	set @msg = 'Date must be greater or equal to System Date' ;

			--	raiserror(@msg, 16, 1) ;
			--end ;

			select  @change_amount	= isnull(change_amount,0)
					,@agreement_no	= dcm.agreement_no
					,@remark		= dcm.change_remarks
					,@change_date	= dcm.change_date
					,@currency		= am.currency_code
			from	dbo.due_date_change_main dcm 
					inner join dbo.agreement_main am on (am.agreement_no = dcm.agreement_no)
			where	code			= @p_code			
			 
			update dbo.due_date_change_main
			set		change_status   = 'APPROVE'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where   code			= @p_code

			-- update agreement asset amortization
			begin 
				declare currchangeduedetail cursor fast_forward read_only for
				select	asset_no
						,ddcd.at_installment_no
				from	dbo.due_date_change_detail ddcd
				where	ddcd.due_date_change_code = @p_code ;

				open currchangeduedetail ;

				fetch next from currchangeduedetail
				into @asset_no
					 ,@billing_no ;

				while @@fetch_status = 0
				begin
					exec dbo.xsp_due_date_change_update_amortization @p_code			= @p_code
																	 ,@p_asset_no		= @asset_no
																	 ,@p_agreement_no   = @agreement_no
																	 ,@p_billing_no	    = @billing_no
																	 ,@p_mod_date		= @p_mod_date
																	 ,@p_mod_by			= @p_mod_by
																	 ,@p_mod_ip_address = @p_mod_ip_address

					fetch next from currchangeduedetail
					into @asset_no
						 ,@billing_no ;
				end ;

				close currchangeduedetail ;
				deallocate currchangeduedetail ;
            end
			
			-- update lms status
			exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
															,@p_status		= N'' 
		end

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
	


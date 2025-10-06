/*
	alterd : Yunus Muslim, 24 April 2020
*/
CREATE PROCEDURE dbo.xsp_termination_request_proceed 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@code						nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@policy_code				nvarchar(50)
			,@policy_status				nvarchar(50)
			,@policy_payment_type		nvarchar(5)
			,@policy_eff_date			datetime
			,@from_date					datetime
			,@to_date					datetime
			,@termination_date			datetime
			,@year_period				int
			,@premi						decimal(18,2) = 0
			,@total_sisa_premi			decimal(18,2) = 0
			,@total_buy_amount_period	decimal(18,2)
			,@total_buy_amount_loading	decimal(18,2)
			,@termination_remarks		nvarchar(4000)
			,@sisa_hari					int
			,@total_hari				int
			,@sisa_premi				decimal(18,2) = 0;

	begin try
    
		if exists (select 1 from dbo.termination_request where code = @p_code and request_status = 'HOLD')
		begin
			select	@branch_code			= ipm.branch_code
					,@branch_name			= ipm.branch_name 
					,@policy_code			= tr.policy_code
					,@policy_status			= ipm.policy_status
					,@policy_payment_type	= ipm.policy_payment_type
					,@policy_eff_date		= ipm.policy_eff_date
					,@termination_remarks	= 'Termination from policy insurance from policy code : '+ @policy_code
			from	dbo.termination_request tr
		 			inner join dbo.insurance_policy_main ipm on ipm.code = tr.policy_code
			WHERE	tr.code =@p_code

			select	@total_buy_amount_period	= sum (total_buy_amount)
			from	insurance_policy_main_period  
			where	year_periode				= @year_period

			select	@total_buy_amount_loading	= sum(total_buy_amount) 
			from	dbo.insurance_policy_main_loading  
			where	year_period					= @year_period
			
			set	@termination_date = dbo.xfn_get_system_date()
			exec dbo.xsp_termination_main_insert @p_code							= @code output
												 ,@p_branch_code					= @branch_code
												 ,@p_branch_name					= @branch_name
												 ,@p_policy_code					= @policy_code
												 ,@p_termination_status				= 'HOLD'
												 ,@p_termination_date				= @termination_date
												 ,@p_termination_approved_amount	= @total_sisa_premi
												 ,@p_termination_remarks			= @termination_remarks
												 ,@p_termination_request_code       = @p_code
												 ,@p_cre_date						= @p_cre_date		
												 ,@p_cre_by							= @p_cre_by			
												 ,@p_cre_ip_address					= @p_cre_ip_address
												 ,@p_mod_date						= @p_mod_date		
												 ,@p_mod_by							= @p_mod_by			
												 ,@p_mod_ip_address					= @p_mod_ip_address
		 
			--if @policy_payment_type = 'FTFP' or @policy_payment_type = 'ATAP'
			--begin		    
			--	declare efam_cur	cursor local fast_forward for

			--	select	year_periode
			--	from	dbo.insurance_policy_main_period
			--	where	policy_code = @policy_code
						
			--	open efam_cur
			--	fetch next from efam_cur  
			--	into	@year_period
						
			--	while @@fetch_status = 0
			--	begin
			--		set	@from_date	= dateadd(year,(@year_period-1),@policy_eff_date)
			--		set	@to_date	= dateadd(year,(@year_period-1),@policy_eff_date)

			--		if @termination_date > @to_date
			--		begin
			--			set @sisa_premi = 0
			--		end
			--		else if @termination_date > @from_date and @termination_date < @to_date
			--		begin
			--			set @premi		= @total_buy_amount_period + @total_buy_amount_loading
			--			set @sisa_hari	= datediff(day,@termination_date,@to_date)
			--			set	@total_hari = datediff(day,@from_date,@to_date)
			--			set	@sisa_premi = @sisa_hari / @total_hari * @premi
			--		end
			--		else if @termination_date < @to_date
			--		begin
			--			set @premi = @total_buy_amount_period + @total_buy_amount_loading 
			--		end

			--		set	@total_sisa_premi += @sisa_premi
			
			--		fetch next from efam_cur  
			--		into	@year_period
			
			--	end
				
			--	close efam_cur
			--	deallocate efam_cur
			--end
		
			--if @policy_payment_type = 'FTAP'
			--begin		    
			--	declare efam_cur	cursor local fast_forward for

			--	select	year_periode
			--	from	dbo.insurance_policy_main_period
			--	where	policy_code = @policy_code
						
			--	open efam_cur
			--	fetch next from efam_cur  
			--	into	@year_period
						
			--	while @@fetch_status = 0
			--	begin
			--		set	@from_date	= dateadd(year,(@year_period-1),@policy_eff_date)
			--		set	@to_date	= dateadd(year,(@year_period-1),@policy_eff_date)

			--		if @termination_date > @from_date and @termination_date < @to_date
			--		begin
			--			set @premi = @total_buy_amount_period + @total_buy_amount_loading
			--			set @sisa_hari	= datediff(day,@termination_date,@to_date)
			--			set	@total_hari = datediff(day,@from_date,@to_date)
			--			set	@sisa_premi = @sisa_hari / @total_hari * @premi
			--		end
			--		else
			--		begin
			--			set @premi = 0
			--		end

			--		set	@total_sisa_premi += @sisa_premi
			
			--		fetch next from efam_cur  
			--		into	@year_period
			
			--	end
				
			--	close efam_cur
			--	deallocate efam_cur
			--end	

			update termination_request
			set		request_status		= 'POST'
					,termination_code	= @code
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code
		end
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
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
end ;




CREATE PROCEDURE dbo.xsp_application_financial_recapitulation_detail_calculate
(
	@p_financial_recapitulation_code nvarchar(50)
	--
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg						  nvarchar(max)
			,@counter					  int			= 0
			,@level_key					  int
			,@statement_parent			  nvarchar(50)
			,@statement_from_value_amount decimal(18, 2)
			,@statement_to_value_amount	  decimal(18, 2)
			,@statement_ratio_pct		  decimal(9, 6) ;

	begin try
		update	dbo.application_financial_recapitulation_detail
		set		statement_ratio_pct				= case when statement_from_value_amount = 0 then 0
													  when (((statement_to_value_amount - statement_from_value_amount) / statement_from_value_amount) * 100 > 1000) then 999
													  else ((statement_to_value_amount - statement_from_value_amount) / statement_from_value_amount) * 100
												  end

				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	financial_recapitulation_code	= @p_financial_recapitulation_code
				and statement_parent_code is not null ;

		select	@level_key = max(level_key)
		from	application_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_financial_recapitulation_code ;

		while (@counter < @level_key)
		begin
			declare parentstatement cursor fast_forward read_only for
			select distinct
					statement_parent_code
			from	dbo.application_financial_recapitulation_detail
			where	level_key = @level_key ;

			open parentstatement ;

			fetch next from parentstatement
			into @statement_parent ;

			while @@fetch_status = 0
			begin
				select	@statement_from_value_amount = isnull(sum(statement_from_value_amount), 0)
				from	dbo.application_financial_recapitulation_detail
				where	level_key				  = @level_key
						and financial_recapitulation_code = @p_financial_recapitulation_code
						and statement_parent_code = @statement_parent ;

				select	@statement_to_value_amount = isnull(sum(statement_to_value_amount), 0)
				from	dbo.application_financial_recapitulation_detail
				where	level_key				  = @level_key
						and financial_recapitulation_code = @p_financial_recapitulation_code
						and statement_parent_code = @statement_parent ;
				if (
					   @statement_from_value_amount = 0
					  or @statement_to_value_amount = 0
				   )
				begin
					set @statement_ratio_pct = 0 ;
				end ;
				else
				begin
					if (((@statement_to_value_amount - @statement_from_value_amount) / @statement_from_value_amount) * 100  > 1000)
					begin
						set @statement_ratio_pct = 999 ;
					end
					else
					begin
						set @statement_ratio_pct = ((@statement_to_value_amount - @statement_from_value_amount) / @statement_from_value_amount) * 100 ;
					end
				end ;

				update	dbo.application_financial_recapitulation_detail
				set		statement_from_value_amount = @statement_from_value_amount
						,statement_to_value_amount	= @statement_to_value_amount
						,statement_ratio_pct		= @statement_ratio_pct
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	financial_recapitulation_code = @p_financial_recapitulation_code
						and statement_code			  = @statement_parent ;

				fetch next from parentstatement
				into @statement_parent ;
			end ;

			close parentstatement ;
			deallocate parentstatement ;

			set @level_key -= 1 ;
		end ;
	end try
	Begin catch
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


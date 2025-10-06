CREATE PROCEDURE [dbo].[xsp_application_financial_recapitulation_copy]
(
	@p_client_no	   nvarchar(50)
	,@p_application_no nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max)
			,@get_application_no	   nvarchar(50)
			,@new_financial_recap_code nvarchar(50)
			,@financial_recap_code	   nvarchar(50)
			,@from_periode_year		   nvarchar(4)
			,@from_periode_month	   nvarchar(2)
			,@to_periode_year		   nvarchar(4)
			,@to_periode_month		   nvarchar(2)
			,@current_rasio_pct		   decimal(9, 6) = 0
			,@debet_to_asset_pct	   decimal(9, 6) = 0
			,@return_on_equity_pct	   decimal(9, 6) = 0
			,@p_periode_year		   nvarchar(4)
			,@p_periode_month		   nvarchar(2)
			,@p_dsr_pct				   decimal(9, 6) = 0
			,@p_idir_pct			   decimal(9, 6) = 0
			,@p_dbr_pct				   decimal(9, 6) = 0 ;

	select		top 1
				@get_application_no = am.application_no 
	from		dbo.client_main cm
				inner join dbo.application_main am on (am.client_code = cm.code)
	where		cm.client_no			  = @p_client_no
				and am.application_no	  <> @p_application_no
				and am.application_status = 'GO LIVE'
	order	by am.golive_date desc, am.cre_date   desc
	 
	begin try 
		if exists (select 1 from dbo.application_financial_recapitulation where application_no = @get_application_no)
		begin 
			declare currFinancialRecapitulation cursor fast_forward read_only for
			select	code
					,from_periode_year
					,from_periode_month
					,to_periode_year
					,to_periode_month
					,current_rasio_pct
					,debet_to_asset_pct
					,return_on_equity_pct
			from	dbo.application_financial_recapitulation
			where	application_no = @get_application_no ;

			open currFinancialRecapitulation ;

			fetch next from currFinancialRecapitulation
			into @financial_recap_code
				 ,@from_periode_year
				 ,@from_periode_month
				 ,@to_periode_year
				 ,@to_periode_month
				 ,@current_rasio_pct
				 ,@debet_to_asset_pct
				 ,@return_on_equity_pct ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_application_financial_recapitulation_insert @p_code							 = @new_financial_recap_code output
	    																 ,@p_application_code				 = @p_application_no
	    																 ,@p_from_periode_year				 = @from_periode_year		
	    																 ,@p_from_periode_month				 = @from_periode_month	
	    																 ,@p_to_periode_year				 = @to_periode_year		
	    																 ,@p_to_periode_month				 = @to_periode_month		
	    																 ,@p_current_rasio_pct				 = @current_rasio_pct		
	    																 ,@p_debet_to_asset_pct				 = @debet_to_asset_pct	
	    																 ,@p_return_on_equity_pct			 = @return_on_equity_pct	 
	    																 ,@p_cre_date						 = @p_cre_date	  
	    																 ,@p_cre_by							 = @p_cre_by		  
	    																 ,@p_cre_ip_address					 = @p_cre_ip_address
	    																 ,@p_mod_date						 = @p_mod_date	  
	    																 ,@p_mod_by							 = @p_mod_by		  
	    																 ,@p_mod_ip_address					 = @p_mod_ip_address

				insert into dbo.application_financial_recapitulation_detail
				(
					financial_recapitulation_code
					,report_type
					,statement_code
					,statement_description
					,statement_parent_code
					,statement_from_value_amount
					,statement_to_value_amount
					,statement_ratio_pct
					,level_key
					,order_key
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@new_financial_recap_code
						,report_type
						,statement_code
						,statement_description
						,statement_parent_code
						,statement_from_value_amount
						,statement_to_value_amount
						,statement_ratio_pct
						,level_key
						,order_key
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_financial_recapitulation_detail
				where	financial_recapitulation_code = @financial_recap_code ;

				fetch next from currFinancialRecapitulation
				into @financial_recap_code
					 ,@from_periode_year
					 ,@from_periode_month
					 ,@to_periode_year
					 ,@to_periode_month
					 ,@current_rasio_pct
					 ,@debet_to_asset_pct
					 ,@return_on_equity_pct ;
			end ;

			close currFinancialRecapitulation ;
			deallocate currFinancialRecapitulation ;
		end
		else if exists (select 1 from dbo.application_financial_analysis where application_no = @get_application_no)
		begin 
			declare currfinancialanalysis cursor fast_forward read_only for
			select	code
					,application_no
					,periode_year
					,periode_month
					,dsr_pct
					,idir_pct
					,dbr_pct
			from	dbo.application_financial_analysis
			where	application_no = @get_application_no ;

			open currFinancialAnalysis ;

			fetch next from currFinancialAnalysis
			into @financial_recap_code
				 ,@p_periode_year
				 ,@p_periode_month
				 ,@p_dsr_pct
				 ,@p_idir_pct
				 ,@p_dbr_pct ;

			while @@fetch_status = 0
			begin

				exec dbo.xsp_application_financial_analysis_insert @p_code				= @new_financial_recap_code output
																   ,@p_application_no	= @p_application_no
																   ,@p_periode_year		= @p_periode_year
																   ,@p_periode_month	= @p_periode_month
																   ,@p_dsr_pct			= @p_dsr_pct
																   ,@p_idir_pct			= @p_idir_pct
																   ,@p_dbr_pct			= @p_dbr_pct
																   ,@p_cre_date			= @p_cre_date
																   ,@p_cre_by			= @p_cre_by
																   ,@p_cre_ip_address	= @p_cre_ip_address
																   ,@p_mod_date			= @p_mod_date
																   ,@p_mod_by			= @p_mod_by
																   ,@p_mod_ip_address	= @p_mod_ip_address ;

				insert into dbo.application_financial_analysis_expense
				(
					application_financial_analysis_code
					,expense_type
					,expense_amount
					,remarks
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@new_financial_recap_code
						,expense_type
						,expense_amount
						,remarks
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_financial_analysis_expense
				where	application_financial_analysis_code = @financial_recap_code ;

				insert into dbo.application_financial_analysis_income
				(
					application_financial_analysis_code
					,income_type_code
					,income_amount
					,net_income_pct
					,net_income_amount
					,remarks
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@new_financial_recap_code
						,income_type_code
						,income_amount
						,net_income_pct
						,net_income_amount
						,remarks
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_financial_analysis_income
				where	application_financial_analysis_code = @financial_recap_code ;

				fetch next from currFinancialAnalysis
				into @financial_recap_code
					 ,@p_periode_year
					 ,@p_periode_month
					 ,@p_dsr_pct
					 ,@p_idir_pct
					 ,@p_dbr_pct ;
			end ;

			close currFinancialAnalysis ;
			deallocate currFinancialAnalysis ;
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

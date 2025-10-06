CREATE PROCEDURE dbo.xsp_application_financial_recapitulation_detail_insert
(
	@p_id							  bigint output
	,@p_financial_recapitulation_code nvarchar(50)
	,@p_report_type					  nvarchar(50) 
	--
	,@p_cre_date					  datetime
	,@p_cre_by						  nvarchar(15)
	,@p_cre_ip_address				  nvarchar(15)
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	begin try
		if not exists
		(
			select	1
			from	dbo.master_financial_statement
			where	report_type = @p_report_type
		)
		begin
			set @msg = 'Please setting Master Financial Statement' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into application_financial_recapitulation_detail
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
		select	@p_financial_recapitulation_code
				,@p_report_type
				,code
				,description
				,parent_code
				,0
				,0
				,0
				,level_key
				,order_key
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_financial_statement
		where	report_type	  = @p_report_type
				and is_active = '1' ;

		set @p_id = @@identity ;
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


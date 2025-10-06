CREATE PROCEDURE dbo.xsp_final_good_receipt_note_insert
(
	@p_code			   nvarchar(50)		output
	,@p_date		   datetime
	,@p_complate_date  datetime
	,@p_status		   nvarchar(50)
	,@p_reff_no		   nvarchar(50)
	,@p_total_amount   decimal(18, 2)
	,@p_total_item	   int
	,@p_receive_item   int
	,@p_remark		   nvarchar(4000)
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
	declare @msg		nvarchar(max)
			,@year		nvarchar(2)
			,@month		nvarchar(2)
			,@code		nvarchar(50)

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= 'DSF'
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= 'FGRN'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'FINAL_GOOD_RECEIPT_NOTE'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;
		insert into final_good_receipt_note
		(
			code
			,date
			,complate_date
			,status
			,reff_no
			,total_amount
			,total_item
			,receive_item
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_date
			,@p_complate_date
			,@p_status
			,@p_reff_no
			,@p_total_amount
			,@p_total_item	
			,@p_receive_item
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_code = @code
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

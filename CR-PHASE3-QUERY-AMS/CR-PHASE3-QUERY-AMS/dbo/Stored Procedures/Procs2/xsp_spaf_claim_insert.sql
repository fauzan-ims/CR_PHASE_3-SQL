CREATE procedure [dbo].[xsp_spaf_claim_insert]
(
	@p_code				    nvarchar(50)	output
	,@p_date			    datetime
	,@p_status			    nvarchar(50)
	,@p_claim_amount		decimal(18,2)
	,@p_ppn_amount			decimal(18,2)
	,@p_pph_amount			decimal(18,2)
	,@p_total_claim_amount  decimal(18, 2)	= 0
	,@p_remark			    nvarchar(4000)
	,@p_claim_type			nvarchar(25)	= null
	,@p_reff_claim_req_no	nvarchar(50)
	,@p_receipt_no			nvarchar(50)
	,@p_faktur_no			nvarchar(50)
	,@p_faktur_date			datetime
	--
	,@p_cre_date		    datetime
	,@p_cre_by			    nvarchar(15)
	,@p_cre_ip_address	    nvarchar(15)
	,@p_mod_date		    datetime
	,@p_mod_by			    nvarchar(15)
	,@p_mod_ip_address	    nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@year		nvarchar(4)
			,@month		nvarchar(2)
			,@code		nvarchar(50) 

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
													,@p_branch_code			 = 'DSF'
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'SC'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'SPAF_CLAIM'
													,@p_run_number_length	 = 5
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = '0' ;


		insert into spaf_claim
		(
			code
			,date
			,status
			,claim_amount
			,ppn_amount
			,pph_amount
			,total_claim_amount
			,remark
			,claim_type
			,receipt_no
			,reff_claim_req_no
			,faktur_no
			,faktur_date
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
			,upper(@p_status)
			,@p_claim_amount
			,@p_ppn_amount
			,@p_pph_amount
			,@p_total_claim_amount
			,@p_remark
			,@p_claim_type
			,@p_receipt_no
			,@p_reff_claim_req_no
			,@p_faktur_no
			,@p_faktur_date
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;
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

CREATE PROCEDURE dbo.xsp_ams_interface_spaf_claim_insert
(
	@p_id							bigint			output
	,@p_date						datetime
	,@p_status						nvarchar(15)
	,@p_fa_code						nvarchar(50)
	,@p_claim_amount				decimal(18,2)
	,@p_ppn_amount					decimal(18,2)
	,@p_pph_amount					decimal(18,2)
	,@p_total_claim_amount			decimal(18,2)
	,@p_claim_type					nvarchar(250)
	,@p_claim_no					nvarchar(50)
	,@p_receipt_no					nvarchar(50)
	,@p_remark						nvarchar(4000)
	,@p_job_status					nvarchar(15)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) ;

	begin try
		insert into dbo.ams_interface_spaf_claim
		(
			date
			,status
			,fa_code
			,claim_amount
			,ppn_amount
			,pph_amount
			,total_claim_amount
			,claim_type
			,claim_no
			,receipt_no
			,remark
			,job_status
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
			@p_date
			,@p_status
			,@p_fa_code
			,@p_claim_amount
			,@p_ppn_amount
			,@p_pph_amount
			,@p_total_claim_amount
			,@p_claim_type
			,@p_claim_no
			,@p_receipt_no
			,@p_remark
			,@p_job_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;

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

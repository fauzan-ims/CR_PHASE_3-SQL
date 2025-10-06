/*
	created: Fadlan, 27 Mei 2021
*/
CREATE PROCEDURE dbo.xsp_fin_interface_account_transfer_proceed
(
	@p_code			   nvarchar(50)
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
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.account_transfer
			(
			    code
			    ,transfer_status
			    ,transfer_trx_date
			    ,transfer_value_date
			    ,transfer_remarks
			    ,cashier_code
			    ,cashier_amount
				,is_from
			    ,from_branch_code
			    ,from_branch_name
			    ,from_currency_code
			    ,from_exch_rate
			    ,from_orig_amount
			    ,from_branch_bank_code
			    ,from_branch_bank_name
			    ,from_gl_link_code
			    ,to_branch_code
			    ,to_branch_name
			    ,to_currency_code
			    ,to_exch_rate
			    ,to_orig_amount
			    ,to_branch_bank_code
			    ,to_branch_bank_name
			    ,to_gl_link_code
			    ,cre_date
			    ,cre_by
			    ,cre_ip_address
			    ,mod_date
			    ,mod_by
			    ,mod_ip_address
			)
			select code
					,'HOLD'
                    ,transfer_trx_date
                    ,transfer_value_date
                    ,transfer_remarks
					,NULL
					,NULL
					,case isnull(from_branch_code,'')
						when '' then '0'
						else '1'
					end
                    ,isnull(from_branch_code,to_branch_code)
                    ,isnull(from_branch_name,to_branch_name)
                    ,from_currency_code
                    ,from_exch_rate
                    ,from_orig_amount
                    ,from_branch_bank_code
                    ,from_branch_bank_name
                    ,from_gl_link_code
                    ,to_branch_code
                    ,to_branch_name
                    ,to_currency_code
                    ,to_exch_rate
                    ,to_orig_amount
                    ,to_branch_bank_code
                    ,to_branch_bank_name
                    ,to_gl_link_code
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.fin_interface_account_transfer
			where	code = @p_code;

			update	dbo.fin_interface_account_transfer
			set		job_status = 'POST'
					,failed_remarks = null
			where	code = @p_code;
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

--set quoted_identifier on|off
--set ansi_nulls on|off
--go
CREATE procedure dbo.xsp_job_pull_lgl_to_fin_interface_payment_request
    @p_last_id_from_job		bigint
	,@p_last_id				bigint	= 0 output
	,@p_number_rows			int		= 0 output
-- with encryption, recompile, execute as caller|self|owner| 'user_name'
as

	declare @msg	nvarchar(max);

	begin try

		insert into dbo.fin_interface_payment_request
		(
		    code
		  , branch_code
		  , branch_name
		  , payment_source
		  , payment_source_no
		  , payment_status
		  , payment_currency_code
		  , payment_amount
		  , payment_remarks
		  , payment_request_date
		  , to_bank_account_name
		  , to_bank_name
		  , to_bank_account_no
		  , process_date
		  , process_reff_no
		  , process_reff_name
		  , cre_date
		  , cre_by
		  , cre_ip_address
		  , mod_date
		  , mod_by
		  , mod_ip_address
		)
		select
             code
             , branch_code
             , branch_name
             , payment_source
             , payment_source_no
             , payment_status
			 , payment_currency_code
             , payment_amount
             , payment_remarks
			 , payment_request_date
             , to_bank_account_name
             , to_bank_name
             , to_bank_account_no
             , process_date
             , process_reff_no
             , process_reff_name
             , getdate()
			 , 'job'
			 , '127.0.0.1'
			 , getdate()
			 , 'job'
			 , '127.0.0.1'
		from ifinlgl.dbo.lgl_interface_payment_request
		where id > @p_last_id_from_job
		order by id asc
		offset 0 rows
		fetch next 10 rows only;

		set @p_number_rows = @@rowcount;

		select @p_last_id = max(data.id) from (
		select  id
		from ifinlgl.dbo.lgl_interface_payment_request
		where id > @p_last_id_from_job
		order by id asc
		offset 0 rows
		fetch next 10 rows only) data;

		if isnull(@p_last_id, 0) = 0
		begin
			select @p_last_id = @p_last_id_from_job;
		end

		
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch;
 

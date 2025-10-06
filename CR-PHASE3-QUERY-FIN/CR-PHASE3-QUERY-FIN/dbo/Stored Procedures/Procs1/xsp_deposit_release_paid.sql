CREATE PROCEDURE dbo.xsp_deposit_release_paid
(
	@p_code					nvarchar(50)
	--,@p_transaction_code	nvarchar(50)
	,@p_exch_rate			decimal(18,6)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			--,@gl_link_code				nvarchar(50)
			--,@agreement_no				nvarchar(50)
			,@deposit_code				nvarchar(50)
			,@release_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@agreement_no				nvarchar(50)
			--,@release_date				datetime
			,@deposit_currency_code		nvarchar(3)
			--,@currency_code				nvarchar(3)
			,@deposit_type				nvarchar(15)
			--,@release_remarks			nvarchar(4000)
			--,@index						bigint
			,@id						bigint

	begin try
	
		if exists (select 1 from dbo.deposit_release where code = @p_code and release_status <> 'APPROVE')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			declare cur_deposit_release_detail cursor fast_forward read_only for
			
			select	srd.id
					,srd.deposit_code
					,srd.release_amount
					,sr.branch_code
					,sr.branch_name
					,sr.currency_code
					,am.agreement_no
					,srd.deposit_type
					--,sm.deposit_type
					--,'Releas Deposit for ' + sr.code + ' ' + sr.release_remarks
					--,sm.agreement_no
					--,row_number() over(order by srd.id asc) as row#
			from	dbo.deposit_release_detail srd
					inner join dbo.deposit_release sr on (sr.code = srd.deposit_release_code)
					left join dbo.agreement_main am on (am.agreement_no = sr.agreement_no)
			where	srd.deposit_release_code = @p_code

			open cur_deposit_release_detail
		
			fetch next from cur_deposit_release_detail 
			into	@id
					,@deposit_code
					,@release_amount
					,@branch_code
					,@branch_name
					,@deposit_currency_code
					,@agreement_no
					,@deposit_type

			while @@fetch_status = 0
			begin

				if exists (select 1 from dbo.deposit_release_detail where id = @id and release_amount > deposit_amount)
				begin
					close cur_deposit_release_detail
					deallocate cur_deposit_release_detail
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Release Amount','Deposit Amount');
					raiserror(@msg ,16,-1)
				end
								
				--01/07/2021 deposit insert ke fin_interface_agreement_deposit_history
				set @release_amount = @release_amount * -1;
				set @base_amount = @release_amount * @p_exch_rate;
				exec dbo.xsp_fin_interface_agreement_deposit_history_insert @p_id						= 0                    
						                                                    ,@p_branch_code				= @branch_code
						                                                    ,@p_branch_name				= @branch_name
						                                                    ,@p_agreement_no			= @agreement_no
																			,@p_agreement_deposit_code  = @deposit_code
						                                                    ,@p_deposit_type			= @deposit_type
						                                                    ,@p_transaction_date		= @p_cre_date
						                                                    ,@p_orig_amount				= @release_amount
						                                                    ,@p_orig_currency_code		= @deposit_currency_code
						                                                    ,@p_exch_rate				= @p_exch_rate  
						                                                    ,@p_base_amount				= @base_amount
						                                                    ,@p_source_reff_module		= 'IFINFIN'
						                                                    ,@p_source_reff_code		= @p_code
						                                                    ,@p_source_reff_name		= 'Deposit Release'
						                                                    ,@p_cre_date				= @p_cre_date		
																			,@p_cre_by					= @p_cre_by			
																			,@p_cre_ip_address			= @p_cre_ip_address
																			,@p_mod_date				= @p_mod_date		
																			,@p_mod_by					= @p_mod_by			
																			,@p_mod_ip_address			= @p_mod_ip_address 

				
				fetch next from cur_deposit_release_detail 
				into	@id
						,@deposit_code
						,@release_amount
						,@branch_code
						,@branch_name
						,@deposit_currency_code
						,@agreement_no
						,@deposit_type
			
			end
			close cur_deposit_release_detail
			deallocate cur_deposit_release_detail

			update	dbo.deposit_release
			set		release_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
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




--Created by, Rian at 21/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_invoice_list
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_from_date		datetime
	,@p_to_date			datetime
    ,@p_is_condition	nvarchar(1)
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

	delete	dbo.rpt_invoice_list
	where user_id	= @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@invoice_no			nvarchar(50)
			,@invoice_type			nvarchar(50)
			,@description			nvarchar(250)
			,@invoice_date			datetime
			,@invoice_due_date		datetime
			,@status				nvarchar(50)
			,@amount				decimal(18,2)
			,@discount_amoun		decimal(18,2)
			,@ppn_amount			decimal(18,2)
			,@pph_amount			decimal(18,2)
			,@billing_amount		decimal(18,2)
			,@currency				nvarchar(5)
			,@faktur_no				nvarchar(50)
			,@client_name			nvarchar(250)
			,@settlement_pph_no		nvarchar(50)
			,@settlement_pph_date	datetime
            ,@branch_name			nvarchar(250)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report Invoice List'

		--insert into dbo.rpt_invoice_list
		--(
		--	user_id
		--	,report_company
		--	,report_image
		--	,report_title
		--	,from_date
		--	,to_date
		--	,branch_code
		--	,branch_name
		--	,invoice_no
		--	,invoice_type
		--	,description
		--	,invoice_date
		--	,invoice_due_date
		--	,status
		--	,amount
		--	,discount_amoun
		--	,ppn_amount
		--	,pph_amount
		--	,billing_amount
		--	,currency
		--	,faktur_no
		--	,client_name
		--	,settlement_pph_no
		--	,settlement_pph_date
		--	,is_condition
		--	--
		--	,cre_date
		--	,cre_by
		--	,cre_ip_address
		--	,mod_date
		--	,mod_by
		--	,mod_ip_address
		--)
		--select	@p_user_id
		--		,@report_company
		--		,@report_image	
		--		,@report_title	
		--		,@p_from_date	
		--		,@p_to_date		
		--		,@p_branch_code
		--		,@p_branch_name
		--		,invoice_no
		--		,invoice_type
		--		,invoice_name
		--		,invoice_date
		--		,invoice_due_date
		--		,invoice_status
		--		,total_amount
		--		,total_discount_amount
		--		,total_ppn_amount
		--		,total_pph_amount
		--		,total_billing_amount
		--		,currency_code
		--		,faktur_no
		--		,client_name
		--		,''--settlement_pph_no
		--		,''--settlement_pph_date
		--		,@p_is_condition
		--		--	--
		--		,@p_cre_date		
		--		,@p_cre_by			
		--		,@p_cre_ip_address	
		--		,@p_mod_date		
		--		,@p_mod_by			
		--		,@p_mod_ip_address	
		--from	dbo.invoice
		--where	branch_code = case @p_branch_code
		--							when 'ALL' then branch_code
		--							else @p_branch_code
		--						end	
		--		and cast(invoice_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

		insert into dbo.rpt_invoice_list
		(
		    user_id,
		    report_company,
		    report_image,
		    report_title,
		    from_date,
		    to_date,
		    branch_code,
		    branch_name,
		    invoice_no,
		    client_name,
		    invoice_type,
		    description,
		    invoice_date,
		    invoice_due_date,
		    status,
		    currency,
		    rental_amount,
		    discount_amount,
		    ppn_amount,
		    invoice_amount,
		    pph_amount,
		    nett_amount,
		    faktur_no,
		    settlement_pph_no,
		    settlement_pph_date,
			-- (+) Ari 2023-10-12
			agreement_no,
			payment_date,
			payment_amount,
			-- (+) Ari 2023-10-12
		    is_condition,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address,
			dpp_nilai_lain
		)
		select @p_user_id
				,@report_company
				,@report_image	
				,@report_title	
				,@p_from_date	
				,@p_to_date		
				,@p_branch_code
				,@p_branch_name
				,invoice_no
				,client_name
				,invoice_type
				,invoice_name
				,invoice_date
				,invoice_due_date 
				,invoice_status
				,currency_code
				,total_billing_amount
				,total_discount_amount
				,total_ppn_amount
				,(total_billing_amount - total_discount_amount + total_ppn_amount)
				,total_pph_amount
				,(total_billing_amount - total_discount_amount + total_ppn_amount) - total_pph_amount
				,faktur_no
				,''
				,null
				-- (+) Ari 2023-10-12
				,agr.agreement_external_no
				,received_reff_date
				,pay.payment_amount
				-- (+) Ari 2023-10-12
				,@p_is_condition
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address
				,dpp_nilai_lain
		from	dbo.invoice i with (nolock)
		-- (+) Ari 2023-10-12 ket : get agreement, payment amoun & date (Report Invoice List dan Outstanding Invoice digabung menjadi 1 report)
		outer	apply 
				(
					select	top 1
							am.agreement_external_no
							--,aip.payment_date
					from	dbo.invoice_detail id  with (nolock)
					inner	join dbo.agreement_main am  with (nolock) ON (am.agreement_no = id.agreement_no)
					--left	join dbo.agreement_invoice_payment aip on (aip.agreement_no = am.agreement_no)
					where	id.invoice_no = i.invoice_no
				) agr
		outer	apply
				(
					select	sum(isnull(aip.payment_amount,0)) 'payment_amount'
					from	dbo.agreement_invoice_payment aip  with (nolock)
					where	aip.invoice_no = i.invoice_no 
				) pay
		-- (+) Ari 2023-10-12
		where	branch_code = case @p_branch_code
									when 'ALL' then branch_code
									else @p_branch_code
								end	
				and cast(invoice_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

		if not exists (select * from dbo.rpt_invoice_list where user_id = @p_user_id)
		begin
				insert into dbo.rpt_invoice_list
				(
				    user_id,
					report_company,
					report_image,
					report_title,
					from_date,
					to_date,
					branch_code,
					branch_name,
					invoice_no,
					client_name,
					invoice_type,
					description,
					invoice_date,
					invoice_due_date,
					status,
					currency,
					rental_amount,
					discount_amount,
					ppn_amount,
					invoice_amount,
					pph_amount,
					nett_amount,
					faktur_no,
					settlement_pph_no,
					settlement_pph_date,
					is_condition,
					cre_date,
					cre_by,
					cre_ip_address,
					mod_date,
					mod_by,
					mod_ip_address,
					dpp_nilai_lain
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_image
				    ,@report_title
				    ,@p_from_date
				    ,@p_to_date
				    ,@p_branch_code
				    ,@p_branch_name
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,@p_is_condition
				    ,@p_cre_date		
					,@p_cre_by			
					,@p_cre_ip_address	
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address
					,null	
				 )
		end

		--values
		--(	
		--	@p_user_id
		--	,@report_image	
		--	,@report_title	
		--	,@p_from_date	
		--	,@p_to_date		
		--	,@p_branch_code
		--	,@invoice_no			
		--	,@invoice_type			
		--	,@description			
		--	,@invoice_date			
		--	,@invoice_due_date		
		--	,@status				
		--	,@amount				
		--	,@discount_amoun		
		--	,@ppn_amount			
		--	,@pph_amount			
		--	,@billing_amount		
		--	,@currency				
		--	,@faktur_no				
		--	,@client_name			
		--	,@settlement_pph_no		
		--	,@settlement_pph_date	
		--	--
		--	,@p_cre_date		
		--	,@p_cre_by			
		--	,@p_cre_ip_address	
		--	,@p_mod_date		
		--	,@p_mod_by			
		--	,@p_mod_ip_address	
		--) 

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

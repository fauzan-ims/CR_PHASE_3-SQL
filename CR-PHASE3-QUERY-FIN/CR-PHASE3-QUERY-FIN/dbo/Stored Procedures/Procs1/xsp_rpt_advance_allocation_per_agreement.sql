CREATE PROCEDURE dbo.xsp_rpt_advance_allocation_per_agreement
(
	@p_user_id				nvarchar(50) 	
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_agreement_no		nvarchar(50)
	,@p_deposit_type		nvarchar(50)
	,@p_is_condition		nvarchar(50)
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
		delete	dbo.rpt_advance_allocation_per_agreement
		where	user_id = @p_user_id

		declare @report_company					nvarchar(250)
				,@report_title					nvarchar(250)
				,@report_image					nvarchar(250) 
				,@deposit_type					nvarchar(50)
				,@client_name					nvarchar(250) 
				,@transaction_date				datetime
				,@transaction_no				nvarchar(50)
				,@description					nvarchar(250)
				,@currency						nvarchar(3)
				,@transaction_amount			decimal(18,2)
				,@outstanding_advance			decimal(18,2)
				,@note							nvarchar(4000)
				--
                ,@outstanding_advance_tampung	decimal(18,2)	
                ,@transcation_amount_tampung	decimal(18,2)	

		set	@report_title = 'Report Advance Mutation'

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'				
	 
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'

		/* declare main cursor */
		declare c_advance_allocation cursor local fast_forward read_only for 
		select	isnull(am.client_name,'-')
				,dm.transaction_date
				,isnull(dm.source_reff_code,'-')
				,isnull(dm.source_reff_name,'-')
				,isnull(dm.orig_currency_code,'-')
				,isnull(dm.orig_amount,0)
				,isnull(dm.source_reff_name,'-')
				,isnull(dm.deposit_type,'-')
		from	dbo.fin_interface_agreement_deposit_history dm with(nolock)
				left join dbo.agreement_main am with(nolock) on (am.agreement_no = dm.agreement_no)
		where	CAST(dm.transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		and		(am.agreement_external_no = @p_agreement_no)
		and		(dm.deposit_type = @p_deposit_type or @p_deposit_type = 'ALL')

		/* fetch record */
		open	c_advance_allocation
		fetch	c_advance_allocation
		into	@client_name				
				,@transaction_date		
				,@transaction_no		
				,@description			
				,@currency					
				,@transaction_amount   
				,@note		
				,@deposit_type			

		while @@fetch_status = 0
		begin

				if (@p_deposit_type = 'ALL')
				begin

						set @outstanding_advance = @transaction_amount

						if (@deposit_type = 'INSTALLMENT')
						begin

								select  @transcation_amount_tampung = sum(isnull(orig_amount,0))
								from dbo.fin_interface_agreement_deposit_history
								where (agreement_no = @p_agreement_no)
								and deposit_type = 'INSTALLMENT'

								if (@description = 'Deposit Move')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Revenue')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Allocation')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end

						end 
						
						if (@deposit_type = 'INSURANCE')
						begin

								select  @transcation_amount_tampung = sum(isnull(orig_amount,0))
								from dbo.fin_interface_agreement_deposit_history
								where (agreement_no = @p_agreement_no)
								and deposit_type = 'INSURANCE'

								if (@description = 'Deposit Move')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Revenue')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Allocation')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
						end
                        
						if (@deposit_type = 'OTHER')
						begin                   

								select  @transcation_amount_tampung = sum(isnull(orig_amount,0))
								from dbo.fin_interface_agreement_deposit_history
								where (agreement_no = @p_agreement_no)
								and deposit_type = 'OTHER'

								if (@description = 'Deposit Move')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Revenue')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
                                else if (@description = 'Deposit Allocation')
								begin
										set @outstanding_advance = @transcation_amount_tampung
								end
						end
						
				end
				else
                begin

						if (@description = 'CASHIER')
						begin

							set @outstanding_advance = @transaction_amount

						end
						else if (@description = 'Deposit Move')
						begin

							set @outstanding_advance = @outstanding_advance + @transaction_amount

						end
                
				end


				/* insert into table report */
				insert into dbo.rpt_advance_allocation_per_agreement
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_agreement_no 
						  ,filter_deposit_type
						  ,deposit_type
						  ,client_name
				          ,transaction_date 
				          ,transaction_no 
				          ,description 
				          ,currency 
				          ,transaction_amount 
				          ,outstanding_advance 
				          ,note 
						  ,is_condition
				          ,cre_by 
				          ,cre_date 
				          ,cre_ip_address 
				          ,mod_by 
				          ,mod_date 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title
				          ,@report_image
				          ,@p_from_date
						  ,@p_to_date
				          ,@p_agreement_no
						  ,@p_deposit_type
						  ,@deposit_type
						  ,@client_name
				          ,@transaction_date
				          ,@transaction_no
				          ,@description
				          ,@currency 
				          ,@transaction_amount
				          ,@outstanding_advance
				          ,@note
						  ,@p_is_condition
				          ,@p_cre_by
						  ,@p_cre_date
						  ,@p_cre_ip_address
						  ,@p_mod_by 							 
						  ,@p_mod_date
						  ,@p_mod_ip_address
				        )

		/* fetch record berikutnya */
		fetch	c_advance_allocation
		into	@client_name				
				,@transaction_date		
				,@transaction_no		
				,@description			
				,@currency				
				,@transaction_amount   
				,@note
				,@deposit_type

		end		

		--update	dbo.rpt_advance_allocation_per_agreement
		--set		outstanding_advance = @outstanding_advance
		--where	user_id = @p_user_id
		
		/* tutup cursor */
		close		c_advance_allocation
		deallocate	c_advance_allocation

		if not exists (select * from dbo.rpt_advance_allocation_per_agreement where user_id = @p_user_id)
		begin

				insert into dbo.rpt_advance_allocation_per_agreement
				        ( 
						  user_id 
				          ,report_company 
				          ,report_title 
				          ,report_image 
				          ,filter_from_date
						  ,filter_to_date 
				          ,filter_agreement_no 
						  ,filter_deposit_type
						  ,deposit_type
						  ,client_name
				          ,transaction_date 
				          ,transaction_no 
				          ,description 
				          ,currency 
				          ,transaction_amount 
				          ,outstanding_advance 
				          ,note 
						  ,is_condition
				          ,cre_by 
				          ,cre_date 
				          ,cre_ip_address 
				          ,mod_by 
				          ,mod_date 
				          ,mod_ip_address
				        )
				values  ( 
						  @p_user_id
				          ,@report_company
				          ,@report_title
				          ,@report_image
				          ,@p_from_date
						  ,@p_to_date
				          ,@p_agreement_no
						  ,@p_deposit_type
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
				          ,@p_cre_by
						  ,@p_cre_date
						  ,@p_cre_ip_address
						  ,@p_mod_by 							 
						  ,@p_mod_date
						  ,@p_mod_ip_address
				        )

		end


end

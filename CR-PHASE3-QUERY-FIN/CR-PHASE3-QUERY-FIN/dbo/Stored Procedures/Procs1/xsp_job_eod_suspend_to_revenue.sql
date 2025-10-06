CREATE PROCEDURE dbo.xsp_job_eod_suspend_to_revenue
as
begin

	declare @msg								nvarchar(max)  
            ,@mod_date							datetime = getdate()
            ,@sys_date							datetime = dbo.xfn_get_system_date()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'
			,@receipt_code						nvarchar(50)
			,@revenue_code						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@currency_code						nvarchar(3)
			,@suspend_code						nvarchar(50)
			,@max_month							bigint
			,@revenue_amount					decimal(18,2)	
			,@max_amount						decimal(18,2)	

	select	@max_month = cast(value as bigint)
	from	dbo.sys_global_param
	where	code = 'MAXMHSPN'

	begin try
		begin		
			declare cur_suspend cursor fast_forward read_only for
			select	code
					,branch_code
					,branch_name
					,suspend_currency_code
					,remaining_amount
			from	dbo.suspend_main
			where	datediff(month, suspend_date, dbo.xfn_get_system_date()) >= @max_month
					and remaining_amount									 > 0 
					and isnull(transaction_code, '')						 = ''

			open cur_suspend
		
			fetch next from cur_suspend 
			into	@suspend_code
					,@branch_code
					,@branch_name
					,@currency_code
					,@revenue_amount

			while @@fetch_status = 0
			begin
				
				exec dbo.xsp_suspend_revenue_insert @p_code					= @revenue_code output         
				                                    ,@p_branch_code			= @branch_code                   
				                                    ,@p_branch_name			= @branch_name
				                                    ,@p_revenue_status		= N'HOLD'                
				                                    ,@p_revenue_date		= @sys_date
				                                    ,@p_revenue_amount		= @revenue_amount 				                                    
													,@p_revenue_remarks		= N'Automatic Suspend to Revenue'               
				                                    ,@p_currency_code		= @currency_code                  
				                                    ,@p_exch_rate			= 1                    
				                                    ,@p_cre_date			= @mod_date    
				                                    ,@p_cre_by				= @mod_by                        
				                                    ,@p_cre_ip_address		= @mod_ip_address                
				                                    ,@p_mod_date			= @mod_date        
				                                    ,@p_mod_by				= @mod_by              
				                                    ,@p_mod_ip_address		= @mod_ip_address
				
				exec dbo.xsp_suspend_revenue_detail_insert @p_id					= 0
				                                           ,@p_suspend_revenue_code = @revenue_code
				                                           ,@p_suspend_code			= @suspend_code
				                                           ,@p_cre_date				= @mod_date    
				                                           ,@p_cre_by				= @mod_by               
				                                           ,@p_cre_ip_address		= @mod_ip_address       
				                                           ,@p_mod_date				= @mod_date        
				                                           ,@p_mod_by				= @mod_by              
				                                           ,@p_mod_ip_address		= @mod_ip_address
				
				exec dbo.xsp_suspend_revenue_post @p_code				= @revenue_code
				                                  ,@p_cre_date			= @mod_date    
				                                  ,@p_cre_by			= @mod_by         
				                                  ,@p_cre_ip_address	= @mod_ip_address 
				                                  ,@p_mod_date			= @mod_date       
				                                  ,@p_mod_by			= @mod_by         
				                                  ,@p_mod_ip_address	= @mod_ip_address
				

				fetch next from cur_suspend 
				into	@suspend_code
						,@branch_code
						,@branch_name
						,@currency_code
						,@revenue_amount
			
			end
			close cur_suspend
			deallocate cur_suspend

		end
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end

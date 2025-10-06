/*
exec xsp_job_eod_policy
*/
-- Louis Selasa, 14 Maret 2023 10.53.04 --
CREATE PROCEDURE [dbo].[xsp_job_eod_policy]
as
begin

	declare @msg								nvarchar(max)  
			,@policy_code						nvarchar(50)
			,@sysdate							nvarchar(250)
			,@policy_exp_date					date
            ,@mod_date							datetime = getdate()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'


	begin try
		begin			
			select @sysdate = value
			from dbo.sys_global_param
			where code = 'SYSDATE'

			declare c_policymain cursor local fast_forward read_only for
			select  code
					,cast(policy_exp_date as date)
			from	dbo.insurance_policy_main 
			where	policy_status in ('ACTIVE')
			and CRE_IP_ADDRESS <> 'MIGRASI'--temporary solution
			and policy_exp_date < @sysdate

			open c_policymain
			fetch c_policymain
			into  @policy_code
				  ,@policy_exp_date

			while @@fetch_status = 0 
			begin
				--if @policy_exp_date < @sysdate
				begin
					update insurance_policy_main
					set    policy_status = 'TERMINATE'
					where code = @policy_code
				
					exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0
					                                                  ,@p_policy_code		= @policy_code
					                                                  ,@p_history_date		= @mod_date
					                                                  ,@p_history_type		= 'TERMINATE'
					                                                  ,@p_policy_status		= 'EXPIRED'
					                                                  ,@p_history_remarks	= 'This transaction expired'
					                                                  ,@p_cre_date			= @mod_date		
					                                                  ,@p_cre_by			= @mod_by		
					                                                  ,@p_cre_ip_address	= @mod_ip_address
					                                                  ,@p_mod_date			= @mod_date		
					                                                  ,@p_mod_by			= @mod_by		
					                                                  ,@p_mod_ip_address	= @mod_ip_address
					
				end

				fetch c_policymain
				into  @policy_code
					  ,@policy_exp_date

			end
			close c_policymain
			deallocate c_policymain
			
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
	


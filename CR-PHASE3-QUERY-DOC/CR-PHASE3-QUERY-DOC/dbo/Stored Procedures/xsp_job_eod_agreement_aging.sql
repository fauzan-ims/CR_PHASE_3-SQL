CREATE PROCEDURE [dbo].[xsp_job_eod_agreement_aging]

as
BEGIN

	declare @msg								nvarchar(max)
			,@eod_date							datetime   
            ,@mod_date							datetime = getdate()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'
			,@agreement_no						nvarchar(50)
			,@collateral_no						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@locker_position					nvarchar(10)
			,@locker_name						nvarchar(250)
			,@drawer_name						nvarchar(250)
			,@row_name							nvarchar(250)
			,@document_status					nvarchar(20)
			,@mutation_type						nvarchar(20)
			,@mutation_location					nvarchar(20)
			,@mutation_from						nvarchar(50)
			,@mutation_to						nvarchar(50)
			,@mutation_by						nvarchar(250)
			,@mutation_date						datetime
			,@mutation_return_date				datetime
			,@last_mutation_type				nvarchar(20)
			,@last_mutation_date				datetime
			,@last_locker_position				nvarchar(10)
			,@first_receive_date				datetime
			,@release_customer_date				datetime;

	select  @eod_date	= value
	from	dbo.sys_global_param 
	where	code		= 'SYSDATE'

	begin try
		begin
		
			declare c_agr cursor local fast_forward read_only for
			select  am.agreement_no
					,isnull(dm.collateral_no, '')
					,am.branch_code
					,am.branch_name
					,isnull(dm.locker_position, '')
					,ml.locker_name
					,md.drawer_name
					,mr.row_name
					,isnull(dm.document_status, '')
					,isnull(dm.mutation_type, '')
					,isnull(dm.mutation_location, '')
					,isnull(dm.mutation_from, '')
					,isnull(dm.mutation_to, '')
					,isnull(dm.mutation_by, '')
					,dm.mutation_date
					,dm.mutation_return_date
					,dm.last_mutation_type
					,dm.last_mutation_date
					,dm.last_locker_position
					,dm.first_receive_date
					,dm.release_customer_date
			from	dbo.agreement_main am 
					left join dbo.document_main dm on (dm.agreement_no = am.agreement_no)
					left join dbo.master_locker ml on (ml.code = dm.locker_code)
					left join dbo.master_drawer md on (md.code = dm.drawer_code)
					left join dbo.master_row mr on (mr.code = dm.row_code)
			where	agreement_status		= 'GO LIVE'
			
			open c_agr
			fetch c_agr
			into @agreement_no
				 ,@collateral_no
				 ,@branch_code
				 ,@branch_name
				 ,@locker_position
				 ,@locker_name
				 ,@drawer_name
				 ,@row_name
				 ,@document_status
				 ,@mutation_type
				 ,@mutation_location
				 ,@mutation_from
				 ,@mutation_to
				 ,@mutation_by
				 ,@mutation_date
				 ,@mutation_return_date
				 ,@last_mutation_type
				 ,@last_mutation_date
				 ,@last_locker_position
				 ,@first_receive_date
				 ,@release_customer_date

			while @@fetch_status = 0 
			begin
				
				exec dbo.xsp_doc_interface_agreement_collateral_aging_insert @p_id						= 0
																			 ,@p_aging_date				= @eod_date
																			 ,@p_agreement_no			= @agreement_no
																			 ,@p_collateral_no			= @collateral_no
																			 ,@p_branch_code			= @branch_code
																			 ,@p_branch_name			= @branch_name
																			 ,@p_locker_position		= @locker_position
																			 ,@p_locker_name			= @locker_name
																			 ,@p_drawer_name			= @drawer_name
																			 ,@p_row_name				= @row_name
																			 ,@p_document_status		= @document_status
																			 ,@p_mutation_type			= @mutation_type
																			 ,@p_mutation_location		= @mutation_location
																			 ,@p_mutation_from			= @mutation_from
																			 ,@p_mutation_to			= @mutation_to
																			 ,@p_mutation_by			= @mutation_by
																			 ,@p_mutation_date			= @mutation_date
																			 ,@p_mutation_return_date	= @mutation_return_date
																			 ,@p_last_mutation_type		= @last_mutation_type
																			 ,@p_last_mutation_date		= @last_mutation_date
																			 ,@p_last_locker_position	= @last_locker_position
																			 ,@p_first_receive_date		= @first_receive_date
																			 ,@p_release_customer_date	= @release_customer_date
																			 ,@p_cre_date				= @mod_date		
																			 ,@p_cre_by					= @mod_by		
																			 ,@p_cre_ip_address			= @mod_ip_address
																			 ,@p_mod_date				= @mod_date		
																			 ,@p_mod_by					= @mod_by		
																			 ,@p_mod_ip_address			= @mod_ip_address
				
				
			    fetch c_agr
				into @agreement_no
					 ,@collateral_no
					 ,@branch_code
					 ,@branch_name
					 ,@locker_position
					 ,@locker_name
					 ,@drawer_name
					 ,@row_name
					 ,@document_status
					 ,@mutation_type
					 ,@mutation_location
					 ,@mutation_from
					 ,@mutation_to
					 ,@mutation_by
					 ,@mutation_date
					 ,@mutation_return_date
					 ,@last_mutation_type
					 ,@last_mutation_date
					 ,@last_locker_position
					 ,@first_receive_date
					 ,@release_customer_date

			end
			close c_agr
			deallocate c_agr
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


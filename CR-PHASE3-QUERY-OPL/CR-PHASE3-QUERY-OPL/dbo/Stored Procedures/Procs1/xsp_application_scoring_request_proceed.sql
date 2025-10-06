/*
	ALTERd : Louis, 20 May 2020
*/
CREATE PROCEDURE [dbo].[xsp_application_scoring_request_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@application_no		 nvarchar(50)
			,@scoring_status		 nvarchar(10)
			,@scoring_date			 datetime
			,@scoring_remarks		 nvarchar(4000)
			,@scoring_result_date	 datetime
			,@scoring_result_value	 nvarchar(250)
			,@scoring_result_remarks nvarchar(4000)
			,@process_date			 datetime
			,@process_reff_no		 nvarchar(50)
			,@process_reff_name		 nvarchar(250) 
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(50)
			,@reff_object			 nvarchar(4000) 
			,@request_id			 bigint	

	begin try
		if exists
		(
			select	1
			from	dbo.application_scoring_request
			where	code			   = @p_code
					and scoring_status = 'HOLD'
		)
		begin
		
			If not exists (	select 1 
						from	dbo.master_scoring
						where	is_active = '1'
						and		scoring_reff_type = 'APPSCR'
						and		code = 'APPLICATION_SCORING'
					)
			begin
				set @msg = 'Please setting master scoring for APPLICATION_SCORING'
				raiserror(@msg,16,1)
				return
			END
            
			--(+) Rinda  7/12/2021  Notes :	validasi klu masih ada dimension yg kosong lengkapi dlu 
			if exists (select 1 from dbo.master_scoring_dimension mcd
						inner join dbo.master_scoring mc on (mc.code=mcd.scoring_code)
						where mc.is_active ='1'
						and		scoring_reff_type = 'APPSCR'
						and		code = 'APPLICATION_SCORING'
						AND		ISNULL(mcd.DIMENSION_CODE,'') =''
						)
			begin
				set @msg = 'Please complete setting dimension master scoring for APPLICATION_SCORING'
				raiserror(@msg,16,1)
				return
			end
		
			select	@application_no				= application_no
					,@scoring_status			= scoring_status
					,@scoring_date				= scoring_date
					,@scoring_remarks			= scoring_remarks
					,@scoring_result_date		= scoring_result_date
					,@scoring_result_value		= scoring_result_value
					,@scoring_result_remarks	= scoring_result_remarks
					,@reff_object				= scoring_object
			from	application_scoring_request 
			where	code						= @p_code ;

			select	@branch_code = branch_code
					,@branch_name = branch_name
			from	dbo.application_main
			where	application_no = @application_no ;
			
			update	dbo.application_scoring_request
			set		scoring_status	= 'REQUEST'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code ;
			
			If  exists (select 1 
						from	dbo.master_scoring
						where	is_active = '1'
						and		scoring_reff_type = 'APPSCR'
						and		code = 'APPLICATION_SCORING'
					)
			begin
				exec dbo.xsp_opl_interface_scoring_request_insert @p_id							= @request_id output
																  ,@p_code						= ''
																  ,@p_branch_code				= @branch_code
																  ,@p_branch_name				= @branch_name
																  ,@p_reff_code					= @p_code
																  ,@p_reff_name					= N'APPLICATION SCORING'
																  ,@p_reff_type					= 'APPSCR'
																  ,@p_reff_remarks				= @scoring_remarks
																  ,@p_status					= N'HOLD'
																  ,@p_date						= @scoring_date
																  ,@p_scoring_result_date		= null
																  ,@p_scoring_result_value		= null
																  ,@p_scoring_result_remarks	= null
																  ,@p_process_date				= null
																  ,@p_process_reff_no			= null
																  ,@p_process_reff_name			= null
																  ,@p_reff_object				= @reff_object
																  ,@p_cre_date					=  @p_mod_date		
																  ,@p_cre_by					=  @p_mod_by			
																  ,@p_cre_ip_address			=  @p_mod_ip_address
																  ,@p_mod_date					=  @p_mod_date		
																  ,@p_mod_by					=  @p_mod_by			
																  ,@p_mod_ip_address			=  @p_mod_ip_address

				exec dbo.xsp_opl_interface_request_detail @p_type					= N'SCORING'            
				                                          ,@p_master_reff_type		= N'APPSCR'         
				                                          ,@p_reff_code				= @application_no       
				                                          ,@p_reff_table			= N'APPLICATION_MAIN'
														  ,@p_master_code			= 'APPLICATION_SCORING'
				                                          ,@p_request_code			= @p_code
				                                          ,@p_mod_date				= @p_mod_date
														  ,@p_mod_by				= @p_mod_by
														  ,@p_mod_ip_address		= @p_mod_ip_address ;
			end
		end ;
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
		end ;
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


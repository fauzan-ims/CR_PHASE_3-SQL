CREATE PROCEDURE dbo.xsp_opl_interface_request_detail
(
	@p_type					nvarchar(20) -- scoring, survey atau appraisal
	,@p_master_reff_type	nvarchar(50) --'appscr'
	,@p_reff_code			nvarchar(50)
	,@p_reff_table			nvarchar(250)
	,@p_request_code		nvarchar(50)
    ,@p_master_code			nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @msg					nvarchar(max)
			,@request_code			nvarchar(50)
			,@dimension_code		nvarchar(50)
			,@dim_value				nvarchar(100)
			,@dimension_description	nvarchar(250)
			,@item_code				nvarchar(50)--(+) Rinda  7/12/2021  Notes :	
			,@dim_svy_code			nvarchar(50)--(+) Rinda  7/12/2021  Notes :	
			,@dim_apr_code			nvarchar(50)--(+) Rinda  7/12/2021  Notes :	

			
	if (@p_type = 'SCORING')
	begin
		select	@request_code	 = code
		from	dbo.opl_interface_scoring_request
		where	reff_code = @p_request_code
	
		declare master_dimension cursor for
		select	msd.dimension_code
				,sd.description
				,msd.reff_item_code
		from	dbo.master_scoring ms
				inner join dbo.master_scoring_dimension msd on ms.code = msd.scoring_code
				left join dbo.sys_dimension sd on sd.code = msd.dimension_code
		where	ms.scoring_reff_type = @p_master_reff_type
		and		ms.code	= @p_master_code	
		and		ms.is_active = '1'

		open master_dimension		
		fetch next from master_dimension
		into	@dimension_code
				,@dimension_description
				,@item_code
				
		while @@fetch_status = 0
		begin
			if (isnull(@dimension_code, '') = '')
			begin
				set @msg = 'Please setting Master Scoring';
				raiserror(@msg, 16, 1) ;
			end

			set @dim_value = '';
			
			exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
														,@p_reff_code	= @p_reff_code	
														,@p_reff_table	= @p_reff_table	
														,@p_output		= @dim_value output ;
												
			exec dbo.xsp_opl_interface_scoring_request_detail_insert	@p_id						= 0             
																		,@p_scoring_request_code	= @request_code
																		,@p_scoring_item_code		= @item_code
																		,@p_scoring_item_value		= @dim_value
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address ;

		fetch next from master_dimension
		into	@dimension_code
				,@dimension_description
				,@item_code
		end
				
		close master_dimension
		deallocate master_dimension
	end	
end 



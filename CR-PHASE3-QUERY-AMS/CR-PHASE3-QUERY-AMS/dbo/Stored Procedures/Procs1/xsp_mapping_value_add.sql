CREATE PROCEDURE dbo.xsp_mapping_value_add
(
	@p_id			   bigint
	,@p_code		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@asset_type			nvarchar(50)
			,@transaction_type		nvarchar(50);

	begin try
		
		declare curr_mapping_vallue cursor fast_forward read_only for
		select asset_type
				,transaction_type 
		from dbo.master_custom_report
		where code = @p_code
		
		open curr_mapping_vallue
		
		fetch next from curr_mapping_vallue 
		into @asset_type
			,@transaction_type
		
		while @@fetch_status = 0
		begin
		    insert into dbo.master_custom_report_column
		    (
		    	custom_report_code
		    	,column_name
		    	,header_name
		    	,order_key
		    	,cre_date
		    	,cre_by
		    	,cre_ip_address
		    	,mod_date
		    	,mod_by
		    	,mod_ip_address
		    )
		    select 
				  @p_code
				  ,column_name
				  ,field_name
				  ,0
				  ,cre_date
				  ,cre_by
				  ,cre_ip_address
				  ,mod_date
				  ,mod_by
				  ,mod_ip_address 
			from dbo.master_mapping_value_detail
			where id = @p_id
		
		    fetch next from curr_mapping_vallue 
			into @asset_type
			,@transaction_type
		end
		
		close curr_mapping_vallue
		deallocate curr_mapping_vallue

		
		
	end try
	Begin catch
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

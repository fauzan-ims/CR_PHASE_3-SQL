CREATE PROCEDURE [dbo].[xsp_supplier_selection_approve]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@reff_no		  nvarchar(50)
			,@asset_no		  nvarchar(50)
			,@description_log nvarchar(4000)
			,@application_no  nvarchar(50)
			,@item_name		  nvarchar(250)
			,@date			  datetime = dbo.xfn_get_system_date()

	begin try
		if exists
		(
			select	1
			from	supplier_selection
			where	status	 = 'ON PROCESS'
					and code = @p_code
		)
		begin
			update	dbo.supplier_selection
			set		status			= 'APPROVE'
					,count_return	= 0
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			update	dbo.supplier_selection_detail
			set		supplier_selection_detail_status = 'HOLD'
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	selection_code					= @p_code ;

			
			declare curr_log cursor fast_forward read_only for
			select	reff_no
			from	dbo.supplier_selection_detail
			where	selection_code = @p_code ;
			
			open curr_log
			
			fetch next from curr_log 
			into @reff_no
			
			while @@fetch_status = 0
			begin
				select	distinct
						@asset_no	= d.asset_no
						,@item_name	= a.item_name
				from	dbo.supplier_selection_detail		  a
						left join dbo.quotation_review_detail b on a.reff_no = b.quotation_review_code collate Latin1_General_CI_AS
						left join dbo.procurement			  c on c.code	 = isnull(b.reff_no, a.reff_no)collate Latin1_General_CI_AS
						inner join dbo.procurement_request	  d on d.code	 = c.procurement_request_code
				where	a.reff_no = @reff_no ;

				select @application_no = isnull(application_no,'') 
				from ifinopl.dbo.application_asset 
				where asset_no = @asset_no

				if (@application_no <> '')
				begin
					set @description_log = 'Supplier selection approve, Asset no : ' + @asset_no + ' - ' + @item_name
		
					exec ifinopl.dbo.xsp_application_log_insert @p_id					= 0
																,@p_application_no		= @application_no
																,@p_log_date			= @date
																,@p_log_description		= @description_log
																,@p_cre_date			= @p_mod_date
																,@p_cre_by				= @p_mod_by
																,@p_cre_ip_address		= @p_mod_ip_address
																,@p_mod_date			= @p_mod_date
																,@p_mod_by				= @p_mod_by
																,@p_mod_ip_address		= @p_mod_ip_address
				end

				
			    			
			    fetch next from curr_log 
				into @reff_no
			end
			
			close curr_log
			deallocate curr_log
		end ;
		else
		begin
			set @msg = N'Data already POST.' ;

			raiserror(@msg, 16, -1) ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

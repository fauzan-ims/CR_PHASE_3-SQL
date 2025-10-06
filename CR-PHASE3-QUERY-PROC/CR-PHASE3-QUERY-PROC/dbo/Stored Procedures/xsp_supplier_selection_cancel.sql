CREATE PROCEDURE [dbo].[xsp_supplier_selection_cancel]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@status			nvarchar(20)
			,@reff_no			nvarchar(50)
			,@status_detail		nvarchar(50)
			,@asset_no			nvarchar(50)
			,@description_log	nvarchar(4000)
			,@application_no	nvarchar(50)
			,@item_name			nvarchar(250)
			,@date				datetime = dbo.xfn_get_system_date()

	begin try  
		select	@status		= status
		from	dbo.supplier_selection
		where	code = @p_code ;

		if exists (select 1 from dbo.supplier_selection_detail where selection_code = @p_code and supplier_selection_detail_status = 'POST')
		begin
			set @msg = 'Cannot cancel this data. Data already proceed.';
			raiserror(@msg ,16,-1);
		end

		if (@status = 'HOLD')
		begin
			update	dbo.supplier_selection
			set		status			= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;


			declare cursor_name cursor fast_forward read_only for
			select reff_no 
			from dbo.supplier_selection_detail
			where selection_code = @p_code
			
			open cursor_name
			
			fetch next from cursor_name 
			into @reff_no
			
			while @@fetch_status = 0
			begin
			    update dbo.quotation_review
				set		status = 'HOLD'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @reff_no;

				--update dbo.QUOTATION_REVIEW_DETAIL
				--set		TYPE					= 'NEW'
				--		--
				--		,mod_date				= @p_mod_date
				--		,mod_by					= @p_mod_by
				--		,mod_ip_address			= @p_mod_ip_address
				--where	quotation_review_code	= @reff_no;


				 update dbo.procurement
				 set	status = 'HOLD'
				 		--
				 		,mod_date		= @p_mod_date
				 		,mod_by			= @p_mod_by
				 		,mod_ip_address = @p_mod_ip_address
				 where	code = @reff_no;

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
					set @description_log = 'Supplier selection cancel, Asset no : ' + @asset_no + ' - ' + @item_name
		
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

				
			
			    fetch next from cursor_name 
				into @reff_no
			end
			
			close cursor_name
			deallocate cursor_name
		end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
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
end ;

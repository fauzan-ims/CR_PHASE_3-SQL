CREATE PROCEDURE dbo.xsp_warning_letter_delivery_detail_update
(
	@p_id				  int
	,@p_received_status	  nvarchar(20) = null
	,@p_received_date	  datetime = null
	,@p_received_by		  nvarchar(250) = null
	,@p_received_remarks  nvarchar(4000) = null
    --,@p_file_name		  nvarchar(250) = null
    --,@p_paths			  nvarchar(250) = null
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@delivery_code			nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@id_detail				int
			,@installment_no 		int;

		select  @agreement_no		= wl.agreement_no
				,@installment_no	= wl.installment_no 
				,@delivery_code		= wldd.delivery_code 
		from	dbo.warning_letter_delivery_detail wldd
				inner join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
		where	wldd.id = @p_id

	begin try
		if (@p_received_date is not null and cast(@p_received_date as date) > cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Received Date','System Date');
			raiserror(@msg ,16,-1)
		end

		if(@p_received_status = 'NOT DELIVERED')
		begin
			update	dbo.warning_letter_delivery_detail 
			set		received_status		= @p_received_status
					,received_date		= NULL
					,received_by		= NULL
					,received_remarks	= @p_received_remarks
					--,file_name			= NULL
					--,paths				= NULL
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			from	dbo.warning_letter_delivery_detail wldd
					inner join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			where	wldd.delivery_code = @delivery_code
					and wl.agreement_no = @agreement_no
			--where	id					= @p_id ;

			--declare	c_detail cursor local fast_forward for
			
			--select	wldd.id 
			--from	dbo.warning_letter_delivery_detail wldd
			--		inner join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			--where	wldd.delivery_code = @delivery_code
			--		and wl.agreement_no = @agreement_no
			--		and wldd.id <> @p_id
			
			--open c_detail		
			--fetch next from c_detail 
			--into @id_detail						

			--while	@@fetch_status = 0
			--begin
				
			--	update	dbo.warning_letter_delivery_detail
			--	set		received_status		= @p_received_status
			--			,received_date		= NULL
			--			,received_by		= NULL
			--			,received_remarks	= @p_received_remarks
			--			,file_name			= NULL
			--			,paths				= NULL
			--			,mod_date			= @p_mod_date
			--			,mod_by				= @p_mod_by
			--			,mod_ip_address		= @p_mod_ip_address
			--	where	id					= @id_detail

			--	fetch next from c_detail 
			--	into @id_detail
			--end
			--close	c_detail
			--deallocate	c_detail

			--update	dbo.warning_letter_delivery_detail
			--set		received_status		= @p_received_status
			--		,received_date		= NULL
			--		,received_by		= NULL
			--		,received_remarks	= @p_received_remarks
			--		,file_name			= NULL
			--		,paths				= NULL
			--		,mod_date			= @p_mod_date
			--		,mod_by				= @p_mod_by
			--		,mod_ip_address		= @p_mod_ip_address
			--where	id	in  (
			--					select id from	dbo.warning_letter_delivery_detail wldd
			--					inner	join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			--					where	wl.agreement_no = @agreement_no
			--							and wl.installment_no = @installment_no
			--							and id <> @p_id
			--							--and wldd.received_remarks <> @p_received_remarks
			--				)

		end
        else if(@p_received_status = 'DELIVERED')
		begin
			--declare	c_detail cursor local fast_forward for
			
			--select	wldd.id 
			--from	dbo.warning_letter_delivery_detail wldd
			--		inner join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			--where	wldd.delivery_code = @delivery_code
			--		and wl.agreement_no = @agreement_no
			--		and wldd.id <> @p_id
			
			--open c_detail		
			--fetch next from c_detail 
			--into @id_detail						

			--while	@@fetch_status = 0
			--begin
				
			--	set @p_received_by = isnull(@p_received_by,'CLIENT') 
			--	update	dbo.warning_letter_delivery_detail
			--	set		received_status		= @p_received_status
			--			,received_date		= @p_received_date
			--			,received_by		= @p_received_by
			--			,received_remarks	= @p_received_remarks
			--			,mod_date			= @p_mod_date
			--			,mod_by				= @p_mod_by
			--			,mod_ip_address		= @p_mod_ip_address
			--	where	id					= @id_detail

			--	fetch next from c_detail 
			--	into @id_detail
			--end
			--close	c_detail
			--deallocate	c_detail

			--if (isnull(@p_received_by,'') = '')
			--begin
				--set @p_received_by = isnull(@p_received_by,'CLIENT') 
				--update	dbo.warning_letter_delivery_detail
				--set		received_status		= @p_received_status
				--		,received_date		= @p_received_date
				--		,received_by		= @p_received_by
				--		,received_remarks	= @p_received_remarks
				--		,mod_date			= @p_mod_date
				--		,mod_by				= @p_mod_by
				--		,mod_ip_address		= @p_mod_ip_address
				--where	id	in  (
				--					select id from	dbo.warning_letter_delivery_detail wldd
				--					inner	join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
				--					where	wl.agreement_no = @agreement_no
				--							and wl.installment_no = @installment_no
				--							and id <> @p_id
				--							--and wldd.received_remarks <> @p_received_remarks
				--				)
			--end
			--else 
			--begin
			--	update	dbo.warning_letter_delivery_detail
			--	set		received_status		= @p_received_status
			--			,mod_date			= @p_mod_date
			--			,mod_by				= @p_mod_by
			--			,mod_ip_address		= @p_mod_ip_address
			--	where	id	in  (
			--						select id from	dbo.warning_letter_delivery_detail wldd
			--						inner	join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			--						where	wl.agreement_no = @agreement_no
			--								and wl.installment_no = @installment_no
			--					)
			--end

			set @p_received_by = isnull(@p_received_by,'CLIENT') 
			update	dbo.warning_letter_delivery_detail
			set		received_status		= @p_received_status
					,received_date		= @p_received_date
					,received_by		= @p_received_by
					,received_remarks	= @p_received_remarks
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			from	dbo.warning_letter_delivery_detail wldd
					inner join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
			where	wldd.delivery_code = @delivery_code
					and wl.agreement_no = @agreement_no
			--where	id					= @p_id ;

		end

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

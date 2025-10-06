CREATE PROCEDURE [dbo].[xsp_rpt_listing_data_master]
(
	@p_table_name nvarchar(100)
)
as
begin
	declare @msg	nvarchar(max)
			,@value	nvarchar(max)

	begin try
		--if (@p_table_name = 'MASTER_ROW')
		--begin
		--	select	mr.code
		--			,mr.row_name
		--			,md.drawer_name
		--			,ml.locker_name
		--			,case mr.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_row mr
		--			inner join dbo.master_drawer md on md.code = mr.drawer_code 
		--			inner join dbo.master_locker ml on ml.code = md.locker_code ;
		--end ;
		--else if (@p_table_name = 'MASTER_LOCKER')
		--begin
		--	select	code
		--		   ,branch_code
		--		   ,branch_name
		--		   ,locker_name
		--		   ,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_locker ;
		--end ;
		--else 
		--IF (@p_table_name = 'MASTER_FAQ')
		--begin
		--	select	msf.id
		--			,msf.question
		--			,msf.answer
		--			,msf.filename
		--			,msf.paths
		--			,case msf.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_faq msf;
		--end
		--else
		--begin
		
			set @value = 'SELECT * FROM .dbo.' + @p_table_name
			exec sp_executesql @value	

		--end

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

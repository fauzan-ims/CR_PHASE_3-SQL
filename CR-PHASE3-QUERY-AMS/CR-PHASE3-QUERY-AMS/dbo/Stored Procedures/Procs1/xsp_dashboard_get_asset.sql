CREATE PROCEDURE dbo.xsp_dashboard_get_asset
(
	@p_company_code		nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @temp_table table
		(
			total_data int
			,reff_name nvarchar(250)
		) ;

		insert into @temp_table
		(
			total_data
			,reff_name
		)
		select		count(1)
					,'Vehicle'
		from		dbo.asset
		where		type_code = 'VHCL'
		union
		select		count(1)
					,'Electronic'
		from		dbo.asset
		where		type_code = 'ELCT'
		union
		select		count(1)
					,'Furniture'
		from		dbo.asset
		where		type_code = 'FNTR'
		union
		select		count(1)
					,'Machine'
		from		dbo.asset
		where		type_code = 'MCHN'
		union
		select		count(1)
					,'Machine'
		from		dbo.asset
		where		type_code = 'PRTY'
		union
		select		count(1)
					,'Others'
		from		dbo.asset
		where		type_code = 'OTHR'


		select	total_data
				,reff_name
		from	@temp_table ;

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

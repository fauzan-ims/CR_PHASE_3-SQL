CREATE PROCEDURE dbo.xsp_faktur_registration_generate
(
	@p_code				  nvarchar(50)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin

	declare @counter				int = 1
			,@no_of_faktur			int
			,@faktur_no				nvarchar(50)
			,@faktur_prefix			nvarchar(15)
			,@faktur_postfix		nvarchar(10)
			,@faktur_running_no		nvarchar(35)
			,@no					int
			,@lenght				int
			,@temp					int
			,@year					nvarchar(4)
			,@msg					nvarchar(max) ;

	begin try

		delete dbo.faktur_registration_detail
		where registration_code = @p_code

		select	@faktur_running_no			= faktur_running_no
				,@faktur_prefix				= faktur_prefix
				,@faktur_postfix			= '' --faktur_postfix
				,@no_of_faktur				= count
				,@year						= year
		from	dbo.faktur_registration
		where	code						= @p_code

		set @lenght = len(@faktur_running_no)
		set @temp = len(@faktur_running_no)

		while (@counter <= @no_of_faktur)
		begin		
			
			set @faktur_no = @faktur_prefix + @faktur_running_no + isnull(@faktur_postfix, '')--format faktur

			exec	dbo.xsp_faktur_registration_detail_insert 
					0
					,@p_code
					,@year
					,@faktur_no
					--
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address	
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address	

				set	@no = cast(@faktur_running_no as int) + 1
				set	@lenght = len(@no)	

				IF @lenght > @temp
					SET @temp = @lenght

			set @faktur_running_no = replace(str(cast((cast(@faktur_running_no as int) + 1) as nvarchar), @temp, 0), ' ', '0') --untuk buat faktur selanjutnya
			set @counter	= @counter + 1
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

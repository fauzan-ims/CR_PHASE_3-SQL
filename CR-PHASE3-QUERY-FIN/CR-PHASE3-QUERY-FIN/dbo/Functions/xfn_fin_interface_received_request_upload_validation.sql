CREATE FUNCTION dbo.xfn_fin_interface_received_request_upload_validation
(
	@p_branch_code								nvarchar(50)
	,@p_branch_name								nvarchar(250)
	,@p_received_source							nvarchar(50)
	,@p_received_source_no						nvarchar(50)
	,@p_received_request_date					datetime
    ,@p_received_currency_code					nvarchar(3)
	,@p_received_amount							decimal(18, 2)	
	,@p_received_remarks						nvarchar(4000)
	
)
returns nvarchar(max)
as
begin
	
	declare @static_err			nvarchar(max)=''
			,@validation_err	nvarchar(max)=''

	--Branch Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_branch_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_branch_code,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Code ' + @validation_err;

    END
    
	--Branch Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_branch_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_branch_code,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Branch Name ' + @validation_err;

    end

	--Received Source--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_received_source)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Source ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_received_source,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Received Source ' + @validation_err;

    END
    
	--Received Source No--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_received_source_no)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Source No ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_received_source_no,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Received Source No ' + @validation_err;

    END

	--Received Request Date--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_received_request_date)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Request Date ' + @validation_err;
	END
    
	set @validation_err = ''

	set @validation_err = dbo.xfn_xfn_upload_validation_system_date(@p_received_request_date,'Received Request Date')

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + @validation_err;
	END

	--Received Currency Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_received_currency_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Currency Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_received_currency_code,3)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Currency Code ' + @validation_err;

    END

	--Received Amount--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_amount_cannot_be_zero(@p_received_amount)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Received Amount ' + @validation_err;
	END
    
	--Received Remarks--
	--set @validation_err = ''

	--SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_received_remarks)

	--if (@validation_err <> '')
	--begin
	--	set @static_err = @static_err + 'Received Remarks ' + @validation_err;
	--end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_received_remarks,4000)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Received Remarks ' + @validation_err;

    END

	if(@static_err = '')
	begin
		
		set @static_err = 'OK'

    end
    else
	begin

		set @static_err = (select substring(@static_err ,2,len(@static_err)-2))

		SET @static_err = 'NOK :' + @static_err

    END

	return @static_err

end

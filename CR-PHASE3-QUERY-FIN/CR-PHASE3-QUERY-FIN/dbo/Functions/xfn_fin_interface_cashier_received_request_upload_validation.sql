CREATE FUNCTION dbo.xfn_fin_interface_cashier_received_request_upload_validation
(
	@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_request_currency_code				nvarchar(5)
	,@p_request_date						datetime
	,@p_request_amount						decimal(18, 2)
	,@p_request_remarks						nvarchar(4000)
	,@p_agreement_no						nvarchar(50)
	,@p_pdc_code							nvarchar(50)
	,@p_pdc_no								nvarchar(50)
	,@p_doc_ref_code						nvarchar(50)
	,@p_doc_ref_name						nvarchar(250)
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

    END

	--Request Currency--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_request_currency_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Currency ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_request_currency_code,3)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Currency ' + @validation_err;

    END

	--Request Date--
	set @validation_err = ''

	set @validation_err = dbo.xfn_xfn_upload_validation_system_date(@p_request_date,'Request Date')

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + @validation_err;
	END

	--Request Amount--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_amount_cannot_be_zero(@p_request_amount)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Request Amount ' + @validation_err;
	END
    
	--Request Remarks--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_request_remarks)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Request Remarks ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_request_remarks,4000)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Request Remarks ' + @validation_err;

    END

	--Agreement No--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_agreement_no)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Agreement No ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_agreement_no,20)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Agreement No ' + @validation_err;

    END

	--PDC Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_pdc_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'PDC Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_pdc_code,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', PDC Code ' + @validation_err;

    END

	--PDC No--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_pdc_no)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'PDC No ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_pdc_no,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', PDC No ' + @validation_err;

    END

	--DOC REFF Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_doc_ref_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'DOC REFF Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_doc_ref_code,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', DOC REFF Code ' + @validation_err;

    END

	--DOC REFF Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_doc_ref_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'DOC REFF Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_doc_ref_name,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', DOC REFF Name ' + @validation_err;

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


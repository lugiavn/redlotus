function isvalid = sin_check_valid_data( data )
%SIN_CHECK_VALID_DATA Check data >= 0 and < inf
%   Detailed explanation goes here

    check = ~((data >= 0) & (data < inf));
    isvalid = sum(sum(check)) == 0;

end

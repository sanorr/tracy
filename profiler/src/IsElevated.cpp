#include "IsElevated.hpp"

#ifdef _WIN32

#include <windows.h>

bool IsElevated()
{
    HANDLE token;
    if( OpenProcessToken( GetCurrentProcess(), TOKEN_QUERY, &token ) == 0 ) return false;

    TOKEN_ELEVATION te;
    DWORD sz;
    if( GetTokenInformation( token, TokenElevation, &te, sizeof( te ), &sz ) == 0 )
    {
        CloseHandle( token );
        return false;
    }

    bool ret = te.TokenIsElevated;
    CloseHandle( token );
    return ret;
}

#else

bool IsElevated()
{
    return false;
}

#endif

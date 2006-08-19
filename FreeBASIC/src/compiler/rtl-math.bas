''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2006 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


'' intrinsic runtime lib math functions (FIX, ACOS, LOG, ...)
''
'' chng: oct/2004 written [v1ctor]


#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\ast.bi"
#include once "inc\rtl.bi"

	dim shared as FB_RTL_PROCDEF funcdata( 0 to 19 ) = _
	{ _
		/' fb_LongintDIV ( byval x as longint, byval y as longint ) as longint '/ _
		( _
			@FB_RTL_LONGINTDIV, NULL, _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
	 		{ _
	 			( _
					FB_DATATYPE_LONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			), _
	 			( _
					FB_DATATYPE_LONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_ULongintDIV ( byval x as ulongint, byval y as ulongint ) as ulongint '/ _
		( _
			@FB_RTL_ULONGINTDIV, NULL, _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
	 		{ _
	 			( _
					FB_DATATYPE_ULONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			), _
	 			( _
					FB_DATATYPE_ULONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_LongintMOD ( byval x as longint, byval y as longint ) as longint '/ _
		( _
			@FB_RTL_LONGINTMOD, NULL, _
			FB_DATATYPE_LONGINT, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
	 		{ _
	 			( _
					FB_DATATYPE_LONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			), _
	 			( _
					FB_DATATYPE_LONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_ULongintMOD ( byval x as ulongint, byval y as ulongint ) as ulongint '/ _
		( _
			@FB_RTL_ULONGINTMOD, NULL, _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
	 		{ _
	 			( _
					FB_DATATYPE_ULONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			), _
	 			( _
					FB_DATATYPE_ULONGINT, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_Dbl2ULongint ( byval x as double ) as ulongint '/ _
		( _
			@FB_RTL_DBL2ULONGINT, NULL, _
			FB_DATATYPE_ULONGINT, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_Pow CDECL ( byval x as double, byval y as double ) as double '/ _
		( _
			@FB_RTL_POW, @"pow", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			2, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			), _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_SGNSingle ( byval x as single ) as integer '/ _
		( _
			@FB_RTL_SGNSINGLE, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_SINGLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_SGNDouble ( byval x as double ) as integer '/ _
		( _
			@FB_RTL_SGNDOUBLE, NULL, _
			FB_DATATYPE_INTEGER, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_FIXSingle ( byval x as single ) as single '/ _
		( _
			@FB_RTL_FIXSINGLE, NULL, _
			FB_DATATYPE_SINGLE, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
			FB_DATATYPE_SINGLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' fb_FIXDouble ( byval x as double ) as double '/ _
		( _
			@FB_RTL_FIXDOUBLE, NULL, _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' asin CDECL ( byval x as double ) as double '/ _
		( _
			@FB_RTL_ASIN, @"asin", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' acos CDECL ( byval x as double ) as double '/ _
		( _
			@FB_RTL_ACOS, @"acos", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' log CDECL ( byval x as double ) as double '/ _
		( _
			@FB_RTL_LOG, @"log", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' exp CDECL ( byval rad as double ) as double '/ _
		( _
			@"exp", @"exp", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_CDECL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, FALSE _
	 			) _
	 		} _
		), _
		/' randomize ( byval seed as double = -1.0 ) as void '/ _
		( _
			@"randomize", @"fb_Randomize", _
			FB_DATATYPE_VOID, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_DOUBLE, FB_PARAMMODE_BYVAL, TRUE, -1.0 _
	 			) _
	 		} _
		), _
		/' rnd ( byval n as integer ) as double '/ _
		( _
			@"rnd", @"fb_Rnd", _
			FB_DATATYPE_DOUBLE, FB_FUNCMODE_STDCALL, _
			NULL, FB_RTL_OPT_NONE, _
			1, _
	 		{ _
	 			( _
					FB_DATATYPE_INTEGER, FB_PARAMMODE_BYVAL, TRUE, 1 _
	 			) _
	 		} _
	 	), _
	 	/' EOL '/ _
	 	( _
	 		NULL _
	 	) _
	 }


'':::::
sub rtlMathModInit( )

	rtlAddIntrinsicProcs( @funcdata(0) )

end sub

'':::::
sub rtlMathModEnd( )

	'' procs will be deleted when symbEnd is called

end sub

'':::::
function rtlMathPow	_
	( _
		byval xexpr as ASTNODE ptr, _
		byval yexpr as ASTNODE ptr _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc

	function = NULL

	''
    proc = astNewCALL( PROCLOOKUP( POW ) )

    '' byval x as double
    if( astNewARG( proc, xexpr ) = NULL ) then
 		exit function
 	end if

    '' byval y as double
    if( astNewARG( proc, yexpr ) = NULL ) then
 		exit function
 	end if

    ''
    function = proc

end function

'':::::
function rtlMathFSGN _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as FBSYMBOL ptr f

	function = NULL

	''
	if( astGetDataType( expr ) = FB_DATATYPE_SINGLE ) then
		f = PROCLOOKUP( SGNSINGLE )
	else
		f = PROCLOOKUP( SGNDOUBLE )
	end if

    proc = astNewCALL( f )

    '' byval x as single|double
    if( astNewARG( proc, expr ) = NULL ) then
 		exit function
 	end if

    ''
    function = proc

end function

'':::::
function rtlMathTRANS _
	( _
		byval op as integer, _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as FBSYMBOL ptr f

	function = NULL

	''
	select case op
	case AST_OP_ASIN
		f = PROCLOOKUP( ASIN )
	case AST_OP_ACOS
		f = PROCLOOKUP( ACOS )
	case AST_OP_LOG
		f = PROCLOOKUP( LOG )
	end select

    proc = astNewCALL( f )

    '' byval x as double
    if( astNewARG( proc, expr ) = NULL ) then
 		exit function
 	end if

    ''
    function = proc

end function


'':::::
function rtlMathFIX _
	( _
		byval expr as ASTNODE ptr _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as FBSYMBOL ptr f

	function = NULL

	''
	select case astGetDataClass( expr )
	case FB_DATACLASS_FPOINT
		if( astGetDataType( expr ) = FB_DATATYPE_SINGLE ) then
			f = PROCLOOKUP( FIXSINGLE )
		else
			f = PROCLOOKUP( FIXDOUBLE )
		end if

	case FB_DATACLASS_INTEGER
		return expr

	case else
		exit function
	end select

    proc = astNewCALL( f )

    '' byval x as single|double
    if( astNewARG( proc, expr ) = NULL ) then
 		exit function
 	end if

    ''
    function = proc

end function

'':::::
function rtlMathLen _
	( _
		byval expr as ASTNODE ptr, _
		byval islen as integer = TRUE _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as integer dtype, lgt
    dim as FBSYMBOL ptr litsym

	function = NULL

	dtype = astGetDataType( expr )

	'' LEN()?
	if( islen ) then
		select case dtype
		'' dyn-len or zstring?
		case FB_DATATYPE_STRING, FB_DATATYPE_CHAR

    		'' literal? evaluate at compile-time..
    		if( dtype = FB_DATATYPE_CHAR ) then
    			litsym = astGetStrLitSymbol( expr )
    			if( litsym <> NULL ) then
    				lgt = symbGetStrLen( litsym ) - 1
    			end if
    		else
    			litsym = NULL
    		end if

    		if( litsym = NULL ) then
    			proc = astNewCALL( PROCLOOKUP( STRLEN ) )

    			'' always calc len before pushing the param
    			lgt = rtlCalcStrLen( expr, dtype )

    			'' str as any
    			if( astNewARG( proc, expr, FB_DATATYPE_STRING ) = NULL ) then
 					exit function
 				end if

    			'' byval strlen as integer
				if( astNewARG( proc, astNewCONSTi( lgt, FB_DATATYPE_INTEGER ), FB_DATATYPE_INTEGER ) = NULL ) then
 					exit function
 				end if

				return proc
			end if

		'' wstring?
		case FB_DATATYPE_WCHAR

    		'' literal? evaluate at compile-time..
    		litsym = astGetStrLitSymbol( expr )
    		if( litsym <> NULL ) then
    			lgt = symbGetWstrLen( litsym ) - 1

    		else
    			proc = astNewCALL( PROCLOOKUP( WSTRLEN ) )

    			'' byval str as wchar ptr
    			if( astNewARG( proc, expr ) = NULL ) then
 					exit function
 				end if

 				return proc
 			end if

		'' anything else..
		case else
			lgt = rtlCalcExprLen( expr, FALSE )

			'' handle fix-len strings (evaluated at compile-time)
			if( dtype = FB_DATATYPE_FIXSTR ) then
				if( lgt > 0 ) then
					lgt -= 1						'' less the null-term
				end if
			end if

		end select

	'' SIZEOF()
	else
		lgt = rtlCalcExprLen( expr, FALSE )

		'' wstring? multiply by sizeof(wchar) to get the
		'' number of bytes, not of chars
		if( dtype = FB_DATATYPE_WCHAR ) then
			lgt *= symbGetDataSize( FB_DATATYPE_WCHAR )
		end if

	end if

	''
	astDelTree( expr )

	function = astNewCONSTi( lgt, FB_DATATYPE_INTEGER )

end function

'':::::
function rtlMathLongintDIV _
	( _
		byval dtype as integer, _
		byval lexpr as ASTNODE ptr, _
		byval ldtype as integer, _
		byval rexpr as ASTNODE ptr, _
		byval rdtype as integer _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as FBSYMBOL ptr f

	function = NULL

	if( dtype = FB_DATATYPE_LONGINT ) then
		f = PROCLOOKUP( LONGINTDIV )
	else
		f = PROCLOOKUP( ULONGINTDIV )
	end if

    proc = astNewCALL( f )

    ''
    if( astNewARG( proc, lexpr, ldtype ) = NULL ) then
    	exit function
    end if

    if( astNewARG( proc, rexpr, rdtype ) = NULL ) then
    	exit function
    end if

    function = proc

end function

'':::::
function rtlMathLongintMOD _
	( _
		byval dtype as integer, _
		byval lexpr as ASTNODE ptr, _
		byval ldtype as integer, _
		byval rexpr as ASTNODE ptr, _
		byval rdtype as integer _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc
    dim as FBSYMBOL ptr f

	function = NULL

	if( dtype = FB_DATATYPE_LONGINT ) then
		f = PROCLOOKUP( LONGINTMOD )
	else
		f = PROCLOOKUP( ULONGINTMOD )
	end if

    proc = astNewCALL( f )

    ''
    if( astNewARG( proc, lexpr, ldtype ) = NULL ) then
    	exit function
    end if

    if( astNewARG( proc, rexpr, rdtype ) = NULL ) then
    	exit function
    end if

    function = proc

end function

'':::::
function rtlMathFp2ULongint _
	( _
		byval expr as ASTNODE ptr, _
		byval dtype as integer _
	) as ASTNODE ptr static

    dim as ASTNODE ptr proc

	function = NULL

    proc = astNewCALL( PROCLOOKUP( DBL2ULONGINT)  )

    ''
    if( astNewARG( proc, expr, dtype ) = NULL ) then
    	exit function
    end if

    function = proc

end function


'' quirk varargs function (VA_FIRST) parsing
''
'' chng: sep/2004 written [v1ctor]
'' chng: oct/2018 added   [jeffm], cVALIST*

#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "ast.bi"

private function hGetVarArgProcParam _
	( _
		byref proc as FBSYMBOL ptr, _
		byref vararg_param as FBSYMBOL ptr, _
		byref vararg_sym as FBSYMBOL ptr _
	) as integer

	function = FALSE

	if( fbIsModLevel( ) ) then
		exit function
	end if

	proc = parser.currproc
	if( symbGetProcMode( proc ) <> FB_FUNCMODE_CDECL ) then
		exit function
	end if

	vararg_param = symbGetProcTailParam( proc )
	if( vararg_param = NULL ) then
		exit function
	end if
	if( symbGetParamMode( vararg_param ) <> FB_PARAMMODE_VARARG ) then
		exit function
	end if
	vararg_param = vararg_param->prev
	if( vararg_param = NULL ) then
		exit function
	end if

	vararg_sym = symbGetParamVar( vararg_param )
	if( vararg_sym = NULL ) then
		exit function
	end if

	function = TRUE

end function

private function hCheckForValistCompatibleType _
	( _
		byval expr as ASTNODE ptr, _
		byval allow_const as integer _
	) as integer

	'' no expression?
	if( expr = NULL ) then
		errReport( FB_ERRMSG_EXPECTEDIDENTIFIER )
		return FALSE
	end if

	'' const?
	if( astIsConstant( expr ) and (allow_const = FALSE) ) then
		errReport( FB_ERRMSG_CONSTANTCANTBECHANGED )
		return FALSE
	end if

	'' side effects? don't allow
	if( astHasSideFx( expr ) ) then
		'' !!! TODO !!!
		'' better error message
		errReport( FB_ERRMSG_EXPECTEDPOINTER, TRUE )
		return FALSE
	end if

	'' cva_list compatible type?
	select case typeGetDtOnly( astGetDataType( expr ) )
	case FB_DATATYPE_VOID, FB_DATATYPE_STRUCT
		'' TODO: maybe can be more selective here
		'' possibly checking target platform and known
		'' compatible types
		return TRUE
	end select

	'' invalid type
	errReport( FB_ERRMSG_INVALIDDATATYPES )
	return FALSE

end function

private function hCheckLastParameterSymbol _
	( _
		byval expr as ASTNODE ptr, _
		byval vararg_param as FBSYMBOL ptr, _
		byval vararg_sym as FBSYMBOL ptr _
	) as ASTNODE ptr

	assert( vararg_sym <> NULL )

	if( expr = NULL ) then
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: use the vararg_sym variable
		return astNewVAR( vararg_sym )
	end if

	select case astGetClass( expr )
	case AST_NODECLASS_VAR
		if( astGetSymbol( expr ) = vararg_sym ) then
			return expr
		end if

	'' string or array?
	case AST_NODECLASS_DEREF, AST_NODECLASS_NIDXARRAY
		if( astGetClass( expr->l ) = AST_NODECLASS_VAR ) then
			if( astGetSymbol( expr->l ) = vararg_sym ) then
				return expr
			end if
		end if

	end select

	errReportEx( FB_ERRMSG_EXPECTEDIDENTIFIER, symbGetName( vararg_param ) )
	'' error recovery: use the vararg variable
	astDelTree( expr )

	return astNewVAR( vararg_sym )

end function

private sub hSolveValistType _
	( _
		byval n as ASTNODE ptr _
	)

	assert( n <> NULL )

	'' solve the special cases before passing the expression on to gcc
	''
	'' if using FB_DATATYPE_VOID, it must be a pointer in fbc to give
	'' it a size, but gcc just expects the expression without any
	'' indirection, because __builtin_va_list is already a pointer
	'' type, so we remove one level of indirection and just pass
	'' the value of the pointer expression.
	''
	'' if using FB_DATATYPE_STRUCT, it must be a struct in fbc to
	'' give it the proper size, but fbc does not support array 
	'' typedefs as in C.  gcc expects a pointer to the struct as 
	'' if it were an array so we need to replace with array or non-array
	'' __builtin_va_list type here and let the backend handle it.

	if( n->l ) then hSolveValistType( n->l )
	if( n->r ) then hSolveValistType( n->r )

	if( typeGetMangleDt( n->dtype ) = FB_DATATYPE_VA_LIST ) then

		select case symbGetValistType( n->dtype, n->subtype )
		case FB_CVA_LIST_POINTER, FB_CVA_LIST_BUILTIN_POINTER
			'' cast( __builtin_va_list, *expr )
			n->dtype = typeJoinDtOnly( typeDeref( n->dtype ) , FB_DATATYPE_VA_LIST )

		case FB_CVA_LIST_BUILTIN_C_STD
			'' va_list[1] gets passed as a pointer
			'' *cast( __builtin_va_list ptr, @expr )
			n = astNewDeref( n, typeAddrOf( typeJoinDtOnly( n->dtype, FB_DATATYPE_VA_LIST ) ), astGetSubType( n ) )

		case else
			'' cast( __builtin_va_list, expr )
			n->dtype = typeJoinDtOnly( n->dtype, FB_DATATYPE_VA_LIST )

		end select

	end if

end sub

'':::::
''cVAFunct =     VA_FIRST ('(' ')')? .
''
function cVAFunct() as ASTNODE ptr
	function = FALSE

	dim as FBSYMBOL ptr vararg_proc = any, vararg_param = any, vararg_sym = any
	if( hGetVarArgProcParam( vararg_proc, vararg_param, vararg_sym ) = FALSE ) then
		exit function
	end if

	'' VA_FIRST
	lexSkipToken( )

	'' ('(' ')')?
	if( hMatch( CHAR_LPRNT ) ) then
		hMatchRPRNT( )
	end if

	'' C backend? va_* not supported
	if( env.clopt.backend = FB_BACKEND_GCC ) then
		errReport( FB_ERRMSG_STMTUNSUPPORTEDINGCC, TRUE )

		'' error recovery: fake an expr
		function = astNewCONSTi( 0 )
	else
		'' @param
		var expr = astNewADDROF( astNewVAR( vararg_sym ) )

		'' Cast to ANY PTR to hide that it's based on the parameter
		expr = astNewCONV( typeAddrOf( FB_DATATYPE_VOID ), NULL, expr )

		'' + paramlen( param )
		function = astNewBOP( AST_OP_ADD, expr, astNewCONSTi( symbGetLen( vararg_param ), FB_DATATYPE_UINT ),,AST_OPOPT_NOCOERCION )
	end if
end function

'':::::
''cVALISTFunct =     CVA_ARG ('(' expr ',' datatype ')')?
''
function cVALISTFunct _
	( _
		byval tk as FB_TOKEN _
	) as ASTNODE ptr

	dim as ASTNODE ptr expr
	dim as integer dtype
	dim as FBSYMBOL ptr subtype

	function = NULL

	assert( tk = FB_TK_CVA_ARG )

	'' CVA_ARG
	lexSkipToken( )

	'' '('
	if( hMatch( CHAR_LPRNT ) = FALSE ) then
		errReport( FB_ERRMSG_EXPECTEDLPRNT )
	end if

	'' cva_list variable?
	expr = cVarOrDeref()

	if( hCheckForValistCompatibleType( expr, FALSE ) = FALSE ) then
		'' error recovery: skip until ')' and fake a node
		hSkipUntil( CHAR_RPRNT, TRUE )
		astDelTree( expr )
		return astNewCONSTi( 0 )
	end if

	'' ','
	if( lexGetToken( ) <> CHAR_COMMA ) then
		errReport( FB_ERRMSG_EXPECTEDCOMMA )
	else
		lexSkipToken( )
	end if

	'' datatype?
	if( cSymbolType( dtype, subtype ) = FALSE ) then
		errReport( FB_ERRMSG_EXPECTEDEXPRESSION )
		'' error recovery: skip until ')' and fake a node
		hSkipUntil( CHAR_RPRNT, TRUE )
		astDelTree( expr )
		return astNewCONSTi( 0 )
	end if

	'' ')'
	if( hMatch( CHAR_RPRNT ) = FALSE ) then
		errReport( FB_ERRMSG_EXPECTEDRPRNT )
	end if

	if( symbIsBuiltinVaListType( astGetFullType( expr ), astGetSubtype( expr ) ) ) then
		'' delegate to gcc backend to solve "result = __builtin_va_arg( ap, type )"
		hSolveValistType( expr )
		function = astNewMACRO( AST_OP_VA_ARG, expr, NULL, dtype, subtype )

	else
		'' pointer expression: modify expr variable & return value of expr variable before modification
		'' based on:
		'' #define __va_argsiz(t) (((sizeof(t) + sizeof(int) - 1) / sizeof(int)) * sizeof(int))
		'' #define va_arg(ap, t) (((ap) = (ap) + __va_argsiz(t)), *((t*) (void*) ((ap) - __va_argsiz(t))))

		'' size of parameter on the stack depends on stack alignment
		dim lgt as longint = (symbCalcLen( dtype, subtype ) + env.pointersize - 1 and -env.pointersize)

		'' cptr( any ptr, expr ) + lgt	
		var expr1 = astNewBOP( AST_OP_ADD, astCloneTree( expr ), astNewCONSTi(lgt, FB_DATATYPE_UINT ) )
		
		'' cptr( any ptr, expr ) - lgt
		var expr2 = astNewBOP( AST_OP_SUB, astCloneTree( expr ), astNewCONSTi(lgt, FB_DATATYPE_UINT ) )

		'' return ( expr += lgt: *cptr(dtype ptr, expr - lgt) )
		function = astNewLink( astNewASSIGN( expr, expr1 ), astNewDEREF( expr2, dtype, subtype ), FALSE )

	end if

end function

'':::::
''cVALISTStmt =      CVA_START ('(' expr ',' parameter ')')?
''                 | CVA_END ('(' expr ')')?
''                 | CVA_COPY ('(' expr ',' expr ')')?
''
function cVALISTStmt _
	( _
		byval tk as FB_TOKEN _
	) as integer

	dim as ASTNODE ptr expr1, expr2

	function = FALSE

	dim as FBSYMBOL ptr vararg_proc = any, vararg_param = any, vararg_sym = any

	select case as const tk
	case FB_TK_CVA_START

		if( hGetVarArgProcParam( vararg_proc, vararg_param, vararg_sym ) = FALSE ) then
			exit function
		end if

		'' CVA_START
		lexSkipToken( )

		'' '('
		if( hMatch( CHAR_LPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDLPRNT )
		end if

		'' cva_list variable?
		expr1 = cVarOrDeref( )

		if( hCheckForValistCompatibleType( expr1, FALSE ) = FALSE ) then
			'' error recovery: skip until ')'
			hSkipUntil( CHAR_RPRNT, TRUE )
			astDelTree( expr1 )
			return FALSE
		end if

		'' ','
		if( lexGetToken( ) <> CHAR_COMMA ) then
			errReport( FB_ERRMSG_EXPECTEDCOMMA )
		else
			lexSkipToken( )
		end if

		'' last parameter before var-args?
		expr2 = cVarOrDeref( FB_VAREXPROPT_NOARRAYCHECK )
		expr2 = hCheckLastParameterSymbol( expr2, vararg_param, vararg_sym )

		'' ')'
		if( hMatch( CHAR_RPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDRPRNT )
		end if

		if( symbIsBuiltinValistType( astGetFullType( expr1 ), astGetSubtype( expr1 ) ) ) then
			'' delegate to gcc backend to solve "__builtin_va_start( ap, param )"
			hSolveValistType( expr1 )
			astAdd( astNewMACRO( AST_OP_VA_START, expr1, expr2, FB_DATATYPE_INVALID, NULL ) )

		else
			'' pointer expression: first variable argument
			'' based on:
			'' #define va_start(ap, pN) ((ap) = ((va_list) (&pN) + __va_argsiz(pN)))

			'' @param
			var expr = astNewADDROF( astNewVAR( vararg_sym ) )

			'' Cast to ANY PTR to hide that it's based on the parameter
			'' expr = astNewCONV( typeAddrOf( FB_DATATYPE_VOID ), NULL, expr )

			'' + paramlen( param )
			expr = astNewBOP( AST_OP_ADD, expr, astNewCONSTi( symbGetLen( vararg_param ), FB_DATATYPE_UINT ) )

			'' cptr( any ptr, list ) = first_vararg
			astAdd( astNewASSIGN( expr1, expr ) )

		end if
		function = TRUE

	case FB_TK_CVA_END
		
		'' CVA_END
		lexSkipToken( )

		'' '('
		if( hMatch( CHAR_LPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDLPRNT )
		end if

		'' cva_list variable?
		expr1 = cVarOrDeref()

		if( hCheckForValistCompatibleType( expr1, FALSE ) = FALSE ) then
			'' error recovery: skip until ')'
			hSkipUntil( CHAR_RPRNT, TRUE )
			astDelTree( expr1 )
			return FALSE
		end if

		'' ')'
		if( hMatch( CHAR_RPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDRPRNT )
		end if

		if( symbIsBuiltinValistType( astGetFullType( expr1 ), astGetSubtype( expr1 ) ) ) then
			'' delegate to gcc backend to solve "__builtin_va_end( ap )"
			hSolveValistType( expr1 )
			astAdd( astNewMACRO( AST_OP_VA_END, expr1, NULL, FB_DATATYPE_INVALID, NULL ) )

		else
			'' pointer expression: no-op
			'' based on:
			'' #define va_end(ap)	((void)0)

		end if
		function = TRUE

	case FB_TK_CVA_COPY

		'' CVA_COPY
		lexSkipToken( )

		'' '('
		if( hMatch( CHAR_LPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDLPRNT )
		end if

		'' destination cva_list variable?
		expr1 = cVarOrDeref()

		if( hCheckForValistCompatibleType( expr1, FALSE ) = FALSE ) then
			'' error recovery: skip until ')'
			hSkipUntil( CHAR_RPRNT, TRUE )
			astDelTree( expr1 )
			return FALSE
		end if

		'' ','
		if( lexGetToken( ) <> CHAR_COMMA ) then
			errReport( FB_ERRMSG_EXPECTEDCOMMA )
		else
			lexSkipToken( )
		end if

		'' source cva_list variable?
		expr2 = cVarOrDeref()

		if( hCheckForValistCompatibleType( expr2, TRUE ) = FALSE ) then
			'' error recovery: skip until ')'
			hSkipUntil( CHAR_RPRNT, TRUE )
			astDelTree( expr1 )
			astDelTree( expr2 )
			return FALSE
		end if

		'' ')'
		if( hMatch( CHAR_RPRNT ) = FALSE ) then
			errReport( FB_ERRMSG_EXPECTEDRPRNT )
		end if

		if( symbIsBuiltinValistType( astGetFullType( expr1 ), astGetSubtype( expr1 ) ) ) then
			'' delegate to gcc backend to solve "__builtin_va_copy( dst, src )"
			hSolveValistType( expr1 )
			hSolveValistType( expr2 )
			astAdd( astNewMACRO( AST_OP_VA_COPY, expr1, expr2, FB_DATATYPE_INVALID, NULL ) )

		else
			'' pointer expression: assignment
			'' based on:
			'' #define va_copy(ap, src) ((dest) = (src))

			astAdd( astNewASSIGN( expr1, expr2 ) )

		end if
		function = TRUE

	end select

end function

''  fbdoc - FreeBASIC User's Manual Converter/Generator
''	Copyright (C) 2006, 2007 Jeffery R. Marshall (coder[at]execulink.com)
''  and the FreeBASIC development team.
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


'' CWikiCon
''
'' chng: apr/2006 written [v1ctor]
'' chng: sep/2006 updated [coderJeff]
''       dec/2006 updated [coderJeff] - using classes
''

#include once "CHttp.bi"
#include once "CHttpForm.bi"
#include once "CHttpStream.bi"
#include once "CWikiCon.bi"

namespace fb.fbdoc

	type CWikiConCtx_
		as CHttp ptr		http
		as zstring ptr		url
		as zstring ptr		pagename
		as integer			pageid
	end type

	const wakka_prefix = "?wakka="
	const wakka_loginpage = "UserSettings"
	const wakka_raw = "/raw"
	const wakka_edit = "/edit"
	const wakka_getid = "/getid"
	const wakka_error = "wiki-error"
	const wakka_response = "wiki-response"

	'':::::
	private function build_url _
		( _
			byval ctx as CWikiConCtx ptr, _
			byval page as zstring ptr = NULL, _
			byval method as zstring ptr = NULL _
		) as string

		dim as string url
		
		url = *ctx->url + wakka_prefix
		
		if( page = NULL ) then
			page = ctx->pagename 
		end if
		
		url += *page
		
		if( method <> NULL ) then
			url += *method
		end if
		
		function = url

	end function

	'':::::
	constructor CWikiCon _
		( _
			byval url as zstring ptr _
		)

		ctx = new CWikiConCtx	
  
  		ctx->http = new CHttp
  		ctx->url = allocate( len( *url ) + 1 )
  		*ctx->url = *url
  		
  		ctx->pagename = NULL
  		ctx->pageid = 0
		
	end constructor

	'':::::
	destructor CWikiCon _
		( _
		)
		
		if( ctx = NULL ) then
			exit destructor
		end if
		
		if( ctx->pagename <> NULL ) then
    		deallocate( ctx->pagename )
    		ctx->pagename = NULL
		end if

		if( ctx->url <> NULL ) then
    		deallocate( ctx->url )
    		ctx->url = NULL
		end if
		
		if( ctx->http <> NULL ) then
			delete ctx->http
			ctx->http = NULL
		end if		

		delete ctx

	end destructor

	'':::::
	private function check_iserror _
		( _
			byval body as zstring ptr _
		) as integer
		
		if( len( *body ) = 0 ) then
			return TRUE
		end if

		function = ( instr( 1, *body, "<" + wakka_error + ">" ) > 0 )
		
	end function

	'':::::
	function CWikiCon.Login _
		( _
			byval username as zstring ptr, _
			byval password as zstring ptr _
		) as integer
		
		if( ctx = NULL ) then
			return FALSE
		end if
		
		dim as CHttpForm ptr form
		
		form = new CHttpForm
		if( form = NULL ) then
			return FALSE
		end if
		
		form->Add( "action", "login" )
		form->Add( "wakka", "UserSettings" )
		form->Add( "name", username )
		form->Add( "password", password )
		
		dim as string response = ctx->http->Post( build_url( ctx, wakka_loginpage ), form )
		
		function = ( check_iserror( response ) = FALSE )
		
		delete form

	end function

	'':::::
	private function get_response _
		( _
			byval body as zstring ptr _
		) as string
		
		dim as string res
		dim as integer ps, pe, lgt, i
		
		function = ""
		
		if( len( *body ) = 0 ) then
			exit function
		end if
		
		ps = instr( 1, *body, "<" + wakka_response + ">" )
		if( ps = 0 ) then
			exit function
		end if

		pe = instr( ps, *body, "</" + wakka_response + ">" )
		if( pe = 0 ) then
			exit function
		end if
		
		ps -= 1
		pe -= 1
		
		ps += 1 + len( wakka_response ) + 1
		lgt = ((pe - 1) - ps) + 1
		res = space( lgt )
		i = 0
		do while( i < lgt )
			res[i] = body[ps+i]
			i += 1
		loop
		
		function = res
		
	end function

	'':::::
	private sub remove_http_headers( byref body as string )

		dim as integer i = 1, n = len(body)
		const whitespace = chr(9,10,13,32)
		const crlfcrlf = chr(13,10,13,10)

		while( i <= n )
			if instr(whitespace,mid(body, i, 1)) = 0 then
				exit while
			end if
			i += 1
		wend

		if ( i < n ) then
			if( mid(body, i, 5) = "HTTP/" ) then
				i = instr( i, body, crlfcrlf )
				if( i > 0 ) then
					body = mid( body, i + 4 )
				end if

			end if
		end if

	end sub

	'':::::
	private sub remove_trailing_whitespace( byref body as string )

		dim as integer i, n = len(body)
		const whitespace = chr(9,10,13,32)

		i = n
		while( i >= 1 )
			if instr(whitespace,mid(body, i, 1)) = 0 then
				exit while
			end if
			i -= 1
		wend

		if( i < n ) then
			if( i > 0 ) then
				body = left( body, i )
			else
				body = chr(10)
			end if
		end if

	end sub

	'':::::
	private function get_pageid _
		( _
			byval ctx as CWikiConCtx ptr _
		) as integer
		
		dim as CHttpStream ptr stream
		
		function = -1
		
		stream = new CHttpStream( ctx->http )
		if( stream = NULL ) then
			exit function
		end if
			
		dim as string body, URL
		URL = build_url( ctx, NULL, wakka_getid )
		
		if( stream->Receive( URL, TRUE ) ) then
			body = stream->Read()
		end if

		delete stream
		
		if( check_iserror( body ) = FALSE ) then
			remove_http_headers( body )
			function = valint( get_response( body ) )
		end if
		
	end function

	'':::::
	function CWikiCon.LoadPage _
		( _
			byval page as zstring ptr, _
			byval israw as integer, _
			byval getid as integer, _
			byref body as string _
		) as integer

		function = FALSE
		body = ""
		
		if( ctx = NULL ) then
			exit function
		end if

		ctx->pageid = -1
		ctx->pagename = reallocate( ctx->pagename, len( *page ) + 1 )
		*ctx->pagename = *page
		
		dim as CHttpStream ptr stream
		
		stream = new CHttpStream( ctx->http )
		if( stream = NULL ) then
			exit function
		end if
			
		dim as zstring ptr rawmethod = iif( israw, @wakka_raw, NULL )
		
		dim URL as string
		URL = build_url( ctx, NULL, rawmethod )

		if( stream->Receive( URL, TRUE ) ) then
			body = stream->Read()
			remove_http_headers( body )
''			remove_trailing_whitespace( body )
		end if
		
		delete stream
		
		if( getid ) then
			'if( len( body ) > 0 ) then
				ctx->pageid = get_pageid( ctx )
			'else
			'	ctx->pageid = -1
			'end if
		else
				ctx->pageid = -1
		end if	

		''body += chr( 13, 10 )
		
		function = TRUE
		
	end function

	'':::::
	function CWikiCon.StorePage _
		( _
			byval body_in as zstring ptr, _
			byval note as zstring ptr _
		) as integer
		
		dim body as string

		if( ctx = NULL ) then
			return FALSE
		end if

		if( ctx->pageid <= 0 ) then
			return FALSE
		end if
		
		dim as CHttpForm ptr form
		
		form = new CHttpForm
		if( form = NULL ) then
			return FALSE
		end if

		form->Add( "wakka", *ctx->pagename + wakka_edit )

		form->Add( "previous",  ctx->pageid )

		body = *body_in
''		remove_trailing_whitespace( body )

		form->Add( "body", body, "text/html" )
		if( note ) then
			form->Add( "note", *note )
		else
			form->Add( "note", "updated" )
		end if

		form->Add( "submit", "Store" )

		dim url as string 
		URL = build_url( ctx, NULL, wakka_edit )

		dim as string response = ctx->http->Post( url, form )

		dim as integer res = ( check_iserror( response ) = FALSE )

		if( res ) then 
			ctx->pageid = get_pageid( ctx )
		end if
		
		delete form
		
		function = res
		
	end function

	'':::::
	function CWikiCon.StoreNewPage _
		( _
			byval body as zstring ptr, _
			byval pagename as zstring ptr _
		) as integer

		if( ctx = NULL ) then
			return FALSE
		end if

		dim as CHttpForm ptr form
		
		form = new CHttpForm
		if( form = NULL ) then
			return FALSE
		end if

		form->Add( "wakka", *pagename + wakka_edit )

		form->Add( "previous",  " " )
		form->Add( "body", body, "text/html" )
		form->Add( "note", "new page" )
		form->Add( "submit", "Store" )
		
		dim URL as string
		URL = build_url( ctx, pagename, wakka_edit )
		
		dim as string response = ctx->http->Post( URL, form )
		
		dim as integer res = ( check_iserror( response ) = FALSE )

		if( res ) then 
			ctx->pageid = get_pageid( ctx )
		end if
		
		delete form
		
		function = res
		
	end function

	'':::::
	function CWikiCon.GetPageID _
		( _
		) as integer

		if( ctx = NULL ) then
			return 0
		end if

		return ctx->pageid

	end function

end namespace
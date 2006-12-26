''
'' FreeBASIC gfx library constants
''
#ifndef __fbgfx_bi__
#define __fbgfx_bi__

#inclib "fbgfx"
#ifdef __FB_WIN32__
	#inclib "gdi32"
	#inclib "winmm"
	#inclib "user32"
#elseif defined(__FB_LINUX__)
	#libpath "/usr/X11R6/lib"
	#inclib "X11"
	#inclib "Xext"
	#inclib "Xpm"
	#inclib "Xrandr"
	#inclib "Xrender"
	#inclib "pthread"
#endif


namespace FB


	'' Flags accepted by Screen and ScreenRes
	''
	'' Usage examples:
	''	SCREEN 14, 16,, GFX_FULLSCREEN
	''	SCREEN 18, 32,, GFX_OPENGL OR GFX_STENCIL_BUFFER
	''
	const as integer GFX_NULL 					= -1		, _
					 GFX_WINDOWED				= &h00		, _
					 GFX_FULLSCREEN				= &h01		, _
					 GFX_OPENGL					= &h02		, _
					 GFX_NO_SWITCH				= &h04		, _
					 GFX_NO_FRAME				= &h08		, _
					 GFX_SHAPED_WINDOW			= &h10		, _
					 GFX_ALWAYS_ON_TOP			= &h20		, _
					 GFX_ALPHA_PRIMITIVES		= &h40
	'' OpenGL options
	const as integer GFX_STENCIL_BUFFER			= &h10000	, _
					 GFX_ACCUMULATION_BUFFER	= &h20000	, _
					 GFX_MULTISAMPLE			= &h40000


	'' Constants accepted by ScreenControl
	''
	'' Getters:
	const as integer GET_WINDOW_POS				= 0		, _
					 GET_WINDOW_TITLE			= 1		, _
					 GET_WINDOW_HANDLE			= 2		, _
					 GET_DESKTOP_SIZE			= 3		, _
					 GET_SCREEN_SIZE			= 4		, _
					 GET_SCREEN_DEPTH			= 5		, _
					 GET_SCREEN_BPP				= 6		, _
					 GET_SCREEN_PITCH			= 7		, _
					 GET_SCREEN_REFRESH			= 8		, _
					 GET_DRIVER_NAME			= 9		, _
					 GET_TRANSPARENT_COLOR		= 10	, _
					 GET_VIEWPORT				= 11	, _
					 GET_PEN_POS				= 12	, _
					 GET_COLOR					= 13	, _
					 GET_ALPHA_PRIMITIVES		= 14	, _
					 GET_GL_EXTENSIONS			= 15
	'' Setters:
	const as integer SET_WINDOW_POS				= 100	, _
					 SET_WINDOW_TITLE			= 101	, _
					 SET_PEN_POS				= 102	, _
					 SET_DRIVER_NAME			= 103	, _
					 SET_ALPHA_PRIMITIVES		= 104


	'' Color values for transparency
	''
	const as integer MASK_COLOR_INDEX			= 0, _
					 MASK_COLOR					= &hFF00FF


	'' Event type IDs
	''
	const as integer EVENT_KEY_PRESS			= 1		, _
					 EVENT_KEY_RELEASE			= 2		, _
					 EVENT_KEY_REPEAT			= 3		, _
					 EVENT_MOUSE_MOVE			= 4		, _
					 EVENT_MOUSE_BUTTON_PRESS	= 5		, _
					 EVENT_MOUSE_BUTTON_RELEASE	= 6		, _
					 EVENT_MOUSE_DOUBLE_CLICK	= 7		, _
					 EVENT_MOUSE_WHEEL			= 8		, _
					 EVENT_MOUSE_ENTER			= 9		, _
					 EVENT_MOUSE_EXIT			= 10	, _
					 EVENT_WINDOW_GOT_FOCUS		= 11	, _
					 EVENT_WINDOW_LOST_FOCUS	= 12	, _
					 EVENT_WINDOW_CLOSE			= 13


	'' Event structure, to be used with ScreenEvent
	''
	type EVENT field = 1
		type as integer
		union
			type
				scancode as integer
				ascii as integer
			end type
			type
				x as integer
				y as integer
				dx as integer
				dy as integer
			end type
			button as integer
			z as integer
		end union
	end type


	'' Image buffer header, old style
	''
	type _OLD_HEADER field = 1
		bpp : 3 as ushort
		width : 13 as ushort
		height as ushort
	end type


	'' Image buffer header, new style (incorporates old header)
	''
	type IMAGE field = 1
		union
			old as _OLD_HEADER
			type as uinteger
		end union
		bpp as integer
		width as uinteger
		height as uinteger
		pitch as uinteger
		_reserved(1 to 12) as ubyte
		
'		'' properties
'		declare property pixels() as ubyte ptr
	end type
	
	'' This is a trick to obtain a pointer to the pixels data area
	''
'	property IMAGE.pixels() as ubyte ptr
'		return cast(ubyte ptr, @this) + sizeof(IMAGE)
'	end property
	
	type PUT_HEADER as IMAGE
	

	'' Constant identifying new style headers
	'' (image.type must be equal to this value in new style headers)
	''
	const as integer PUT_HEADER_NEW				= &h7


	'' Mouse button constants to be used with GETMOUSE
	''
	const as integer BUTTON_LEFT				= &h1	, _
					 BUTTON_RIGHT				= &h2	, _
					 BUTTON_MIDDLE				= &h4


	'' Keyboard scancodes returned by MULTIKEY
	''
	enum
        SC_ESCAPE     = &h01
        SC_1
        SC_2
        SC_3
        SC_4
        SC_5
        SC_6
        SC_7
        SC_8
        SC_9
        SC_0
        SC_MINUS
        SC_EQUALS
        SC_BACKSPACE
        SC_TAB
        SC_Q
        SC_W
        SC_E
        SC_R
        SC_T
        SC_Y
        SC_U
        SC_I
        SC_O
        SC_P
        SC_LEFTBRACKET
        SC_RIGHTBRACKET
        SC_ENTER
        SC_CONTROL
        SC_A
        SC_S
        SC_D
        SC_F
        SC_G
        SC_H
        SC_J
        SC_K
        SC_L
        SC_SEMICOLON
        SC_QUOTE
        SC_TILDE
        SC_LSHIFT
        SC_BACKSLASH
        SC_Z
        SC_X
        SC_C
        SC_V
        SC_B
        SC_N
        SC_M
        SC_COMMA
        SC_PERIOD
        SC_SLASH
        SC_RSHIFT
        SC_MULTIPLY
        SC_ALT
        SC_SPACE
        SC_CAPSLOCK
        SC_F1
        SC_F2
        SC_F3
        SC_F4
        SC_F5
        SC_F6
        SC_F7
        SC_F8
        SC_F9
        SC_F10
        SC_NUMLOCK
        SC_SCROLLLOCK
        SC_HOME
        SC_UP         
        SC_PAGEUP
        SC_LEFT       = &h4B
        SC_RIGHT      = &h4D
        SC_PLUS
        SC_END
        SC_DOWN
        SC_PAGEDOWN
        SC_INSERT
        SC_DELETE
        SC_F11        = &h57
        SC_F12
        SC_LWIN       = &h7D
        SC_RWIN
        SC_MENU
    end enum

end namespace

#endif

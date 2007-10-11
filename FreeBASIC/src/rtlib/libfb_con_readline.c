/*
 *  libfb - FreeBASIC's runtime library
 *	Copyright (C) 2004-2007 The FreeBASIC development team.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  As a special exception, the copyright holders of this library give
 *  you permission to link this library with independent modules to
 *  produce an executable, regardless of the license terms of these
 *  independent modules, and to copy and distribute the resulting
 *  executable under terms of your choice, provided that you also meet,
 *  for each linked independent module, the terms and conditions of the
 *  license of that module. An independent module is a module which is
 *  not derived from or based on this library. If you modify this library,
 *  you may extend this exception to your version of the library, but
 *  you are not obligated to do so. If you do not wish to do so, delete
 *  this exception statement from your version.
 */

/*
 *	con_readline - comfortable INPUT function
 *
 * chng: sep/2005 written [mjs]
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fb.h"

static void DoAdjust
	(
		int *x, int *y,
		int dx, int dy,
		int cols, int rows
	)
{
    DBG_ASSERT( x!=NULL && y!=NULL );

    *x -= 1;
    *y -= 1;

    *x += dx;
    if( *x < 0 ) {
        *x = -*x + cols;
        *y -= *x / cols;
        *x = cols - (*x % cols);
    }
    *y += *x / cols;
    *x %= cols;
    *y += dy;

    *x += 1;
    *y += 1;
}

static void DoMove
	(
		int *x, int *y,
		int dx, int dy,
		int cols, int rows
	)
{
    DoAdjust( x, y, dx, dy, cols, rows );
    if( *y==(rows+1) && *x==1 ) {
        fb_Locate( rows, cols, -1, 0, 0 );
        fb_PrintBufferEx( FB_NEWLINE, sizeof(FB_NEWLINE)-1, 0 );
    } else {
        fb_Locate( *y, *x, -1, 0, 0 );
    }
}

void fb_ConReadLineEx
	(
		FBSTRING *dst,
		int soft_cursor
	)
{
    int current_x, current_y;
    int cols, rows;
    size_t pos, len, tmp_buffer_len = 0;
    int cursor_visible;
    int k;
    char ch, tmp_buffer[12];

    fb_GetSize(&cols, &rows);

    cursor_visible = (fb_Locate( 0, 0, -1, 0, 0 ) & 0x10000) != 0;
    fb_Locate( 0, 0, FALSE, 0, 0 );

    pos = len = FB_STRSIZE(dst);
    fb_PrintBufferEx( dst->data, len, 0 );

    /* Ensure that the cursor is visible during INPUT */
    fb_Locate( 0, 0, (soft_cursor == FALSE), 0, 0 );

    do {
        size_t delete_char_count = 0, add_char = FALSE;
        FBSTRING *sTmp;

        fb_GetXY(&current_x, &current_y);

		if( soft_cursor )
		{
			fb_PrintFixString( 0, "\377", 0 );
			fb_Locate( current_y, current_x, FALSE, 0, 0 );
        }

        while( fb_KeyHit( ) == 0 )
        {
          	fb_Delay( 25 );				/* release time slice */
        }

        sTmp = fb_Inkey( );
        if( sTmp->data != NULL )
        {
        	if( FB_STRSIZE(sTmp) == 2 )
        	{
            	k = FB_MAKE_EXT_KEY(sTmp->data[1]);
            	ch = 0;
        	}
        	else
        	{
            	k = FB_MAKE_KEY(ch = sTmp->data[0]);
        	}

        	fb_hStrDelTemp( sTmp );
        }
        else
        {
        	k = 0;
        	continue;
        }

		if( soft_cursor )
		{
			char mask[2] = { ((dst->data != NULL) && (pos < len)? dst->data[pos]: ' '), '\0' };
			fb_PrintFixString( 0, mask, 0 );
			fb_Locate( current_y, current_x, FALSE, 0, 0 );
		}

        switch (k) {
        case 8:
            /* DEL */
			if (pos!=0) {
                DoMove( &current_x, &current_y, -1, 0, cols, rows );
                --pos;
                delete_char_count = 1;
            }
            break;
        case 9:
            /* TAB */
            tmp_buffer_len = ((pos + 8) / 8 * 8) - pos;
            memset(tmp_buffer, 32, tmp_buffer_len);
            add_char = TRUE;
            break;
        case 27:
            /* ESC */
            DoMove( &current_x, &current_y, -pos, 0, cols, rows );
            pos = 0;
            delete_char_count = len;
            break;
        case FB_MAKE_EXT_KEY(0x53):
            /* CLeaR */
            if( len!=pos ) {
                delete_char_count = 1;
            } else {
                fb_Beep();
            }
            break;
        case FB_MAKE_EXT_KEY(0x4B):
            /* Cursor LEFT */
            if( pos != 0 ) {
                DoMove( &current_x, &current_y, -1, 0, cols, rows );
                --pos;
            }
            break;
        case FB_MAKE_EXT_KEY(0x4D):
            /* Cursor RIGHT */
            if( pos != len ) {
                DoMove( &current_x, &current_y, 1, 0, cols, rows );
                ++pos;
            }
            break;
        case FB_MAKE_EXT_KEY(0x47):
            /* HOME */
            DoMove( &current_x, &current_y, -pos, 0, cols, rows );
            pos = 0;
            break;
        case FB_MAKE_EXT_KEY(0x4F):
            /* END */
            DoMove( &current_x, &current_y, len-pos, 0, cols, rows );
            pos = len;
            break;
        case FB_MAKE_EXT_KEY(0x48):
            /* Cursor UP */
            if( pos >= cols) {
                DoMove( &current_x, &current_y, -cols, 0, cols, rows );
                pos -= cols;
            }
            break;
        case FB_MAKE_EXT_KEY(0x50):
            /* Cursor DOWN */
            if( ( pos + cols ) <= len ) {
                DoMove( &current_x, &current_y, cols, 0, cols, rows );
                pos += cols;
            }
            break;
        default:
            if( k>=32 && k<=255 ) {
                tmp_buffer[0] = (char) k;
                tmp_buffer_len = 1;
                add_char = TRUE;
                /* DoMove( &current_x, &current_y, 1, 0, cols ); */
            }
            break;
        }

        if( delete_char_count!=0 || add_char ) {
			/* Turn off the cursor during output (speed-up) */
            fb_Locate( 0, 0, FALSE, 0, 0 );
        }

        if( delete_char_count ) {
            FBSTRING *str_fill;
            FBSTRING *str_tmp1 = fb_StrAllocTempDescV( dst );
            FBSTRING *str_tmp2 = fb_StrAllocTempDescV( dst );
            FBSTRING *str_left = fb_StrMid( str_tmp1, 1, pos );
            FBSTRING *str_right = fb_StrMid( str_tmp2,
                                             pos + 1 + delete_char_count,
                                             len - pos - delete_char_count);
            fb_StrAssign( dst, -1, str_left, -1, FALSE );
            fb_StrConcatAssign( dst, -1, str_right, -1, FALSE );
            len -= delete_char_count;

            FB_LOCK();

            fb_PrintBufferEx( dst->data + pos, len - pos, 0 );

            /* Overwrite all deleted characters with SPC's */
            str_fill = fb_StrFill1 ( delete_char_count, ' ' );
            fb_PrintBufferEx( str_fill->data, delete_char_count, 0 );
            fb_hStrDelTemp( str_fill );

            fb_Locate( current_y, current_x, -1, 0, 0 );

            FB_UNLOCK();
        }

        if( add_char ) {
            tmp_buffer[tmp_buffer_len] = 0;
        }

        if( add_char ) {
            int old_x = current_x, old_y = current_y;
            FBSTRING *str_add = fb_StrAllocTempDescF( tmp_buffer, tmp_buffer_len + 1 );
            FBSTRING *str_tmp1 = fb_StrAllocTempDescV( dst );
            FBSTRING *str_tmp2 = fb_StrAllocTempDescV( dst );
            FBSTRING *str_left = fb_StrMid( str_tmp1, 1, pos );
            FBSTRING *str_right = fb_StrMid( str_tmp2, pos + 1, len - pos);
            fb_StrAssign( dst, -1, str_left, -1, FALSE );
            fb_StrConcatAssign( dst, -1, str_add, -1, FALSE );
            fb_StrConcatAssign( dst, -1, str_right, -1, FALSE );
            len += tmp_buffer_len;

            FB_LOCK();

            fb_PrintBufferEx( dst->data + pos, len - pos, 0 );

            fb_GetXY(&current_x, &current_y);

            if( pos==(len-tmp_buffer_len) ) {
                current_x = old_x; current_y = old_y;
                DoMove( &current_x, &current_y, tmp_buffer_len, 0, cols, rows );
            } else {
                int tmp_x_2 = old_x, tmp_y_2 = old_y;
                DoAdjust( &tmp_x_2, &tmp_y_2, len - pos, 0, cols, rows );
                if( tmp_y_2 > (rows+1) || (tmp_y_2==(rows+1) && tmp_x_2>1) ) {
                    DoMove( &current_x, &current_y, -(len - pos - tmp_buffer_len), 0, cols, rows );
                } else {
                    current_x = old_x; current_y = old_y;
                    DoMove( &current_x, &current_y, tmp_buffer_len, 0, cols, rows );
                }
            }
            pos += tmp_buffer_len;

            FB_UNLOCK();
        }

        fb_Locate( 0, 0, (soft_cursor == FALSE), 0, 0 );

	} while (k!='\r' && k!='\n');

    FB_LOCK();

    /* set cursor to end of line */
    fb_GetXY(&current_x, &current_y);
    DoMove( &current_x, &current_y, len - pos, 0, cols, rows );

    /* Restore old cursor visibility */
    fb_Locate( 0, 0, cursor_visible, 0, 0 );

    FB_UNLOCK();
}


FBCALL FBSTRING *fb_ConReadLine
	(
		int soft_cursor
	)
{
    FBSTRING *tmp = fb_hStrAllocTmpDesc();
    if( tmp!=NULL )
        fb_ConReadLineEx( tmp, soft_cursor );
    return tmp;
}

/*
 *  libfb - FreeBASIC's runtime library
 *	Copyright (C) 2004-2005 Andre V. T. Vicentini (av1ctor@yahoo.com.br) and others.
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
 */

/*
 * drv_intl.c -- helper functions for internationalization support
 *
 * chng: aug/2005 written [mjs]
 *
 */

#include <stddef.h>
#include <assert.h>
#include "fbext_dos.h"

int fb_hIntlGetInfo( DOS_COUNTRY_INFO_GENERAL *pInfo )
{
    int result = FALSE;
    int arg_seg, arg_sel;
    __dpmi_regs r;

    assert( pInfo!=NULL );
    memset( pInfo, 0, sizeof(DOS_COUNTRY_INFO_GENERAL) );

    pInfo->info_id = 0x01;
    pInfo->size_data = sizeof(DOS_COUNTRY_INFO_GENERAL) - 3;

    arg_seg = __dpmi_allocate_dos_memory( (sizeof(DOS_COUNTRY_INFO_GENERAL) + 15) >> 4,
                                          &arg_sel );
    if( arg_seg==0 )
        return FALSE;

    r.x.ax = 0x6501;
    r.x.bx = 0xFFFF;
    r.x.dx = 0xFFFF;
    r.x.es = arg_seg;
    r.x.di = 0x0000;
    r.x.cx = sizeof(DOS_COUNTRY_INFO_GENERAL);

    if( __dpmi_int( 0x21, &r )==0 ) {
        if( (r.x.flags & 0x01)==0 ) {
            movedata( arg_sel, 0,
                      _my_ds(), (unsigned) pInfo,
                      sizeof(DOS_COUNTRY_INFO_GENERAL) );
            result = TRUE;
        }
    }

    __dpmi_free_dos_memory( arg_sel );

    return result;
}

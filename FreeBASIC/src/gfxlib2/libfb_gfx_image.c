/*
 *  libgfx2 - FreeBASIC's alternative gfx library
 *	Copyright (C) 2005 Angelo Mottola (a.mottola@libero.it)
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
 * image.c -- image create/destroy functions
 *
 * chng: jan/2005 written [lillo]
 *
 */

#include "fb_gfx.h"


/*:::::*/
FBCALL void *fb_GfxImageCreate(int width, int height, unsigned int color)
{
	void *image;
	PUT_HEADER *header;
	int size, pitch;
	
	if ((!fb_mode) || (width <= 0) || (height <= 0))
		return NULL;

	if (color == DEFAULT_COLOR) {
		if (fb_mode->bpp == 1)
			color = 0;
		else
			color = fb_hFixColor(MASK_COLOR_32 | MASK_A_32);
	}
	else
		color = fb_hFixColor(color);
	pitch = ((width * fb_mode->bpp) + 0xF) & ~0xF;
	size = pitch * height;
	
	image = malloc(size + sizeof(PUT_HEADER));
	header = (PUT_HEADER *)image;
	header->type = PUT_HEADER_NEW;
	header->bpp = fb_mode->bpp;
	header->width = width;
	header->height = height;
	header->pitch = pitch;
	fb_hMemSet(header->_reserved, 0, sizeof(header->_reserved));
	fb_hPixelSet(image + sizeof(PUT_HEADER), color, (pitch / header->bpp) * height);
	
	return image;
}


/*:::::*/
FBCALL void fb_GfxImageDestroy(void *image)
{
	free(image);
}

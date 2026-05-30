/*
	Copyright 2012 bitHeads inc.

	This file is part of the BaboViolent 2 source code.

	The BaboViolent 2 source code is free software: you can redistribute it and/or 
	modify it under the terms of the GNU General Public License as published by the 
	Free Software Foundation, either version 3 of the License, or (at your option) 
	any later version.

	The BaboViolent 2 source code is distributed in the hope that it will be useful, 
	but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with the 
	BaboViolent 2 source code. If not, see http://www.gnu.org/licenses/.
*/

#ifndef DEDICATED_SERVER
#if defined(_PRO_)
#include "screengrab.h"
#include "Zeven.h"
#include "GameVar.h"
#include "Game.h"
#include "Player.h"
#include "Scene.h"
#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#ifndef GL_BGRA_EXT
#define GL_BGRA_EXT 0x80E1
#endif
#include <cstdint>
#include <ctime>
#include <cstdio>


extern Scene* scene;

static void bmp_write_le16(FILE *f, std::uint16_t v)
{
	unsigned char b[2] = { (unsigned char)(v & 0xff), (unsigned char)(v >> 8) };
	std::fwrite(b, 1, 2, f);
}

static void bmp_write_le32(FILE *f, std::uint32_t v)
{
	unsigned char b[4] = {
		(unsigned char)(v & 0xff),
		(unsigned char)((v >> 8) & 0xff),
		(unsigned char)((v >> 16) & 0xff),
		(unsigned char)((v >> 24) & 0xff)
	};
	std::fwrite(b, 1, 4, f);
}

// Portable 32-bit BGRA BMP (matches glReadPixels GL_BGRA_EXT layout).
void SaveBitmapToFile(unsigned char *pBitmapBits, int lWidth, int lHeight, int wBitsPerPixel, const char *lpszFileName)
{
	if (!pBitmapBits || !lpszFileName || wBitsPerPixel != 32 || lWidth <= 0 || lHeight <= 0)
		return;

	const std::uint32_t rowBytes = (std::uint32_t)lWidth * 4u;
	const std::uint32_t imageSize = rowBytes * (std::uint32_t)lHeight;
	const std::uint32_t infoHeaderSize = 40;
	const std::uint32_t fileHeaderSize = 14;
	const std::uint32_t offBits = fileHeaderSize + infoHeaderSize;

	FILE *hFile = std::fopen(lpszFileName, "wb");
	if (!hFile)
		return;

	std::fputc('B', hFile);
	std::fputc('M', hFile);
	bmp_write_le32(hFile, offBits + imageSize);
	bmp_write_le16(hFile, 0);
	bmp_write_le16(hFile, 0);
	bmp_write_le32(hFile, offBits);

	bmp_write_le32(hFile, infoHeaderSize);
	bmp_write_le32(hFile, (std::uint32_t)lWidth);
	bmp_write_le32(hFile, (std::uint32_t)lHeight);
	bmp_write_le16(hFile, 1);
	bmp_write_le16(hFile, 32);
	bmp_write_le32(hFile, 0);
	bmp_write_le32(hFile, imageSize);
	bmp_write_le32(hFile, 0);
	bmp_write_le32(hFile, 0);
	bmp_write_le32(hFile, 0);
	bmp_write_le32(hFile, 0);

	std::fwrite(pBitmapBits, 1, imageSize, hFile);
	std::fclose(hFile);
}

bool SaveScreenGrabAuto() 
{
   char path[512];
   time_t time;
   ::time(&time);
   sprintf(path, "SS_%d.bmp", time);
   return SaveScreenGrab(path);
}

bool SaveStatsAuto()
{
   char path[512];
   time_t time;
   ::time(&time);
   sprintf(path, "SS_%d.bmp", time);
   SaveScreenGrab(path);
   sprintf(path, "SS_%d.txt", time);

  FILE * pFile;
  pFile = fopen (path,"w");
  if (pFile!=NULL)
  {
/*
	CString mapName;

	// Le type de jeu et les scores
	int gameType;
   int spawnType;
   int subGameType;
	int blueScore;
	int redScore;
	int blueWin;
	int redWin;
   */
    Game* pGame = scene->client->game;


    fputs (pGame->mapName.s,pFile);
    fprintf(pFile, "\nBlue:%d\nRed:%d\n", pGame->blueScore, pGame->redScore);
   
	 for (int i=0;i<MAX_PLAYER;++i)
	 {
       if (pGame->players[i])
		 {         
       Player* pPlayer = pGame->players[i];       
       fprintf(pFile, "PlayerName:%s\n", textColorLess(pPlayer->name).s);       
       fprintf(pFile, "PlayerId:%d\nTeamId:%d\n", pPlayer->playerID, pPlayer->teamID);              
       fprintf(pFile, "Kills:%d\n", pPlayer->kills);
       fprintf(pFile, "Deaths:%d\n", pPlayer->deaths);
       fprintf(pFile, "Damage:%f\n", pPlayer->dmg);
       fprintf(pFile, "FlagAttempts:%d\n", pPlayer->flagAttempts);
       fprintf(pFile, "Returns:%d\n", pPlayer->returns);
       fprintf(pFile, "Score:%d\n", pPlayer->score);       
		 }
	 }
   
    fclose(pFile);
  }
 
   return true;
}



bool SaveScreenGrab(const char* filename) {

	// get some info about the screen size
   CVector2i res = dkwGetResolution();
   
   int sw           =  res.x();
	int sh           =  res.y();
   int bitdepth     =  32;
   GLenum   format  =  GL_BGRA_EXT;
   int bpp          =  4;
	//int bitdepth     =  gameVar.r_bitdepth;
	//GLenum   format  =  (bitdepth==32) ? GL_BGRA_EXT : GL_BGR_EXT;
   //int bpp          =  (bitdepth==32) ? 4 : 3;

	// allocate memory to store image data
	unsigned char* pdata = new unsigned char[sw*sh*bpp];
#ifndef _DX_
	// read from front buffer
	glReadBuffer(GL_FRONT);

	// read pixel data
	glReadPixels(0,0,sw,sh,format,GL_UNSIGNED_BYTE,pdata);

	// write data as a tga file
   SaveBitmapToFile(pdata,sw,sh,bitdepth,filename);
#endif

	// clean up
	delete [] pdata;

	// done
	return true;
}

#endif
#endif

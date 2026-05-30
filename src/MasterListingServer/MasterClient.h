#ifndef _MASTERCLIENT_H_
#define _MASTERCLIENT_H_

#ifdef WIN32
#include <winsock2.h>
#else
#include "LinuxHeader.h"
#endif

#include "cMSstruct.h"

// Per-connection node for the master server (distinct from babonet class cClient).
class MasterClient
{
public:
	MasterClient *Next;
	MasterClient *Previous;
	unsigned long BabonetID;
	char IP[40];
	int nbGames;
	int CurrentGame;
	stBV2row CurrentGames[100];
	bool isServer;
	struct timeval Timeout;

	MasterClient(unsigned long baboNetID, char *ip);
	int Update(float elapsed);
};

#endif

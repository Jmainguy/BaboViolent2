#include "MasterClient.h"
#include <string.h>

MasterClient::MasterClient(unsigned long baboNetID, char *ip)
	: Next(0)
	, Previous(0)
	, BabonetID(baboNetID)
	, nbGames(0)
	, CurrentGame(0)
	, isServer(false)
{
	memset(CurrentGames, 0, sizeof(CurrentGames));
	if (ip)
		strncpy(IP, ip, sizeof(IP) - 1);
	else
		IP[0] = '\0';
	IP[sizeof(IP) - 1] = '\0';
	Timeout.tv_sec = 0;
	Timeout.tv_usec = 0;
}

int MasterClient::Update(float elapsed)
{
	(void)elapsed;
	return 0;
}

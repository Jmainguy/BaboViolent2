
#ifndef WIN32
	#include "sys/times.h"

	#define stricmp strcasecmp //helper define
#else
	#include <windows.h>
#endif

#include "cNetManager.h"
#include "dkc.h"
#include <cstdio>


int main()
{
	// When stdout is piped (e.g. | tee), glibc fully buffers it; line-buffer so logs appear live.
	setvbuf(stdout, NULL, _IOLBF, 0);
	setvbuf(stderr, NULL, _IOLBF, 0);

	//creating the net Manager
	cNetManager	NetManager;
	NetManager.Init();


	//main program here
	bool isRunning = true;
	
	dkcInit(30);

	//linux time struct
	#ifndef WIN32
		timespec ts;

		ts.tv_sec = 0;
		ts.tv_nsec = 1000000;
	#endif


	while(isRunning)
	{
		// On va updater notre timer
		int nbFrameElapsed = dkcUpdateTimer();

		// On va chercher notre delay
		float delay = dkcGetElapsedf();
		
		while (nbFrameElapsed)
		{ 
			//let's update our NetManager
			isRunning	=	NetManager.Update(delay);

			nbFrameElapsed--;
		}
		//linux sleep
		#ifndef WIN32
			nanosleep(&ts,0);
			ts.tv_sec = 0;
			ts.tv_nsec = 1000000;
		//windows sleep
		#else
			Sleep(1);
		#endif
		
	}
  
    return 0; 
}

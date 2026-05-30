
#ifndef CTHREAD_H
#define CTHREAD_H


#include <iostream>

#ifndef WIN32
#include <pthread.h>
#endif

#define CTHREAD_PRIORITY_VERY_LOW 0
#define CTHREAD_PRIORITY_LOW 1
#define CTHREAD_PRIORITY_NORMAL 2
#define CTHREAD_PRIORITY_HIGH 3
#define CTHREAD_PRIORITY_VERY_HIGH 4

#ifdef WIN32
typedef unsigned long CThreadEntryRet;
typedef unsigned long CThreadNativeId;
#else
typedef void* CThreadEntryRet;
typedef pthread_t CThreadNativeId;
#endif

int createThread(CThreadEntryRet (*pFuncter)(void*), void * pParam, CThreadNativeId & pThreadID, int pPriority);



class CThread
{
private:
	// holding the user Data
	void * mArg;

	// The thread is running
	bool mIsRunning;

protected:

#ifndef WIN32
	//pthread_t threadID;
#endif

	// To hold the thread ID
	CThreadNativeId mThreadId;

	static CThreadEntryRet entryPoint(void*);
	void * arg() const {return mArg;}
	void arg(void * pArg){mArg = pArg;}
	void run(void * arg);

	// The functions you have to redefine
	virtual void setup(); // Setuping your stuff
	virtual void execute(void* pArg) = 0; // Execute your thread

public:

	// Constructor
	CThread();

	// To start the thread process
	bool start(void * pArg = 0, int pThreadPriority = CTHREAD_PRIORITY_NORMAL);

	// To know if the thread is running
	bool isRunning() {return mIsRunning;}
};


#endif

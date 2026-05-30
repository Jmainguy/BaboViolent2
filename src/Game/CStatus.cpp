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

#include "CStatus.h"

CStatus* status = 0;

CStatus::CStatus(): m_status(ONLINE)
{
	update();
}

CStatus::~CStatus()
{
	if (m_status != OFFLINE)
		set(OFFLINE);
}

void CStatus::set(int status, CString serverName /* =  */, CString serverIP /* =  */, int port /* = 0 */)
{
	m_status = status;
	m_server = serverName;
	m_ip = serverIP;
	m_port = port;
	update();
}

int CStatus::get()
{
	return m_status;
}

CString CStatus::getText(int in_status)
{
	if (in_status < OFFLINE || in_status > INGAME)
		in_status = m_status;

	switch (in_status)
	{
	case ONLINE:
		return CString("%s", "\x2Online");
	case WEBSITE:
		return CString("%s", "\x3Website");
	case INGAME:
		return CString("%s", "\x9In Game");
	case OFFLINE:
	default:
		return CString("%s", "\x7Offline");
	}
}

void CStatus::update()
{
	// Legacy ladder HTTP status updates removed (dead third-party service).
}

void CStatus::processQueue()
{
}

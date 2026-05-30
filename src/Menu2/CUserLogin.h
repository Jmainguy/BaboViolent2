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
#ifndef CUSERLOGIN_H_INCLUDED
#define CUSERLOGIN_H_INCLUDED


#include "CPanel.h"


class CUserLogin : public CPanel
{
private:
	CString scratchLogin;
	CString scratchPassword;

public:
	CControl * parent = nullptr;

	// Le son pour quand on clic
	FSOUND_SAMPLE * m_sfxClic = nullptr;

	// Le son pour quand on passe au dessus
	FSOUND_SAMPLE * m_sfxOver = nullptr;

	// Client options
	CControl * txt_playerName = nullptr;

	// Pour dessiner notre sphere
#ifndef _DX_
	//GLUquadricObj* qObj;
#endif

	// Son shadow
	unsigned int tex_baboShadow = 0;
	unsigned int tex_skin = 0;
	unsigned int tex_skinOriginal = 0;

	float rollingAngle = 0.f;

	//--- we have 2 possible view
	CControl * pnl_login = nullptr;

		//--- Text field
		CControl * txt_userName = nullptr;
		CControl * txt_password = nullptr;

		//--- Some controls (Login and create acount)
		CControl * btn_login = nullptr;
		CControl * btn_createAccount = nullptr;

	//--- The stats panel
	CControl * pnl_stats = nullptr;
	
		//--- Le render zone o� on va dessiner notre babo yea poup�
		CControl * pic_babo = nullptr;

		//--- To choose babo color
		CControl * sld_layer1_r = nullptr;
		CControl * sld_layer1_g = nullptr;
		CControl * sld_layer1_b = nullptr;

		CControl * sld_layer2_r = nullptr;
		CControl * sld_layer2_g = nullptr;
		CControl * sld_layer2_b = nullptr;

		CControl * sld_layer3_r = nullptr;
		CControl * sld_layer3_g = nullptr;
		CControl * sld_layer3_b = nullptr;

		//--- His skin
		CControl * sld_skin = nullptr;

		//--- His medals
		unsigned long m_medals = 0;
		CControl * pic_medals[32]{};

		//--- Other stats
		CControl * lbl_honor = nullptr;
		CControl * lbl_xp = nullptr;
		CControl * lbl_leftToNextLevel = nullptr;
		CControl * lbl_totalKill = nullptr;
		CControl * lbl_totalDeath = nullptr;
		CControl * lbl_ratio = nullptr;
		CControl * lbl_killWeapon[20]{};
		CControl * lbl_weaponOfChoice = nullptr;

public:
	CUserLogin(CControl * in_parent, CControl * in_alignTo);
	virtual ~CUserLogin();

	void MouseEnter(CControl * control);
	void MouseLeave(CControl * control);
	void MouseDown(CControl * control);
	void MouseUp(CControl * control);
	void MouseMove(CControl * control);
	void Click(CControl * control);
	void Validate(CControl * control);
	void Paint(CControl * control);

	int updateSkinInt = 0;

	void updatePerso(float delay)
	{
		rollingAngle += delay * 90;
		while (rollingAngle >= 360) rollingAngle -= 360;

		if (instance->visible)
		{
			updateSkinInt++;
			if (updateSkinInt == 15)
			{
				updateSkin();
				updateSkinInt = 0;
			}
		}
	}

	void updateSkin();
};


#endif
#endif


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

/// \brief Module de gestion d'OpenGL
///
/// \file dkgl.h
/// Ce module prend en charge la gestion d'un contexte OpenGL et offre plusieurs fonctions utilitaires lui �tant rattach�. Ceci comprend :
/// 	- une fonction de cr�ation d'un contexte OpenGL
/// 	- une fonction de terminaison d'utilisation du module
/// 	- une fonction de permettant de v�rifier le support d'extensions d'OpenGL
/// 	- des fonctions permettant de changer la fa�on dont l'environnement 3D est transf�r� sur une surface 2D (vue de perspective ou orthogonale)
/// 	- diverses autres fonctions utilitaires
///
/// Le contexte OpenGL est une structure de donn�e utilis� par OpenGL qui contient une instance de cette librairie graphique.
///
/// \author David St-Louis (alias Daivuk)
/// \author Louis Poirier (� des fins de documentation seulement)
///


#ifndef DKGL_H
#define DKGL_H

#include "BrebisGL.h"
#include <SDL.h>

#include "CVector.h"


/// \name BlendingPreset
/// Drapeaux repr�sentant chacun une configuration de coefficients de m�lange de couleurs d'un pixel source et d'un pixel destination fr�quemment utilis�es. Voir DKP pour plus de d�tails sur le m�lange de couleur (blending)
//@{
/// repr�sente la paire de coefficients (source, destination) : (GL_ONE, GL_ONE)
const int DKGL_BLENDING_ADD_SATURATE = 0;
/// repr�sente la paire de coefficients (source, destination) : (GL_SRC_ALPHA, GL_ONE)
const int DKGL_BLENDING_ADD = 3;
/// repr�sente la paire de coefficients (source, destination) : (GL_DST_COLOR, GL_ZERO)
const int DKGL_BLENDING_MULTIPLY = 1;
/// repr�sente la paire de coefficients (source, destination) : (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
const int DKGL_BLENDING_ALPHA = 2;
//@}


// Les fonction du DKG


/// \brief v�rifie la pr�sence d'une extension d'OpenGL support�e par la carte vid�o
///
/// Cette fonction v�rifie la pr�sence d'une extension d'OpenGL support�e par la carte vid�o.
///
/// \param extension nom de l'extension
/// \return true si elle est support�e, false sinon
bool			dkglCheckExtension(char * extension);



/// \brief cr�e un contexte OpenGL
///
/// Cette fonction cr�e un contexte OpenGL essentiel au rendu. Elle doit �tre appel� avant tout autres appels � des fonctions de ce module ou d'OpenGL.
///
/// \param mDC Device Context de la fen�tre Windows
/// \param colorDepth nombre de bit utiliser pour chaque composant de couleur d'un pixel (16 ou 32.....donc 32)
/// \return true si la cr�ation du contexte a r�ussi, false sinon
int				 dkglCreateContext(SDL_GLContext mDC, int colorDepth);



/// \brief dessine le rep�re vectoriel de la sc�ne � l'origine
///
/// Cette fonction dessine le rep�re vectoriel de la sc�ne � l'origine. Le rep�re vectoriel est constitu� de 3 vecteurs tous perpendiculaire l'un par rapport � l'autre.
///
void			dkglDrawCoordSystem();



/// \brief dessine un cube en fil de fer
///
/// Cette fonction dessine un cube en fil de fer.
///
void			dkglDrawWireCube();



/// \brief permet de revenir en mode de rendu en perspective
///
/// Cette fonction de passer du mode de rendu orthographique (surtout utilis� pour dessiner en 2D sur l'�cran ou pour conserver le rapport des mesures comme dans les applications CAD) au mode de rendu en perspective 3D.
///
void			dkglPopOrtho();



/// \brief permet de passer en mode de rendu orthographique
///
/// Cette fonction passer du mode de rendu en perspective 3D au mode de rendu orthographique poss�dant une certaine dimension de rendu.
///
/// \param mWidth dimension en pixel du mode de rendu orthographique
/// \param mHeight dimension en pixel du mode de rendu orthographique
void			dkglPushOrtho(float mWidth, float mHeight);



/// \brief permet de sp�cifier la fonction de m�lange de couleur qui est active
///
/// Cette fonction permet de sp�cifier la fonction de m�lange de couleur(blending) qui est active en passant un des 4 drapeaux BlendingPreset en param�tre
///
/// \param blending drapeau BlendingPreset qui d�fini une fonction de m�lange de couleur(blending)
void			dkglSetBlendingFunc(int blending);


/// enable vsync ( true or false )
void			dkglEnableVsync(bool enabled = true);


/// \brief active une lumi�re OpenGL
///
/// Cette fonction active une des 8 lumi�res qu'OpenGL offre avec les sp�cificit�s suivantes :
/// 	- position = {x,y,z,1}
/// 	- couleur ambiente = {r/4,g/4,b/4,1}
/// 	- couleur diffuse = {r,g,b,1}
/// 	- couleur sp�culaire = {r,g,b,1}
///
/// \param ID Identifiant unique de la lumi�re (de 0 � 7)
/// \param x position de la lumi�re
/// \param y position de la lumi�re
/// \param z position de la lumi�re
/// \param r couleur de la lumi�re
/// \param g couleur de la lumi�re
/// \param b couleur de la lumi�re
void			dkglSetPointLight(int ID, float x, float y, float z, float r, float g, float b);



/// \brief sp�cifie et active un mode de rendu en perspective
///
/// Cette fonction sp�cifie et active un mode de rendu en perspective.
///
/// \param mFieldOfView angle de vue vertical en degr�s
/// \param mNear distance la plus proche de la cam�ra pouvant poss�der un rendu
/// \param mFar distance la plus �loign�e de la cam�ra pouvant poss�der un rendu
/// \param mWidth largeur de la fen�tre (unit� arbitraire, seul le ratio mWidth/mHeight importe vraiment)
/// \param mHeight hauteur de la fen�tre (unit� arbitraire)
void			dkglSetProjection(float mFieldOfView, float mNear, float mFar, float mWidth, float mHeight);



/// \brief d�truit le contexte OpenGL pr�c�demment cr��
///
/// Cette fonction d�truit le contexte OpenGL pr�c�demment cr��. Apr�s l'appel, un nouvel appel � dkglCreateContext() devra �tre fait avant tout autres appels de fonctions de ce module ainsi que de fonctions provenant d'OpenGL.
///
void			dkglShutDown();



/// \brief transforme la position de la souris 2D en un vecteur 3D
///
/// Cette fonction permet de faire correspondre la position de la souris et une certaine valeur entre [0,1] � un vecteur 3D. Le vecteur est simplement construit en prenant la position de la souris et en y ajoutant zRange (z,y,zRange) et en y soustrayant la position de la cam�ra.
/// On obtient alors un vecteur que l'on multiplie par la valeur de profondeur la plus �loign� de la cam�ra pouvant poss�der un rendu. C'est ce nouveau vecteur qui est retourn�.
///
/// \param pos2D position de la souris � l'�cran en pixel
/// \param zRange profondeur d�sir�e (entre 0 et 1)
/// \return le nouveau vecteur repr�sentant correspondant � la position de la souris en 3D � une certaine profondeur.
CVector3f		dkglUnProject(CVector2i & pos2D, float zRange);

CVector3f		dkglProject(const CVector3f & pos3D);


void gluLookAt(
    GLdouble eyex,
    GLdouble eyey,
    GLdouble eyez,
    GLdouble centerx,
    GLdouble centery,
    GLdouble centerz,
    GLdouble upx,
    GLdouble upy,
    GLdouble upz);

void drawSphere(GLdouble radius, GLint slices, GLint stacks, GLenum topology);

#endif

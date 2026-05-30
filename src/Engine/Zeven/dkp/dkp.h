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

/// \brief Module de gestion de particules
///
/// \file dkp.h
/// Ce module prend en charge la gestion des particules. Ceci comprend :
/// 	- une fonction d'initialisation du module
/// 	- une fonction de terminaison d'utilisation du module
/// 	- des fonctions de cr�ation de particules
/// 	- une fonction de rendu des particules
/// 	- une fonction de mise � jour des particules
/// 	- diverses autres fonctions utilitaires
///
/// Une particule est simplement une image affich�e sur un polygone qui fait toujours face � la cam�ra et qui se d�place, qui a une certaine dur�e de vie et qui peut changer d'image avec le temps ou selon d'autres circomstances.
/// D�pendant du type d'effet que l'on veut simuler avec des particules, on utilisera un m�lange de couleur (blending) diff�rent.
///
/// Le blending est la facon dont la couleur d'un certain pixel (pixel source) sera m�langer avec la couleur du pixel qui se trouve d�j� dans le tampon d'image (framebuffer) � la m�me coordonn�e (pixel destination) pour remplacer ce dernier. L'ordre dans lequel les primitives 3D sont dessin�es est donc importante ici puisque que lors du rendu d'une certaine primitive, c'est la valeur pr�sentement dans le tampon d'image (framebuffer) qui sera utilis� pour le m�lange de couleur et non avec le pixel de la primitive se trouvant directement derri�re (en profondeur) dans le tampon, comme on pourrait s'y attendre.
/// Chaque composante de couleur passant � une �chelle de [0,1] depuis [0,255], OpenGL d�fini 11 configurations RGBA pour m�langer les couleurs d'un pixel source avec un pixel destination:
/// 	- GL_ZERO : (0,0,0,0)
/// 	- GL_ONE : (1,1,1,1)
/// 	- GL_SRC_COLOR : (R,G,B,A) du pixel source
/// 	- GL_ONE_MINUS_SRC_COLOR : (1-R,1-G,1-B,1-A) du pixel source
/// 	- GL_SRC_ALPHA : (A,A,A,A) du pixel source
/// 	- GL_ONE_MINUS_SRC_ALPHA : (1-A,1-A,1-A,1-A) du pixel source
/// 	- GL_DST_ALPHA : (A,A,A,A) du pixel destination
/// 	- GL_ONE_MINUS_DST_ALPHA : (1-A,1-A,1-A,1-A) du pixel destination
/// 	- GL_DST_COLOR : (R,G,B,A) du pixel destination
/// 	- GL_ONE_MINUS_DST_COLOR : (1-R,1-G,1-B,1-A) du pixel destination
/// 	- GL_SRC_ALPHA_SATURATE : (i,i,i,1) o� i = la valeur la plus petite entre le A du pixel source et 1-A du pixel destination
/// 
/// Apr�s avoir sp�cifier une de ces configurations pour le pixel source et pour le pixel destination, la formule suivante est utiliser pour g�n�rer la nouvelle couleur :
///
/// Rd = min ( 255 , Rs*sR + Rd*dR )
/// Gd = min ( 255 , Gs*sG + Gd*dG )
/// Bd = min ( 255 , Bs*sB + Bd*dB )
/// Ad = min ( 255 , As*sA + Ad*dA )
/// o� :
/// 	- (Rd,Gd,Bd,Ad) = pixel destination (d�j� pr�sent dans le tampon d'image et qui sera mis � jour) sur une �chelle de [0,255]
/// 	- (Rs,Gs,Bs,As) = pixel source sur une �chelle de [0,255]
/// 	- (sR,sG,sB,sA) = coefficients de m�lange du pixel source (l'une des 9 configurations possibles) sur une �chelle de [0,1]
/// 	- (dR,dG,dB,dA) = coefficients de m�lange du pixel destination (l'une des 8 configurations possibles)  sur une �chelle de [0,1]
///
/// \author David St-Louis (alias Daivuk)
/// \author Louis Poirier (� des fins de documentation seulement)
///


#ifndef DKP_H
#define DKP_H



#include "CVector.h"


/// \name not used
/// constantes non utilis�es
//@{
const int DKP_TRANS_LINEAR = 0;
const int DKP_TRANS_FASTIN = 1;
const int DKP_TRANS_FASTOUT = 2;
const int DKP_TRANS_SMOOTH = 3;
//@}


// BlendingFactorDest
/// \name BlendingFactorDest
/// Drapeaux repr�sentant les 8 configurations possibles pour les coefficients de m�lange de couleur (blending) du pixel destination
//@{
#define DKP_ZERO                           0
#define DKP_ONE                            1
#define DKP_SRC_COLOR                      0x0300
#define DKP_ONE_MINUS_SRC_COLOR            0x0301
#define DKP_SRC_ALPHA                      0x0302
#define DKP_ONE_MINUS_SRC_ALPHA            0x0303
#define DKP_DST_ALPHA                      0x0304
#define DKP_ONE_MINUS_DST_ALPHA            0x0305
//@}

// BlendingFactorSrc
/// \name BlendingFactorSrc
/// Drapeaux repr�sentant les 9 configurations possibles pour les coefficients de m�lange de couleur (blending) du pixel source
/// \note Il y a 6 drapeaux communs entre BlendingFactorDest et BlendingFactorSrc
//@{
///     DKP_ZERO
///     DKP_ONE
#define DKP_DST_COLOR                      0x0306
#define DKP_ONE_MINUS_DST_COLOR            0x0307
#define DKP_SRC_ALPHA_SATURATE             0x0308
///     DKP_SRC_ALPHA
///     DKP_ONE_MINUS_SRC_ALPHA
///     DKP_DST_ALPHA
///     DKP_ONE_MINUS_DST_ALPHA
//@}


// Struct pratique pour se cr�er des presets

/// \brief conteneur de configurations de particules
///
/// Cette structure permet une utilisation plus flexible de la cr�ation de particules en isolant les nombreux param�tres de cr�ation. Cette structure peut �tre pass�e � dkpCreateParticleExP().
/// Voir la d�finition des param�tres de dkpCreateParticleEx() pour plus de d�tails sur les membres de cette structure : il s'agit exactement des m�mes champs.
///
struct dkp_preset {
	CVector3f positionFrom;
	CVector3f positionTo;
	CVector3f direction;
	float speedFrom;
	float speedTo;
	float pitchFrom;
	float pitchTo;
	float startSizeFrom;
	float startSizeTo;
	float endSizeFrom;
	float endSizeTo;
	float durationFrom;
	float durationTo;
	CColor4f startColorFrom;
	CColor4f startColorTo;
	CColor4f endColorFrom;
	CColor4f endColorTo;
	float angleFrom;
	float angleTo;
	float angleSpeedFrom;
	float angleSpeedTo;
	float gravityInfluence;
	float airResistanceInfluence;
	unsigned int particleCountFrom;
	unsigned int particleCountTo;
	unsigned int *texture;
	int textureFrameCount;
	unsigned int srcBlend;
	unsigned int dstBlend;
};



// Les fonction du DKP

/// \brief non utilis�e
///
/// Non utilis�e
///
void			dkpCreateBillboard(	CVector3f & positionFrom,
									CVector3f & positionTo,
									float fadeSpeed,
									float fadeOutDistance,
									float size,
									CColor4f & color,
									unsigned int textureID,
									unsigned int srcBlend,
									unsigned int dstBlend);
									
									

/// \brief cr�ation d'une particule
///
/// Cette fonction permet de cr�er une particule par appel. Il s'agit ici d'une fonction impliquant un minimum de controle sur le comportement de la particule cr��.
///
/// \param position position de d�part de la particule par rapport � l'origine de la sc�ne
/// \param vel vecteur vitesse de d�part de la particule
/// \param startColor couleur de d�part de la particule
/// \param endColor couleur de fin de la particule
/// \param startSize grosseur de d�part de la particule
/// \param endSize grosseur de fin de la particule
/// \param duration dur�e de vie de la particule
/// \param gravityInfluence pourcentage d'influence de la gravit� sur la particule
/// \param airResistanceInfluence coefficient de frottement de l'air sur la particule
/// \param rotationSpeed vitesse de rotation de la particule (l'axe de rotation est parall�le � la droite que forme la cam�ra et la particule et le sens de rotation est d�termin� par le signe du nombre)
/// \param texture identifiant unique d'une texture OpenGL charg�e en m�moire qui sera la partie visible de la particule
/// \param srcBlend drapeau repr�sentant l'une des 9 configurations possibles du pixel source pour le m�lange de couleur(blending) 
/// \param dstBlend drapeau repr�sentant l'une des 8 configurations possibles du pixel destination pour le m�lange de couleur(blending)
/// \param transitionFunc non utilis� (peut �tre toujours mis � 0)
void			dkpCreateParticle(	float *position,
									float *vel,
									float *startColor,
									float *endColor,
									float startSize,
									float endSize,
									float duration,
									float gravityInfluence,
									float airResistanceInfluence,
									float rotationSpeed,
									unsigned int texture,
									unsigned int srcBlend,
									unsigned int dstBlend,
									int transitionFunc);
									
									

/// \brief cr�ation d'une particule avec plus de controle
///
/// Cette fonction permet de cr�er une ou un groupe de particules avec ou sans animations par appel. Il s'agit ici d'une fonction impliquant plus de controle sur le comportement de la particule cr�� que la fonction dkpCreateParticle().
/// Chaque paire de param�tre dont les noms se terminent par 'From' et 'To' d�finissent une port�e de valeurs � l'int�rieur de laquelle une certaine valeur sera choisie al�atoirement.
///
/// \param positionFrom position de d�part de la particule (ext�mit� d'une boite align�e avec chaque axe du rep�re de la sc�ne, la position g�n�r� al�atoirement se trouvera dans cette boite)
/// \param positionTo position de d�part de la particule ( seconde ext�mit� d'une boite align�e avec chaque axe du rep�re de la sc�ne, la position g�n�r� al�atoirement se trouvera dans cette boite)
/// \param direction vecteur direction de d�part de la particule (sera multipli� par 'speed' pour donner le vecteur vitesse de d�part de la particule)
/// \param speedFrom vitesse de d�part de la particule
/// \param speedTo vitesse de d�part de la particule
/// \param pitchFrom angle de faisceau de d�part (entre 0 et 360)
/// \param pitchTo angle de faisceau de d�part(entre 0 et 360)
/// \param startSizeFrom grandeur de d�part
/// \param startSizeTo grandeur de d�part
/// \param endSizeFrom grandeur de fin (grandeur qu'aura la particule � la fin de sa dur�e de vie, l'interpolation est lin�aire)
/// \param endSizeTo grandeur de fin (grandeur qu'aura la particule � la fin de sa dur�e de vie, l'interpolation est lin�aire)
/// \param durationFrom dur�e de vie
/// \param durationTo dur�e de vie
/// \param startColorFrom couleur de d�part
/// \param startColorTo couleur de d�part
/// \param endColorFrom couleur de fin (couleur qu'aura la particule � la fin de sa dur�e de vie, l'interpolation est lin�aire)
/// \param endColorTo couleur de fin (couleur qu'aura la particule � la fin de sa dur�e de vie, l'interpolation est lin�aire)
/// \param angleFrom angle de d�part
/// \param angleTo angle de d�part
/// \param angleSpeedFrom vitesse de rotation
/// \param angleSpeedTo vitesse de rotation
/// \param gravityInfluence pourcentage d'influence de la gravit� sur la particule
/// \param airResistanceInfluence coefficient de frottement de l'air sur la particule
/// \param particleCountFrom nombre de particule devant �tre cr��es
/// \param particleCountTo nombre de particule devant �tre cr��es
/// \param texture tableau d'identifiants uniques de textures OpenGL charg�es en m�moire. L'ordre du tableau d�terminera l'animation de la particule
/// \param textureFrameCount nombre de textures contenues dans le param�tre 'texture'. Ce nombre d�termine aussi le nombre d'images constituants l'animation de la ou des particules
/// \param srcBlend drapeau repr�sentant l'une des 9 configurations possibles du pixel source pour le m�lange de couleur(blending)
/// \param dstBlend drapeau repr�sentant l'une des 8 configurations possibles du pixel destination pour le m�lange de couleur(blending)
void			dkpCreateParticleEx(const CVector3f & positionFrom,
									const CVector3f & positionTo,
									const CVector3f & direction,
									float speedFrom,
									float speedTo,
									float pitchFrom,
									float pitchTo,
									float startSizeFrom,
									float startSizeTo,
									float endSizeFrom,
									float endSizeTo,
									float durationFrom,
									float durationTo,
									const CColor4f & startColorFrom,
									const CColor4f & startColorTo,
									const CColor4f & endColorFrom,
									const CColor4f & endColorTo,
									float angleFrom,
									float angleTo,
									float angleSpeedFrom,
									float angleSpeedTo,
									float gravityInfluence,
									float airResistanceInfluence,
									unsigned int particleCountFrom,
									unsigned int particleCountTo,
									unsigned int *texture,
									int textureFrameCount,
									unsigned int srcBlend,
									unsigned int dstBlend);



/// \brief cr�ation d'une particule avec plus de controle et de flexibilit�
///
/// Cette fonction accomplie exactement la m�me chose que dkpCreateParticleEx() mais en utilisant la structure dkp_preset comme param�tre.
///
/// \param preset pr�configuration de la g�n�ration de particules
void			dkpCreateParticleExP(dkp_preset & preset);



/// \brief initialisation du module
///
/// Cette fonction effectue l'initialisation du module et doit �tre appel� AVANT tout autres appels � d'autres fonctions de ce module.
///
void			dkpInit();



/// \brief affiche toutes les particules � l'�cran
///
/// Cette fonction effectue le rendu � l'ecran de toutes les particules qui ont �t� cr��es jusqu'� pr�sent et qui sont actives.
///
void			dkpRender();




/// \brief lib�re la m�moire allou�e pour la cr�ation de particules
///
/// Cette fonction lib�re toute la m�moire allou�e pour la cr�ation des particules pr�sentement actives. Toutes les particules cr��es seront effac�es.
///
void			dkpReset();



/// \brief sp�cifie une densit� de l'air
///
/// Cette fonction permet de changer la densit� de l'air qui sera utiliser pour la simulation des particules (leurs vitesses sera d�c�l�r�es proportionnellement � cette valeur)
///
/// \param airDensity nouvelle densit� de l'air
void			dkpSetAirDensity(float airDensity);



/// \brief sp�cifie une attraction gravitationnelle
///
/// Cette fonction permet de changer l'attraction gravitationnelle qui sera utiliser pour la simulation des particules.
///
/// \param vel vecteur acc�l�ration gravitationnelle
void			dkpSetGravity(float *vel);



/// \brief active le triage des particules
///
/// Cette fonction permet d'activer ou de d�sactiver le triage des particules qui seront cr��es apr�s l'appel. Ce triage fait en sorte que la particule la plus �loign�e de la cam�ra sera rendue en premier, puis la suivante la plus �loign�e et ainsi de suite. Ceci permet certain type de m�lange de couleur (blending) de donner un effet attendu.
///
/// \param sort true pour activer le triage, false si on veut le d�sactiver
void			dkpSetSorting(bool sort);



/// \brief lib�re la m�moire allou�e pour la cr�ation de particules et termine l'utilisation de ce module
///
/// Cette fonction lib�re la m�moire allou�e pour la cr�ation de particules et termine l'utilisation de ce module. dkpInit() pourra �tre appel� de nouveau par la suite pour red�marrer le module.
///
void			dkpShutDown();



/// \brief effectue la mise � jour des particules pour le rendu
///
/// Cette fonction effectue la mise � jour de la position, la vitesse, la dur�e de vie, la couleur, l'angle, et l'image de chaque particule pour le rendu.
///
/// \param delay intervalle de temps sur lequel la mise � jour est effectu�e.
/// \return le nombre de particule encore actives apr�s l'ex�cution de la mise � jour
int				dkpUpdate(float delay);



#endif
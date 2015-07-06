/*****************************************************************************\
  textsupport.cpp : Implimentation for the TextTranslator class

  Copyright (c) 1996 - 2001, Hewlett-Packard Co.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
  3. Neither the name of Hewlett-Packard nor the names of its
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
  NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
  TO, PATENT INFRINGEMENT; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
\*****************************************************************************/


#include "header.h"
#if defined(APDK_FONTS_NEEDED)

APDK_BEGIN_NAMESPACE

extern BYTE EscCopy(BYTE *dest,const char *s,int num, char end);
///////////////////////////////////////////////////////////////////////
// TEXT SECTION
// Code from other modules to be left out of "no-font" builds.
///////////////////////////////////////////////////////////////////////

TextTranslator::TextTranslator(Printer* p, int quality,unsigned int colorplanes)
    : thePrinter(p), qualcode(quality), iNumPlanes(colorplanes)
{
    lastname[0]='\0';       // init variable used to check for changed typeface
    constructor_error= NO_ERROR;
}

TextTranslator::~TextTranslator()
{ }

//////////////////////////////////////////////////////////////////
BYTE TextTranslator::ColorCode(TEXTCOLOR eColor)
{
    if (!thePrinter->UseCMYK(DEFAULTMODE_INDEX))
        // then the palette setting is "RGB", 3 planes, same as CMY
        return ColorCode3(eColor);

    if (iNumPlanes==1)
        return ColorCode1(eColor);
    if (iNumPlanes==3)
        return ColorCode3(eColor);
    if (iNumPlanes>3)
        return ColorCode4(eColor);
    else return 1;                  // bail out -- black

}

BYTE TextTranslator::ColorCode1(TEXTCOLOR eColor)
// One plane only -- must be black or white
{
    if (eColor==WHITE_TEXT) return 0;
    else return 1;
}

BYTE TextTranslator::ColorCode4(TEXTCOLOR eColor)
// 4 planes -- KCMY pen
{ BYTE color;

    switch(eColor)
    {   case(BLACK_TEXT): color=7; break;
        case(CYAN_TEXT): color=2; break;
        case(MAGENTA_TEXT): color=4; break;
        case(YELLOW_TEXT): color=8; break;
        case(RED_TEXT): color=12; break;
        case(GREEN_TEXT): color=10; break;
        case(BLUE_TEXT): color=6; break;
        case(WHITE_TEXT): color=0; break;
        default:
            color=7; break;
    }
    return color;
}

BYTE TextTranslator::ColorCode3(TEXTCOLOR eColor)
// 3 planes -- CMY pen
{   BYTE color;

    switch(eColor)
    {   case(BLACK_TEXT): color=7; break;
        case(CYAN_TEXT): color=1; break;
        case(MAGENTA_TEXT): color=2; break;
        case(YELLOW_TEXT): color=4; break;
        case(RED_TEXT): color=6; break;
        case(GREEN_TEXT): color=5; break;
        case(BLUE_TEXT): color=3; break;
        case(WHITE_TEXT): color=0; break;
        default:
            color=7; break;
    }
return color;
}

int TextTranslator::TypefaceCode(const char* FontName)
{
  if (!strcmp(FontName,sCourier))
      return 3;
  if (!strcmp(FontName,sLetterGothic))
      return 6;
  if (!strcmp(FontName,sCGTimes))
      return 4101;
  if (!strcmp(FontName,sUnivers))
      return 52;
return 0;
}


DRIVER_ERROR TextTranslator::SendCAP(unsigned int iAbsX, unsigned int iAbsY)
{ int len; BYTE temp[20];

    len= EscCopy(temp,"*p",iAbsX,'X');
    len += EscCopy(&temp[len],"*p",iAbsY,'Y');

 return thePrinter->Send( temp, len);
}

///////////////////////////////////////////////////////////////////////////
DRIVER_ERROR TextTranslator::SendColorSequence(const TEXTCOLOR eColor)
{
    return thePrinter->Send( ColorSequence(eColor) );
}

const BYTE* TextTranslator::ColorSequence(TEXTCOLOR eColor)
{
    sprintf((char*)EscSeq,"\033*v%dS",ColorCode(eColor));
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendPointsize(const unsigned int iPointsize)
{
    return thePrinter->Send( PointsizeSequence(iPointsize) );
}

const BYTE* TextTranslator::PointsizeSequence(unsigned int iPointsize)
{
    sprintf((char*)EscSeq,"\033(s%dV", iPointsize);
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendPitch(const unsigned int iPitch)
{
    return thePrinter->Send( PitchSequence(iPitch) );
}

const BYTE* TextTranslator::PitchSequence(unsigned int iPitch)
{
  sprintf((char*)EscSeq,"\033(s%dH", iPitch);
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendStyle(const BOOL bItalic)
{
    return thePrinter->Send( StyleSequence(bItalic) );
}

const BYTE* TextTranslator::StyleSequence(BOOL bItalic)
// Only supported styles are currently 1 (italic) and 0 (normal).
{
    sprintf((char*)EscSeq,"\033(s%dS", bItalic);
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendWeight(const BOOL bBold)
{
    return thePrinter->Send( WeightSequence(bBold) );
}

const BYTE* TextTranslator::WeightSequence(BOOL bBold)
// Only supported weights are currently 3 (bold) and 0 (normal).
{ int w;

    if (bBold) w=3;
    else w=0;

    sprintf((char*)EscSeq,"\033(s%dB",w);
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendUnderline()
{
    return thePrinter->Send( UnderlineSequence() );
}

const BYTE* TextTranslator::UnderlineSequence()
{
    sprintf((char*)EscSeq,"\033&d%dD", 0);
  return EscSeq;
}

DRIVER_ERROR TextTranslator::DisableUnderline()
{
    return thePrinter->Send( DisableUnderlineSequence() );
}

const BYTE* TextTranslator::DisableUnderlineSequence()
{
    sprintf((char*)EscSeq,"\033&d@");
  return EscSeq;
}

DRIVER_ERROR TextTranslator::SendCompleteSequence(const Font& font)
{
    return thePrinter->Send( CompleteSequence(font) );
}

const BYTE* TextTranslator::CompleteSequence(const Font& font)
// send complete specification:
// charset spacing pitch height style weight face quality
// send combined sequence
{
    BYTE weightval;
    if (font.bBold)
        weightval=3;
    else weightval=0;

    if (font.IsProportional())
    // omit pitch for proportional
        sprintf((char*)EscSeq,"\033(%s\033(s%dp%dv%ds%db%dt%dQ",
                    font.charset,
                    font.IsProportional(),
                    font.iPointsize,
                    font.bItalic,
                    weightval,
                    TypefaceCode(font.GetName()),
                    qualcode);
    else
        sprintf((char*)EscSeq,"\033(%s\033(s%dp%dh%dv%ds%db%dt%dQ",
                    font.charset,
                    font.IsProportional(),
                    font.iPitch,
                    font.iPointsize,
                    font.bItalic,
                    weightval,
                    TypefaceCode(font.GetName()),
                    qualcode);


 return EscSeq;
}



int TextTranslator::TransparentChar(unsigned int iMaxLen, BYTE b, BYTE* outbuff)
// Output the PCL command to prevent b from being interpreted as a control code.
// Writes sequence into outbuff.
// Returns the length of the sequence, or 0 if length>iMaxLen.
{
    if (iMaxLen<6)  // 6 chars in string below
        return 0;
    sprintf((char*)outbuff,"%c%c%c%d%c%c",'\033','&','p',1,'X',b);

    return 6;
}


///////////////////////////////////////////////////////////
DRIVER_ERROR TextTranslator::SendFont(const Font& font)
// Resets font characteristics as needed;
// after first time, resend==FALSE unless ForceFontSend called.
{
    DRIVER_ERROR err = NO_ERROR;
/*
	if (thePrinter->PrinterLanguage () == 10)
	{
		char	psStr[256];
		static  char *textColors[] =  {
									  {"1.0 1.0 1.0"},
									  {"0.0 1.0 1.0"},
									  {"1.0 0.0 1.0"},
									  {"0.0 0.0 1.0"},
									  {"1.0 1.0 0.0"},
									  {"0.0 1.0 0.0"},
									  {"1.0 0.0 0.0"},
									  {"0.0 0.0 0.0"}
									  };
		int		fh = (font.iPointsize * 600 / 72);
		sprintf (psStr, "/%s", font.GetName ());

		if (font.bItalic)
			strcat (psStr, "-Italic");
		if (font.bBold)
			strcat (psStr, "-bold");
		sprintf (psStr + strlen (psStr), " findfont %d scalefont setfont\n", fh);
		if (lastcolor != font.eColor)
		{
			sprintf (psStr + strlen (psStr), "%s setcolor\n", textColors[font.eColor]);
		}
		err = thePrinter->Send ((const BYTE *) psStr, strlen (psStr));

	    SetLast(font);

		return err;
	}
*/
    // set color
    if (lastcolor != font.eColor)
    {
		err=SendColorSequence(font.eColor);
        ERRCHECK;
    }

    // if different typeface or charset
    if (strcmp(lastname,font.GetName()) || strcmp(lastcharset,font.charset) )
      { err=SendCompleteSequence(font);
        ERRCHECK;
       }
    else
      {

        if (lastpointsize != font.iPointsize)
          { err=SendPointsize(font.iPointsize);
            ERRCHECK;
            if (font.IsProportional() == FALSE)
            {
              err=SendPitch(font.iPitch);
              ERRCHECK;
            }
          }

        if (lastitalic != font.bItalic)
          { err=SendStyle(font.bItalic);
            ERRCHECK;
          }

        if (lastbold != font.bBold)
          { err=SendWeight(font.bBold);
            ERRCHECK;
          }
      }

// logic of underlining is different, because underlining will happen even on
// horizontal move without chars; so underlining must always be turned off
// after sending any underlined string; thus we need to re-enable it every time
    if (font.bUnderline)
        err=SendUnderline();


    SetLast(font);

 return err;
}

void TextTranslator::SetLast(const Font& font)
{
    lastcolor=font.eColor;
    strcpy(lastname,font.GetName());
    strcpy(lastcharset,font.charset);
    lastpointsize=font.iPointsize;
    lastitalic=font.bItalic;
    lastbold=font.bBold;
}
////////////////////////////////////////////////////////////////////////////
// This routine is called by the external API TextOut routine.
// Does actual writing to printer, including sending CAP if specified.
DRIVER_ERROR TextTranslator::TextOut(const char* pTextString, unsigned int LenString,
                                 const Font& font,BOOL sendfont,
                                 int iAbsX, int iAbsY)
{
    DRIVER_ERROR err = NO_ERROR;

	if (thePrinter->PrinterLanguage () == 10)
	{

		char	psStr[512];
		static  char *textColors[] =  {
									  {"1.0 1.0 1.0"},
									  {"0.0 1.0 1.0"},
									  {"1.0 0.0 1.0"},
									  {"0.0 0.0 1.0"},
									  {"1.0 1.0 0.0"},
									  {"0.0 1.0 0.0"},
									  {"1.0 0.0 0.0"},
									  {"0.0 0.0 0.0"}
									  };
		int		fh = (font.iPointsize * 600 / 72);
		psStr[0] = '\0';
		if (lastcolor != font.eColor)
		{
			sprintf (psStr, "%s sc\n", textColors[font.eColor]);
		}

		sprintf (psStr + strlen (psStr), "/%s", font.GetName ());

		if (font.bItalic)
			strcat (psStr, "-Italic");
		if (font.bBold)
			strcat (psStr, "-bold");
		sprintf (psStr + strlen (psStr), " ff");
		err = thePrinter->SaveText (psStr, font.iPointsize, iAbsX, iAbsY,
									pTextString, LenString, font.bUnderline);
	    SetLast(font);
		return err;
	}
			
    if ((iAbsX!= -1) && (iAbsY != -1))
        err= SendCAP(iAbsX,iAbsY);
    ERRCHECK;
    if (sendfont)
        err=SendFont(font);
    ERRCHECK;

    err= thePrinter->Send( (const BYTE*)pTextString, LenString);
    ERRCHECK;

    // underlining must always be disabled after the string, otherwise
    // lines will be drawn when the CAP moves
    if (font.bUnderline)
        DisableUnderline();

return err;
}

////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
// Functions to report on printer properties, passed to client
// from the Printer objects themselves.

/*!
Returns a Font object for the selected printer based on index, in order for
host to query font properties prior to selection.
\param ICurrIdx Caller starts at zero; reference variable is incremented
automatically for next call.
\return Pointer to a reference font of the specified family, which can be
queried regarding its properties and allowable settings. This object cannot
be deleted by caller.  If index is out of range, returns NULL.
*/
ReferenceFont* PrintContext::EnumFont(int& iCurrIdx)
{

    if (thePrinter==NULL)
        return NULL;
    return thePrinter->EnumFont(iCurrIdx);
}


/*!
The means of creating a Font object with the desired properties, for use in
Job::TextOut calls.
\param index Font index number as returned by EnumFont.
\param bSize Point size
\param eColor Color to use to print this font
\param bBold TRUE to use bold
\param bItalic TRUE to use italics
\param bUnderline TRUE to use underlining
\return Pointer to font object with desired properties. If index is out of
range or fonts are unsupported, returns NULL.
\note Caller has the responsibility for deleting the resulting Font object when done.
*/
Font* PrintContext::RealizeFont(const int index,const BYTE bSize,
                       const TEXTCOLOR eColor,
                       const BOOL bBold,const BOOL bItalic,
                       const BOOL bUnderline)
{
    Font* pf;
    if ((thePrinter==NULL) || (CurrentMode==NULL))
        return NULL;

    if (CurrentMode->bFontCapable)
        pf = thePrinter->RealizeFont(index,bSize,eColor,bBold,bItalic,bUnderline);
    else pf = NULL;

#ifdef APDK_CAPTURE
    if (pf)
        pf->pSS = pSS;
    Capture_RealizeFont((const unsigned int)pf,index,bSize,eColor,bBold,bItalic,bUnderline);
#endif

    return pf;

}

//////////////////////////////////////////////////////////////////////////////////////
ReferenceFont* Printer::EnumFont(int& iCurrIdx)
// Get info directly out of the font classes we know about.
{
    ReferenceFont* pFont = NULL;

    // The following switch statement allows returning
    // potentially non-consecutive index values.

    // Note that if a particular font is not in the build,
    // the case will fall to the next available font in
    // the list and the index value incremented from there.

    iCurrIdx++;  // increment to the next font

    switch (iCurrIdx)
    {
        case COURIER_INDEX:
#ifdef APDK_COURIER
                pFont = fontarray[COURIER_INDEX];
                iCurrIdx = COURIER_INDEX;
                break;
#endif
        case CGTIMES_INDEX:
#ifdef APDK_CGTIMES
                pFont = fontarray[CGTIMES_INDEX];
                iCurrIdx = CGTIMES_INDEX;
                break;
#endif
        case LETTERGOTHIC_INDEX:
#ifdef APDK_LTRGOTHIC
                pFont = fontarray[LETTERGOTHIC_INDEX];
                iCurrIdx = LETTERGOTHIC_INDEX;
                break;
#endif
        case UNIVERS_INDEX:
#ifdef APDK_UNIVERS
                pFont = fontarray[UNIVERS_INDEX];
                iCurrIdx = UNIVERS_INDEX;
                break;
#endif
        default:
                pFont = NULL;
                iCurrIdx = 0;
                break;
    }

    return pFont;
}

// DJ400 will override this function with it's own fonts
Font* Printer::RealizeFont(const int index,const BYTE bSize,
                           const TEXTCOLOR eColor,
                           const BOOL bBold,const BOOL bItalic,
                           const BOOL bUnderline)

{
#ifdef APDK_COURIER
    if (index==COURIER_INDEX)
    {
        Courier* c=(Courier*) fontarray[index];
        return new Courier(*c,bSize,eColor,bBold,bItalic,bUnderline);
    }
    else
#endif
#ifdef APDK_CGTIMES
    if (index==CGTIMES_INDEX)
    {
        CGTimes* c=(CGTimes*) fontarray[index];
        return new CGTimes(*c,bSize,eColor,bBold,bItalic,bUnderline);
    }
    else
#endif
#ifdef APDK_LTRGOTHIC
    if (index==LETTERGOTHIC_INDEX)
    {
        LetterGothic* c=(LetterGothic*) fontarray[index];
        return new LetterGothic(*c,bSize,eColor,bBold,bItalic,bUnderline);
    }
    else
#endif
#ifdef APDK_UNIVERS
    if (index==UNIVERS_INDEX)
    {
        Univers* c=(Univers*) fontarray[index];
        return new Univers(*c,bSize,eColor,bBold,bItalic,bUnderline);
    }
    else
#endif
        return NULL;
}

APDK_END_NAMESPACE

#endif // any fonts

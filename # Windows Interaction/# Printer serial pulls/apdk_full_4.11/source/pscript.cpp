/*****************************************************************************\
  pscript.cpp : Implimentation for the PScript class

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


#ifdef APDK_PSCRIPT

#include "header.h"
#include "io_defs.h"
#include "pscript.h"
#include "printerproxy.h"
#include "resources.h"

APDK_BEGIN_NAMESPACE

#define PS_BUFFER_CHUNK_SIZE 2 * 1024 * 1024

PScript::PScript (SystemServices* pSS, int numfonts, BOOL proto)
    : Printer(pSS, numfonts, proto)
{

    if ((!proto) && (IOMode.bDevID))
    {
        constructor_error = VerifyPenInfo();
        CERRCHECK;
    }
    else ePen = BOTH_PENS;    // matches default mode

    pMode[GRAYMODE_INDEX]      = new PScriptGrayMode ();
    pMode[DEFAULTMODE_INDEX]   = new PScriptNormalMode ();
    pMode[SPECIALMODE_INDEX]   = new PScriptDraftMode ();
    ModeCount = 3;

    CMYMap = NULL;

    m_pHeadPtr = NULL;
    m_pCurItem = NULL;

    m_pbyJpegBuffer = NULL;
    m_pbyInputRaster = NULL;
    m_iPageNumber = 0;

    DBG1("PScript created\n");
}

PScript::~PScript ()
{
    if (m_pbyInputRaster)
        pSS->FreeMem (m_pbyInputRaster);
    if (m_pbyJpegBuffer)
        pSS->FreeMem (m_pbyJpegBuffer);
    FreeList ();
}

void PScript::FreeList ()
{
    StrList *p = m_pHeadPtr;
    while ((p = m_pHeadPtr) != NULL)
    {
        m_pHeadPtr = p->next;
        pSS->FreeMem ((BYTE *) p->pPSString);
        pSS->FreeMem ((BYTE *) p);
    }
    m_pHeadPtr = NULL;
}

PScriptDraftMode::PScriptDraftMode ()
: PrintMode (NULL)
{
    ResolutionX[0] = PS_BASE_RES;
    ResolutionY[0] = PS_BASE_RES;
    BaseResX = PS_BASE_RES;
    BaseResY = PS_BASE_RES;
    MixedRes = FALSE;
    bFontCapable = TRUE;
    theQuality = qualityDraft;
    pmQuality = QUALITY_DRAFT;
    Config.bCompress = FALSE;
}

PScriptNormalMode::PScriptNormalMode ()
: PrintMode (NULL)
{
    ResolutionX[0] = PS_BASE_RES * 2;
    ResolutionY[0] = PS_BASE_RES * 2;
    BaseResX = PS_BASE_RES * 2;
    BaseResY = PS_BASE_RES * 2;
    TextRes =  PS_BASE_RES * 2;
    MixedRes = FALSE;
    bFontCapable = TRUE;
    Config.bColorImage = FALSE;
    Config.bCompress = FALSE;
}

PScriptGrayMode::PScriptGrayMode () : PrintMode (NULL)
{
    ResolutionX[0] =
    ResolutionY[0] =
    BaseResX =
    BaseResY = PS_BASE_RES * 2;
    Config.bColorImage = FALSE;
    pmColor = GREY_CMY;
    Config.bCompress = FALSE;
}

HeaderPScript::HeaderPScript (Printer* p,PrintContext* pc)
    : Header(p,pc)
{
    CAPy = 0;
}

DRIVER_ERROR HeaderPScript::Send ()
{
    DRIVER_ERROR err;

    err = StartSend ();

    return err;
}

DRIVER_ERROR HeaderPScript::StartSend ()
{
    DRIVER_ERROR err;
    char    res[256];
    int     iRes;
    const char    *pszStartJob = "\x1B%-12345X@PJL JOB\x0A@PJL SET HOLD=OFF\x0A@PJL ENTER LANGUAGE=POSTSCRIPT\x0A";
    const char *pULProc = "/ul {\r\n\
currentpoint\r\n\
/starty exch def\r\n\
/startx exch def\r\n\
show\r\n\
currentpoint\r\n\
/endy exch def\r\n\
/endx exch def\r\n\
currentfont dup\r\n\
/FontMatrix get\r\n\
exch\r\n\
/FontInfo get dup\r\n\
/UnderlinePosition get\r\n\
exch\r\n\
/UnderlineThickness get\r\n\
3 -1 roll dtransform\r\n\
/UT exch def\r\n\
/UP exch def\r\n\
0 UP rmoveto\r\n\
startx endx sub 0 rlineto\r\n\
currentlinewidth\r\n\
UT setlinewidth\r\n\
stroke\r\n\
setlinewidth\r\n\
endx endy moveto\r\n\
} def\r\n";

    iRes = thePrintContext->EffectiveResolutionY ();
    err = thePrinter->Send ((const BYTE *) pszStartJob, strlen (pszStartJob));

    sprintf (res, "%%!PS-Adobe-3.0\n/in {%d mul} def\n/tr {translate} def\n", iRes);
    err = thePrinter->Send ((const BYTE *) res, strlen (res));
    ERRCHECK;
    sprintf (res, "/sv {save} def\n/re {restore} def\n");
    sprintf (res + strlen (res), "/sf {setfont} def\r\n/ff {findfont} def\r\n/scf {scalefont} def\r\n");
    sprintf (res + strlen (res), "/sc {setcolor} def\r\n/mv {moveto} def\r\n");
    sprintf (res + strlen (res), "/sh {show} def\r\n/ro {rotate} def\r\n");
    err = thePrinter->Send ((const BYTE *) res, strlen (res));
    ERRCHECK;

    err = thePrinter->Send ((const BYTE *) pULProc, strlen (pULProc));
    ERRCHECK;

    sprintf (res, "72 %d div 72 %d div scale\n", thePrintContext->EffectiveResolutionX (),
             thePrintContext->EffectiveResolutionY ());
    thePrinter->Send ((const BYTE *) res, strlen (res));
    ERRCHECK;

    sprintf (res, "%0.3f in %2.3f in tr\n180 rotate\n", thePrintContext->PrintableStartX (),
             thePrintContext->PhysicalPageSizeY () - thePrintContext->PrintableStartY ());
    thePrinter->Send ((const BYTE *) res, strlen (res));
    ERRCHECK;

//    strcpy (res, "/DeviceRGB setcolorspace\n");
//    err = thePrinter->Send ((const BYTE *) res, strlen (res));

//    CAPy = (int) (thePrintContext->EffectiveResolutionY () * thePrintContext->PrintableStartY ());

    return err;
}

DRIVER_ERROR HeaderPScript::FormFeed ()
{
//    return (thePrinter->Send ((const BYTE *) "newpage\n", 8));
    DRIVER_ERROR    err;
    err = ((PScript *) thePrinter)->SendText (CAPy);
    ((PScript *) thePrinter)->FreeList ();
    err = thePrinter->Flush (0);
    CAPy = 0;
    return err;
//  return NO_ERROR;
}

DRIVER_ERROR HeaderPScript::EndJob()
{
//    return (thePrinter->Send ((const BYTE *) "showpage\n", 9));
    thePrinter->Send ((const BYTE *) "\x1B%-12345X@PJL EOJ\x0A\x1B%-12345X", 27);
    return NO_ERROR;
}

DRIVER_ERROR HeaderPScript::SendCAPy (unsigned int iAbsY)
{
    DRIVER_ERROR    err = NO_ERROR;
    char    cOut[32];
    sprintf (cOut, "0 %d tr\n", iAbsY - CAPy);
    if (CAPy == 0)
    {
        err = thePrinter->Send ((const BYTE *) cOut, strlen (cOut));
        CAPy = iAbsY;
	return err;
    }
    CAPy = iAbsY;
    return NO_ERROR;
}

DRIVER_ERROR PScript::SkipRasters (int nBlankLines)
{
    memset (m_pbyInputRaster, 0xFF, m_iRowWidth);
    for (int i = 0; i < nBlankLines; i++)
    {
	m_iRowNumber++;
	JpegRaster ();
    }
    return NO_ERROR;
}

DRIVER_ERROR PScript::Flush (int iFlushSize)
{
    if (m_iRowNumber > 0 && iFlushSize == 0)
    {
        SendImage ();
        Send ((const BYTE *) "showpage\ngrestore\n", 18);
        StartJpegCompression ();
    }
    return NO_ERROR;
}

Header* PScript::SelectHeader (PrintContext* pc)
{
    m_pPC = pc;

    m_iRowNumber = 0;
    m_iJpegBufferSize = PS_BUFFER_CHUNK_SIZE;
    m_iRowWidth = int (pc->PrintableWidth () * pc->EffectiveResolutionX ());
    if (m_iRowWidth % 4)
        m_iRowWidth = m_iRowWidth / 4 + 4;
    m_iRowWidth *= 3;
    m_pbyInputRaster = (BYTE *) pSS->AllocMem (m_iRowWidth);
    m_pbyJpegBuffer = (BYTE *) pSS->AllocMem (m_iJpegBufferSize + 4);
    if (m_pbyJpegBuffer == NULL || m_pbyInputRaster == NULL)
    {
        constructor_error = ALLOCMEM_ERROR;
        return NULL;
    }
    MEDIATYPE    eM;
    QUALITY_MODE eQ;
    BOOL         bT;
    m_eColorMode = COLOR;
    pc->GetPrintModeSettings (eQ, eM, m_eColorMode, bT);
    StartJpegCompression ();
    return new HeaderPScript (this, pc);
}

DRIVER_ERROR PScript::VerifyPenInfo()
{

    DRIVER_ERROR err = NO_ERROR;

    if(IOMode.bDevID == FALSE)
    {
        return err;
    }

    ePen = BOTH_PENS;
    return NO_ERROR;
}

DRIVER_ERROR PScript::ParsePenInfo(PEN_TYPE& ePen, BOOL QueryPrinter)
{
    ePen = BOTH_PENS;

    return NO_ERROR;
}

DRIVER_ERROR PScript::SaveText (const char *psStr, int iPointSize, int iX, int iY,
                                const char *pTextString, int iTextStringLen,
                                BOOL bUnderline)
{
    DRIVER_ERROR    err = NO_ERROR;
    int     iLen = strlen (psStr) + iTextStringLen + 64;
    char    *p;
    StrList *pSL = NULL;
    const char    *pShowOp = (bUnderline) ? "ul" : "sh";
    iPointSize = (iPointSize * m_pPC->EffectiveResolutionY ()) / 72;
    pSL = (StrList *) pSS->AllocMem (sizeof (StrList));
    if (pSL == NULL)
    {
        return ALLOCMEM_ERROR;
    }
    p =  (char *) pSS->AllocMem (iLen);
    if (p == NULL)
    {
        pSS->FreeMem ((BYTE *) pSL);
        return ALLOCMEM_ERROR;
    }
    sprintf (p, "%s %d scf sf\r\n%d -%d mv\r\n(%s) %s\r\n",
             psStr, iPointSize, iX, iY, pTextString, pShowOp);
    pSL->pPSString = p;
    if (m_pHeadPtr == NULL)
    {
        m_pHeadPtr = pSL;
        m_pCurItem = m_pHeadPtr;
    }
    else
    {
        m_pCurItem->next = pSL;
        m_pCurItem = m_pCurItem->next;
    }
    m_pCurItem->next = NULL;
    return err;
}

DRIVER_ERROR PScript::SendText (int iCurYPos)
{
    DRIVER_ERROR    err;
    char    psStr[128];
    StrList *p = m_pHeadPtr;
    if (m_pHeadPtr == NULL)
    {
        return NO_ERROR;
    }
    sprintf (psStr, "sv\r\n0 -%d tr\r\n180 ro\r\n", iCurYPos);

    err = Send ((const BYTE *) psStr, strlen (psStr));
    while (p)
    {
        err = Send ((const BYTE *) p->pPSString, strlen (p->pPSString));
        ERRCHECK;
        p = p->next;
    }
    err = Send ((const BYTE *) "re\r\n", 4);
    return err;
}

DRIVER_ERROR PScript::Encapsulate (const RASTERDATA* InputRaster, BOOL bLastPlane)
{
    DRIVER_ERROR    err = NO_ERROR;
    m_iRowNumber++;
    AddRaster (InputRaster->rasterdata[COLORTYPE_COLOR], InputRaster->rastersize[COLORTYPE_COLOR]);

    return err;
}

DRIVER_ERROR PScript::SendImage ()
{
    DRIVER_ERROR    err;
    BYTE    cOut[512];
    int     iEncodedBufferSize;
    FinishJpegCompression ();
    iEncodedBufferSize = EncodeJpeg ();
    if (iEncodedBufferSize == -1)
    {
        return ALLOCMEM_ERROR;
    }
    err = Send ((const BYTE *) "/DeviceRGB setcolorspace\n", 25);
    sprintf ((char *) cOut, "gsave\n<<\n/ImageType 1\n/Width %d\n/Height %d\n/BitsPerComponent 8\n \
/ImageMatrix [-1 0 0 1 0 0]\n/DataSource currentfile /ASCII85Decode filter /DCTDecode filter\n \
/MultipleDataSources false\n/Decode [0 1 0 1 0 1]\n>>\nimage\n", m_iRowWidth/3, m_cinfo.image_height);
    err = Send ((const BYTE *) cOut, strlen ((char *) cOut));

    err = Send (m_pbyEncodedBuffer, iEncodedBufferSize);
    err = Send ((const BYTE *) "\015\012~>\015\012\n", 7);
    pSS->FreeMem (m_pbyEncodedBuffer);
    m_pbyEncodedBuffer = NULL;
    m_iRowNumber = 0;
    m_iJpegBufferPos = 0;
    return err;
}

int  PScript::EncodeJpeg ()
{
    BYTE    *jpg;
    int     irem = m_iJpegBufferPos % 4;
    unsigned long   lval;
    int     i, k = m_iJpegBufferPos - irem;
    unsigned long   l84x2 = 7225;
    unsigned long   l84x3 = 614125;
    unsigned long   l84x4 = 52200625;
    int      l = 0;
    int      size = ((m_iJpegBufferPos * 5) / 4) + 64;

    m_pbyEncodedBuffer = (BYTE *) pSS->AllocMem (size);
    if (m_pbyEncodedBuffer == NULL)
    {
        return -1;
    }
    jpg = m_pbyJpegBuffer;
    memset (m_pbyEncodedBuffer, 0, size);
    for (i = 0; i < k; i += 4, jpg += 4)
    {
        lval = ((unsigned long) (jpg[0])) << 24 |
               ((unsigned long) (jpg[1])) << 16 |
               ((unsigned long) (jpg[2])) << 8  |
               (unsigned long) jpg[3];
        if (lval == 0)
        {
            m_pbyEncodedBuffer[l++] = 'z';
        }
        else
        {
            m_pbyEncodedBuffer[l++] = (char) (lval / l84x4 + 33); lval = lval % l84x4;
            m_pbyEncodedBuffer[l++] = (char) (lval / l84x3 + 33); lval = lval % l84x3;
            m_pbyEncodedBuffer[l++] = (char) (lval / l84x2 + 33); lval = lval % l84x2;
            m_pbyEncodedBuffer[l++] = (char) (lval / 85    + 33); lval = lval % 85;
            m_pbyEncodedBuffer[l++] = (char) (lval + 33);
        }
    }
    if (irem != 0)
    {
        lval = 0;
        for (i = 0; i < irem; i++)
        {
            lval |= (unsigned long) (jpg[i]) << (24 - i * 8);
        }
        m_pbyEncodedBuffer[l++] = (char) (lval / l84x4 + 33); lval = lval % l84x4;
        m_pbyEncodedBuffer[l++] = (char) (lval / l84x3 + 33); lval = lval % l84x3;
        m_pbyEncodedBuffer[l++] = (char) (lval / l84x2 + 33); lval = lval % l84x2;
        m_pbyEncodedBuffer[l++] = (char) (lval / 85    + 33); lval = lval % 85;
        m_pbyEncodedBuffer[l++] = (char) (lval + 33);
    }
    return l;
}

void HPPScript_flush_output_buffer_callback (JOCTET *outbuf, BYTE *buffer, int size)
{
    PScript    *pPS = (PScript *) outbuf;
    pPS->JpegData (buffer, size);
}

void PScript::JpegData (BYTE *buffer, int iSize)
{
    if ((m_iJpegBufferPos + iSize) > m_iJpegBufferSize)
    {
        BYTE    *p = pSS->AllocMem (m_iJpegBufferSize + PS_BUFFER_CHUNK_SIZE + 4);
        if (p == NULL)
        {
            return;
        }
        memcpy (p, m_pbyJpegBuffer, m_iJpegBufferPos);
        pSS->FreeMem (m_pbyJpegBuffer);
        m_pbyJpegBuffer = p;
        m_iJpegBufferSize += PS_BUFFER_CHUNK_SIZE;
    }
    memcpy (m_pbyJpegBuffer + m_iJpegBufferPos, buffer, iSize);
    m_iJpegBufferPos += iSize;
}

//----------------------------------------------------------------
// These are "overrides" to the JPEG library error routines
//----------------------------------------------------------------

void HPPScript_error (j_common_ptr cinfo)
{

}

extern "C"
{
void jpeg_buffer_dest (j_compress_ptr cinfo, JOCTET* outbuff, void* flush_output_buffer_callback);
void hp_rgb_ycc_setup (int iFlag);
}

DRIVER_ERROR  PScript::StartJpegCompression () 
{

//  Use the standard RGB to YCC table rather than the modified one for JetReady

    m_iPageNumber++;

    hp_rgb_ycc_setup (0);
    m_iJpegBufferPos = 0;
    memset (m_pbyJpegBuffer, 0xFF, m_iJpegBufferSize);

    m_cinfo.err = jpeg_std_error (&m_jerr);
    m_jerr.error_exit = HPPScript_error;
    if (setjmp (m_setjmp_buffer))
    {
        jpeg_destroy_compress (&m_cinfo);
        return SYSTEM_ERROR;
    }

    jpeg_create_compress (&m_cinfo);
    m_cinfo.in_color_space = JCS_RGB;
    jpeg_set_defaults (&m_cinfo);
    m_cinfo.image_width = m_iRowWidth / 3;
    m_cinfo.image_height = (int) (m_pPC->PrintableHeight () * m_pPC->EffectiveResolutionY ());
    m_cinfo.input_components = 3;
    m_cinfo.data_precision = 8;
    jpeg_buffer_dest (&m_cinfo, (JOCTET *) this, (void *) (HPPScript_flush_output_buffer_callback));
    jpeg_start_compress (&m_cinfo, TRUE);
    return NO_ERROR;
}

#define ConvertToGrayMacro(red, green, blue) \
        ((unsigned char) (((red * 30) + (green * 59) + (blue * 11) ) / 100))

void PScript::AddRaster (BYTE *pbyRow, int iLength)
{

    if (m_iRowNumber > m_cinfo.image_height)
    {
        return;
    }
    memset (m_pbyInputRaster, 0xFF, m_iRowWidth);
    if (m_eColorMode != COLOR)
    {
        BYTE *p = m_pbyInputRaster;
        BYTE tmp;
        for (int i = 0; i < iLength; i += 3)
        {
            tmp = ConvertToGrayMacro (*pbyRow, *(pbyRow + 1), *(pbyRow + 2));
            *p++ = tmp;
            *p++ = tmp;
            *p++ = tmp;
            pbyRow += 3;
        }
    }
    else
    {
        memcpy (m_pbyInputRaster, pbyRow, iLength);
    }
    JpegRaster ();
}

void PScript::JpegRaster ()
{
    JSAMPROW    pRowArray[1];
    pRowArray[0] = (JSAMPROW) m_pbyInputRaster;
    jpeg_write_scanlines (&m_cinfo, pRowArray, 1);
}

void PScript::FinishJpegCompression ()
{
    JSAMPROW    pRowArray[1];
    pRowArray[0] = (JSAMPROW) m_pbyInputRaster;

    m_cinfo.image_height = m_iRowNumber;
    jpeg_finish_compress (&m_cinfo);
    jpeg_destroy_compress (&m_cinfo);
}

/*
 *  Function name: ParseError
 *
 *  Owner: Darrell Walker
 *
 *  Purpose:  To determine what error state the printer is in.
 *
 *  Called by: Send()
 *
 *  Parameters on entry: status_reg is the contents of the centronics
 *                      status register (at the time the error was
 *                      detected)
 *
 *  Parameters on exit: unchanged
 *
 *  Return Values: The proper DISPLAY_STATUS to reflect the printer
 *              error state.
 *
 */

/*  We have to override the base class's (Printer) ParseError function due
    to the fact that the 8XX series returns a status byte of F8 when it's out of
    paper.  Unfortunately, the 600 series returns F8 when they're turned off.
    The way things are structured in Printer::ParseError, we used to check only
    for DEVICE_IS_OOP.  This would return true even if we were connected to a
    600 series printer that was turned off, causing the Out of paper status
    message to be displayed.  This change also reflects a corresponding change
    in IO_defs.h, where I split DEVICE_IS_OOP into DEVICE_IS_OOP, DJ400_IS_OOP, and
    DJ8XX_IS_OOP and we now check for DJ8XX_IS_OOP in the DJ8xx class's
    ParseError function below.  05/11/99 DGC.
*/

DISPLAY_STATUS PScript::ParseError(BYTE status_reg)
{
    DBG1("PScript: parsing error info\n");

    DRIVER_ERROR err = NO_ERROR;
    BYTE DevIDBuffer[DevIDBuffSize];

    if(IOMode.bDevID)
    {
        // If a bi-di cable was plugged in and everything was OK, let's see if it's still
        // plugged in and everything is OK
        err = pSS->GetDeviceID(DevIDBuffer, DevIDBuffSize, TRUE);
        if(err != NO_ERROR)
            // job was bi-di but now something's messed up, probably cable unplugged
            return DISPLAY_COMM_PROBLEM;

        if ( TopCoverOpen(status_reg) )
        {
            DBG1("Top Cover Open\n");
            return DISPLAY_TOP_COVER_OPEN;
        }

        // VerifyPenInfo will handle prompting the user
        // if this is a problem
        err = VerifyPenInfo();

        if(err != NO_ERROR)
            // VerifyPenInfo returned an error, which can only happen when ToDevice
            // or GetDeviceID returns an error. Either way, it's BAD_DEVICE_ID or
            // IO_ERROR, both unrecoverable.  This is probably due to the printer
            // being turned off during printing, resulting in us not being able to
            // power it back on in VerifyPenInfo, since the buffer still has a
            // partial raster in it and we can't send the power-on command.
            return DISPLAY_COMM_PROBLEM;
    }

    // check for errors we can detect from the status reg
    if (IOMode.bStatus)
    {
        if ( DEVICE_IS_OOP(status_reg) )
        {
            DBG1("Out Of Paper\n");
            return DISPLAY_OUT_OF_PAPER;
        }

        if (DEVICE_PAPER_JAMMED(status_reg))
        {
            DBG1("Paper Jammed\n");
            return DISPLAY_PAPER_JAMMED;
        }
    }

    // don't know what the problem is-
    //  Is the PrinterAlive?
    if (pSS->PrinterIsAlive())
    {
        iTotal_SLOW_POLL_Count += iMax_SLOW_POLL_Count;
#if defined(DEBUG) && (DBG_MASK & DBG_LVL1)
        printf("iTotal_SLOW_POLL_Count = %d\n",iTotal_SLOW_POLL_Count);
#endif
        // -Note that iTotal_SLOW_POLL_Count is a multiple of
        //  iMax_SLOW_POLL_Count allowing us to check this
        //  on an absolute time limit - not relative to the number
        //  of times we happen to have entered ParseError.
        // -Also note that we have different thresholds for uni-di & bi-di.
        if(
            ((IOMode.bDevID == FALSE) && (iTotal_SLOW_POLL_Count >= 60)) ||
            ((IOMode.bDevID == TRUE)  && (iTotal_SLOW_POLL_Count >= 120))
          )
        {
            return DISPLAY_BUSY;
        }
        else
        {
            return DISPLAY_PRINTING;
        }
    }
    else
    {
        return DISPLAY_COMM_PROBLEM;
    }
}

APDK_END_NAMESPACE

#endif  // defined APDK_PSCRIPT


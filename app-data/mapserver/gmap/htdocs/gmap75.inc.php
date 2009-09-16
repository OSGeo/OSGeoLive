<?php

/**********************************************************************
 * $Id: gmap75.inc.php,v 1.1 2003/07/23 02:22:10 daniel Exp $
 **********************************************************************
 * Copyright (c) 2000-2002, DM Solutions Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 **********************************************************************/

/************************************************************************/
/*                  GMap mapping engine (PHP version)                   */
/*                                                                      */
/*        This is the main script of the PHP version of the GMap        */
/*        map navigation engine.  It should be loaded inside an HTML    */
/*        page using the PHP include() command.                         */
/*                                                                      */
/************************************************************************/

/* ==================================================================== */
/*      HTTP_FORM_VARS array contains the HTTP GET or POST parameters.  */
/* ==================================================================== */

if (sizeof($HTTP_POST_VARS) > 0)
  $HTTP_FORM_VARS = $HTTP_POST_VARS;
else if (sizeof($HTTP_GET_VARS) > 0)
  $HTTP_FORM_VARS = $HTTP_GET_VARS;
else
  $HTTP_FORM_VARS = array("");


/* ==================================================================== */
/* Find out whether GIF is supported... if not falback on PNG/JPG       */
/* ==================================================================== */
if (strpos( ms_GetVersion(), "OUTPUT=GIF") > 0 )
{
  $gAppletImgFmt = MS_GIF;
  $gImagesFmt = MS_GIF;
}
else
{ 
  $gAppletImgFmt = MS_JPEG;
  $gImagesFmt = MS_PNG;
}

/************************************************************************/
/*                     function GMap75CheckClick()                      */
/*                                                                      */
/*      Function to set the status ON/OFF of a layer according to       */
/*      htrtp parameters passed. (paremeters are here equal to the      */
/*      layer name).                                                    */
/************************************************************************/
function GMap75CheckClick()
{
    GLOBAL      $HTTP_FORM_VARS;
    GLOBAL      $gpoMap, $gbShowQueryResults, $gszZoomBoxExt;
    GLOBAL      $dfMapExtMinX;
    GLOBAL      $dfMapExtMinY;
    GLOBAL      $dfMapExtMaxX;
    GLOBAL      $dfMapExtMaxY;
    
    GLOBAL      $dfMaxExtMinX;
    GLOBAL      $dfMaxExtMinY;
    GLOBAL      $dfMaxExtMaxX;
    GLOBAL      $dfMaxExtMaxY;
    
    reset( $HTTP_FORM_VARS );

//    while ( list( $key, $val ) = each( $HTTP_FORM_VARS ) ) 
//    {
//        printf("%s=%s<BR>\n", $key, $val);
//    }

/* -------------------------------------------------------------------- */
/*      look for all layers set to on/off                               */
/* -------------------------------------------------------------------- */
    if (sizeof($HTTP_FORM_VARS) >= 2)
    {
        $poLayer = $gpoMap->getlayerbyname(road);	
        if ($HTTP_FORM_VARS["road"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

         $poLayer = $gpoMap->getlayerbyname(rail);	
        if ($HTTP_FORM_VARS["rail"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(drainage);	
        if ($HTTP_FORM_VARS["drainage"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(drain_fn);	
        if ($HTTP_FORM_VARS["drain_fn"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(park);	
        if ($HTTP_FORM_VARS["park"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

	$poLayer = $gpoMap->getlayerbyname("bathymetry");	
        if ($HTTP_FORM_VARS["bathymetry"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(popplace);	
        if ($HTTP_FORM_VARS["popplace"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(prov_bound);	
        if ($HTTP_FORM_VARS["prov_bound"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);


        $poLayer = $gpoMap->getlayerbyname(fedlimit);	
        if ($HTTP_FORM_VARS["fedlimit"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(land_fn);	
        if ($HTTP_FORM_VARS["land_fn"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);

        $poLayer = $gpoMap->getlayerbyname(grid);	
        if ($HTTP_FORM_VARS["grid"])
            $poLayer->set("status", 1);
        else
            $poLayer->set("status", 0);
    }

/* -------------------------------------------------------------------- */
/*      these are the extents of waht is seen actually, they are        */
/*      generated in function GMapRedraw().                             */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["minx"])
    {
        $dfMinX = doubleval($HTTP_FORM_VARS["minx"]);
        $dfMinY = doubleval($HTTP_FORM_VARS["miny"]);
        $dfMaxX = doubleval($HTTP_FORM_VARS["maxx"]); 
        $dfMaxY = doubleval($HTTP_FORM_VARS["maxy"]);
//        printf("minx\n");
        
    }
    else
    {
        $dfMinX = $gpoMap->extent->minx;
        $dfMinY = $gpoMap->extent->miny;
        $dfMaxX = $gpoMap->extent->maxx;
        $dfMaxY = $gpoMap->extent->maxy;
    }

/* -------------------------------------------------------------------- */
/*      check for image width, hight changes.                           */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["MapSize"])
    {
        if (ereg("([0-9]+),([0-9]+)",
                 $HTTP_FORM_VARS["MapSize"], $MapSizeExtents))
        {
            $dfWidthPix = intval($MapSizeExtents[1]);
            $dfHeightPix = intval($MapSizeExtents[2]);
 
            $gpoMap->set("width",$dfWidthPix);
            $gpoMap->set("height",$dfHeightPix);
            
            SetMapExtents($dfMinX, $dfMinY, $dfMaxX, $dfMaxY);
        }
    }
  
/* -------------------------------------------------------------------- */
/*      check if the key map has been cliked.                           */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["KEYMAP_x"])
    {
/* -------------------------------------------------------------------- */
/*      initilalize the georef extents of the key map.                  */
/* -------------------------------------------------------------------- */
        $dfKeyMapXMin = $gpoMap->reference->extent->minx;
        $dfKeyMapYMin = $gpoMap->reference->extent->miny;
        $dfKeyMapXMax = $gpoMap->reference->extent->maxx;
        $dfKeyMapYMax = $gpoMap->reference->extent->maxy;
    
//        printf("dfkeyxmin %f<BR>\n",$dfKeyMapXMin);
//        printf("dfkeyymin %f<BR>\n",$dfKeyMapYMin);
//        printf("dfkeyxmax %f<BR>\n",$dfKeyMapXMax);
//        printf("dfkeyymax %f<BR>\n",$dfKeyMapYMax);

        $nClickPixX = intval($HTTP_FORM_VARS[KEYMAP_x]);
        $nClickPixY = intval($HTTP_FORM_VARS[KEYMAP_y]);
        
        $dfWidthPix = doubleval($HTTP_FORM_VARS[KEYMAPXSIZE]);
        $dfHeightPix = doubleval($HTTP_FORM_VARS[KEYMAPYSIZE]);
        
        $nClickGeoX = GMapPix2Geo($nClickPixX, 0, $dfWidthPix, $dfKeyMapXMin, 
                                   $dfKeyMapXMax, 0);
        $nClickGeoY = GMapPix2Geo($nClickPixY, 0, $dfHeightPix, $dfKeyMapYMin, 
                                  $dfKeyMapYMax, 1);

        $dfDeltaX = $dfMaxX - $dfMinX;
        $dfDeltaY = $dfMaxY - $dfMinY;
        $dfMiddleX = $nClickGeoX; 
        $dfMiddleY = $nClickGeoY;

        $dfNewMinX = $dfMiddleX - ($dfDeltaX/2);
        $dfNewMinY = $dfMiddleY - ($dfDeltaY/2);
        $dfNewMaxX = $dfMiddleX + ($dfDeltaX/2);
        $dfNewMaxY = $dfMiddleY + ($dfDeltaY/2);

/* -------------------------------------------------------------------- */
/*      not go outside the borders.                                     */
/* -------------------------------------------------------------------- */
        if ($dfNewMinX < $dfMaxExtMinX)
        {
            $dfNewMinX = $dfMaxExtMinX;
            $dfNewMaxX = $dfNewMinX + ($dfDeltaX);
        }

        if ($dfNewMaxX > $dfMaxExtMaxX)
        {
            $dfNewMaxX = $dfMaxExtMaxX;
            $dfNewMinX = $dfNewMaxX - ($dfDeltaX);
        }
        if ($dfNewMinY < $dfMaxExtMinY)
        {
            $dfNewMinY = $dfMaxExtMinY;
            $dfNewMaxY = $dfNewMinY + ($dfDeltaY);
        }
        if ($dfNewMaxY > $dfMaxExtMaxY)
        {
            $dfNewMaxY = $dfMaxExtMaxY;
            $dfNewMinY = $dfNewMaxY - ($dfDeltaY);
        }
        
        SetMapExtents($dfNewMinX, $dfNewMinY, $dfNewMaxX, $dfNewMaxY);

//      return;
    }
  
/* -------------------------------------------------------------------- */
/*      province selection.                                             */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["ViewRegion"])
    {
        if (ereg("(-?[0-9]+),(-?[0-9]+),(-?[0-9]+),(-?[0-9]+)",
                 $HTTP_FORM_VARS["ViewRegion"], $ProvExtents))
        {
            $dfMinX = doubleval($ProvExtents[1]);
            $dfMinY = doubleval($ProvExtents[2]);
            $dfMaxX = doubleval($ProvExtents[3]);
            $dfMaxY = doubleval($ProvExtents[4]);

            SetMapExtents($dfMinX, $dfMinY, $dfMaxX, $dfMaxY);
        }
    }

/* -------------------------------------------------------------------- */
/*      extract the current width and height.                           */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["imagewidth"])
    {
        $dfWidthPix = intval($HTTP_FORM_VARS["imagewidth"]);
        $dfHeightPix = intval($HTTP_FORM_VARS["imageheight"]);
    }
    else
    {
        $dfWidthPix  = $gpoMap->width;
        $dfHeightPix = $gpoMap->height;
    }


    
/* -------------------------------------------------------------------- */
/*      check if it the redraw button which is pressed : if it is       */
/*      the case redraw the same extents.                               */
/* -------------------------------------------------------------------- */
    if ($HTTP_FORM_VARS["redraw_x"])
    {
        SetMapExtents($dfMinX, $dfMinY, $dfMaxX, $dfMaxY);
    }
/* -------------------------------------------------------------------- */
/*      Check for zoom out (auto-submit) button.                        */
/* -------------------------------------------------------------------- */
    else if ($HTTP_FORM_VARS["CMD"] == "ZOOM_OUT" && 
             !($HTTP_FORM_VARS["mainmap_x"] || $HTTP_FORM_VARS["INPUT_COORD"]))
    {
        $oPixelPos = ms_newpointobj();
        $oGeorefExt = ms_newrectobj();
        $oGeorefMaxExt = ms_newrectobj();

        $oPixelPos->setxy($dfWidthPix/2.0, $dfHeightPix/2.0);
        $oGeorefExt->setextent($dfMinX, $dfMinY, $dfMaxX, $dfMaxY);
        $oGeorefMaxExt->setextent($dfMaxExtMinX, $dfMaxExtMinY,
                                  $dfMaxExtMaxX, $dfMaxExtMaxY);

        if (!$gpoMap->zoompoint(-2, $oPixelPos, $dfWidthPix, $dfHeightPix,
                                $oGeorefExt, $oGeorefMaxExt))
        {
            $gpoMap->setExtent($dfMapExtMinX, $dfMapExtMinY, 
                               $dfMapExtMaxX, $dfMapExtMaxY);
        }
    }
/* -------------------------------------------------------------------- */
/*      check for zoom / query through applet or image click            */
/* -------------------------------------------------------------------- */
    else
    {
        $dfDeltaX = $dfMaxX - $dfMinX;
        $dfDeltaY = $dfMaxY - $dfMinY;
	
/* -------------------------------------------------------------------- */
/*      extract click position.                                         */
/*      Convert the click pos to georeref coordinates.                  */
/* -------------------------------------------------------------------- */
        if ($HTTP_FORM_VARS["mainmap_x"] || $HTTP_FORM_VARS["INPUT_TYPE"])
        {
	    $bRectangleInput = 0;
	    if ($HTTP_FORM_VARS["INPUT_TYPE"])
	    {
		$szCoord = strval($HTTP_FORM_VARS["INPUT_COORD"]);
		$szCoordType = strval($HTTP_FORM_VARS["INPUT_TYPE"]);
		if (strcmp($szCoordType,"auto_point") == 0)
		{
		    $szCoordArray =explode(",", $szCoord);
		    $nClickPixX = $szCoordArray[0];
		    $nClickPixY = $szCoordArray[1];
		}
/* -------------------------------------------------------------------- */
/*      Rosa applet is used and the input is a rectangle                */
/*      (syntax is X1,Y1;X2,Y2).                                        */
/*      If the 2 sets of points are the same treat the case as a        */
/*      point click.                                                    */
/* -------------------------------------------------------------------- */
		else if (strcmp($szCoordType,"auto_rect") == 0)
		{
		    $bRectangleInput = 1;

		    $szFirstSetXY = strtok($szCoord, ";");
		    $szSecondSetXY = strtok("\n");
		    
		    $szFirstCoord = explode(",", $szFirstSetXY);
		    $szSecondCoord = explode(",", $szSecondSetXY);
		    
		    $oPixelRect = ms_newrectobj();
		    
			
		    $oPixelRect->setextent($szFirstCoord[0],  $szFirstCoord[1],
					   $szSecondCoord[0], $szSecondCoord[1]);

                    if ($oPixelRect->minx ==  $oPixelRect->maxx &&
			$oPixelRect->miny ==  $oPixelRect->maxy)
		    {
			$bRectangleInput = 0;
			$nClickPixX = $oPixelRect->minx;
			$nClickPixY = $oPixelRect->miny;
		    }
		    else
		    {
			if ($oPixelRect->minx >  $oPixelRect->maxx)
			{
                            // Use *1 to avoid dfTmp becoming a reference
                            // to $oPixelRect->minx with PHP4 !?!?!?
			    $dfTmp = $oPixelRect->minx*1;
			    $oPixelRect->set("minx",$oPixelRect->maxx);
			    $oPixelRect->set("maxx",$dfTmp);
			}
			if ($oPixelRect->miny <  $oPixelRect->maxy)
			{
			    $dfTmp = $oPixelRect->miny*1;
			    $oPixelRect->set("miny", $oPixelRect->maxy);
			    $oPixelRect->set("maxy", $dfTmp);
			}
		    }

                    // We'll insert a copy of the box's georef extent in a
                    // comment in the HTML output... useful for defining views.
		    $gszZoomBoxExt = sprintf("<!-- BOX= (%f, %f)-(%f, %f) -->",
                                             GMapPix2Geo($oPixelRect->minx, 0, 
                                                         $dfWidthPix, $dfMinX, 
                                                         $dfMaxX, 0),
                                             GMapPix2Geo($oPixelRect->miny, 0, 
                                                         $dfHeightPix, $dfMinY,
                                                         $dfMaxY, 1),
                                             GMapPix2Geo($oPixelRect->maxx, 0, 
                                                         $dfWidthPix, $dfMinX, 
                                                         $dfMaxX, 0),
                                             GMapPix2Geo($oPixelRect->maxy, 0, 
                                                         $dfHeightPix, $dfMinY,
                                                         $dfMaxY, 1) );
		}
	    }   
	    else
	    {
		$nClickPixX = intval($HTTP_FORM_VARS[mainmap_x]);
		$nClickPixY = intval($HTTP_FORM_VARS[mainmap_y]);
	    }
            
	    
	    $oPixelPos = ms_newpointobj();
	    $oGeorefExt = ms_newrectobj();
	    $oGeorefMaxExt = ms_newrectobj();

	    $oPixelPos->setxy($nClickPixX, $nClickPixY);
	    $oGeorefExt->setextent($dfMinX, $dfMinY, $dfMaxX, $dfMaxY);
	    $oGeorefMaxExt->setextent($dfMaxExtMinX, $dfMaxExtMinY,
				      $dfMaxExtMaxX, $dfMaxExtMaxY);

            if ($HTTP_FORM_VARS["CMD"] == "ZOOM_IN")
            {
		if ($bRectangleInput)
		{
		    $gpoMap->zoomrectangle($oPixelRect, $dfWidthPix, 
					   $dfHeightPix, $oGeorefExt);
		}
		else
		    $gpoMap->zoompoint(2, $oPixelPos, $dfWidthPix, 
				       $dfHeightPix, $oGeorefExt, $oGeorefMaxExt);
            }
            if ($HTTP_FORM_VARS["CMD"] == "ZOOM_OUT")
            {
		if (!$gpoMap->zoompoint(-2, $oPixelPos, $dfWidthPix, 
					$dfHeightPix, $oGeorefExt, 
					$oGeorefMaxExt))
		{
		    $gpoMap->setExtent($dfMapExtMinX, $dfMapExtMinY, 
		    		       $dfMapExtMaxX, $dfMapExtMaxY);
		}
	    }
            if ($HTTP_FORM_VARS["CMD"] == "RECENTER")
            {
		$gpoMap->zoompoint(1, $oPixelPos, $dfWidthPix, 
				   $dfHeightPix, $oGeorefExt, 
				   $oGeorefMaxExt);
            }
            else if ($HTTP_FORM_VARS["CMD"] == "QUERY_POINT")
            {
/* -------------------------------------------------------------------- */
/*      Query selected layers at point location or in a rectangle.      */
/*      DumpQueryResults() will be called later to display the          */
/*      results.                                                        */
/* -------------------------------------------------------------------- */
		if ($bRectangleInput)
		{	
		    $oGeorefRect = ms_newrectobj();
		    $oGeorefRect->set("minx", GMapPix2Geo($oPixelRect->minx, 0, 
							  $dfWidthPix, $dfMinX, 
							  $dfMaxX, 0));
		    $oGeorefRect->set("maxx", GMapPix2Geo($oPixelRect->maxx, 0, 
							  $dfWidthPix, $dfMinX, 
							  $dfMaxX, 0));
		    $oGeorefRect->set("miny", GMapPix2Geo($oPixelRect->miny, 0, 
							  $dfHeightPix, $dfMinY, 
							  $dfMaxY, 1));
		    $oGeorefRect->set("maxy", GMapPix2Geo($oPixelRect->maxy, 0, 
							  $dfHeightPix, $dfMinY, 
							  $dfMaxY, 1));
                    // Use '@' to avoid warning if query found nothing
		    @$gpoMap->queryByRect($oGeorefRect);
                    $gbShowQueryResults = TRUE;
		}
		else
		{
		    $nClickGeoX = GMapPix2Geo($nClickPixX, 0, $dfWidthPix, 
					      $dfMinX, $dfMaxX, 0);
		    $nClickGeoY = GMapPix2Geo($nClickPixY, 0, $dfHeightPix, 
					      $dfMinY, $dfMaxY, 1);
		
		    $oClickGeo = ms_newPointObj();
		    $oClickGeo->setXY($nClickGeoX, $nClickGeoY);

                    // Use '@' to avoid warning if query found nothing
		    @$gpoMap->queryByPoint($oClickGeo, MS_SINGLE, -1);

                    $gbShowQueryResults = TRUE;
		}
            }
        }
    } 
}		
			
/************************************************************************/
/*                   fuction GMapGetStatus($szLayerName)                */
/*                                                                      */
/*      return if the layer is on or off (displayed or not) :           */
/*                                                                      */
/*       ON = MS_ON =1                                                  */
/*       OFF = MS_OFF = 0                                               */
/*                                                                      */
/************************************************************************/
function GMapGetStatus($szLayerName)
{
  GLOBAL $gpoMap;
  
  $poLayer = $gpoMap->getlayerbyname($szLayerName);
  $nStatus = $poLayer->status;

   return ($nStatus);

}
			

/************************************************************************/
/*                        function GMapDrawMap()                        */
/*                                                                      */
/*      Funcion to draw the contains of the map.                        */
/************************************************************************/
function GMapDrawMap()
{
    GLOBAL $gpoMap, $gbShowQueryResults;
    GLOBAL $gbIsHtmlMode;
    GLOBAL $gszCommand, $gszZoomBoxExt;
    GLOBAL $gAppletImgFmt, $gImagesFmt;

    if ($gbShowQueryResults)
    {
        $img = $gpoMap->drawQuery();
    }
    else
        $img = $gpoMap->draw();

    $url = $img->saveWebImage($gAppletImgFmt, 0, 0, -1);

    echo "\n".$gszZoomBoxExt."\n";
    printf("<INPUT TYPE=HIDDEN NAME=minx VALUE=\"%f\">", $gpoMap->extent->minx);
    printf("<INPUT TYPE=HIDDEN NAME=miny VALUE=\"%f\">", $gpoMap->extent->miny);
    printf("<INPUT TYPE=HIDDEN NAME=maxx VALUE=\"%f\">", $gpoMap->extent->maxx);
    printf("<INPUT TYPE=HIDDEN NAME=maxy VALUE=\"%f\">", $gpoMap->extent->maxy);
	
    printf("<INPUT TYPE=HIDDEN NAME=imagewidth VALUE=\"%d\">", $gpoMap->width);
    printf("<INPUT TYPE=HIDDEN NAME=imageheight VALUE=\"%d\">", $gpoMap->height);

/* -------------------------------------------------------------------- */
/*      Use the command to update the rosa applet.                      */
/* -------------------------------------------------------------------- */
    if ( strlen($gszCommand) == 0)
    {
	$szButtonName = "zoomin";
    }
    else 
    {
	if ($gszCommand == "ZOOM_IN")
	    $szButtonName = "zoomin";
// Do not keep zoomout pressed ot avoid infinite zoomout loop!!!
//	if ($gszCommand == "ZOOM_OUT")
//	    $szButtonName = "zoomout";
	if ($gszCommand == "RECENTER")
	    $szButtonName = "recentre";
	if ($gszCommand == "QUERY_POINT")
	    $szButtonName = "pquery";
    }
    
    
    if (!$gbIsHtmlMode) //use applet
    {
	printf("\n");
	printf("<APPLET NAME=\"RosaApplet\" ARCHIVE=\"./rosa/rosa.jar\" CODE=\"Rosa2000\" WIDTH=\"%d\" HEIGHT=\"%d\" MAYSCRIPT>\n", $gpoMap->width, $gpoMap->height);
	printf("<PARAM NAME=\"TB_POSITION\" VALUE=\"right\">\n");
	printf("<PARAM NAME=\"TB_ALIGN\" VALUE=\"top\">");
	printf("<PARAM NAME=\"IMG_URL\" VALUE=\"%s\">",$url);
	printf("<PARAM NAME=\"INP_FORM_NAME\" VALUE=\"myform\">");
	printf("<PARAM NAME=\"TB_BUTTONS\" VALUE=\"zoomin|zoomout|recentre|pquery\">\n");
	printf("<PARAM NAME=\"INP_TYPE_NAME\" VALUE=\"INPUT_TYPE\">\n");
	printf("<PARAM NAME=\"INP_COORD_NAME\" VALUE=\"INPUT_COORD\">\n");

		    
	printf("<PARAM NAME=\"TB_SELECTED_BUTTON\" VALUE=\"%s\">",$szButtonName);

        printf("<PARAM NAME=\"TB_BUT_zoomin_IMG\" VALUE=\"./images/tool_zoomin_1.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_zoomin_IMG_PR\" VALUE=\"./images/tool_zoomin_2.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_zoomin_HINT\" VALUE=\"Zoom in: Click the button|and the map will zoom in\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomin_INPUT\" VALUE=\"auto_rect\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomin_NAME\" VALUE=\"CMD\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomin_VALUE\" VALUE=\"ZOOM_IN\">\n");
	
                      
        printf("<PARAM NAME=\"TB_BUT_zoomout_IMG\" VALUE=\"./images/tool_zoomout_1.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_zoomout_IMG_PR\" VALUE=\"./images/tool_zoomout_2.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_zoomout_HINT\" VALUE=\"Zoom out: Click the button|and the map will zoom out\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomout_INPUT\" VALUE=\"submit\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomout_NAME\" VALUE=\"CMD\">\n");
        printf("<PARAM NAME=\"TB_BUT_zoomout_VALUE\" VALUE=\"ZOOM_OUT\">\n");
                                                       
        printf("<PARAM NAME=\"TB_BUT_recentre_IMG\" VALUE=\"./images/tool_recentre_1.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_recentre_IMG_PR\" VALUE=\"./images/tool_recentre_2.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_recentre_HINT\" VALUE=\"Recenter: Click the button|and the map will recenter\">\n");
        printf("<PARAM NAME=\"TB_BUT_recentre_INPUT\" VALUE=\"auto_point\">\n");
        printf("<PARAM NAME=\"TB_BUT_recentre_NAME\" VALUE=\"CMD\">\n");
        printf("<PARAM NAME=\"TB_BUT_recentre_VALUE\" VALUE=\"RECENTER\">\n");

	printf("<PARAM NAME=\"TB_BUT_pquery_IMG\" VALUE=\"./images/tool_info_1.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_pquery_IMG_PR\" VALUE=\"./images/tool_info_2.gif\">\n");
	printf("<PARAM NAME=\"TB_BUT_pquery_HINT\" VALUE=\"Point Query: Click a point on the map|for information about that point\">\n");
        printf("<PARAM NAME=\"TB_BUT_pquery_INPUT\" VALUE=\"auto_rect\">\n");
        printf("<PARAM NAME=\"TB_BUT_pquery_NAME\" VALUE=\"CMD\">\n");
        printf("<PARAM NAME=\"TB_BUT_pquery_VALUE\" VALUE=\"QUERY_POINT\">\n");

	printf("</APPLET>");
	printf("<INPUT TYPE=\"HIDDEN\" NAME=\"CMD\" VALUE=\"\">");
	printf("<INPUT TYPE=\"HIDDEN\" NAME=\"INPUT_TYPE\" VALUE=\"\">");
	printf("<INPUT TYPE=\"HIDDEN\" NAME=\"INPUT_COORD\" VALUE=\"\">");
    }
    else
    {
	echo"<INPUT  TYPE=image SRC=$url  BORDER=0 WIDTH=$gpoMap->width HEIGHT=$gpoMap->height NAME=mainmap>";
	printf("<INPUT TYPE=\"HIDDEN\" NAME=\"CMD\" VALUE=\"%s\">", $gszCommand);
    }
//  printf("<IMG SRC=%s WIDTH=%d HEIGHT=%d>\n", $url, $gpoMap->width, $gpoMap->height);

}

/************************************************************************/
/*                      function GMapDrawKeyMap()                       */
/*                                                                      */
/*      Utility function to draw the refernece map (key map).           */
/************************************************************************/
function GMapDrawKeyMap()
{
    GLOBAL      $gpoMap;
    GLOBAL $gAppletImgFmt, $gImagesFmt;
	
    $img = $gpoMap->drawreferencemap();
    $url = $img->saveWebImage($gImagesFmt, 0, 0, -1);

    printf("<INPUT TYPE=HIDDEN NAME=KEYMAPXSIZE VALUE=\"%d\">", $img->width);
    printf("<INPUT TYPE=HIDDEN NAME=KEYMAPYSIZE VALUE=\"%d\">", $img->height);

//    echo"<IMG  SRC=$url  BORDER=0 >\n";
    echo"<INPUT  TYPE=image SRC=$url  BORDER=0 NAME=KEYMAP>";
}


/************************************************************************/
/*                     function GMapDrawScaleBar()                      */
/*                                                                      */
/*      Draw sacle bar.                                                 */
/************************************************************************/
function GMapDrawScaleBar()
{
    GLOBAL $gpoMap;
    GLOBAL $gAppletImgFmt, $gImagesFmt;
	
    $img = $gpoMap->drawScaleBar();
    $url = $img->saveWebImage($gImagesFmt, 0, 0, -1);

    echo"<IMG  SRC=$url  BORDER=0 >\n";

}


/************************************************************************/
/*function GMapPix2Geo($nPixPos, $dfPixMin, $dfPixMax, $dfGeoMin, dfGeoMax,*/
/*                           $nInversePix)                              */
/*                                                                      */
/*      Utility function to convert a pixel position to geocoded        */
/*      position.                                                       */
/*                                                                      */
/*       The parameter $nInversePix could be set to 1 for Y pixel       */
/*      coordinates where the UL > LR. Else set to 0.                   */
/************************************************************************/
function GMapPix2Geo($nPixPos, $dfPixMin, $dfPixMax, $dfGeoMin, $dfGeoMax, 
                     $nInversePix) 
{
    
//    if ($nPixPos < $dfPixMin)  
//        return -1;

//    if ($nPixPos > $dfPixMax)
//        return -1;

//    if ($dfPixMin >= $dfPixMaX || 
//        $dfGeoMin >= $dfGeoMax)
//        return -1;

    $dfWidthGeo = $dfGeoMax - $dfGeoMin;
    $dfWidthPix = $dfPixMax - $dfPixMin;
   
    
    $dfPixToGeo = $dfWidthGeo / $dfWidthPix;

    if (!$nInversePix)
        $dfDeltaPix = $nPixPos - $dfPixMin;
    else
        $dfDeltaPix = $dfPixMax - $nPixPos;

    $dfDeltaGeo = $dfDeltaPix * $dfPixToGeo;


    $dfPosGeo = $dfGeoMin + $dfDeltaGeo;

    return ($dfPosGeo);
}

/************************************************************************/
/*  function SetMapExtents($dfNewMinX, $dfNewMinY, $dfNewMaxX, $dfNewMaxY)*/
/*                                                                      */
/*          Set map extents of the map. We also make a test here with   */
/*          the min/max scale set in the .map file (the web object)     */
/*          to verify if the extents are respected. If it is the        */
/*          case return true. Else return false.                        */
/*                                                                      */
/*         Note : the extents of the map are still set using the        */
/*      parameters passed in argument. The caller has the               */
/*      responsability to check the return value.                       */
/************************************************************************/
function SetMapExtents($dfNewMinX, $dfNewMinY, $dfNewMaxX, $dfNewMaxY)
{
    GLOBAL $gpoMap;
    
    $gpoMap->setExtent($dfNewMinX, $dfNewMinY, $dfNewMaxX, $dfNewMaxY);

    $dfScale = $gpoMap->scale;

//  printf("scale : %f <BR>\n", $dfScale);
//  printf("minscale : %f<BR>\n",$gpoMap->web->minscale);
//  printf("maxscale : %f<BR>\n",$gpoMap->web->maxscale);

    if ($dfScale <  $gpoMap->web->minscale ||
        $dfScale >  $gpoMap->web->maxscale)
        return false;
    
        return true;
}

/************************************************************************/
/*                     function GMapDumpQueryResults()                  */
/*                                                                      */
/*      Produce a table with query results.                             */
/*      Simply prints an "&nbsp;" if there are no query results.        */
/************************************************************************/
function GMapDumpQueryResults()
{
    GLOBAL $gpoMap, $gbShowQueryResults;

    if (! $gbShowQueryResults )
    {
        printf("&nbsp;");
        return;
    }

    $numResultsTotal = 0;

    for($iLayer=0; $iLayer < $gpoMap->numlayers; $iLayer++)
    {
        $oLayer = $gpoMap->GetLayer($iLayer);

        $numResults = $oLayer->getNumResults();

        if ($numResults == 0)
            continue;  // No results in this layer

        // Open layer's table... take the list of fields to display from 
        // the "RESULT_FIELDS" metadata in the layer object.
        $oLayer->open();


	//
        // One row in table for each selected record
        //

        for ($iRes=0; $iRes < $numResults; $iRes++)
        {
            $oRes = $oLayer->getResult($iRes);

            $oShape = $oLayer->getShape($oRes->tileindex,$oRes->shapeindex);

            if ($iRes == 0)
            {
                //
                // Table header: attribute names...
                //
                if ($oLayer->getMetaData("RESULT_FIELDS"))
                {
                    // Display fields listed in RESULT_FIELDS metadata
                    $selFields = explode(" ", $oLayer->getMetaData("RESULT_FIELDS"));
                }
                else
                {
                    // RESULT_FIELDS not set. display first 4 fields
                    $i=0;
                    while ( list($key,$val) = each($oShape->values) ) 
                    {
                        $selFields[$i++] = $key;
                        if ($i>=4) break;
                    }
                }

                printf("<TABLE BORDER=0 CELLSPACING=1 CELLPADDING=2 WIDTH=100%%>\n");
                printf("<TR>\n");
                printf("<TD COLSPAN=%d BGCOLOR=#C1D8E3>", count($selFields));
                printf("<CENTER> %s </CENTER>", $oLayer->getMetaData("DESCRIPTION"));
                printf("</TD>\n");
                printf("</TR>\n");
                printf("<TR>\n");

                for ($iField=0; $iField < count($selFields); $iField++)
                {
                    printf("<TD BGCOLOR=#E2EFF7>");
                    printf("%s",$selFields[$iField]);
                    printf("</TD>\n");
                }
                printf("</TR>\n");	
            }


            printf("<TR>\n");	

            printf("<!-- bounds(%f, %f)-(%f, %f)-->\n", 
                   $oShape->bounds->minx, $oShape->bounds->miny,
                   $oShape->bounds->maxx, $oShape->bounds->maxy);
//            printf("<!-- ");
//            print_r($oShape);
//            printf(" -->\n");

            for($iField=0; $iField < sizeof($selFields); $iField++)
            {
                printf("<TD BGCOLOR=#FFFFFF>");
                printf("%s", $oShape->values[$selFields[$iField]]);
                printf("</TD>\n");
            }
            printf("</TR>\n");	

            $oShape->free();

            $numResultsTotal++;
        }

        $oLayer->close();

        printf("</TABLE>\n");
    }

    if ($numResultsTotal == 0)
        echo "Nothing found at query location.";

}


?>

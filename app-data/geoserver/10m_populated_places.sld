<?xml version="1.0" encoding="UTF-8"?>
<sld:StyledLayerDescriptor xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml" version="1.0.0">
  <sld:UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>Default Styler</sld:Name>
      <sld:Title>Default Styler</sld:Title>
      <sld:Abstract/>
      <sld:FeatureTypeStyle>
        <sld:Name>name</sld:Name>
        <sld:Title>title</sld:Title>
        <sld:Abstract>abstract</sld:Abstract>
        <sld:FeatureTypeName>Feature</sld:FeatureTypeName>
        <sld:SemanticTypeIdentifier>generic:geometry</sld:SemanticTypeIdentifier>
        <sld:SemanticTypeIdentifier>colorbrewer:equalinterval:oranges</sld:SemanticTypeIdentifier>
<sld:Rule>

          <sld:Name>Other Cities</sld:Name>
          <sld:Title>Other Cities</sld:Title>
          <sld:Abstract>Abstract</sld:Abstract>
          <sld:ElseFilter />

          
          <sld:MaxScaleDenominator>1e7</sld:MaxScaleDenominator>
          <sld:PointSymbolizer>
            <sld:Graphic>
              <sld:Mark>
                <sld:WellKnownName>square</sld:WellKnownName>
                <sld:Fill>
                  <sld:CssParameter name="fill">
                    <ogc:Literal>#ffffff</ogc:Literal>
                  </sld:CssParameter>
                  <sld:CssParameter name="fill-opacity">
                    <ogc:Literal>1.0</ogc:Literal>
                  </sld:CssParameter>
                </sld:Fill>
                <sld:Stroke>
                  <sld:CssParameter name="stroke">
                    <ogc:Literal>#000000</ogc:Literal>
                  </sld:CssParameter>
                </sld:Stroke>
              </sld:Mark>
              <sld:Opacity>
                <ogc:Literal>1.0</ogc:Literal>
              </sld:Opacity>
              <sld:Size>
                <ogc:Literal>5</ogc:Literal>
              </sld:Size>
              <sld:Rotation>
                <ogc:Literal>0.0</ogc:Literal>
              </sld:Rotation>
            </sld:Graphic>
          </sld:PointSymbolizer>
          <sld:TextSymbolizer>
            <sld:Label>
              <ogc:PropertyName>NAME</ogc:PropertyName>
            </sld:Label>
            <sld:Font>
              <sld:CssParameter name="font-family">Arial</sld:CssParameter>
              <sld:CssParameter name="font-family">Helvetica</sld:CssParameter>
              <sld:CssParameter name="font-family">Liberation Sans</sld:CssParameter>
              <sld:CssParameter name="font-family">SansSerif</sld:CssParameter>
              <sld:CssParameter name="font-size">
                <ogc:Literal>9.0</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="font-style">
                <ogc:Literal>normal</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="font-weight">
                <ogc:Literal>normal</ogc:Literal>
              </sld:CssParameter>
            </sld:Font>
           
            <sld:LabelPlacement>
              <sld:PointPlacement>
                <sld:AnchorPoint>
                  <sld:AnchorPointX>
                    <ogc:Literal>0.5</ogc:Literal>
                  </sld:AnchorPointX>
                  <sld:AnchorPointY>
                    <ogc:Literal>1.0</ogc:Literal>
                  </sld:AnchorPointY>
                </sld:AnchorPoint>
                <sld:Displacement>
                  <sld:DisplacementX>
                    <ogc:Literal>0</ogc:Literal>
                  </sld:DisplacementX>
                  <sld:DisplacementY>
                    <ogc:Literal>15</ogc:Literal>
                  </sld:DisplacementY>
                </sld:Displacement>
                <sld:Rotation>
                  <ogc:Literal>0.0</ogc:Literal>
                </sld:Rotation>
              </sld:PointPlacement>
            </sld:LabelPlacement>
            <sld:Halo>
              <sld:Radius>2</sld:Radius>
              <sld:Fill>
                <sld:CssParameter name="fill">#FFFFFF</sld:CssParameter>
              </sld:Fill>
            </sld:Halo>
            <sld:Fill>
              <sld:CssParameter name="fill">
                <ogc:Literal>#000000</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="fill-opacity">
                <ogc:Literal>1.0</ogc:Literal>
              </sld:CssParameter>
            </sld:Fill>
            <sld:Priority>
              <ogc:PropertyName>LABELRANK</ogc:PropertyName>
            </sld:Priority>
            <sld:VendorOption name="spaceAround">2</sld:VendorOption>
          </sld:TextSymbolizer>
        </sld:Rule>        
<sld:Rule>
          <sld:Name>Capitals</sld:Name>
          <sld:Title>Capitals</sld:Title>
          <sld:Abstract>Abstract</sld:Abstract>
          <ogc:Filter>

            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>ADM0CAP</ogc:PropertyName>
              <ogc:Literal>1</ogc:Literal>
            </ogc:PropertyIsEqualTo>


          </ogc:Filter>
          <sld:MinScaleDenominator>1</sld:MinScaleDenominator>
          <sld:MaxScaleDenominator>1e9</sld:MaxScaleDenominator>
          <sld:PointSymbolizer>
            <sld:Graphic>
              <sld:Mark>
                <sld:WellKnownName>star</sld:WellKnownName>
                <sld:Fill>
                  <sld:CssParameter name="fill">
                    <ogc:Literal>#ff0000</ogc:Literal>
                  </sld:CssParameter>
                  <sld:CssParameter name="fill-opacity">
                    <ogc:Literal>1.0</ogc:Literal>
                  </sld:CssParameter>
                </sld:Fill>
                <sld:Stroke>
                  <sld:CssParameter name="stroke">
                    <ogc:Literal>#000000</ogc:Literal>
                  </sld:CssParameter>
                </sld:Stroke>
              </sld:Mark>
              <sld:Opacity>
                <ogc:Literal>1.0</ogc:Literal>
              </sld:Opacity>
              <sld:Size>
                <ogc:Literal>10</ogc:Literal>
              </sld:Size>
              <sld:Rotation>
                <ogc:Literal>0.0</ogc:Literal>
              </sld:Rotation>
            </sld:Graphic>
          </sld:PointSymbolizer>
          <sld:TextSymbolizer>
            <sld:Label>
              <ogc:PropertyName>NAME</ogc:PropertyName>
            </sld:Label>
            <sld:Font>
              <sld:CssParameter name="font-family">Arial</sld:CssParameter>
              <sld:CssParameter name="font-family">Helvetica</sld:CssParameter>
              <sld:CssParameter name="font-family">Liberation Sans</sld:CssParameter>
              <sld:CssParameter name="font-family">SansSerif</sld:CssParameter>
              <sld:CssParameter name="font-size">
                <ogc:Literal>9.0</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="font-style">
                <ogc:Literal>normal</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="font-weight">
                <ogc:Literal>bold</ogc:Literal>
              </sld:CssParameter>
            </sld:Font>
            <sld:LabelPlacement>
              <sld:PointPlacement>
                <sld:AnchorPoint>
                  <sld:AnchorPointX>
                    <ogc:Literal>0.5</ogc:Literal>
                  </sld:AnchorPointX>
                  <sld:AnchorPointY>
                    <ogc:Literal>1.0</ogc:Literal>
                  </sld:AnchorPointY>
                </sld:AnchorPoint>
                <sld:Displacement>
                  <sld:DisplacementX>
                    <ogc:Literal>0</ogc:Literal>
                  </sld:DisplacementX>
                  <sld:DisplacementY>
                    <ogc:Literal>20</ogc:Literal>
                  </sld:DisplacementY>
                </sld:Displacement>
                <sld:Rotation>
                  <ogc:Literal>0.0</ogc:Literal>
                </sld:Rotation>
              </sld:PointPlacement>
            </sld:LabelPlacement>
            <sld:Halo>
              <sld:Radius>2</sld:Radius>
              <sld:Fill>
                <sld:CssParameter name="fill">#FFFFFF</sld:CssParameter>
              </sld:Fill>
            </sld:Halo>
            <sld:Fill>
              <sld:CssParameter name="fill">
                <ogc:Literal>#000000</ogc:Literal>
              </sld:CssParameter>
              <sld:CssParameter name="fill-opacity">
                <ogc:Literal>1.0</ogc:Literal>
              </sld:CssParameter>
            </sld:Fill>
            <sld:Priority>
              <ogc:PropertyName>LABELRANK</ogc:PropertyName>
            </sld:Priority>

            <sld:VendorOption name="spaceAround">2</sld:VendorOption>
          </sld:TextSymbolizer>
        </sld:Rule>
        
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </sld:UserLayer>
</sld:StyledLayerDescriptor>
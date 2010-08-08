<?xml version="1.0" encoding="UTF-8"?>
<sld:StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml" version="1.0.0">
    <sld:UserLayer>
        <sld:LayerFeatureConstraints>
            <sld:FeatureTypeConstraint/>
        </sld:LayerFeatureConstraints>
        <sld:UserStyle>
            <sld:Name>Default Styler</sld:Name>
            <sld:Title>Default Styler</sld:Title>
            <sld:FeatureTypeStyle>
                <sld:Name>simple</sld:Name>
                <sld:Title>title</sld:Title>
                <sld:Abstract>abstract</sld:Abstract>
                <sld:FeatureTypeName>Feature</sld:FeatureTypeName>
                <sld:SemanticTypeIdentifier>generic:geometry</sld:SemanticTypeIdentifier>
                <sld:SemanticTypeIdentifier>simple</sld:SemanticTypeIdentifier>
                <sld:Rule>
                    <sld:Name>name</sld:Name>
                    <sld:Title>title</sld:Title>
                    <sld:Abstract>Abstract</sld:Abstract>
                    <ogc:Filter>
                        <ogc:PropertyIsLessThanOrEqualTo>
                            <ogc:PropertyName>ScaleRank</ogc:PropertyName>
                            <ogc:Literal>1</ogc:Literal>
                        </ogc:PropertyIsLessThanOrEqualTo>
                    </ogc:Filter>
                    <sld:MinScaleDenominator>1.1E8</sld:MinScaleDenominator>
                    <sld:MaxScaleDenominator>1.7976931348623157E308</sld:MaxScaleDenominator>
                    <sld:LineSymbolizer>
                        <sld:Stroke>
                            <sld:CssParameter name="stroke">#0000FF</sld:CssParameter>
                        </sld:Stroke>
                    </sld:LineSymbolizer>
                </sld:Rule>
                <sld:Rule>
                    <sld:Name>name</sld:Name>
                    <sld:Title>title</sld:Title>
                    <sld:Abstract>Abstract</sld:Abstract>
                    <ogc:Filter>
                        <ogc:PropertyIsLessThanOrEqualTo>
                            <ogc:PropertyName>ScaleRank</ogc:PropertyName>
                            <ogc:Literal>3</ogc:Literal>
                        </ogc:PropertyIsLessThanOrEqualTo>
                    </ogc:Filter>
                    <sld:MinScaleDenominator>3.0E7</sld:MinScaleDenominator>
                    <sld:MaxScaleDenominator>1.1E8</sld:MaxScaleDenominator>
                    <sld:LineSymbolizer>
                        <sld:Stroke>
                            <sld:CssParameter name="stroke">#0000FF</sld:CssParameter>
                        </sld:Stroke>
                    </sld:LineSymbolizer>
                </sld:Rule>
                <sld:Rule>
                    <sld:Name>name</sld:Name>
                    <sld:Title>title</sld:Title>
                    <sld:Abstract>Abstract</sld:Abstract>
                    <ogc:Filter>
                        <ogc:PropertyIsLessThanOrEqualTo>
                            <ogc:PropertyName>ScaleRank</ogc:PropertyName>
                            <ogc:Literal>7</ogc:Literal>
                        </ogc:PropertyIsLessThanOrEqualTo>
                    </ogc:Filter>
                    <sld:MaxScaleDenominator>3.0E7</sld:MaxScaleDenominator>
                    <sld:LineSymbolizer>
                        <sld:Stroke>
                            <sld:CssParameter name="stroke">#0000ff</sld:CssParameter>
                            <sld:CssParameter name="stroke-linecap">round</sld:CssParameter>
                            <sld:CssParameter name="stroke-width">3.0</sld:CssParameter>
                        </sld:Stroke>
                    </sld:LineSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
            <sld:FeatureTypeStyle>
                <sld:Name>simple</sld:Name>
                <sld:Title>title</sld:Title>
                <sld:Abstract>abstract</sld:Abstract>
                <sld:FeatureTypeName>Feature</sld:FeatureTypeName>
                <sld:SemanticTypeIdentifier>generic:geometry</sld:SemanticTypeIdentifier>
                <sld:SemanticTypeIdentifier>simple</sld:SemanticTypeIdentifier>
                <sld:Rule>
                    <sld:Name>name</sld:Name>
                    <sld:Title>title</sld:Title>
                    <sld:Abstract>Abstract</sld:Abstract>
                    <ogc:Filter>
                        <ogc:PropertyIsLessThanOrEqualTo>
                            <ogc:PropertyName>ScaleRank</ogc:PropertyName>
                            <ogc:Literal>7</ogc:Literal>
                        </ogc:PropertyIsLessThanOrEqualTo>
                    </ogc:Filter>
                    <sld:MaxScaleDenominator>3.0E7</sld:MaxScaleDenominator>
                    <sld:LineSymbolizer>
                        <sld:Stroke>
                            <sld:CssParameter name="stroke">#4876FF</sld:CssParameter>
                            <sld:CssParameter name="stroke-linecap">round</sld:CssParameter>
                        </sld:Stroke>
                    </sld:LineSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
            <sld:FeatureTypeStyle>
                <sld:Name>simple</sld:Name>
                <sld:Title>title</sld:Title>
                <sld:Abstract>abstract</sld:Abstract>
                <sld:FeatureTypeName>Feature</sld:FeatureTypeName>
                <sld:SemanticTypeIdentifier>generic:geometry</sld:SemanticTypeIdentifier>
                <sld:SemanticTypeIdentifier>simple</sld:SemanticTypeIdentifier>
                <sld:Rule>
                    <sld:Name>name</sld:Name>
                    <sld:Title>title</sld:Title>
                    <sld:Abstract>Abstract</sld:Abstract>
                    <ogc:Filter>
                        <ogc:And>
                            <ogc:PropertyIsLessThanOrEqualTo>
                                <ogc:PropertyName>ScaleRank</ogc:PropertyName>
                                <ogc:Literal>7</ogc:Literal>
                            </ogc:PropertyIsLessThanOrEqualTo>
                            <ogc:PropertyIsEqualTo>
                                <ogc:PropertyName>FeatureCla</ogc:PropertyName>
                                <ogc:Literal>River</ogc:Literal>
                            </ogc:PropertyIsEqualTo>
                        </ogc:And>
                    </ogc:Filter>
                    <sld:MaxScaleDenominator>3.0E7</sld:MaxScaleDenominator>
                    <sld:TextSymbolizer>
                        <sld:Label>
                            <ogc:PropertyName>Name</ogc:PropertyName>
                        </sld:Label>
                        <sld:Font>
                            <sld:CssParameter name="font-family">SansSerif</sld:CssParameter>
                            <sld:CssParameter name="font-size">10</sld:CssParameter>
                            <sld:CssParameter name="font-style">normal</sld:CssParameter>
                            <sld:CssParameter name="font-weight">bold</sld:CssParameter>
                        </sld:Font>
                        <sld:LabelPlacement>
                            <sld:LinePlacement>
                                <sld:PerpendicularOffset>
                                    <ogc:Literal>10</ogc:Literal>
                                </sld:PerpendicularOffset>
                            </sld:LinePlacement>
                        </sld:LabelPlacement>
                        <sld:Halo>
                            <sld:Radius>
                                <ogc:Literal>2</ogc:Literal>
                            </sld:Radius>
                            <sld:Fill>
                                <sld:CssParameter name="fill">#FFFFFF</sld:CssParameter>
                            </sld:Fill>
                        </sld:Halo>
                        <sld:Fill>
                            <sld:CssParameter name="fill">#000000</sld:CssParameter>
                        </sld:Fill>
                        <sld:VendorOption name="maxAngleDelta">90</sld:VendorOption>
                        <sld:VendorOption name="followLine">true</sld:VendorOption>
                        <sld:VendorOption name="group">yes</sld:VendorOption>
                        <sld:VendorOption name="maxDisplacement">400</sld:VendorOption>
                    </sld:TextSymbolizer>
                </sld:Rule>
            </sld:FeatureTypeStyle>
        </sld:UserStyle>
    </sld:UserLayer>
</sld:StyledLayerDescriptor>

